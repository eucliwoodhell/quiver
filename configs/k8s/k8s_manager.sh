#!/usr/bin/env bash
# Universal version compatible with macOS (old Bash) and Linux

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# --- Utility functions ---

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo -e "${RED}Error: command '$1' not found.${NC}"
    exit 1
  }
}

# Wrapper for kubectl or kubecolor
KUBECTL_CMD="kubectl"
if command -v kubecolor >/dev/null 2>&1; then
  KUBECTL_CMD="kubecolor"
  echo -e "${GREEN}Using kubecolor.${NC}"
else
  echo -e "${YELLOW}kubecolor not found, using kubectl.${NC}"
fi

kc() {
  "$KUBECTL_CMD" "$@"
}

# Profile selection compatible with filter
select_profile() {
  local filter_type="${1:-}" # Can be "role" or empty
  profiles=()

  echo -e "${YELLOW}Searching for profiles in ~/.aws/config...${NC}"

  while IFS= read -r line; do
    if [[ -n "$line" ]]; then
      if [[ "$filter_type" == "role" ]]; then
        # Only profiles that END in role or rol
        if [[ "$line" == *rol || "$line" == *role ]]; then
          profiles+=("$line")
        fi
      else
        # Only profiles that DO NOT END in role or rol
        if [[ "$line" != *rol && "$line" != *role ]]; then
          profiles+=("$line")
        fi
      fi
    fi
  done < <(aws configure list-profiles)

  if [[ ${#profiles[@]} -eq 0 ]]; then
    echo -e "${RED}No profiles found matching the filter ($filter_type).${NC}"
    # If no filtered profiles, show all for safety or exit
    exit 1
  fi

  echo -e "${BLUE}Available AWS profiles (${filter_type:-Identity}):${NC}"
  for i in "${!profiles[@]}"; do
    printf "%d) %s\n" "$((i + 1))" "${profiles[$i]}"
  done

  while true; do
    read -rp "Select a profile (number): " option
    if [[ "$option" =~ ^[0-9]+$ ]] && ((option >= 1 && option <= ${#profiles[@]})); then
      PROFILE="${profiles[$((option - 1))]}"
      break
    fi
    echo -e "${RED}Invalid option.${NC}"
  done
}

# Compatible cluster selection
select_cluster() {
  echo -e "${YELLOW}Getting EKS cluster list in $REGION...${NC}"
  clusters=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && clusters+=("$line")
  done < <(aws eks list-clusters --profile "$PROFILE" --region "$REGION" --query 'clusters[]' --output text | tr '\t' '\n')

  if [[ ${#clusters[@]} -eq 0 ]]; then
    echo -e "${RED}No clusters found.${NC}"
    exit 1
  fi

  echo -e "${BLUE}Available EKS clusters:${NC}"
  for i in "${!clusters[@]}"; do
    printf "%d) %s\n" "$((i + 1))" "${clusters[$i]}"
  done

  while true; do
    read -rp "Select a cluster (number): " option
    if [[ "$option" =~ ^[0-9]+$ ]] && ((option >= 1 && option <= ${#clusters[@]})); then
      CLUSTER_NAME="${clusters[$((option - 1))]}"
      break
    fi
    echo -e "${RED}Invalid option.${NC}"
  done
}

# --- Pod Autocompletion ---
_get_pod_list() {
  kubectl get pods -n "$NAMESPACE" --no-headers -o custom-columns=":metadata.name"
}

# Configura Readline to use the pod list
_setup_pod_completion() {
  local pods
  pods=$(_get_pod_list)
  # This tells Bash how to complete for the 'read' command in this script
  complete -W "$pods" read_pod
}

# Function to read user input with autocompletion
read_pod() {
  local prompt="$1"
  local pod_var_name="$2"

  # Get pod list separated by spaces
  local pods
  pods=$(kubectl get pods -n "$NAMESPACE" --no-headers -o custom-columns=":metadata.name" | tr '\n' ' ')

  # Trick: Use 'compgen' to filter the list based on what the user types
  # Enable autocompletion for the 'read' command using Readline
  # IMPORTANT: Define the word list for autocompletion of this specific command
  complete -W "$pods" read_pod_internal 2>/dev/null || true

  # Use read -e to allow Readline usage
  # User must start typing and press TAB
  read -e -rp "$prompt" input
  eval "$pod_var_name=\"$input\""
}

# --- Initialization ---
require_cmd aws
require_cmd kubectl

echo -e "${BLUE}######### AWS & EKS Manager (Universal) #########${NC}"

# Initially search for those that DO NOT end in 'role'
select_profile "principal"

REGION="$(aws configure get region --profile "$PROFILE" || true)"
if [[ -z "${REGION}" ]]; then
  read -rp "Enter AWS region (e.g.: us-east-1): " REGION
fi

echo -e "${YELLOW}Starting SSO session...${NC}"
while true; do
  if aws sso login --profile "$PROFILE"; then
    echo -e "${GREEN}SSO login successful.${NC}"
    break
  else
    echo -e "${RED}Error or cancellation in SSO login.${NC}"
    read -rp "Do you want to retry the login? (y/n): " REINTENTAR
    if [[ ! "$REINTENTAR" =~ ^[Yy]$ ]]; then
      echo -e "${YELLOW}Exiting script...${NC}"
      exit 1
    fi
  fi
done

select_cluster

# echo -e "${YELLOW}Updating kubeconfig for $CLUSTER_NAME...${NC}"
# aws eks update-kubeconfig --name "$CLUSTER_NAME" --profile "$PROFILE"

read -rp "Kubernetes Namespace [default]: " NAMESPACE
NAMESPACE="${NAMESPACE:-default}"

# --- Main Menu ---
while true; do
  echo -e "\n${BLUE}Context: ${GREEN}$PROFILE${NC} | ${BLUE}Cluster: ${GREEN}$CLUSTER_NAME${NC}"
  echo -e "${BLUE}Current Namespace: ${YELLOW}$NAMESPACE${NC}"
  echo "1) List pods"
  echo "2) Connect to a pod"
  echo "3) View pod logs"
  echo "4) Change namespace"
  echo "5) Delete JOBS with prefix 'job-'"
  echo "6) Change Role / Profile (Login + Kubeconfig)"
  echo "7) Add New Profile/Role to AWS Config"
  echo "8) Exit"
  read -rp "Select an option: " OPTION

  case "$OPTION" in
  1)
    kc get pods -n "$NAMESPACE" -o wide
    ;;
  2)
    echo -e "${YELLOW}Loading pod list... (Use TAB to autocomplete)${NC}"
    _get_pod_list
    read_pod "Pod name: " POD
    # Try bash, if fails try sh
    kc exec -it -n "$NAMESPACE" "$POD" -- /bin/bash || kc exec -it -n "$NAMESPACE" "$POD" -- /bin/sh
    ;;
  3)
    echo -e "${YELLOW}Loading pod list... (Use TAB to autocomplete)${NC}"
    _get_pod_list
    read_pod "Pod name: " POD
    echo -e "${YELLOW}Logs for $POD (last 200 lines):${NC}"
    kc logs -n "$NAMESPACE" "$POD" --tail=200 -f
    ;;
  4)
    read -rp "New namespace: " NAMESPACE
    ;;
  5)
    echo -e "${RED}Searching for jobs in $NAMESPACE...${NC}"
    # Filter compatible with all AWK
    JOBS=$(kubectl get jobs -n "$NAMESPACE" --no-headers | awk '$1 ~ /^job-/ {print $1}')
    if [[ -z "$JOBS" ]]; then
      echo "No jobs starting with 'job-' found."
    else
      echo -e "${YELLOW}To delete:${NC}\n$JOBS"
      read -rp "Confirm deletion? (yes/n): " CONFIRM
      if [[ "$CONFIRM" == "yes" ]]; then
        echo "$JOBS" | xargs -r -n 1 kc delete job -n "$NAMESPACE"
      else
        echo "Cancelled."
      fi
    fi
    ;;
  6)
    echo -e "${YELLOW}Changing to a ROLE profile (profiles ending in 'rol')...${NC}"
    # Filter to only show those ending in 'rol'
    select_profile "role"

    REGION="$(aws configure get region --profile "$PROFILE" || true)"
    if [[ -z "${REGION}" ]]; then
      read -rp "Enter region for this profile: " REGION
    fi

    echo -e "${YELLOW}Getting clusters for new role...${NC}"
    select_cluster

    echo -e "${YELLOW}Associating kubeconfig...${NC}"
    aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION" --profile "$PROFILE"
    ;;
  7)
    echo -e "${BLUE}######### Configure New Role Profile (AssumeRole) #########${NC}"
    read -rp "New profile name (e.g.: prod-admin-role): " NEW_P
    read -rp "Role ARN (arn:aws:iam::...): " NEW_ARN

    # List profiles to choose source_profile
    echo -e "${YELLOW}Select source profile (source_profile):${NC}"
    select_profile "principal"
    SOURCE_P="$PROFILE"

    read -rp "Region (e.g.: us-east-1): " NEW_REG

    echo -e "${YELLOW}Writing to ~/.aws/config...${NC}"
    cat >>~/.aws/config <<EOF

[profile $NEW_P]
role_arn = $NEW_ARN
source_profile = $SOURCE_P
region = $NEW_REG
output = json
EOF
    echo -e "${GREEN}Profile '$NEW_P' added successfully.${NC}"
    echo -e "${YELLOW}Now you can use option 6 to activate this role.${NC}"
    ;;

  8)
    exit 0
    ;;

  *)
    echo "Invalid option."
    ;;
  esac
done
