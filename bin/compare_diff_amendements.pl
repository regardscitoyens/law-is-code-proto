#!/usr/bin/perl
#
# Note les amendements en fonction du diff du texte passé en argument
#
#

@diff = (shift, shift, shift);
$nblignes = shift;
%actions = ('supprime' => -1, 'remplace' => 0, 'ajout' => 1);

while (<STDIN>) {
	chomp;
	@amd = split /\t/;
	$amd{$amd[4]} = $_;
	$action = abs($actions{$amd[1]} - $actions{$diff[1]}) / 2;
	print "Score action : ($amd[1] $diff[1]) $action\n";
	$alinea = abs($amd[0] - $diff[0]) / $nblignes;
	print "Score alinea : $alinea\n";
	$diff[2] =~ s/[\.\(\)]//g;
	@mots = split / +/, $diff[2];
	$totalmots = $#mots +1;
	@mots = split / +/, $amd[2];
	$totalmots += $#mots +1;
	@noncommuns = ();
	foreach $mot (split(/ +/, $diff[2])) {
		unless ($amd[2] =~ s/ $mot / /) {
			push @noncommuns, $mot;
		}
	}
	push @noncommuns, split(/ +/, $amd[2]);
	$mots = ($#noncommuns+1) / $totalmots;
	print "Score mot : ( $#noncommuns / $totalmots ) $mots\n";
	$score{$amd[4]} = ($mots + $action*2 + $alinea*2) /5;
}
foreach $key (sort {$score{$b} <=> $score{$a}} keys %score) {
	print "$key : ".$score{$key}.' ';
	print $amd{$key};
	print "\n";
}
