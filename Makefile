SHELL = /bin/bash

PWD = $(shell pwd)
HOME = $(shell echo $$HOME)

HOME_FILES = .bash_aliases \
						 .bash_profile \
						 .bashrc \
						 .gitconfig \
						 .vimrc \
						 .inputrc

SCRIPTS_DIR = ./scripts

.PHONY: all to_home to_config stylua neovim

all: to_home to_config

to_home: $(HOME_FILES)
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

neovim: $(SCRIPTS_DIR)/neovim/install.sh
	$(SHELL) $^

stylua:
	docker compose run --rm stylua
