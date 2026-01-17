def rock_unpack [
    archive_path: path,         # The .tar OCI archive
    provided_tag?: string       # Optional: Specific tag to use
] {
    # 1. Error out early if archive doesn't exist
    if not ($archive_path | path exists) {
        error make { msg: $"Archive not found at ($archive_path)" }
    }

    # 2. Create a temporary directory
    let temp_dir = (mktemp -d)
    print $"Working in: ($temp_dir)"

    # 3. Extract the archive
    tar -xf $archive_path -C $temp_dir

    # 4. Determine which tag to use
    let tag = if ($provided_tag | is-not-empty) {
        print $"Using provided tag: ($provided_tag)"
        $provided_tag
    } else {
        # Parse index.json directly as a Nu table
        let tags = (open $"($temp_dir)/index.json" | get manifests.annotations.'org.opencontainers.image.ref.name')

        if ($tags | is-empty) {
            error make { msg: "No tags found in index.json and no tag provided." }
        } else if ($tags | length) > 1 {
            error make { msg: $"Multiple tags found: ($tags). Please provide one." }
        }

        let found_tag = ($tags | first)
        print $"Extracted tag: ($found_tag)"
        $found_tag
    }

    # 5. Unpack with umoci
    # Nushell handles directory context gracefully
    do {
        cd $temp_dir
        umoci unpack --rootless --image $".:($tag)" container
    }

    print $"Unpacked successfully into: ($temp_dir)/container"
}
