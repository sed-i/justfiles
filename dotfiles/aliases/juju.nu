alias j = juju
alias jb = juju bootstrap
alias jst = juju status --relations
alias jssl = juju show-status-log
alias jm = juju models
alias jam = juju add-model --config logging-config="<root>=WARNING; unit=DEBUG" --config update-status-hook-interval="60m"
alias jctl = juju controllers
alias jssh = juju ssh
alias jsshc = juju ssh --container
alias jdl = juju debug-log
alias jdlparse = parse '{unit} {time} {level} {origin} {message}'
alias jdmds = juju destroy-model --no-prompt --destroy-storage
alias jdmds! = juju destroy-model --no-prompt --destroy-storage --force --no-wait
alias jrmds = juju remove-application --destroy-storage
alias jrmds! = juju remove-application --destroy-storage --force --no-wait
alias jsw = juju switch
alias jd = juju deploy
alias jdc = juju destroy-controller --no-prompt --destroy-all-models --destroy-storage
alias jdc! = juju destroy-controller --no-prompt --destroy-all-models --destroy-storage --force --no-wait
alias jkc = juju kill-controller
alias jrel = juju relate
alias jrmrel = juju remove-relation
alias jc = juju config
alias jrp = juju refresh --path
alias jshu = juju show-unit
alias jof = juju offer
alias jcon = juju consume
alias jsa = juju scale-application

def jpbl [unit container command] {
  sh -c $'juju exec --unit ($unit) -- PEBBLE_SOCKET=/charm/containers/($container)/pebble.socket pebble ($command)'
}

def relation_info [
  unit: string,
  endpoint?: string,
  --app_only (-a),
  --unit_only (-u),
] {

  let info = juju show-unit $unit
  | from yaml
  | get $unit
  | get relation-info

  let endpoint_given = $endpoint != null

  match [$endpoint_given, $app_only $unit_only] {

    # Entire relation-info, i.e. both app and unit data for all endpoints
    [false, false, false] | [false, true, true] => $info

    # Both app and unit data for given endpoint
    [true, false, false] | [true, true, true] => {
      $info
      | where endpoint == $endpoint
      | reject endpoint related-endpoint
    }

    # App data for given endpoint
    [true, true, false] => {
      $info
      | where endpoint == $endpoint
      | reject related-units endpoint related-endpoint
    }

    # Unit data for given endpoint
    [true, false, true] => {
      $info
      | where endpoint == $endpoint
      | reject application-data endpoint related-endpoint
    }

    # App data for all endpoints
    [false, true, false] => {
      $info | reject related-units
    }

    # Unit data for all endpoints
    [false, false, true] => {
      $info | reject application-data
    }

    _ => { "Error" }
  }
}

def xz64 [] {
  $in | xz --compress | base64
}

def xz64d [] {
  $in | base64 -d | xz --decompress
}

def uid_from_encoded_dashboard [] {
  $in | base64 -d | xz --decompress --stdout | from json | get uid dashboard_alt_uid
}

def jsync [unit_name: string, filepath: path] {
  let charm_root = get_charm_root
  let metadata_path = $charm_root | path join 'metadata.yaml'
  let charmcraft_path = $charm_root | path join 'charmcraft.yaml'
  let charm_name = if ($metadata_path | path exists) {
    open $metadata_path | get name
  } else {
    open $charmcraft_path | get name
  }

  print $"Attempting to sync ($unit_name) \(($charm_name)) from ($charm_root)..."

  let rel_path = $filepath | path expand | path relative-to $charm_root

  let remote_target = $'/var/lib/juju/agents/unit-($unit_name | str replace '/' '-')/charm/($rel_path)'
  print $'  - Copying from ($rel_path) to ($remote_target)'
  let remote_temp = juju ssh $unit_name mktemp -d
  printf $'  - via ($remote_temp)'
  juju scp $filepath $'($unit_name):($remote_temp)'
  juju ssh $unit_name mkdir -p $'($remote_target | path dirname)'
  juju ssh $unit_name cp $'($remote_temp)/($rel_path | path basename)' $remote_target
}

def get_charm_root []: nothing -> string {
  mut p = pwd
  while ($p != "/") {
    #print $p
    let pp = $p
    if (["charmcraft.yaml" "metadata.yaml"] | each {|it| $pp | path join $it} | path exists | any {|el| $el}) {
      return $pp
      break
    }
    $p = $p | path dirname
  }
  ""
}

def charmcraft_purge {
  (lxc list --project=charmcraft --format json
  | from json
  | get name
  | where { |it| $it | str starts-with 'charmcraft-' }
  | each { |it| lxc --project=charmcraft delete $it }
  )
}

