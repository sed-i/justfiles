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

def uid_from_encoded_dashboard [] {
  $in | base64 -d | xz --decompress --stdout | from json | get uid dashboard_alt_uid
}

