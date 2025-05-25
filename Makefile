SHELL = /bin/bash

PWD = $(shell pwd)
HOME = $(shell echo $$HOME)

.PHONY: all to_home to_config

all: to_home to_config

to_home: .bash_aliases .bash_profile .bashrc .gitconfig .vimrc .inputrc
	for target in $^ ; \
	do \
		ln -sfv $(addprefix $(PWD)/, $$target) $(addprefix $(HOME)/, $$target) ; \
	done

to_config: config/*
	for target in $^ ; \
	do \
		base=$$(basename $$target) ; \
		ln -sfnv $(addprefix $(PWD)/config/, $$base) $(addprefix $(HOME)/.config/, $$base) ; \
	done
