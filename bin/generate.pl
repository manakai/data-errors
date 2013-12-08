use strict;
use warnings;
use Path::Class;
use lib glob file (__FILE__)->dir->subdir ('modules', '*', 'lib');
use Encode;
use JSON;
use Web::DOM::Document;
use Web::XML::Parser;

my $source_f = file (__FILE__)->dir->parent->file ('source', 'errors.xml');
my $doc = Web::DOM::Document->new;

my $parser = Web::XML::Parser->new;
$parser->parse_char_string ((decode 'utf-8', scalar $source_f->slurp) => $doc);
$doc->manakai_is_html (1);

my $items = $doc->get_elements_by_tag_name_ns ('http://suika.fam.cx/~wakaba/archive/2007/wdcc-desc/', 'item');

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

my $errors_f = file (__FILE__)->dir->parent->file ('data', 'errors.json');
print { $errors_f->openw } JSON->new->utf8->canonical->pretty->encode ($data);
