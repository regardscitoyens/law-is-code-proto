use Data::Dumper;
use strict;

my $wdiffile = shift;
my $amdtfile = shift;
my $nbalineas = shift;
my %actions = ('supprime' => -1, 'remplace' => 0, 'ajout' => 1);
my $verbose = shift;

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

sub compareMotsCommuns {
    my $diff = shift;
    my $amdt = shift;
    my $nbmots = length(join('', (keys %{$diff->{'mots'}})).join('', (keys %{$amdt->{'mots'}})));
    my $nbcommuns = 0;
    foreach my $mot (keys %{$diff->{'mots'}}) {
	if ($amdt->{'mots'}{$mot}) {
	    $nbcommuns += length($mot);
	}
    }
    #si pas de mots dans amendements, pas de mots communs
    return 1 if (!scalar(keys(%{$amdt->{'mots'}})));
    return 1 - ($nbcommuns / ($nbmots / 2));
    
}

sub compareMotsRestants {
    my $diff = shift;
    my $amdt = shift;
    my $nbmots = length(join('', (keys %{$diff->{'mots'}})).join('', (keys %{$amdt->{'mots'}})));
    my $nbrestants = scalar(keys(%{$amdt->{'mots'}}));
    return ($nbrestants / ($nbmots / 2));
}

sub compare {
    my $diff = shift;
    my $amdt = shift;
    my $action = compareAction($diff, $amdt);
    my $alinea = compareAlineas($diff, $amdt);
    my $mcommuns = compareMotsCommuns($diff, $amdt);
    my $moy = (($action + $alinea + $mcommuns) / 3);
    if ($verbose) {
	print $diff->{'action'}."\t".$diff->{'alinea'}."\t".$diff->{'debug'}."\n";
	print $amdt->{'action'}."\t".$amdt->{'alinea'}."\t".$amdt->{'debug'}."\n";
	print "\n";
	print "action: $action\n";
	print "alinea: $alinea\n";
	print "communs: $mcommuns\n";
	print "=====================================\n";
	print "moyenne : $moy\n";
	print "=====================================\n";
    }
    return $moy;
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

#Identifie les amendements identiques
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
#Identifie les sous amendements
foreach my $id (keys %ssamdts) {
    foreach $a (@{$ssamdts{$id}}) {
	$amdts{$amendtalinea{$id}}{$id} = sousamendement($a, $amdts{$amendtalinea{$id}}{$id});
    }
}
my $deleted = 1;
while($deleted) {
    $deleted = 0;
    my $min = 1;
    my %minid = ('wdiff_alinea' => -1, 'wdiff_id' => -1, 'amdt_alinea' => -1, 'amdt_id' => -1);
    foreach my $a_alinea (sort {$a <=> $b} keys %amdts) {
#	    $a_alinea = 24;
	foreach my $idamendt (keys %{$amdts{$a_alinea}}) {
	    foreach my $alinea (sort {$a <=> $b} keys %wdiff) {
#    $alinea = $a_alinea;
		for(my $i = 0 ; $i <= $#{$wdiff{$alinea}} ; $i++) {
		    my $diff = $wdiff{$alinea}[$i];
		    my $moy = compare($diff, $amdts{$a_alinea}{$idamendt});
		    if ($moy < $min) {
			%minid = ('wdiff_alinea' => $alinea, 'wdiff_id' => $i, 'amdt_alinea' => $a_alinea, 'amdt_id' => $idamendt);
			$min = $moy;
		    }
		}
	    }
	}
    }
    if ($minid{'wdiff_alinea'} > -1) {
	print "======================================\n";
	print "$min ".join(' ', %minid)."\n";
	print $wdiff{$minid{'wdiff_alinea'}}[$minid{'wdiff_id'}]{'debug'}."\n";
	print $amdts{$minid{'amdt_alinea'}}{$minid{'amdt_id'}}{'debug'}."\n";
	print "======================================\n";
	delete($wdiff{$minid{'wdiff_alinea'}}[$minid{'wdiff_id'}]);
	delete($amdts{$minid{'amdt_alinea'}}{$minid{'amdt_id'}});
	$deleted = 1;
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
