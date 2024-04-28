#!/bin/bash

# TO BE RUN VIA CRON

ENVIRONMENT="PRODUCTION" # "PRODUCTION"
REPO_NAME="commit-farming"
REPO_FOLDER="/Users/lewistorrington/Repositories/personal/$REPO_NAME"

generate_random_text() {
    openssl rand -base64 15 | tr -dc 'a-zA-Z0-9' | head -c 10
}

create_payload_file() {
    # Find the next available payload file name
    index=0
    while true; do
        filename="payload-$(printf '%04d' $index).md"
        if [ ! -f "$filename" ]; then
            break
        fi
        ((index++))
    done

    # Create the payload file and fill it with random text
    touch "$REPO_FOLDER/$filename"
    for ((i = 0; i < 100; i++)); do
        generate_random_text >> "$REPO_FOLDER/$filename"
        echo >> "$REPO_FOLDER/$filename"
    done

    echo "File '$REPO_FOLDER/$filename' created with 100 lines of random text."
}

delete_random_payload_file() {
    # List all payload files
    files=($REPO_FOLDER/payload-*.md)

    if [ ${#files[@]} -eq 0 ]; then
        echo "No payload files found for deletion."
        return
    fi

    # Choose a random file from the list
    random_file="${files[RANDOM % ${#files[@]}]}"

    # Delete the chosen file
    rm "$random_file"
    echo "File '$random_file' deleted."
}

# Randomly choose between creating a new payload file or deleting an existing one
random_action=$((RANDOM % 2))
if [ "$random_action" -eq 0 ]; then
    create_payload_file
else
    delete_random_payload_file
fi

git_actions=("fix:" "feat:" "chore:" "refactor:")
subjects=("Lewis" "The cat" "My friend" "The weather" "A bird" "She" "He")
verbs=("runs" "plays" "eats" "loves" "reads" "jumps around" "programs" "coded")
objects=("the ball" "in the park" "a book" "every day" "with enthusiasm" "unapologetically")

# Function to pick a random element from an array
pick_random_element() {
    local array=("$@")
    local random_index=$((RANDOM % ${#array[@]}))
    echo "${array[random_index]}"
}

# Generate a random English-like sentence
random_commit_msg="$(pick_random_element "${git_actions[@]}") $(pick_random_element "${subjects[@]}") $(pick_random_element "${verbs[@]}") $(pick_random_element "${objects[@]}")"

if [ "$ENVIRONMENT" == "PRODUCTION" ]; then
    git -C $REPO_FOLDER add -A
    git -C $REPO_FOLDER commit -a -m "$random_commit_msg"
    git -C $REPO_FOLDER push
else
    echo "$random_commit_msg"
fi
