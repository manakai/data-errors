# -*- Makefile -*-

all: all-data

## ------ Setup ------

WGET = wget
GIT = git

deps: git-submodules pmbp-install

git-submodules:
	$(GIT) submodule update --init

local/bin/pmbp.pl:
	mkdir -p local/bin
	$(WGET) -O $@ https://raw.github.com/wakaba/perl-setupenv/master/bin/pmbp.pl
pmbp-upgrade: local/bin/pmbp.pl
	perl local/bin/pmbp.pl --update-pmbp-pl
pmbp-update: git-submodules pmbp-upgrade
	perl local/bin/pmbp.pl --update
pmbp-install: pmbp-upgrade
	perl local/bin/pmbp.pl --install

## ------ Build ------

PERL = ./perl

all-data: data/errors.json data/xml.json

data/errors.json: source/errors.xml bin/generate.pl
	$(PERL) bin/generate.pl

data/xml.json: source/xml-constraints.json source/xmlns-constraints.json bin/xml.pl
	$(PERL) bin/xml.pl > $@

## ------ Tests ------

test: test-deps test-main

test-deps: deps

test-main:
	# XXX
