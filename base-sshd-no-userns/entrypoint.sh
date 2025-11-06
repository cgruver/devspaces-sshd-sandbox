#!/usr/bin/env bash

# Ensure $HOME exists when starting
if [ ! -d "${HOME}" ]; then
  mkdir -p "${HOME}"
fi

mkdir -p ${HOME}/.config/containers
(echo '[storage]';echo 'driver = "vfs"') > ${HOME}/.config/containers/storage.conf

# Add current (arbitrary) user to /etc/passwd and /etc/group
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-user}:x:$(id -u):0:${USER_NAME:-user} user:${HOME}:/bin/bash" >> /etc/passwd
    echo "${USER_NAME:-user}:x:$(id -u):" >> /etc/group
  fi
fi
USER=$(whoami)
START_ID=$(( $(id -u)+1 ))
echo "${USER}:${START_ID}:2147483646" > /etc/subuid
echo "${USER}:${START_ID}:2147483646" > /etc/subgid

# Setup $PS1 for a consistent and reasonable prompt
if [ -w "${HOME}" ] && [ ! -f "${HOME}"/.bashrc ]; then
  echo "PS1='[\u@\h \W]\$ '" > "${HOME}"/.bashrc
  (echo "if [ -f ${PROJECT_SOURCE}/workspace.rc ]"; echo "then"; echo "  . ${PROJECT_SOURCE}/workspace.rc"; echo "fi") > ${HOME}/.bashrc
fi

if [ -w "${HOME}" ] && [ ! -f ${HOME}/.zshrc ]
then
  (echo "HISTFILE=${HOME}/.zsh_history"; echo "HISTSIZE=1000"; echo "SAVEHIST=1000") > ${HOME}/.zshrc
  (echo "if [ -f ${PROJECT_SOURCE}/workspace.rc ]"; echo "then"; echo "  . ${PROJECT_SOURCE}/workspace.rc"; echo "fi") >> ${HOME}/.zshrc
fi

# Set up SSHD
if [[ -f /etc/ssh/dwo_ssh_key.pub ]]
then
  mkdir -p ${HOME}/.ssh
  cp /etc/ssh/dwo_ssh_key.pub ${HOME}/.ssh/authorized_keys
  chmod 600 ${HOME}/.ssh/authorized_keys
  nohup /usr/sbin/sshd -D -f /usr/local/ssh/sshd_config -E /tmp/sshd.log &
fi

exec "$@"