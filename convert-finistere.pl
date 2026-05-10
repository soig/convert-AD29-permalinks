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
    '1029EDEPOT_001' => '644418.1465136', # 1029 E-dépôt 1 (Baptêmes et mariages (1783-1786, 1790-1792). Sépultures (1789-1792). Naissances (1793-an VI, an VIII-1820).)
    # NMD Carhaix
    '1024EDEPOT_018' => '1464972',            # Registre registre paroissial baptême mariage sépulture Carhaix (Carhaix-Plouguer, Finistère) 1024 E DEPOT 18 (1788-1793.)
    #'1024EDEPOT_019' => '1464976',            # Registre décès mariage naissance Carhaix (Carhaix-Plouguer, Finistère) 1024 E DEPOT 19 (1793-1821.)
    '1024EDEPOT_020' => '1464977',            # Registre décès mariage naissance Carhaix (Carhaix-Plouguer, Finistère) 1024 E DEPOT 20 (1822-1841.)
    '1024EDEPOT_021' => '1464978',            # Registre décès mariage naissance Carhaix (Carhaix-Plouguer, Finistère) 1024 E DEPOT 21 (1842-1861.)
    '1024EDEPOT_022' => '1464979',            # Registre décès mariage naissance Carhaix (Carhaix-Plouguer, Finistère) 1024 E DEPOT 22 (1862-1876.)
    #'1024EDEPOT_024' => '1464982',            # Registre décès mariage naissance Carhaix (Carhaix-Plouguer, Finistère) 1024 E DEPOT 24 (an II - 1821.)
    '1024EDEPOT_025' => '1464983',            # Registre décès mariage naissance Carhaix (Carhaix-Plouguer, Finistère) 1024 E DEPOT 25 (1822-1852.)
    '1024EDEPOT_026' => '1464984',            # Registre décès mariage naissance Carhaix (Carhaix-Plouguer, Finistère) 1024 E DEPOT 26 (1853-1877.)
    '1024EDEPOT_027' => '1464985',            # Registre décès mariage naissance Carhaix (Carhaix-Plouguer, Finistère) 1024 E DEPOT 27 (1878-1892.)
    '1024EDEPOT_028' => '1464987',            # Registre décès mariage naissance Carhaix (Carhaix-Plouguer, Finistère) 1024 E DEPOT 28 (1793 - an X.)
    '1024EDEPOT_029' => '1464988',            # Registre décès mariage naissance Carhaix (Carhaix-Plouguer, Finistère) 1024 E DEPOT 29 (an XI - 1821.)
    '1024EDEPOT_030' => '1464989',            # Registre décès mariage naissance Carhaix (Carhaix-Plouguer, Finistère) 1024 E DEPOT 30 (1822-1843.)
    '1024EDEPOT_031' => '1464990',            # Registre décès mariage naissance Carhaix (Carhaix-Plouguer, Finistère) 1024 E DEPOT 31 (1844-1860.)
    '1024EDEPOT_032' => '1464991',            # Registre décès mariage naissance Carhaix (Carhaix-Plouguer, Finistère) 1024 E DEPOT 32 (1861-1876.)
    '1024EDEPOT_033' => '1464992',            # Registre décès mariage naissance Carhaix (Carhaix-Plouguer, Finistère) 1024 E DEPOT 33 (1877-1892.)

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
    # FIXME: pas un simple renommage, il faudrait également changer les références aux vues dans les notes associées, par ex la vue 187/201 devient 187/431:
    # "Lors de la préparation de la migration vers notre nouveau moteur de recherche, nous nous sommes aperçus qu’il y avait une erreur d’affectation de certains lots numérisés pour Carhaix et Morlaix.
    # Une partie de ces lots avaient été microfilmés, il y a longtemps, à partir d’originaux empruntés en mairie.
    # Lors de la numérisation de ces microfilms, et leur publication en 2022, cette information avait été omise, et les lots correspondants avaient été raccrochés, à tort, aux collections départementales « 3 E » de ces deux communes.
    # Ceci explique pourquoi vous ne retrouvez pas en cotation « 3 E » certains lots de Carhaix. Il faut regarder côté collection communale « E Dépôt », aux dates équivalentes.
    # Et même chose pour Morlaix, donc."
    '3E037_0012' => '1464976',			# Naissances Carhaix  3 E 37/12	1793-an X => '1024 E DEPOT 19 - 1793-1821' maintenant (plages d'années plus grande)
    '3E037_0022' => '1464982',			# Mariages Carhaix    3 E 37/22	1793-an X => '1024 E DEPOT 19 - 1793-1821' maintenant (201 images précedemment, 431 maintenant)
    # => remplacé par "1024 E DEPOT 24 - an II - 1821. | an II-1821" qui contient les mariages (mais 431 images au lieu de 201).
    # Les références sont bonne, par ex je retrouve le même mariage anciennement vue 187/201 sur la vue 431.
    # Et vue 202/431 on voit "1802-1803 Mariages an 11" donc il semble que deux lots d'images aient été aggloméré en un seul.

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
    '3E234_0003' => '659572.1340590',	# BM Plouguer  3 E 234 3        1750-28 février 1793
    '3E234_0004' => '659573.1340592',	# Sép Plouguer 3 E 234 4
    '3E309_0005' => '1040259.1634656',	# Sép Saint-Hernin 1753-1792

    # NMD :
    # TODO: Sépultures Carhaix, Cleden-Poher, Plonéis, Plouguer, Saint-Hernin
    # TODO: décès … Tourc'h
    # TODO: mariages … Cleden-Poher Elliant Kergloff Kernével Laz Motreff Plouguer Poullaouen, Saint-Goazec, Saint-Hernin Scaer Spezet Tourc'h
    # TODO: naissances Bannalec Beuzec-Conq Châteauneuf-du-Faou Cleden-Poher Elliant Kergloff Landeleau Laz Motreff Plouguer Plouguerneau Quéménéven Rosnoen Poullaouen, Saint-Goazec, Saint-Hernin Scaer

    # NMD Carhaix
    '3E037_0041' => {			# Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37 41   1886-1894
	1886   => '1275559',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/41/1 (1886)
	1887   => '1275560',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/41/2 (1887)
	1888   => '1275561',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/41/3 (1888)
	1889   => '1275562',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/41/4 (1889)
	1890   => '1275563',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/41/5 (1890)
	1891   => '1275564',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/41/6 (1891)
	1892   => '1275565',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/41/7 (1892)
	1893   => '1275566',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/41/8 (1893)
	1894   => '1275567',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/41/9 (1894)
    },

    '3E037_0042' => {			# Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37 42   1888-1896
	1888   => '1275709',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/42/1 (1888)
	1889   => '1275710',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/42/2 (1889)
	1890   => '1275711',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/42/3 (1890)
	1891   => '1275712',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/42/4 (1891)
	1892   => '1275713',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/42/5 (1892)
	1893   => '1275714',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/42/6 (1893)
	1894   => '1275715',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/42/7 (1894)
	1895   => '1275716',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/42/8 (1895)
	1896   => '1275717',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/42/9 (1896)
    },

    '3E037_0043' => {			# Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37 43   1895-1903
	1895   => '1275569',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/43/1 (1895)
	1896   => '1275570',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/43/2 (1896)
	1897   => '1275571',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/43/3 (1897)
	1898   => '1275572',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/43/4 (1898)
	1899   => '1275573',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/43/5 (1899)
	1900   => '1275574',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/43/6 (1900)
	1901   => '1275575',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/43/7 (1901)
	1902   => '1275576',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/43/8 (1902)
	1903   => '1275577',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/43/9 (1903)
    },

    '3E037_0044' => {			# Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37 44   1892-1903
	1892   => '1275639',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/44/1 (1892)
	1893   => '1275640',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/44/2 (1893)
	1894   => '1275641',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/44/3 (1894)
	1895   => '1275642',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/44/4 (1895)
	1896   => '1275643',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/44/5 (1896)
	1897   => '1275644',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/44/6 (1897)
	1898   => '1275645',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/44/7 (1898)
	1899   => '1275646',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/44/8 (1899)
	1900   => '1275647',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/44/9 (1900)
	1901   => '1275648',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/44/10 (1901)
	1902   => '1275649',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/44/11 (1902)
	1903   => '1275650',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/44/12 (1903)
    },

    '3E037_0045' => {			# Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37 45   1897-1905
	1897   => '1275719',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/45/1 (1897)
	1898   => '1275720',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/45/2 (1898)
	1899   => '1275721',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/45/3 (1899)
	1900   => '1275722',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/45/4 (1900)
	1901   => '1275723',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/45/5 (1901)
	1902   => '1275724',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/45/6 (1902)
	1903   => '1275725',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/45/7 (1903)
	1904   => '1275726',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/45/8 (1904)
	1905   => '1275727',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/45/9 (1905)
    },

    '3E037_0046' => {			# Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37 46   1904-1911
	1904   => '1275579',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/46/1 (1904)
	1905   => '1275580',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/46/2 (1905)
	1906   => '1275581',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/46/3 (1906)
	1907   => '1275582',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/46/4 (1907)
	1908   => '1275583',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/46/5 (1908)
	1909   => '1275584',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/46/6 (1909)
	1910   => '1275585',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/46/7 (1910)
	1911   => '1275586',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/46/8 (1911)
    },

    '3E037_0047' => {			# Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37 47   1912-1919
	1912   => '1275588',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/47/1 (1912)
	1913   => '1275589',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/47/2 (1913)
	1914   => '1275590',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/47/3 (1914)
	1915   => '1275591',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/47/4 (1915)
	1916   => '1275592',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/47/5 (1916)
	1917   => '1275593',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/47/6 (1917)
	1918   => '1275594',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/47/7 (1918)
	1919   => '1275595',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/47/8 (1919)
    },

    '3E037_0048' => {			# Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37 48   1920-1925
	1920   => '1275597',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/48/1 (1920)
	1921   => '1275598',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/48/2 (1921)
	1922   => '1275599',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/48/3 (1922)
	1923   => '1275600',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/48/4 (1923)
	1924   => '1275601',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/48/5 (1924)
	1925   => '1275602',            # Naissance Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/48/6 (1925)
    },

    '3E037_0050' => {			# Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37 50   1904-1913
	1904   => '1275652',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/50/1 (1904)
	1905   => '1275653',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/50/2 (1905)
	1906   => '1275654',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/50/3 (1906)
	1907   => '1275655',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/50/4 (1907)
	1908   => '1275656',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/50/5 (1908)
	1909   => '1275657',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/50/6 (1909)
	1910   => '1275658',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/50/7 (1910)
	1911   => '1275659',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/50/8 (1911)
	1912   => '1275660',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/50/9 (1912)
	1913   => '1275661',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/50/10 (1913)
    },

    '3E037_0051' => {			# Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37 51   1914-1923
	1914   => '1275663',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/51/1 (1914)
	1915   => '1275664',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/51/2 (1915)
	1916   => '1275665',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/51/3 (1916)
	1917   => '1275666',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/51/4 (1917)
	1918   => '1275667',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/51/5 (1918)
	1919   => '1275668',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/51/6 (1919)
	1920   => '1275669',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/51/7 (1920)
	1921   => '1275670',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/51/8 (1921)
	1922   => '1275671',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/51/9 (1922)
	1923   => '1275672',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/51/10 (1923)
    },

    '3E037_0052' => {			# Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37 52   1924-1925
	1924   => '1275674',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/52/1 (1924)
	1925   => '1275675',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/52/2 (1925)
    },

    '3E037_0053' => {			# Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37 53   1906-1913
	1906   => '1275729',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/53/1 (1906)
	1907   => '1275730',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/53/2 (1907)
	1908   => '1275731',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/53/3 (1908)
	1909   => '1275732',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/53/4 (1909)
	1910   => '1275733',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/53/5 (1910)
	1911   => '1275734',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/53/6 (1911)
	1912   => '1275735',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/53/7 (1912)
	1913   => '1275736',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/53/8 (1913)
    },

    '3E037_0054' => {			# Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37 54   1914-1920
	1914   => '1275738',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/54/1 (1914)
	1915   => '1275739',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/54/2 (1915)
	1916   => '1275740',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/54/3 (1916)
	1917   => '1275741',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/54/4 (1917)
	1918   => '1275742',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/54/5 (1918)
	1919   => '1275743',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/54/6 (1919)
	1920   => '1275744',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/54/7 (1920)
    },

    '3E037_0055' => {			# Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37 55   1921-1928
	1921   => '1275746',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/55/1 (1921)
	1922   => '1275747',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/55/2 (1922)
	1923   => '1275748',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/55/3 (1923)
	1924   => '1275749',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/55/4 (1924)
	1925   => '1275750',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/55/5 (1925)
	1926   => '1275751',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/55/6 (1926)
	1927   => '1275752',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/55/7 (1927)
	1928   => '1275753',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/55/8 (1928)
    },

    '3E037_0056' => {			# Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37 56   1929-1936
	1929   => '1275755',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/56/1 (1929)
	1930   => '1275756',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/56/2 (1930)
	1931   => '1275757',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/56/3 (1931)
	1932   => '1275758',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/56/4 (1932)
	1933   => '1275759',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/56/5 (1933)
	1934   => '1275760',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/56/6 (1934)
	1935   => '1275761',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/56/7 (1935)
	1936   => '1275762',            # Décès Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/56/8 (1936)
    },

    # NMD Cleden-Poher
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

    '3E042_0013' => {                   # Naissance Cléden-Poher 3 E 42 13   1823-1832
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

    '3E042_0014' => {                   # Naissance Cléden-Poher 3 E 42 14   1833-1842
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

    '3E042_0015' => {                   # Naissance Cléden-Poher 3 E 42 15   1843-1852
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

    '3E042_0016' => {                   # Naissance Cléden-Poher 3 E 42 16   1853-1862
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

    '3E042_0017' => {                   # Naissance Cléden-Poher 3 E 42 17   1863-1869
        1863 => '1277254',              # Naissance Cléden-Poher 3 E 42/17/1 (1863)
        1864 => '1277255',              # Naissance Cléden-Poher 3 E 42/17/2 (1864)
        1865 => '1277256',              # Naissance Cléden-Poher 3 E 42/17/3 (1865)
        1866 => '1277257',              # Naissance Cléden-Poher 3 E 42/17/4 (1866)
        1867 => '1277258',              # Naissance Cléden-Poher 3 E 42/17/5 (1867)
        1868 => '1277259',              # Naissance Cléden-Poher 3 E 42/17/6 (1868)
        1869 => '1277260',              # Naissance Cléden-Poher 3 E 42/17/7 (1869)
    },

    '3E042_0018' => {                   # Naissance Cléden-Poher 3 E 42 18   1870-1880
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

    '3E042_0019' => {                   # Naissance Cléden-Poher 3 E 42 19   1881-1891
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

    '3E042_0037' => {                   # Naissance Cléden-Poher 3 E 42 37   1892-1904
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

    '3E042_0039' => {                   # Décès Cléden-Poher 3 E 42 39   1896-1909
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

    '3E042_0040' => {                   # Naissance Cléden-Poher 3 E 42 40   1904-1913
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

    '3E042_0041' => {                   # Naissance Cléden-Poher 3 E 42 41   1914-1923
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

    '3E042_0042' => {                   # Naissance Cléden-Poher 3 E 42 42   1924-1936
	# Only 1924-1925 were online
        1924 => '1277321',              # Naissance Cléden-Poher 3 E 42/42/1 (1924)
        1925 => '1277322',              # Naissance Cléden-Poher 3 E 42/42/2 (1925)
    },

    '3E042_0045' => {                   # Décès Cléden-Poher 3 E 42 45   1910-1921
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
    '3E042_0046' => {                   # Décès Cléden-Poher 3 E 42 46   1922-1936
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

    '3E106_0009' => {                   # Naissance Kergloff 3 E 106 9   1863-1869
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

    '3E106_0011' => {			# Mariage Kergloff 3 E 106 11   1793-1812
	'AN02' => '1301995',            # Mariage Kergloff 3 E 106/11/1 (1793 - an II)
	'AN03' => '1301996',            # Mariage Kergloff 3 E 106/11/2 (an III)
	'AN04' => '1301997',            # Mariage Kergloff 3 E 106/11/3 (an IV)
	'AN05' => '1301998',            # Mariage Kergloff 3 E 106/11/4 (an V)
	'AN06' => '1301999',            # Mariage Kergloff 3 E 106/11/5 (an VI)
	'AN09' => '1302000',            # Mariage Kergloff 3 E 106/11/6 (an IX)
	'AN10' => '1302001',            # Mariage Kergloff 3 E 106/11/7 (an X)
	'AN11' => '1302002',            # Mariage Kergloff 3 E 106/11/8 (an XI)
	'AN12' => '1302003',            # Mariage Kergloff 3 E 106/11/9 (an XII)
	'AN13' => '1302004',            # Mariage Kergloff 3 E 106/11/10 (an XIII)
	'AN14' => '1302005',            # Mariage Kergloff 3 E 106/11/11 (an XIV - 1806)
	1807   => '1302006',            # Mariage Kergloff 3 E 106/11/12 (1807)
	1808   => '1302007',            # Mariage Kergloff 3 E 106/11/13 (1808)
	1809   => '1302008',            # Mariage Kergloff 3 E 106/11/14 (1809)
	1810   => '1302009',            # Mariage Kergloff 3 E 106/11/15 (1810)
	1811   => '1302010',            # Mariage Kergloff 3 E 106/11/16 (1811)
	1812   => '1302011',            # Mariage Kergloff 3 E 106/11/17 (1812)
    },

    '3E106_0012' => {			# Mariage Kergloff 3 E 106 12   1813-1832
	1813   => '1302013',            # Mariage Kergloff 3 E 106/12/1 (1813)
	1814   => '1302014',            # Mariage Kergloff 3 E 106/12/2 (1814)
	1815   => '1302015',            # Mariage Kergloff 3 E 106/12/3 (1815)
	1816   => '1302016',            # Mariage Kergloff 3 E 106/12/4 (1816)
	1817   => '1302017',            # Mariage Kergloff 3 E 106/12/5 (1817)
	1818   => '1302018',            # Mariage Kergloff 3 E 106/12/6 (1818)
	1819   => '1302019',            # Mariage Kergloff 3 E 106/12/7 (1819)
	1820   => '1302020',            # Mariage Kergloff 3 E 106/12/8 (1820)
	1821   => '1302021',            # Mariage Kergloff 3 E 106/12/9 (1821)
	1822   => '1302022',            # Mariage Kergloff 3 E 106/12/10 (1822)
	1823   => '1302023',            # Mariage Kergloff 3 E 106/12/11 (1823)
	1824   => '1302024',            # Mariage Kergloff 3 E 106/12/12 (1824)
	1825   => '1302025',            # Mariage Kergloff 3 E 106/12/13 (1825)
	1826   => '1302026',            # Mariage Kergloff 3 E 106/12/14 (1826)
	1827   => '1302027',            # Mariage Kergloff 3 E 106/12/15 (1827)
	1828   => '1302028',            # Mariage Kergloff 3 E 106/12/16 (1828)
	1829   => '1302029',            # Mariage Kergloff 3 E 106/12/17 (1829)
	1830   => '1302030',            # Mariage Kergloff 3 E 106/12/18 (1830)
	1831   => '1302031',            # Mariage Kergloff 3 E 106/12/19 (1831)
        1832   => '1302032',            # Mariage Kergloff 3 E 106/12/20 (1832)
    },

    '3E106_0013' => {			# Mariage Kergloff 3 E 106 13   1833-1842
	1833   => '1302034',            # Mariage Kergloff 3 E 106/13/1 (1833)
	1834   => '1302035',            # Mariage Kergloff 3 E 106/13/2 (1834)
	1835   => '1302036',            # Mariage Kergloff 3 E 106/13/3 (1835)
	1836   => '1302037',            # Mariage Kergloff 3 E 106/13/4 (1836)
	1837   => '1302038',            # Mariage Kergloff 3 E 106/13/5 (1837)
	1838   => '1302039',            # Mariage Kergloff 3 E 106/13/6 (1838)
	1839   => '1302040',            # Mariage Kergloff 3 E 106/13/7 (1839)
	1840   => '1302041',            # Mariage Kergloff 3 E 106/13/8 (1840)
	1841   => '1302042',            # Mariage Kergloff 3 E 106/13/9 (1841)
	1842   => '1302043',            # Mariage Kergloff 3 E 106/13/10 (1842)
    },

    '3E106_0014' => {			# Mariage Kergloff 3 E 106 14   1843-1852
	1843   => '1302045',            # Mariage Kergloff 3 E 106/14/1 (1843)
	1844   => '1302046',            # Mariage Kergloff 3 E 106/14/2 (1844)
	1845   => '1302047',            # Mariage Kergloff 3 E 106/14/3 (1845)
	1846   => '1302048',            # Mariage Kergloff 3 E 106/14/4 (1846)
	1847   => '1302049',            # Mariage Kergloff 3 E 106/14/5 (1847)
	1848   => '1302050',            # Mariage Kergloff 3 E 106/14/6 (1848)
	1849   => '1302051',            # Mariage Kergloff 3 E 106/14/7 (1849)
	1850   => '1302052',            # Mariage Kergloff 3 E 106/14/8 (1850)
	1851   => '1302053',            # Mariage Kergloff 3 E 106/14/9 (1851)
	1852   => '1302054',            # Mariage Kergloff 3 E 106/14/10 (1852)
    },

    '3E106_0015' => {			# Mariage Kergloff 3 E 106 15   1853-1862
	1853   => '1302056',            # Mariage Kergloff 3 E 106/15/1 (1853)
	1854   => '1302057',            # Mariage Kergloff 3 E 106/15/2 (1854)
	1855   => '1302058',            # Mariage Kergloff 3 E 106/15/3 (1855)
	1856   => '1302059',            # Mariage Kergloff 3 E 106/15/4 (1856)
	1857   => '1302060',            # Mariage Kergloff 3 E 106/15/5 (1857)
	1858   => '1302061',            # Mariage Kergloff 3 E 106/15/6 (1858)
	1859   => '1302062',            # Mariage Kergloff 3 E 106/15/7 (1859)
	1860   => '1302063',            # Mariage Kergloff 3 E 106/15/8 (1860)
	1861   => '1302064',            # Mariage Kergloff 3 E 106/15/9 (1861)
	1862   => '1302065',            # Mariage Kergloff 3 E 106/15/10 (1862)
    },

    '3E106_0016' => {			# Mariage Kergloff 3 E 106 16   1863-1869
	1863   => '1302067',            # Mariage Kergloff 3 E 106/16/1 (1863)
	1864   => '1302068',            # Mariage Kergloff 3 E 106/16/2 (1864)
	1865   => '1302069',            # Mariage Kergloff 3 E 106/16/3 (1865)
	1866   => '1302070',            # Mariage Kergloff 3 E 106/16/4 (1866)
	1867   => '1302071',            # Mariage Kergloff 3 E 106/16/5 (1867)
	1868   => '1302072',            # Mariage Kergloff 3 E 106/16/6 (1868)
	1869   => '1302073',            # Mariage Kergloff 3 E 106/16/7 (1869)
    },

    '3E106_0017' => {			# Mariage Kergloff 3 E 106 17   1870-1887
	1870   => '1302075',            # Mariage Kergloff 3 E 106/17/1 (1870)
	1871   => '1302076',            # Mariage Kergloff 3 E 106/17/2 (1871)
	1872   => '1302077',            # Mariage Kergloff 3 E 106/17/3 (1872)
	1873   => '1302078',            # Mariage Kergloff 3 E 106/17/4 (1873)
	1874   => '1302079',            # Mariage Kergloff 3 E 106/17/5 (1874)
	1875   => '1302080',            # Mariage Kergloff 3 E 106/17/6 (1875)
	1876   => '1302081',            # Mariage Kergloff 3 E 106/17/7 (1876)
	1877   => '1302082',            # Mariage Kergloff 3 E 106/17/8 (1877)
	1878   => '1302083',            # Mariage Kergloff 3 E 106/17/9 (1878)
	1879   => '1302084',            # Mariage Kergloff 3 E 106/17/10 (1879)
	1880   => '1302085',            # Mariage Kergloff 3 E 106/17/11 (1880)
	1881   => '1302086',            # Mariage Kergloff 3 E 106/17/12 (1881)
	1882   => '1302087',            # Mariage Kergloff 3 E 106/17/13 (1882)
	1883   => '1302088',            # Mariage Kergloff 3 E 106/17/14 (1883)
	1884   => '1302089',            # Mariage Kergloff 3 E 106/17/15 (1884)
	1885   => '1302090',            # Mariage Kergloff 3 E 106/17/16 (1885)
	1886   => '1302091',            # Mariage Kergloff 3 E 106/17/17 (1886)
	1887   => '1302092',            # Mariage Kergloff 3 E 106/17/18 (1887)
    },

    '3E106_0018' => {			# Décès Kergloff 3 E 106 18   1793-1813
	'AN02' => '1302147',            # Décès Kergloff 3 E 106/18/1 (1793 - an II)
	'AN03' => '1302148',            # Décès Kergloff 3 E 106/18/2 (an III)
	'AN04' => '1302149',            # Décès Kergloff 3 E 106/18/3 (an IV)
	'AN05' => '1302150',            # Décès Kergloff 3 E 106/18/4 (an V)
	'AN06' => '1302151',            # Décès Kergloff 3 E 106/18/5 (an VI)
	'AN07' => '1302152',            # Décès Kergloff 3 E 106/18/6 (an VII)
	'AN08' => '1302153',            # Décès Kergloff 3 E 106/18/7 (an VIII)
	'AN09' => '1302154',            # Décès Kergloff 3 E 106/18/8 (an IX)
	'AN10' => '1302155',            # Décès Kergloff 3 E 106/18/9 (an X)
	'AN11' => '1302156',            # Décès Kergloff 3 E 106/18/10 (an XI)
	'AN12' => '1302157',            # Décès Kergloff 3 E 106/18/11 (an XII)
	'AN13' => '1302158',            # Décès Kergloff 3 E 106/18/12 (an XIII)
	'AN14' => '1302159',            # Décès Kergloff 3 E 106/18/13 (an XIV - 1806)
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

    '3E106_0026' => {			# Décès Kergloff 3 E 106 26   1885-1901
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

    '3E106_0027' => {			# Mariage Kergloff 3 E 106 27   1888-1903
	1888   => '1302094',            # Mariage Kergloff 3 E 106/27/1 (1888)
	1889   => '1302095',            # Mariage Kergloff 3 E 106/27/2 (1889)
	1890   => '1302096',            # Mariage Kergloff 3 E 106/27/3 (1890)
	1891   => '1302097',            # Mariage Kergloff 3 E 106/27/4 (1891)
	1892   => '1302098',            # Mariage Kergloff 3 E 106/27/5 (1892)
	1893   => '1302099',            # Mariage Kergloff 3 E 106/27/6 (1893)
	1894   => '1302100',            # Mariage Kergloff 3 E 106/27/7 (1894)
	1895   => '1302101',            # Mariage Kergloff 3 E 106/27/8 (1895)
	1896   => '1302102',            # Mariage Kergloff 3 E 106/27/9 (1896)
	1897   => '1302103',            # Mariage Kergloff 3 E 106/27/10 (1897)
	1898   => '1302104',            # Mariage Kergloff 3 E 106/27/11 (1898)
	1899   => '1302105',            # Mariage Kergloff 3 E 106/27/12 (1899)
	1900   => '1302106',            # Mariage Kergloff 3 E 106/27/13 (1900)
	1901   => '1302107',            # Mariage Kergloff 3 E 106/27/14 (1901)
	1902   => '1302108',            # Mariage Kergloff 3 E 106/27/15 (1902)
	1903   => '1302109',            # Mariage Kergloff 3 E 106/27/16 (1903)
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

    '3E106_0031' => {			# Mariage Kergloff 3 E 106 31   1904-1917
	1904   => '1302111',            # Mariage Kergloff 3 E 106/31/1 (1904)
	1905   => '1302112',            # Mariage Kergloff 3 E 106/31/2 (1905)
	1906   => '1302113',            # Mariage Kergloff 3 E 106/31/3 (1906)
	1907   => '1302114',            # Mariage Kergloff 3 E 106/31/4 (1907)
	1908   => '1302115',            # Mariage Kergloff 3 E 106/31/5 (1908)
	1909   => '1302116',            # Mariage Kergloff 3 E 106/31/6 (1909)
	1910   => '1302117',            # Mariage Kergloff 3 E 106/31/7 (1910)
	1911   => '1302118',            # Mariage Kergloff 3 E 106/31/8 (1911)
	1912   => '1302119',            # Mariage Kergloff 3 E 106/31/9 (1912)
	1913   => '1302120',            # Mariage Kergloff 3 E 106/31/10 (1913)
	1914   => '1302121',            # Mariage Kergloff 3 E 106/31/11 (1914)
	1915   => '1302122',            # Mariage Kergloff 3 E 106/31/12 (1915)
	1916   => '1302123',            # Mariage Kergloff 3 E 106/31/13 (1916)
	1917   => '1302124',            # Mariage Kergloff 3 E 106/31/14 (1917)
    },

    '3E106_0032' => {			# Mariage Kergloff 3 E 106 32   1918-1925
	1918   => '1302126',            # Mariage Kergloff 3 E 106/32/1 (1918)
	1919   => '1302127',            # Mariage Kergloff 3 E 106/32/2 (1919)
	1920   => '1302128',            # Mariage Kergloff 3 E 106/32/3 (1920)
	1921   => '1302129',            # Mariage Kergloff 3 E 106/32/4 (1921)
	1922   => '1302130',            # Mariage Kergloff 3 E 106/32/5 (1922)
	1923   => '1302131',            # Mariage Kergloff 3 E 106/32/6 (1923)
	1924   => '1302132',            # Mariage Kergloff 3 E 106/32/7 (1924)
	1925   => '1302133',            # Mariage Kergloff 3 E 106/32/8 (1925)
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

    # Plouguer
    '3E234_0005' => {			# Naissance Plouguer 3 E 234 5   AN02-1812
	'AN02' => '1340595',            # Naissance Plouguer 3 E 234/5/1 (an II)
	'AN03' => '1340596',            # Naissance Plouguer 3 E 234/5/2 (an III)
	'AN04' => '1340597',            # Naissance Plouguer 3 E 234/5/3 (an IV)
	'AN05' => '1340598',            # Naissance Plouguer 3 E 234/5/4 (an V)
	'AN06' => '1340599',            # Naissance Plouguer 3 E 234/5/5 (an VI)
	'AN07' => '1340600',            # Naissance Plouguer 3 E 234/5/6 (an VII)
	'AN08' => '1340601',            # Naissance Plouguer 3 E 234/5/7 (an VIII)
	'AN09' => '1340602',            # Naissance Plouguer 3 E 234/5/8 (an IX)
	'AN10' => '1340603',            # Naissance Plouguer 3 E 234/5/9 (an X)
	'AN11' => '1340604',            # Naissance Plouguer 3 E 234/5/10 (an XI)
	'AN12' => '1340605',            # Naissance Plouguer 3 E 234/5/11 (an XII)
	'AN13' => '1340606',            # Naissance Plouguer 3 E 234/5/12 (an XIII)
	'AN14' => '1340607',            # Naissance Plouguer 3 E 234/5/13 (an XIV - 1806)
	1807   => '1340608',            # Naissance Plouguer 3 E 234/5/14 (1807)
	1808   => '1340609',            # Naissance Plouguer 3 E 234/5/15 (1808)
	1809   => '1340610',            # Naissance Plouguer 3 E 234/5/16 (1809)
	1810   => '1340611',            # Naissance Plouguer 3 E 234/5/17 (1810)
	1811   => '1340612',            # Naissance Plouguer 3 E 234/5/18 (1811)
	1812   => '1340613',            # Naissance Plouguer 3 E 234/5/19 (1812)
    },

    '3E234_0006' => {			# Naissance Plouguer 3 E 234 6   1813-1832
	1813   => '1340615',            # Naissance Plouguer 3 E 234/6/1 (1813)
	1814   => '1340616',            # Naissance Plouguer 3 E 234/6/2 (1814)
	1815   => '1340617',            # Naissance Plouguer 3 E 234/6/3 (1815)
	1816   => '1340618',            # Naissance Plouguer 3 E 234/6/4 (1816)
	1817   => '1340619',            # Naissance Plouguer 3 E 234/6/5 (1817)
	1818   => '1340620',            # Naissance Plouguer 3 E 234/6/6 (1818)
	1819   => '1340621',            # Naissance Plouguer 3 E 234/6/7 (1819)
	1823   => '1340625',            # Naissance Plouguer 3 E 234/6/11 (1823)
	1824   => '1340626',            # Naissance Plouguer 3 E 234/6/12 (1824)
	1825   => '1340627',            # Naissance Plouguer 3 E 234/6/13 (1825)
	1826   => '1340628',            # Naissance Plouguer 3 E 234/6/14 (1826)
	1827   => '1340629',            # Naissance Plouguer 3 E 234/6/15 (1827)
	1828   => '1340630',            # Naissance Plouguer 3 E 234/6/16 (1828)
	1829   => '1340631',            # Naissance Plouguer 3 E 234/6/17 (1829)
	1830   => '1340632',            # Naissance Plouguer 3 E 234/6/18 (1830)
	1831   => '1340633',            # Naissance Plouguer 3 E 234/6/19 (1831)
	1832   => '1340634',            # Naissance Plouguer 3 E 234/6/20 (1832)
    },

    '3E234_0007' => {			# Naissance Plouguer 3 E 234 7   1833-1842
	1833   => '1340636',            # Naissance Plouguer 3 E 234/7/1 (1833)
	1834   => '1340637',            # Naissance Plouguer 3 E 234/7/2 (1834)
	1835   => '1340638',            # Naissance Plouguer 3 E 234/7/3 (1835)
	1836   => '1340639',            # Naissance Plouguer 3 E 234/7/4 (1836)
	1837   => '1340640',            # Naissance Plouguer 3 E 234/7/5 (1837)
	1838   => '1340641',            # Naissance Plouguer 3 E 234/7/6 (1838)
	1839   => '1340642',            # Naissance Plouguer 3 E 234/7/7 (1839)
	1840   => '1340643',            # Naissance Plouguer 3 E 234/7/8 (1840)
	1841   => '1340644',            # Naissance Plouguer 3 E 234/7/9 (1841)
	1842   => '1340645',            # Naissance Plouguer 3 E 234/7/10 (1842)
    },

    '3E234_0008' => {			# Naissance Plouguer 3 E 234 8   1843-1852
	1843   => '1340647',            # Naissance Plouguer 3 E 234/8/1 (1843)
	1844   => '1340648',            # Naissance Plouguer 3 E 234/8/2 (1844)
	1845   => '1340649',            # Naissance Plouguer 3 E 234/8/3 (1845)
	1846   => '1340650',            # Naissance Plouguer 3 E 234/8/4 (1846)
	1847   => '1340651',            # Naissance Plouguer 3 E 234/8/5 (1847)
	1848   => '1340652',            # Naissance Plouguer 3 E 234/8/6 (1848)
	1849   => '1340653',            # Naissance Plouguer 3 E 234/8/7 (1849)
	1850   => '1340654',            # Naissance Plouguer 3 E 234/8/8 (1850)
	1851   => '1340655',            # Naissance Plouguer 3 E 234/8/9 (1851)
	1852   => '1340656',            # Naissance Plouguer 3 E 234/8/10 (1852)
    },

    '3E234_0009' => {			# Naissance Plouguer 3 E 234 9   1853-1862
	1853   => '1340658',            # Naissance Plouguer 3 E 234/9/1 (1853)
	1854   => '1340659',            # Naissance Plouguer 3 E 234/9/2 (1854)
	1855   => '1340660',            # Naissance Plouguer 3 E 234/9/3 (1855)
	1856   => '1340661',            # Naissance Plouguer 3 E 234/9/4 (1856)
	1857   => '1340662',            # Naissance Plouguer 3 E 234/9/5 (1857)
	1858   => '1340663',            # Naissance Plouguer 3 E 234/9/6 (1858)
	1859   => '1340664',            # Naissance Plouguer 3 E 234/9/7 (1859)
	1860   => '1340665',            # Naissance Plouguer 3 E 234/9/8 (1860)
	1861   => '1340666',            # Naissance Plouguer 3 E 234/9/9 (1861)
	1862   => '1340667',            # Naissance Plouguer 3 E 234/9/10 (1862)
    },

    '3E234_0010' => {			# Naissance Plouguer 3 E 234 10   1863-1869
	1863   => '1340669',            # Naissance Plouguer 3 E 234/10/1 (1863)
	1864   => '1340670',            # Naissance Plouguer 3 E 234/10/2 (1864)
	1865   => '1340671',            # Naissance Plouguer 3 E 234/10/3 (1865)
	1866   => '1340672',            # Naissance Plouguer 3 E 234/10/4 (1866)
	1867   => '1340673',            # Naissance Plouguer 3 E 234/10/5 (1867)
	1868   => '1340674',            # Naissance Plouguer 3 E 234/10/6 (1868)
	1869   => '1340675',            # Naissance Plouguer 3 E 234/10/7 (1869)
    },

    '3E234_0011' => {			# Mariage promesse de mariage Plouguer 3 E 234 11   AN02-1811
	'AN02' => '1340749',            # Mariage promesse de mariage Plouguer 3 E 234/11/1 (an II)
	'AN03' => '1340750',            # Mariage promesse de mariage Plouguer 3 E 234/11/2 (an III)
	'AN04' => '1340751',            # Mariage promesse de mariage Plouguer 3 E 234/11/3 (an IV)
	'AN05' => '1340752',            # Mariage promesse de mariage Plouguer 3 E 234/11/4 (an V)
	'AN06' => '1340753',            # Mariage promesse de mariage Plouguer 3 E 234/11/5 (an VI)
	'AN07' => '1340754',            # Mariage promesse de mariage Plouguer 3 E 234/11/6 (an VII (contient uniquement des promesses de mariages))
	'AN08' => '1340755',            # Mariage promesse de mariage Plouguer 3 E 234/11/7 (an VIII (contient uniquement des promesses de mariages))
	'AN09' => '1340756',            # Mariage promesse de mariage Plouguer 3 E 234/11/8 (an IX)
	'AN10' => '1340757',            # Mariage promesse de mariage Plouguer 3 E 234/11/9 (an X)
	'AN11' => '1340758',            # Mariage promesse de mariage Plouguer 3 E 234/11/10 (an XI)
	'AN12' => '1340759',            # Mariage promesse de mariage Plouguer 3 E 234/11/11 (an XII)
	'AN13' => '1340760',            # Mariage promesse de mariage Plouguer 3 E 234/11/12 (an XIII)
	'AN14' => '1340761',            # Mariage promesse de mariage Plouguer 3 E 234/11/13 (an XIV - 1806)
	1807   => '1340762',            # Mariage promesse de mariage Plouguer 3 E 234/11/14 (1807)
	1808   => '1340763',            # Mariage promesse de mariage Plouguer 3 E 234/11/15 (1808)
	1809   => '1340764',            # Mariage promesse de mariage Plouguer 3 E 234/11/16 (1809)
	1810   => '1340765',            # Mariage promesse de mariage Plouguer 3 E 234/11/17 (1810)
	1811   => '1340766',            # Mariage promesse de mariage Plouguer 3 E 234/11/18 (1811)
    },

    '3E234_0012' => {			# Mariage Plouguer 3 E 234 12   1813-1831
	1813   => '1340769',            # Mariage Plouguer 3 E 234/12/1 (1813)
	1814   => '1340770',            # Mariage Plouguer 3 E 234/12/2 (1814)
	1815   => '1340771',            # Mariage Plouguer 3 E 234/12/3 (1815)
	1816   => '1340772',            # Mariage Plouguer 3 E 234/12/4 (1816)
	1817   => '1340773',            # Mariage Plouguer 3 E 234/12/5 (1817)
	1818   => '1340774',            # Mariage Plouguer 3 E 234/12/6 (1818)
	1819   => '1340775',            # Mariage Plouguer 3 E 234/12/7 (1819)
	1820   => '1340776',            # Mariage Plouguer 3 E 234/12/8 (1820)
	1821   => '1340777',            # Mariage Plouguer 3 E 234/12/9 (1821)
	1822   => '1340778',            # Mariage Plouguer 3 E 234/12/10 (1822)
	1823   => '1340779',            # Mariage Plouguer 3 E 234/12/11 (1823)
	1824   => '1340780',            # Mariage Plouguer 3 E 234/12/12 (1824)
	1825   => '1340781',            # Mariage Plouguer 3 E 234/12/13 (1825)
	1826   => '1340782',            # Mariage Plouguer 3 E 234/12/14 (1826)
	1827   => '1340783',            # Mariage Plouguer 3 E 234/12/15 (1827)
	1828   => '1340784',            # Mariage Plouguer 3 E 234/12/16 (1828)
	1829   => '1340785',            # Mariage Plouguer 3 E 234/12/17 (1829)
	1830   => '1340786',            # Mariage Plouguer 3 E 234/12/18 (1830)
	1831   => '1340787',            # Mariage Plouguer 3 E 234/12/19 (1831)
    },

    '3E234_0013' => {			# Mariage Plouguer 3 E 234 13   1833-1842
	1833   => '1340790',            # Mariage Plouguer 3 E 234/13/1 (1833)
	1834   => '1340791',            # Mariage Plouguer 3 E 234/13/2 (1834)
	1835   => '1340792',            # Mariage Plouguer 3 E 234/13/3 (1835)
	1836   => '1340793',            # Mariage Plouguer 3 E 234/13/4 (1836)
	1837   => '1340794',            # Mariage Plouguer 3 E 234/13/5 (1837)
	1838   => '1340795',            # Mariage Plouguer 3 E 234/13/6 (1838)
	1839   => '1340796',            # Mariage Plouguer 3 E 234/13/7 (1839)
	1840   => '1340797',            # Mariage Plouguer 3 E 234/13/8 (1840)
	1841   => '1340798',            # Mariage Plouguer 3 E 234/13/9 (1841)
	1842   => '1340799',            # Mariage Plouguer 3 E 234/13/10 (1842)
    },

    '3E234_0014' => {			# Mariage Plouguer 3 E 234 14   1843-1852
	1843   => '1340801',            # Mariage Plouguer 3 E 234/14/1 (1843)
	1844   => '1340802',            # Mariage Plouguer 3 E 234/14/2 (1844)
	1845   => '1340803',            # Mariage Plouguer 3 E 234/14/3 (1845)
	1846   => '1340804',            # Mariage Plouguer 3 E 234/14/4 (1846)
	1847   => '1340805',            # Mariage Plouguer 3 E 234/14/5 (1847)
	1848   => '1340806',            # Mariage Plouguer 3 E 234/14/6 (1848)
	1849   => '1340807',            # Mariage Plouguer 3 E 234/14/7 (1849)
	1850   => '1340808',            # Mariage Plouguer 3 E 234/14/8 (1850)
	1851   => '1340809',            # Mariage Plouguer 3 E 234/14/9 (1851)
	1852   => '1340810',            # Mariage Plouguer 3 E 234/14/10 (1852)
    },

    '3E234_0015' => {			# Mariage Plouguer 3 E 234 15   1853-1862
	1853   => '1340812',            # Mariage Plouguer 3 E 234/15/1 (1853)
	1854   => '1340813',            # Mariage Plouguer 3 E 234/15/2 (1854)
	1855   => '1340814',            # Mariage Plouguer 3 E 234/15/3 (1855)
	1856   => '1340815',            # Mariage Plouguer 3 E 234/15/4 (1856)
	1857   => '1340816',            # Mariage Plouguer 3 E 234/15/5 (1857)
	1858   => '1340817',            # Mariage Plouguer 3 E 234/15/6 (1858)
	1859   => '1340818',            # Mariage Plouguer 3 E 234/15/7 (1859)
	1860   => '1340819',            # Mariage Plouguer 3 E 234/15/8 (1860)
	1861   => '1340820',            # Mariage Plouguer 3 E 234/15/9 (1861)
	1862   => '1340821',            # Mariage Plouguer 3 E 234/15/10 (1862)
    },

    '3E234_0016' => {			# Mariage Plouguer 3 E 234 16   1863-1869
	1863   => '1340823',            # Mariage Plouguer 3 E 234/16/1 (1863)
	1864   => '1340824',            # Mariage Plouguer 3 E 234/16/2 (1864)
	1865   => '1340825',            # Mariage Plouguer 3 E 234/16/3 (1865)
	1866   => '1340826',            # Mariage Plouguer 3 E 234/16/4 (1866)
	1867   => '1340827',            # Mariage Plouguer 3 E 234/16/5 (1867)
	1868   => '1340828',            # Mariage Plouguer 3 E 234/16/6 (1868)
	1869   => '1340829',            # Mariage Plouguer 3 E 234/16/7 (1869)
    },

    '3E234_0017' => {			# Mariage Plouguer 3 E 234 17   1870-1884
	1870   => '1340831',            # Mariage Plouguer 3 E 234/17/1 (1870)
	1871   => '1340832',            # Mariage Plouguer 3 E 234/17/2 (1871)
	1872   => '1340833',            # Mariage Plouguer 3 E 234/17/3 (1872)
	1873   => '1340834',            # Mariage Plouguer 3 E 234/17/4 (1873)
	1874   => '1340835',            # Mariage Plouguer 3 E 234/17/5 (1874)
	1875   => '1340836',            # Mariage Plouguer 3 E 234/17/6 (1875)
	1876   => '1340837',            # Mariage Plouguer 3 E 234/17/7 (1876)
	1877   => '1340838',            # Mariage Plouguer 3 E 234/17/8 (1877)
	1878   => '1340839',            # Mariage Plouguer 3 E 234/17/9 (1878)
	1879   => '1340840',            # Mariage Plouguer 3 E 234/17/10 (1879)
	1880   => '1340841',            # Mariage Plouguer 3 E 234/17/11 (1880)
	1881   => '1340842',            # Mariage Plouguer 3 E 234/17/12 (1881)
	1882   => '1340843',            # Mariage Plouguer 3 E 234/17/13 (1882)
	1883   => '1340844',            # Mariage Plouguer 3 E 234/17/14 (1883)
	1884   => '1340845',            # Mariage Plouguer 3 E 234/17/15 (1884)
    },

    '3E234_0018' => {			# Décès Plouguer 3 E 234 18   AN02-1812
	'AN02' => '1340903',            # Décès Plouguer 3 E 234/18/1 (an II)
	'AN03' => '1340904',            # Décès Plouguer 3 E 234/18/2 (an III)
	'AN04' => '1340905',            # Décès Plouguer 3 E 234/18/3 (an IV)
	'AN05' => '1340906',            # Décès Plouguer 3 E 234/18/4 (an V)
	'AN06' => '1340907',            # Décès Plouguer 3 E 234/18/5 (an VI)
	'AN07' => '1340908',            # Décès Plouguer 3 E 234/18/6 (an VII)
	'AN08' => '1340909',            # Décès Plouguer 3 E 234/18/7 (an VIII)
	'AN09' => '1340910',            # Décès Plouguer 3 E 234/18/8 (an IX)
	'AN10' => '1340911',            # Décès Plouguer 3 E 234/18/9 (an X)
	'AN11' => '1340912',            # Décès Plouguer 3 E 234/18/10 (an XI)
	'AN12' => '1340913',            # Décès Plouguer 3 E 234/18/11 (an XII)
	'AN13' => '1340914',            # Décès Plouguer 3 E 234/18/12 (an XIII)
	'AN14' => '1340915',            # Décès Plouguer 3 E 234/18/13 (an XIV - 1806)
	1807   => '1340916',            # Décès Plouguer 3 E 234/18/14 (1807)
	1808   => '1340917',            # Décès Plouguer 3 E 234/18/15 (1808)
	1809   => '1340918',            # Décès Plouguer 3 E 234/18/16 (1809)
	1810   => '1340919',            # Décès Plouguer 3 E 234/18/17 (1810)
	1811   => '1340920',            # Décès Plouguer 3 E 234/18/18 (1811)
	1812   => '1340921',            # Décès Plouguer 3 E 234/18/19 (1812)
    },

    '3E234_0019' => {			# Décès Plouguer 3 E 234 19   1813-1832
	1813   => '1340923',            # Décès Plouguer 3 E 234/19/1 (1813)
	1814   => '1340924',            # Décès Plouguer 3 E 234/19/2 (1814)
	1815   => '1340925',            # Décès Plouguer 3 E 234/19/3 (1815)
	1816   => '1340926',            # Décès Plouguer 3 E 234/19/4 (1816)
	1817   => '1340927',            # Décès Plouguer 3 E 234/19/5 (1817)
	1818   => '1340928',            # Décès Plouguer 3 E 234/19/6 (1818)
	1819   => '1340929',            # Décès Plouguer 3 E 234/19/7 (1819)
	1823   => '1340933',            # Décès Plouguer 3 E 234/19/11 (1823)
	1824   => '1340934',            # Décès Plouguer 3 E 234/19/12 (1824)
	1825   => '1340935',            # Décès Plouguer 3 E 234/19/13 (1825)
	1826   => '1340936',            # Décès Plouguer 3 E 234/19/14 (1826)
	1827   => '1340937',            # Décès Plouguer 3 E 234/19/15 (1827)
	1828   => '1340938',            # Décès Plouguer 3 E 234/19/16 (1828)
	1829   => '1340939',            # Décès Plouguer 3 E 234/19/17 (1829)
	1830   => '1340940',            # Décès Plouguer 3 E 234/19/18 (1830)
	1831   => '1340941',            # Décès Plouguer 3 E 234/19/19 (1831)
	1832   => '1340942',            # Décès Plouguer 3 E 234/19/20 (1832)
    },

    '3E234_0020' => {			# Décès Plouguer 3 E 234 20   1833-1842
	1833   => '1340944',            # Décès Plouguer 3 E 234/20/1 (1833)
	1834   => '1340945',            # Décès Plouguer 3 E 234/20/2 (1834)
	1835   => '1340946',            # Décès Plouguer 3 E 234/20/3 (1835)
	1836   => '1340947',            # Décès Plouguer 3 E 234/20/4 (1836)
	1837   => '1340948',            # Décès Plouguer 3 E 234/20/5 (1837)
	1838   => '1340949',            # Décès Plouguer 3 E 234/20/6 (1838)
	1839   => '1340950',            # Décès Plouguer 3 E 234/20/7 (1839)
	1840   => '1340951',            # Décès Plouguer 3 E 234/20/8 (1840)
	1841   => '1340952',            # Décès Plouguer 3 E 234/20/9 (1841)
	1842   => '1340953',            # Décès Plouguer 3 E 234/20/10 (1842)
    },

    '3E234_0021' => {			# Décès Plouguer 3 E 234 21   1843-1852
	1843   => '1340955',            # Décès Plouguer 3 E 234/21/1 (1843)
	1844   => '1340956',            # Décès Plouguer 3 E 234/21/2 (1844)
	1845   => '1340957',            # Décès Plouguer 3 E 234/21/3 (1845)
	1846   => '1340958',            # Décès Plouguer 3 E 234/21/4 (1846)
	1847   => '1340959',            # Décès Plouguer 3 E 234/21/5 (1847)
	1848   => '1340960',            # Décès Plouguer 3 E 234/21/6 (1848)
	1849   => '1340961',            # Décès Plouguer 3 E 234/21/7 (1849)
	1850   => '1340962',            # Décès Plouguer 3 E 234/21/8 (1850)
	1851   => '1340963',            # Décès Plouguer 3 E 234/21/9 (1851)
	1852   => '1340964',            # Décès Plouguer 3 E 234/21/10 (1852)
    },

    '3E234_0022' => {			# Décès Plouguer 3 E 234 22   1853-1862
	1853   => '1340966',            # Décès Plouguer 3 E 234/22/1 (1853)
	1854   => '1340967',            # Décès Plouguer 3 E 234/22/2 (1854)
	1855   => '1340968',            # Décès Plouguer 3 E 234/22/3 (1855)
	1856   => '1340969',            # Décès Plouguer 3 E 234/22/4 (1856)
	1857   => '1340970',            # Décès Plouguer 3 E 234/22/5 (1857)
	1858   => '1340971',            # Décès Plouguer 3 E 234/22/6 (1858)
	1859   => '1340972',            # Décès Plouguer 3 E 234/22/7 (1859)
	1860   => '1340973',            # Décès Plouguer 3 E 234/22/8 (1860)
	1861   => '1340974',            # Décès Plouguer 3 E 234/22/9 (1861)
	1862   => '1340975',            # Décès Plouguer 3 E 234/22/10 (1862)
    },

    '3E234_0023' => {			# Décès Plouguer 3 E 234 23   1863-1869
	1863   => '1340977',            # Décès Plouguer 3 E 234/23/1 (1863)
	1864   => '1340978',            # Décès Plouguer 3 E 234/23/2 (1864)
	1865   => '1340979',            # Décès Plouguer 3 E 234/23/3 (1865)
	1866   => '1340980',            # Décès Plouguer 3 E 234/23/4 (1866)
	1867   => '1340981',            # Décès Plouguer 3 E 234/23/5 (1867)
	1868   => '1340982',            # Décès Plouguer 3 E 234/23/6 (1868)
	1869   => '1340983',            # Décès Plouguer 3 E 234/23/7 (1869)
    },

    '3E234_0024' => {			# Naissance Plouguer 3 E 234 24   1870-1888
	1870   => '1340677',            # Naissance Plouguer 3 E 234/24/1 (1870)
	1871   => '1340678',            # Naissance Plouguer 3 E 234/24/2 (1871)
	1872   => '1340679',            # Naissance Plouguer 3 E 234/24/3 (1872)
	1873   => '1340680',            # Naissance Plouguer 3 E 234/24/4 (1873)
	1874   => '1340681',            # Naissance Plouguer 3 E 234/24/5 (1874)
	1875   => '1340682',            # Naissance Plouguer 3 E 234/24/6 (1875)
	1876   => '1340683',            # Naissance Plouguer 3 E 234/24/7 (1876)
	1877   => '1340684',            # Naissance Plouguer 3 E 234/24/8 (1877)
	1878   => '1340685',            # Naissance Plouguer 3 E 234/24/9 (1878)
	1879   => '1340686',            # Naissance Plouguer 3 E 234/24/10 (1879)
	1880   => '1340687',            # Naissance Plouguer 3 E 234/24/11 (1880)
	1881   => '1340688',            # Naissance Plouguer 3 E 234/24/12 (1881)
	1882   => '1340689',            # Naissance Plouguer 3 E 234/24/13 (1882)
	1883   => '1340690',            # Naissance Plouguer 3 E 234/24/14 (1883)
	1884   => '1340691',            # Naissance Plouguer 3 E 234/24/15 (1884)
	1885   => '1340692',            # Naissance Plouguer 3 E 234/24/16 (1885)
	1886   => '1340693',            # Naissance Plouguer 3 E 234/24/17 (1886)
	1887   => '1340694',            # Naissance Plouguer 3 E 234/24/18 (1887)
	1888   => '1340695',            # Naissance Plouguer 3 E 234/24/19 (1888)
    },

    '3E234_0025' => {			# Mariage Plouguer 3 E 234 25   1885-1900
	1885   => '1340847',            # Mariage Plouguer 3 E 234/25/1 (1885)
	1886   => '1340848',            # Mariage Plouguer 3 E 234/25/2 (1886)
	1887   => '1340849',            # Mariage Plouguer 3 E 234/25/3 (1887)
	1888   => '1340850',            # Mariage Plouguer 3 E 234/25/4 (1888)
	1889   => '1340851',            # Mariage Plouguer 3 E 234/25/5 (1889)
	1890   => '1340852',            # Mariage Plouguer 3 E 234/25/6 (1890)
	1891   => '1340853',            # Mariage Plouguer 3 E 234/25/7 (1891)
	1892   => '1340854',            # Mariage Plouguer 3 E 234/25/8 (1892)
	1893   => '1340855',            # Mariage Plouguer 3 E 234/25/9 (1893)
	1894   => '1340856',            # Mariage Plouguer 3 E 234/25/10 (1894)
	1895   => '1340857',            # Mariage Plouguer 3 E 234/25/11 (1895)
	1896   => '1340858',            # Mariage Plouguer 3 E 234/25/12 (1896)
	1897   => '1340859',            # Mariage Plouguer 3 E 234/25/13 (1897)
	1898   => '1340860',            # Mariage Plouguer 3 E 234/25/14 (1898)
	1899   => '1340861',            # Mariage Plouguer 3 E 234/25/15 (1899)
	1900   => '1340862',            # Mariage Plouguer 3 E 234/25/16 (1900)
    },

    '3E234_0026' => {			# Décès Plouguer 3 E 234 26   1870-1886
	1870   => '1340985',            # Décès Plouguer 3 E 234/26/1 (1870)
	1871   => '1340986',            # Décès Plouguer 3 E 234/26/2 (1871)
	1872   => '1340987',            # Décès Plouguer 3 E 234/26/3 (1872)
	1873   => '1340988',            # Décès Plouguer 3 E 234/26/4 (1873)
	1874   => '1340989',            # Décès Plouguer 3 E 234/26/5 (1874)
	1875   => '1340990',            # Décès Plouguer 3 E 234/26/6 (1875)
	1876   => '1340991',            # Décès Plouguer 3 E 234/26/7 (1876)
	1877   => '1340992',            # Décès Plouguer 3 E 234/26/8 (1877)
	1878   => '1340993',            # Décès Plouguer 3 E 234/26/9 (1878)
	1879   => '1340994',            # Décès Plouguer 3 E 234/26/10 (1879)
	1880   => '1340995',            # Décès Plouguer 3 E 234/26/11 (1880)
	1881   => '1340996',            # Décès Plouguer 3 E 234/26/12 (1881)
	1882   => '1340997',            # Décès Plouguer 3 E 234/26/13 (1882)
	1883   => '1340998',            # Décès Plouguer 3 E 234/26/14 (1883)
	1884   => '1340999',            # Décès Plouguer 3 E 234/26/15 (1884)
	1885   => '1341000',            # Décès Plouguer 3 E 234/26/16 (1885)
	1886   => '1341001',            # Décès Plouguer 3 E 234/26/17 (1886)
    },

    '3E234_0027' => {			# Décès Plouguer 3 E 234 27   1887-1900
	1887   => '1341003',            # Décès Plouguer 3 E 234/27/1 (1887)
	1888   => '1341004',            # Décès Plouguer 3 E 234/27/2 (1888)
	1889   => '1341005',            # Décès Plouguer 3 E 234/27/3 (1889)
	1890   => '1341006',            # Décès Plouguer 3 E 234/27/4 (1890)
	1891   => '1341007',            # Décès Plouguer 3 E 234/27/5 (1891)
	1892   => '1341008',            # Décès Plouguer 3 E 234/27/6 (1892)
	1893   => '1341009',            # Décès Plouguer 3 E 234/27/7 (1893)
	1894   => '1341010',            # Décès Plouguer 3 E 234/27/8 (1894)
	1895   => '1341011',            # Décès Plouguer 3 E 234/27/9 (1895)
	1896   => '1341012',            # Décès Plouguer 3 E 234/27/10 (1896)
	1897   => '1341013',            # Décès Plouguer 3 E 234/27/11 (1897)
	1898   => '1341014',            # Décès Plouguer 3 E 234/27/12 (1898)
	1899   => '1341015',            # Décès Plouguer 3 E 234/27/13 (1899)
	1900   => '1341016',            # Décès Plouguer 3 E 234/27/14 (1900)
    },

    '3E234_0028' => {			# Naissance Plouguer 3 E 234 28   1889-1904
	1889   => '1340697',            # Naissance Plouguer 3 E 234/28/1 (1889)
	1890   => '1340698',            # Naissance Plouguer 3 E 234/28/2 (1890)
	1891   => '1340699',            # Naissance Plouguer 3 E 234/28/3 (1891)
	1892   => '1340700',            # Naissance Plouguer 3 E 234/28/4 (1892)
	1893   => '1340701',            # Naissance Plouguer 3 E 234/28/5 (1893)
	1894   => '1340702',            # Naissance Plouguer 3 E 234/28/6 (1894)
	1895   => '1340703',            # Naissance Plouguer 3 E 234/28/7 (1895)
	1896   => '1340704',            # Naissance Plouguer 3 E 234/28/8 (1896)
	1897   => '1340705',            # Naissance Plouguer 3 E 234/28/9 (1897)
	1898   => '1340706',            # Naissance Plouguer 3 E 234/28/10 (1898)
	1899   => '1340707',            # Naissance Plouguer 3 E 234/28/11 (1899)
	1900   => '1340708',            # Naissance Plouguer 3 E 234/28/12 (1900)
	1901   => '1340709',            # Naissance Plouguer 3 E 234/28/13 (1901)
	1902   => '1340710',            # Naissance Plouguer 3 E 234/28/14 (1902)
	1903   => '1340711',            # Naissance Plouguer 3 E 234/28/15 (1903)
	1904   => '1340712',            # Naissance Plouguer 3 E 234/28/16 (1904)
    },

    '3E234_0029' => {			# Naissance Plouguer 3 E 234 29   1905-1919
	1905   => '1340714',            # Naissance Plouguer 3 E 234/29/1 (1905)
	1906   => '1340715',            # Naissance Plouguer 3 E 234/29/2 (1906)
	1907   => '1340716',            # Naissance Plouguer 3 E 234/29/3 (1907)
	1908   => '1340717',            # Naissance Plouguer 3 E 234/29/4 (1908)
	1909   => '1340718',            # Naissance Plouguer 3 E 234/29/5 (1909)
	1910   => '1340719',            # Naissance Plouguer 3 E 234/29/6 (1910)
	1911   => '1340720',            # Naissance Plouguer 3 E 234/29/7 (1911)
	1912   => '1340721',            # Naissance Plouguer 3 E 234/29/8 (1912)
	1913   => '1340722',            # Naissance Plouguer 3 E 234/29/9 (1913)
	1914   => '1340723',            # Naissance Plouguer 3 E 234/29/10 (1914)
	1915   => '1340724',            # Naissance Plouguer 3 E 234/29/11 (1915)
	1916   => '1340725',            # Naissance Plouguer 3 E 234/29/12 (1916)
	1917   => '1340726',            # Naissance Plouguer 3 E 234/29/13 (1917)
	1918   => '1340727',            # Naissance Plouguer 3 E 234/29/14 (1918)
	1919   => '1340728',            # Naissance Plouguer 3 E 234/29/15 (1919)
    },

    '3E234_0030' => {			# Naissance Plouguer 3 E 234 30   1920-1925
	1920   => '1340730',            # Naissance Plouguer 3 E 234/30/1 (1920)
	1921   => '1340731',            # Naissance Plouguer 3 E 234/30/2 (1921)
	1922   => '1340732',            # Naissance Plouguer 3 E 234/30/3 (1922)
	1923   => '1340733',            # Naissance Plouguer 3 E 234/30/4 (1923)
	1924   => '1340734',            # Naissance Plouguer 3 E 234/30/5 (1924)
	1925   => '1340735',            # Naissance Plouguer 3 E 234/30/6 (1925)
    },

    '3E234_0031' => {			# Mariage Plouguer 3 E 234 31   1901-1917
	1901   => '1340864',            # Mariage Plouguer 3 E 234/31/1 (1901)
	1902   => '1340865',            # Mariage Plouguer 3 E 234/31/2 (1902)
	1903   => '1340866',            # Mariage Plouguer 3 E 234/31/3 (1903)
	1904   => '1340867',            # Mariage Plouguer 3 E 234/31/4 (1904)
	1905   => '1340868',            # Mariage Plouguer 3 E 234/31/5 (1905)
	1906   => '1340869',            # Mariage Plouguer 3 E 234/31/6 (1906)
	1907   => '1340870',            # Mariage Plouguer 3 E 234/31/7 (1907)
	1908   => '1340871',            # Mariage Plouguer 3 E 234/31/8 (1908)
	1909   => '1340872',            # Mariage Plouguer 3 E 234/31/9 (1909)
	1910   => '1340873',            # Mariage Plouguer 3 E 234/31/10 (1910)
	1911   => '1340874',            # Mariage Plouguer 3 E 234/31/11 (1911)
	1912   => '1340875',            # Mariage Plouguer 3 E 234/31/12 (1912)
	1913   => '1340876',            # Mariage Plouguer 3 E 234/31/13 (1913)
	1914   => '1340877',            # Mariage Plouguer 3 E 234/31/14 (1914)
	1915   => '1340878',            # Mariage Plouguer 3 E 234/31/15 (1915)
	1916   => '1340879',            # Mariage Plouguer 3 E 234/31/16 (1916)
	1917   => '1340880',            # Mariage Plouguer 3 E 234/31/17 (1917)
    },

    '3E234_0032' => {			# Mariage Plouguer 3 E 234 32   1918-1925
	1918   => '1340882',            # Mariage Plouguer 3 E 234/32/1 (1918)
	1919   => '1340883',            # Mariage Plouguer 3 E 234/32/2 (1919)
	1920   => '1340884',            # Mariage Plouguer 3 E 234/32/3 (1920)
	1921   => '1340885',            # Mariage Plouguer 3 E 234/32/4 (1921)
	1922   => '1340886',            # Mariage Plouguer 3 E 234/32/5 (1922)
	1923   => '1340887',            # Mariage Plouguer 3 E 234/32/6 (1923)
	1924   => '1340888',            # Mariage Plouguer 3 E 234/32/7 (1924)
	1925   => '1340889',            # Mariage Plouguer 3 E 234/32/8 (1925)
    },

    '3E234_0033' => {			# Décès Plouguer 3 E 234 33   1901-1915
	1901   => '1341018',            # Décès Plouguer 3 E 234/33/1 (1901)
	1902   => '1341019',            # Décès Plouguer 3 E 234/33/2 (1902)
	1903   => '1341020',            # Décès Plouguer 3 E 234/33/3 (1903)
	1904   => '1341021',            # Décès Plouguer 3 E 234/33/4 (1904)
	1905   => '1341022',            # Décès Plouguer 3 E 234/33/5 (1905)
	1906   => '1341023',            # Décès Plouguer 3 E 234/33/6 (1906)
	1907   => '1341024',            # Décès Plouguer 3 E 234/33/7 (1907)
	1908   => '1341025',            # Décès Plouguer 3 E 234/33/8 (1908)
	1909   => '1341026',            # Décès Plouguer 3 E 234/33/9 (1909)
	1910   => '1341027',            # Décès Plouguer 3 E 234/33/10 (1910)
	1911   => '1341028',            # Décès Plouguer 3 E 234/33/11 (1911)
	1912   => '1341029',            # Décès Plouguer 3 E 234/33/12 (1912)
	1913   => '1341030',            # Décès Plouguer 3 E 234/33/13 (1913)
	1914   => '1341031',            # Décès Plouguer 3 E 234/33/14 (1914)
	1915   => '1341032',            # Décès Plouguer 3 E 234/33/15 (1915)
    },

    '3E234_0034' => {			# Décès Plouguer 3 E 234 34   1916-1936
	1916   => '1341034',            # Décès Plouguer 3 E 234/34/1 (1916)
	1917   => '1341035',            # Décès Plouguer 3 E 234/34/2 (1917)
	1918   => '1341036',            # Décès Plouguer 3 E 234/34/3 (1918)
	1919   => '1341037',            # Décès Plouguer 3 E 234/34/4 (1919)
	1920   => '1341038',            # Décès Plouguer 3 E 234/34/5 (1920)
	1921   => '1341039',            # Décès Plouguer 3 E 234/34/6 (1921)
	1922   => '1341040',            # Décès Plouguer 3 E 234/34/7 (1922)
	1923   => '1341041',            # Décès Plouguer 3 E 234/34/8 (1923)
	1924   => '1341042',            # Décès Plouguer 3 E 234/34/9 (1924)
	1925   => '1341043',            # Décès Plouguer 3 E 234/34/10 (1925)
	1926   => '1341044',            # Décès Plouguer 3 E 234/34/11 (1926)
	1927   => '1341045',            # Décès Plouguer 3 E 234/34/12 (1927)
	1928   => '1341046',            # Décès Plouguer 3 E 234/34/13 (1928)
	1929   => '1341047',            # Décès Plouguer 3 E 234/34/14 (1929)
	1930   => '1341048',            # Décès Plouguer 3 E 234/34/15 (1930)
	1931   => '1341049',            # Décès Plouguer 3 E 234/34/16 (1931)
	1932   => '1341050',            # Décès Plouguer 3 E 234/34/17 (1932)
	1933   => '1341051',            # Décès Plouguer 3 E 234/34/18 (1933)
	1934   => '1341052',            # Décès Plouguer 3 E 234/34/19 (1934)
	1935   => '1341053',            # Décès Plouguer 3 E 234/34/20 (1935)
	1936   => '1341054',            # Décès Plouguer 3 E 234/34/21 (1936)
    },

    # Saint-Hernin
    '3E309_0006' => '1040260.1634658',  # Naissance Saint-Hernin 3 E 309 6 (1793-1812)
    '3E309_0007' => '1040261.1634659',  # Naissance Saint-Hernin 3 E 309 7 (1813-1832)
    '3E309_0008' => '1040452.1634660',  # Naissance Saint-Hernin 3 E 309 8 (1833-1842)
    '3E309_0009' => '1040453.1634661',  # Naissance Saint-Hernin 3 E 309 9 (1843-1852)
    '3E309_0010' => '1040454.1634662',  # Naissance Saint-Hernin 3 E 309 10 (1853-1862)
    '3E309_0011' => '1040455.1634663',  # Naissance Saint-Hernin 3 E 309 11 (1863-1869)
    '3E309_0012' => '1040456.1634664',  # Naissance Saint-Hernin 3 E 309 12 (1870-1885)
    '3E309_0013' => '1040457.1634708',  # Mariage promesse de mariage publication de mariage Saint-Hernin 3 E 309 13 (1793-1812)
    '3E309_0014' => '1040458.1634709',  # Mariage Saint-Hernin 3 E 309 14 (1813-1832)
    '3E309_0015' => '1040459.1634710',  # Mariage Saint-Hernin 3 E 309 15 (1833-1842)
    '3E309_0016' => '1040460.1634711',  # Mariage Saint-Hernin 3 E 309 16 (1843-1852)
    '3E309_0017' => '1040461.1634712',  # Mariage Saint-Hernin 3 E 309 17 (1853-1862)
    '3E309_0018' => '1040462.1634713',  # Mariage Saint-Hernin 3 E 309 18 (1863-1869)
    '3E309_0019' => '1040463.1634714',  # Mariage Saint-Hernin 3 E 309 19 (1870-1887)
    '3E309_0020' => '1040464.1634768',  # Décès Saint-Hernin 3 E 309 20 (1793-1812)
    '3E309_0021' => '1040465.1634769',  # Décès Saint-Hernin 3 E 309 21 (1813-1832)
    '3E309_0022' => '1040466.1634770',  # Décès Saint-Hernin 3 E 309 22 (1833-1842)
    '3E309_0023' => '1040467.1634771',  # Décès Saint-Hernin 3 E 309 23 (1843-1852)
    '3E309_0024' => '1040468.1634772',  # Décès Saint-Hernin 3 E 309 24 (1853-1862)
    '3E309_0025' => '1040469.1634773',  # Décès Saint-Hernin 3 E 309 25 (1863-1869)
    '3E309_0026' => '1040470.1634774',  # Décès Saint-Hernin 3 E 309 26 (1870-1888)
    '3E309_0027' => '1040471.1634665',  # Naissance Saint-Hernin 3 E 309 27 (1886-1898)
    '3E309_0028' => {			# Mariage Saint-Hernin 3 E 309 28   1888-1904
	1888   => '1634716',            # Mariage Saint-Hernin 3 E 309/28/1 (1888)
	1889   => '1634717',            # Mariage Saint-Hernin 3 E 309/28/2 (1889)
	1890   => '1634718',            # Mariage Saint-Hernin 3 E 309/28/3 (1890)
	1891   => '1634719',            # Mariage Saint-Hernin 3 E 309/28/4 (1891)
	1892   => '1634720',            # Mariage Saint-Hernin 3 E 309/28/5 (1892)
	1893   => '1634721',            # Mariage Saint-Hernin 3 E 309/28/6 (1893)
	1894   => '1634722',            # Mariage Saint-Hernin 3 E 309/28/7 (1894)
	1895   => '1634723',            # Mariage Saint-Hernin 3 E 309/28/8 (1895)
	1896   => '1634724',            # Mariage Saint-Hernin 3 E 309/28/9 (1896)
	1897   => '1634725',            # Mariage Saint-Hernin 3 E 309/28/10 (1897)
	1898   => '1634726',            # Mariage Saint-Hernin 3 E 309/28/11 (1898)
	1899   => '1634727',            # Mariage Saint-Hernin 3 E 309/28/12 (1899)
	1900   => '1634728',            # Mariage Saint-Hernin 3 E 309/28/13 (1900)
	1901   => '1634729',            # Mariage Saint-Hernin 3 E 309/28/14 (1901)
	1902   => '1634730',            # Mariage Saint-Hernin 3 E 309/28/15 (1902)
	1903   => '1634731',            # Mariage Saint-Hernin 3 E 309/28/16 (1903)
	1904   => '1634732',            # Mariage Saint-Hernin 3 E 309/28/17 (1904)
    },

    '3E309_0029' => {			# Décès Saint-Hernin 3 E 309 29   1889-1906
	1889   => '1634776',            # Décès Saint-Hernin 3 E 309/29/1 (1889)
	1890   => '1634777',            # Décès Saint-Hernin 3 E 309/29/2 (1890)
	1891   => '1634778',            # Décès Saint-Hernin 3 E 309/29/3 (1891)
	1892   => '1634779',            # Décès Saint-Hernin 3 E 309/29/4 (1892)
	1893   => '1634780',            # Décès Saint-Hernin 3 E 309/29/5 (1893)
	1894   => '1634781',            # Décès Saint-Hernin 3 E 309/29/6 (1894)
	1895   => '1634782',            # Décès Saint-Hernin 3 E 309/29/7 (1895)
	1896   => '1634783',            # Décès Saint-Hernin 3 E 309/29/8 (1896)
	1897   => '1634784',            # Décès Saint-Hernin 3 E 309/29/9 (1897)
	1898   => '1634785',            # Décès Saint-Hernin 3 E 309/29/10 (1898)
	1899   => '1634786',            # Décès Saint-Hernin 3 E 309/29/11 (1899)
	1900   => '1634787',            # Décès Saint-Hernin 3 E 309/29/12 (1900)
	1901   => '1634788',            # Décès Saint-Hernin 3 E 309/29/13 (1901)
	1902   => '1634789',            # Décès Saint-Hernin 3 E 309/29/14 (1902)
	1903   => '1634790',            # Décès Saint-Hernin 3 E 309/29/15 (1903)
	1904   => '1634791',            # Décès Saint-Hernin 3 E 309/29/16 (1904)
	1905   => '1634792',            # Décès Saint-Hernin 3 E 309/29/17 (1905)
	1906   => '1634793',            # Décès Saint-Hernin 3 E 309/29/18 (1906)
    },

    '3E309_0030' => {			# Naissance Saint-Hernin 3 E 309 30   1899-1909
	1899   => '1634667',            # Naissance Saint-Hernin 3 E 309/30/1 (1899)
	1900   => '1634668',            # Naissance Saint-Hernin 3 E 309/30/2 (1900)
	1901   => '1634669',            # Naissance Saint-Hernin 3 E 309/30/3 (1901)
	1902   => '1634670',            # Naissance Saint-Hernin 3 E 309/30/4 (1902)
	1903   => '1634671',            # Naissance Saint-Hernin 3 E 309/30/5 (1903)
	1904   => '1634672',            # Naissance Saint-Hernin 3 E 309/30/6 (1904)
	1905   => '1634673',            # Naissance Saint-Hernin 3 E 309/30/7 (1905)
	1906   => '1634674',            # Naissance Saint-Hernin 3 E 309/30/8 (1906)
	1907   => '1634675',            # Naissance Saint-Hernin 3 E 309/30/9 (1907)
	1908   => '1634676',            # Naissance Saint-Hernin 3 E 309/30/10 (1908)
	1909   => '1634677',            # Naissance Saint-Hernin 3 E 309/30/11 (1909)
    },

    '3E309_0031' => {			# Naissance Saint-Hernin 3 E 309 31   1910-1921
	1910   => '1634679',            # Naissance Saint-Hernin 3 E 309/31/1 (1910)
	1911   => '1634680',            # Naissance Saint-Hernin 3 E 309/31/2 (1911)
	1912   => '1634681',            # Naissance Saint-Hernin 3 E 309/31/3 (1912)
	1913   => '1634682',            # Naissance Saint-Hernin 3 E 309/31/4 (1913)
	1914   => '1634683',            # Naissance Saint-Hernin 3 E 309/31/5 (1914)
	1915   => '1634684',            # Naissance Saint-Hernin 3 E 309/31/6 (1915)
	1916   => '1634685',            # Naissance Saint-Hernin 3 E 309/31/7 (1916)
	1917   => '1634686',            # Naissance Saint-Hernin 3 E 309/31/8 (1917)
	1918   => '1634687',            # Naissance Saint-Hernin 3 E 309/31/9 (1918)
	1919   => '1634688',            # Naissance Saint-Hernin 3 E 309/31/10 (1919)
	1920   => '1634689',            # Naissance Saint-Hernin 3 E 309/31/11 (1920)
	1921   => '1634690',            # Naissance Saint-Hernin 3 E 309/31/12 (1921)
    },

    '3E309_0032' => {			# Naissance Saint-Hernin 3 E 309 32   1922-1925
	1922   => '1634692',            # Naissance Saint-Hernin 3 E 309/32/1 (1922)
	1923   => '1634693',            # Naissance Saint-Hernin 3 E 309/32/2 (1923)
	1924   => '1634694',            # Naissance Saint-Hernin 3 E 309/32/3 (1924)
	1925   => '1634695',            # Naissance Saint-Hernin 3 E 309/32/4 (1925)
    },

    '3E309_0033' => {			# Mariage Saint-Hernin 3 E 309 33   1905-1919
	1905   => '1634734',            # Mariage Saint-Hernin 3 E 309/33/1 (1905)
	1906   => '1634735',            # Mariage Saint-Hernin 3 E 309/33/2 (1906)
	1907   => '1634736',            # Mariage Saint-Hernin 3 E 309/33/3 (1907)
	1908   => '1634737',            # Mariage Saint-Hernin 3 E 309/33/4 (1908)
	1909   => '1634738',            # Mariage Saint-Hernin 3 E 309/33/5 (1909)
	1910   => '1634739',            # Mariage Saint-Hernin 3 E 309/33/6 (1910)
	1911   => '1634740',            # Mariage Saint-Hernin 3 E 309/33/7 (1911)
	1912   => '1634741',            # Mariage Saint-Hernin 3 E 309/33/8 (1912)
	1913   => '1634742',            # Mariage Saint-Hernin 3 E 309/33/9 (1913)
	1914   => '1634743',            # Mariage Saint-Hernin 3 E 309/33/10 (1914)
	1915   => '1634744',            # Mariage Saint-Hernin 3 E 309/33/11 (1915)
	1916   => '1634745',            # Mariage Saint-Hernin 3 E 309/33/12 (1916)
	1917   => '1634746',            # Mariage Saint-Hernin 3 E 309/33/13 (1917)
	1918   => '1634747',            # Mariage Saint-Hernin 3 E 309/33/14 (1918)
	1919   => '1634748',            # Mariage Saint-Hernin 3 E 309/33/15 (1919)
    },

    '3E309_0034' => {			# Mariage Saint-Hernin 3 E 309 34   1920-1925
	1920   => '1634750',            # Mariage Saint-Hernin 3 E 309/34/1 (1920)
	1921   => '1634751',            # Mariage Saint-Hernin 3 E 309/34/2 (1921)
	1922   => '1634752',            # Mariage Saint-Hernin 3 E 309/34/3 (1922)
	1923   => '1634753',            # Mariage Saint-Hernin 3 E 309/34/4 (1923)
	1924   => '1634754',            # Mariage Saint-Hernin 3 E 309/34/5 (1924)
	1925   => '1634755',            # Mariage Saint-Hernin 3 E 309/34/6 (1925)
    },

    '3E309_0035' => {			# Décès Saint-Hernin 3 E 309 35   1907-1921
	1907   => '1634795',            # Décès Saint-Hernin 3 E 309/35/1 (1907)
	1908   => '1634796',            # Décès Saint-Hernin 3 E 309/35/2 (1908)
	1909   => '1634797',            # Décès Saint-Hernin 3 E 309/35/3 (1909)
	1910   => '1634798',            # Décès Saint-Hernin 3 E 309/35/4 (1910)
	1911   => '1634799',            # Décès Saint-Hernin 3 E 309/35/5 (1911)
	1912   => '1634800',            # Décès Saint-Hernin 3 E 309/35/6 (1912)
	1913   => '1634801',            # Décès Saint-Hernin 3 E 309/35/7 (1913)
	1914   => '1634802',            # Décès Saint-Hernin 3 E 309/35/8 (1914)
	1915   => '1634803',            # Décès Saint-Hernin 3 E 309/35/9 (1915)
	1916   => '1634804',            # Décès Saint-Hernin 3 E 309/35/10 (1916)
	1917   => '1634805',            # Décès Saint-Hernin 3 E 309/35/11 (1917)
	1918   => '1634806',            # Décès Saint-Hernin 3 E 309/35/12 (1918)
	1919   => '1634807',            # Décès Saint-Hernin 3 E 309/35/13 (1919)
	1920   => '1634808',            # Décès Saint-Hernin 3 E 309/35/14 (1920)
	1921   => '1634809',            # Décès Saint-Hernin 3 E 309/35/15 (1921)
    },

    '3E309_0036' => {			# Décès Saint-Hernin 3 E 309 36   1922-1936
	1922   => '1634811',            # Décès Saint-Hernin 3 E 309/36/1 (1922)
	1923   => '1634812',            # Décès Saint-Hernin 3 E 309/36/2 (1923)
	1924   => '1634813',            # Décès Saint-Hernin 3 E 309/36/3 (1924)
	1925   => '1634814',            # Décès Saint-Hernin 3 E 309/36/4 (1925)
	1926   => '1634815',            # Décès Saint-Hernin 3 E 309/36/5 (1926)
	1927   => '1634816',            # Décès Saint-Hernin 3 E 309/36/6 (1927)
	1928   => '1634817',            # Décès Saint-Hernin 3 E 309/36/7 (1928)
	1929   => '1634818',            # Décès Saint-Hernin 3 E 309/36/8 (1929)
	1930   => '1634819',            # Décès Saint-Hernin 3 E 309/36/9 (1930)
	1931   => '1634820',            # Décès Saint-Hernin 3 E 309/36/10 (1931)
	1932   => '1634821',            # Décès Saint-Hernin 3 E 309/36/11 (1932)
	1933   => '1634822',            # Décès Saint-Hernin 3 E 309/36/12 (1933)
	1934   => '1634823',            # Décès Saint-Hernin 3 E 309/36/13 (1934)
	1935   => '1634824',            # Décès Saint-Hernin 3 E 309/36/14 (1935)
	1936   => '1634825',            # Décès Saint-Hernin 3 E 309/36/15 (1936)
    },

    # Scaër
    '3E344_0013' => {			# Naissance Scaër 3 E 344 13   AN 2 - AN 10
	'AN02' => '1371660',            # Naissance Scaër 3 E 344/13/1 (1793 - an II)
	'AN03' => '1371661',            # Naissance Scaër 3 E 344/13/2 (an III)
	'AN04' => '1371662',            # Naissance Scaër 3 E 344/13/3 (an IV)
	'AN05' => '1371663',            # Naissance Scaër 3 E 344/13/4 (an V)
	'AN06' => '1371664',            # Naissance Scaër 3 E 344/13/5 (an VI)
	'AN07' => '1371665',            # Naissance Scaër 3 E 344/13/6 (an VII)
	'AN08' => '1371666',            # Naissance Scaër 3 E 344/13/7 (an VIII)
	'AN09' => '1371667',            # Naissance Scaër 3 E 344/13/8 (an IX)
	'AN10' => '1371668',            # Naissance Scaër 3 E 344/13/9 (an X)
    },

    '3E344_0014' => {			# Naissance Scaër 3 E 344 14   AN11-1812
	'AN11' => '1371670',            # Naissance Scaër 3 E 344/14/1 (an XI)
	'AN12' => '1371671',            # Naissance Scaër 3 E 344/14/2 (an XII)
	'AN13' => '1371672',            # Naissance Scaër 3 E 344/14/3 (an XIII)
	'AN14' => '1371673',            # Naissance Scaër 3 E 344/14/4 (an XIV - 1806)
	1807   => '1371674',            # Naissance Scaër 3 E 344/14/5 (1807)
	1808   => '1371675',            # Naissance Scaër 3 E 344/14/6 (1808)
	1809   => '1371676',            # Naissance Scaër 3 E 344/14/7 (1809)
	1810   => '1371677',            # Naissance Scaër 3 E 344/14/8 (1810)
	1811   => '1371678',            # Naissance Scaër 3 E 344/14/9 (1811)
	1812   => '1371679',            # Naissance Scaër 3 E 344/14/10 (1812)
    },

    '3E344_0015' => {			# Naissance Scaër 3 E 344 15   1813-1817
	1813   => '1371681',            # Naissance Scaër 3 E 344/15/1 (1813)
	1814   => '1371682',            # Naissance Scaër 3 E 344/15/2 (1814)
	1815   => '1371683',            # Naissance Scaër 3 E 344/15/3 (1815)
	1816   => '1371684',            # Naissance Scaër 3 E 344/15/4 (1816)
	1817   => '1371685',            # Naissance Scaër 3 E 344/15/5 (1817)
    },

    '3E344_0016' => {			# Naissance Scaër 3 E 344 16   1823-1832
	1823   => '1371692',            # Naissance Scaër 3 E 344/16/1 (1823)
	1824   => '1371693',            # Naissance Scaër 3 E 344/16/2 (1824)
	1825   => '1371694',            # Naissance Scaër 3 E 344/16/3 (1825)
	1826   => '1371695',            # Naissance Scaër 3 E 344/16/4 (1826)
	1827   => '1371696',            # Naissance Scaër 3 E 344/16/5 (1827)
	1828   => '1371697',            # Naissance Scaër 3 E 344/16/6 (1828)
	1829   => '1371698',            # Naissance Scaër 3 E 344/16/7 (1829)
	1830   => '1371699',            # Naissance Scaër 3 E 344/16/8 (1830)
	1831   => '1371700',            # Naissance Scaër 3 E 344/16/9 (1831)
	1832   => '1371701',            # Naissance Scaër 3 E 344/16/10 (1832)
    },

    '3E344_0017' => {			# Naissance Scaër 3 E 344 17   1833-1842
	1833   => '1371703',            # Naissance Scaër 3 E 344/17/1 (1833)
	1834   => '1371704',            # Naissance Scaër 3 E 344/17/2 (1834)
	1835   => '1371705',            # Naissance Scaër 3 E 344/17/3 (1835)
	1836   => '1371706',            # Naissance Scaër 3 E 344/17/4 (1836)
	1837   => '1371707',            # Naissance Scaër 3 E 344/17/5 (1837)
	1838   => '1371708',            # Naissance Scaër 3 E 344/17/6 (1838)
	1839   => '1371709',            # Naissance Scaër 3 E 344/17/7 (1839)
	1840   => '1371710',            # Naissance Scaër 3 E 344/17/8 (1840)
	1841   => '1371711',            # Naissance Scaër 3 E 344/17/9 (1841)
	1842   => '1371712',            # Naissance Scaër 3 E 344/17/10 (1842)
    },

    '3E344_0018' => {			# Naissance Scaër 3 E 344 18   1843-1852
	1843   => '1371714',            # Naissance Scaër 3 E 344/18/1 (1843)
	1844   => '1371715',            # Naissance Scaër 3 E 344/18/2 (1844)
	1845   => '1371716',            # Naissance Scaër 3 E 344/18/3 (1845)
	1846   => '1371717',            # Naissance Scaër 3 E 344/18/4 (1846)
	1847   => '1371718',            # Naissance Scaër 3 E 344/18/5 (1847)
	1848   => '1371719',            # Naissance Scaër 3 E 344/18/6 (1848)
	1849   => '1371720',            # Naissance Scaër 3 E 344/18/7 (1849)
	1850   => '1371721',            # Naissance Scaër 3 E 344/18/8 (1850)
	1851   => '1371722',            # Naissance Scaër 3 E 344/18/9 (1851)
	1852   => '1371723',            # Naissance Scaër 3 E 344/18/10 (1852)
    },

    '3E344_0019' => {			# Naissance Scaër 3 E 344 19   1853-1862
	1853   => '1371725',            # Naissance Scaër 3 E 344/19/1 (1853)
	1854   => '1371726',            # Naissance Scaër 3 E 344/19/2 (1854)
	1855   => '1371727',            # Naissance Scaër 3 E 344/19/3 (1855)
	1856   => '1371728',            # Naissance Scaër 3 E 344/19/4 (1856)
	1857   => '1371729',            # Naissance Scaër 3 E 344/19/5 (1857)
	1858   => '1371730',            # Naissance Scaër 3 E 344/19/6 (1858)
	1859   => '1371731',            # Naissance Scaër 3 E 344/19/7 (1859)
	1860   => '1371732',            # Naissance Scaër 3 E 344/19/8 (1860)
	1861   => '1371733',            # Naissance Scaër 3 E 344/19/9 (1861)
	1862   => '1371734',            # Naissance Scaër 3 E 344/19/10 (1862)
    },

    '3E344_0020' => {			# Naissance Scaër 3 E 344 20   1863-1869
	1863   => '1371736',            # Naissance Scaër 3 E 344/20/1 (1863)
	1864   => '1371737',            # Naissance Scaër 3 E 344/20/2 (1864)
	1865   => '1371738',            # Naissance Scaër 3 E 344/20/3 (1865)
	1866   => '1371739',            # Naissance Scaër 3 E 344/20/4 (1866)
	1867   => '1371740',            # Naissance Scaër 3 E 344/20/5 (1867)
	1868   => '1371741',            # Naissance Scaër 3 E 344/20/6 (1868)
	1869   => '1371742',            # Naissance Scaër 3 E 344/20/7 (1869)
    },

    '3E344_0021' => {			# Naissance Scaër 3 E 344 21   1870-1878
	1870   => '1371744',            # Naissance Scaër 3 E 344/21/1 (1870)
	1871   => '1371745',            # Naissance Scaër 3 E 344/21/2 (1871)
	1872   => '1371746',            # Naissance Scaër 3 E 344/21/3 (1872)
	1873   => '1371747',            # Naissance Scaër 3 E 344/21/4 (1873)
	1874   => '1371748',            # Naissance Scaër 3 E 344/21/5 (1874)
	1875   => '1371749',            # Naissance Scaër 3 E 344/21/6 (1875)
	1876   => '1371750',            # Naissance Scaër 3 E 344/21/7 (1876)
	1877   => '1371751',            # Naissance Scaër 3 E 344/21/8 (1877)
	1878   => '1371752',            # Naissance Scaër 3 E 344/21/9 (1878)
    },

    '3E344_0022' => {			# Naissance Scaër 3 E 344 22   1879-1885
	1879   => '1371754',            # Naissance Scaër 3 E 344/22/1 (1879)
	1880   => '1371755',            # Naissance Scaër 3 E 344/22/2 (1880)
	1881   => '1371756',            # Naissance Scaër 3 E 344/22/3 (1881)
	1882   => '1371757',            # Naissance Scaër 3 E 344/22/4 (1882)
	1883   => '1371758',            # Naissance Scaër 3 E 344/22/5 (1883)
	1884   => '1371759',            # Naissance Scaër 3 E 344/22/6 (1884)
	1885   => '1371760',            # Naissance Scaër 3 E 344/22/7 (1885)
    },

    '3E344_0023' => {			# Naissance Scaër 3 E 344 23   1886-1892
	1886   => '1371762',            # Naissance Scaër 3 E 344/23/1 (1886)
	1887   => '1371763',            # Naissance Scaër 3 E 344/23/2 (1887)
	1888   => '1371764',            # Naissance Scaër 3 E 344/23/3 (1888)
	1889   => '1371765',            # Naissance Scaër 3 E 344/23/4 (1889)
	1890   => '1371766',            # Naissance Scaër 3 E 344/23/5 (1890)
	1891   => '1371767',            # Naissance Scaër 3 E 344/23/6 (1891)
	1892   => '1371768',            # Naissance Scaër 3 E 344/23/7 (1892)
    },

    '3E344_0024' => {			# Mariage promesse de mariage Scaër 3 E 344 24   an 2 - an 10
	'AN02' => '1371825',            # Mariage promesse de mariage Scaër 3 E 344/24/1 (1793 - an II)
	# HOLE!
	'AN05' => '1371826',            # Mariage promesse de mariage Scaër 3 E 344/24/2 (an V)
	'AN06' => '1371827',            # Mariage promesse de mariage Scaër 3 E 344/24/3 (an VI)
	'AN07' => '1371828',            # Mariage promesse de mariage Scaër 3 E 344/24/4 (an VII)
	'AN08' => '1371829',            # Mariage promesse de mariage Scaër 3 E 344/24/5 (an VIII)
	'AN09' => '1371830',            # Mariage promesse de mariage Scaër 3 E 344/24/6 (an IX)
	'AN10' => '1371831',            # Mariage promesse de mariage Scaër 3 E 344/24/7 (an X)
    },

    '3E344_0025' => {			# Mariage promesse de mariage Scaër 3 E 344 25   an 11 - 1812
	'AN11' => '1371833',            # Mariage promesse de mariage Scaër 3 E 344/25/1 (an XI)
	'AN12' => '1371834',            # Mariage promesse de mariage Scaër 3 E 344/25/2 (an XII)
	'AN13' => '1371835',            # Mariage promesse de mariage Scaër 3 E 344/25/3 (an XIII)
	'AN14' => '1371836',            # Mariage promesse de mariage Scaër 3 E 344/25/4 (an XIV - 1806)
	1807   => '1371837',            # Mariage promesse de mariage Scaër 3 E 344/25/5 (1807) (contient uniquement des promesses de mariages)
	1808   => '1371838',            # Mariage promesse de mariage Scaër 3 E 344/25/6 (1808)
	1809   => '1371839',            # Mariage promesse de mariage Scaër 3 E 344/25/7 (1809)
	1810   => '1371840',            # Mariage promesse de mariage Scaër 3 E 344/25/8 (1810)
	1811   => '1371841',            # Mariage promesse de mariage Scaër 3 E 344/25/9 (1811)
	1812   => '1371842',            # Mariage promesse de mariage Scaër 3 E 344/25/10 (1812)
    },

    '3E344_0026' => {			# Mariage Scaër 3 E 344 26   1813-1822
	1813   => '1371844',            # Mariage Scaër 3 E 344/26/1 (1813)
	1814   => '1371845',            # Mariage Scaër 3 E 344/26/2 (1814)
	1815   => '1371846',            # Mariage Scaër 3 E 344/26/3 (1815)
	1816   => '1371847',            # Mariage Scaër 3 E 344/26/4 (1816)
	1817   => '1371848',            # Mariage Scaër 3 E 344/26/5 (1817)
	1818   => '1371849',            # Mariage Scaër 3 E 344/26/6 (1818)
	1819   => '1371850',            # Mariage Scaër 3 E 344/26/7 (1819)
	1820   => '1371851',            # Mariage Scaër 3 E 344/26/8 (1820)
	1821   => '1371852',            # Mariage Scaër 3 E 344/26/9 (1821)
	1822   => '1371853',            # Mariage Scaër 3 E 344/26/10 (1822)
    },

    '3E344_0027' => {			# Mariage Scaër 3 E 344 27   1823-1829
	1823   => '1371855',            # Mariage Scaër 3 E 344/27/1 (1823)
	1824   => '1371856',            # Mariage Scaër 3 E 344/27/2 (1824)
	1825   => '1371857',            # Mariage Scaër 3 E 344/27/3 (1825)
	1826   => '1371858',            # Mariage Scaër 3 E 344/27/4 (1826)
	1827   => '1371859',            # Mariage Scaër 3 E 344/27/5 (1827)
	1828   => '1371860',            # Mariage Scaër 3 E 344/27/6 (1828)
	1829   => '1371861',            # Mariage Scaër 3 E 344/27/7 (1829)
    },

    '3E344_0028' => {			# Mariage Scaër 3 E 344 28   1833-1842
	1833   => '1371866',            # Mariage Scaër 3 E 344/28/1 (1833)
	1834   => '1371867',            # Mariage Scaër 3 E 344/28/2 (1834)
	1835   => '1371868',            # Mariage Scaër 3 E 344/28/3 (1835)
	1836   => '1371869',            # Mariage Scaër 3 E 344/28/4 (1836)
	1837   => '1371870',            # Mariage Scaër 3 E 344/28/5 (1837)
	1838   => '1371871',            # Mariage Scaër 3 E 344/28/6 (1838)
	1839   => '1371872',            # Mariage Scaër 3 E 344/28/7 (1839)
	1840   => '1371873',            # Mariage Scaër 3 E 344/28/8 (1840)
	1841   => '1371874',            # Mariage Scaër 3 E 344/28/9 (1841)
	1842   => '1371875',            # Mariage Scaër 3 E 344/28/10 (1842)
    },

    '3E344_0029' => {			# Mariage Scaër 3 E 344 29   1843-1852
	1843   => '1371877',            # Mariage Scaër 3 E 344/29/1 (1843)
	1844   => '1371878',            # Mariage Scaër 3 E 344/29/2 (1844)
	1845   => '1371879',            # Mariage Scaër 3 E 344/29/3 (1845)
	1846   => '1371880',            # Mariage Scaër 3 E 344/29/4 (1846)
	1847   => '1371881',            # Mariage Scaër 3 E 344/29/5 (1847)
	1848   => '1371882',            # Mariage Scaër 3 E 344/29/6 (1848)
	1849   => '1371883',            # Mariage Scaër 3 E 344/29/7 (1849)
	1850   => '1371884',            # Mariage Scaër 3 E 344/29/8 (1850)
	1851   => '1371885',            # Mariage Scaër 3 E 344/29/9 (1851)
	1852   => '1371886',            # Mariage Scaër 3 E 344/29/10 (1852)
    },

    '3E344_0030' => {			# Mariage Scaër 3 E 344 30   1853-1862
	1853   => '1371888',            # Mariage Scaër 3 E 344/30/1 (1853)
	1854   => '1371889',            # Mariage Scaër 3 E 344/30/2 (1854)
	1855   => '1371890',            # Mariage Scaër 3 E 344/30/3 (1855)
	1856   => '1371891',            # Mariage Scaër 3 E 344/30/4 (1856)
	1857   => '1371892',            # Mariage Scaër 3 E 344/30/5 (1857)
	1858   => '1371893',            # Mariage Scaër 3 E 344/30/6 (1858)
	1859   => '1371894',            # Mariage Scaër 3 E 344/30/7 (1859)
	1860   => '1371895',            # Mariage Scaër 3 E 344/30/8 (1860)
	1861   => '1371896',            # Mariage Scaër 3 E 344/30/9 (1861)
	1862   => '1371897',            # Mariage Scaër 3 E 344/30/10 (1862)
    },

    '3E344_0031' => {			# Mariage Scaër 3 E 344 31   1863-1869
	1863   => '1371899',            # Mariage Scaër 3 E 344/31/1 (1863)
	1864   => '1371900',            # Mariage Scaër 3 E 344/31/2 (1864)
	1865   => '1371901',            # Mariage Scaër 3 E 344/31/3 (1865)
	1866   => '1371902',            # Mariage Scaër 3 E 344/31/4 (1866)
	1867   => '1371903',            # Mariage Scaër 3 E 344/31/5 (1867)
	1868   => '1371904',            # Mariage Scaër 3 E 344/31/6 (1868)
	1869   => '1371905',            # Mariage Scaër 3 E 344/31/7 (1869)
    },

    '3E344_0032' => {			# Mariage Scaër 3 E 344 32   1870-1881
	1870   => '1371907',            # Mariage Scaër 3 E 344/32/1 (1870)
	1871   => '1371908',            # Mariage Scaër 3 E 344/32/2 (1871)
	1872   => '1371909',            # Mariage Scaër 3 E 344/32/3 (1872)
	1873   => '1371910',            # Mariage Scaër 3 E 344/32/4 (1873)
	1874   => '1371911',            # Mariage Scaër 3 E 344/32/5 (1874)
	1875   => '1371912',            # Mariage Scaër 3 E 344/32/6 (1875)
	1876   => '1371913',            # Mariage Scaër 3 E 344/32/7 (1876)
	1877   => '1371914',            # Mariage Scaër 3 E 344/32/8 (1877)
	1878   => '1371915',            # Mariage Scaër 3 E 344/32/9 (1878)
	1879   => '1371916',            # Mariage Scaër 3 E 344/32/10 (1879)
	1880   => '1371917',            # Mariage Scaër 3 E 344/32/11 (1880)
	1881   => '1371918',            # Mariage Scaër 3 E 344/32/12 (1881)
    },

    '3E344_0033' => {			# Mariage Scaër 3 E 344 33   1882-1891
	1882   => '1371920',            # Mariage Scaër 3 E 344/33/1 (1882)
	1883   => '1371921',            # Mariage Scaër 3 E 344/33/2 (1883)
	1884   => '1371922',            # Mariage Scaër 3 E 344/33/3 (1884)
	1885   => '1371923',            # Mariage Scaër 3 E 344/33/4 (1885)
	1886   => '1371924',            # Mariage Scaër 3 E 344/33/5 (1886)
	1887   => '1371925',            # Mariage Scaër 3 E 344/33/6 (1887)
	1888   => '1371926',            # Mariage Scaër 3 E 344/33/7 (1888)
	1889   => '1371927',            # Mariage Scaër 3 E 344/33/8 (1889)
	1890   => '1371928',            # Mariage Scaër 3 E 344/33/9 (1890)
	1891   => '1371929',            # Mariage Scaër 3 E 344/33/10 (1891)
    },

    '3E344_0034' => {			# Décès Scaër 3 E 344 34   AN06-AN06
	'AN02' => '1371985',            # Décès Scaër 3 E 344/34/1 (1793 - an II)
	'AN03' => '1371986',            # Décès Scaër 3 E 344/34/2 (an III)
	'AN04' => '1371987',            # Décès Scaër 3 E 344/34/3 (an IV)
	'AN05' => '1371988',            # Décès Scaër 3 E 344/34/4 (an V)
	'AN06' => '1371989',            # Décès Scaër 3 E 344/34/5 (an VI)
	'AN07' => '1371990',            # Décès Scaër 3 E 344/34/6 (an VII)
	'AN08' => '1371991',            # Décès Scaër 3 E 344/34/7 (an VIII)
	'AN09' => '1371992',            # Décès Scaër 3 E 344/34/8 (an IX)
	'AN10' => '1371993',            # Décès Scaër 3 E 344/34/9 (an X)
    },

    '3E344_0035' => {			# Décès Scaër 3 E 344 35   AN11-1812
	'AN11' => '1371995',            # Décès Scaër 3 E 344/35/1 (an XI)
	'AN12' => '1371996',            # Décès Scaër 3 E 344/35/2 (an XII)
	'AN13' => '1371997',            # Décès Scaër 3 E 344/35/3 (an XIII)
	'AN14' => '1371998',            # Décès Scaër 3 E 344/35/4 (an XIV - 1806)
	1807   => '1371999',            # Décès Scaër 3 E 344/35/5 (1807)
	1808   => '1372000',            # Décès Scaër 3 E 344/35/6 (1808)
	1809   => '1372001',            # Décès Scaër 3 E 344/35/7 (1809)
	1810   => '1372002',            # Décès Scaër 3 E 344/35/8 (1810)
	1811   => '1372003',            # Décès Scaër 3 E 344/35/9 (1811)
	1812   => '1372004',            # Décès Scaër 3 E 344/35/10 (1812)
    },

    '3E344_0036' => {			# Décès Scaër 3 E 344 36   1813-1817
	1813   => '1372006',            # Décès Scaër 3 E 344/36/1 (1813)
	1814   => '1372007',            # Décès Scaër 3 E 344/36/2 (1814)
	1815   => '1372008',            # Décès Scaër 3 E 344/36/3 (1815)
	1816   => '1372009',            # Décès Scaër 3 E 344/36/4 (1816)
	1817   => '1372010',            # Décès Scaër 3 E 344/36/5 (1817)
    },

    '3E344_0037' => {			# Décès Scaër 3 E 344 37   1823-1832
	1823   => '1372017',            # Décès Scaër 3 E 344/37/1 (1823)
	1824   => '1372018',            # Décès Scaër 3 E 344/37/2 (1824)
	1825   => '1372019',            # Décès Scaër 3 E 344/37/3 (1825)
	1826   => '1372020',            # Décès Scaër 3 E 344/37/4 (1826)
	1827   => '1372021',            # Décès Scaër 3 E 344/37/5 (1827)
	1828   => '1372022',            # Décès Scaër 3 E 344/37/6 (1828)
	1829   => '1372023',            # Décès Scaër 3 E 344/37/7 (1829)
	1830   => '1372024',            # Décès Scaër 3 E 344/37/8 (1830)
	1831   => '1372025',            # Décès Scaër 3 E 344/37/9 (1831)
	1832   => '1372026',            # Décès Scaër 3 E 344/37/10 (1832)
    },

    '3E344_0038' => {			# Décès Scaër 3 E 344 38   1833-1842
	1833   => '1372028',            # Décès Scaër 3 E 344/38/1 (1833)
	1834   => '1372029',            # Décès Scaër 3 E 344/38/2 (1834)
	1835   => '1372030',            # Décès Scaër 3 E 344/38/3 (1835)
	1836   => '1372031',            # Décès Scaër 3 E 344/38/4 (1836)
	1837   => '1372032',            # Décès Scaër 3 E 344/38/5 (1837)
	1838   => '1372033',            # Décès Scaër 3 E 344/38/6 (1838)
	1839   => '1372034',            # Décès Scaër 3 E 344/38/7 (1839)
	1840   => '1372035',            # Décès Scaër 3 E 344/38/8 (1840)
	1841   => '1372036',            # Décès Scaër 3 E 344/38/9 (1841)
	1842   => '1372037',            # Décès Scaër 3 E 344/38/10 (1842)
    },

    '3E344_0039' => {			# Décès Scaër 3 E 344 39   1843-1852
	1843   => '1372039',            # Décès Scaër 3 E 344/39/1 (1843)
	1844   => '1372040',            # Décès Scaër 3 E 344/39/2 (1844)
	1845   => '1372041',            # Décès Scaër 3 E 344/39/3 (1845)
	1846   => '1372042',            # Décès Scaër 3 E 344/39/4 (1846)
	1847   => '1372043',            # Décès Scaër 3 E 344/39/5 (1847)
	1848   => '1372044',            # Décès Scaër 3 E 344/39/6 (1848)
	1849   => '1372045',            # Décès Scaër 3 E 344/39/7 (1849)
	1850   => '1372046',            # Décès Scaër 3 E 344/39/8 (1850)
	1851   => '1372047',            # Décès Scaër 3 E 344/39/9 (1851)
	1852   => '1372048',            # Décès Scaër 3 E 344/39/10 (1852)
    },

    '3E344_0040' => {			# Décès Scaër 3 E 344 40   1853-1862
	1853   => '1372050',            # Décès Scaër 3 E 344/40/1 (1853)
	1854   => '1372051',            # Décès Scaër 3 E 344/40/2 (1854)
	1855   => '1372052',            # Décès Scaër 3 E 344/40/3 (1855)
	1856   => '1372053',            # Décès Scaër 3 E 344/40/4 (1856)
	1857   => '1372054',            # Décès Scaër 3 E 344/40/5 (1857)
	1858   => '1372055',            # Décès Scaër 3 E 344/40/6 (1858)
	1859   => '1372056',            # Décès Scaër 3 E 344/40/7 (1859)
	1860   => '1372057',            # Décès Scaër 3 E 344/40/8 (1860)
	1861   => '1372058',            # Décès Scaër 3 E 344/40/9 (1861)
	1862   => '1372059',            # Décès Scaër 3 E 344/40/10 (1862)
    },

    '3E344_0041' => {			# Décès Scaër 3 E 344 41   1863-1869
	1863   => '1372061',            # Décès Scaër 3 E 344/41/1 (1863)
	1864   => '1372062',            # Décès Scaër 3 E 344/41/2 (1864)
	1865   => '1372063',            # Décès Scaër 3 E 344/41/3 (1865)
	1866   => '1372064',            # Décès Scaër 3 E 344/41/4 (1866)
	1867   => '1372065',            # Décès Scaër 3 E 344/41/5 (1867)
	1868   => '1372066',            # Décès Scaër 3 E 344/41/6 (1868)
	1869   => '1372067',            # Décès Scaër 3 E 344/41/7 (1869)
    },

    '3E344_0042' => {			# Décès Scaër 3 E 344 42   1870-1878
	1870   => '1372069',            # Décès Scaër 3 E 344/42/1 (1870)
	1871   => '1372070',            # Décès Scaër 3 E 344/42/2 (1871)
	1872   => '1372071',            # Décès Scaër 3 E 344/42/3 (1872)
	1873   => '1372072',            # Décès Scaër 3 E 344/42/4 (1873)
	1874   => '1372073',            # Décès Scaër 3 E 344/42/5 (1874)
	1875   => '1372074',            # Décès Scaër 3 E 344/42/6 (1875)
	1876   => '1372075',            # Décès Scaër 3 E 344/42/7 (1876)
	1877   => '1372076',            # Décès Scaër 3 E 344/42/8 (1877)
	1878   => '1372077',            # Décès Scaër 3 E 344/42/9 (1878)
    },

    '3E344_0043' => {			# Décès Scaër 3 E 344 43   1879-1887
	1879   => '1372079',            # Décès Scaër 3 E 344/43/1 (1879)
	1880   => '1372080',            # Décès Scaër 3 E 344/43/2 (1880)
	1881   => '1372081',            # Décès Scaër 3 E 344/43/3 (1881)
	1882   => '1372082',            # Décès Scaër 3 E 344/43/4 (1882)
	1883   => '1372083',            # Décès Scaër 3 E 344/43/5 (1883)
	1884   => '1372084',            # Décès Scaër 3 E 344/43/6 (1884)
	1885   => '1372085',            # Décès Scaër 3 E 344/43/7 (1885)
	1886   => '1372086',            # Décès Scaër 3 E 344/43/8 (1886)
	1887   => '1372087',            # Décès Scaër 3 E 344/43/9 (1887)
    },

    '3E344_0044' => {			# Naissance Scaër 3 E 344 44   1893-1899
	1893   => '1371770',            # Naissance Scaër 3 E 344/44/1 (1893)
	1894   => '1371771',            # Naissance Scaër 3 E 344/44/2 (1894)
	1895   => '1371772',            # Naissance Scaër 3 E 344/44/3 (1895)
	1896   => '1371773',            # Naissance Scaër 3 E 344/44/4 (1896)
	1897   => '1371774',            # Naissance Scaër 3 E 344/44/5 (1897)
	1898   => '1371775',            # Naissance Scaër 3 E 344/44/6 (1898)
	1899   => '1371776',            # Naissance Scaër 3 E 344/44/7 (1899)
    },

    '3E344_0045' => {			# Mariage Scaër 3 E 344 45   1892-1901
	1892   => '1371931',            # Mariage Scaër 3 E 344/45/1 (1892)
	1893   => '1371932',            # Mariage Scaër 3 E 344/45/2 (1893)
	1894   => '1371933',            # Mariage Scaër 3 E 344/45/3 (1894)
	1895   => '1371934',            # Mariage Scaër 3 E 344/45/4 (1895)
	1896   => '1371935',            # Mariage Scaër 3 E 344/45/5 (1896)
	1897   => '1371936',            # Mariage Scaër 3 E 344/45/6 (1897)
	1898   => '1371937',            # Mariage Scaër 3 E 344/45/7 (1898)
	1899   => '1371938',            # Mariage Scaër 3 E 344/45/8 (1899)
	1900   => '1371939',            # Mariage Scaër 3 E 344/45/9 (1900)
	1901   => '1371940',            # Mariage Scaër 3 E 344/45/10 (1901)
    },

    '3E344_0046' => {			# Décès Scaër 3 E 344 46   1888-1897
	1888   => '1372089',            # Décès Scaër 3 E 344/46/1 (1888)
	1889   => '1372090',            # Décès Scaër 3 E 344/46/2 (1889)
	1890   => '1372091',            # Décès Scaër 3 E 344/46/3 (1890)
	1891   => '1372092',            # Décès Scaër 3 E 344/46/4 (1891)
	1892   => '1372093',            # Décès Scaër 3 E 344/46/5 (1892)
	1893   => '1372094',            # Décès Scaër 3 E 344/46/6 (1893)
	1894   => '1372095',            # Décès Scaër 3 E 344/46/7 (1894)
	1895   => '1372096',            # Décès Scaër 3 E 344/46/8 (1895)
	1896   => '1372097',            # Décès Scaër 3 E 344/46/9 (1896)
	1897   => '1372098',            # Décès Scaër 3 E 344/46/10 (1897)
    },

    '3E344_0047' => {			# Naissance Scaër 3 E 344 47   1900-1904
	1900   => '1371778',            # Naissance Scaër 3 E 344/47/1 (1900)
	1901   => '1371779',            # Naissance Scaër 3 E 344/47/2 (1901)
	1902   => '1371780',            # Naissance Scaër 3 E 344/47/3 (1902)
	1903   => '1371781',            # Naissance Scaër 3 E 344/47/4 (1903)
	1904   => '1371782',            # Naissance Scaër 3 E 344/47/5 (1904)
    },

    '3E344_0048' => {			# Décès Scaër 3 E 344 48   1898-1905
	1898   => '1372100',            # Décès Scaër 3 E 344/48/1 (1898)
	1899   => '1372101',            # Décès Scaër 3 E 344/48/2 (1899)
	1900   => '1372102',            # Décès Scaër 3 E 344/48/3 (1900)
	1901   => '1372103',            # Décès Scaër 3 E 344/48/4 (1901)
	1902   => '1372104',            # Décès Scaër 3 E 344/48/5 (1902)
	1903   => '1372105',            # Décès Scaër 3 E 344/48/6 (1903)
	1904   => '1372106',            # Décès Scaër 3 E 344/48/7 (1904)
	1905   => '1372107',            # Décès Scaër 3 E 344/48/8 (1905)
    },

    '3E344_0049' => {			# Naissance Scaër 3 E 344 49   1905-1909
	1905   => '1371784',            # Naissance Scaër 3 E 344/49/1 (1905)
	1906   => '1371785',            # Naissance Scaër 3 E 344/49/2 (1906)
	1907   => '1371786',            # Naissance Scaër 3 E 344/49/3 (1907)
	1908   => '1371787',            # Naissance Scaër 3 E 344/49/4 (1908)
	1909   => '1371788',            # Naissance Scaër 3 E 344/49/5 (1909)
    },

    '3E344_0050' => {			# Mariage Scaër 3 E 344 50   1902-1909
	1902   => '1371942',            # Mariage Scaër 3 E 344/50/1 (1902)
	1903   => '1371943',            # Mariage Scaër 3 E 344/50/2 (1903)
	1904   => '1371944',            # Mariage Scaër 3 E 344/50/3 (1904)
	1905   => '1371945',            # Mariage Scaër 3 E 344/50/4 (1905)
	1906   => '1371946',            # Mariage Scaër 3 E 344/50/5 (1906)
	1907   => '1371947',            # Mariage Scaër 3 E 344/50/6 (1907)
	1908   => '1371948',            # Mariage Scaër 3 E 344/50/7 (1908)
	1909   => '1371949',            # Mariage Scaër 3 E 344/50/8 (1909)
    },

    '3E344_0051' => {			# Naissance Scaër 3 E 344 51   1910-1913
	1910   => '1371790',            # Naissance Scaër 3 E 344/51/1 (1910)
	1911   => '1371791',            # Naissance Scaër 3 E 344/51/2 (1911)
	1912   => '1371792',            # Naissance Scaër 3 E 344/51/3 (1912)
	1913   => '1371793',            # Naissance Scaër 3 E 344/51/4 (1913)
    },

    '3E344_0052' => {			# Décès Scaër 3 E 344 52   1906-1912
	1906   => '1372109',            # Décès Scaër 3 E 344/52/1 (1906)
	1907   => '1372110',            # Décès Scaër 3 E 344/52/2 (1907)
	1908   => '1372111',            # Décès Scaër 3 E 344/52/3 (1908)
	1909   => '1372112',            # Décès Scaër 3 E 344/52/4 (1909)
	1910   => '1372113',            # Décès Scaër 3 E 344/52/5 (1910)
	1911   => '1372114',            # Décès Scaër 3 E 344/52/6 (1911)
	1912   => '1372115',            # Décès Scaër 3 E 344/52/7 (1912)
    },

    '3E344_0053' => {			# Naissance Scaër 3 E 344 53   1914-1921
	1914   => '1371795',            # Naissance Scaër 3 E 344/53/1 (1914)
	1915   => '1371796',            # Naissance Scaër 3 E 344/53/2 (1915)
	1916   => '1371797',            # Naissance Scaër 3 E 344/53/3 (1916)
	1917   => '1371798',            # Naissance Scaër 3 E 344/53/4 (1917)
	1918   => '1371799',            # Naissance Scaër 3 E 344/53/5 (1918)
	1919   => '1371800',            # Naissance Scaër 3 E 344/53/6 (1919)
	1920   => '1371801',            # Naissance Scaër 3 E 344/53/7 (1920)
	1921   => '1371802',            # Naissance Scaër 3 E 344/53/8 (1921)
    },

    '3E344_0054' => {			# Naissance Scaër 3 E 344 54   1922-1925
	1922   => '1371804',            # Naissance Scaër 3 E 344/54/1 (1922)
	1923   => '1371805',            # Naissance Scaër 3 E 344/54/2 (1923)
	1924   => '1371806',            # Naissance Scaër 3 E 344/54/3 (1924)
	1925   => '1371807',            # Naissance Scaër 3 E 344/54/4 (1925)
    },

    '3E344_0056' => {			# Mariage Scaër 3 E 344 56   1910-1918
	1910   => '1371951',            # Mariage Scaër 3 E 344/56/1 (1910)
	1911   => '1371952',            # Mariage Scaër 3 E 344/56/2 (1911)
	1912   => '1371953',            # Mariage Scaër 3 E 344/56/3 (1912)
	1913   => '1371954',            # Mariage Scaër 3 E 344/56/4 (1913)
	1914   => '1371955',            # Mariage Scaër 3 E 344/56/5 (1914)
	1915   => '1371956',            # Mariage Scaër 3 E 344/56/6 (1915)
	1916   => '1371957',            # Mariage Scaër 3 E 344/56/7 (1916)
	1917   => '1371958',            # Mariage Scaër 3 E 344/56/8 (1917)
	1918   => '1371959',            # Mariage Scaër 3 E 344/56/9 (1918)
    },

    '3E344_0057' => {			# Mariage Scaër 3 E 344 57   1919-1924
	1919   => '1371961',            # Mariage Scaër 3 E 344/57/1 (1919)
	1920   => '1371962',            # Mariage Scaër 3 E 344/57/2 (1920)
	1921   => '1371963',            # Mariage Scaër 3 E 344/57/3 (1921)
	1922   => '1371964',            # Mariage Scaër 3 E 344/57/4 (1922)
	1923   => '1371965',            # Mariage Scaër 3 E 344/57/5 (1923)
	1924   => '1371966',            # Mariage Scaër 3 E 344/57/6 (1924)
    },

    '3E344_0058' => '1371968',            # Mariage Scaër 3 E 344/58/1 (1925)
    '3E344_0060' => {			# Décès Scaër 3 E 344 60   1913-1919
	1913   => '1372117',            # Décès Scaër 3 E 344/60/1 (1913)
	1914   => '1372118',            # Décès Scaër 3 E 344/60/2 (1914)
	1915   => '1372119',            # Décès Scaër 3 E 344/60/3 (1915)
	1916   => '1372120',            # Décès Scaër 3 E 344/60/4 (1916)
	1917   => '1372121',            # Décès Scaër 3 E 344/60/5 (1917)
	1918   => '1372122',            # Décès Scaër 3 E 344/60/6 (1918)
	1919   => '1372123',            # Décès Scaër 3 E 344/60/7 (1919)
    },

    '3E344_0061' => {			# Décès Scaër 3 E 344 61   1920-1926
	1920   => '1372125',            # Décès Scaër 3 E 344/61/1 (1920)
	1921   => '1372126',            # Décès Scaër 3 E 344/61/2 (1921)
	1922   => '1372127',            # Décès Scaër 3 E 344/61/3 (1922)
	1923   => '1372128',            # Décès Scaër 3 E 344/61/4 (1923)
	1924   => '1372129',            # Décès Scaër 3 E 344/61/5 (1924)
	1925   => '1372130',            # Décès Scaër 3 E 344/61/6 (1925)
	1926   => '1372131',            # Décès Scaër 3 E 344/61/7 (1926)
    },

    '3E344_0062' => {			# Décès Scaër 3 E 344 62   1927-1936
	1927   => '1372133',            # Décès Scaër 3 E 344/62/1 (1927)
	1928   => '1372134',            # Décès Scaër 3 E 344/62/2 (1928)
	1929   => '1372135',            # Décès Scaër 3 E 344/62/3 (1929)
	1930   => '1372136',            # Décès Scaër 3 E 344/62/4 (1930)
	1931   => '1372137',            # Décès Scaër 3 E 344/62/5 (1931)
	1932   => '1372138',            # Décès Scaër 3 E 344/62/6 (1932)
	1933   => '1372139',            # Décès Scaër 3 E 344/62/7 (1933)
	1934   => '1372140',            # Décès Scaër 3 E 344/62/8 (1934)
	1935   => '1372141',            # Décès Scaër 3 E 344/62/9 (1935)
	1936   => '1372142',            # Décès Scaër 3 E 344/62/10 (1936)
    },

    # Spezet
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
    # Normalize some URLs:
    s!&amp;!&!g;
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
	my ($year) = /s=FRAD029_[^_]+_[^_]+_[^_]+_([A0-9][N0-9]\d\d)_001.jpg/;
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
