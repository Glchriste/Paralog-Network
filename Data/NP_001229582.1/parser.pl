#!/usr/bin/perl
use strict;
use warnings;
use Bio::Phylo::IO 'parse_tree';
use JSON;

my $input_file = "RAxML_bestTree.15-ORTHOMCL477.faa.blastp.xml-NP_001229582.1.raxml.newick";
open(my $input_fh, "<", $input_file) || die "Can't open $input_file: $!";
 
# this just reads the newick string in the __DATA__ section below
my $tree = parse_tree(
    '-handle' => \*$input_fh,
    '-format' => 'newick',
);
 
# here we produce a nested data structure for which a simple mapping
# to JSON is provided by the standard CPAN module. 
my $result = traverse( $tree->get_root );
 
# this produces the output in pretty printed format
print JSON->new->pretty->encode($result);
 
# this is the important bit: this subroutine is first called with
# the root as argument (on line 15), and subsequently on the children 
# and the children's children, and so on
sub traverse {
    my $node = shift;
     
    # initializes a data structure equivalent to the JSON syntax 
    # for the focal node
    my $result = { 'name' => $node->get_name };
     
    # the 'children' property is optional, so only create one for
    # internal nodes
    if ( my @children = @{ $node->get_children } ) {
     
        # here the 'children' property is magically filled in
        # recursively
        $result->{'children'} = [ map { traverse($_) } @children ];
    }
    return $result;
}
 
my $output_name = "RAxML_bestTree.15-ORTHOMCL477.faa.blastp.xml-NP_001229582.1.json";
open(my $output_file, ">>", $output_name);
print { $output_file } JSON->new->pretty->encode($result);