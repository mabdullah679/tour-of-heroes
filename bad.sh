#!/usr/bin/env bash
# bad.sh - Build and Deploy script

# 1. Show the current Git status
echo "Showing current Git status..."
git status

# 2. Find all modified files from the 'git status' output
#    Using '--porcelain' makes it easier to parse:
#      - Lines with ' M' indicate a modified file
modified_files=$(git status --porcelain | grep '^ M' | awk '{print $2}')

# 3. If no files are modified, exit
if [ -z "$modified_files" ]; then
  echo "No modified files found. Nothing to commit."
  exit 0
fi

# 4. Add all modified files
echo "Adding modified files..."
git add $modified_files

# 5. Commit with the message "ci-cd"
echo "Committing changes with message 'ci-cd'..."
git commit -m "ci-cd"

# 6. Optional: If you want to push automatically, uncomment the next line:
git push origin main

echo "Done!"
