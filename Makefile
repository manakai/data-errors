all: deps all-data

clean: clean-json-ps
	rm -fr local/data-web-defs

WGET = wget
CURL = curl
GIT = git

updatenightly: update-submodules dataautoupdate
update-submodules: local/bin/pmbp.pl
	$(CURL) -s -S -L https://gist.githubusercontent.com/motemen/667573/raw/git-submodule-track | sh
	$(GIT) add bin/modules
	perl local/bin/pmbp.pl --update
	$(GIT) add config
dataautoupdate: clean deps all-data
	$(GIT) add data/*.json

## ------ Setup ------

deps: git-submodules pmbp-install json-ps

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

local/data-web-defs/parser-errors.json:
	mkdir -p local/data-web-defs
	$(WGET) -O $@ https://raw.githubusercontent.com/manakai/data-web-defs/master/intermediate/errors/parser-errors.json

data/errors.json: source/errors.xml bin/generate.pl \
    local/data-web-defs/parser-errors.json
	$(PERL) bin/generate.pl

data/xml.json: source/xml-constraints.json source/xmlns-constraints.json bin/xml.pl
	$(PERL) bin/xml.pl > $@

json-ps: local/perl-latest/pm/lib/perl5/JSON/PS.pm
clean-json-ps:
	rm -fr local/perl-latest/pm/lib/perl5/JSON/PS.pm
local/perl-latest/pm/lib/perl5/JSON/PS.pm:
	mkdir -p local/perl-latest/pm/lib/perl5/JSON
	$(WGET) -O $@ https://raw.githubusercontent.com/wakaba/perl-json-ps/master/lib/JSON/PS.pm

## ------ Tests ------

test: test-deps test-main

test-deps: deps

test-main:
	# XXX
