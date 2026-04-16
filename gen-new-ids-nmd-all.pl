#!/bin/perl
# Wrapper for emitting all in once for one commune : all births, mariages & deaths, grouped by register
# FIXME : collect all data in a hash before outputing at once at the end? (less manual formating after)

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
    },

    'Décès' => {
	1793 => 1802,
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

my $url = "https://recherche.archives.finistere.fr/archive/resultats/etatcivil/tableau/n:138/limit:20?REch_commune_Libel=%s|&REch_commune_Md5=%s|&Rech_typologie[0]=%s&RECH_unitdate_debut=%s&RECH_unitdate_fin=%s&type=etatcivil&pagination_25";
foreach my $type (qw(Naissance Décès)) {
    my $years2 = $years{$type};
    foreach my $first (sort(keys %$years2)) {
	my $end = $years2->{$first};
	#warn ">> TRY " . sprintf($url, $real_ville, $md5, $type, $first, $end) . "\n";
	system('./gen-new-ids-nmd.pl', '--no-warning', sprintf($url, $real_ville, $md5, $type, $first, $end));
    }
}
