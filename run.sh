#!/bin/bash
set -x

SSH_HOST=$1

killall() {
    ssh -p $SSH_PORT $SSH_HOST "killall vboxwebsrv"
}

# SIGTERM-handler
term_handler() {
    killall
    exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; term_handler' SIGTERM

# run application
[ -z "$1" ] && echo "Error: No target argument given" && exit 1;

if [ "$USE_KEY" != "0" ] && [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
    echo -e "\n\nPlease copy public key to the servers authorized_keys file before continuing:\n"
    cat ~/.ssh/id_rsa.pub
    echo -e "\n"
    read -p "Press [Enter] to contiue..."
fi

sshHost=$(awk -F@ '{print $2}' <<<$1)
killall
ssh -p $SSH_PORT -L 0.0.0.0:18083:$sshHost:$PORT $SSH_HOST "killall vboxwebsrv; \"$VBOXWEBSRVPATH\" -p $PORT -A null -H $sshHost --background"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
