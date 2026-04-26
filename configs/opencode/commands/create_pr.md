---
description: Creates a PR of the current branch
agent: build
model: opencode/minimax-m2.5-free
subtask: true
---

create a github PR to my main branch using the specified commands and rules.

**Instructions**

1. Inspect with a git diff everyting that has changed on this branch in comparison with de the main branch.

2. Create a PR with the following params:

- **head** the current branch. `git branch --show-current`
- **title** short and appropriate title base on the changes of the PR.
- **body** change in short bullet points listed. Nothing else.

3. Follow extra instructions passed by the user EVEN if the override previous instructions listed here.

**extra-user-instructions**: $ARGUMENTS

**CLI command syntax**

```
gh pr create \
    --base main \
    --head <FILL_IN_ACCORDINGLY> \
    --title <FILL_IN_ACCORDINGLY> \
    --body <FILL_IN_ACCORDINGLY>
```

