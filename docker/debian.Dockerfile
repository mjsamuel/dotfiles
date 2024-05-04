FROM debian:stable-slim
ARG username=matt
ARG password=dummy

RUN apt update
RUN apt install -y sudo git

# Create a non-root user
RUN useradd -ms /bin/bash "$username"
RUN echo "$username:$password" | chpasswd
RUN usermod -aG sudo "$username"
USER $username
ENV USER $username

WORKDIR "/home/$username/"
RUN mkdir -p "Developer/dotfiles"
COPY . ./Developer/dotfiles/
RUN ./Developer/dotfiles/bootstrap <<EOF
$password

EOF

CMD "/bin/zsh"
