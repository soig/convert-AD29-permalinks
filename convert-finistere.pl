#!/bin/perl
# Converion to official permalinks not to direct view links
# Eg: OLD https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/03E/3E234/3E234_0004?img=FRAD029_1MIEC234_06_0052.jpg
# Could be  https://recherche.archives.finistere.fr/ark:/72506/659573.1340592/daoloc/0/48 (like AD56 is doing)
# (which matches the view number eg 48/207 here)
# But we do https://recherche.archives.finistere.fr/ark:/72506/659573.1340592/img:FRAD029_1MIEC234_06_0052
# (which is what we got when clicking on the permalien)
#
# Sometimes, there's a huge discrepedancy between view number & image number:
# Eg "vue 6/83" is img 218 : https://recherche.archives.finistere.fr/ark:/72506/652437.1277175/img:FRAD029_1MIEC042_04_0218

use strict;

my $_old_prefix = 'https://recherche.archives.finistere.fr/viewer/series/medias/collections/'; # unused, for reference only
my $prefix     = 'https://recherche.archives.finistere.fr/ark:/72506/';

# The config for converting old obsolete permalinks into new ones:
# - old software included the register ID in the URL
# - new one includes an arbitrary ID
# We need to map then
#
# There's a special case for registers that has been split per year:
# We map to a sub hash mapping eavery year
# B/c we need to account either eg s=FRAD029_3E348_0050_00N_1925_001.jpg or levelDescription=FRAD029_00003E348_pa-1204 from the old URL
# Compare
# Spezet 1924: https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/03E/3E348/3E348_0050?s=FRAD029_3E348_0050_00N_1924_001.jpg&e=FRAD029_3E348_0050_00N_1924_028.jpg&img=FRAD029_3E348_0050_00N_1924_007.jpg&levelDescription=FRAD029_00003E348_pa-1203
# => https://recherche.archives.finistere.fr/ark:/72506/1373301/daogrp/0/layout:table/idsearch:RECH_FranceConnect_bb51b13adf7724dfe3a92e71b3dc52b9
# Spezet 1925: https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/03E/3E348/3E348_0050?s=FRAD029_3E348_0050_00N_1925_001.jpg&e=FRAD029_3E348_0050_00N_1925_029.jpg&img=FRAD029_3E348_0050_00N_1925_008.jpg&levelDescription=FRAD029_00003E348_pa-1204
# => https://recherche.archives.finistere.fr/ark:/72506/1373302/daogrp/0/layout:table/idsearch:RECH_FranceConnect_bb51b13adf7724dfe3a92e71b3dc52b9
# Same register so duplicating 3E348_0050 but each year has a different ID : '1373301' vs '1373302'

my %convert = (
	'1237EDEPOT' => '645578.1478934',	# Sép Saint-Hernin 1753-1787 (comm)
	# Registre matricule:
	'1R01653' => '1145865',			# Bureau de Brest-Châteaulin n° 4001 à 4422, 4433 à 4434, 4439 à 4440. (1920)
	'3E037_0001' => '652175.1275534',	# BMS Carhaix  3 E 37/1		1674-1689
	'3E037_0002' => '652176.1275535',	# BMS Carhaix  3 E 37/2		1690-1714
	'3E037_0003' => '652177.1275536',	# BMS Carhaix  3 E 37/3		1715-1728
	'3E037_0004' => '652178.1275537',	# BMS Carhaix  3 E 37/4		1729-1743
	'3E037_0005' => '652179.1275538',	# BMS Carhaix  3 E 37/5		1744-1752
	'3E037_0006' => '652180.1275540',	# BM  Carhaix  3 E 37/6		1753-1766
	'3E037_0007' => '652181.1275541',	# BM  Carhaix  3 E 37/7		1767-1780
	'3E037_0008' => '652182.1275542',	# BM  Carhaix  3 E 37/8		1781-1792
	'3E037_0009' => '652183.1275544',	# Sép Carhaix  3 E 37/9		1754-1766
	'3E037_0010' => '652184.1275545',	# Sép Carhaix  3 E 37/10	1767-1780
	'3E037_0011' => '652185.1275546',	# Sép Carhaix  3 E 37/11	1781-1792
	#'3E037_0012' => '',			# Naissances Carhaix  3 E 37/12	1793-an X	Pas numérisé
	'3E042_0001' => '652429.1277165',	# BMS Cleden-Poher 3 E 42 1	1694-1712
	'3E042_0002' => '652430.1277166',	# BMS Cleden-Poher 3 E 42 2	1713-1730
	'3E042_0003' => '652431.1277167',	# BMS Cleden-Poher 3 E 42 3	1730-1746
	'3E042_0004' => '652432.1277168',	# BMS Cleden-Poher 3 E 42 4	1743-1752
	'3E042_0005' => '652433.1277170',	# BMS Cleden-Poher 3 E 42 5	1753-1766
	'3E042_0006' => '652434.1277171',	# BMS Cleden-Poher 3 E 42 6	1767-1780
	'3E042_0007' => '652435.1277172',	# BMS Cleden-Poher 3 E 42 7	1781-1792
	'3E042_0008' => '652436.1277174',	# Sép Cleden-Poher 3 E 42 8	1753-1766
	'3E042_0009' => '652437.1277175',	# Sép Cleden-Poher 3 E 42 9	1767-1780
	'3E042_0010' => '652438.1277176',	# Sép Cleden-Poher 3 E 42 10	1781-1792
	'3E190_0035' => '',			# Sép Le Moustoir		1755-1773 (BUG/FIXME: n'apparait plus avec le nouveau site!)
	'3E212_0002' => '658571.1332282',	# BM  Plonéis  3 E 212 2	1749-1774
	'3E212_0003' => '658572.1332283',	# BM  Plonéis  3 E 212 3	1775-1792
	'3E212_0004' => '658573.1332285',	# Sép Plonéis  3 E 212 4	1749-1792
	'3E234_0004' => '659573.1340592',	# Sép Plouguer 3 E 234 4
	'3E309_0005' => '1040259.1634656',	# Sép Saint-Hernin 1753-1792
	# TODO: more compact format if there's no jump (eg: first_year_id => , first_year => 1870, last_year => 1883, last_year_id => …) ?
	# TODO: BMS
	# TODO: Sépultures Carhaix, Cleden-Poher, Plonéis, Plouguer, Saint-Hernin
	# TODO: décès … Tourc'h
	# TODO: mariages … Cleden-Poher Elliant Kergloff Kernével Laz Motreff Plouguer Poullaouen, Saint-Goazec, Saint-Hernin Scaer Spezet Tourc'h
	# TODO: naissances Bannalec Beuzec-Conq Châteauneuf-du-Faou Cleden-Poher Elliant Kergloff Landeleau Laz Motreff Plouguer Plouguerneau Quéménéven Rosnoen Poullaouen, Saint-Goazec, Saint-Hernin Scaer 
	'3E348_0012' => '1373156',		# Naissances Spezet  3 E 348 12		1793 - an II
	'3E348_0013' => {			# Naissances Spezet  3 E 348 13		an XI-1812
		# TODO: vérifier les URLs qui correspondent au calendrier républicain: mais je n'en ai pas dans mon arbre !
		'an XI' => '1373166',		# Naissances Spezet  3 E 348 13 1	an XI
		'an XII' => '1373167',
		'an XII' => '1373168',
		'an XIV' => '1373169',
		# TODO: fin du bloc que je ne peux tester
		1807 => '1373170',		# Naissances Spezet  3 E 348 13 5	1807
		1808 => '1373171',
		1809 => '1373172',
		1810 => '1373173',
		1811 => '1373174',
		1812 => '1373175',
	},
	'3E348_0014' => {			# Naissances Spezet  3 E 348 14		1813-1822
		1813 => '1373177',		# Naissances Spezet  3 E 348 14 1	1813
		1814 => '1373178',
		1815 => '1373179',
		1816 => '1373180',
		1817 => '1373181',
		1818 => '1373182',
		1819 => '1373183',
		1820 => '1373184',
		1821 => '1373185',
		1822 => '1373186',
	},
	'3E348_0016' => {			# Naissances Spezet  3 E 348 16		1833-1842
		1833 => '1373199',		# Naissances Spezet  3 E 348 16 1	1833
		1834 => '1373200',
		1835 => '1373201',
		1836 => '1373202',
		1837 => '1373203',
		1839 => '1373204',
		1839 => '1373205',
		1840 => '1373206',
		1841 => '1373207',
		1842 => '1373208',
	},
	# Unused in my tree:1843-1852
	'3E348_0018' => {			# Naissances Spezet  3 E 348 18		1853-1862
		1853 => '1373221',		# Naissances Spezet  3 E 348 18 1	1853
		1854 => '1373222',
		1855 => '1373223',
		1856 => '1373224',
		1857 => '1373225',
		1858 => '1373226',
		1859 => '1373227',
		1860 => '1373228',
		1861 => '1373229',
		1862 => '1373230',
	},
	# Unused in my tree:1863-1869
	'3E348_0020' => {			# Naissances Spezet  3 E 348 20		1870-1877
		1870 => '1373240',		# Naissances Spezet  3 E 348 20 1	1870
		1871 => '1373241',
		1872 => '1373242',
		1873 => '1373243',
		1874 => '1373244',
		1875 => '1373245',
		1876 => '1373246',
		1877 => '1373247',
	},
	'3E348_0021' => {			# Naissances Spezet  3 E 348 21		1878-1886
		# Unused in my tree
		1878 => '1373249',		# Naissances Spezet  3 E 348 21 1	1878
		1879 => '1373250',
		1880 => '1373251',
		1881 => '1373252',
		1882 => '1373253',
		1883 => '1373254',
		1884 => '1373255',
		1885 => '1373256',
		1886 => '1373257',
	},
	'3E348_0041' => {			# Naissances Spezet  3 E 348 41		1887-1895
		1887 => '1373259',		# Naissances Spezet  3 E 348 41 1	1887
		1888 => '1373260',
		1889 => '1373261',
		1890 => '1373262',
		1891 => '1373263',
		1892 => '1373264',
		1893 => '1373265',
		1894 => '1373266',
		1895 => '1373267',
	},
	'3E348_0044' => {			# Naissances Spezet  3 E 348 44		1896-1902
		1896 => '1373269',		# Naissances Spezet  3 E 348 44 1	1896
		1897 => '1373270',
		1898 => '1373271',
		1899 => '1373272',
		1900 => '1373273',
		1901 => '1373274',
		1902 => '1373275',
	},
	'3E348_0047' => {			# Naissances Spezet  3 E 348 47		1903-1909
		1903 => '1373277',		# Naissances Spezet  3 E 348 47 1	1903
		1904 => '1373278',
		1905 => '1373279',
		1906 => '1373280',
		1907 => '1373281',
		1908 => '1373282',
		1909 => '1373283',
	},
	'3E348_0048' => {			# Naissances Spezet  3 E 348 48		1910-1916
		1910 => '1373285',		# Naissances Spezet  3 E 348 48 1	1910
		1911 => '1373286',		# Naissances Spezet  3 E 348 48 2	1911
		1912 => '1373287',
		1913 => '1373288',
		1914 => '1373289',		# Naissances Spezet  3 E 348 48 5	1914
		1915 => '1373290',
		1916 => '1373291',
	},
	'3E348_0049' => {			# Naissances Spezet  3 E 348 49		1917-1923
		1917 => '1373293',		# Naissances Spezet  3 E 348 49 1	1917
		1918 => '1373294',
		1919 => '1373295',
		1920 => '1373296',
		1921 => '1373297',
		1922 => '1373298',
		1923 => '1373299',
	},
	'3E348_0050' => {			# Naissances Spezet  3 E 348 50		1924-1929
		1924 => '1373301',		# Naissances Spezet  3 E 348 50 1	1924
		1925 => '1373302',
		1926 => '1373303',
		1927 => '1373304',
		1928 => '1373305',
		1929 => '1373306',
	},
	'3E348_0051' => {			# Naissances Spezet  3 E 348 51		1930-1936
		1930 => '1373308',		# Naissances Spezet  3 E 348 51 1	1930
		1931 => '1373309',
		1932 => '1373310',
		1933 => '1373311',
		1934 => '1373312',
		1935 => '1373313',
		1936 => '1373314',
	},
	'3E348_0057' => {			# Décès      Spezet  3 E 348 57		1924-1936
		1935 => '1373628',
		1936 => '1373629',
	},
	'3E351_0010' => {			# Naissances Tourc'h 3 E 351 10	1870-1883
		1870 => '1374392',		# Naissances Tourc'h 3 E 351/10/1	1870
		1871 => '1374393',
		1872 => '1374394',
		1873 => '1374395',
		1874 => '1374396',
		1875 => '1374397',
		1876 => '1374398',
		1876 => '1374399',
		1878 => '1374400',
		1879 => '1374401',
		1880 => '1374402',		# Naissances Tourc'h 3 E 351/10/11	1880
		1881 =>	'1374403',		# Naissances Tourc'h 3 E 351/10/12	1881
		1882 =>	'1374404',
		1883 =>	'1374405',
	},
	'3E348_0050' => {			# Naissances Spezet 3 E 348 50		1924-1929
		1924 => '1373301',		# Naissances Spezet 3 E 348/50/1	1924
		1925 => '1373302',
		1926 => '1373303',
		1927 => '1373304',
		1928 => '1373305',
		1929 => '1373306',
	},
	'5E_0283_001_01' => '1133694',		# TD Scaer
	'5E_0287_002_08' => '1133798',		# TD Spezet
	'5E_0241_006_03' => '1132985',		# TD Quimperlé
	'6M0833' => {				# Recensement Spézet
	       5360 => '1145863',		# Recensement Spézet 1926
	       5361 => '1145864',		# Recensement Spézet 1931
	       5362 => '1145865',		# Recensement Spézet 1936
       },
);

# Sanitation check:
# TODO: would need to check subkeys too for registers split by year
my %seen_keys;
foreach my $key (keys %convert) {
    push @{$seen_keys{$convert{$key}}}, $key;
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

foreach my $arg (@ARGV) {
    if ($arg =~ /https/) {
	my $new_url = process($arg);
	warn "<<OLD URL: '$arg'\n>>NEW_URL=\n$new_url\n"; # "\n" in order to be able to do fast copying from terminal
    }
}

sub process {
	my ($url) = @_;
	local $_ = $url;
	## before last "/"
	#my ($id) = m!([^/]*)/[^/]*$!;
	# after last "/" (more complete ID + extract image name); accept an optional "/" before "?img="
	my ($id, $image) = m![^/]*/([^/?]*)/?\?(img=.*)\.jpg$!;
	if (!$id) {
		# accept other args before "?img="
		#https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/03E/3E351/3E351_0010?s=FRAD029_3E351_0010_00N_1881_001.jpg&e=FRAD029_3E351_0010_00N_1881_008.jpg&img=FRAD029_3E351_0010_00N_1881_004.jpg&levelDescription=FRAD029_00003E351_pa-88
		#KO: https://recherche.archives.finistere.fr/ark:/72506/652182.1275542/img:FRAD029_3E351_0010_00N_1881_004
		($id,$image) = m![^/]*/([^/?]*)\?.*(img=.*)\.jpg!;
	}
	# for new URL scheme:
	$image =~ s/img=/img:/;
	# Looks like all communal collections have simplified ID (eg: 1237EDEPOT_003 => 1237EDEPOT):
	$id =~ s/_00[0-9]$// if /EDEPOT_00/;
	if (!$id) {
		warn "!!! FAILED TO PARSE '$_'!\n";
		return;
	}
	my $newID = $convert{$id};
	# Special case for registers that has beep split per year (and thus share the same ID):
	if (ref($newID)) {
		my ($year) = /s=FRAD029_[^_]+_[^_]+_[^_]+_(\d\d\d\d)_001.jpg/;
		if ($year) {
			$newID = $newID->{$year};
		} elsif (my ($subID) = /levelDescription=FRAD029_[^_]+_pa-(\d+)/) {
			# Above does't work for recensements:
			# https://recherche.archives.finistere.fr/viewer/series/medias/collections/M/06M/6M03/6M0833?s=FRAD029_6M_0833_04_000001.jpg&e=FRAD029_6M_0833_04_000068.jpg&img=FRAD029_6M_0833_04_000030.jpg&levelDescription=FRAD029_00000006M_pa-5360 (1926)
			# https://recherche.archives.finistere.fr/viewer/series/medias/collections/M/06M/6M05/6M0833?s=FRAD029_6M_0833_06_000001.jpg&e=FRAD029_6M_0833_06_000062.jpg&img=FRAD029_6M_0833_06_000034.jpg&levelDescription=FRAD029_00000006M_pa-5362 (1936)
			$newID = $newID->{$subID};
		} else {
			warn ">> Failed to parse '$_'\n";
		}
	}
	if (!$newID) {
		warn "!!! ID '$id' IS NOT IN THE DB!\n";
		return;
	}
	return "${prefix}$newID/$image";
}


