#!/bin/perl
# Wrapper for emitting all in once for one commune : all censuses, grouped by register
# Like gen-new-ids-nmd-all.pl but inline gen-new-ids-nmd.pl in order to have better output, readier to use


use strict;
use Data::Dumper;
use File::Temp qw(tempfile);
use HTML::TableExtract;
use List::Util;
use Scalar::Util qw(looks_like_number);

my ($ville, $md5) = @ARGV;

# MD5SUM comes from the "REch_commune_Md5=" when doing a request on https://recherche.archives.finistere.fr/archive/resultats/etatcivil/n:138?
my %villes = (
    'Bannalec' => 'dcf2206f47407a1bf48605e0bb530622',
    'Beuzec-Conq' => '0d0d4f67092f7818c9848de6895d9e3e',
    'Carhaix' => 'f9e985cbb1445d7e1f082868b76e19e9',
    'Cléden-Poher' => '5be72e6a952159ab5ea609ce32073fcc',
    'Châteauneuf-du-Faou' => 'c4e561615bc60b9006dd2126a0a34a81',
    'Concarneau' => '138f8fa29371880cfddd91bd286d4bd5',
    'Elliant' => '64b3c3ec77773f58f3967ca255acb1c6',
    'Fouesnant' => '810c361c96ad6fb8548ba3a6cbfc1f30',
    'Kergloff' => 'b514c4417f09b16bf87e6d3adcf13473',
    'Kernével' => 'e5a954d46ea1c9ecd8a89c955023f326',
    'Landeleau' => 'cb35595a1cd1f1870791fe496ae679d6',
    'Laz' => '9e65506ecf84c23dc0dae3c751b28bbd',
    'Le Moustoir' => 'bd1776d155d280f985d30f73b87b2530',
    #'Le+Moustoir' => 'bd1776d155d280f985d30f73b87b2530', # commented out due to sanity check
    'Leuhan' => 'eb2f0726cae4778ee9538ef597db7f92',
    'Locmaria-Berrien' => '4c09c40124360cd6314ab2759a1c79ac',
    'Locmaria-an-Hent' => 'b5a5509cbc217d7767e65f5628e760c5',
    'Melgven' => 'c574b669ddf7a891dfeff601cb25ecb4',
    'Motreff' => '4c3ae13cbf62a5e72b9c034018a6a467',
    'Plonéis' => 'c2e2fc6c89a009fcc699e9d615eae31d',
    'Plonévez-du-Faou' => '3dd456aaae4fef02b19832b0e3daeb8f',
    'Plouguer' => 'f96ae4a1741a2ec286a159cf90e26788%7C',
    'Plounévézel' => '88514f3e1b6bb4b2bb40e42067c7d4a5',
    'Poullaouen' => 'fe51e2fc610856ad9d8aeb573f8452d4',
    'Quéménéven' => 'a594ce426ea4fa1b88fd6ebed913202e',
    'Querrien' => 'b97876ea08c0a92eb4dfee07349382f2',
    'Rosnoën' => 'b8fb689b18cbf17a533ac9835b7f5c97',
    'Saint-Goazec' => '0a844f426cd1fac6871d300fee00f491',
    'Saint-Hernin' => '4253319ee371d0a987f959bf9da20d89',
    'Saint-Quijeau' => 'bc506da005d12c0c478dd344c3a35314',
    'Saint-Thurien' => '6f370d60e404cff523ade007336a076a',
    'Saint-Yvi' => 'd3390a4cb3c1a6bafc609604d7071491',
    'Scaër' => '9c354717cc7a5c14e68227d48522db2a',
    'Spézet' => 'b6713734e42457b28f4773f547444ce7',
    "Tourc'h" => '4bf1ee125457d932f80806b7da556577',
    'Tourch' => '6e5e559fd968f5b9686bd78989889cf2',
    );


# Sanitation check: Make sure that each old key translates to a unique key
# TODO: would need to check subkeys too for registers split by year
my %seen_keys;
foreach my $key (keys %villes) {
    push @{$seen_keys{$villes{$key}}}, $key;
}
# Ignore empty key (bug on AD29 site):
delete $seen_keys{''};
foreach my $key (keys %seen_keys) {
    if (@{$seen_keys{$key}} > 1) {
	print "\nDuplicate keys for value $key:\n";
	print "$_\n" foreach @{$seen_keys{$key}};
	exit 1;
    }
}
# end of check


# https://recherche.archives.finistere.fr/archive/recherche/recensements/tableau?RECH_commune_Libel=Saint-Hernin%20(Finistère)|&RECH_commune_Md5=4253319ee371d0a987f959bf9da20d89|&type=recensements

# A cople special cases (usually when two towns were merged):
my %special_towns = (
    'Beuzec-Conq' => 'Beuzec-Conq (Concarneau, Finistère)',
    'Carhaix' => 'Carhaix%20(Carhaix-Plouguer,%20Finistère)',
    'Kernével' => 'Kernével (Rosporden, Finistère)',
    'Locmaria-an-Hent' => 'Locmaria-an-Hent (Saint-Yvi, Finistère)',
    'Plouguer' => 'Plouguer+%28Carhaix-Plouguer%2C+Finistère',
    'Saint-Quijeau' => 'Saint-Quijeau%20(Plouguer,%20Carhaix-Plouguer,%20Finistère)',
    'Le Moustoir' => 'Le%20Moustoir%20(Châteauneuf-du-Faou,%20Finistère)',
    'Le+Moustoir' => 'Le+Moustoir+%28Châteauneuf-du-Faou%2C+Finistère%29',
    );

# Autoguess MD5:
$md5 ||= $villes{$ville};

if (!$ville) {
    die qq(Usage:
$0 <ville>
Eg: $0 'Carhaix'
);
}

my $real_ville = $special_towns{$ville} || $ville =~ /Finist/ ? $ville : "$ville+(Finistère)"; # %20(Finistère)
#my $real_ville = $ville =~ /Finist/ ? $ville : "$ville+(Finistère)"; # %20(Finistère)

# The split is different for each type (eg: 1881-1891 for births but 1883-1892 for deaths)
# we cannot actually request the web site for a year range, but we can by "côte":
my %cotes = (
    'Recensement' => {
	# Recensements < 1946:
	'"6 M"' => undef, # doesn't work w/o doble quotes in the string
	# Recensements >= 1946:4
	'238 W' => undef,
	# Other towns have "126 W", "179 W"
    },
    );

my ($_fh, $filename) = tempfile();
END {
    unlink($filename);
}

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
    'An III' => 'AN03',
    'An IV' => 'AN04',
    'An IX' => 'AN09',
    'An V' => 'AN05',
    'An VI' => 'AN06',
    'An VII' => 'AN07',
    'An VIII' => 'AN08',
    'An X' => 'AN10',
    'An XI' => 'AN11',
    'An XI-1812' => 'AN11',
    'An XII' => 'AN12',
    'An XIII' => 'AN13',
    'An XIV - 1806' => 'AN14',
    );

# https://recherche.archives.finistere.fr/archive/resultats/recensements/n:139?RECH_commune_Libel=Sca%C3%ABr%20(Finist%C3%A8re)|&RECH_commune_Md5=9c354717cc7a5c14e68227d48522db2a|&type=recensements
my $url = "https://recherche.archives.finistere.fr/archive/recherche/recensements/tableau?RECH_commune_Libel=%s|&RECH_commune_Md5=%s|&Rech_cote=%s&type=recensements";
my $url_nomd5 = "https://recherche.archives.finistere.fr/archive/resultats/recensements/n:139?RECH_commune=%s&Rech_cote=%s&type=recensements";
my (%results, %pretty);
foreach my $type (qw(Recensement)) {
    my $cotes2 = $cotes{$type};
    foreach my $cote (sort(keys %$cotes2)) {
	warn ">> TRY " . sprintf($url, $real_ville, $md5, $cote) . "\n";
	if ($md5) {
	    process(sprintf($url, $real_ville, $md5, $cote));
	} else {
	    process(sprintf($url_nomd5, $real_ville, $cote));
	}
    }
}

use Data::Dumper; output("dump.pm", Data::Dumper->Dump([ \%pretty, \%results ], [ qw(pretty results) ]));

# Output all:
foreach my $id (sort keys %results) {
    # print hash opening with comment:
    my %subhash = %{$results{$id}};
    my $nb = scalar keys %subhash;
    if ($nb == 1) {
	my ($str) = values %subhash;
	$str =~ s/.* => //;
	print "    '$id' => $str";
	next;
    }
    print sprintf("    '$id' => {			# $pretty{$id}   %s-%s\n", min(keys %subhash), max(keys %subhash));
    foreach my $year (sort keys %subhash) {
	print $subhash{$year};
    }
    # Close hash:
    print "    },\n\n";
}

#========================
# From gen-new-ids-nmd.pl:
#!/bin/perl
# Generate the table for converting old permalinks to new ones

# From the old AD29 permalinks I'd in my tree:

sub process {
    my ($url) = @_;

    # Force 25 resultats per page:
    $url .= "&pagination_25";


    #warn ">> Using temp file: $filename\n";
    system('wget', '-q', '-O', $filename, $url);

    my $te = HTML::TableExtract->new(attribs => { id => 'resultats' }, keep_html => 1);
    $te->parse_file($filename);
    my ($table) = $te->tables;
    if (!$table) {
	warn ">> ERROR: No results for URL='$url'\n";
	return;
    }
    my $i;
    foreach my $row ($table->rows) {
	# rows are : Commune, year, cote, link, actions…
	# eg: "Cléden-Poher (Finistère)", "1793 - an II", "naissance", "3 E 42/11/1", <link>

	my ($commune, $year, $id, $link) = @$row;
	$i++;
	next if $i == 1; # skip header line
	# Formating:
	$commune =~ s/<[^>]*>//g;
	$commune =~ s/ \(Finist.*re\)//;
	# Use the IDS that appears in old permalinks, eg: 'AN08' as in 'FRAD029_3E010_0028_00D_AN08_007.jpg':
	$year = $conv_cal_republicain{$year} || $year;
	my ($ark) = $link =~ m!/ark:/72506/([^/]+)/!;
	my $mainID;
	# The web site returns different types of IDs :-(
	if ($id =~ m!^\d+ L \d+/\d+!) {     # eg: "10 L 177/7/1"
	    # FIXME/TODO: I've no such permalink to doble check in my tree!
	    $mainID = format_6M($id);
	} elsif ($id =~ m!^\d M \d+/\d+!) { # eg: "6 M 820/2"
	    $mainID = format_6M($id);
	} elsif ($id =~ m!^\d+ W \d+!) { # eg: "238 W 7"
	    $mainID = format_238W($id);
	} else {
	    warn ">> FAILED TO PARSE ID='$id'\n";
	}
	if ($link) {
	    ($link) = $link =~ m!<a href="(/ark[^"]*)"!;
	    # emit quotes if republican years, else just add 2 spaces for padding if numerical:
	    #eg: "	1917 => '1373293',		# Naissances Spezet  3 E 348 49 1	1917"
	    my $str_year;
	    if ($mainID =~ /^\d+ E DEPOT/) { # Collection communale
		$str_year = $id;
		$str_year =~ s/ E-dépôt/ E DEPOT/; # Normalize
		my @l = split(' E DEPOT ', $str_year);
		$str_year = sprintf("'%sEDEPOT_%03d'", $l[0], $l[1]); # eg: '1024EDEPOT_010'  # Ideally to doble check in old tree!
	    } else {
		$str_year = looks_like_number($year) ? "$year  " : "'$year'";
	    }
	    #warn "--> ID(year) $id ==> $mainID -> $str_year\n";
	    my $rec_id = format_6M_long($id);
	    $results{$mainID}{$year} = "	'$rec_id' => '$ark',	# Recensement $commune $id ($year)\n";
	    #warn "--> ID(section) $id ==> $mainID\n";
	    # the section ID is recomputed everytime but who cares…
	    my $prettyID = $id;
	    $prettyID =~ s!/\d+$!!;
	    $pretty{$mainID} = "Recensement $commune $prettyID";
	}
    }
}

sub format_238W {
    my ($id) = @_;
    # Normalize: '238 W 2' => '238W02_10' # FIXME/BUG: the "_10" from old permalink doesn't appear on the new web site result!
    $id =~ s!/! !g;
    sprintf("%s%s%02d_%02d", split(' ', $id)); # Ideally to doble check in old tree!
}

sub format_6M_long {
    my ($id) = @_;
    # Normalize: '6 M 833/5' =>  6M_0833_05
    $id =~ s!/! !g;
    sprintf("%s%s_%04d_%02d", split(' ', $id)); # Ideally to doble check in old tree!
}

sub format_6M {
    my ($id) = @_;
    # Normalize: '6 M 820/2' =>  6M0820
    $id =~ s!/! !g;
    my ($a, $b, $c) = split(' ', $id);
    sprintf("%s%s%04d", $a, $b, $c); # Ideally to doble check in old tree!
}

# From MDK::Common:
sub min  { my $n = shift; $_ < $n and $n = $_ foreach @_; $n }
sub max  { my $n = shift; $_ > $n and $n = $_ foreach @_; $n }
sub output { my $f = shift; open(my $F, ">$f") or die "output in file $f failed: $!\n"; print $F $_ foreach @_; 1 }
