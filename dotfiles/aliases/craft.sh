charmcraft_purge() {
  for instance in $(lxc list --project=charmcraft --format json | jq -r '.[] | select(.name | startswith("charmcraft-")) | .name');
  do
    lxc --project=charmcraft delete $instance
  done
}

# Helper function that handles the common *craft.yaml detection and command execution.
# This function is used internally by the public commands (pack, build, prime).
#
# Usage: _craft_command <subcommand> [craft_type] [args...]
#   subcommand: The *craft subcommand to run (e.g., "pack", "build", "prime")
#   craft_type: Optional. The type of craft to use (e.g., "snap", "charm", "rock")
#              Required only if multiple *craft.yaml files are present
#   args:       Optional. Additional arguments to pass to the *craft command
#
# Examples:
#   _craft_command "pack" --debug
#   _craft_command "build" snap --verbose
#   _craft_command "prime" charm --destructive-mode
_craft_command() {
    local subcommand="$1"
    shift  # Remove the subcommand from arguments

    # Find all *craft.yaml files in the current directory
    local craft_files=()
    local craft_apps=()
    local i=0

    # Use find to get all *craft.yaml files and store them
    while IFS= read -r yaml_file; do
        # Strip the ./ prefix if present
        yaml_file="${yaml_file#./}"
        # Get the prefix (everything before 'craft.yaml')
        local prefix="${yaml_file%craft.yaml}"
        # Check if the corresponding *craft command exists
        if command -v "${prefix}craft" >/dev/null 2>&1; then
            craft_files+=("$yaml_file")
            craft_apps+=("${prefix}craft")
            ((i++))
        else
            echo "Warning: Found $yaml_file but ${prefix}craft command not found in PATH"
        fi
    done < <(find . -maxdepth 1 -name "*craft.yaml" -type f)

    local total_crafts=${#craft_files[@]}

    # If no valid *craft.yaml files found
    if [[ $total_crafts -eq 0 ]]; then
        echo "Error: No valid *craft.yaml files found in current directory"
        return 1
    fi

    # If only one *craft.yaml file exists, use it directly
    if [[ $total_crafts -eq 1 ]]; then
        "${craft_apps[0]}" "$subcommand" "$@"
        return 0
    fi

    # If multiple *craft.yaml files exist, require an argument
    if [[ $total_crafts -gt 1 ]]; then
        if [[ -z "$1" ]]; then
            echo "Error: Multiple *craft.yaml files found. Please specify which to use:"
            for ((i=0; i<total_crafts; i++)); do
                local prefix="${craft_apps[$i]%craft}"
                echo "  $subcommand $prefix    - for ${craft_files[$i]}"
            done
            return 1
        fi

        # Store the first argument and shift it off
        local craft_type="$1"
        shift

        # Find the matching craft application
        local found=0
        for ((i=0; i<total_crafts; i++)); do
            local prefix="${craft_apps[$i]%craft}"
            if [[ "$craft_type" == "$prefix" ]]; then
                "${craft_apps[$i]}" "$subcommand" "$@"
                found=1
                break
            fi
        done

        if [[ $found -eq 0 ]]; then
            echo "Error: Invalid argument. Available options:"
            for ((i=0; i<total_crafts; i++)); do
                local prefix="${craft_apps[$i]%craft}"
                echo "  $prefix    - for ${craft_files[$i]}"
            done
            return 1
        fi
    fi
}

# Function to handle the 'pack' subcommand for *craft applications.
# Automatically detects and uses the appropriate *craft command based on
# the presence of *craft.yaml files in the current directory.
#
# Usage: pack [craft_type] [args...]
#   craft_type: Optional. The type of craft to use (e.g., "snap", "charm", "rock")
#              Required only if multiple *craft.yaml files are present
#   args:       Optional. Additional arguments to pass to the *craft command
#
# Examples:
#   pack --debug                    # Uses single *craft.yaml if only one exists
#   pack snap --debug              # Explicitly uses snapcraft
#   pack charm --verbose           # Explicitly uses charmcraft
#   pack rock --destructive-mode   # Explicitly uses rockcraft
pack() {
    _craft_command "pack" "$@"
}

build() {
    _craft_command "build" "$@"
}

prime() {
    _craft_command "prime" "$@"
} 