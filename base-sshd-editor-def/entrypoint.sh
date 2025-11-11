#!/usr/bin/env bash

if [ ! -d "${HOME}" ]; then
  mkdir -p "${HOME}"
fi
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-user}:x:$(id -u):0:${USER_NAME:-user} user:${HOME}:/bin/bash" >> /etc/passwd
    echo "${USER_NAME:-user}:x:$(id -u):" >> /etc/group
  fi
fi
mkdir /tmp/git-work-dir
git clone -b ${REVISION} --single-branch ${GIT_URL} /tmp/git-work-dir
cp -r /tmp/git-work-dir/www /tmp
rm -rf /tmp/git-work-dir
nohup node /tmp/www/server.js &

exec "$@"