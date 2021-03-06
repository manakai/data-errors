all: deps all-data

clean: clean-json-ps
	rm -fr local/data-web-defs local/perl-web-*

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
PROVE = ./prove

data: all-data
all-data: data/errors.json data/xml.json

local/data-web-defs/parser-errors.json:
	mkdir -p local/data-web-defs
	$(WGET) -O $@ https://raw.githubusercontent.com/manakai/data-web-defs/master/intermediate/errors/parser-errors.json
local/perl-web-markup/validation-errors.json:
	mkdir -p local/perl-web-markup
	$(WGET) -O $@ https://raw.githubusercontent.com/manakai/perl-web-markup/master/intermediate/validator-errors.json
local/perl-web-encodings/encoding-errors.json:
	mkdir -p local/perl-web-encodings
	$(WGET) -O $@ https://raw.githubusercontent.com/manakai/perl-web-encodings/master/intermediate/encoding-errors.json
local/perl-web-js/webidl-errors.json:
	mkdir -p local/perl-web-js
	$(WGET) -O $@ https://raw.githubusercontent.com/manakai/perl-web-js/master/intermediate/errors.json
local/perl-web-resource/parsing-errors.json:
	mkdir -p local/perl-web-resource
	$(WGET) -O $@ https://raw.githubusercontent.com/manakai/perl-web-resource/master/intermediate/parsing-errors.json

data/errors.json: source/errors.xml bin/generate.pl \
    local/data-web-defs/parser-errors.json \
    local/perl-web-markup/validation-errors.json \
    local/perl-web-encodings/encoding-errors.json \
    local/perl-web-js/webidl-errors.json \
    local/perl-web-resource/parsing-errors.json
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

test-deps: deps local/bin/jq

local/bin/jq:
	mkdir -p local/bin
	$(WGET) -O $@ https://stedolan.github.io/jq/download/linux64/jq
	chmod u+x $@

test-main:
	$(PROVE) t/

## License: Public Domain.