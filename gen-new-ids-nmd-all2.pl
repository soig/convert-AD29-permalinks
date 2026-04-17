#!/bin/perl
# Wrapper for emitting all in once for one commune : all births, mariages & deaths, grouped by register
# Like gen-new-ids-nmd-all.pl but inline gen-new-ids-nmd.pl in order to have better output, readier to use
# FIXME: add options to select only N, M or D?


use strict;
use Data::Dumper;
use File::Temp qw(tempfile);
use HTML::TableExtract;
use List::Util;
use Scalar::Util qw(looks_like_number);

my ($ville, $md5) = @ARGV;

my %villes = (
    'Carhaix' => 'f9e985cbb1445d7e1f082868b76e19e9',
    'Cléden-Poher' => '5be72e6a952159ab5ea609ce32073fcc',
    'Châteauneuf-du-Faou+%28Finistère%29' => 'c4e561615bc60b9006dd2126a0a34a81',
    'Kergloff' => 'b514c4417f09b16bf87e6d3adcf13473',
    'Le Moustoir' => 'bd1776d155d280f985d30f73b87b2530',
    'Le+Moustoir' => 'bd1776d155d280f985d30f73b87b2530',
    'Motreff' => '4c3ae13cbf62a5e72b9c034018a6a467',
    'Plonéis' => 'c2e2fc6c89a009fcc699e9d615eae31d',
    'Plouguer' => 'f96ae4a1741a2ec286a159cf90e26788%7C',
    'Saint-Hernin' => '4253319ee371d0a987f959bf9da20d89',
    'Saint-Quijeau' => 'bc506da005d12c0c478dd344c3a35314',
    'Spézet' => 'b6713734e42457b28f4773f547444ce7',
    "Tourc'h" => '4bf1ee125457d932f80806b7da556577',
    'Tourch' => '6e5e559fd968f5b9686bd78989889cf2',
    );
    
# "https://recherche.archives.finistere.fr/archive/resultats/etatcivil/tableau/n:138/limit:15?REch_commune_Libel=Cl%A8!è%A9den-Poher+%28Finist%C3%A8re%29%7C&REch_commune_Md5=5be72e6a952159ab5ea609ce32073fcc%7C&Rech_typologie%5B0%5D=Naissance&RECH_unitdate_debut=1793&RECH_unitdate_fin=1810&type=etatcivil");

# A cople special cases (usually when two towns were merged):
my %special_towns = (
    'Carhaix' => 'Carhaix%20(Carhaix-Plouguer,%20Finistère)',
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

if (!$md5) {
    die "Unknown MD5 for '$ville'\n";
}

my $real_ville = $special_towns{$ville} || $ville =~ /Finist/ ? $ville : "$ville+(Finistère)"; # %20(Finistère)
#my $real_ville = $ville =~ /Finist/ ? $ville : "$ville+(Finistère)"; # %20(Finistère)

# The split is different for each type (eg: 1881-1891 for births but 1883-1892 for deaths)
my %years = (
    'Naissance' => {
	1793 => 1802,
	1802 => 1822,
	1823 => 1832,
	1833 => 1842,
	1843 => 1852,
	1853 => 1862,
	1863 => 1869,
	1870 => 1880,
	1881 => 1891,
	1892 => 1904,
	1904 => 1913,
	1914 => 1923,
	1924 => 1925, # Technically 1924-1936 but later years weren't online on the old server
    },

    'Mariage' => {
	# FIXME: to split if too wide a span?
	1793 => 1812,
	1813 => 1832,
	1833 => 1842,
	1843 => 1852,
	1853 => 1862,
	1863 => 1869,
	1870 => 1887,
	1888 => 1903,
	1904 => 1917,
	1918 => 1925, # Technically 1919-1936 but later years weren't online on the old server
    },

    'Décès' => {
	1793 => 1802,
	# FIXME : we usually emit a hole here for years 1804-1806
	1802 => 1822,
	1823 => 1832,
	1833 => 1842,
	1843 => 1852,
	1853 => 1862,
	1863 => 1872,
	1870 => 1882,
	1883 => 1895,
	1896 => 1909,
	1910 => 1921,
	1922 => 1936,
    },
    );

my ($_fh, $filename) = tempfile();
END {
    unlink($filename);
}

my $url = "https://recherche.archives.finistere.fr/archive/resultats/etatcivil/tableau/n:138/limit:20?REch_commune_Libel=%s|&REch_commune_Md5=%s|&Rech_typologie[0]=%s&RECH_unitdate_debut=%s&RECH_unitdate_fin=%s&type=etatcivil&pagination_25";
my (%results, %pretty);
foreach my $type (qw(Naissance Mariage Décès)) {
    my $years2 = $years{$type};
    foreach my $first (sort(keys %$years2)) {
	my $end = $years2->{$first};
	#warn ">> TRY " . sprintf($url, $real_ville, $md5, $type, $first, $end) . "\n";
	process(sprintf($url, $real_ville, $md5, $type, $first, $end));
    }
}

use MDK::Common; use Data::Dumper; output("dump.pm", Data::Dumper->Dump([ \%pretty, \%results ], [ qw(pretty results) ]));

# Output all:
foreach my $id (sort keys %results) {
    # print hash opening with comment:
    my %subhash = %{$results{$id}};
    print sprintf("    '$id' => {			# $pretty{$id}   %s-%s\n", min(keys %subhash), max(keys %subhash));
    foreach my $year (sort keys %subhash) {
	my $link = $subhash{$year};
	($link) = $link =~ m!<a href="(/ark[^"]*)"!;
	# emit quotes if republican years, else just add 2 spaces for padding if numerical:
	#eg: "	1917 => '1373293',		# Naissances Spezet  3 E 348 49 1	1917"
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

sub process {
    my ($url) = @_;
    
    # Force 25 resultats per page:
    $url .= "pagination_25";


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
	my $year = $conv_cal_republicain{$desc} || $desc;
	my ($ark) = $link =~ m!/ark:/72506/([^/]+)/!;
	my $mainID;
	# The web site returns different types of IDs :-(
	if ($id =~ /^3 E \d+ \d+/) { # eg: "3 E 37 21"
	    $mainID = format_3E($id);
	} elsif ($id =~ /^(\d+) E DEPOT \d+|^(\d+) E-dépôt \d+/) { # eg: "1024 E DEPOT 28" or "1029 E-dépôt 1"
	    # We'll create a subhash but it's special case to manually
	    # remove from subhash, those needs to be included at the
	    # top of the main hash in convert-finistere.pl
	    $mainID = ($1 || $2) . " E DEPOT";
	} elsif ($id =~ m!^(3 E \d+/\d+)/\d+!) { # eg: 3 E 37/41/7
	    $mainID = format_3E($1);
	    $mainID =~ s!/! !;
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
	    $results{$mainID}{$year} = "	$str_year => '$ark',            # $type $commune $id ($desc)\n";
	} else {
	    warn "--> ID(section) $id ==> $mainID\n";
	    $pretty{$mainID} = "$type $commune $id";
	}
    }
}

sub format_3E {
    my ($id) = @_;
    # '3 E 37 14' or '3 E 37/41' 
    # Normalize:
    $id =~ s!/! !g;
    sprintf("%s%s%03d_%04d", split(' ', $id)); # Ideally to doble check in old tree!
}
