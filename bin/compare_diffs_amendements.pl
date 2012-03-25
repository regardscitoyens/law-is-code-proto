#!/usr/bin/perl
#
# Compare tous les diffs avec les amendemenst
#

$perlscript = shift;
$amendementsfile = shift;

@lignes = <STDIN>;
$nblignes = $lignes[$#lignes];
chomp($nblignes);
$nblignes =~ s/\t.*//;
foreach(@lignes) {
	chomp;
	@args = split /\t/;
	print('echo "DIFF: '."@args"."\"\n".'echo -n "RES:";perl '.$perlscript.' "'.$args[0].'" "'.$args[1].'" "'.$args[2].'" '.$nblignes.' < '.$amendementsfile." | tail -n 1\n");
}


