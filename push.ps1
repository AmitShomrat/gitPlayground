# 1. Stash all changes
git stash push --include-untracked --keep-index -m "auto-stash-before-pull"

# 2. Pull remote changes
git pull --rebase

# 3. Apply stash back
git stash apply

# 4. Auto-resolve in favor of stashed version (ours)
git diff --name-only --diff-filter=U | xargs -I{} git checkout --ours "{}"
git add .

# 5. Continue rebase
git rebase --continue

# 6. Push changes
git push
