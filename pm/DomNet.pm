################################################################################
### Cluster functions ##########################################################
################################################################################

sub get_cluster_functions_all {
    my ($link, $r_func) = @_;

    my $mbgd_func = get_cluster_functions($link, $r_func, "MBGD");
    my $cog_func = get_cluster_functions($link, $r_func, "COG");
    my $kegg_func = get_cluster_functions($link, $r_func, "KEGG");
    my $tigr_func = get_cluster_functions($link, $r_func, "TIGR");

    return join("\t", $mbgd_func, $cog_func, $kegg_func, $tigr_func);
}

sub get_cluster_functions {
    my ($link, $r_func, $db_name) = @_;

    my ($cluster1, $cluster2) = split("-", $link);
    my $func1 = ${$r_func}{$cluster1}{$db_name};
    my $func2 = ${$r_func}{$cluster2}{$db_name};
    my $func1_higher = get_higher_function_hierarchy($func1);
    my $func2_higher = get_higher_function_hierarchy($func2);

    my $type;
    if (check_if_defined_function($db_name, $func1) and check_if_defined_function($db_name, $func2)) {
	if ($func1 eq $func2) {
    	    $type = $db_name . "_SAME_EXACTLY";
	} elsif ($func1_higher eq $func2_higher) {
	    $type = $db_name . "_SAME_MOSTLY";
	} else {
	    $type = $db_name . "_DIFFERENT";
	}
    } else {
	$type = $db_name . "_UNKNOWN";
    }

    return $func1 . "-" . $func2 . "\t" . $type;
}

sub check_if_defined_function {
    my ($db_name, $func) = @_;

    if (! $func) {
	return 0;
    }

    if ($db_name eq "MBGD") {
	if ($func eq "14" || $func eq "15" || $func eq "15.1") {
	    return 0;
	} else {
	    return 1;
	}
    } elsif ($db_name eq "COG") {
	if ($func eq "4" || $func eq "4.1" || $func eq "4.2") {
	    return 0;
	} else {
	    return 1;
	}
    } elsif ($db_name eq "KEGG") {
	if ($func eq "98" || $func eq "98.1" || 
	    $func eq "99" || $func eq "99.1" || $func eq "99.2") {
	    return 0;
	} else {
	    return 1;
	}
    } elsif ($db_name eq "TIGR") {
	if ($func eq "17" || $func eq "17.1" || 
	    $func eq "18" || $func eq "18.1" || $func eq "18.2" ||
	    $func eq "19" || $func eq "19.1" || $func eq "19.2") {
	    return 0;
	} else {
	    return 1;
	}
    }
}

sub get_higher_function_hierarchy {
    my ($func) = @_;

    if ($func =~ /^(\d+)$/) {
	return $func;
    } elsif ($func =~ /^(\d+).\d+$/) {
	return $1;
    } else {
	# print STDERR "cannot get higher function hierarchy: $func\n";
	return $func;
    }
}

sub read_cluster_functions {
    my ($file, $r_func) = @_;

    open(FILE, "$file") || die;
    while (<FILE>) {
	chomp;
	my ($cluter, @func) = split("\t", $_, -1);
	if (@func != 4) {
	    die;
	}
	add_cluster_functions($r_func, $cluter, "MBGD", $func[0]);
	add_cluster_functions($r_func, $cluter, "COG", $func[1]);
	add_cluster_functions($r_func, $cluter, "KEGG", $func[2]);
	add_cluster_functions($r_func, $cluter, "TIGR", $func[3]);
    }
    close(FILE);
}

sub add_cluster_functions {
    my ($r_func, $cluter, $db_name, $category_ids) = @_;

    my @category_id = split(",", $category_ids);
    for my $category_id (@category_id) {
	if ($category_id =~ /^\d+$/) {
	} elsif ($category_id =~ /^\d+.\d+$/) {
	} else {
	    die;
	}
    }
    ${$r_func}{$cluter}{$db_name} = $category_ids;
}

################################################################################
### General ####################################################################
################################################################################

sub read_func_def {
    my ($file, $r_func_def, $r_func) = @_;

    open(FILE, "$file") || die $file;
    while (<FILE>) {
	chomp;
	if (/^#/) {
	    next;
	}
	my @f = split("\t", $_);
	if (@f < 3) {
	    die;
	}
	if (defined ${$r_func_def}{$f[1]}) {
	    die;
	}
	${$r_func_def}{$f[1]} = $f[2];
	push @{$r_func}, $f[1];
    }
    close(FILE);
}

sub read_values {
    my ($file, $r_value, %opt) = @_;

    my $col = $opt{col} || 2;
    my $col_i = $col - 1;

    open(FILE, "$file") || die;
    while (<FILE>) {
	chomp;
	my @f = split("\t", $_, -1);
	if (defined($f[$col_i])) {
	    my ($key, $value) = ($f[0], $f[$col_i]);
	    if (defined ${$r_value}{$key}) {
		die;
	    }
	    ${$r_value}{$key} = $value;
	} else {
	    print STDERR "WARNING: no values in $file: $_\n";
	}
    }
    close(FILE);
}

sub read_descendents {
    my ($file, $r_descendents) = @_;

    open(FILE, "$file") || die;
    while (<FILE>) {
	chomp;
	my @f = split("\t", $_);
	if (! defined($f[1])) {
	    die;
	}
	my ($taxid, $orgs) = ($f[0], $f[1]);
	if (defined ${$r_descendents}{$taxid}) {
	    die;
	}
	my @orgs = split(",", $orgs);
	for my $org (@orgs) {
	    ${$r_descendents}{$taxid}{$org} = 1;
	}
    }
    close(FILE);
}

sub read_lines_to_hash {
    my ($file, $r_hash) = @_;

    open(FILE, "$file") || die;
    while (<FILE>) {
	chomp;
	if (/^(\S+)\t(.*)$/) {
	    my ($key, $values) = ($1, $2);
	    if (defined ${$r_hash}{$key}) {
		die;
	    }
	    ${$r_hash}{$key} = $values;
	} else {
	    die;
	}
    }
    close(FILE);
}

sub read_ini_file {
    my ($file, $r_val) = @_;
    
    open(INI, $file) || die;
    while (<INI>) {
	chomp;
	if (/^\s*#/) {
	    next;
	}
	if (/^\s*$/) {
	    next;
	}
	if (/^\s*(\S+)\s+(.*)/) {
	    my ($key, $val) = ($1, $2);
	    ${$r_val}{$key} = $val;
	}
    }
    close(INI);
}

################################################################################
### Others #####################################################################
################################################################################

sub organisms_to_taxon {
    my ($organisms, $r_tax_name, $r_count_taxon) = @_;

    my @organisms = split(",", $organisms);

    for my $organism (@organisms) {
	if (defined ${$r_tax_name}{$organism}) {
	    my $taxon = ${$r_tax_name}{$organism};
	    ${$r_count_taxon}{$taxon}++;
	}
    }
}

sub organisms_to_prok_euk {
    my ($organisms, $r_tax_name) = @_;

    my @organisms = split(",", $organisms);

    my $bacteria = 0;
    my $archaea = 0;
    my $eukaryota = 0;

    for my $organism (@organisms) {
	if (defined ${$r_tax_name}{$organism}) {
	    if (${$r_tax_name}{$organism} eq "Bacteria") {
		$bacteria = 1;
	    } elsif (${$r_tax_name}{$organism} eq "Archaea") {
		$archaea = 1;
	    } elsif (${$r_tax_name}{$organism} eq "Eukaryota") {
		$eukaryota = 1;
	    }
	}
    }

    if (($archaea or $bacteria) and $eukaryota) {
	return "prok_euk";
    } elsif ($archaea or $bacteria) {
	return "prok";
    } elsif ($eukaryota) {
	return "euk";
    } else {
	return "null";
    }
}

sub organisms_to_eury_cren {
    my ($organisms, $r_tax_name) = @_;

    my @organisms = split(",", $organisms);

    my $eury = 0;
    my $cren = 0;

    for my $organism (@organisms) {
	if (defined ${$r_tax_name}{$organism}) {
	    if (${$r_tax_name}{$organism} eq "Euryarchaeota") {
		$eury = 1;
	    }
	    if (${$r_tax_name}{$organism} eq "Crenarchaeota") {
		$cren = 1;
	    }
	}
    }

    if ($eury and $cren) {
	return "eury_cren";
    } elsif ($eury) {
	return "eury";
    } elsif ($cren) {
	return "cren";
    } else {
	return "others";
    }
}

1;
