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

def reldata_endpoints [unit] {
  juju show-unit $unit
  | from yaml
  | get $unit
  | get relation-info
  | get endpoint
}

def app_data [unit endpoint] {
  juju show-unit $unit
  | from yaml
  | get $unit
  | get relation-info
  | where endpoint == $endpoint
  | reject related-units
}

def unit_data [unit endpoint] {
  juju show-unit $unit
  | from yaml
  | get $unit
  | get relation-info
  | where endpoint == $endpoint
  | reject application-data
}

