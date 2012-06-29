use Data::Dumper;
use strict;

my $wdiffile = shift;
my $amdtfile = shift;
my $nbalineas = shift;
my $correspondancefile = shift;
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

sub compareNbMots {
    my $diff = shift;
    my $amdt = shift;
    my $nbrestants = scalar(keys(%{$amdt->{'mots'}})) + scalar(keys(%{$diff->{'mots'}})) ;
    return $nbrestants / 100;
}

sub compare {
    my $diff = shift;
    my $amdt = shift;
    my $action = compareAction($diff, $amdt);
    my $alinea = compareAlineas($diff, $amdt);
    my $mcommuns = compareMotsCommuns($diff, $amdt);
    my $dist = sqrt($action*$action + $alinea*$alinea + $mcommuns*$mcommuns);
    if ($verbose) {
	print $diff->{'action'}."\t".$diff->{'alinea'}."\t".$diff->{'debug'}."\n";
	print $amdt->{'action'}."\t".$amdt->{'alinea'}."\t".$amdt->{'debug'}."\n";
	print "\n";
	print "action: $action\n";
	print "alinea: $alinea\n";
	print "communs: $mcommuns\n";
	print "=====================================\n";
	print "distance : $dist\n";
	print "=====================================\n";
    }
    my $nb_mots_amdmt = scalar(keys %{$amdt->{'mots'}})/1000;
    my $nb_mots_diff  = scalar(keys %{$diff->{'mots'}})/1000;
    return ('distance' => $dist, 'action' => $action, 'alinea'=>$alinea, 'mots_communs'=>$mcommuns, 'nb_mots_amdmt'=>$nb_mots_amdmt, 'nb_mots_diff'=>$nb_mots_diff, 'distance_nb_mots' => abs($nb_mots_amdmt - $nb_mots_diff));
}

my %correspondance_wdiff_amdt;
open(CORR, $correspondancefile);
while(<CORR>) {
    s/ //g;
    my @csv = split /;/;
    my @wdiff = split /,/, $csv[1];
    foreach my $wd (@wdiff) {
	print $wd." ".$csv[0]."\n" if($verbose);
	$correspondance_wdiff_amdt{$wd}{$csv[0]} = 1;
    }
}
close(CORR);

open(WDIFF, $wdiffile);
my %wdiff = ();
my $numligne = 0;
while (<WDIFF>) {
    chomp;
    my @split = split /\t/;
    $numligne++;
    push @{$wdiff{$split[0]}}, {'alinea' => $split[0], 'action' => $split[1], 'mots' => cleanAndCountMots($split[2], $split[1]), 'debug' => $split[3], 'numligne' => $numligne};
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

my %proba;
#Compare le score de chaq amendement avec chaq wdiff
foreach my $a_alinea (sort {$a <=> $b} keys %amdts) {
    foreach my $idamendt (keys %{$amdts{$a_alinea}}) {
	foreach my $alinea (sort {$a <=> $b} keys %wdiff) {
	    for(my $i = 0 ; $i <= $#{$wdiff{$alinea}} ; $i++) {
		my $diff = $wdiff{$alinea}[$i];
		printf "amdmt: %05d",$idamendt if ($verbose);
		printf " wdiff: %05d", $diff->{'numligne'} if ($verbose);
		print " " if ($verbose);
		my %compare = compare($diff, $amdts{$a_alinea}{$idamendt});
		foreach my $type (qw(distance alinea action mots_communs nb_mots_amdmt nb_mots_diff distance_nb_mots)) {
		    my $key = sprintf("%02.3f", $compare{$type});
		    printf "$type:$key" if ($verbose);
		    $proba{$type}{$key}{'nb_occur'}++;
		    $proba{$type}{$key}{'nb_match'} += $correspondance_wdiff_amdt{$diff->{'numligne'}}{$idamendt};
		}
		if ($correspondance_wdiff_amdt{$diff->{'numligne'}}{$idamendt}) {
		    print '1'  if ($verbose);
		}else{
		    print '0'  if ($verbose);
		}
		print " -- \n" if ($verbose);
	    }
	}
    }
}

foreach my $type (keys %proba) {
    print ";;\n$type;valeur;proba match;nb occurence\n";
    for(my $i = 0 ; $i <= 1.001 ; $i += 0.001) {
	my $key = sprintf("%02.3f", $i);
	if (!$proba{$type}{$key}{'nb_occur'}) {
#	    printf "$type;%.3f;%.3f\n", $i, 0;
	}else{
	    printf "$type;%.3f;%02.3f;%d\n", $i, $proba{$type}{$key}{'nb_match'}/$proba{$type}{$key}{'nb_occur'},$proba{$type}{$key}{'nb_occur'};
	}
    }
}
exit;
