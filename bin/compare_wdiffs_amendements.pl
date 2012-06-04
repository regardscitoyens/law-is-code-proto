use Data::Dumper;
use strict;

my $wdiffile = shift;
my $amdtfile = shift;
my $nbalineas = shift;
my %actions = ('supprime' => -1, 'remplace' => 0, 'ajout' => 1);


sub cleanAndCountMots {
    my $mots = shift;
    my $action = shift;
    $mots =~ s/^  //g;
    $mots =~ s/  $//g;
    $mots =~ s/[\(\)–]/ /g;
    $mots =~ s/(\d)-/$1 /g;
    $mots =~ s/  +/ /g;
    my @mots = split / +/, $mots;
    return countMots(\@mots, $action);
}

sub countMots {
    my $mots = shift;
    my $action = shift;
    my %mots = ();
    foreach my $mot (@$mots) {
	next unless ($mot);
	$mot = lc($mot);
	$mots{$mot}++;
	if ($action eq 'remplace' && $mots{$mot} == 2) {
	    delete($mots{$mot});
	}
    }
    return \%mots;
}

sub sousamendement {
    my $sousa = shift;
    my $aoriginal = shift;

    foreach my $mot (keys %{$sousa->{'mots'}}) {
	if ($sousa->{'action'} eq 'ajout') {
	    $aoriginal->{'mots'}{$mot}++;
	}elsif ($sousa->{'action'} eq 'supprime') {
	    $aoriginal->{'mots'}{$mot}--;
	}else{
	    if ($aoriginal->{'mots'}{$mot} > 0) {
		$aoriginal->{'mots'}{$mot}--;
	    }else{
		$aoriginal->{'mots'}{$mot}++;
	    }
	}
    }
    return $aoriginal;
}

sub isAIdentiq {
    my $a1 = shift;
    my $a2 = shift;
    if ($a1->{'action'} ne $a2->{'action'}) {
	return 0;
    }
    if ($a1->{'alinea'} ne $a2->{'alinea'}) {
	return 0;
    }
    if (%{$a1->{'mots'}} != %{$a2->{'mots'}}) {
	return 0;
    }
    foreach my $k (keys %{$a1->{'mots'}}) {
	if ($a1->{'mots'}{$k} != $a2->{'mots'}{$k}) {
	    return 0;
	}
    }
    return 1;
    
}

sub compareAction {
    my $a1 = shift;
    my $a2 = shift;
    return abs($actions{$a1->{'action'}} - $actions{$a2->{'action'}})/2;
}

sub compareAlineas {
    my $a1 = shift;
    my $a2 = shift;
    return abs($a1->{'alinea'} - $a2->{'alinea'}) / $nbalineas;
}

sub compareMots {
    my $a1 = shift;
    my $a2 = shift;
    my $nbmots = length(join('', (keys %{$a1->{'mots'}})).join('', (keys %{$a2->{'mots'}})));
    my $nbcommuns = 1;
    foreach my $mot (keys %{$a1->{'mots'}}) {
	if ($a2->{'mots'}{$mot}) {
	    $nbcommuns += length($mot);
	}
    }
    return 1 - ($nbcommuns / ($nbmots / 2));
}

sub compare {
    my $a1 = shift;
    my $a2 = shift;
    print $a1->{'action'}."\t".$a1->{'alinea'}."\t".$a1->{'debug'}."\n";
    print $a2->{'action'}."\t".$a2->{'alinea'}."\t".$a2->{'debug'}."\n";
    print "\n";
    my $action = compareAction($a1, $a2);
    my $alinea = compareAlineas($a1, $a2);
    my $mots = compareMots($a1, $a2);
    print "action: $action\n";
    print "alinea: $alinea\n";
    print "mots: $mots\n";
    print "=====================================\n";
    print "moyenne : ".(($action + $alinea + $mots) / 3)."\n";
    print "=====================================\n";
}

open(WDIFF, $wdiffile);
my %wdiff = ();
while (<WDIFF>) {
    chomp;
    my @split = split /\t/;
    push @{$wdiff{$split[0]}}, {'alinea' => $split[0], 'action' => $split[1], 'mots' => cleanAndCountMots($split[2], $split[1]), 'debug' => $split[3]};
}
close WDIFF;

open(AMDT, $amdtfile);
my %amdts = ();
my %ssamdts = ();
my %amendtalinea = ();
while(<AMDT>) {
    chomp;
    my @split = split /\t/;
    $split[3] =~ s/"//g;
    my @unamendt = split(/,/, $split[3]);
    if ($unamendt[6]) {
	push @{$ssamdts{$unamendt[6]}}, {'amendement' => $unamendt[6], 'alinea' => $split[0], 'action' => $split[1], 'mots' => cleanAndCountMots($split[2], $split[1]), 'debug' => $split[3]};
    }else{
	$amdts{$split[0]}{$unamendt[5]} = {'alinea' => $split[0], 'action' => $split[1], 'mots' => cleanAndCountMots($split[2], $split[1]), 'debug' => $split[3]};
	$amendtalinea{$unamendt[5]} = $split[0];
    }
}
close AMDT;

foreach my $alin (keys %amdts) {
    foreach my $a1id (keys %{$amdts{$alin}}) {
	foreach my $a2id (keys %{$amdts{$alin}}) {
	    next if ($a1id eq $a2id);
	    if (isAIdentiq($amdts{$alin}{$a1id}, $amdts{$alin}{$a2id})) {
		push @{$amdts{$amendtalinea{$a1id}}{$a1id}{'identiques'}}, $a2id;
	    }
	}
    }
}

foreach my $id (keys %ssamdts) {
    foreach $a (@{$ssamdts{$id}}) {
	$amdts{$amendtalinea{$id}}{$id} = sousamendement($a, $amdts{$amendtalinea{$id}}{$id});
    }
}

foreach my $alinea (keys %wdiff) {
    print "alinea $alinea\n";
    foreach my $diff (@{$wdiff{$alinea}}) {
	foreach my $idamendt (keys %{$amdts{$alinea}}) {
	    if (isAIdentiq($diff, $amdts{$alinea}{$idamendt})) {
		print "$idamendt TROUVÉ !!\n";
		delete($wdiff{$alinea});
		delete($amdts{$alinea}{$idamendt});
	    }
	}
    }
}
foreach my $a_alinea (sort {$a <=> $b} keys %amdts) {
#	    $a_alinea = 24;
    foreach my $idamendt (keys %{$amdts{$a_alinea}}) {
	foreach my $alinea (sort {$a <=> $b} keys %wdiff) {
#    $alinea = $a_alinea;
	    foreach my $diff (@{$wdiff{$alinea}}) {
		compare($diff, $amdts{$a_alinea}{$idamendt});
	    }
	}
    }
}
exit;		

foreach my $alinea (sort {$a <=> $b} keys %amdts) {
    print "alinea $alinea :\n texte : ";
    print Dumper($wdiff{$alinea});
    print " amendements : ";
    print Dumper($amdts{$alinea});
    print "======================================\n";
}
