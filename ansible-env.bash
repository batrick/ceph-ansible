export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_INVENTORY=ansible_inventory
export ANSIBLE_SSH_RETRIES=20

SSH_COMMON_ARGS="-o ConnectTimeout=60 -o ConnectionAttempts=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
ANSIBLE_ARGS="--timeout=60 -vvv --forks=50 --become"

function ans {
    time ansible --ssh-common-args="$SSH_COMMON_ARGS" $ANSIBLE_ARGS "$@"
}

function do_playbook {
    #FIXME missing os_tuning_params
    #FIXME ssh timeout?
    time ansible-playbook $ANSIBLE_ARGS "$@" --extra-vars "cluster_network=192.168.0.0/16 journal_size=100 public_network=192.168.0.0/16 devices=/dev/sdc journal_collocation=true monitor_address_block=192.168.0.0/16 pool_default_size=2"
}
