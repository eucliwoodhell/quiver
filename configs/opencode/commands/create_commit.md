---
description: Creates a commit of the current branch
agent: build
model: opencode/minimax-m2.5-free
subtask: true
---

create a github commit to branch using the specified commands and rules.

**Instructions**

1. Angular Commit Message Format
   The standard format is:
   <type>(<scope>): <short description>
   **Allowed Types:** - **feat**: A new feature for the user. - **fix**: A bug fix. - **docs**: Documentation only changes. - **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc). - **refactor**: A code change that neither fixes a bug nor adds a feature. - **perf**: A code change that improves performance. - **test**: Adding missing tests or correcting existing tests. - **build**: Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm). - **ci**: Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs). - **chore**: Other changes that don't modify src or test files.

2. Terminal Command Sequence

- **Step 1: Stage your changes** Add the files you want to include in the commit.

```
git add .
```

Or add specific files:

```
git add <file1> <file2> <file3>
```

- **Step 2: Commit your changes** Commit your changes with a message.

```
git commit -m "<commit message>"
```

**Example Commit Message:**

```
git commit -m "feat(auth): add password strength validation"
```

- **Step 3: Push your changes** Push your changes to the remote repository.

```
git push origin main
```

or

```
git push origin <branch_name>
```

3. Best Practices

- **Scope**: The parenthesis is optional but highly recommended to indicate which part of the project was modified.
- **Description**: Use the imperative, present tense: "change" not "changed" nor "changes".
- **No period**: Do not capitalize the first letter and do not end the description with a dot (.).
- **Extended Message**: If the change is complex, you can add a body:

```
git commit -m "feat(ui): redesign submit button" -m "Changed color to blue and added a loading animation to improve UX."
```
