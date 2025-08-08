alias l='eza -l'
alias bat='batcat'
alias ssho='ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking no"'
alias scpo='scp -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking no"'

alias partitions='sudo lsblk --exclude 7 --output NAME,FSTYPE,FSVER,LABEL,SIZE,FSAVAIL,FSUSE%,RO,TYPE,MOUNTPOINTS'

alias e='${EDITOR:-vim}'
