#!/bin/perl
# Generate the table for converting old permalinks to new ones

use strict;
use Data::Dumper;
use File::Temp qw(tempfile);
use HTML::TableExtract;

my ($url) = @ARGV;

if (!$url) {
    die qq(No URL provided !" ;
Usage : $0 <url>
eg for 1920's registre matricule :
$0 "https://recherche.archives.finistere.fr/archive/resultats/matricules/n:141?RECH_dateclassefacettes=1920&type=matricules");
}

my ($_fh, $filename) = tempfile();
END {
    unlink($filename);
}

#warn ">> Using temp file: $filename\n";
system('wget', '-q', '-O', $filename, $url);

my $te = HTML::TableExtract->new(attribs => { id => 'resultats' }, keep_html => 1);
$te->parse_file($filename);
my ($table) = $te->tables;
foreach my $row ($table->rows) {
    # rows are : "Bureau desc", year, ID, link, notice_link
    # eg: "Bureau de Brest n° 1001 à 1500.", "1920", "1 R 1644", "<a href=…", [notice button]
    my ($desc, $year, $id, $link) = @$row;
    next if $id =~ /<a href.*Cote/; # Skip header line (alternatively we could count and skip first line)
    ($link) = $link =~ m!<a href="(/ark[^"]*)"!;
    #format id:
    my ($prefix, $suffix) = split(' R ', $id);
    $id = sprintf("${prefix}R%05d", $suffix);
    my ($ark) = $link =~ m!/ark:/72506/([^/]+)/!;
    #eg: "    '1R01653' => '1145865',			# Bureau de Brest-Châteaulin n° 4001 à 4422, 4433 à 4434, 4439 à 4440. (1920)"
    print "    '$id' => '$ark',			# Bureau $desc ($year)\n";
}
