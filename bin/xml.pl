use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->child ('modules', '*', 'lib');
use JSON::PS qw(file2perl perl2json_bytes_for_record);

my $xml = file2perl path (__FILE__)->parent->parent->child ('source', 'xml-constraints.json');
my $xmlns = file2perl path (__FILE__)->parent->parent->child ('source', 'xmlns-constraints.json');

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
