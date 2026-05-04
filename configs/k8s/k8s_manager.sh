#!/usr/bin/env bash
# Versión universal compatible con macOS (Bash viejo) y Linux

# --- Colores ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# --- Funciones de utilidad ---

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo -e "${RED}Error: no se encontró el comando '$1'.${NC}"
    exit 1
  }
}

# Wrapper para kubectl o kubecolor
KUBECTL_CMD="kubectl"
if command -v kubecolor >/dev/null 2>&1; then
  KUBECTL_CMD="kubecolor"
  echo -e "${GREEN}Usando kubecolor.${NC}"
else
  echo -e "${YELLOW}kubecolor no encontrado, usando kubectl.${NC}"
fi

kc() {
  "$KUBECTL_CMD" "$@"
}

# Selección de perfil compatible con filtro
select_profile() {
  local filter_type="${1:-}" # Puede ser "rol" o vacío
  profiles=()

  echo -e "${YELLOW}Buscando perfiles en ~/.aws/config...${NC}"

  while IFS= read -r line; do
    if [[ -n "$line" ]]; then
      if [[ "$filter_type" == "rol" ]]; then
        # Solo perfiles que TERMINAN en rol o role
        if [[ "$line" == *rol || "$line" == *role ]]; then
          profiles+=("$line")
        fi
      else
        # Solo perfiles que NO TERMINAN en rol ni role
        if [[ "$line" != *rol && "$line" != *role ]]; then
          profiles+=("$line")
        fi
      fi
    fi
  done < <(aws configure list-profiles)

  if [[ ${#profiles[@]} -eq 0 ]]; then
    echo -e "${RED}No se encontraron perfiles que coincidan con el filtro ($filter_type).${NC}"
    # Si no hay perfiles filtrados, mostramos todos por seguridad o salimos
    exit 1
  fi

  echo -e "${BLUE}Perfiles AWS disponibles (${filter_type:-Identidad}):${NC}"
  for i in "${!profiles[@]}"; do
    printf "%d) %s\n" "$((i + 1))" "${profiles[$i]}"
  done

  while true; do
    read -rp "Selecciona un perfil (número): " option
    if [[ "$option" =~ ^[0-9]+$ ]] && ((option >= 1 && option <= ${#profiles[@]})); then
      PROFILE="${profiles[$((option - 1))]}"
      break
    fi
    echo -e "${RED}Opción inválida.${NC}"
  done
}

# Selección de clúster compatible (Sustituye mapfile)
select_cluster() {
  echo -e "${YELLOW}Obteniendo lista de clústeres EKS en $REGION...${NC}"
  clusters=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && clusters+=("$line")
  done < <(aws eks list-clusters --profile "$PROFILE" --region "$REGION" --query 'clusters[]' --output text | tr '\t' '\n')

  if [[ ${#clusters[@]} -eq 0 ]]; then
    echo -e "${RED}No se encontraron clústeres.${NC}"
    exit 1
  fi

  echo -e "${BLUE}Clústeres EKS disponibles:${NC}"
  for i in "${!clusters[@]}"; do
    printf "%d) %s\n" "$((i + 1))" "${clusters[$i]}"
  done

  while true; do
    read -rp "Selecciona un clúster (número): " option
    if [[ "$option" =~ ^[0-9]+$ ]] && ((option >= 1 && option <= ${#clusters[@]})); then
      CLUSTER_NAME="${clusters[$((option - 1))]}"
      break
    fi
    echo -e "${RED}Opción inválida.${NC}"
  done
}

# --- Autocompletado de Pods ---
_get_pod_list() {
  kubectl get pods -n "$NAMESPACE" --no-headers -o custom-columns=":metadata.name"
}

# Configura Readline para usar la lista de pods
_setup_pod_completion() {
  local pods
  pods=$(_get_pod_list)
  # Esto le dice a Bash cómo completar para el comando 'read' en este script
  complete -W "$pods" read_pod
}

# Función para leer la entrada del usuario con autocompletado
read_pod() {
  local prompt="$1"
  local pod_var_name="$2"

  # Obtenemos la lista de pods separada por espacios
  local pods
  pods=$(kubectl get pods -n "$NAMESPACE" --no-headers -o custom-columns=":metadata.name" | tr '\n' ' ')

  # Truco: Usamos 'compgen' para filtrar la lista basándonos en lo que el usuario escribe
  # Habilitamos autocompletado para el comando 'read' usando Readline
  # IMPORTANTE: Definimos la lista de palabras para el autocompletado de este comando específico
  complete -W "$pods" read_pod_internal 2>/dev/null || true

  # Usamos read -e para permitir el uso de Readline
  # El usuario debe empezar a escribir y presionar TAB
  read -e -rp "$prompt" input
  eval "$pod_var_name=\"$input\""
}

# --- Inicialización ---
require_cmd aws
require_cmd kubectl

echo -e "${BLUE}######### AWS & EKS Manager (Universal) #########${NC}"

# Inicialmente buscamos los que NO terminan en 'rol'
select_profile "principal"

REGION="$(aws configure get region --profile "$PROFILE" || true)"
if [[ -z "${REGION}" ]]; then
  read -rp "Ingresa la región AWS (ej: us-east-1): " REGION
fi

echo -e "${YELLOW}Iniciando sesión SSO...${NC}"
while true; do
  if aws sso login --profile "$PROFILE"; then
    echo -e "${GREEN}Login SSO exitoso.${NC}"
    break
  else
    echo -e "${RED}Error o cancelación en el Login SSO.${NC}"
    read -rp "¿Deseas reintentar el login? (s/n): " REINTENTAR
    if [[ ! "$REINTENTAR" =~ ^[Ss]$ ]]; then
      echo -e "${YELLOW}Saliendo del script...${NC}"
      exit 1
    fi
  fi
done

select_cluster

# echo -e "${YELLOW}Actualizando kubeconfig para $CLUSTER_NAME...${NC}"
# aws eks update-kubeconfig --name "$CLUSTER_NAME" --profile "$PROFILE"

read -rp "Namespace Kubernetes [default]: " NAMESPACE
NAMESPACE="${NAMESPACE:-default}"

# --- Menú Principal ---
while true; do
  echo -e "\n${BLUE}Contexto: ${GREEN}$PROFILE${NC} | ${BLUE}Cluster: ${GREEN}$CLUSTER_NAME${NC}"
  echo -e "${BLUE}Namespace actual: ${YELLOW}$NAMESPACE${NC}"
  echo "1) Listar pods"
  echo "2) Conectar a un pod"
  echo "3) Ver logs de un pod"
  echo "4) Cambiar namespace"
  echo "5) Eliminar JOBS con prefijo 'job-'"
  echo "6) Cambiar de Rol / Perfil (Login + Kubeconfig)"
  echo "7) Agregar Nuevo Perfil/Rol a AWS Config"
  echo "8) Salir"
  read -rp "Selecciona una opción: " OPTION

  case "$OPTION" in
  1)
    kc get pods -n "$NAMESPACE" -o wide
    ;;
  2)
    echo -e "${YELLOW}Cargando lista de pods... (Usa TAB para autocompletar)${NC}"
    _get_pod_list
    read_pod "Nombre del pod: " POD
    # Intenta bash, si falla intenta sh
    kc exec -it -n "$NAMESPACE" "$POD" -- /bin/bash || kc exec -it -n "$NAMESPACE" "$POD" -- /bin/sh
    ;;
  3)
    echo -e "${YELLOW}Cargando lista de pods... (Usa TAB para autocompletar)${NC}"
    _get_pod_list
    read_pod "Nombre del pod: " POD
    echo -e "${YELLOW}Logs de $POD (últimas 200 líneas):${NC}"
    kc logs -n "$NAMESPACE" "$POD" --tail=200 -f
    ;;
  4)
    read -rp "Nuevo namespace: " NAMESPACE
    ;;
  5)
    echo -e "${RED}Buscando jobs en $NAMESPACE...${NC}"
    # Filtrado compatible con todos los AWK
    JOBS=$(kubectl get jobs -n "$NAMESPACE" --no-headers | awk '$1 ~ /^job-/ {print $1}')
    if [[ -z "$JOBS" ]]; then
      echo "No hay jobs que empiecen por 'job-'."
    else
      echo -e "${YELLOW}A eliminar:${NC}\n$JOBS"
      read -rp "¿Confirmar eliminación? (sí/n): " CONFIRM
      if [[ "$CONFIRM" == "sí" ]]; then
        echo "$JOBS" | xargs -r -n 1 kc delete job -n "$NAMESPACE"
      else
        echo "Cancelado."
      fi
    fi
    ;;
  6)
    echo -e "${YELLOW}Cambiando a un perfil de ROL (perfiles terminados en 'rol')...${NC}"
    # Filtramos para que solo muestre los que terminan en 'rol'
    select_profile "rol"

    REGION="$(aws configure get region --profile "$PROFILE" || true)"
    if [[ -z "${REGION}" ]]; then
      read -rp "Ingresa la región para este perfil: " REGION
    fi

    echo -e "${YELLOW}Obteniendo clústeres para el nuevo rol...${NC}"
    select_cluster

    echo -e "${YELLOW}Asociando kubeconfig...${NC}"
    aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION" --profile "$PROFILE"
    ;;
  7)
    echo -e "${BLUE}######### Configurar Nuevo Perfil de Rol (AssumeRole) #########${NC}"
    read -rp "Nombre del nuevo perfil (ej: prod-admin-role): " NEW_P
    read -rp "Role ARN (arn:aws:iam::...): " NEW_ARN

    # Listamos perfiles para elegir el source_profile
    echo -e "${YELLOW}Selecciona el perfil origen (source_profile):${NC}"
    select_profile "principal"
    SOURCE_P="$PROFILE"

    read -rp "Región (ej: us-east-1): " NEW_REG

    echo -e "${YELLOW}Escribiendo en ~/.aws/config...${NC}"
    cat >>~/.aws/config <<EOF

[profile $NEW_P]
role_arn = $NEW_ARN
source_profile = $SOURCE_P
region = $NEW_REG
output = json
EOF
    echo -e "${GREEN}Perfil '$NEW_P' agregado correctamente.${NC}"
    echo -e "${YELLOW}Ahora puedes usar la opción 6 para activar este rol.${NC}"
    ;;

  8)
    exit 0
    ;;

  *)
    echo "Opción inválida."
    ;;
  esac
done
