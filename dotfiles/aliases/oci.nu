alias nsenter_all = sudo nsenter --mount --uts --ipc --net --pid -t


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


def ctrzd [
    matcher?: string  # Optional: Filter for PIDs whose command matches this regex
] {
    # start with shim pids
    mut next_pids = (ps -l | where name =~ containerd-shim | get pid)

    # table to collect all discovered pid rows
    mut collected = [] # (ps -l | where ppid in $next_pids | select ppid pid user_id name command)

    # set of current parent pids to expand
    # mut next_parents = $collected

    # loop until no new pids are found
    while ($next_pids | length) > 0 {
        # append new rows to collected
        $collected = ($collected ++ (ps -l | where ppid in $next_pids | select ppid pid user_id name command))

        # find direct children of current parents
        $next_pids = (ps -l | where ppid in ($next_pids) | get pid)
    }

    # collected now contains all rows reachable from shim pids via ppid links
    if ($matcher | is-empty) {
        $collected | sort-by name
    } else {
        $collected | where name =~ $matcher | sort-by name
    }
}

def subuid [
    user?: string
] {
    # Note: In a standard Root (privileged) container (the default for Docker if not specially configured),
    # the container engine runs as the host's root. It doesn't use the mapping in /etc/subuid at all.
    let user = if ($user | is-not-empty) { $user } else { $env.USER }
    let range = (open /etc/subuid | lines | parse "{user}:{uid}:{count}" | where user == $env.USER | first | {"from": ($in.uid | into int), "to": (($in.uid | into int ) + ($in.count | into int))})
    let match = (ps -l | where user_id >= $range.from and user_id <= $range.to | select ppid pid user_id name command)
    if ($match | is-empty ) {
        print -e ("Note: In a standard Root (privileged) container (the default for Docker if not specially configured), " +
                 "the container engine runs as the host's root. It doesn't use the mapping in /etc/subuid at all.")
    }
    $match
}