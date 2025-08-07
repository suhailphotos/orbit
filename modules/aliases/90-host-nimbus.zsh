# modules/aliases/90-host-nimbus.zsh
[[ $ORBIT_HOST == nimbus ]] || return
alias nvidia='nvidia-smi'
alias gpustats='watch -n1 nvidia-smi'
