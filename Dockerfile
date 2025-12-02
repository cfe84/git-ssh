FROM alpine:latest

ARG EVENTS_DIR
ARG REPO_ROOT
RUN apk add --no-cache openssh git bash
# && ssh-keygen -A

RUN echo "root:x:0:0:root:/root:/user/bin/false" > /etc/passwd \
 && echo "root:x:0:" > /etc/group \
 && adduser -u 1002 -D git -s /usr/bin/git-shell \
 && mkdir -p /repos \
 && chown -R git:git /home/git /repos \
 && mkdir -p /var/run/sshd && chown git:git /var/run/sshd \
 && echo "/usr/bin/git-shell" >> /etc/shells

# Git config
RUN echo -e "[init]\n  defaultBranch = main\n[core]\n  hooksPath = /hooks" > /home/git/.gitconfig

# Shell commands
RUN mkdir /home/git/git-shell-commands && \
 echo -e "#!/bin/sh\nprintf '%s\n' \"Hi! You can't use shell access\"\nexit 128" > /home/git/git-shell-commands/no-interactive-login  && \
 echo -e "#!/bin/sh\ngit init --bare \"\$1\"" > /home/git/git-shell-commands/create-repo && \
 echo -e "#!/bin/sh\nif [ -z \"\$1\" ]; then echo \"Missing parameter\"; exit 128; fi; ls \"\$1\"" > /home/git/git-shell-commands/list

# Copy stuff from gitomatic
RUN mkdir /hooks/
COPY /gitomatic/git-shell-commands/ /home/git/git-shell-commands/
COPY /gitomatic/hooks/ /hooks/

RUN echo -e "EVENTS_DIR=$EVENTS_DIR\nREPO_ROOT=$REPO_ROOT" > /home/git/.env \
  && chmod +x /home/git/.env

RUN  chmod +x /home/git/git-shell-commands/*

EXPOSE 22

CMD ["/bin/sh", "-c", "\
  [ -f /etc/ssh/ssh_host_rsa_key ] || ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N '' && \
  [ -f /etc/ssh/ssh_host_ecdsa_key ] || ssh-keygen -t ecdsa -b 521 -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
  [ -f /etc/ssh/ssh_host_ed25519_key ] || ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' && \
  ls -la /home/git && \
  cat /etc/passwd && \
  chmod 700 /home/git && \
  chmod 700 /home/git/.ssh && \
  exec /usr/sbin/sshd -D -e -f /etc/ssh/sshd_config -o PidFile=/var/run/sshd/sshd.pid"]

