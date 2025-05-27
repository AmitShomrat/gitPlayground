set -e  # Stop if any command fails

# 💬 Step 1: Commit local changes
echo "📦 Staging and committing local changes..."
git add .
git commit -m "${1:-Auto commit before combining with remote}" || echo "ℹ️ Nothing to commit."

# 💬 Step 2: Stash the commit just in case we’re behind origin
echo "📥 Stashing local changes before pull..."
git stash push --include-untracked -m "temp-stash-before-pull"

# 💬 Step 3: Pull remote changes with rebase
echo "🔁 Pulling remote changes with rebase..."
git pull --rebase || {
  echo "❌ Pull failed. Aborting rebase..."
  git rebase --abort
  exit 1
}

# 💬 Step 4: Reapply stashed changes
echo "📤 Applying stashed changes..."
git stash apply

# 💬 Step 5: Auto-resolve all conflicts in favor of local (stashed) version
echo "⚔️ Resolving conflicts by keeping your local changes..."
CONFLICT_FILES=$(git diff --name-only --diff-filter=U)
if [ -n "$CONFLICT_FILES" ]; then
  echo "$CONFLICT_FILES" | while read -r file; do
    git checkout --ours "$file"
    git add "$file"
  done
fi

# 💬 Step 6: Finish rebase
echo "✅ Continuing rebase..."
git rebase --continue || echo "ℹ️ No rebase in progress."

# 💬 Step 7: Push the combined result
echo "🚀 Pushing changes to remote..."
git push

# 💬 Done
echo "🎉 Done! Your changes and remote changes have been combined and pushed successfully."
