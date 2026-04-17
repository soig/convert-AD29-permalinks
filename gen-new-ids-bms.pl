#!/bin/perl
# Generate the table for converting old permalinks to new ones

use strict;
use Data::Dumper;
use File::Temp qw(tempfile);
use HTML::TableExtract;

my ($url) = @ARGV;

if (!$url) {
    die qq(No URL provided !
Don't use a too wide year range else some results will be "lost" (links to 2nd, 3rd, … pages)
Usage : $0 <url>
eg for 1920's naissances :
$0 "https://recherche.archives.finistere.fr/archive/resultats/etatcivil/tableau/n:138/limit:15?REch_commune_Libel=Cl%C3%A9den-Poher+%28Finist%C3%A8re%29%7C&REch_commune_Md5=5be72e6a952159ab5ea609ce32073fcc%7C&Rech_typologie%5B0%5D=Naissance&RECH_unitdate_debut=1793&RECH_unitdate_fin=1810&type=etatcivil");
}

# Force 25 resultats per page:
$url .= "pagination_25";

my ($_fh, $filename) = tempfile();
END {
    unlink($filename);
}

#warn ">> Using temp file: $filename\n";
system('wget', '-q', '-O', $filename, $url);

my $te = HTML::TableExtract->new(attribs => { id => 'resultats' }, keep_html => 1);
$te->parse_file($filename);
my ($table) = $te->tables;
my $i;
foreach my $row ($table->rows) {
    # rows are : Commune, desc, type, cote, link, actions…
    # eg: "Cléden-Poher (Finistère)", "1793 - an II", "naissance", "3 E 42/11/1", <link>

    my ($commune, $desc, $type, $id, $link) = @$row;
    $i++;
    next if $i == 1; # skip header line
    # Formating:
    $commune =~ s/<[^>]*>//g;
    $commune =~ s/ \(Finist.*re\)//;
    $type = ucfirst($type);
    # Use the IDS that appears in old permalinks, eg: 'AN08' as in 'FRAD029_3E010_0028_00D_AN08_007.jpg':
    my ($ark) = $link =~ m!/ark:/72506/([^/]+)/!;
    if ($link) {
	($link) = $link =~ m!<a href="(/ark[^"]*)"!;
	# Collection communale:
	if (my ($prefix, $suffix) = $id =~ /([0-9]+) E-dépôt ([0-9]+)/) {
	    # for old URLs such as eg:
	    # https://recherche.archives.finistere.fr/viewer/series/medias/collections/EDEPOT/1237EDEPOT/1237EDEPOT_001
	    # https://recherche.archives.finistere.fr/viewer/series/medias/collections/EDEPOT/1024EDEPOT/1024EDEPOT_010?img=FRAD029_1MIEC037_04_0306.jpg
	    my $oldid = sprintf("%04dEDEPOT_%03d", $prefix, $suffix);
	    print "    '$oldid' => '$ark', # $type $commune $id ($desc)\n";
	} elsif (my ($prefix, $suffix1, $suffix2) = $id =~ /([0-9]+) E ([0-9]+) ([0-9]+)/) {
	    # Collection départementale;
	    my $oldid = sprintf("${prefix}E%03d_%04d", $suffix1, $suffix2);
	    print "    '$oldid' => '$ark',	# $type $commune $id ($desc)\n";
	} else {
	    print ">> FAILED TO PARSE '$id'\n";
	}
    }
}
