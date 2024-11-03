################################################################################
# Author: Tamas Faitli
# Date: 25/10/2024
# Description:
# 	Take a base image and build a neovim based development environment on
# 	top of it. The idea is to have all project and build related
# 	dependencies in a base image, but use docker image on top of it in order
# 	to edit, develop and debug the project.
# Notes:
# 	During docker build, use the following to specify the base image:
# 		--build-arg BASE_IMG=$target-image
################################################################################
ARG BASE_IMG=ubuntu:20.04
FROM $BASE_IMG

# these are after the FROM command which resets arguments apparently
ARG USER=tamasfaitli
# probably not working with nvim but let's see if I ever run it on other
# than x86_64
ARG SYSARCH=amd64
ARG FD_VER=10.2.0
ARG FZF_VER=0.55.0
ARG NVIM_VER=0.10.2

# adding line to solve apt installation stuck on inputting geograph loc
ARG DEBIAN_FRONTEND=noninteractive

# Installing dependencies for editors and plugins
RUN apt update && apt install -y \
	wget tmux unzip git build-essential bash-completion \
	# requirements for neovim plugins and installations
	tree ripgrep lua5.1 luarocks curl xclip python3 python3-venv \
	cmake python3-pip

# This might not be necessary for everyone, should figure out how to get the
# one installed by Mason used within the setup and not adding it here
RUN pip3 install debugpy

# Some Mason downloads need npm (installing it without recommendations as
# not needed)
RUN apt update && apt install \
        -y --no-install-recommends --no-install-suggests \
        npm

# Setting up tools (not from apt..)
WORKDIR /home/$USER/tmp

# fd - simpler alternative to find (integrates well with fzf)
RUN wget "https://github.com/sharkdp/fd/releases/download/v$FD_VER/fd_${FD_VER}_$SYSARCH.deb" \
	&& dpkg --install fd_${FD_VER}_$SYSARCH.deb

# fzf - fuzzy file finder
RUN wget "https://github.com/junegunn/fzf/releases/download/v$FZF_VER/fzf-$FZF_VER-linux_$SYSARCH.tar.gz" \
	&& tar -xf fzf-$FZF_VER-linux_$SYSARCH.tar.gz \
	&& mv fzf /usr/bin && fzf --bash >> ~/.bashrc

# neovim as vi, vim, and nvim
RUN wget "https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz" \
	&& tar -xf nvim-linux64.tar.gz \
	&& mv nvim-linux64 /opt/ \
	&& printf "vi\nvim\nnvim" | xargs -I {} ln -s /opt/nvim-linux64/bin/nvim /usr/bin/{}

# Copying neovim config (that is added as submodule to this repo)
# adapt as needed
COPY user-configs/. /root/
# don't want to overwrite whole bashrc from custom config, have an extension
# only for docker that is added to the existing one
RUN echo "source /root/.bashrc-docker" >> ~/.bashrc


# running the nvim package manager from cli
RUN nvim --headless "+Lazy! sync" +qa

# setting the final workdir for the image
WORKDIR /home/$USER
