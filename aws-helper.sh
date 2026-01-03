#!/bin/bash

set -e

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Install it with: brew install awscli"
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "AWS CLI is not configured. Run: aws configure"
    exit 1
fi

# Function to update SSH config with 'aws' alias
update_ssh_alias() {
    local public_dns=$1
    local ssh_config="$HOME/.ssh/config"
    local ssh_entry="Host aws
    HostName $public_dns
    User ubuntu
    IdentityFile ~/.ssh/tryqueueapp.pem"

    # Remove existing 'aws' host block if present
    if [ -f "$ssh_config" ]; then
        temp_file=$(mktemp)
        awk '/^Host aws$/{skip=1; next} /^Host /{skip=0} !skip' "$ssh_config" > "$temp_file"
        mv "$temp_file" "$ssh_config"
    fi

    # Append new entry
    echo "" >> "$ssh_config"
    echo "$ssh_entry" >> "$ssh_config"

    echo ""
    echo "SSH alias 'aws' configured. Connect with:"
    echo "  ssh aws"
}

# Function to select from a list of instances
select_instance() {
    local instances=$1
    local -a instance_ids
    local -a instance_names
    local i=1

    while read -r id name; do
        instance_ids+=("$id")
        instance_names+=("${name:-<no name>}")
        printf "%d) %s (%s)\n" "$i" "$id" "${name:-<no name>}" >&2
        ((i++))
    done <<< "$instances"

    echo "" >&2
    read -p "Select instance (1-$((i-1))): " selection

    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $((i-1)) ]; then
        echo "Invalid selection." >&2
        exit 1
    fi

    echo "${instance_ids[$((selection-1))]}"
}

# Flow 1: Start a stopped instance
start_instance() {
    echo "Fetching stopped instances..."

    instances=$(aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=stopped" \
        --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value | [0]]' \
        --output text)

    if [ -z "$instances" ]; then
        echo "No stopped instances found."
        exit 0
    fi

    echo ""
    echo "Stopped instances:"
    echo "-------------------"

    selected_id=$(select_instance "$instances")

    echo ""
    echo "Starting instance: $selected_id..."
    aws ec2 start-instances --instance-ids "$selected_id" --output text

    echo ""
    echo "Waiting for instance to be running..."
    aws ec2 wait instance-running --instance-ids "$selected_id"

    public_dns=$(aws ec2 describe-instances \
        --instance-ids "$selected_id" \
        --query 'Reservations[0].Instances[0].PublicDnsName' \
        --output text)

    echo ""
    echo "Instance $selected_id is now running!"

    if [ -z "$public_dns" ] || [ "$public_dns" = "None" ]; then
        echo "No public DNS available for this instance."
        exit 0
    fi

    echo "Public DNS: $public_dns"
    update_ssh_alias "$public_dns"
}

# Flow 2: Select a running instance
select_running_instance() {
    echo "Fetching running instances..."

    instances=$(aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value | [0]]' \
        --output text)

    if [ -z "$instances" ]; then
        echo "No running instances found."
        exit 0
    fi

    echo ""
    echo "Running instances:"
    echo "-------------------"

    selected_id=$(select_instance "$instances")

    public_dns=$(aws ec2 describe-instances \
        --instance-ids "$selected_id" \
        --query 'Reservations[0].Instances[0].PublicDnsName' \
        --output text)

    if [ -z "$public_dns" ] || [ "$public_dns" = "None" ]; then
        echo "No public DNS available for this instance."
        exit 0
    fi

    echo ""
    echo "Public DNS: $public_dns"
    update_ssh_alias "$public_dns"
}

# Flow 3: Stop a running instance
stop_instance() {
    echo "Fetching running instances..."

    instances=$(aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value | [0]]' \
        --output text)

    if [ -z "$instances" ]; then
        echo "No running instances found."
        exit 0
    fi

    echo ""
    echo "Running instances:"
    echo "-------------------"

    selected_id=$(select_instance "$instances")

    echo ""
    echo "Stopping instance: $selected_id..."
    aws ec2 stop-instances --instance-ids "$selected_id" --output text

    echo ""
    echo "Instance $selected_id is stopping."
}

# Main menu
echo "AWS Instance Helper"
echo "==================="
echo "1) Start a stopped instance"
echo "2) Select a running instance"
echo "3) Stop a running instance"
echo ""
read -p "Choose an option (1-3): " option

case $option in
    1) start_instance ;;
    2) select_running_instance ;;
    3) stop_instance ;;
    *) echo "Invalid option."; exit 1 ;;
esac
