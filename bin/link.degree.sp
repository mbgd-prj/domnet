#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: cat LINK | $PROGRAM cluster_sp [sp,sp,...]
-m: calculate mean degree
";

my %OPT;
getopts('m', \%OPT);

my ($CLUSTER_SP, $SPS);
if (@ARGV == 1) {
    ($CLUSTER_SP) = @ARGV;
} elsif (@ARGV == 2) {
    ($CLUSTER_SP, $SPS) = @ARGV;
} else {
    print STDERR $USAGE;
    exit 1;
}

-t and die $USAGE;
my @LINK = ();
while (<STDIN>) {
    chomp;
    my ($link) = split("\t", $_);
    push @LINK, $link;
}

my %ALL_SP = ();
my %INCLUDES = ();
open(CLUSTER_SP, "$CLUSTER_SP") || die;
while (<CLUSTER_SP>) {
    chomp;
    my @f = split;
    if (@f != 2) {
        die;
    }
    my ($cluster, $sp) = @f;
    $ALL_SP{$sp} = 1;
    $INCLUDES{$sp}{$cluster} = 1;
}
close(CLUSTER_SP);

if ($SPS) {
    get_subset_degree($SPS);
} else {
    STDOUT->autoflush;
    for my $sp (sort {$a cmp $b} keys(%ALL_SP)) {
        calc_mean_degree($sp);
    }
}

################################################################################
### Function ###################################################################
################################################################################

sub get_subset_degree {
    my ($sps) = @_;

    my %degree = ();
    for my $link (@LINK) {
        my ($cluster1, $cluster2) = split("-", $link);
        if (includes_sps($cluster1, $sps) && includes_sps($cluster2, $sps)) {
            if ($cluster1 eq $cluster2) {
                $degree{$cluster1}++;
            } else {
                $degree{$cluster1}++;
                $degree{$cluster2}++;
            }
        }
    }
    if ($OPT{m}) {
        my $sum = 0;
        my $count = 0;
        for my $cluster (keys %degree) {
            $sum += $degree{$cluster};
            $count ++;
        }
        print $sps, "\t", $count, "\t", $sum/$count, "\n";
    } else {
        for my $cluster (sort { $a cmp $b } keys %degree) {
            print $cluster, "\t", $degree{$cluster}, "\n";
        }
    }
}

sub includes_sps {
    my ($cluster, $sps) = @_;

    my @sp = split(',', $sps);
    for my $sp (@sp) {
        if ($INCLUDES{$sp}{$cluster}) {
            return 1;
        }
    }

    return 0;
}

sub calc_mean_degree {
    my ($sp) = @_;

    my %degree = ();
    for my $link (@LINK) {
        my ($cluster1, $cluster2) = split("-", $link);
        if ($INCLUDES{$sp}{$cluster1} && $INCLUDES{$sp}{$cluster2}) {
            if ($cluster1 eq $cluster2) {
                $degree{$cluster1}++;
            } else {
                $degree{$cluster1}++;
                $degree{$cluster2}++;
            }
        }
    }

    my $sum = 0;
    my $count = 0;
    for my $cluster (keys %degree) {
        $sum += $degree{$cluster};
        $count ++;
    }
    print $sp, "\t", $count, "\t", $sum/$count, "\n";
}
