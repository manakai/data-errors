use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->subdir ('modules', '*', 'lib');
use Encode;
use JSON::Functions::XS qw(file2perl perl2json_bytes_for_record);

my $xml = file2perl file (__FILE__)->dir->parent->file ('source', 'xml-constraints.json');
my $xmlns = file2perl file (__FILE__)->dir->parent->file ('source', 'xmlns-constraints.json');

my $Data = {};

for (@$xml) {
  $Data->{$_->{id}} = $_;
  $Data->{$_->{id}}->{spec} = 'XML';
}

for (@$xmlns) {
  $Data->{$_->{id}} = $_;
  $Data->{$_->{id}}->{spec} = 'XMLNS';
}

print perl2json_bytes_for_record $Data;
