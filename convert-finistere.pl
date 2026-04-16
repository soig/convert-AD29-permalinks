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
#
# To add conversion, one need both :
# - old URL, as well as the register name
# - lookup the new register URL in AD29 and identiy the new ARK ID for the register (eg: "137330X" in the above example)

my %convert = (
    # Collection communale:
    '1237EDEPOT' => '645578.1478934',	# Sép Saint-Hernin 1753-1787 (comm)

    # Registre matricule:
    # 1920: https://recherche.archives.finistere.fr/archive/resultats/matricules/n:141?RECH_dateclassefacettes=1920&type=matricules
    '1R01642' => '836100.1076426',             # Bureau Bureau de Brest n° 1 à 500. (1920)
    '1R01643' => '836101.1076427',             # Bureau Bureau de Brest n° 501 à 1000. (1920)
    '1R01644' => '836102.1076428',             # Bureau Bureau de Brest n° 1001 à 1500. (1920)
    '1R01645' => '836103.1076429',             # Bureau Bureau de Brest n° 1501 à 2000. (1920)
    '1R01646' => '836104.1076430',             # Bureau Bureau de Brest n° 2001 à 2500. (1920)
    '1R01647' => '836105.1076431',             # Bureau Bureau de Brest n° 2501 à 3000. (1920)
    '1R01648' => '836106.1076432',             # Bureau Bureau de Brest n° 3001 à 3500. (1920)
    '1R01649' => '836107.1076433',             # Bureau Bureau de Brest n° 3501 à 4000. (1920)
    '1R01650' => '836108.1076434',             # Bureau Bureau de Brest n° 4001 à 4432. (1920)
    '1R01654' => '1076435',                    # Bureau Table alphabétique de Brest. (1920)
    '1R01651' => '836109.1076436',             # Bureau Bureau de Brest-Châteaulin n° 3104 à 3500. (1920)
    '1R01652' => '836110.1076437',             # Bureau Bureau de Brest-Châteaulin n° 3501 à 4000. (1920)
    '1R01653' => '836111.1076438',             # Bureau Bureau de Brest-Châteaulin n° 4001 à 4422, 4433 à 4434, 4439 à 4440. (1920)
    '1R01654' => '1076439',                    # Bureau Table alphabétique de Brest-Châteaulin, suivie d'une liste d'omis et (ou) d'exemptés, de natifs du Finistère recensés ailleurs et d'étrangers recensés dans le Finistère. (1920)
    '1R01655' => '836113.1076440',             # Bureau Bureau de Quimper n° 1 à 500. (1920)
    '1R01656' => '836114.1076441',             # Bureau Bureau de Quimper n° 501 à 1000. (1920)
    '1R01657' => '836115.1076442',             # Bureau Bureau de Quimper n° 1001 à 1500. (1920)
    '1R01658' => '836116.1076443',             # Bureau Bureau de Quimper n° 1501 à 2000. (1920)
    '1R01659' => '836117.1076444',             # Bureau Bureau de Quimper n° 2001 à 2500. (1920)
    '1R01660' => '836118.1076445',             # Bureau Bureau de Quimper n° 2501 à 3104, 3484, 3486, 3515, 3523, 3525, 3543, 3547 à 3548, 3569, 3578, 3581, 3596, 3608, 3610, 3616, 3628 à 3629, 3640, 3649, 3657, 3665, 4423 à 4432, 4435 à 4438, 4441 à 4443. (1920)

    # BMS :
    # TODO: add conversion for all BMS in my tree
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

    # NMD :
    # TODO: Sépultures Carhaix, Cleden-Poher, Plonéis, Plouguer, Saint-Hernin
    # TODO: décès … Tourc'h
    # TODO: mariages … Cleden-Poher Elliant Kergloff Kernével Laz Motreff Plouguer Poullaouen, Saint-Goazec, Saint-Hernin Scaer Spezet Tourc'h
    # TODO: naissances Bannalec Beuzec-Conq Châteauneuf-du-Faou Cleden-Poher Elliant Kergloff Landeleau Laz Motreff Plouguer Plouguerneau Quéménéven Rosnoen Poullaouen, Saint-Goazec, Saint-Hernin Scaer


    # https://recherche.archives.finistere.fr/archive/resultats/etatcivil/n:138?REch_commune_Libel=Cléden-Poher%20(Finistère)|&REch_commune_Md5=5be72e6a952159ab5ea609ce32073fcc|&Rech_typologie[]=Naissance&type=etatcivil
    '3E042_0011' => {		        # Naissances Cleden-Poher  3 E 42 11		1793 - an X
	999999 => 'dummy',              # Just so that perl-mode indents correctly :-(
	'AN02' => '1277179',            # Naissance Cléden-Poher 3 E 42/11/1 (1793 - an II)
	'AN03' => '1277180',            # Naissance Cléden-Poher 3 E 42/11/2 (an III)
	'AN04' => '1277181',            # Naissance Cléden-Poher 3 E 42/11/3 (an IV)
	'AN05' => '1277182',            # Naissance Cléden-Poher 3 E 42/11/4 (an V)
	'AN06' => '1277183',            # Naissance Cléden-Poher 3 E 42/11/5 (an VI)
	'AN07' => '1277184',            # Naissance Cléden-Poher 3 E 42/11/6 (an VII)
	'AN08' => '1277185',            # Naissance Cléden-Poher 3 E 42/11/7 (an VIII)
	'AN09' => '1277186',            # Naissance Cléden-Poher 3 E 42/11/8 (an IX)
	'AN10' => '1277187',            # Naissance Cléden-Poher 3 E 42/11/9 (an X)
    },

    '3E042_0012' => {			# Naissances Cleden-Poher  3 E 42 12		an 11 - 1822
	# FIXME: à part l'an 12, je n'ai pas d'autres actes pour lesquels vérifier la conversion
	999999 => 'dummy',              # Just so that perl-mode indents correctly :-(
	'AN11' => '1277189',            # Naissance Cléden-Poher 3 E 42/12/1 (an XI)
	'AN12' => '1277190',            # Naissance Cléden-Poher 3 E 42/12/2 (an XII)
	'AN13' => '1277191',            # Naissance Cléden-Poher 3 E 42/12/3 (an XIII)
	'AN14' => '1277192',            # Naissance Cléden-Poher 3 E 42/12/4 (an XIV - 1806)
	1807 => '1277193',              # Naissance Cléden-Poher 3 E 42/12/5 (1807)
	1808 => '1277194',              # Naissance Cléden-Poher 3 E 42/12/6 (1808)
	1809 => '1277195',              # Naissance Cléden-Poher 3 E 42/12/7 (1809)
	1810 => '1277196',              # Naissance Cléden-Poher 3 E 42/12/8 (1810)
        1812 => '1277198',              # Naissance Cléden-Poher 3 E 42/12/10 (1812)
        1813 => '1277199',              # Naissance Cléden-Poher 3 E 42/12/11 (1813)
        1814 => '1277200',              # Naissance Cléden-Poher 3 E 42/12/12 (1814)
        1815 => '1277201',              # Naissance Cléden-Poher 3 E 42/12/13 (1815)
        1816 => '1277202',              # Naissance Cléden-Poher 3 E 42/12/14 (1816)
        1817 => '1277203',              # Naissance Cléden-Poher 3 E 42/12/15 (1817)
        1818 => '1277204',              # Naissance Cléden-Poher 3 E 42/12/16 (1818)
        1819 => '1277205',              # Naissance Cléden-Poher 3 E 42/12/17 (1819)
        1820 => '1277206',              # Naissance Cléden-Poher 3 E 42/12/18 (1820)
        1821 => '1277207',              # Naissance Cléden-Poher 3 E 42/12/19 (1821)
        1822 => '1277208',              # Naissance Cléden-Poher 3 E 42/12/20 (1822)
    },

    '3E42_0013' => {                    # Naissance Cléden-Poher 3 E 42 13   1823-1832
        1823 => '1277210',              # Naissance Cléden-Poher 3 E 42/13/1 (1823)
        1824 => '1277211',              # Naissance Cléden-Poher 3 E 42/13/2 (1824)
        1825 => '1277212',              # Naissance Cléden-Poher 3 E 42/13/3 (1825)
        1826 => '1277213',              # Naissance Cléden-Poher 3 E 42/13/4 (1826)
        1827 => '1277214',              # Naissance Cléden-Poher 3 E 42/13/5 (1827)
        1828 => '1277215',              # Naissance Cléden-Poher 3 E 42/13/6 (1828)
        1829 => '1277216',              # Naissance Cléden-Poher 3 E 42/13/7 (1829)
        1830 => '1277217',              # Naissance Cléden-Poher 3 E 42/13/8 (1830)
        1831 => '1277218',              # Naissance Cléden-Poher 3 E 42/13/9 (1831)
        1832 => '1277219',              # Naissance Cléden-Poher 3 E 42/13/10 (1832)
    },

    '3E42_0014' => {                    # Naissance Cléden-Poher 3 E 42 14   1833-1842
        1833 => '1277221',              # Naissance Cléden-Poher 3 E 42/14/1 (1833)
        1834 => '1277222',              # Naissance Cléden-Poher 3 E 42/14/2 (1834)
        1835 => '1277223',              # Naissance Cléden-Poher 3 E 42/14/3 (1835)
        1836 => '1277224',              # Naissance Cléden-Poher 3 E 42/14/4 (1836)
        1837 => '1277225',              # Naissance Cléden-Poher 3 E 42/14/5 (1837)
        1838 => '1277226',              # Naissance Cléden-Poher 3 E 42/14/6 (1838)
        1839 => '1277227',              # Naissance Cléden-Poher 3 E 42/14/7 (1839)
        1840 => '1277228',              # Naissance Cléden-Poher 3 E 42/14/8 (1840)
        1841 => '1277229',              # Naissance Cléden-Poher 3 E 42/14/9 (1841)
        1842 => '1277230',              # Naissance Cléden-Poher 3 E 42/14/10 (1842)
    },

    '3E42_0015' => {                    # Naissance Cléden-Poher 3 E 42 15   1843-1852
        1843 => '1277232',              # Naissance Cléden-Poher 3 E 42/15/1 (1843)
        1844 => '1277233',              # Naissance Cléden-Poher 3 E 42/15/2 (1844)
        1845 => '1277234',              # Naissance Cléden-Poher 3 E 42/15/3 (1845)
        1846 => '1277235',              # Naissance Cléden-Poher 3 E 42/15/4 (1846)
        1847 => '1277236',              # Naissance Cléden-Poher 3 E 42/15/5 (1847)
        1848 => '1277237',              # Naissance Cléden-Poher 3 E 42/15/6 (1848)
        1849 => '1277238',              # Naissance Cléden-Poher 3 E 42/15/7 (1849)
        1850 => '1277239',              # Naissance Cléden-Poher 3 E 42/15/8 (1850)
        1851 => '1277240',              # Naissance Cléden-Poher 3 E 42/15/9 (1851)
        1852 => '1277241',              # Naissance Cléden-Poher 3 E 42/15/10 (1852)
        1853 => '1277243',              # Naissance Cléden-Poher 3 E 42/16/1 (1853)
    },

    '3E42_0016' => {                    # Naissance Cléden-Poher 3 E 42 16   1853-1862
        1853 => '1277243',              # Naissance Cléden-Poher 3 E 42/16/1 (1853)
        1854 => '1277244',              # Naissance Cléden-Poher 3 E 42/16/2 (1854)
        1855 => '1277245',              # Naissance Cléden-Poher 3 E 42/16/3 (1855)
        1856 => '1277246',              # Naissance Cléden-Poher 3 E 42/16/4 (1856)
        1857 => '1277247',              # Naissance Cléden-Poher 3 E 42/16/5 (1857)
        1858 => '1277248',              # Naissance Cléden-Poher 3 E 42/16/6 (1858)
        1859 => '1277249',              # Naissance Cléden-Poher 3 E 42/16/7 (1859)
        1860 => '1277250',              # Naissance Cléden-Poher 3 E 42/16/8 (1860)
        1861 => '1277251',              # Naissance Cléden-Poher 3 E 42/16/9 (1861)
        1862 => '1277252',              # Naissance Cléden-Poher 3 E 42/16/10 (1862)
    },

    '3E42_0017' => {                    # Naissance Cléden-Poher 3 E 42 17   1863-1869
        1863 => '1277254',              # Naissance Cléden-Poher 3 E 42/17/1 (1863)
        1864 => '1277255',              # Naissance Cléden-Poher 3 E 42/17/2 (1864)
        1865 => '1277256',              # Naissance Cléden-Poher 3 E 42/17/3 (1865)
        1866 => '1277257',              # Naissance Cléden-Poher 3 E 42/17/4 (1866)
        1867 => '1277258',              # Naissance Cléden-Poher 3 E 42/17/5 (1867)
        1868 => '1277259',              # Naissance Cléden-Poher 3 E 42/17/6 (1868)
        1869 => '1277260',              # Naissance Cléden-Poher 3 E 42/17/7 (1869)
    },

    '3E42_0018' => {                    # Naissance Cléden-Poher 3 E 42 18   1870-1880
        1870 => '1277262',              # Naissance Cléden-Poher 3 E 42/18/1 (1870)
        1871 => '1277263',              # Naissance Cléden-Poher 3 E 42/18/2 (1871)
        1872 => '1277264',              # Naissance Cléden-Poher 3 E 42/18/3 (1872)
        1873 => '1277265',              # Naissance Cléden-Poher 3 E 42/18/4 (1873)
        1874 => '1277266',              # Naissance Cléden-Poher 3 E 42/18/5 (1874)
        1875 => '1277267',              # Naissance Cléden-Poher 3 E 42/18/6 (1875)
        1876 => '1277268',              # Naissance Cléden-Poher 3 E 42/18/7 (1876)
        1877 => '1277269',              # Naissance Cléden-Poher 3 E 42/18/8 (1877)
        1878 => '1277270',              # Naissance Cléden-Poher 3 E 42/18/9 (1878)
        1879 => '1277271',              # Naissance Cléden-Poher 3 E 42/18/10 (1879)
        1880 => '1277272',              # Naissance Cléden-Poher 3 E 42/18/11 (1880)
    },

    '3E42_0019' => {                    # Naissance Cléden-Poher 3 E 42 19   1881-1891
        1881 => '1277274',              # Naissance Cléden-Poher 3 E 42/19/1 (1881)
        1882 => '1277275',              # Naissance Cléden-Poher 3 E 42/19/2 (1882)
        1883 => '1277276',              # Naissance Cléden-Poher 3 E 42/19/3 (1883)
        1884 => '1277277',              # Naissance Cléden-Poher 3 E 42/19/4 (1884)
        1885 => '1277278',              # Naissance Cléden-Poher 3 E 42/19/5 (1885)
        1886 => '1277279',              # Naissance Cléden-Poher 3 E 42/19/6 (1886)
        1887 => '1277280',              # Naissance Cléden-Poher 3 E 42/19/7 (1887)
        1888 => '1277281',              # Naissance Cléden-Poher 3 E 42/19/8 (1888)
        1889 => '1277282',              # Naissance Cléden-Poher 3 E 42/19/9 (1889)
        1890 => '1277283',              # Naissance Cléden-Poher 3 E 42/19/10 (1890)
        1891 => '1277284',              # Naissance Cléden-Poher 3 E 42/19/11 (1891)
    },

    # https://recherche.archives.finistere.fr/archive/resultats/etatcivil/tableau/n:138/limit:20?REch_commune_Libel=Cléden-Poher+(Finistère)|&REch_commune_Md5=5be72e6a952159ab5ea609ce32073fcc|&Rech_typologie[0]=Décès&RECH_unitdate_debut=1793&RECH_unitdate_fin=1810&type=etatcivil&pagination_25
    '3E042_0028' => {			# Décès Cléden-Poher  3 E 42 28             1793 - an X
	999999 => 'dummy',              # Just so that perl-mode indents correctly :-(
	'AN02' => '1277491',            # Décès Cléden-Poher 3 E 42/28/1 (1793 - an II)
        'AN03' => '1277492',            # Décès Cléden-Poher 3 E 42/28/2 (an III)
        'AN04' => '1277493',            # Décès Cléden-Poher 3 E 42/28/3 (an IV)
        'AN05' => '1277494',            # Décès Cléden-Poher 3 E 42/28/4 (an V)
        'AN06' => '1277495',            # Décès Cléden-Poher 3 E 42/28/5 (an VI)
        'AN07' => '1277496',            # Décès Cléden-Poher 3 E 42/28/6 (an VII)
        'AN08' => '1277497',            # Décès Cléden-Poher 3 E 42/28/7 (an VIII)
        'AN09' => '1277498',            # Décès Cléden-Poher 3 E 42/28/8 (an IX)
        'AN10' => '1277499',            # Décès Cléden-Poher 3 E 42/28/9 (an X)
    },

    '3E042_0029' => {	    # Décès Cléden-Poher  3 E 42 29             an XI - 1822
	999999 => 'dummy',              # Just so that perl-mode indents correctly :-(
        'AN11' => '1277501',            # Décès Cléden-Poher 3 E 42/29/1 (an XI)
	'AN12' => '1277502',            # Décès Cléden-Poher 3 E 42/29/2 (an XII)
        'AN13' => '1277503',            # Décès Cléden-Poher 3 E 42/29/3 (an XIII)
        'AN14' => '1277504',            # Décès Cléden-Poher 3 E 42/29/4 (an XIV - 1806)
        1807 => '1277505',              # Décès Cléden-Poher 3 E 42/29/5 (1807)
        1808 => '1277506',              # Décès Cléden-Poher 3 E 42/29/6 (1808)
        1809 => '1277507',              # Décès Cléden-Poher 3 E 42/29/7 (1809)
        1810 => '1277508',              # Décès Cléden-Poher 3 E 42/29/8 (1810)
        1811 => '1277509',              # Décès Cléden-Poher 3 E 42/29/9 (1811)
        1812 => '1277510',              # Décès Cléden-Poher 3 E 42/29/10 (1812)
        1813 => '1277511',              # Décès Cléden-Poher 3 E 42/29/11 (1813)
        1814 => '1277512',              # Décès Cléden-Poher 3 E 42/29/12 (1814)
        1815 => '1277513',              # Décès Cléden-Poher 3 E 42/29/13 (1815)
        1816 => '1277514',              # Décès Cléden-Poher 3 E 42/29/14 (1816)
        1817 => '1277515',              # Décès Cléden-Poher 3 E 42/29/15 (1817)
        1818 => '1277516',              # Décès Cléden-Poher 3 E 42/29/16 (1818)
        1819 => '1277517',              # Décès Cléden-Poher 3 E 42/29/17 (1819)
        1820 => '1277518',              # Décès Cléden-Poher 3 E 42/29/18 (1820)
        1820 => '1277518',              # Décès Cléden-Poher 3 E 42/29/18 (1820)
        1821 => '1277519',              # Décès Cléden-Poher 3 E 42/29/19 (1821)
        1822 => '1277520',              # Décès Cléden-Poher 3 E 42/29/20 (1822)
    },

    '3E042_0030' => {			# Décès Cléden-Poher 3 E 42 30   1823-1832
        1823 => '1277522',              # Décès Cléden-Poher 3 E 42/30/1 (1823)
        1824 => '1277523',              # Décès Cléden-Poher 3 E 42/30/2 (1824)
        1825 => '1277524',              # Décès Cléden-Poher 3 E 42/30/3 (1825)
        1826 => '1277525',              # Décès Cléden-Poher 3 E 42/30/4 (1826)
        1827 => '1277526',              # Décès Cléden-Poher 3 E 42/30/5 (1827)
        1828 => '1277527',              # Décès Cléden-Poher 3 E 42/30/6 (1828)
        1829 => '1277528',              # Décès Cléden-Poher 3 E 42/30/7 (1829)
        1830 => '1277529',              # Décès Cléden-Poher 3 E 42/30/8 (1830)
        1831 => '1277530',              # Décès Cléden-Poher 3 E 42/30/9 (1831)
        1832 => '1277531',              # Décès Cléden-Poher 3 E 42/30/10 (1832)
    },

    # https://recherche.archives.finistere.fr/archive/resultats/etatcivil/tableau/n:138/limit:20?REch_commune_Libel=Cléden-Poher+(Finistère)|&REch_commune_Md5=5be72e6a952159ab5ea609ce32073fcc|&Rech_typologie[0]=Décès&RECH_unitdate_debut=1833&RECH_unitdate_fin=1853&type=etatcivil&pagination_25
    '3E042_0031' => {			# Décès Cléden-Poher 3 E 42 31   1833-1842
        1833 => '1277533',              # Décès Cléden-Poher 3 E 42/31/1 (1833)
        1834 => '1277534',              # Décès Cléden-Poher 3 E 42/31/2 (1834)
        1835 => '1277535',              # Décès Cléden-Poher 3 E 42/31/3 (1835)
        1836 => '1277536',              # Décès Cléden-Poher 3 E 42/31/4 (1836)
        1837 => '1277537',              # Décès Cléden-Poher 3 E 42/31/5 (1837)
        1838 => '1277538',              # Décès Cléden-Poher 3 E 42/31/6 (1838)
        1839 => '1277539',              # Décès Cléden-Poher 3 E 42/31/7 (1839)
        1840 => '1277540',              # Décès Cléden-Poher 3 E 42/31/8 (1840)
        1841 => '1277541',              # Décès Cléden-Poher 3 E 42/31/9 (1841)
        1842 => '1277542',              # Décès Cléden-Poher 3 E 42/31/10 (1842)
    },

    '3E042_0032' => {			# Décès Cléden-Poher 3 E 42 32   1843-1852
        1843 => '1277544',              # Décès Cléden-Poher 3 E 42/32/1 (1843)
        1844 => '1277545',              # Décès Cléden-Poher 3 E 42/32/2 (1844)
        1845 => '1277546',              # Décès Cléden-Poher 3 E 42/32/3 (1845)
        1846 => '1277547',              # Décès Cléden-Poher 3 E 42/32/4 (1846)
        1847 => '1277548',              # Décès Cléden-Poher 3 E 42/32/5 (1847)
        1848 => '1277549',              # Décès Cléden-Poher 3 E 42/32/6 (1848)
        1849 => '1277550',              # Décès Cléden-Poher 3 E 42/32/7 (1849)
        1850 => '1277551',              # Décès Cléden-Poher 3 E 42/32/8 (1850)
        1851 => '1277552',              # Décès Cléden-Poher 3 E 42/32/9 (1851)
        1852 => '1277553',              # Décès Cléden-Poher 3 E 42/32/10 (1852)
    },

    '3E042_0033' => {			# Décès Cléden-Poher 3 E 42 33   1853-1862
        1853 => '1277555',              # Décès Cléden-Poher 3 E 42/33/1 (1853)
        1854 => '1277556',              # Décès Cléden-Poher 3 E 42/33/2 (1854)
        1855 => '1277557',              # Décès Cléden-Poher 3 E 42/33/3 (1855)
        1856 => '1277558',              # Décès Cléden-Poher 3 E 42/33/4 (1856)
        1857 => '1277559',              # Décès Cléden-Poher 3 E 42/33/5 (1857)
        1858 => '1277560',              # Décès Cléden-Poher 3 E 42/33/6 (1858)
        1859 => '1277561',              # Décès Cléden-Poher 3 E 42/33/7 (1859)
        1860 => '1277562',              # Décès Cléden-Poher 3 E 42/33/8 (1860)
        1861 => '1277563',              # Décès Cléden-Poher 3 E 42/33/9 (1861)
        1862 => '1277564',              # Décès Cléden-Poher 3 E 42/33/10 (1862)
    },

    '3E042_0034' => {			# Décès Cléden-Poher 3 E 42 34   1863-1872
        1863 => '1277566',              # Décès Cléden-Poher 3 E 42/34/1 (1863)
        1864 => '1277567',              # Décès Cléden-Poher 3 E 42/34/2 (1864)
        1865 => '1277568',              # Décès Cléden-Poher 3 E 42/34/3 (1865)
        1866 => '1277569',              # Décès Cléden-Poher 3 E 42/34/4 (1866)
        1867 => '1277570',              # Décès Cléden-Poher 3 E 42/34/5 (1867)
        1868 => '1277571',              # Décès Cléden-Poher 3 E 42/34/6 (1868)
        1869 => '1277572',              # Décès Cléden-Poher 3 E 42/34/7 (1869)
    },

    '3E042_0035' => {			# Décès Cléden-Poher 3 E 42 35   1870-1882
        1870 => '1277574',              # Décès Cléden-Poher 3 E 42/35/1 (1870)
        1871 => '1277575',              # Décès Cléden-Poher 3 E 42/35/2 (1871)
        1872 => '1277576',              # Décès Cléden-Poher 3 E 42/35/3 (1872)
        1873 => '1277577',              # Décès Cléden-Poher 3 E 42/35/4 (1873)
        1874 => '1277578',              # Décès Cléden-Poher 3 E 42/35/5 (1874)
        1875 => '1277579',              # Décès Cléden-Poher 3 E 42/35/6 (1875)
        1876 => '1277580',              # Décès Cléden-Poher 3 E 42/35/7 (1876)
        1877 => '1277581',              # Décès Cléden-Poher 3 E 42/35/8 (1877)
        1878 => '1277582',              # Décès Cléden-Poher 3 E 42/35/9 (1878)
        1879 => '1277583',              # Décès Cléden-Poher 3 E 42/35/10 (1879)
        1880 => '1277584',              # Décès Cléden-Poher 3 E 42/35/11 (1880)
        1881 => '1277585',              # Décès Cléden-Poher 3 E 42/35/12 (1881)
        1882 => '1277586',              # Décès Cléden-Poher 3 E 42/35/13 (1882)
    },

    '3E042_0036' => {			# Décès Cléden-Poher 3 E 42 36   1883-1895
        1883 => '1277588',              # Décès Cléden-Poher 3 E 42/36/1 (1883)
        1884 => '1277589',              # Décès Cléden-Poher 3 E 42/36/2 (1884)
        1885 => '1277590',              # Décès Cléden-Poher 3 E 42/36/3 (1885)
        1886 => '1277591',              # Décès Cléden-Poher 3 E 42/36/4 (1886)
        1887 => '1277592',              # Décès Cléden-Poher 3 E 42/36/5 (1887)
        1888 => '1277593',              # Décès Cléden-Poher 3 E 42/36/6 (1888)
        1889 => '1277594',              # Décès Cléden-Poher 3 E 42/36/7 (1889)
        1890 => '1277595',              # Décès Cléden-Poher 3 E 42/36/8 (1890)
        1891 => '1277596',              # Décès Cléden-Poher 3 E 42/36/9 (1891)
        1892 => '1277597',              # Décès Cléden-Poher 3 E 42/36/10 (1892)
        1893 => '1277598',              # Décès Cléden-Poher 3 E 42/36/11 (1893)
        1894 => '1277599',              # Décès Cléden-Poher 3 E 42/36/12 (1894)
        1895 => '1277600',              # Décès Cléden-Poher 3 E 42/36/13 (1895)
    },

    '3E42_0037' => {                    # Naissance Cléden-Poher 3 E 42 37   1892-1904
        1892 => '1277286',              # Naissance Cléden-Poher 3 E 42/37/1 (1892)
        1893 => '1277287',              # Naissance Cléden-Poher 3 E 42/37/2 (1893)
        1894 => '1277288',              # Naissance Cléden-Poher 3 E 42/37/3 (1894)
        1895 => '1277289',              # Naissance Cléden-Poher 3 E 42/37/4 (1895)
        1896 => '1277290',              # Naissance Cléden-Poher 3 E 42/37/5 (1896)
        1897 => '1277291',              # Naissance Cléden-Poher 3 E 42/37/6 (1897)
        1898 => '1277292',              # Naissance Cléden-Poher 3 E 42/37/7 (1898)
        1899 => '1277293',              # Naissance Cléden-Poher 3 E 42/37/8 (1899)
        1900 => '1277294',              # Naissance Cléden-Poher 3 E 42/37/9 (1900)
        1901 => '1277295',              # Naissance Cléden-Poher 3 E 42/37/10 (1901)
        1902 => '1277296',              # Naissance Cléden-Poher 3 E 42/37/11 (1902)
        1903 => '1277297',              # Naissance Cléden-Poher 3 E 42/37/12 (1903)
        1904 => '1277299',              # Naissance Cléden-Poher 3 E 42/40/1 (1904)
    },

    '3E42_0039' => {                    # Décès Cléden-Poher 3 E 42 39   1896-1909
        1896 => '1277602',              # Décès Cléden-Poher 3 E 42/39/1 (1896)
        1897 => '1277603',              # Décès Cléden-Poher 3 E 42/39/2 (1897)
        1898 => '1277604',              # Décès Cléden-Poher 3 E 42/39/3 (1898)
        1899 => '1277605',              # Décès Cléden-Poher 3 E 42/39/4 (1899)
        1900 => '1277606',              # Décès Cléden-Poher 3 E 42/39/5 (1900)
        1901 => '1277607',              # Décès Cléden-Poher 3 E 42/39/6 (1901)
        1902 => '1277608',              # Décès Cléden-Poher 3 E 42/39/7 (1902)
        1903 => '1277609',              # Décès Cléden-Poher 3 E 42/39/8 (1903)
        1904 => '1277610',              # Décès Cléden-Poher 3 E 42/39/9 (1904)
        1905 => '1277611',              # Décès Cléden-Poher 3 E 42/39/10 (1905)
        1906 => '1277612',              # Décès Cléden-Poher 3 E 42/39/11 (1906)
        1907 => '1277613',              # Décès Cléden-Poher 3 E 42/39/12 (1907)
        1908 => '1277614',              # Décès Cléden-Poher 3 E 42/39/13 (1908)
        1909 => '1277615',              # Décès Cléden-Poher 3 E 42/39/14 (1909)
    },

    '3E42_0040' => {                    # Naissance Cléden-Poher 3 E 42 40   1904-1913
        1904 => '1277299',              # Naissance Cléden-Poher 3 E 42/40/1 (1904)
        1905 => '1277300',              # Naissance Cléden-Poher 3 E 42/40/2 (1905)
        1906 => '1277301',              # Naissance Cléden-Poher 3 E 42/40/3 (1906)
        1907 => '1277302',              # Naissance Cléden-Poher 3 E 42/40/4 (1907)
        1908 => '1277303',              # Naissance Cléden-Poher 3 E 42/40/5 (1908)
        1909 => '1277304',              # Naissance Cléden-Poher 3 E 42/40/6 (1909)
        1910 => '1277305',              # Naissance Cléden-Poher 3 E 42/40/7 (1910)
        1911 => '1277306',              # Naissance Cléden-Poher 3 E 42/40/8 (1911)
        1912 => '1277307',              # Naissance Cléden-Poher 3 E 42/40/9 (1912)
        1913 => '1277308',              # Naissance Cléden-Poher 3 E 42/40/10 (1913)
    },

    '3E42_0041' => {                    # Naissance Cléden-Poher 3 E 42 41   1914-1923
        1914 => '1277310',              # Naissance Cléden-Poher 3 E 42/41/1 (1914)
        1915 => '1277311',              # Naissance Cléden-Poher 3 E 42/41/2 (1915)
        1916 => '1277312',              # Naissance Cléden-Poher 3 E 42/41/3 (1916)
        1917 => '1277313',              # Naissance Cléden-Poher 3 E 42/41/4 (1917)
        1918 => '1277314',              # Naissance Cléden-Poher 3 E 42/41/5 (1918)
        1919 => '1277315',              # Naissance Cléden-Poher 3 E 42/41/6 (1919)
        1920 => '1277316',              # Naissance Cléden-Poher 3 E 42/41/7 (1920)
        1921 => '1277317',              # Naissance Cléden-Poher 3 E 42/41/8 (1921)
        1922 => '1277318',              # Naissance Cléden-Poher 3 E 42/41/9 (1922)
        1923 => '1277319',              # Naissance Cléden-Poher 3 E 42/41/10 (1923)
    },

    '3E42_0042' => {                    # Naissance Cléden-Poher 3 E 42 42   1924-1936
	# Only 1924-1925 were online
        1924 => '1277321',              # Naissance Cléden-Poher 3 E 42/42/1 (1924)
        1925 => '1277322',              # Naissance Cléden-Poher 3 E 42/42/2 (1925)
    },

    '3E42_0045' => {                    # Décès Cléden-Poher 3 E 42 45   1910-1921
        1910 => '1277617',              # Décès Cléden-Poher 3 E 42/45/1 (1910)
        1911 => '1277618',              # Décès Cléden-Poher 3 E 42/45/2 (1911)
        1912 => '1277619',              # Décès Cléden-Poher 3 E 42/45/3 (1912)
        1913 => '1277620',              # Décès Cléden-Poher 3 E 42/45/4 (1913)
        1914 => '1277621',              # Décès Cléden-Poher 3 E 42/45/5 (1914)
        1915 => '1277622',              # Décès Cléden-Poher 3 E 42/45/6 (1915)
        1916 => '1277623',              # Décès Cléden-Poher 3 E 42/45/7 (1916)
        1917 => '1277624',              # Décès Cléden-Poher 3 E 42/45/8 (1917)
        1918 => '1277625',              # Décès Cléden-Poher 3 E 42/45/9 (1918)
        1919 => '1277626',              # Décès Cléden-Poher 3 E 42/45/10 (1919)
        1920 => '1277627',              # Décès Cléden-Poher 3 E 42/45/11 (1920)
        1921 => '1277628',              # Décès Cléden-Poher 3 E 42/45/12 (1921)
    },

    # I'm not sure that the old site offered events betweeen 1925 & 1936?
    '3E42_0046' => {                    # Décès Cléden-Poher 3 E 42 46   1922-1936
        1922 => '1277630',              # Décès Cléden-Poher 3 E 42/46/1 (1922)
        1923 => '1277631',              # Décès Cléden-Poher 3 E 42/46/2 (1923)
        1924 => '1277632',              # Décès Cléden-Poher 3 E 42/46/3 (1924)
        1925 => '1277633',              # Décès Cléden-Poher 3 E 42/46/4 (1925)
        1926 => '1277634',              # Décès Cléden-Poher 3 E 42/46/5 (1926)
        1927 => '1277635',              # Décès Cléden-Poher 3 E 42/46/6 (1927)
        1928 => '1277636',              # Décès Cléden-Poher 3 E 42/46/7 (1928)
        1929 => '1277637',              # Décès Cléden-Poher 3 E 42/46/8 (1929)
        1930 => '1277638',              # Décès Cléden-Poher 3 E 42/46/9 (1930)
        1931 => '1277639',              # Décès Cléden-Poher 3 E 42/46/10 (1931)
        1932 => '1277640',              # Décès Cléden-Poher 3 E 42/46/11 (1932)
        1933 => '1277641',              # Décès Cléden-Poher 3 E 42/46/12 (1933)
        1934 => '1277642',              # Décès Cléden-Poher 3 E 42/46/13 (1934)
        1935 => '1277643',              # Décès Cléden-Poher 3 E 42/46/14 (1935)
        1936 => '1277644',              # Décès Cléden-Poher 3 E 42/46/15 (1936)
    },

    # https://recherche.archives.finistere.fr/archive/resultats/etatcivil/n:138?REch_commune_Libel=Kergloff+%28Finist%C3%A8re%29%7C&REch_commune_Md5=b514c4417f09b16bf87e6d3adcf13473%7C&Rech_typologie%5B0%5D=Naissance&RECH_unitdate_debut=1793&RECH_unitdate_fin=1810&type=etatcivil

    '3E106_0004' => {                   # Naissance Kergloff 3 E 106 4   1793-1810
	999999 => 'dummy',              # Just so that perl-mode indents correctly :-(
        'AN02' => '1301840',            # Naissance Kergloff 3 E 106/4/1 (1793 - an II)
        'AN03' => '1301841',            # Naissance Kergloff 3 E 106/4/2 (an III)
        'AN04' => '1301842',            # Naissance Kergloff 3 E 106/4/3 (an IV)
        'AN05' => '1301843',            # Naissance Kergloff 3 E 106/4/4 (an V)
        'AN06' => '1301844',            # Naissance Kergloff 3 E 106/4/5 (an VI)
        'AN07' => '1301845',            # Naissance Kergloff 3 E 106/4/6 (an VII)
        'AN08' => '1301846',            # Naissance Kergloff 3 E 106/4/7 (an VIII)
        'AN09' => '1301847',            # Naissance Kergloff 3 E 106/4/8 (an IX)
        'AN10' => '1301848',            # Naissance Kergloff 3 E 106/4/9 (an X)
        'AN11' => '1301849',            # Naissance Kergloff 3 E 106/4/10 (an XI)
        'AN12' => '1301850',            # Naissance Kergloff 3 E 106/4/11 (an XII)
        'AN13' => '1301851',            # Naissance Kergloff 3 E 106/4/12 (an XIII)
        'AN14' => '1301852',            # Naissance Kergloff 3 E 106/4/13 (an XIV - 1806)
        1807 => '1301853',              # Naissance Kergloff 3 E 106/4/14 (1807)
        1808 => '1301854',              # Naissance Kergloff 3 E 106/4/15 (1808)
        1809 => '1301855',              # Naissance Kergloff 3 E 106/4/16 (1809)
        1810 => '1301856',              # Naissance Kergloff 3 E 106/4/17 (1810)
        1811 => '1301857',              # Naissance Kergloff 3 E 106/4/18 (1811)
    },

    '3E106_0005' => {                   # Naissance Kergloff 3 E 106 5   1812-1832
        1812 => '1301859',              # Naissance Kergloff 3 E 106/5/1 (1812)
        1813 => '1301860',              # Naissance Kergloff 3 E 106/5/2 (1813)
        1814 => '1301861',              # Naissance Kergloff 3 E 106/5/3 (1814)
        1815 => '1301862',              # Naissance Kergloff 3 E 106/5/4 (1815)
        1816 => '1301863',              # Naissance Kergloff 3 E 106/5/5 (1816)
        1817 => '1301864',              # Naissance Kergloff 3 E 106/5/6 (1817)
        1818 => '1301865',              # Naissance Kergloff 3 E 106/5/7 (1818)
        1819 => '1301866',              # Naissance Kergloff 3 E 106/5/8 (1819)
        1820 => '1301867',              # Naissance Kergloff 3 E 106/5/9 (1820)
        1821 => '1301868',              # Naissance Kergloff 3 E 106/5/10 (1821)
        1822 => '1301869',              # Naissance Kergloff 3 E 106/5/11 (1822)
        1823 => '1301870',              # Naissance Kergloff 3 E 106/5/12 (1823)
        1824 => '1301871',              # Naissance Kergloff 3 E 106/5/13 (1824)
        1825 => '1301872',              # Naissance Kergloff 3 E 106/5/14 (1825)
        1825 => '1301872',              # Naissance Kergloff 3 E 106/5/14 (1825)
        1826 => '1301873',              # Naissance Kergloff 3 E 106/5/15 (1826)
        1827 => '1301874',              # Naissance Kergloff 3 E 106/5/16 (1827)
        1828 => '1301875',              # Naissance Kergloff 3 E 106/5/17 (1828)
        1829 => '1301876',              # Naissance Kergloff 3 E 106/5/18 (1829)
        1830 => '1301877',              # Naissance Kergloff 3 E 106/5/19 (1830)
        1831 => '1301878',              # Naissance Kergloff 3 E 106/5/20 (1831)
        1832 => '1301879',              # Naissance Kergloff 3 E 106/5/21 (1832)
    },

    '3E106_0006' => {                   # Naissance Kergloff 3 E 106 6   1833-1842
        1833 => '1301881',              # Naissance Kergloff 3 E 106/6/1 (1833)
        1834 => '1301882',              # Naissance Kergloff 3 E 106/6/2 (1834)
        1835 => '1301883',              # Naissance Kergloff 3 E 106/6/3 (1835)
        1836 => '1301884',              # Naissance Kergloff 3 E 106/6/4 (1836)
        1837 => '1301885',              # Naissance Kergloff 3 E 106/6/5 (1837)
        1838 => '1301886',              # Naissance Kergloff 3 E 106/6/6 (1838)
        1839 => '1301887',              # Naissance Kergloff 3 E 106/6/7 (1839)
        1840 => '1301888',              # Naissance Kergloff 3 E 106/6/8 (1840)
        1841 => '1301889',              # Naissance Kergloff 3 E 106/6/9 (1841)
        1842 => '1301890',              # Naissance Kergloff 3 E 106/6/10 (1842)
    },

    '3E106_0007' => {                   # Naissance Kergloff 3 E 106 7   1843-1852
        1843 => '1301892',              # Naissance Kergloff 3 E 106/7/1 (1843)
        1844 => '1301893',              # Naissance Kergloff 3 E 106/7/2 (1844)
        1845 => '1301894',              # Naissance Kergloff 3 E 106/7/3 (1845)
        1846 => '1301895',              # Naissance Kergloff 3 E 106/7/4 (1846)
        1847 => '1301896',              # Naissance Kergloff 3 E 106/7/5 (1847)
        1848 => '1301897',              # Naissance Kergloff 3 E 106/7/6 (1848)
        1849 => '1301898',              # Naissance Kergloff 3 E 106/7/7 (1849)
        1850 => '1301899',              # Naissance Kergloff 3 E 106/7/8 (1850)
        1851 => '1301900',              # Naissance Kergloff 3 E 106/7/9 (1851)
        1852 => '1301901',              # Naissance Kergloff 3 E 106/7/10 (1852)
        1853 => '1301903',              # Naissance Kergloff 3 E 106/8/1 (1853)
    },

    '3E106_0008' => {                   # Naissance Kergloff 3 E 106 8   1853-1862
        1853 => '1301903',              # Naissance Kergloff 3 E 106/8/1 (1853)
        1854 => '1301904',              # Naissance Kergloff 3 E 106/8/2 (1854)
        1855 => '1301905',              # Naissance Kergloff 3 E 106/8/3 (1855)
        1856 => '1301906',              # Naissance Kergloff 3 E 106/8/4 (1856)
        1857 => '1301907',              # Naissance Kergloff 3 E 106/8/5 (1857)
        1858 => '1301908',              # Naissance Kergloff 3 E 106/8/6 (1858)
        1859 => '1301909',              # Naissance Kergloff 3 E 106/8/7 (1859)
        1860 => '1301910',              # Naissance Kergloff 3 E 106/8/8 (1860)
        1861 => '1301911',              # Naissance Kergloff 3 E 106/8/9 (1861)
        1862 => '1301912',              # Naissance Kergloff 3 E 106/8/10 (1862)
    },

    '3E106_0009' => {                   # Naissance Kergloff 3 E 106 9   1863-1869"
        1863 => '1301914',              # Naissance Kergloff 3 E 106/9/1 (1863)
        1864 => '1301915',              # Naissance Kergloff 3 E 106/9/2 (1864)
        1865 => '1301916',              # Naissance Kergloff 3 E 106/9/3 (1865)
        1866 => '1301917',              # Naissance Kergloff 3 E 106/9/4 (1866)
        1867 => '1301918',              # Naissance Kergloff 3 E 106/9/5 (1867)
        1868 => '1301919',              # Naissance Kergloff 3 E 106/9/6 (1868)
        1869 => '1301920',              # Naissance Kergloff 3 E 106/9/7 (1869)
    },

    '3E106_0010' => {			# Naissance Kergloff 3 E 106 10   1870-1881
	1870 => '1301922',              # Naissance Kergloff 3 E 106/10/1 (1870)
	1871 => '1301923',              # Naissance Kergloff 3 E 106/10/2 (1871)
	1872 => '1301924',              # Naissance Kergloff 3 E 106/10/3 (1872)
	1873 => '1301925',              # Naissance Kergloff 3 E 106/10/4 (1873)
	1874 => '1301926',              # Naissance Kergloff 3 E 106/10/5 (1874)
	1875 => '1301927',              # Naissance Kergloff 3 E 106/10/6 (1875)
	1876 => '1301928',              # Naissance Kergloff 3 E 106/10/7 (1876)
	1877 => '1301929',              # Naissance Kergloff 3 E 106/10/8 (1877)
	1878 => '1301930',              # Naissance Kergloff 3 E 106/10/9 (1878)
	1879 => '1301931',              # Naissance Kergloff 3 E 106/10/10 (1879)
	1880 => '1301932',              # Naissance Kergloff 3 E 106/10/11 (1880)
	1881 => '1301933',              # Naissance Kergloff 3 E 106/10/12 (1881)
    },

    '3E106_0018' => {			# Décès Kergloff 3 E 106 18   1793-1813
	'AN02' => '1302147',            # Décès Kergloff 3 E 106/18/1 (1793 - an II)
	'AN03' => '1302148',            # Décès Kergloff 3 E 106/18/2 (an III)
	'AN04' => '1302149',            # Décès Kergloff 3 E 106/18/3 (an IV)
	'AN09' => '1302154',            # Décès Kergloff 3 E 106/18/8 (an IX)
	'AN05' => '1302150',            # Décès Kergloff 3 E 106/18/4 (an V)
	'AN06' => '1302151',            # Décès Kergloff 3 E 106/18/5 (an VI)
	'AN07' => '1302152',            # Décès Kergloff 3 E 106/18/6 (an VII)
	'AN08' => '1302153',            # Décès Kergloff 3 E 106/18/7 (an VIII)
	'AN10' => '1302155',            # Décès Kergloff 3 E 106/18/9 (an X)
	'AN11' => '1302156',            # Décès Kergloff 3 E 106/18/10 (an XI)
	# FIXME: hole
	1807   => '1302160',            # Décès Kergloff 3 E 106/18/14 (1807)
	1808   => '1302161',            # Décès Kergloff 3 E 106/18/15 (1808)
	1809   => '1302162',            # Décès Kergloff 3 E 106/18/16 (1809)
	1810   => '1302163',            # Décès Kergloff 3 E 106/18/17 (1810)
	1811   => '1302164',            # Décès Kergloff 3 E 106/18/18 (1811)
	1812   => '1302165',            # Décès Kergloff 3 E 106/18/19 (1812)
	1813   => '1302167',            # Décès Kergloff 3 E 106/19/1 (1813)
    },

    '3E106_0019' => {			# Décès Kergloff 3 E 106 19   1814-1832
	1814   => '1302168',            # Décès Kergloff 3 E 106/19/2 (1814)
	1815   => '1302169',            # Décès Kergloff 3 E 106/19/3 (1815)
	1816   => '1302170',            # Décès Kergloff 3 E 106/19/4 (1816)
	1817   => '1302171',            # Décès Kergloff 3 E 106/19/5 (1817)
	1818   => '1302172',            # Décès Kergloff 3 E 106/19/6 (1818)
	1819   => '1302173',            # Décès Kergloff 3 E 106/19/7 (1819)
	1820   => '1302174',            # Décès Kergloff 3 E 106/19/8 (1820)
	1821   => '1302175',            # Décès Kergloff 3 E 106/19/9 (1821)
	1822   => '1302176',            # Décès Kergloff 3 E 106/19/10 (1822)
	1823   => '1302177',            # Décès Kergloff 3 E 106/19/11 (1823)
	1824   => '1302178',            # Décès Kergloff 3 E 106/19/12 (1824)
	1825   => '1302179',            # Décès Kergloff 3 E 106/19/13 (1825)
	1826   => '1302180',            # Décès Kergloff 3 E 106/19/14 (1826)
	1827   => '1302181',            # Décès Kergloff 3 E 106/19/15 (1827)
	1828   => '1302182',            # Décès Kergloff 3 E 106/19/16 (1828)
	1829   => '1302183',            # Décès Kergloff 3 E 106/19/17 (1829)
	1830   => '1302184',            # Décès Kergloff 3 E 106/19/18 (1830)
	1831   => '1302185',            # Décès Kergloff 3 E 106/19/19 (1831)
	1832   => '1302186',            # Décès Kergloff 3 E 106/19/20 (1832)
    },

    '3E106_0020' => {			# Décès Kergloff 3 E 106 20   1833-1842
	1833   => '1302188',            # Décès Kergloff 3 E 106/20/1 (1833)
	1834   => '1302189',            # Décès Kergloff 3 E 106/20/2 (1834)
	1835   => '1302190',            # Décès Kergloff 3 E 106/20/3 (1835)
	1836   => '1302191',            # Décès Kergloff 3 E 106/20/4 (1836)
	1837   => '1302192',            # Décès Kergloff 3 E 106/20/5 (1837)
	1838   => '1302193',            # Décès Kergloff 3 E 106/20/6 (1838)
	1839   => '1302194',            # Décès Kergloff 3 E 106/20/7 (1839)
	1840   => '1302195',            # Décès Kergloff 3 E 106/20/8 (1840)
	1841   => '1302196',            # Décès Kergloff 3 E 106/20/9 (1841)
	1842   => '1302197',            # Décès Kergloff 3 E 106/20/10 (1842)
    },

    '3E106_0021' => {			# Décès Kergloff 3 E 106 21   1843-1852
	1843   => '1302199',            # Décès Kergloff 3 E 106/21/1 (1843)
	1844   => '1302200',            # Décès Kergloff 3 E 106/21/2 (1844)
	1845   => '1302201',            # Décès Kergloff 3 E 106/21/3 (1845)
	1846   => '1302202',            # Décès Kergloff 3 E 106/21/4 (1846)
	1847   => '1302203',            # Décès Kergloff 3 E 106/21/5 (1847)
	1848   => '1302204',            # Décès Kergloff 3 E 106/21/6 (1848)
	1849   => '1302205',            # Décès Kergloff 3 E 106/21/7 (1849)
	1850   => '1302206',            # Décès Kergloff 3 E 106/21/8 (1850)
	1851   => '1302207',            # Décès Kergloff 3 E 106/21/9 (1851)
	1852   => '1302208',            # Décès Kergloff 3 E 106/21/10 (1852)
    },

    '3E106_0022' => {			# Décès Kergloff 3 E 106 22   1853-1862
	1853   => '1302210',            # Décès Kergloff 3 E 106/22/1 (1853)
	1854   => '1302211',            # Décès Kergloff 3 E 106/22/2 (1854)
	1855   => '1302212',            # Décès Kergloff 3 E 106/22/3 (1855)
	1856   => '1302213',            # Décès Kergloff 3 E 106/22/4 (1856)
	1857   => '1302214',            # Décès Kergloff 3 E 106/22/5 (1857)
	1858   => '1302215',            # Décès Kergloff 3 E 106/22/6 (1858)
	1859   => '1302216',            # Décès Kergloff 3 E 106/22/7 (1859)
	1860   => '1302217',            # Décès Kergloff 3 E 106/22/8 (1860)
	1861   => '1302218',            # Décès Kergloff 3 E 106/22/9 (1861)
	1862   => '1302219',            # Décès Kergloff 3 E 106/22/10 (1862)
    },

    '3E106_0023' => {			# Décès Kergloff 3 E 106 23   1863-1869
	1863   => '1302221',            # Décès Kergloff 3 E 106/23/1 (1863)
	1864   => '1302222',            # Décès Kergloff 3 E 106/23/2 (1864)
	1865   => '1302223',            # Décès Kergloff 3 E 106/23/3 (1865)
	1866   => '1302224',            # Décès Kergloff 3 E 106/23/4 (1866)
	1867   => '1302225',            # Décès Kergloff 3 E 106/23/5 (1867)
	1868   => '1302226',            # Décès Kergloff 3 E 106/23/6 (1868)
	1869   => '1302227',            # Décès Kergloff 3 E 106/23/7 (1869)
    },

    '3E106_0024' => {			# Décès Kergloff 3 E 106 24   1870-1884
	1870   => '1302229',            # Décès Kergloff 3 E 106/24/1 (1870)
	1871   => '1302230',            # Décès Kergloff 3 E 106/24/2 (1871)
	1872   => '1302231',            # Décès Kergloff 3 E 106/24/3 (1872)
	1873   => '1302232',            # Décès Kergloff 3 E 106/24/4 (1873)
	1874   => '1302233',            # Décès Kergloff 3 E 106/24/5 (1874)
	1875   => '1302234',            # Décès Kergloff 3 E 106/24/6 (1875)
	1876   => '1302235',            # Décès Kergloff 3 E 106/24/7 (1876)
	1877   => '1302236',            # Décès Kergloff 3 E 106/24/8 (1877)
	1878   => '1302237',            # Décès Kergloff 3 E 106/24/9 (1878)
	1879   => '1302238',            # Décès Kergloff 3 E 106/24/10 (1879)
	1880   => '1302239',            # Décès Kergloff 3 E 106/24/11 (1880)
	1881   => '1302240',            # Décès Kergloff 3 E 106/24/12 (1881)
	1882   => '1302241',            # Décès Kergloff 3 E 106/24/13 (1882)
	1883   => '1302242',            # Décès Kergloff 3 E 106/24/14 (1883)
	1884   => '1302243',            # Décès Kergloff 3 E 106/24/15 (1884)
    },

    '3E106_0025' => {			# Naissance Kergloff 3 E 106 25   1882-1896
	1882 => '1301935',              # Naissance Kergloff 3 E 106/25/1 (1882)
	1883 => '1301936',              # Naissance Kergloff 3 E 106/25/2 (1883)
	1884 => '1301937',              # Naissance Kergloff 3 E 106/25/3 (1884)
	1885 => '1301938',              # Naissance Kergloff 3 E 106/25/4 (1885)
	1886 => '1301939',              # Naissance Kergloff 3 E 106/25/5 (1886)
	1887 => '1301940',              # Naissance Kergloff 3 E 106/25/6 (1887)
	1888 => '1301941',              # Naissance Kergloff 3 E 106/25/7 (1888)
	1889 => '1301942',              # Naissance Kergloff 3 E 106/25/8 (1889)
	1890 => '1301943',              # Naissance Kergloff 3 E 106/25/9 (1890)
	1891 => '1301944',              # Naissance Kergloff 3 E 106/25/10 (1891)
	1892 => '1301945',              # Naissance Kergloff 3 E 106/25/11 (1892)
	1893 => '1301946',              # Naissance Kergloff 3 E 106/25/12 (1893)
	1894 => '1301947',              # Naissance Kergloff 3 E 106/25/13 (1894)
	1895 => '1301948',              # Naissance Kergloff 3 E 106/25/14 (1895)
	1896 => '1301949',              # Naissance Kergloff 3 E 106/25/15 (1896)
    },

    '3E106_0026' => {			# Décès Kergloff 3 E 106 26   1885-1901"
	1885   => '1302245',            # Décès Kergloff 3 E 106/26/1 (1885)
	1886   => '1302246',            # Décès Kergloff 3 E 106/26/2 (1886)
	1887   => '1302247',            # Décès Kergloff 3 E 106/26/3 (1887)
	1888   => '1302248',            # Décès Kergloff 3 E 106/26/4 (1888)
	1889   => '1302249',            # Décès Kergloff 3 E 106/26/5 (1889)
	1890   => '1302250',            # Décès Kergloff 3 E 106/26/6 (1890)
	1891   => '1302251',            # Décès Kergloff 3 E 106/26/7 (1891)
	1892   => '1302252',            # Décès Kergloff 3 E 106/26/8 (1892)
	1893   => '1302253',            # Décès Kergloff 3 E 106/26/9 (1893)
	1894   => '1302254',            # Décès Kergloff 3 E 106/26/10 (1894)
	1895   => '1302255',            # Décès Kergloff 3 E 106/26/11 (1895)
	1896   => '1302256',            # Décès Kergloff 3 E 106/26/12 (1896)
	1897   => '1302257',            # Décès Kergloff 3 E 106/26/13 (1897)
	1898   => '1302258',            # Décès Kergloff 3 E 106/26/14 (1898)
	1899   => '1302259',            # Décès Kergloff 3 E 106/26/15 (1899)
	1900   => '1302260',            # Décès Kergloff 3 E 106/26/16 (1900)
	1901   => '1302261',            # Décès Kergloff 3 E 106/26/17 (1901)
    },

    '3E106_0028' => {			# Naissance Kergloff 3 E 106 28   1897-1908
	1897 => '1301951',              # Naissance Kergloff 3 E 106/28/1 (1897)
	1898 => '1301952',              # Naissance Kergloff 3 E 106/28/2 (1898)
	1899 => '1301953',              # Naissance Kergloff 3 E 106/28/3 (1899)
	1900 => '1301954',              # Naissance Kergloff 3 E 106/28/4 (1900)
	1901 => '1301955',              # Naissance Kergloff 3 E 106/28/5 (1901)
	1902 => '1301956',              # Naissance Kergloff 3 E 106/28/6 (1902)
	1903 => '1301957',              # Naissance Kergloff 3 E 106/28/7 (1903)
	1904 => '1301958',              # Naissance Kergloff 3 E 106/28/8 (1904)
	1904 => '1301958',              # Naissance Kergloff 3 E 106/28/8 (1904)
	1905 => '1301959',              # Naissance Kergloff 3 E 106/28/9 (1905)
	1906 => '1301960',              # Naissance Kergloff 3 E 106/28/10 (1906)
	1907 => '1301961',              # Naissance Kergloff 3 E 106/28/11 (1907)
	1908 => '1301962',              # Naissance Kergloff 3 E 106/28/12 (1908)
    },

    '3E106_0029' => {			# Naissance Kergloff 3 E 106 29   1909-1920
	1909 => '1301964',              # Naissance Kergloff 3 E 106/29/1 (1909)
	1910 => '1301965',              # Naissance Kergloff 3 E 106/29/2 (1910)
	1911 => '1301966',              # Naissance Kergloff 3 E 106/29/3 (1911)
	1912 => '1301967',              # Naissance Kergloff 3 E 106/29/4 (1912)
	1913 => '1301968',              # Naissance Kergloff 3 E 106/29/5 (1913)
	1914 => '1301969',              # Naissance Kergloff 3 E 106/29/6 (1914)
	1915 => '1301970',              # Naissance Kergloff 3 E 106/29/7 (1915)
	1916 => '1301971',              # Naissance Kergloff 3 E 106/29/8 (1916)
	1917 => '1301972',              # Naissance Kergloff 3 E 106/29/9 (1917)
	1918 => '1301973',              # Naissance Kergloff 3 E 106/29/10 (1918)
	1919 => '1301974',              # Naissance Kergloff 3 E 106/29/11 (1919)
	1920 => '1301975',              # Naissance Kergloff 3 E 106/29/12 (1920)
    },

    '3E106_0030' => {                   # Naissance Kergloff 3 E 106 30   1923-1941
	1921 => '1301977',              # Naissance Kergloff 3 E 106/30/1 (1921)
	1922 => '1301978',              # Naissance Kergloff 3 E 106/30/2 (1922)
        1923 => '1301979',              # Naissance Kergloff 3 E 106/30/3 (1923)
        1924 => '1301980',              # Naissance Kergloff 3 E 106/30/4 (1924)
        1925 => '1301981',              # Naissance Kergloff 3 E 106/30/5 (1925)
    },

    '3E106_0033' => {			# Décès Kergloff 3 E 106 33   1902-1916
	1902   => '1302263',            # Décès Kergloff 3 E 106/33/1 (1902)
	1903   => '1302264',            # Décès Kergloff 3 E 106/33/2 (1903)
	1904   => '1302265',            # Décès Kergloff 3 E 106/33/3 (1904)
	1905   => '1302266',            # Décès Kergloff 3 E 106/33/4 (1905)
	1906   => '1302267',            # Décès Kergloff 3 E 106/33/5 (1906)
	1907   => '1302268',            # Décès Kergloff 3 E 106/33/6 (1907)
	1908   => '1302269',            # Décès Kergloff 3 E 106/33/7 (1908)
	1909   => '1302270',            # Décès Kergloff 3 E 106/33/8 (1909)
	1910   => '1302271',            # Décès Kergloff 3 E 106/33/9 (1910)
	1911   => '1302272',            # Décès Kergloff 3 E 106/33/10 (1911)
	1912   => '1302273',            # Décès Kergloff 3 E 106/33/11 (1912)
	1913   => '1302274',            # Décès Kergloff 3 E 106/33/12 (1913)
	1914   => '1302275',            # Décès Kergloff 3 E 106/33/13 (1914)
	1915   => '1302276',            # Décès Kergloff 3 E 106/33/14 (1915)
	1916   => '1302277',            # Décès Kergloff 3 E 106/33/15 (1916)
    },

    '3E106_0034' => {			# Décès Kergloff 3 E 106 34   1917-1936
	1917   => '1302279',            # Décès Kergloff 3 E 106/34/1 (1917)
	1918   => '1302280',            # Décès Kergloff 3 E 106/34/2 (1918)
	1919   => '1302281',            # Décès Kergloff 3 E 106/34/3 (1919)
	1920   => '1302282',            # Décès Kergloff 3 E 106/34/4 (1920)
	1921   => '1302283',            # Décès Kergloff 3 E 106/34/5 (1921)
	1922   => '1302284',            # Décès Kergloff 3 E 106/34/6 (1922)
	1923   => '1302285',            # Décès Kergloff 3 E 106/34/7 (1923)
	1924   => '1302286',            # Décès Kergloff 3 E 106/34/8 (1924)
	1925   => '1302287',            # Décès Kergloff 3 E 106/34/9 (1925)
	# years 1926-1936 never were online with old server
},
    # https://recherche.archives.finistere.fr/archive/resultats/etatcivil/n:138?REch_commune_Libel=Spézet+%28Finistère%29%7C&REch_commune_Md5=b6713734e42457b28f4773f547444ce7%7C&Rech_typologie%5B0%5D=Naissance&type=etatcivil
    '3E348_0012' => '1373156',		# Naissances Spezet  3 E 348 12		1793 - an II
    '3E348_0013' => {			# Naissances Spezet  3 E 348 13		an XI-1812
	999999 => 'dummy',              # Just so that perl-mode indents correctly :-(
	# TODO: vérifier les URLs qui correspondent au calendrier républicain: mais je n'en ai pas dans mon arbre !
	'AN11' => '1373166',		# Naissances Spezet  3 E 348 13 1	an XI
	'AN12' => '1373167',
	'AN13' => '1373168',
	'AN14' => '1373169',
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

    '3E348_0017' => {                   # Naissance Spézet 3 E 348 17   1843-1852
        1843 => '1373210',              # Naissance Spézet 3 E 348/17/1 (1843)
        1844 => '1373211',              # Naissance Spézet 3 E 348/17/2 (1844)
        1845 => '1373212',              # Naissance Spézet 3 E 348/17/3 (1845)
        1846 => '1373213',              # Naissance Spézet 3 E 348/17/4 (1846)
        1847 => '1373214',              # Naissance Spézet 3 E 348/17/5 (1847)
        1848 => '1373215',              # Naissance Spézet 3 E 348/17/6 (1848)
        1849 => '1373216',              # Naissance Spézet 3 E 348/17/7 (1849)
        1850 => '1373217',              # Naissance Spézet 3 E 348/17/8 (1850)
        1851 => '1373218',              # Naissance Spézet 3 E 348/17/9 (1851)
        1852 => '1373219',              # Naissance Spézet 3 E 348/17/10 (1852)
    },

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

    # https://recherche.archives.finistere.fr/archive/resultats/etatcivil/n:138?REch_commune_Libel=Tourch+%28Finistère%29%7C&REch_commune_Md5=b6713734e42457b28f4773f547444ce7%7C&Rech_typologie%5B0%5D=Naissance&type=etatcivil
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

    # Tables décennales :
    # TD Kergloff
    # https://recherche.archives.finistere.fr/archive/resultats/etatcivil/tableau?REch_commune_Libel=Kergloff+%28Finistère%29%7C&REch_commune_Md5=b514c4417f09b16bf87e6d3adcf13473%7C&Rech_typologie%5B0%5D=Table+d%C3%A9cennale&type=etatcivil
    '5E_0092_002_02' => '1130530',
    '5E_0283_001_01' => '1133694',	# TD Scaer
    '5E_0287_002_08' => '1133798',	# TD Spezet
    '5E_0241_006_03' => '1132985',	# TD Quimperlé

    # Recensements :
    # https://recherche.archives.finistere.fr/archive/recherche/recensements/tableau?RECH_commune_Libel=Cléden-Poher%20(Finistère)|&RECH_commune_Md5=5be72e6a952159ab5ea609ce32073fcc|&type=recensements
    '6M0209' => {			# Recensement Clédin-Poher
	# I don't have (and thus haven't tested) any of them in my tree:
	572 => '1140255',   		# Recensement Clédin-Poher 1836
	573 => '1140256',   		# Recensement Clédin-Poher 1841
	574 => '1140257',   		# Recensement Clédin-Poher 1846
	575 => '1140258',   		# Recensement Clédin-Poher 1851
	576 => '1140259',   		# Recensement Clédin-Poher 1856
	577 => '1140260',   		# Recensement Clédin-Poher 1861
	578 => '1140261',   		# Recensement Clédin-Poher 1866
	579 => '1140262',   		# Recensement Clédin-Poher 1872
	580 => '1140263',   		# Recensement Clédin-Poher 1876
    },

    '6M0210' => {			# Recensement Clédin-Poher
	# I only have (and thus only tested) the 1936 in my tree:
	581 => '1140265',   		# Recensement Clédin-Poher 1881 (Note they jumped from 1140263 to 1140265)
	582 => '1140266',   		# Recensement Clédin-Poher 1886
	583 => '1140267',   		# Recensement Clédin-Poher 1891
	584 => '1140268',   		# Recensement Clédin-Poher 1896
	585 => '1140269',   		# Recensement Clédin-Poher 1901
	586 => '1140270',   		# Recensement Clédin-Poher 1906
	587 => '1140271',   		# Recensement Clédin-Poher 1911
	588 => '1140272',   		# Recensement Clédin-Poher 1921
	589 => '1140273',   		# Recensement Clédin-Poher 1926
	590 => '1140274',   		# Recensement Clédin-Poher 1931
	591 => '1140275',   		# Recensement Clédin-Poher 1936
    },

    # https://recherche.archives.finistere.fr/archive/recherche/recensements/tableau?RECH_commune_Libel=Kergloff%20(Finistère)|&RECH_commune_Md5=b514c4417f09b16bf87e6d3adcf13473|&type=recensements
    '6M0344' => {			# Recensement Kergloff
	1728 => '1141602', 		# Recensement Kergloff 1881
	1729 => '1141603',		# Recensement Kergloff 1886
    },

    # https://recherche.archives.finistere.fr/archive/recherche/recensements/tableau?RECH_commune_Libel=Saint-Hernin%20(Finistère)|&RECH_commune_Md5=4253319ee371d0a987f959bf9da20d89|&type=recensements
    '6M0763' => {			# Recensement Saint-Hernin
	4821 => '1145228',		# Recensement Saint-Hernin 1836
	4822 => '1145229',		# Recensement Saint-Hernin 1841
	4823 => '1145230',		# Recensement Saint-Hernin 1846
	4824 => '1145231',		# Recensement Saint-Hernin 1851
	4825 => '1145232',		# Recensement Saint-Hernin 1856
	4826 => '1145233',		# Recensement Saint-Hernin 1861
	4827 => '1145234',		# Recensement Saint-Hernin 1866
	4828 => '1145235',		# Recensement Saint-Hernin 1872
    },

    '6M0764' => {			# Recensement Saint-Hernin
	# https://recherche.archives.finistere.fr/archive/recherche/recensements/tableau?RECH_commune_Libel=Saint-Hernin%20(Finistère)|&RECH_commune_Md5=4253319ee371d0a987f959bf9da20d89|&type=recensements
	4829 => '1145237',		# Recensement Saint-Hernin 1876
	4830 => '1145238',		# Recensement Saint-Hernin 1881
    },

    # https://recherche.archives.finistere.fr/archive/resultats/recensements/tableau?RECH_commune_Libel=Scaër%20(Finist_re)|&RECH_commune_Md5=9c354717cc7a5c14e68227d48522db2a|&type=recensements
    '6M0819' => {
	# I only have 1906 in my tree:
	5278 => '1145763' 		# Recensement Scaer 1906
    },

    '6M0820' => {
	5279 => '1145765', 		# Recensement Scaer 1911  (Note they jumped from 1145763 to 1145765)
	# Pas de recensement à Scaer en 1921?
	5280 => '1145766', 		# Recensement Scaer 1926
	5281 => '1145767', 		# Recensement Scaer 1931
	5282 => '1145768', 		# Recensement Scaer 1936
    },

    # https://recherche.archives.finistere.fr/archive/recherche/recensements/tableau?RECH_commune_Libel=Spézet%20(Finistère)|&RECH_commune_Md5=b6713734e42457b28f4773f547444ce7|&type=recensements
    '6M0833' => {			# Recensement Spézet
	# I only have (and thus only tested) the 188X in my tree
	5343 => '1145844',		# Recensement Spézet 1836
	5344 => '1145845',		# Recensement Spézet 1841
	5345 => '1145846',		# Recensement Spézet 1846
	5346 => '1145847',		# Recensement Spézet 1851
	5347 => '1145848',		# Recensement Spézet 1856
	5348 => '1145849',		# Recensement Spézet 1861
	5349 => '1145851',		# Recensement Spézet 1866  (Note they jumped from 1145849 to 1145851)
	5350 => '1145852',		# Recensement Spézet 1872
	5351 => '1145853',		# Recensement Spézet 1876
	5352 => '1145854',		# Recensement Spézet 1881
	5353 => '1145855',		# Recensement Spézet 1886
	5354 => '1145856',		# Recensement Spézet 1891
	5355 => '1145857',		# Recensement Spézet 1896
	5356 => '1145858',		# Recensement Spézet 1901
	5357 => '1145860',		# Recensement Spézet 1906  (Note they jumped from 1145858 to 1145860)
	5358 => '1145861',		# Recensement Spézet 1911
	5359 => '1145862',		# Recensement Spézet 1921
	5360 => '1145863',		# Recensement Spézet 1926
	5361 => '1145864',		# Recensement Spézet 1931
	5362 => '1145865',		# Recensement Spézet 1936
    },
    );

# From MDK::Common :
sub substInFile(&@) {
    my ($f, $file) = @_;
    #FIXME we should follow symlinks, and fail in case of loop
    if (-l $file) {
        my $targetfile = readlink $file;
        $file = $targetfile;
    }
    if (-s $file) {
        local @ARGV = $file;
        local $^I = '.bak';
        local $_;
        while (<>) {
            $_ .= "\n" if eof && !/\n/;
            &$f($_);
            print;
        }
        open(my $F, $file);
	warn ">> opening $file\n";
        unlink "$file$^I"; # remove old backup now that we have closed new file
    } else {
        #- special handling for zero-sized or nonexistent files
        #- because while (<>) will not do any iteration
        open(my $F, "+> $file") or return;
        #- "eof" without an argument uses the last file read
        my $dummy = <$F>;
        local $_ = '';
        &$f($_);
        print $F $_;
    }
}


# Sanitation check: Make sure that each old key translates to a unique key
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
    # If it's an URL, just display the new URL:
    if ($arg =~ /https/) {
	my $new_url = process($arg);
	warn "<<OLD URL: '$arg'\n>>NEW_URL=\n$new_url\n"; # "\n" in order to be able to do fast copying from terminal
    } elsif (-f $arg) {
	# If it's a file, convert the file in place:
	substInFile {
	    if (my ($url) = m!(https://recherche.archives.finistere.fr/viewer/[^< \n]*)!) {
		my $new_url = process($url);
		if ($new_url =~ /^http/) { # checkup for bad things
		    s!\Q$url\E!$new_url!;
		}
	    }
	} $arg;
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

    # I've _one_ URL out of thousands that has an issue b/c it's different from all other: here the year is encoded as "/YEAR/" :
    # https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/03E/3E042/3E042_0012/AN11/?img=FRAD029_3E042_0012_00N_AN11_016.jpg
    # Add a special case for it:
    if ($id =~ /^AN[0-9]+/) {
	(my $id2, $image) = m![^/]*/([^/?]*)/AN[0-9]+/?\?(img=.*)\.jpg$!;
	$newID = $convert{$id2}{$id};
    }

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
	    warn ">> Failed to parse: ID=$id, $newID=$newID, URL='$_'\n";
	}
    }
    if (!$newID) {
	warn "!!! ID '$id' IS NOT IN THE DB! (URL=$_)\n";
	return;
    }
    return "${prefix}$newID/$image";
}
