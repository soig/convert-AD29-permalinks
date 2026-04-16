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

# From the old AD29 permalinks I'd in my tree:
my %conv_cal_republicain = (
    '1793 - an II' => 'AN02',
    'an III' => 'AN03',
    'an IV' => 'AN04',
    'an IX' => 'AN09',
    'an V' => 'AN05',
    'an VI' => 'AN06',
    'an VII' => 'AN07',
    'an VIII' => 'AN08',
    'an X' => 'AN10',
    'an XI' => 'AN11',
    'an XII' => 'AN12',
    'an XIII' => 'AN13',
    'an XIV - 1806' => 'AN14',
    );

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
    my $year = $conv_cal_republicain{$desc} || $desc;
    my ($ark) = $link =~ m!/ark:/72506/([^/]+)/!;
    if ($link) {
	($link) = $link =~ m!<a href="(/ark[^"]*)"!;
	#eg: "	1917 => '1373293',		# Naissances Spezet  3 E 348 49 1	1917"
	print "	'$year' => '$ark',            # $type $commune $id ($desc)\n";
    } else {
	# print hash opening with comment (note that one element will be off b/c AD29 badly sort):
	my @oldid = split(' ', $id);
	my $oldid = sprintf("%s%s%s_%04d", @oldid); # Ideally to doble check in old tree!
	print qq(    },

    '$oldid' => {			# $type $commune $id   <YEARS TO FILL>"
);

    }
}
print qq(>> WARNING: ARK ID will be bogus for registers that are not split by years!
In all cases you need the ID used in the old URL!
For example if key is '1793 - an II', the real key from old URL is actually 'AN02' !
);
