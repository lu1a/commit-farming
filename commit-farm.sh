#!/bin/bash

# TO BE RUN VIA CRON

ENVIRONMENT="PRODUCTION" # "DEVELOPMENT"
REPO_NAME="commit-farming"
REPO_FOLDER="/home/lewis/$REPO_NAME"

RANDOM_COMMIT_MSG=""

exit_if_time_during_sleeping_hours() {
    current_hour=$(date +%H)
    current_hour=$((10#$current_hour))
    day_of_week=$(date +%u)

    # Check if the current hour is between 23:00 and 09:00, or if it's Sunday
    if [[ "$current_hour" -ge 21 || "$current_hour" -lt 7 || "$day_of_week" -eq 7 ]]; then
        echo "Current time is in my resting hours. Exiting the script."
        exit 0
    fi
}

exit_at_random() {
    # Get the current day of the week (1 = Monday, 7 = Sunday)
    day_of_week=$(date +%u)
    
    # Calculate the random number range based on the day of the week
    random_num=$((RANDOM % 7 + 1))
    
    # Check if the random number is less than or equal to the day of the week
    if [ "$random_num" -le "$day_of_week" ]; then
        echo "Exiting script due to random chance on day $day_of_week."
        exit 0
    fi
}

generate_random_commit_msg() {
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
    RANDOM_COMMIT_MSG="$(pick_random_element "${git_actions[@]}") $(pick_random_element "${subjects[@]}") $(pick_random_element "${verbs[@]}") $(pick_random_element "${objects[@]}")"
}

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

    # Amount of lines to generate, between 1 and 100
    lines_to_generate=$((1 + RANDOM % 100))

    # Create the payload file and fill it with random text
    touch "$REPO_FOLDER/$filename"
    for ((i = 0; i < $lines_to_generate; i++)); do
        generate_random_text >> "$REPO_FOLDER/$filename"
        echo >> "$REPO_FOLDER/$filename"
    done

    echo "File '$REPO_FOLDER/$filename' created with $lines_to_generate lines of random text."
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

echo "$(date --utc +%Y-%m-%dT%H:%M:%SZ) -- Committing random BS to the commit farm"

git -C $REPO_FOLDER pull
exit_if_time_during_sleeping_hours
exit_at_random
generate_random_commit_msg

# Randomly choose between creating a new payload file or deleting an existing one
random_action=$((RANDOM % 2))
if [ "$random_action" -eq 0 ]; then
    create_payload_file
else
    delete_random_payload_file
fi

if [ "$ENVIRONMENT" == "PRODUCTION" ]; then
    git -C $REPO_FOLDER add -A
    git -C $REPO_FOLDER commit -a -m "$RANDOM_COMMIT_MSG"
    git -C $REPO_FOLDER push
else
    echo "$random_commit_msg"
fi
