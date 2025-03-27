alias j='juju'
alias jb='juju bootstrap'
alias jst='juju status --relations'
alias jssl='juju show-status-log'
alias jm='juju models'
alias jam='juju add-model --config logging-config="<root>=WARNING; unit=DEBUG" --config update-status-hook-interval="60m"'
alias jctl='juju controllers'
alias jssh='juju ssh'
alias jsshc='juju ssh --container'
alias jdl='juju debug-log'
alias jdmds='juju destroy-model --no-prompt --destroy-storage'
alias jdmds!='juju destroy-model --no-prompt --destroy-storage --force --no-wait'
alias jrmds='juju remove-application --destroy-storage'
alias jrmds!='juju remove-application --destroy-storage --force --no-wait'
alias jsw='juju switch'
alias jd='juju deploy'
alias jdc='juju destroy-controller --no-prompt --destroy-all-models --destroy-storage'
alias jdc!='juju destroy-controller --no-prompt --destroy-all-models --destroy-storage --force --no-wait'
alias jkc='juju kill-controller'
alias jrel='juju relate'
alias jrmrel='juju remove-relation'
alias jc='juju config'
alias jrp='juju refresh --path'
alias jshu='juju show-unit'
alias jof='juju offer'
alias jcon='juju consume'
alias jsa='juju scale-application'

reldata_endpoints() {
  # $1 = unit name
  jshu "$1" --format=json | jq -r ".\"$1\".\"relation-info\" | .[] | .endpoint"
}

app_data() {
  # $1 = unit name
  # $2 = endpoint name
  jshu "$1" --format=json | jq -r ".\"$1\".\"relation-info\" | .[] | select(.endpoint == \"$2\") | .\"application-data\""
}

unit_data() {
  # $1 = unit name
  # $2 = endpoint name
  jshu "$1" --format=json | jq -r ".\"$1\".\"relation-info\" | .[] | select(.endpoint == \"$2\") | .\"related-units\""
}

charmcraft_purge() {
  for instance in $(lxc list --project=charmcraft --format json | jq -r '.[] | select(.name | startswith("charmcraft-")) | .name');
  do
    lxc --project=charmcraft delete $instance
  done
}
