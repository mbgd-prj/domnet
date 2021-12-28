#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: cat LINK | $PROGRAM cluster_sp sp_code
";

my %OPT;
getopts('m', \%OPT);

if (@ARGV != 2) {
    print STDERR $USAGE;
    exit 1;
}
my ($CLUSTER_SP, $SP) = @ARGV;

my %INCLUDES = ();
open(CLUSTER_SP, "$CLUSTER_SP") || die;
while (<CLUSTER_SP>) {
    chomp;
    my @f = split;
    if (@f != 2) {
        die;
    }
    my ($cluster, $sp) = @f;
    if ($sp eq $SP) {
        $INCLUDES{$cluster} = 1;
    }
}
close(CLUSTER_SP);

my %DEGREE = ();
-t and die $USAGE;
while (<STDIN>) {
    chomp;
    my ($link) = split("\t", $_);
    my ($cluster1, $cluster2) = split("-", $link);
    if ($INCLUDES{$cluster1} && $INCLUDES{$cluster2}) {
        if ($cluster1 eq $cluster2) {
            $DEGREE{$cluster1}++;
        } else {
            $DEGREE{$cluster1}++;
            $DEGREE{$cluster2}++;
        }
    }
}

if ($OPT{m}) {
    my $sum = 0;
    my $count = 0;
    for my $cluster (keys %DEGREE) {
        $sum += $DEGREE{$cluster};
        $count ++;
    }
    print $SP, "\t", $count, "\t", $sum/$count, "\n";
} else {
    for my $cluster (sort { $a cmp $b } keys %DEGREE) {
        print $cluster, "\t", $DEGREE{$cluster}, "\n";
    }
}
