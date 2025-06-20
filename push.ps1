param (
    [string]$CommitMessage = "Auto commit before combining with remote"
)

Write-Host "📦 Staging and committing local changes..."
git add .
try {
    git commit -m "$CommitMessage"
} catch {
    Write-Host "ℹ️ Nothing to commit or already committed."
}

Write-Host "📥 Stashing changes before pulling..."
git stash push --include-untracked -m "temp-stash-before-pull"

Write-Host "🔁 Pulling latest changes with rebase..."
try {
    git pull --rebase
} catch {
    Write-Host "❌ Pull failed. Aborting rebase..."
    git rebase --abort
    exit 1
}

Write-Host "📤 Applying stashed changes..."
try {
    git stash apply
} catch {
    Write-Host "⚠️ No stash found or nothing to apply."
}

Write-Host "⚔️ Resolving conflicts in favor of your stashed changes..."
$conflictedFiles = git diff --name-only --diff-filter=U
if ($conflictedFiles) {
    foreach ($file in $conflictedFiles) {
        git checkout --ours $file
        git add $file
    }

    Write-Host "✅ Continuing rebase..."
    try {
        git rebase --continue
    } catch {
        Write-Host "⚠️ Rebase could not be continued automatically."
    }
}

Write-Host "🚀 Pushing to remote..."
git push

Write-Host "🎉 Done! Your changes and remote updates are now combined and pushed."
