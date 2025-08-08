alias l = eza -l
alias bat = batcat
alias ssho = ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking no"
alias scpo = scp -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking no"

alias partitions = sudo lsblk --exclude 7 --output NAME,FSTYPE,FSVER,LABEL,SIZE,FSAVAIL,FSUSE%,RO,TYPE,MOUNTPOINTS

def multipass_vm_ip [name] {
  multipass list --format=json | from json | get list | where {|it| $it.name == $name} | flatten | get ipv4.0
}

def multipass_port_fwd [local_port, vm_name, remote_ip, remote_port] {
  let target = multipass_vm_ip $vm_name
  sudo ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking no" -i /var/snap/multipass/common/data/multipassd/ssh-keys/id_rsa $"ubuntu@($target)" -L $"($local_port):($remote_ip):($remote_port)"
}

def edit [fn: string] {
  if "EDITOR" in $env {
    run-external $env.EDITOR $fn
  } else {
    vim $fn
  }
}
