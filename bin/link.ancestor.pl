#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM
";

require "/home/chiba/github/hchiba1/domnet/pm/DomNet.pm";

my %OPT;
getopts('', \%OPT);

my %DESCENDENTS = ();
my %NAME = ();
read_values("additional_info/taxid_nodes/taxid_node.descendents", \%DESCENDENTS);
read_values("additional_info/taxid_nodes/taxid_node.names", \%NAME);
my %SP_ANCESTORS = ();
read_lines_to_hash("additional_info/sp.taxid.ancestors", \%SP_ANCESTORS);

!@ARGV && -t and die $USAGE;
while (<>) {
    chomp;
    my @f = split("\t", $_);
    my ($link, $orgs_fused, $orgs_split) = @f[0,4,5];

    my @stat_fused = analyze_orgs($orgs_fused);
    my @stat_split = analyze_orgs($orgs_split);
    
    print join("\t", $link, @stat_fused, @stat_split), "\n";
}

################################################################################
### Function ###################################################################
################################################################################

sub analyze_orgs {
    my ($orgs) = @_;

    if ($orgs eq "") {
	return ("NA", "NA", "NA", "NA");
    }

    my $n_orgs = split(",", $orgs);
    my $ancestor = get_ancestor($orgs);

    if ($ancestor =~ /^(\d+):(\S+)$/) {
	my ($taxid, $rank) = ($1, $2);
	if ($DESCENDENTS{$taxid} and $NAME{$taxid}) {
	    my @descendents = split(",", $DESCENDENTS{$taxid});
	    my $n_descendents = @descendents;
	    my $name = $NAME{$taxid};
	    if ($rank ne "NoRank") {
		$name .= " ($rank)";
	    }
	    my $ratio = $n_orgs/$n_descendents;
	    return ($ratio, "=$n_orgs/$n_descendents", "$name", "taxid:$taxid");
	} else {
	    die;
	}
    } else {
	die "$orgs $ancestor";
    }
}

sub get_ancestor {
    my ($orgs) = @_;

    my @mat = ();
    my @org = split(",", $orgs);
    for (my $i=0; $i<@org; $i++) {
        my $ancestors = $SP_ANCESTORS{$org[$i]};
        my @f = split("\t", $ancestors);
	for (my $j=0; $j<@f; $j++) {
	    $mat[$i][$j] = $f[$j];
	}
    }

    my $ancestor = "";

    my $j = 0;
    while (1) {
	for (my $i=0; $i<@mat; $i++) {
	    if (! defined $mat[$i][$j]) {
		return $ancestor;
	    }
	    if ($mat[0][$j] ne $mat[$i][$j]) {
		return $ancestor;
	    }
	}
	$ancestor = $mat[0][$j];
	$j ++;
    }

    die;
}
