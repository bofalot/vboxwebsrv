#!/bin/bash

[ -z "$1" ] && echo "Error: No target argument given" && exit 1;

if [ "$USE_KEY" != "0" ] && [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
    echo -e "\n\nPlease copy public key to the servers authorized_keys file before continuing:\n"
    cat ~/.ssh/id_rsa.pub
    echo -e "\n"
    read -p "Press [Enter] to contiue..."
fi

ssh -L 0.0.0.0:18083:localhost:$PORT $1 "killall vboxwebsrv; vboxwebsrv -p $PORT -A null"