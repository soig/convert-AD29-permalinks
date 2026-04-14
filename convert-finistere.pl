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

my $old_prefix = 'https://recherche.archives.finistere.fr/viewer/series/medias/collections/'; # unused, for reference only
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
for my $key (keys %convert) {
	push @{$seen_keys{$convert{$key}}}, $key
}
# Ignore empty key (bug on AD29 site):
delete $seen_keys{''};
for my $key (keys %seen_keys) {
	 if(@{$seen_keys{$key}} > 1) {
		 print "\nDuplicate keys for value $key:\n";
		 print "$_\n" for (@{$seen_keys{$key}});
		 exit 1;
	 }
}
# end of check

foreach (@ARGV) {
	## before last "/"
	#my ($id) = m!([^/]*)/[^/]*$!;
	# after last "/" (more complete ID + extract image name); accept an optional "/" before "?img="
	my ($id,$image) = m![^/]*/([^/?]*)/?\?(img=.*)\.jpg$!;
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
		next;
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
		next;
	}
	#warn "==> ID='$id' => $convert{$id}\n";
	#use Data::Dumper; warn Dumper \%convert;
	warn "<<OLD URL: '$_'\n>>NEW_URL=\n${prefix}$newID/$image\n"; # "\n" in order to be able to do fast copying from terminal
}


