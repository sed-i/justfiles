alias nsenter_all='sudo nsenter --mount --uts --ipc --net --pid -t'

rock_unpack() {
    local ARCHIVE_PATH="$1"
    local PROVIDED_TAG="$2"

    # Error out early if no arguments are provided
    if [ $# -eq 0 ]; then
        echo "Usage: unpack_oci_archive <path_to_oci_archive> [optional_tag]"
        return 1
    fi

    # 1. Create a temporary directory
    local TEMP_DIR=$(mktemp -d)
    echo "Working in: $TEMP_DIR"

    # 2. Extract the archive
    tar -xf "$ARCHIVE_PATH" -C "$TEMP_DIR"

    local TAG=""

    # 3. Determine which tag to use
    if [ -n "$PROVIDED_TAG" ]; then
        # Use the tag provided by the user
        TAG="$PROVIDED_TAG"
        echo "Using provided tag: $TAG"
    else
        # No tag provided; attempt to extract from index.json
        local TAGS=($(jq -r '.manifests[].annotations["org.opencontainers.image.ref.name"] // empty' "$TEMP_DIR/index.json"))

        if [ ${#TAGS[@]} -eq 0 ]; then
            echo "Error: No tags found in index.json and no tag provided as an argument."
            return 1
        elif [ ${#TAGS[@]} -gt 1 ]; then
            echo "Error: Multiple tags found (${TAGS[*]}). Please provide a specific tag as the second argument."
            return 1
        fi
        TAG="${TAGS[0]}"
        echo "Extracted tag from index.json: $TAG"
    fi

    # 4. Unpack with umoci
    (
        cd "$TEMP_DIR"
        umoci unpack --rootless --image .:"$TAG" container && echo "Unpacked successfully into: $TEMP_DIR/container"
    )
}
