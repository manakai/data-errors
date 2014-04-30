use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->child ('modules', '*', 'lib');
use JSON::PS;
use Web::DOM::Document;
use Web::XML::Parser;

my $source_path = path (__FILE__)->parent->parent->child ('source/errors.xml');
my $doc = Web::DOM::Document->new;

my $parser = Web::XML::Parser->new;
$parser->parse_char_string ($source_path->slurp_utf8 => $doc);
$doc->manakai_is_html (1);

my $items = $doc->get_elements_by_tag_name_ns
    ('http://suika.fam.cx/~wakaba/archive/2007/wdcc-desc/', 'item');

my $data = {};

for my $item (@$items) {
  my $name = $item->get_attribute ('name');
  unless (defined $name) {
    warn sprintf "%d.%d: |name| not specified\n",
        $item->get_user_data ('manakai_source_line'),
        $item->get_user_data ('manakai_source_column');
    next;
  }
  $data->{$name} ||= {};
  my $targets = [grep { length } split /[\x09\x0A\x0C\x0D\x20]+/, $item->get_attribute ('targets') // ''];
  $data->{$name}->{targets}->{$_} = 1 for @$targets;
  for my $node (@{$item->children}) {
    my $lang = $node->get_attribute_ns ('http://www.w3.org/XML/1998/namespace', 'lang');
    unless (defined $lang) {
      warn sprintf "%d.%d: |xml:lang| not specified\n",
          $node->get_user_data ('manakai_source_line'),
          $node->get_user_data ('manakai_source_column');
      next;
    }
    if ($node->local_name eq 'message') {
      $data->{$name}->{message}->{$lang} = $node->inner_html;
    } elsif ($node->local_name eq 'desc') {
      $data->{$name}->{desc}->{$lang} = $node->inner_html;
    }
  }
}

my $errors_path = path (__FILE__)->parent->parent->child ('data/errors.json');
print { $errors_path->openw } perl2json_bytes_for_record $data;
