#!/bin/bash

# Max iterations to prevent infinite loop
MAX_LOOPS=200
COUNT=0
export GIT_EDITOR=true

while [ $COUNT -lt $MAX_LOOPS ]; do
    echo "--- Iteration $COUNT ---"
    
    # Check if rebase is in progress
    if ! git status | grep -q "rebase in progress"; then
        echo "Rebase complete!"
        exit 0
    fi
    
    # Check for unmerged paths (conflicts)
    if git status | grep -q "Unmerged paths"; then
        echo "Conflicts detected. Accepting 'theirs' (current branch changes)..."
        git checkout --theirs .
        git add .
        echo "Continuing rebase..."
        git rebase --continue
    else
        # No conflicts detected immediately
        # Check if clean working tree (meaning empty commit or needs skip)
        if git status | grep -q "nothing to commit, working tree clean"; then
            echo "Empty commit or clean tree. Skipping..."
            git rebase --skip
        else
            echo "Status unknown or just paused. attempting continue..."
            git rebase --continue
        fi
    fi
    
    COUNT=$((COUNT+1))
done

echo "Max loops reached. Exiting."
exit 1
