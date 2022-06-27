#!/bin/sh

mkdir ~/.config

#kakoune
cp -r kak ~/.config/kak

#tmux
cp tmux.conf ~/.tmux.conf

#profile
cat profile >>~/.bash_profile
