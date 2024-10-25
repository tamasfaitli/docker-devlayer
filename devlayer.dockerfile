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
ARG SYSARCH=amd64 # probably not working with nvim but let's see if I ever run it on other than x86_64
ARG FZF_VER=0.55.0
ARG NVIM_VER=0.10.2

# adding line to solve apt installation stuck on inputting geograph loc
ARG DEBIAN_FRONTEND=noninteractive

# Installing dependencies for editors and plugins
RUN apt update && apt install -y \
	wget tmux unzip git build-essential \
	# requirements for neovim plugins and installations
	ripgrep lua5.1 luarocks curl xclip python3

# Setting up tools (not from apt..)
WORKDIR /home/$USER/tmp

# fzf - fuzzy file finder
RUN wget "https://github.com/junegunn/fzf/releases/download/v$FZF_VER/fzf-$FZF_VER-linux_$SYSARCH.tar.gz" \
	&& tar -xf fzf-$FZF_VER-linux_$SYSARCH.tar.gz \
	&& mv fzf /usr/bin && fzf --bash >> ~/.bashrc

# neovim as vi, vim, and nvim
RUN wget "https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz" \
	&& tar -xf nvim-linux64.tar.gz \
	&& mv nvim-linux64 /opt/ \
	&& printf "vi\nvim\nnvim" | xargs -I {} ln -s /opt/nvim-linux64/bin/nvim /usr/bin/{}

# parsing neovim config
# TODO : update how config is handled here
# final approach will be:
# - clone from personal git repo, and copy files to the proper place
COPY test-cfg/nvim /root/.config/nvim

# running the nvim package manager from cli
RUN nvim --headless "+Lazy! sync" +qa

# setting the final workdir for the image
WORKDIR /home/$USER
