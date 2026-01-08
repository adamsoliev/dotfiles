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

# Flow 3: Add SSH rule for current IP
add_ssh_rule() {
    echo "Fetching your current public IP..."
    my_ip=$(curl -s https://checkip.amazonaws.com)

    if [ -z "$my_ip" ]; then
        echo "Failed to fetch your public IP."
        exit 1
    fi

    echo "Your IP: $my_ip"
    echo ""
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

    # Get the security group ID for the selected instance
    sg_id=$(aws ec2 describe-instances \
        --instance-ids "$selected_id" \
        --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
        --output text)

    if [ -z "$sg_id" ] || [ "$sg_id" = "None" ]; then
        echo "No security group found for this instance."
        exit 1
    fi

    sg_name=$(aws ec2 describe-instances \
        --instance-ids "$selected_id" \
        --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupName' \
        --output text)

    echo ""
    echo "Security group: $sg_name ($sg_id)"
    echo "Adding SSH rule for $my_ip/32..."

    # Check if rule already exists
    existing_rule=$(aws ec2 describe-security-group-rules \
        --filters "Name=group-id,Values=$sg_id" \
        --query "SecurityGroupRules[?IpProtocol=='tcp' && FromPort==\`22\` && ToPort==\`22\` && CidrIpv4=='$my_ip/32'].SecurityGroupRuleId" \
        --output text)

    if [ -n "$existing_rule" ]; then
        echo "SSH rule for $my_ip/32 already exists."
        exit 0
    fi

    aws ec2 authorize-security-group-ingress \
        --group-id "$sg_id" \
        --protocol tcp \
        --port 22 \
        --cidr "$my_ip/32" \
        --output text

    echo ""
    echo "SSH rule added successfully!"
    echo "You can now SSH to the instance from $my_ip"
}

# Flow 4: Expand EBS volume
expand_ebs_volume() {
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
    echo "Fetching EBS volumes for instance $selected_id..."

    # Get volumes attached to the instance
    volumes=$(aws ec2 describe-volumes \
        --filters "Name=attachment.instance-id,Values=$selected_id" \
        --query 'Volumes[*].[VolumeId,Size,Attachments[0].Device]' \
        --output text)

    if [ -z "$volumes" ]; then
        echo "No EBS volumes found for this instance."
        exit 0
    fi

    echo ""
    echo "Attached EBS volumes:"
    echo "---------------------"

    local -a volume_ids
    local -a volume_sizes
    local i=1

    while read -r vol_id size device; do
        volume_ids+=("$vol_id")
        volume_sizes+=("$size")
        printf "%d) %s - %s GB (%s)\n" "$i" "$vol_id" "$size" "$device"
        ((i++))
    done <<< "$volumes"

    echo ""
    read -p "Select volume to expand (1-$((i-1))): " vol_selection

    if ! [[ "$vol_selection" =~ ^[0-9]+$ ]] || [ "$vol_selection" -lt 1 ] || [ "$vol_selection" -gt $((i-1)) ]; then
        echo "Invalid selection."
        exit 1
    fi

    selected_vol="${volume_ids[$((vol_selection-1))]}"
    current_size="${volume_sizes[$((vol_selection-1))]}"

    echo ""
    echo "Selected volume: $selected_vol (currently $current_size GB)"
    read -p "Enter new size in GB (must be >= $current_size): " new_size

    if ! [[ "$new_size" =~ ^[0-9]+$ ]] || [ "$new_size" -lt "$current_size" ]; then
        echo "Invalid size. New size must be a number >= $current_size GB."
        exit 1
    fi

    if [ "$new_size" -eq "$current_size" ]; then
        echo "New size is the same as current size. No changes made."
        exit 0
    fi

    echo ""
    echo "Expanding volume $selected_vol from $current_size GB to $new_size GB..."

    aws ec2 modify-volume \
        --volume-id "$selected_vol" \
        --size "$new_size" \
        --output text

    echo ""
    echo "Volume modification initiated!"
    echo ""
    echo "IMPORTANT: After the volume modification completes, you need to"
    echo "extend the filesystem on the instance. SSH into the instance and run:"
    echo ""
    echo "  # Check the partition (usually xvda1 or nvme0n1p1)"
    echo "  lsblk"
    echo ""
    echo "  # For ext4 filesystems:"
    echo "  sudo growpart /dev/xvda 1  # or /dev/nvme0n1 1"
    echo "  sudo resize2fs /dev/xvda1  # or /dev/nvme0n1p1"
    echo ""
    echo "  # For xfs filesystems:"
    echo "  sudo growpart /dev/xvda 1"
    echo "  sudo xfs_growfs /"
}

# Flow 5: Stop a running instance
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
echo "3) Add SSH rule for current IP"
echo "4) Expand EBS volume"
echo "5) Stop a running instance"
echo ""
read -p "Choose an option (1-5): " option

case $option in
    1) start_instance ;;
    2) select_running_instance ;;
    3) add_ssh_rule ;;
    4) expand_ebs_volume ;;
    5) stop_instance ;;
    *) echo "Invalid option."; exit 1 ;;
esac
