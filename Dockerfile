FROM archlinux:latest

ENV user=user
ENV password=password

# We should first set up a non-root account with sudo access
RUN pacman -Syu --needed --noconfirm sudo
RUN useradd -m $user
RUN echo $password | passwd $user --stdin
RUN usermod -aG wheel $user
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Docker-specific hack for logname
RUN echo "echo $user" > /usr/bin/logname  

USER $user
COPY --chown=user:user . /tmp/bootstrap
WORKDIR /tmp/bootstrap

# Using --become-password-file for non-interactive use
RUN sed -i 's/--ask-become-pass/--become-password-file password.txt/g' bootstrap.sh
RUN echo $password > password.txt
RUN ./bootstrap.sh

ENTRYPOINT ["/bin/zsh"]

