#!/usr/bin/perl

use WWW::Mechanize;
use HTML::TokeParser;
use Data::Dumper;

$dossier_url = shift;
if ($dossier_url =~ /\/([^\/]+)\.html$/) {
	$dossiersenat = $1;
}

if (!$dossier_url) {
	print "USAGE: perl parse_dossier.pl <url dossier senat> <include header>\n";
	print "\n";
	print "Transforme les dossiers du sénat en un CSV qui contient les url des textes aux différentes étapes\n";
	exit 1;
}

$a = WWW::Mechanize->new();
$a->get($dossier_url);
$content = $a->content;

$p = HTML::TokeParser->new(\$content);

if ($content =~ /timeline-1[^>]*<em>(\d{2})\/(\d{2})\/(\d{2})<\/em>/) {
	print "date : $1/$2/$3\n";
}
@date=();
while ($t = $p->get_tag('div')) {
    if ($t->[1]{id} =~ /block-timeline/) {
        $p->get_tag('ul');
	while (($t = $p->get_tag('li', '/ul')) &&  $t->[0] eq 'li') {
	    $t = $p->get_tag('a');
	    if ($t->[1]{href} =~ /timeline-(\d+)/) {
		$id = $1;
	    }
	    $t = $p->get_tag('em');
	    $txt = $p->get_text('/em');
	    if ($txt =~ /(\d{2})\/(\d{2})\/(\d{2})/) {
		$date[$id] = '20'.$3.'-'.$2.'-'.$1;
	    }
	}
    }
    if ($t->[1]{id} =~ /^timeline-(\d+)/) {
	$id = $1;
	last;
    }
}

$date = $date[1];

$ok = 1;
@lines = ();
while ($ok) {
    $t = $p->get_tag('em', 'img', 'a', 'div', 'h3');
    if($t->[0] eq 'em') {
	$etape = $p->get_text('/em');
	utf8::encode($etape);
	$etape =~ s/dfiniti/definiti/;
    }elsif($t->[0] eq 'img' && $t->[1]{src} =~ /picto_timeline_0([1234])_on.png/) {
	$img = $1;
	if ($img == 3) {
	    $stade = "commission";
	}elsif($img == 4) {
	    $stade = "hemicycle";
	}elsif ($img == 2) {
	    $chambre = "senat";
	    $stade = 'depot';
	}elsif($img == 1) {
	    $chambre = "assemblee";
	    $stade = 'depot';
	}
    }elsif($t->[0] eq 'a' && $t->[1]{href} !~ /^\#/) {
	if ($t->[1]{href} =~ /\/dossiers\/([^\.]+)\./) {
		if ($1 !~ /_scr$/) {
			$dossieran = $1;
		}
	}
      	if ($t->[1]{href} =~ /\/leg\/p/ || $p->get_text('/a') =~ /Texte/ || $t->[1]{href} =~ /conseil-constitutionnel/ || $t->[1]{href} =~ /legifrance/) {
	    $url = $t->[1]{href};
	    $url = "http://www.senat.fr".$url if ($url =~ /^\//) ;
            $idtext = '';
	    $printid = $id;
	    if ($url =~ /legifrance/) {
		$url =~ s/;jsessionid=[^\?]*//;
		$url =~ s/&.*//;		
		$etape = "promulgation";
		$chambre = 'gouvernement';
		$stade = 'JO';		
		$printid = 'EXTRA';
	    }elsif ($url =~ /conseil-constitutionnel/) {
		$url =~ s/#.*//;
		$etape = "constitutionnalité";
		$chambre = 'conseil constitutionnel';
		$stade = 'conforme';
		if ($p->get_text('/li') =~ /\((.*)\)/) {
		    $stade = $1;
		}
		$printid = 'EXTRA';
	    }elsif ($url =~ /assemblee-nationale/) {
		$chambre = 'assemblee' if ($stade eq 'hemicycle');
		if ($url =~ /[^0-9]0*([1-9][0-9]*)(-a\d)?\.asp$/) {
			$idtext = $1;
		}
            }elsif ($url =~ /senat.fr/) {
		$chambre = 'senat' if ($stade eq 'hemicycle');
		if ($url =~ /(\d{2})-(\d+)\.html$/) {
			$idtext='20'.$1.'20'.($1+1).'-'.$2;
		}
            }
	    $lines[$#lines+1] =  "$printid;$etape;$chambre;$stade;$url;$idtext;".$date[$id];
	    $url = '';
	}
	if ($t->[1]{href} =~ /^mailto:/) {
	    last;
	}
    }elsif($t->[0] eq 'div' && $t->[1]{id} =~  /^timeline-(\d+)/) {
	$id = $1;
    }elsif($t->[0] eq 'h3' && $t->[1]{class} =~ /title/) {
	if ($p->get_text('/h3') =~ /mixte paritaire/) {
	    $chambre = 'CMP';
            $etape = 'CMP';
	}
    }
}

$cpt = 0;
print "dossier begining ; an's dossier id ; senat's dossier id ; line id ; senat's step id ; stage ; chamber ; step ; bill url ; bill id ; date depot text; text date\n" if (shift);
foreach $l (@lines) {
        $idline = sprintf("%02d", $cpt);
	print "$date;$dossieran;$dossiersenat;$idline;$l\n";
	$cpt++;
}

if ($content =~ /Proc\S+dure acc\S+l\S+r\S+e/) {
    %mois = ('janvier'=>'01', 'février'=>'02', 'mars'=>'03', 'avril'=>'04', 'mai'=>'05', 'juin'=>'06', 'juillet'=>'07', 'août'=>'08', 'septembre'=>'09','octobre'=>'10','novembre'=>'11','décembre'=>'12');
    if ($content =~ /engag\S+e par le Gouvernement le (\d+) (\w+) (\d+)/) {
	$mois = $2;utf8::encode($mois);
	print "$date;$dossieran;$dossiersenat;XX;EXTRA;URGENCE;Gouvernement;URGENCE;;;$3-".$mois{$mois}."-$1\n";
    }
}
exit;
