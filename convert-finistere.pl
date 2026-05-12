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
#
# See https://patrimoines-archives.morbihan.fr/fileadmin/Archives/actualites/Fonds_d_archives/IR/FRAD056_00000001R.pdf for a list of all matricule registers

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
    # BMS : Collection communale (Baptêmes, mariages, sépultures):
    #============================
    # TODO: Fix handling of BMS IDs for "Collection communale"

    # BMS Bannalec
    '1003EDEPOT_002' => '644271.1463519',            # BMS Bannalec 1003 E-dépôt 2 (1684-1692)
    '1003EDEPOT_003' => '644272.1463520',            # BMS Bannalec 1003 E-dépôt 3 (1708-1724)
    '1003EDEPOT_004' => '644273.1463521',            # BMS Bannalec 1003 E-dépôt 4 (1725-1738)
    '1003EDEPOT_005' => '644274.1463522',            # BMS Bannalec 1003 E-dépôt 5 (1739-1750)
    '1003EDEPOT_006' => '644275.1463524',            # BMS Bannalec 1003 E-dépôt 6 (1751-1766, 1768.)
    '1003EDEPOT_009' => '644278.1463528',            # BMS Bannalec 1003 E-dépôt 9 (1751-1779)
    '1003EDEPOT_007' => '644276.1463525',            # BMS Bannalec 1003 E-dépôt 7 (1769-1781.)
    '1003EDEPOT_010' => '644279.1463529',            # BMS Bannalec 1003 E-dépôt 10 (1780-1792)
    '1003EDEPOT_001' => '644270.1463518',            # BMS Bannalec 1003 E-dépôt 1 (Baptêmes (1621-1632). Mariages (1648-1662). Baptêmes, mariages et sépultures (1674, 1676-1691).)

    # BMS Beuzec-Conq
    '1008EDEPOT_005' => '1463963',            # BMS Beuzec-Conq 1008 E DEPOT 5 (Baptêmes, mariages et sépultures.)
    '1008EDEPOT_007' => '1463965',            # BMS Beuzec-Conq 1008 E DEPOT 7 (Baptêmes et mariages.)
    '1008EDEPOT_008' => '1463966',            # BMS Beuzec-Conq 1008 E DEPOT 8 (Baptêmes et mariages et sépultures.)

    '1029EDEPOT_001' => '644418.1465136', # 1029 E-dépôt 1 (Baptêmes et mariages (1783-1786, 1790-1792). Sépultures (1789-1792). Naissances (1793-an VI, an VIII-1820).)

    # BMS Carhaix
    '1024EDEPOT_002' => '1464954',            # BMS Carhaix 1024 E DEPOT 2 (1651-1653)
    '1024EDEPOT_003' => '1464955',            # BMS Carhaix 1024 E DEPOT 3 (1654-1660)
    '1024EDEPOT_004' => '1464956',            # BMS Carhaix 1024 E DEPOT 4 (1661-1670)
    '1024EDEPOT_005' => '1464957',            # BMS Carhaix 1024 E DEPOT 5 (1671-1677)
    '1024EDEPOT_006' => '1464958',            # BMS Carhaix 1024 E DEPOT 6 (1678-1680)
    '1024EDEPOT_007' => '1464959',            # BMS Carhaix 1024 E DEPOT 7 (1681-1683)
    '1024EDEPOT_008' => '1464960',            # BMS Carhaix 1024 E DEPOT 8 (1684-1690)
    '1024EDEPOT_009' => '1464961',            # BMS Carhaix 1024 E DEPOT 9 (1691-1692)
    '1024EDEPOT_010' => '1464962',            # BMS Carhaix 1024 E DEPOT 10 (1693-1717)
    '1024EDEPOT_011' => '1464963',            # BMS Carhaix 1024 E DEPOT 11 (1718-1732)
    '1024EDEPOT_012' => '1464964',            # BMS Carhaix 1024 E DEPOT 12 (1733-1738)
    '1024EDEPOT_013' => '1464965',            # BMS Carhaix 1024 E DEPOT 13 (1739-1745)
    '1024EDEPOT_014' => '1464966',            # BMS Carhaix 1024 E DEPOT 14 (1746-1760)
    '1024EDEPOT_015' => '1464967',            # BMS Carhaix 1024 E DEPOT 15 (1761-1776)
    '1024EDEPOT_016' => '1464968',            # BMS Carhaix 1024 E DEPOT 16 (1777-1787)
    '1024EDEPOT_018' => '1464972',            # BMS Carhaix 1024 E DEPOT 18 (1788-1793)
    # Techniquement, c'est du NMD et plus du BMS:
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

    # Châteauneuf-du-Faou
    '1027EDEPOT_012' => '1465024',            # Registre paroissial registre baptême mariage sépulture administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance Châteauneuf-du-Faou 1027 E DEPOT 12 (Sépultures)
    '1027EDEPOT_003' => '644405.1465026',     # Table décennale administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance table des baptêmes table des naissances Châteauneuf-du-Faou 1027 E-dépôt 3 (Tables des baptêmes, tables des naissances, tables décennales)
    '1027EDEPOT_013' => '1465028',            # Table décennale administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance Châteauneuf-du-Faou 1027 E DEPOT 13 (Tables décennales)

    # BMS Concarneau
    '1040 E DEPOT' => '1465702',            # Table décennale administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance Concarneau 1040 E DEPOT 9 (Tables décennales)
    '1091EDEPOT_005' => '644938.1469168',            # Registre paroissial registre baptême mariage sépulture administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance naissance Landeleau 1091 E-dépôt 5 (Baptêmes, mariages, naissances)
    '1091EDEPOT_003' => '644936.1469170',            # Registre naissance mariage décès administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance baptême mariage Landeleau 1091 E-dépôt 3 (Baptêmes, mariages, tables décennales)
    '1109 E DEPOT' => '645008.1470239',            # Registre paroissial registre baptême mariage sépulture administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance naissance Laz 1109 E-dépôt 6 (Sépultures, naissances)

    # BMS Plonévez-du-Faou
    '1164EDEPOT_002' => '645226.1473981',            # B   Plonévez-du-Faou 1164 E-dépôt 2 (Baptêmes.)
    '1164EDEPOT_008' => '645232.1473987',            # BM  Plonévez-du-Faou 1164 E-dépôt 8 (Baptêmes, mariages.)
    '1164EDEPOT_009' => '645233.1473988',            # Sépultures Plonévez-du-Faou 1164 E-dépôt 9 (Sépultures.)
    '1164EDEPOT_011' => '645235.1473990',            # BMS Plonévez-du-Faou 1164 E-dépôt 11 (Baptêmes, mariages, sépultures.)

    # BMS Poullaouen
    '1211EDEPOT_003' => '645498.1477662',            # Registre paroissial registre baptême mariage sépulture administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance Poullaouen 1211 E-dépôt 3 (1711-1741)
    '1211EDEPOT_001' => '645496.1477660',            # Registre paroissial registre baptême mariage sépulture administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance Poullaouen 1211 E-dépôt 1 (Baptêmes (1548-1568, 1619-1683). Baptêmes, mariages, sépultures (1666-1670))
    '1211EDEPOT_005' => '645500.1477664',            # Registre paroissial registre baptême mariage sépulture administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance Poullaouen 1211 E-dépôt 5 (Baptêmes et mariages (1789-1792). Sépultures (1753-1787, 1791-1792).)
    '1211EDEPOT_004' => '645499.1477663',            # Registre paroissial registre baptême mariage sépulture administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance Poullaouen 1211 E-dépôt 4 (Baptêmes, mariages, sépultures (1742-1752). Baptêmes et mariages (1762-1788).)

    # BMS Saint-Hernin
    '1237EDEPOT_001' => '645576.1478932',            # BMS Saint-Hernin 1237 E-dépôt 1 (Baptêmes, mariages, sépultures)
    '1237EDEPOT_002' => '645577.1478933',            # BMS Saint-Hernin 1237 E-dépôt 2 (Baptêmes, mariages)
    '1237EDEPOT_003' => '645578.1478934',            # BMS Saint-Hernin 1237 E-dépôt 3 (Sépultures)

    # BMS Saint-Yvi
    '1261EDEPOT_009' => '1480039',            # Registre table administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance Saint-Yvi 1261 E DEPOT 9 (Décès)
    '1261EDEPOT_005' => '645681.1480034',            # Registre table administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance Saint-Yvi 1261 E-dépôt 5 (Décès)
    '1261EDEPOT_008' => '1480038',            # Registre table administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance Saint-Yvi 1261 E DEPOT 8 (Mariages)
    '1261EDEPOT_007' => '1480037',            # Registre table administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance Saint-Yvi 1261 E DEPOT 7 (Naissances)
    '1261EDEPOT_004' => '645680.1480033',            # Registre table administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance Saint-Yvi 1261 E-dépôt 4 (Naissances, mariages)

    # BMS Spézet
    # I'd to manually add the "_0X" prefix:
    '1267EDEPOT_001_02' => '1480477',            # BMS Spézet 1267 E DEPOT 1/2 (1597-1611)
    '1267EDEPOT_001_03' => '1480478',            # BMS Spézet 1267 E DEPOT 1/3 (1617-1635)
    '1267EDEPOT_001_04' => '1480479',            # BMS Spézet 1267 E DEPOT 1/4 (1636- 10 décembre 1645)
    '1267EDEPOT_001_05' => '1480480',            # BMS Spézet  E DEPOT 1/5 (12 décembre 1645- 1648)
    '1267EDEPOT_002_01' => '1480496',            # BMS Spézet 1267 E DEPOT 2/1 (Baptêmes (3 août 1648- 1668))
    '1267EDEPOT_002_02' => '1480497',            # BMS Spézet 1267 E DEPOT 2/2 (Mariages (1597- 1620))
    '1267EDEPOT_002_03' => '1480498',            # BMS Spézet 1267 E DEPOT 2/3 (Mariages (1637-1646))
    '1267EDEPOT_003_01' => '1480483',            # BMS Spézet 1267 E DEPOT 3/1 (Baptêmes (18 mars 1669- 3 mars 1671))
    '1267EDEPOT_003_02' => '1480484',            # BMS Spézet 1267 E DEPOT 3/2 (Baptêmes, mariages et sépultures (1675-1684))
    '1267EDEPOT_003_03' => '1480485',            # BMS Spézet 1267 E DEPOT 3/3 (Baptêmes, mariages et sépultures (1685-1692))
    '1267EDEPOT_004_01' => '1480487',            # BMS Spézet 1267 E DEPOT 4/1 (1693-1709)
    '1267EDEPOT_004_02' => '1480488',            # BMS Spézet 1267 E DEPOT 4/2 (1710-1720)
    '1267EDEPOT_005_01' => '1480490',            # BMS Spézet 1267 E DEPOT 5/1 (1721-1727)
    '1267EDEPOT_005_02' => '1480491',            # BMS Spézet 1267 E DEPOT 5/2 (1728-1743)

    # BMS Tourc'h
    '1270EDEPOT_003' => '1480813',            # Registre naissance mariage décès administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance Tourc'h 1270 E DEPOT 3/1 (1793-an XI)
    '1270EDEPOT_004' => '1480818',            # Registre naissance mariage décès administration administration générale structure administrative administration communale collectivité locale commune société population état civil décès mariage naissance Tourc'h 1270 E DEPOT 4/1 (Publications des bans (1793 -an IV). Mariages (1793-an III, an V-An XI))

    # BMS Morlaix
    '1373EDEPOT_001' => '1472620',            # BMS Morlaix 1373 E DEPOT 1/1 (1594 -1645)
    '1373EDEPOT_001' => '1472621',            # BMS Morlaix 1373 E DEPOT 1/2 (1646 au 3 novembre 1672)
    '1373EDEPOT_002' => '1472623',            # BMS Morlaix 1373 E DEPOT 2 (Mariages.)
    '1373EDEPOT_003' => '1472625',            # BMS Morlaix 1373 E DEPOT 3 (Sépultures.)
    '1373EDEPOT_004' => '1472629',            # BMS Morlaix 1373 E DEPOT 4 (8 novembre 1672-1682.)
    '1373EDEPOT_006' => '1472631',            # BMS Morlaix 1373 E DEPOT 6 (1693-1706.)
    '1373EDEPOT_007' => '1472632',            # BMS Morlaix 1373 E DEPOT 7 (1707-1720.)
    '1373EDEPOT_008' => '1472633',            # BMS Morlaix 1373 E DEPOT 8 (1721-1734.)
    '1373EDEPOT_009' => '1472634',            # BMS Morlaix 1373 E DEPOT 9 (1735-1746.)
    '1373EDEPOT_017' => '1472642',            # BMS Morlaix 1373 E DEPOT 17 (1538-1549, 1570-1581, 1582-1595 (concernerait les baptêmes de la collégiale du Mur, ce qui expliquerait le chevauchement des dates) 1587-1607, 1610-1612.)
    '1373EDEPOT_018' => '1472643',            # BMS Morlaix 1373 E DEPOT 18 (1612- 1647.)
    '1373EDEPOT_019' => '1472644',            # BMS Morlaix 1373 E DEPOT 19 (1648-1657, 1657-1668 suivi de 1587-1606.)
    '1373EDEPOT_020' => '1472646',            # BMS Morlaix 1373 E DEPOT 20 (1625-1658, 1660-1668.)
    '1373EDEPOT_021' => '1472664',            # BMS Morlaix 1373 E DEPOT 21 (1586-1606, 1657-1668.)
    '1373EDEPOT_022' => '1472648',            # BMS Morlaix 1373 E DEPOT 22 (1668-1672.)
    '1373EDEPOT_023' => '1472649',            # BMS Morlaix 1373 E DEPOT 23 (1673-1675.)
    '1373EDEPOT_027' => '1472653',            # BMS Morlaix 1373 E DEPOT 27 (1700-1709.)
    '1373EDEPOT_028' => '1472654',            # BMS Morlaix 1373 E DEPOT 28 (1710-1719.)
    '1373EDEPOT_029' => '1472655',            # BMS Morlaix 1373 E DEPOT 29 (1720-1730.)
    '1373EDEPOT_030' => '1472656',            # BMS Morlaix 1373 E DEPOT 30 (1731-1741.)
    '1373EDEPOT_038' => '1472669',            # BMS Morlaix -- Paroisse Saint-Melaine 1373 E DEPOT 38 (1592-1652.)
    '1373EDEPOT_039' => '1472670',            # BMS Morlaix -- Paroisse Saint-Melaine 1373 E DEPOT 39 (1653-1668.)
    '1373EDEPOT_040' => '1472672',            # BMS Morlaix -- Paroisse Saint-Melaine 1373 E DEPOT 40 (1602-1668.)
    '1373EDEPOT_041' => '1472691',            # BMS Morlaix -- Paroisse Saint-Melaine 1373 E DEPOT 41 (1602-1667.)
    '1373EDEPOT_042' => '1472674',            # BMS Morlaix -- Paroisse Saint-Melaine 1373 E DEPOT 42 (1669-1671.)
    '1373EDEPOT_043' => '1472675',            # BMS Morlaix -- Paroisse Saint-Melaine 1373 E DEPOT 43 (1672-1679.)
    '1373EDEPOT_046' => '1472678',            # BMS Morlaix -- Paroisse Saint-Melaine 1373 E DEPOT 46 (1697-1707.)
    '1373EDEPOT_047' => '1472679',            # BMS Morlaix -- Paroisse Saint-Melaine 1373 E DEPOT 47 (1708-1719.)
    '1373EDEPOT_048' => '1472680',            # BMS Morlaix -- Paroisse Saint-Melaine 1373 E DEPOT 48 (1720-1729.)
    '1373EDEPOT_049' => '1472681',            # BMS Morlaix -- Paroisse Saint-Melaine 1373 E DEPOT 49 (1730-1740.)

    # Registre matricule:
    #====================

    # 1880
    '1R00919' => '835377.1075601',            # Bureau de Brest n° 1 à 489. (1880)
    '1R00920' => '835378.1075602',            # Bureau de Brest n° 490 à 985. (1880)
    '1R00921' => '835379.1075603',            # Bureau de Brest n° 986 à 1478. (1880)
    '1R00922' => '835380.1075604',            # Bureau de Brest n° 1479 à 1975. (1880)
    '1R00923' => '835381.1075605',            # Bureau de Brest n° 1976 à 2473. (1880)
    '1R00924' => '835382.1075606',            # Bureau de Brest n° 2474 à 2967. (1880)
    '1R00925' => '835383.1075607',            # Bureau de Brest n° 2968 à 3042. (1880)
    '1R00927' => '1075609',                   # Bureau de Brest-Crozon n° 2051 à 2181, 2532, 2722 à 2729, 2184, 99. (1880)
    '1R00928' => '835386.1075611',            # Bureau de Quimper n° 1 à 491. (1880)
    '1R00929' => '835387.1075612',            # Bureau de Quimper n° 492 à 985. (1880)
    '1R00930' => '835388.1075613',            # Bureau de Quimper n° 986 à 1480. (1880)
    '1R00931' => '835389.1075614',            # Bureau de Quimper n° 1481 à 1978. (1880)
    '1R00932' => '835390.1075615',            # Bureau de Quimper n° 1979 à 2473. (1880)
    '1R00933' => '835391.1075616',            # Bureau de Quimper n° 2474 à 2755. (1880)
    '1R00935' => '1075618',                   # Liste matricule de la subdivision de Quimper des engagés volontaires non encore inscrits au registre matricule et des réserves étrangers à la subdivision pris au domicile. (1880)

    # 1902
    '1R01281' => '835739.1076011',            # Bureau de Brest n° 1 à 500. (1902)
    '1R01282' => '835740.1076012',            # Bureau de Brest n° 501 à 1000. (1902)
    '1R01283' => '835741.1076013',            # Bureau de Brest n° 1001 à 1500. (1902)
    '1R01284' => '835742.1076014',            # Bureau de Brest n° 1501 à 2000. (1902)
    '1R01285' => '835743.1076015',            # Bureau de Brest n° 2001 à 2500. (1902)
    '1R01286' => '835744.1076016',            # Bureau de Brest n° 2501 à 3000. (1902)
    '1R01287' => '835745.1076017',            # Bureau de Brest n° 3001 à 3500. (1902)
    '1R01288' => '835746.1076018',            # Bureau de Brest n° 3501 à 3793. (1902)
    '1R01289' => '835747.1076020',            # Bureau de Brest-Châteaulin n° 1990 à 2500. (1902)
    '1R01290' => '835748.1076021',            # Bureau de Brest-Châteaulin n° 2501 à 3082, 3865 à 3866, 3915 à 3930, 3933 à 3942, 3962 à 3963, 3966, 3969, 3976, 3982, 3983, 3995 à 3998, 4008, 4010. (1902)
    '1R01292' => '835750.1076023',            # Bureau de Quimper n° 1 à 500. (1902)
    '1R01293' => '835751.1076024',            # Bureau de Quimper n° 501 à 1000. (1902)
    '1R01294' => '835752.1076025',            # Bureau de Quimper n° 1001 à 1500. (1902)
    '1R01295' => '835753.1076026',            # Bureau de Quimper n° 1501 à 1990. (1902)
    '1R01296' => '835754.1076027',            # Bureau de Quimper n° 2870, 2880, 2890, 2897 à 2898, 2924, 2935, 2944, 2995, 2999, 3006, 3010, 3026, 3035, 3048, 3054, 3056 à 3057, 3075, 3078, 3083 à 3500. (1902)
    '1R01297' => '835755.1076028',            # Bureau de Quimper n° 3501 à 3864, 3867 à 3889, 3900 à 3914, 3931 à 3932, 3938, 3940, 3943 à 3968, 3983. (1902)
    '1R01298' => '835756.1076029',            # Bureau de Quimper n° 3969 à 3994, 3999 à 4011. (1902)

    # 1908
    '1R01390' => '835848.1076132',            # Bureau de Brest n° 1 à 500. (1908)
    '1R01391' => '835849.1076133',            # Bureau de Brest n° 501 à 1000. (1908)
    '1R01392' => '835850.1076134',            # Bureau de Brest n° 1001 à 1500. (1908)
    '1R01393' => '835851.1076135',            # Bureau de Brest n° 1501 à 2000. (1908)
    '1R01394' => '835852.1076136',            # Bureau de Brest n° 2001 à 2500. (1908)
    '1R01395' => '835853.1076137',            # Bureau de Brest n° 2501 à 3000. (1908)
    '1R01396' => '835854.1076138',            # Bureau de Brest n° 3001 à 3500. (1908)
    '1R01397' => '835855.1076139',            # Bureau de Brest n° 3501 à 3802. (1908)
    '1R01398' => '835856.1076141',            # Bureau de Brest-Châteaulin n° 311 à 798. (1908)
    '1R01399' => '835857.1076142',            # Bureau de Brest-Châteaulin n° 3023 à 3578, 3580, 3647 à 3680, 3683, 3685 à 3686, 3688, 3692 à 3693, 3698 à 3700, 3716 à 3726, 3732, 3735, 3738. (1908)
    '1R01401' => '835859.1076144',            # Bureau de Quimper n° 1 à 310, 599, 603, 613, 625, 627, 630, 632, 636, 641, 647, 658, 662, 671, 680, 690, 694, 697, 703, 707, 720, 738 à 739, 744, 748, 757, 798 à 800, 799, 800 à 1000. (1908)
    '1R01402' => '835860.1076145',            # Bureau de Quimper n° 1001 à 1500. (1908)
    '1R01403' => '835861.1076146',            # Bureau de Quimper n° 1501 à 2000. (1908)
    '1R01404' => '835862.1076147',            # Bureau de Quimper n° 2001 à 2500. (1908)
    '1R01405' => '835863.1076148',            # Bureau de Quimper n° 2501 à 3000. (1908)
    '1R01406' => '835864.1076149',            # Bureau de Quimper n° 3001 à 3022, 3579 à 3646, 757, 3655 à 3656, 3680 à 3691, 3694 à 3697, 3700 à 3715, 3726 à 3738. (1908)
    '1R01407' => '835865.1076150',            # Tables alphabétiques de Quimper et Brest-Châteaulin, suivies d'une liste d'omis et (ou) d'exemptés. (1908)

    # 1914
    '1R01510' => '835968.1076271',	       # Bureau de Brest n° 1 à 500. (1914)
    '1R01511' => '835969.1076272',	       # Bureau de Brest n° 501 à 1000. (1914)
    '1R01512' => '835970.1076273',	       # Bureau de Brest n° 1001 à 1500. (1914)
    '1R01513' => '835971.1076274',	       # Bureau de Brest n° 1501 à 2000. (1914)
    '1R01514' => '835972.1076275',	       # Bureau de Brest n° 2001 à 2500. (1914)
    '1R01515' => '835973.1076276',	       # Bureau de Brest n° 2501 à 3000. (1914)
    '1R01516' => '835974.1076277',	       # Bureau de Brest n° 3001 à 3500. (1914)
    '1R01517' => '835975.1076278',	       # Bureau de Brest n° 3501 à 3835. (1914)
    '1R01521' => '1076279',	               # Table alphabétique de Brest, suivie d'une liste de natifs du Finistère recensés ailleurs. (1914)
    '1R01518' => '835976.1076280',	       # Bureau de Brest-Châteaulin n° 467 à 1000. (1914)
    '1R01519' => '835977.1076281',	       # Bureau de Brest-Châteaulin n° 1001 à 1169, 1172 à 1500. (1914)
    '1R01520' => '835978.1076282',	       # Bureau de Brest-Châteaulin n° 1501 à 1751. (1914)
    '1R01521' => '1076283',	               # Table alphabétique de Brest-Châteaulin, suivie d'une liste d'omis et (ou) d'exemptés, et de natifs du Finistère recensés ailleurs. (1914)
    '1R01522' => '1076284',	               # Liste matricule de la subdivision de Brest des engagés volontaires non encore inscrits au registre matricule et des hommes des réserves étrangers à la subdivision pris au domicile n° 1 à 500. (1914)
    '1R01522' => '1076285',	               # Table alphabétique de la liste matricule de la subdivision de Brest des engagés volontaires non encore inscrits au registre matricule et des hommes des réserves étrangers à la subdivision pris au domicile n° 1 à 500. (1914)
    '1R01523' => '1076286',	               # Liste matricule de la subdivision de Brest des engagés volontaires non encore inscrits au registre matricule et des hommes des réserves étrangers à la subdivision pris au domicile n° 501 à 992. (1914)
    '1R01523' => '1076287',	       # Table alphabétique de la liste matricule de la subdivision de Brest des engagés volontaires non encore inscrits au registre matricule et des hommes des réserves étrangers à la subdivision pris au domicile n° 501 à 992. (1914)
    '1R01524' => '835982.1076288',	       # Bureau de Quimper n° 1 à 466. (1914)
    '1R01525' => '835983.1076289',	       # Bureau de Quimper n° 589, 597, 624, 633, 637 à 638, 649, 656 à 658, 672, 692, 696, 711, 715, 723 à 724, 765, 772, 776, 778, 786 à 787, 794 à 797, 802, 805, 810, 1751 à 2000. (1914)
    '1R01526' => '835984.1076290',	       # Bureau de Quimper n° 2001 à 2500. (1914)
    '1R01527' => '835985.1076291',            # Bureau de Quimper n° 2501 à 3000. (1914)
    '1R01528' => '835986.1076292',            # Bureau de Quimper n° 3001 à 3500. (1914)
    '1R01529' => '835987.1076293',            # Bureau de Quimper n° 3501 à 4000. (1914)
    '1R01530' => '835988.1076294',            # Bureau de Quimper n° 4001 à 4365. (1914)
    '1R01532' => '1076297',            # Table de la liste matricule de la subdivision de Quimper, des engagés volontaires non encore inscrits au registre matricule et des hommes des réserves étrangers à la subdivision pris au domicile n° 1 à 466. (1914)

    # 1920: https://recherche.archives.finistere.fr/archive/resultats/matricules/n:141?RECH_dateclassefacettes=1920&type=matricules
    '1R01642' => '836100.1076426',             # Bureau de Brest n° 1 à 500. (1920)
    '1R01643' => '836101.1076427',             # Bureau de Brest n° 501 à 1000. (1920)
    '1R01644' => '836102.1076428',             # Bureau de Brest n° 1001 à 1500. (1920)
    '1R01645' => '836103.1076429',             # Bureau de Brest n° 1501 à 2000. (1920)
    '1R01646' => '836104.1076430',             # Bureau de Brest n° 2001 à 2500. (1920)
    '1R01647' => '836105.1076431',             # Bureau de Brest n° 2501 à 3000. (1920)
    '1R01648' => '836106.1076432',             # Bureau de Brest n° 3001 à 3500. (1920)
    '1R01649' => '836107.1076433',             # Bureau de Brest n° 3501 à 4000. (1920)
    '1R01650' => '836108.1076434',             # Bureau de Brest n° 4001 à 4432. (1920)
    '1R01654' => '1076435',                    # Table alphabétique de Brest. (1920)
    '1R01651' => '836109.1076436',             # Bureau de Brest-Châteaulin n° 3104 à 3500. (1920)
    '1R01652' => '836110.1076437',             # Bureau de Brest-Châteaulin n° 3501 à 4000. (1920)
    '1R01653' => '836111.1076438',             # Bureau de Brest-Châteaulin n° 4001 à 4422, 4433 à 4434, 4439 à 4440. (1920)
    '1R01654' => '1076439',                    # Table alphabétique de Brest-Châteaulin, suivie d'une liste d'omis et (ou) d'exemptés, de natifs du Finistère recensés ailleurs et d'étrangers recensés dans le Finistère. (1920)
    '1R01655' => '836113.1076440',             # Bureau de Quimper n° 1 à 500. (1920)
    '1R01656' => '836114.1076441',             # Bureau de Quimper n° 501 à 1000. (1920)
    '1R01657' => '836115.1076442',             # Bureau de Quimper n° 1001 à 1500. (1920)
    '1R01658' => '836116.1076443',             # Bureau de Quimper n° 1501 à 2000. (1920)
    '1R01659' => '836117.1076444',             # Bureau de Quimper n° 2001 à 2500. (1920)
    '1R01660' => '836118.1076445',             # Bureau de Quimper n° 2501 à 3104, 3484, 3486, 3515, 3523, 3525, 3543, 3547 à 3548, 3569, 3578, 3581, 3596, 3608, 3610, 3616, 3628 à 3629, 3640, 3649, 3657, 3665, 4423 à 4432, 4435 à 4438, 4441 à 4443. (1920)

    # BMS : collection départementale :
    #==================================
    # TODO: add conversion for all BMS in my tree

    # BMS Bannalec
    '3E004_0001' => '650488.1266677',            # Baptême mariage sépulture Bannalec 3 E 4 1 (1670-1677)
    '3E004_0002' => '650489.1266678',            # Baptême mariage sépulture Bannalec 3 E 4 2 (1677-1680, 1687-1690)
    '3E004_0003' => '650490.1266679',            # Baptême mariage sépulture Bannalec 3 E 4 3 (1693-1696, 1704, 1706-1710, 1712)
    '3E004_0004' => '650491.1266680',            # Baptême mariage sépulture Bannalec 3 E 4 4 (1713-1716, 1722-janvier 1727)
    '3E004_0005' => '650492.1266681',            # Baptême mariage sépulture Bannalec 3 E 4 5 (janvier 1727-janvier 1734)
    '3E004_0006' => '650493.1266682',            # Baptême mariage sépulture Bannalec 3 E 4 6 (janvier 1734-5 mai 1740)
    '3E004_0007' => '650494.1266683',            # Baptême mariage sépulture Bannalec 3 E 4 7 (6 mai 1740-6 janvier 1745)
    '3E004_0008' => '650495.1626684',            # Baptême mariage sépulture Bannalec 3 E 4 8 (1745-7 février 1750)
    '3E004_0009' => '650496.1266685',            # Baptême mariage sépulture sépulture Bannalec 3 E 4 9 (Baptêmes, mariages (8 février-décembre 1750, 1752-1759) ; baptêmes, mariages, sépultures (1751))
    '3E004_0010' => '650497.1266687',            # Baptême mariage Bannalec 3 E 4 10 (1760-1770)
    '3E004_0011' => '650498.1266688',            # Baptême mariage Bannalec 3 E 4 11 (1771-1778)
    '3E004_0012' => '650499.1266689',            # Baptême mariage Bannalec 3 E 4 12 (1779-1785)
    '3E004_0014' => '650501.1266692',            # Sépulture Bannalec 3 E 4 14 (9 février-décembre 1750, 1752-1770)
    '3E004_0015' => '650502.1266693',            # Sépulture Bannalec 3 E 4 15 (1771-1781)
    '3E004_0016' => '650503.1266694',            # Sépulture Bannalec 3 E 4 16 (1782-1792)

    # BMS Beuzec-Conq
    '3E010_0001' => '650711.1268914',            # BMS Beuzec-Conq 3 E 10 1 (BMS (1664-1726) ; extraits mortuaires (1704-1708))
    '3E010_0002' => '650712.1268915',            # BMS Beuzec-Conq 3 E 10 2 (23 août 1726-1730, 1732-1733, 1741, 1743-1747)
    '3E010_0003' => '650713.1268917',            # BM  Beuzec-Conq 3 E 10 3 (1748-1762)
    '3E010_0004' => '650714.1268918',            # BM  Beuzec-Conq 3 E 10 4 (1763-1778)
    '3E010_0005' => '650715.1268919',            # BM  Beuzec-Conq 3 E 10 5 (1779-1789, 1791-1792)
    '3E010_0006' => '650716.1268921',            # Sépulture Beuzec-Conq 3 E 10 6 (30 décembre 1747-1762)
    '3E010_0007' => '650717.1268922',            # Sépulture Beuzec-Conq 3 E 10 7 (1763-1778)
    '3E010_0008' => '650718.1268923',            # Sépulture Beuzec-Conq 3 E 10 8 (1779- 1789, 1791)

    # BMS Carhaix:
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

    # BMS Cléden-Poher
    '3E042_0001' => '652429.1277165',	# BMS Cleden-Poher 3 E 42 1	1694-1712
    '3E042_0002' => '652430.1277166',	# BMS Cleden-Poher 3 E 42 2	1713-1730
    '3E042_0003' => '652431.1277167',	# BMS Cleden-Poher 3 E 42 3	1730-1746
    '3E042_0004' => '652432.1277168',	# BMS Cleden-Poher 3 E 42 4	1743-1752
    '3E042_0005' => '652433.1277170',	# BMS Cleden-Poher 3 E 42 5	1753-1766
    '3E042_0006' => '652434.1277171',	# BMS Cleden-Poher 3 E 42 6	1767-1780
    '3E042_0007' => '652435.1277172',	# BMS Cleden-Poher 3 E 42 7	1781-1792
    '3E042_0008' => '652436.1277174',	# Sép Cleden-Poher 3 E 42 8	1753-1766
    '3E042_0009' => '652437.1277175',	# Sép Cleden-Poher 3 E 42 9	1767-1780
    '3E042_0010' => '652438.1277176',	# Sép Cleden-Poher 3 E 42 10	1781-1792

    # BMS Cléder
    '3E043_0001' => '652475.1277679',            # Baptême mariage sépulture Cléder 3 E 43 1 (1687-1690, 1717-1720.)
    '3E043_0002' => '652476.1277680',            # Baptême mariage sépulture Cléder 3 E 43 2 (1721-30 décembre 1728.)
    '3E043_0003' => '652477.1277681',            # Baptême mariage sépulture Cléder 3 E 43 3 (30 décembre 1728-1737.)
    '3E043_0004' => '652478.1277682',            # Baptême mariage sépulture Cléder 3 E 43 4 (1738-1746.)
    '3E043_0005' => '652479.1277684',            # Baptême mariage Cléder 3 E 43 5 (1747-1755, 1757, 1759-1760.)
    '3E043_0006' => '652480.1277685',            # Baptême mariage Cléder 3 E 43 6 (1761-1776.)
    '3E043_0007' => '652481.1277686',            # Baptême mariage Cléder 3 E 43 7 (1777-1790, 1792-1er janvier 1793.)
    '3E043_0008' => '652482.1277688',            # Sépulture Cléder 3 E 43 8 (1747-1755, 1765-1772.)
    '3E043_0009' => '652483.1277689',            # Sépulture Cléder 3 E 43 9 (1773-1792.)
    '3E043_0023' => '652497.1277766',            # Mariage publication de mariage Cléder 3 E 43 23 (1793-an IV.)

    # BMS Concarneau
    '3E053_0001' => '652891.1281431',            # BMS Concarneau 3 E 53 1 (Baptêmes (1561-1563 (incomplets) ) ; baptêmes, mariages, sépultures (1678 (incomplet)-1679, 1693, 1704, 1708-1709, 1711-1712, 1714-1715, 1717-1719))
    '3E053_0002' => '652892.1281432',            # BMS Concarneau 3 E 53 2 (1720-1722, 1740-30 décembre 1747)
    '3E053_0003' => '652893.1281434',            # BM  Concarneau 3 E 53 3 (1748-1760)
    '3E053_0004' => '652894.1281435',            # BM  Concarneau 3 E 53 4 (1761-1773)
    '3E053_0005' => '652895.1281436',            # BM  Concarneau 3 E 53 5 (1774-1784)
    '3E053_0006' => '652896.1281437',            # BM  Concarneau 3 E 53 6 (1785-1792)
    '3E053_0007' => '652897.1281439',            # Sépulture Concarneau 3 E 53 7 (31 décembre 1747-1760)
    '3E053_0008' => '652898.1281440',            # Sépulture Concarneau 3 E 53 8 (1761-1773)
    '3E053_0009' => '652899.1281441',            # Sépulture Concarneau 3 E 53 9 (1774-1784)
    '3E053_0010' => '652900.1281442',            # Sépulture Concarneau 3 E 53 10 (1785-1792)

    # BMS Elliant
    '3E064_0001' => '653414.1285727',            # BMS Elliant 3 E 64 1 (1702, 1704-1723, 1731-1732.)
    '3E064_0002' => '653415.1285728',            # BMS Elliant 3 E 64 2 (1733-1749.)
    '3E064_0003' => '653416.1285730',            # BM  Elliant 3 E 64 3 (1750-1771.)
    '3E064_0004' => '653417.1285731',            # BM  Elliant 3 E 64 4 (1772-1792.)
    '3E064_0005' => '653418.1285733',            # Sépulture Elliant 3 E 64 5 (1750-1792.)

    # BMS La Forêt-Fouesnant
    '3E072_0001' => '653719.1289015',            # BMS La Forêt-Fouesnant 3 E 72 1 (avril 1674-17 février 1676, 1er avril-1er novembre 1702, 1704-12 janvier 1720, 1734-1750.)
    '3E072_0002' => '653720.1289017',            # Baptême mariage La Forêt-Fouesnant 3 E 72 2 (1751-1792.)
    '3E072_0003' => '653721.1289019',            # Sépulture La Forêt-Fouesnant 3 E 72 3 (1751-1792.)

    # BMS Kergloff
    '3E106_0001' => '654908.1301833',            # BMS Kergloff 3 E 106 1 (1694-1707, 1709-1720, 1723-1724, 1726-1729, 1740, 1744-1752)
    '3E106_0002' => '654909.1301835',            # BM Kergloff 3 E 106 2 (1753-1792)
    '3E106_0003' => '654910.1301837',            # Sépulture Kergloff 3 E 106 3 (1753-1792)

    # BMS Kernével
    '3E109_0001' => '654999.1302787',            # BMS Kernével 3 E 109 1 (Mariages (13 août 1653-28 février 1658, 1660-1666 - incomplets) ; baptêmes, mariages, sépultures (1668-1669, 1679, 1692, 1702, 1705-1728))
    '3E109_0002' => '655000.1302788',            # BMS Kernével 3 E 109 2 (1729-1748)
    '3E109_0003' => '655001.1302790',            # BM  Kernével 3 E 109 3 (1749-1772)
    '3E109_0004' => '655002.1302791',            # BM Kernével 3 E 109 4 (1773-1792)
    '3E109_0005' => '655003.1302793',            # Sépulture Kernével 3 E 109 5 (1749-1792)

    # BMS Lampaul-Guimiliau
    '3E117_0001' => '655356.1304911',            # Baptême mariage sépulture Lampaul-Guimiliau 3 E 117 1 (1687-1690, 1692-1696.)
    '3E117_0002' => '655357.1304912',            # Baptême mariage sépulture Lampaul-Guimiliau 3 E 117 2 (1697-1703.)
    '3E117_0003' => '655358.1304913',            # Baptême mariage sépulture Lampaul-Guimiliau 3 E 117 3 (1704-1710.)
    '3E117_0004' => '655359.1304914',            # Baptême mariage sépulture Lampaul-Guimiliau 3 E 117 4 (1711-1718.)
    '3E117_0005' => '655360.1304915',            # Baptême mariage sépulture Lampaul-Guimiliau 3 E 117 5 (1719-1727.)
    '3E117_0006' => '655361.1304916',            # Baptême mariage sépulture Lampaul-Guimiliau 3 E 117 6 (1728-1736.)
    '3E117_0007' => '655362.1304917',            # Baptême mariage sépulture Lampaul-Guimiliau 3 E 117 7 (1737, 1739-1745.)
    '3E117_0008' => '655363.1304919',            # Baptême mariage Lampaul-Guimiliau 3 E 117 8 (1747-1755, 1757-1760.)
    '3E117_0009' => '655364.1304920',            # Baptême mariage Lampaul-Guimiliau 3 E 117 9 (1761-1776.)
    '3E117_0010' => '655365.1304921',            # Baptême mariage Lampaul-Guimiliau 3 E 117 10 (1777-1792.)
    '3E117_0011' => '655366.1304923',            # Sépulture Lampaul-Guimiliau 3 E 117 11 (1747-1770.)
    '3E117_0012' => '655367.1304924',            # Sépulture Lampaul-Guimiliau 3 E 117 12 (1771-1792.)

    # BMS Landeleau
    '3E122_0001' => '655525.1307132',            # BMS Landeleau 3 E 122 1 (Baptêmes, mariages, sépultures (1694-1699, 1701-1718, 1724, 1726-1732) ; extraits mortuaires (1699-1732))
    '3E122_0002' => '655526.1307133',            # BMS Landeleau 3 E 122 2 (Baptêmes, mariages, sépultures (1733-1751) ; extraits mortuaires (1733-1746))
    '3E122_0003' => '655527.1307135',            # BM  Landeleau 3 E 122 3 (1752-1774)
    '3E122_0004' => '655528.1307136',            # BM  Landeleau 3 E 122 4 (1775-1792)
    '3E122_0005' => '655529.1307138',            # Sépulture Landeleau 3 E 122 5 (1752-1792)

    # BMS Laz
    '3E148_0001' => '656323.1314137',            # BMS Laz 3 E 148 1 (1674-1676, 1702-1716, 1718-1722, 1724-1725, 1727-1728)
    '3E148_0002' => '656324.1314138',            # BMS Laz 3 E 148 2 (Extraits mortuaires (1730-1746) ; baptêmes, mariages, sépultures (1730, 1732-1733, 1735-1750))
    '3E148_0003' => '656325.1314140',            # BM  Laz 3 E 148 3 (1751-1776)
    '3E148_0004' => '656326.1314141',            # BM  Laz 3 E 148 4 (1777-1792)
    '3E148_0005' => '656327.1314143',            # Sépulture Laz 3 E 148 5 (1751-1792)

    # BMS Leuhan
    '3E151_0001' => '656461.1315011',            # BMS Leuhan 3 E 151 1 (1695-1696, 1698-1702 (incomplet), 1703-1704, 1709-1723, 1725-1734.)
    '3E151_0002' => '656462.1315012',            # BMS Leuhan 3 E 151 2 (1735-1751.)
    '3E151_0003' => '656463.1315014',            # BM  Leuhan 3 E 151 3 (1752-1772.)
    '3E151_0004' => '656464.1315015',            # BM  Leuhan 3 E 151 4 (1773-1er mars 1793.)
    '3E151_0005' => '656465.1315017',            # Sépulture Leuhan 3 E 151 5 (1752-22 mars 1793.)

    # BMS Loperec
    '3E169_0001' => '656880.1320916',            # Baptême mariage sépulture Lopérec 3 E 169 1 (1636-1668.)
    '3E169_0002' => '656881.1320917',            # Baptême mariage sépulture Lopérec 3 E 169 2 (1669-1692.)
    '3E169_0003' => '656882.1320918',            # Baptême mariage sépulture Lopérec 3 E 169 3 (1693-1694 (incomplet), 1695-1705, 1707, 1709 (incomplet)-1722, 1724-1727.)
    '3E169_0004' => '656883.1320919',            # Baptême mariage sépulture Lopérec 3 E 169 4 (1727-1736 (incomplet), 1737-1749.)
    '3E169_0005' => '656884.1320921',            # Baptême mariage Lopérec 3 E 169 5 (1750-1772.)
    '3E169_0006' => '656885.1320922',            # Baptême mariage Lopérec 3 E 169 6 (1773-1792.)
    '3E169_0007' => '656886.1320924',            # Sépulture Lopérec 3 E 169 7 (1750-1792.)
    '3E169_0016' => '656895.1320983',            # Mariage Lopérec 3 E 169 16 (1793-an VI, an IX-1812.)

    # BMS Meilars
    '3E176_0001' => '657076.1322529',            # Baptême mariage sépulture Meilars (Confort-Meilars, Finistère) 3 E 176 1 (1702-1740 (incomplet), 1743-1749.)
    '3E176_0002' => '657077.1322531',            # Baptême mariage Meilars (Confort-Meilars, Finistère) 3 E 176 2 (1750-1772.)
    '3E176_0003' => '657078.1322532',            # Baptême mariage Meilars (Confort-Meilars, Finistère) 3 E 176 3 (1773-1792.)
    '3E176_0004' => '657079.1322534',            # Sépulture Meilars (Confort-Meilars, Finistère) 3 E 176 4 (1750-1792.)
    '3E176_0011' => '1322690',            # Mariage promesse de mariage Meilars (Confort-Meilars, Finistère) 3 E 176/11/1 (1793 - an II)

    # BMS Motreff
    '3E189_0001' => '657656.1324606',            # BMS Motreff 3 E 189 1 (1676-1677 (incomplet), 1685 (incomplet)-1691, 1692 (incomplet), 1694-1703, 1705-1709, 1711-1715, 1717-1719, 1721-1740, 1742, 1744, 1746-1752)
    '3E189_0002' => '657657.1324608',            # BM  Motreff 3 E 189 2 (1753-1792)
    '3E189_0003' => '657658.1324610',            # Sépulture Motreff 3 E 189 3 (1754-1792)

    # BMS Le Moustoir
    '3E190_0001' => '657690.1324826',            # Baptême mariage sépulture Le Moustoir (Châteauneuf-du-Faou, Finistère) 3 E 190 1 (1704-1706, 1708-1712, 1715-1719, 1721-1724, 1728-1754.)
    '3E190_0002' => '657691.1324828',            # Baptême mariage Le Moustoir (Châteauneuf-du-Faou, Finistère) 3 E 190 2 (1755-28 mars 1792.)
    '3E190_0003' => '657692.1324830',            # Sépulture Le Moustoir (Châteauneuf-du-Faou, Finistère) 3 E 190 3 (1755-1773, 1775-1791.)
    '3E190_0035' => '',			# Sép Le Moustoir		1755-1773 (BUG/FIXME: n'apparait plus avec le nouveau site!)

    # BMS Penhars
    '3E195_0001' => '657836.1325884',            # Baptême mariage sépulture Penhars 3 E 195 1 (Baptêmes (1512-1569 (incomplet), 1597-1673) ; baptêmes, mariages, sépultures (1674-1704).)
    '3E195_0002' => '657837.1325885',            # Baptême mariage sépulture Penhars 3 E 195 2 (1702-1703 (doubles), 1705-1728, 1732-1754, 1756-12 janvier 1761.)
    '3E195_0003' => '657838.1325886',            # Baptême mariage sépulture Penhars 3 E 195 3 (Baptêmes, mariages (27 janvier 1761-1765, 1768-1792) ; sépultures (20 février 1761-1765, 1768-1792).)
    '3E195_0011' => '657846.1325902',            # Mariage Penhars 3 E 195 11 (1793-an VI, an IX-1812.)

    # BMS Plonéis
    '3E212_0001' => '658570.1332280',            # BMS Plonéis 3 E 212 1 (1702-1715, 1717-1720, 1728, 1730-1748.)
    '3E212_0002' => '658571.1332282',            # BM Plonéis 3 E 212 2 (1749-1774.)
    '3E212_0003' => '658572.1332283',            # BM Plonéis 3 E 212 3 (1775-1792.)
    '3E212_0004' => '658573.1332285',            # Sépulture Plonéis 3 E 212 4 (1749-1792.)

    # BMS Saint-Quijeau
    '3E326_0001' => '1040982.1366562',            # BMS Saint-Quijeau E 326 1 (1687-1690, 1704-1706, 1708-1712, 1715-1717, 1719-1721, 1723, 1726, 1728-1738, 1744-1752)
    '3E326_0002' => '1040983.1366564',            # BM  Saint-Quijeau E 326 2 (1753-1764, 1766-1791)
    '3E326_0003' => '1040984.1366566',            # Sépulture Saint-Quijeau E 326 3 (1753-1793)

    # BMS Plouguer
    '3E234_0001' => '659570.1340587',	# BMS Plouguer 3 E 234 1        1694-1703
    '3E234_0002' => '659571.1340588',	# BMS Plouguer 3 E 234 2        1704-1749
    '3E234_0003' => '659572.1340590',	# BM Plouguer  3 E 234 3        1750-28 février 1793
    '3E234_0004' => '659573.1340592',	# Sép Plouguer 3 E 234 4        1753-28 février 1793

    # BMS Plounévézel
    '3E245_0001' => '660152.1345472',            # BMS Plounévézel 3 E 245 1 (1676-1678 (incomplet), 1687-1691, 1694-1701, 1703-1706 (incomplet), 1707-1715, 1717-1719, 1724-1731, 1733-1753.)
    '3E245_0002' => '660153.1345474',            # BM  Plounévézel 3 E 245 2 (1754-24 juillet 1792.)
    '3E245_0003' => '660154.1345476',            # Sépulture Plounévézel 3 E 245 3 (1754-1755, 1757-1790.)

    # BMS Poullaouen
    '3E270_0001' => '1039195.1354565',            # Baptême mariage sépulture Poullaouen 3 E 270 1 (1676 (incomplet)-1677, 1687-1688, 1690-1691, 1694-1715.)
    '3E270_0002' => '1039196.1354566',            # Baptême mariage sépulture Poullaouen 3 E 270 2 (1716-1717, 1719-1721, 1723-1726, 1728-1735, 1737-1738, 1742, 1744-1752.)
    '3E270_0003' => '1039197.1354568',            # Baptême mariage Poullaouen 3 E 270 3 (1753-1777.)
    '3E270_0004' => '1039198.1354569',            # Baptême mariage Poullaouen 3 E 270 4 (1778-1792.)
    '3E270_0005' => '1039199.1354571',            # Sépulture Poullaouen 3 E 270 5 (1753-1765, 1768-1792.)

    # BMS Saint-Hernin
    '3E309_0001' => '1040255.1634650',            # BMS Saint-Hernin 3 E 309 1 (9 avril-15 septembre 1694, 6 novembre-décembre 1702, 1704-1720, 1724-1726, 1728-1734)
    '3E309_0004' => '1040258.1634654',            # BM  Saint-Hernin 3 E 309 4 (1771-1792)
    '3E309_0005' => '1040259.1634656',            # Sépulture Saint-Hernin 3 E 309 5 (1753-1792)

    # BMS Plonévez-du-Faou
    '3E214_0001' => '658661.1333267',            # BMS Plonévez-du-Faou 3 E 214 1 (Baptêmes, mariages, sépultures (1694-1702, 1704, 1706-1712, 1714-1719, 1721, 1723, 1728) ; extraits mortuaires (1704-1728))
    '3E214_0002' => '658662.1333268',            # BMS Plonévez-du-Faou 3 E 214 2 (Baptêmes, mariages, sépultures (1729-1739) ; extraits mortuaires (1729-1746))
    '3E214_0003' => '658663.1333269',            # BMS Plonévez-du-Faou 3 E 214 3 (1740-1750)
    '3E214_0004' => '658664.1333271',            # BM  Plonévez-du-Faou 3 E 214 4 (1751-1766)
    '3E214_0005' => '658665.1333272',            # BM  Plonévez-du-Faou 3 E 214 5 (1767-1780)
    '3E214_0006' => '658666.1333273',            # BM  Plonévez-du-Faou 3 E 214 6 (1781-1792)
    '3E214_0007' => '658667.1333275',            # Sépulture Plonévez-du-Faou 3 E 214 7 (1751-1772)
    '3E214_0008' => '658668.1333276',            # Sépulture Plonévez-du-Faou 3 E 214 8 (1773-1792)

    # BMS Querrien
    '3E274_0001' => '1039321.1355723',            # BMS Querrien 3 E 274 1 (Baptêmes (1653 (incomplet)-1661) ; baptêmes, sépultures (1669, 1672-1673) ; baptêmes, mariages, sépultures (1693, 1696 (incomplet), 1704 (incomplet), 1707, 1709-1711 (incomplet), 1712-1720 (incomplet) ).)
    '3E274_0002' => '1039322.1355724',            # BMS Querrien 3 E 274 2 (24 décembre 1720-4 janvier 1736.)
    '3E274_0003' => '1039323.1355725',            # BMS Querrien 3 E 274 3 (7 janvier 1736-1748.)
    '3E274_0004' => '1039324.1355727',            # BM  Querrien 3 E 274 4 (1749-1763.)
    '3E274_0005' => '1039325.1355728',            # BM  Querrien 3 E 274 5 (1764-1766 (incomplet), 1767-1769, 1771-1779.)
    '3E274_0006' => '1039326.1355729',            # BM  Querrien 3 E 274 6 (1780-1790, 1792-7 janvier 1793.)
    '3E274_0007' => '1039327.1355731',            # Sépulture Querrien 3 E 274 7 (1749-1766, 1768-1771, 1773-1776 (incomplet), 1777-1er avril 1793.)

    # BMS Scaër
    '3E344_0001' => '1045957.1371644',            # BMS Scaër 3 E 344 1 (1669-1670 (incomplets), 1701, 1704-1709 (incomplet), 1710-1714 (incomplets), 1715-1716 (incomplet), 1717-6 février 1719)
    '3E344_0002' => '1045958.1371645',            # BMS Scaër 3 E 344 2 (13 février 1719-1722, 20 mars 1724-1731)
    '3E344_0003' => '1045959.1371646',            # BMS Scaër 3 E 344 3 (1732-21 février 1735, 2 août 1735-14 janvier 1742)
    '3E344_0004' => '1045960.1371647',            # BMS Scaër 3 E 344 4 (15 janvier 1742-1747)
    '3E344_0005' => '1045961.1371649',            # BM  Scaër 3 E 344 5 (1748-1758)
    '3E344_0006' => '1045962.1371650',            # BM  Scaër 3 E 344 6 (1759-1770)
    '3E344_0007' => '1045963.1371651',            # BM  Scaër 3 E 344 7 (1771-1782)
    '3E344_0008' => '1045964.1371652',            # BM  Scaër 3 E 344 8 (1783-1792)
    '3E344_0009' => '1045965.1371654',            # Sépulture Scaër 3 E 344 9 (1748-1758)
    '3E344_0010' => '1045966.1371655',            # Sépulture Scaër 3 E 344 10 (1759-1770)
    '3E344_0011' => '1045967.1371656',            # Sépulture Scaër 3 E 344 11 (1771-1782)
    '3E344_0012' => '1045968.1371657',            # Sépulture Scaër 3 E 344 12 (1783-1789, 1791-4 janvier 1793)

    # BMS Spézet
    '3E348_0001' => '1045747.1373143',            # BMS Spézet 3 E 348 1 (1671-1672, 1675-1677, 1687-1690, 1694-1696)
    '3E348_0002' => '1045748.1373144',            # BMS Spézet 3 E 348 2 (1697-1704, 1706-1708)
    '3E348_0003' => '1045749.1373145',            # BMS Spézet 3 E 348 3 (1709-1711, 1713-1721, 1723)
    '3E348_0004' => '1045750.1373146',            # BMS Spézet 3 E 348 4 (1726, 1729-1738, 1741-1742, 1744)
    '3E348_0005' => '1045751.1373147',            # BMS Spézet 3 E 348 5 (1745-1753)
    '3E348_0006' => '1045752.1373148',            # BMS Spézet 3 E 348 6 (1754-1760)
    '3E348_0006' => '1045752.1373148',            # BMS Spézet 3 E 348 6 (1754-1760)
    '3E348_0007' => '1045753.1373149',            # BMS Spézet 3 E 348 7 (Baptêmes, mariages, sépultures (1761-1765, 1768-1770) ; baptêmes, mariages (1766-1767))
    '3E348_0008' => '1045754.1373150',            # BMS Spézet 3 E 348 8 (1771-1776)
    '3E348_0009' => '1045755.1373151',            # BMS Spézet 3 E 348 9 (1777-1782)
    '3E348_0010' => '1045756.1373152',            # BMS Spézet 3 E 348 10 (1783-1788)
    '3E348_0011' => '1045757.1373153',            # BMS Spézet 3 E 348 11 (1789-1791)

    # NMD :
    #=====
    # TODO: Fix BMS/NMD Carhaix with upstream change of ID for Carhaix

    # NMD Bannalec
    '3E004_0017' => {			# Naissance Bannalec 3 E 4 17   AN02-AN10
	'AN02' => '1266697',            # Naissance Bannalec 3 E 4/17/1 (1793 - an II)
	'AN03' => '1266698',            # Naissance Bannalec 3 E 4/17/2 (an III)
	'AN04' => '1266699',            # Naissance Bannalec 3 E 4/17/3 (an IV)
	'AN05' => '1266700',            # Naissance Bannalec 3 E 4/17/4 (an V)
	'AN06' => '1266701',            # Naissance Bannalec 3 E 4/17/5 (an VI)
	'AN07' => '1266702',            # Naissance Bannalec 3 E 4/17/6 (an VII)
	'AN08' => '1266703',            # Naissance Bannalec 3 E 4/17/7 (an VIII)
	'AN09' => '1266704',            # Naissance Bannalec 3 E 4/17/8 (an IX)
	'AN10' => '1266705',            # Naissance Bannalec 3 E 4/17/9 (an X)
    },

    '3E004_0018' => {			# Naissance Bannalec 3 E 4 18   AN11-1812
	'AN11' => '1266707',            # Naissance Bannalec 3 E 4/18/1 (an XI)
	'AN12' => '1266708',            # Naissance Bannalec 3 E 4/18/2 (an XII)
	'AN13' => '1266709',            # Naissance Bannalec 3 E 4/18/3 (an XIII)
	'AN14' => '1266710',            # Naissance Bannalec 3 E 4/18/4 (an XIV - 1806)
	1807   => '1266711',            # Naissance Bannalec 3 E 4/18/5 (1807)
	1808   => '1266712',            # Naissance Bannalec 3 E 4/18/6 (1808)
	1809   => '1266713',            # Naissance Bannalec 3 E 4/18/7 (1809)
	1810   => '1266714',            # Naissance Bannalec 3 E 4/18/8 (1810)
	1811   => '1266715',            # Naissance Bannalec 3 E 4/18/9 (1811)
	1812   => '1266716',            # Naissance Bannalec 3 E 4/18/10 (1812)
    },

    '3E004_0019' => {			# Naissance Bannalec 3 E 4 19   1813-1822
	1813   => '1266718',            # Naissance Bannalec 3 E 4/19/1 (1813)
	1814   => '1266719',            # Naissance Bannalec 3 E 4/19/2 (1814)
	1815   => '1266720',            # Naissance Bannalec 3 E 4/19/3 (1815)
	1816   => '1266721',            # Naissance Bannalec 3 E 4/19/4 (1816)
	1817   => '1266722',            # Naissance Bannalec 3 E 4/19/5 (1817)
	1818   => '1266723',            # Naissance Bannalec 3 E 4/19/6 (1818)
	1819   => '1266724',            # Naissance Bannalec 3 E 4/19/7 (1819)
	1820   => '1266725',            # Naissance Bannalec 3 E 4/19/8 (1820)
	1821   => '1266726',            # Naissance Bannalec 3 E 4/19/9 (1821)
	1822   => '1266727',            # Naissance Bannalec 3 E 4/19/10 (1822)
    },

    '3E004_0020' => {			# Naissance Bannalec 3 E 4 20   1823-1832
	1823   => '1266729',            # Naissance Bannalec 3 E 4/20/1 (1823)
	1824   => '1266730',            # Naissance Bannalec 3 E 4/20/2 (1824)
	1825   => '1266731',            # Naissance Bannalec 3 E 4/20/3 (1825)
	1826   => '1266732',            # Naissance Bannalec 3 E 4/20/4 (1826)
	1827   => '1266733',            # Naissance Bannalec 3 E 4/20/5 (1827)
	1828   => '1266734',            # Naissance Bannalec 3 E 4/20/6 (1828)
	1829   => '1266735',            # Naissance Bannalec 3 E 4/20/7 (1829)
	1830   => '1266736',            # Naissance Bannalec 3 E 4/20/8 (1830)
	1831   => '1266737',            # Naissance Bannalec 3 E 4/20/9 (1831)
	1832   => '1266738',            # Naissance Bannalec 3 E 4/20/10 (1832)
    },

    '3E004_0021' => {			# Naissance Bannalec 3 E 4 21   1833-1842
	1833   => '1266740',            # Naissance Bannalec 3 E 4/21/1 (1833)
	1834   => '1266741',            # Naissance Bannalec 3 E 4/21/2 (1834)
	1835   => '1266742',            # Naissance Bannalec 3 E 4/21/3 (1835)
	1836   => '1266743',            # Naissance Bannalec 3 E 4/21/4 (1836)
	1837   => '1266744',            # Naissance Bannalec 3 E 4/21/5 (1837)
	1838   => '1266745',            # Naissance Bannalec 3 E 4/21/6 (1838)
	1839   => '1266746',            # Naissance Bannalec 3 E 4/21/7 (1839)
	1840   => '1266747',            # Naissance Bannalec 3 E 4/21/8 (1840)
	1841   => '1266748',            # Naissance Bannalec 3 E 4/21/9 (1841)
	1842   => '1266749',            # Naissance Bannalec 3 E 4/21/10 (1842)
    },

    '3E004_0022' => {			# Naissance Bannalec 3 E 4 22   1843-1852
	1843   => '1266751',            # Naissance Bannalec 3 E 4/22/1 (1843)
	1844   => '1266752',            # Naissance Bannalec 3 E 4/22/2 (1844)
	1845   => '1266753',            # Naissance Bannalec 3 E 4/22/3 (1845)
	1846   => '1266754',            # Naissance Bannalec 3 E 4/22/4 (1846)
	1847   => '1266755',            # Naissance Bannalec 3 E 4/22/5 (1847)
	1848   => '1266756',            # Naissance Bannalec 3 E 4/22/6 (1848)
	1849   => '1266757',            # Naissance Bannalec 3 E 4/22/7 (1849)
	1850   => '1266758',            # Naissance Bannalec 3 E 4/22/8 (1850)
	1851   => '1266759',            # Naissance Bannalec 3 E 4/22/9 (1851)
	1852   => '1266760',            # Naissance Bannalec 3 E 4/22/10 (1852)
    },

    '3E004_0023' => {			# Naissance Bannalec 3 E 4 23   1853-1862
	1853   => '1266762',            # Naissance Bannalec 3 E 4/23/1 (1853)
	1854   => '1266763',            # Naissance Bannalec 3 E 4/23/2 (1854)
	1855   => '1266764',            # Naissance Bannalec 3 E 4/23/3 (1855)
	1856   => '1266765',            # Naissance Bannalec 3 E 4/23/4 (1856)
	1857   => '1266766',            # Naissance Bannalec 3 E 4/23/5 (1857)
	1858   => '1266767',            # Naissance Bannalec 3 E 4/23/6 (1858)
	1859   => '1266768',            # Naissance Bannalec 3 E 4/23/7 (1859)
	1860   => '1266769',            # Naissance Bannalec 3 E 4/23/8 (1860)
	1861   => '1266770',            # Naissance Bannalec 3 E 4/23/9 (1861)
	1862   => '1266771',            # Naissance Bannalec 3 E 4/23/10 (1862)
    },

    '3E004_0024' => {			# Naissance Bannalec 3 E 4 24   1863-1869
	1863   => '1266773',            # Naissance Bannalec 3 E 4/24/1 (1863)
	1864   => '1266774',            # Naissance Bannalec 3 E 4/24/2 (1864)
	1865   => '1266775',            # Naissance Bannalec 3 E 4/24/3 (1865)
	1866   => '1266776',            # Naissance Bannalec 3 E 4/24/4 (1866)
	1867   => '1266777',            # Naissance Bannalec 3 E 4/24/5 (1867)
	1868   => '1266778',            # Naissance Bannalec 3 E 4/24/6 (1868)
	1869   => '1266779',            # Naissance Bannalec 3 E 4/24/7 (1869)
    },

    '3E004_0025' => {			# Naissance Bannalec 3 E 4 25   1870-1875
	1870   => '1266781',            # Naissance Bannalec 3 E 4/25/1 (1870)
	1871   => '1266782',            # Naissance Bannalec 3 E 4/25/2 (1871)
	1872   => '1266783',            # Naissance Bannalec 3 E 4/25/3 (1872)
	1873   => '1266784',            # Naissance Bannalec 3 E 4/25/4 (1873)
	1874   => '1266785',            # Naissance Bannalec 3 E 4/25/5 (1874)
	1875   => '1266786',            # Naissance Bannalec 3 E 4/25/6 (1875)
    },

    '3E004_0026' => {			# Naissance Bannalec 3 E 4 26   1876-1881
	1876   => '1266788',            # Naissance Bannalec 3 E 4/26/1 (1876)
	1877   => '1266789',            # Naissance Bannalec 3 E 4/26/2 (1877)
	1878   => '1266790',            # Naissance Bannalec 3 E 4/26/3 (1878)
	1879   => '1266791',            # Naissance Bannalec 3 E 4/26/4 (1879)
	1880   => '1266792',            # Naissance Bannalec 3 E 4/26/5 (1880)
	1881   => '1266793',            # Naissance Bannalec 3 E 4/26/6 (1881)
    },

    '3E004_0027' => {			# Naissance Bannalec 3 E 4 27   1882-1886
	1882   => '1266795',            # Naissance Bannalec 3 E 4/27/1 (1882)
	1883   => '1266796',            # Naissance Bannalec 3 E 4/27/2 (1883)
	1884   => '1266797',            # Naissance Bannalec 3 E 4/27/3 (1884)
	1885   => '1266798',            # Naissance Bannalec 3 E 4/27/4 (1885)
	1886   => '1266799',            # Naissance Bannalec 3 E 4/27/5 (1886)
    },

    '3E004_0028' => {			# Naissance Bannalec 3 E 4 28   1887-1890
	1887   => '1266801',            # Naissance Bannalec 3 E 4/28/1 (1887)
	1888   => '1266802',            # Naissance Bannalec 3 E 4/28/2 (1888)
	1889   => '1266803',            # Naissance Bannalec 3 E 4/28/3 (1889)
	1890   => '1266804',            # Naissance Bannalec 3 E 4/28/4 (1890)
    },

    '3E004_0029' => {			# Naissance Bannalec 3 E 4 29   1891-1894
	1891   => '1266806',            # Naissance Bannalec 3 E 4/29/1 (1891)
	1892   => '1266807',            # Naissance Bannalec 3 E 4/29/2 (1892)
	1893   => '1266808',            # Naissance Bannalec 3 E 4/29/3 (1893)
	1894   => '1266809',            # Naissance Bannalec 3 E 4/29/4 (1894)
    },

    '3E004_0030' => {			# Mariage promesse de mariage Bannalec 3 E 4 30   AN02-1793-an XI
	'AN02' => '1266876',            # Mariage promesse de mariage Bannalec 3 E 4/30/1 (1793-an II)
	'AN03' => '1266877',            # Mariage promesse de mariage Bannalec 3 E 4/30/2 (an III)
	'AN05' => '1266878',            # Mariage promesse de mariage Bannalec 3 E 4/30/3 (an V)
	'AN06' => '1266879',            # Mariage promesse de mariage Bannalec 3 E 4/30/4 (an VI)
	'AN07' => '1266880',            # Mariage promesse de mariage Bannalec 3 E 4/30/5 (an VII)
	'AN08' => '1266881',            # Mariage promesse de mariage Bannalec 3 E 4/30/6 (an VIII)
	'AN09' => '1266882',            # Mariage promesse de mariage Bannalec 3 E 4/30/7 (an IX)
	'AN10' => '1266883',            # Mariage promesse de mariage Bannalec 3 E 4/30/8 (an X)
	'an VI-an VIII, an X-an XI (promesses de mariages)' => '1266884',            # Mariage promesse de mariage Bannalec 3 E 4/30/9 (an VI-an VIII, an X-an XI (promesses de mariages))
    },

    '3E004_0031' => {			# Mariage Bannalec 3 E 4 31   AN11-1812
	'AN11' => '1266886',            # Mariage Bannalec 3 E 4/31/1 (an XI)
	'AN12' => '1266887',            # Mariage Bannalec 3 E 4/31/2 (an XII)
	'AN13' => '1266888',            # Mariage Bannalec 3 E 4/31/3 (an XIII)
	'AN14' => '1266889',            # Mariage Bannalec 3 E 4/31/4 (an XIV - 1806)
	1807   => '1266890',            # Mariage Bannalec 3 E 4/31/5 (1807)
	1808   => '1266891',            # Mariage Bannalec 3 E 4/31/6 (1808)
	1809   => '1266892',            # Mariage Bannalec 3 E 4/31/7 (1809)
	1810   => '1266893',            # Mariage Bannalec 3 E 4/31/8 (1810)
	1811   => '1266894',            # Mariage Bannalec 3 E 4/31/9 (1811)
	1812   => '1266895',            # Mariage Bannalec 3 E 4/31/10 (1812)
    },

    '3E004_0032' => {			# Mariage Bannalec 3 E 4 32   1813-1822
	1813   => '1266897',            # Mariage Bannalec 3 E 4/32/1 (1813)
	1814   => '1266898',            # Mariage Bannalec 3 E 4/32/2 (1814)
	1815   => '1266899',            # Mariage Bannalec 3 E 4/32/3 (1815)
	1816   => '1266900',            # Mariage Bannalec 3 E 4/32/4 (1816)
	1817   => '1266901',            # Mariage Bannalec 3 E 4/32/5 (1817)
	1818   => '1266902',            # Mariage Bannalec 3 E 4/32/6 (1818)
	1819   => '1266903',            # Mariage Bannalec 3 E 4/32/7 (1819)
	1820   => '1266904',            # Mariage Bannalec 3 E 4/32/8 (1820)
	1821   => '1266905',            # Mariage Bannalec 3 E 4/32/9 (1821)
	1822   => '1266906',            # Mariage Bannalec 3 E 4/32/10 (1822)
    },

    '3E004_0033' => {			# Mariage Bannalec 3 E 4 33   1823-1832
	1823   => '1266908',            # Mariage Bannalec 3 E 4/33/1 (1823)
	1824   => '1266909',            # Mariage Bannalec 3 E 4/33/2 (1824)
	1825   => '1266910',            # Mariage Bannalec 3 E 4/33/3 (1825)
	1826   => '1266911',            # Mariage Bannalec 3 E 4/33/4 (1826)
	1827   => '1266912',            # Mariage Bannalec 3 E 4/33/5 (1827)
	1828   => '1266913',            # Mariage Bannalec 3 E 4/33/6 (1828)
	1829   => '1266914',            # Mariage Bannalec 3 E 4/33/7 (1829)
	1830   => '1266915',            # Mariage Bannalec 3 E 4/33/8 (1830)
	1831   => '1266916',            # Mariage Bannalec 3 E 4/33/9 (1831)
	1832   => '1266917',            # Mariage Bannalec 3 E 4/33/10 (1832)
    },

    '3E004_0034' => {			# Mariage Bannalec 3 E 4 34   1833-1842
	1833   => '1266919',            # Mariage Bannalec 3 E 4/34/1 (1833)
	1834   => '1266920',            # Mariage Bannalec 3 E 4/34/2 (1834)
	1835   => '1266921',            # Mariage Bannalec 3 E 4/34/3 (1835)
	1836   => '1266922',            # Mariage Bannalec 3 E 4/34/4 (1836)
	1837   => '1266923',            # Mariage Bannalec 3 E 4/34/5 (1837)
	1838   => '1266924',            # Mariage Bannalec 3 E 4/34/6 (1838)
	1839   => '1266925',            # Mariage Bannalec 3 E 4/34/7 (1839)
	1840   => '1266926',            # Mariage Bannalec 3 E 4/34/8 (1840)
	1841   => '1266927',            # Mariage Bannalec 3 E 4/34/9 (1841)
	1842   => '1266928',            # Mariage Bannalec 3 E 4/34/10 (1842)
    },

    '3E004_0035' => {			# Mariage Bannalec 3 E 4 35   1843-1852
	1843   => '1266930',            # Mariage Bannalec 3 E 4/35/1 (1843)
	1844   => '1266931',            # Mariage Bannalec 3 E 4/35/2 (1844)
	1845   => '1266932',            # Mariage Bannalec 3 E 4/35/3 (1845)
	1846   => '1266933',            # Mariage Bannalec 3 E 4/35/4 (1846)
	1847   => '1266934',            # Mariage Bannalec 3 E 4/35/5 (1847)
	1848   => '1266935',            # Mariage Bannalec 3 E 4/35/6 (1848)
	1849   => '1266936',            # Mariage Bannalec 3 E 4/35/7 (1849)
	1850   => '1266937',            # Mariage Bannalec 3 E 4/35/8 (1850)
	1851   => '1266938',            # Mariage Bannalec 3 E 4/35/9 (1851)
	1852   => '1266939',            # Mariage Bannalec 3 E 4/35/10 (1852)
    },

    '3E004_0036' => {			# Mariage Bannalec 3 E 4 36   1853-1862
	1853   => '1266941',            # Mariage Bannalec 3 E 4/36/1 (1853)
	1854   => '1266942',            # Mariage Bannalec 3 E 4/36/2 (1854)
	1855   => '1266943',            # Mariage Bannalec 3 E 4/36/3 (1855)
	1856   => '1266944',            # Mariage Bannalec 3 E 4/36/4 (1856)
	1857   => '1266945',            # Mariage Bannalec 3 E 4/36/5 (1857)
	1858   => '1266946',            # Mariage Bannalec 3 E 4/36/6 (1858)
	1859   => '1266947',            # Mariage Bannalec 3 E 4/36/7 (1859)
	1860   => '1266948',            # Mariage Bannalec 3 E 4/36/8 (1860)
	1861   => '1266949',            # Mariage Bannalec 3 E 4/36/9 (1861)
	1862   => '1266950',            # Mariage Bannalec 3 E 4/36/10 (1862)
    },

    '3E004_0037' => {			# Mariage Bannalec 3 E 4 37   1863-1869
	1863   => '1266952',            # Mariage Bannalec 3 E 4/37/1 (1863)
	1864   => '1266953',            # Mariage Bannalec 3 E 4/37/2 (1864)
	1865   => '1266954',            # Mariage Bannalec 3 E 4/37/3 (1865)
	1866   => '1266955',            # Mariage Bannalec 3 E 4/37/4 (1866)
	1867   => '1266956',            # Mariage Bannalec 3 E 4/37/5 (1867)
	1868   => '1266957',            # Mariage Bannalec 3 E 4/37/6 (1868)
	1869   => '1266958',            # Mariage Bannalec 3 E 4/37/7 (1869)
    },

    '3E004_0038' => {			# Mariage Bannalec 3 E 4 38   1870-1876
	1870   => '1266960',            # Mariage Bannalec 3 E 4/38/1 (1870)
	1871   => '1266961',            # Mariage Bannalec 3 E 4/38/2 (1871)
	1872   => '1266962',            # Mariage Bannalec 3 E 4/38/3 (1872)
	1873   => '1266963',            # Mariage Bannalec 3 E 4/38/4 (1873)
	1874   => '1266964',            # Mariage Bannalec 3 E 4/38/5 (1874)
	1875   => '1266965',            # Mariage Bannalec 3 E 4/38/6 (1875)
	1876   => '1266966',            # Mariage Bannalec 3 E 4/38/7 (1876)
    },

    '3E004_0039' => {			# Mariage Bannalec 3 E 4 39   1877-1883
	1877   => '1266968',            # Mariage Bannalec 3 E 4/39/1 (1877)
	1878   => '1266969',            # Mariage Bannalec 3 E 4/39/2 (1878)
	1879   => '1266970',            # Mariage Bannalec 3 E 4/39/3 (1879)
	1880   => '1266971',            # Mariage Bannalec 3 E 4/39/4 (1880)
	1881   => '1266972',            # Mariage Bannalec 3 E 4/39/5 (1881)
	1882   => '1266973',            # Mariage Bannalec 3 E 4/39/6 (1882)
	1883   => '1266974',            # Mariage Bannalec 3 E 4/39/7 (1883)
    },

    '3E004_0040' => {			# Mariage Bannalec 3 E 4 40   1884-1888
	1884   => '1266976',            # Mariage Bannalec 3 E 4/40/1 (1884)
	1885   => '1266977',            # Mariage Bannalec 3 E 4/40/2 (1885)
	1886   => '1266978',            # Mariage Bannalec 3 E 4/40/3 (1886)
	1887   => '1266979',            # Mariage Bannalec 3 E 4/40/4 (1887)
	1888   => '1266980',            # Mariage Bannalec 3 E 4/40/5 (1888)
    },

    '3E004_0041' => {			# Mariage Bannalec 3 E 4 41   1889-1893
	1889   => '1266982',            # Mariage Bannalec 3 E 4/41/1 (1889)
	1890   => '1266983',            # Mariage Bannalec 3 E 4/41/2 (1890)
	1891   => '1266984',            # Mariage Bannalec 3 E 4/41/3 (1891)
	1892   => '1266985',            # Mariage Bannalec 3 E 4/41/4 (1892)
	1893   => '1266986',            # Mariage Bannalec 3 E 4/41/5 (1893)
    },

    '3E004_0042' => {			# Décès Bannalec 3 E 4 42   AN02-AN10
	'AN02' => '1267049',            # Décès Bannalec 3 E 4/42/1 (1793 - an II)
	'AN03' => '1267050',            # Décès Bannalec 3 E 4/42/2 (an III)
	'AN04' => '1267051',            # Décès Bannalec 3 E 4/42/3 (an IV)
	'AN05' => '1267052',            # Décès Bannalec 3 E 4/42/4 (an V)
	'AN06' => '1267053',            # Décès Bannalec 3 E 4/42/5 (an VI)
	'AN07' => '1267054',            # Décès Bannalec 3 E 4/42/6 (an VII)
	'AN08' => '1267055',            # Décès Bannalec 3 E 4/42/7 (an VIII)
	'AN09' => '1267056',            # Décès Bannalec 3 E 4/42/8 (an IX)
	'AN10' => '1267057',            # Décès Bannalec 3 E 4/42/9 (an X)
    },

    '3E004_0043' => {			# Décès Bannalec 3 E 4 43   AN11-1812
	'AN11' => '1267059',            # Décès Bannalec 3 E 4/43/1 (an XI)
	'AN12' => '1267060',            # Décès Bannalec 3 E 4/43/2 (an XII)
	'AN13' => '1267061',            # Décès Bannalec 3 E 4/43/3 (an XIII)
	'AN14' => '1267062',            # Décès Bannalec 3 E 4/43/4 (an XIV - 1806)
	1807   => '1267063',            # Décès Bannalec 3 E 4/43/5 (1807)
	1808   => '1267064',            # Décès Bannalec 3 E 4/43/6 (1808)
	1809   => '1267065',            # Décès Bannalec 3 E 4/43/7 (1809)
	1810   => '1267066',            # Décès Bannalec 3 E 4/43/8 (1810)
	1811   => '1267067',            # Décès Bannalec 3 E 4/43/9 (1811)
	1812   => '1267068',            # Décès Bannalec 3 E 4/43/10 (1812)
    },

    '3E004_0044' => {			# Décès Bannalec 3 E 4 44   1813-1822
	1813   => '1267070',            # Décès Bannalec 3 E 4/44/1 (1813)
	1814   => '1267071',            # Décès Bannalec 3 E 4/44/2 (1814)
	1815   => '1267072',            # Décès Bannalec 3 E 4/44/3 (1815)
	1816   => '1267073',            # Décès Bannalec 3 E 4/44/4 (1816)
	1817   => '1267074',            # Décès Bannalec 3 E 4/44/5 (1817)
	1818   => '1267075',            # Décès Bannalec 3 E 4/44/6 (1818)
	1819   => '1267076',            # Décès Bannalec 3 E 4/44/7 (1819)
	1820   => '1267077',            # Décès Bannalec 3 E 4/44/8 (1820)
	1821   => '1267078',            # Décès Bannalec 3 E 4/44/9 (1821)
	1822   => '1267079',            # Décès Bannalec 3 E 4/44/10 (1822)
    },

    '3E004_0045' => {			# Décès Bannalec 3 E 4 45   1823-1832
	1823   => '1267081',            # Décès Bannalec 3 E 4/45/1 (1823)
	1824   => '1267082',            # Décès Bannalec 3 E 4/45/2 (1824)
	1825   => '1267083',            # Décès Bannalec 3 E 4/45/3 (1825)
	1826   => '1267084',            # Décès Bannalec 3 E 4/45/4 (1826)
	1827   => '1267085',            # Décès Bannalec 3 E 4/45/5 (1827)
	1828   => '1267086',            # Décès Bannalec 3 E 4/45/6 (1828)
	1829   => '1267087',            # Décès Bannalec 3 E 4/45/7 (1829)
	1830   => '1267088',            # Décès Bannalec 3 E 4/45/8 (1830)
	1831   => '1267089',            # Décès Bannalec 3 E 4/45/9 (1831)
	1832   => '1267090',            # Décès Bannalec 3 E 4/45/10 (1832)
    },

    '3E004_0046' => {			# Décès Bannalec 3 E 4 46   1833-1842
	1833   => '1267092',            # Décès Bannalec 3 E 4/46/1 (1833)
	1834   => '1267093',            # Décès Bannalec 3 E 4/46/2 (1834)
	1835   => '1267094',            # Décès Bannalec 3 E 4/46/3 (1835)
	1836   => '1267095',            # Décès Bannalec 3 E 4/46/4 (1836)
	1837   => '1267096',            # Décès Bannalec 3 E 4/46/5 (1837)
	1838   => '1267097',            # Décès Bannalec 3 E 4/46/6 (1838)
	1839   => '1267098',            # Décès Bannalec 3 E 4/46/7 (1839)
	1840   => '1267099',            # Décès Bannalec 3 E 4/46/8 (1840)
	1841   => '1267100',            # Décès Bannalec 3 E 4/46/9 (1841)
	1842   => '1267101',            # Décès Bannalec 3 E 4/46/10 (1842)
    },

    '3E004_0047' => {			# Décès Bannalec 3 E 4 47   1843-1852
	1843   => '1267103',            # Décès Bannalec 3 E 4/47/1 (1843)
	1844   => '1267104',            # Décès Bannalec 3 E 4/47/2 (1844)
	1845   => '1267105',            # Décès Bannalec 3 E 4/47/3 (1845)
	1846   => '1267106',            # Décès Bannalec 3 E 4/47/4 (1846)
	1847   => '1267107',            # Décès Bannalec 3 E 4/47/5 (1847)
	1848   => '1267108',            # Décès Bannalec 3 E 4/47/6 (1848)
	1849   => '1267109',            # Décès Bannalec 3 E 4/47/7 (1849)
	1850   => '1267110',            # Décès Bannalec 3 E 4/47/8 (1850)
	1851   => '1267111',            # Décès Bannalec 3 E 4/47/9 (1851)
	1852   => '1267112',            # Décès Bannalec 3 E 4/47/10 (1852)
    },

    '3E004_0048' => {			# Décès Bannalec 3 E 4 48   1853-1862
	1853   => '1267114',            # Décès Bannalec 3 E 4/48/1 (1853)
	1854   => '1267115',            # Décès Bannalec 3 E 4/48/2 (1854)
	1855   => '1267116',            # Décès Bannalec 3 E 4/48/3 (1855)
	1856   => '1267117',            # Décès Bannalec 3 E 4/48/4 (1856)
	1857   => '1267118',            # Décès Bannalec 3 E 4/48/5 (1857)
	1858   => '1267119',            # Décès Bannalec 3 E 4/48/6 (1858)
	1859   => '1267120',            # Décès Bannalec 3 E 4/48/7 (1859)
	1860   => '1267121',            # Décès Bannalec 3 E 4/48/8 (1860)
	1861   => '1267122',            # Décès Bannalec 3 E 4/48/9 (1861)
	1862   => '1267123',            # Décès Bannalec 3 E 4/48/10 (1862)
    },

    '3E004_0049' => {			# Décès Bannalec 3 E 4 49   1863-1869
	1863   => '1267125',            # Décès Bannalec 3 E 4/49/1 (1863)
	1864   => '1267126',            # Décès Bannalec 3 E 4/49/2 (1864)
	1865   => '1267127',            # Décès Bannalec 3 E 4/49/3 (1865)
	1866   => '1267128',            # Décès Bannalec 3 E 4/49/4 (1866)
	1867   => '1267129',            # Décès Bannalec 3 E 4/49/5 (1867)
	1868   => '1267130',            # Décès Bannalec 3 E 4/49/6 (1868)
	1869   => '1267131',            # Décès Bannalec 3 E 4/49/7 (1869)
    },

    '3E004_0050' => {			# Décès Bannalec 3 E 4 50   1870-1875
	1870   => '1267133',            # Décès Bannalec 3 E 4/50/1 (1870)
	1871   => '1267134',            # Décès Bannalec 3 E 4/50/2 (1871)
	1872   => '1267135',            # Décès Bannalec 3 E 4/50/3 (1872)
	1873   => '1267136',            # Décès Bannalec 3 E 4/50/4 (1873)
	1874   => '1267137',            # Décès Bannalec 3 E 4/50/5 (1874)
	1875   => '1267138',            # Décès Bannalec 3 E 4/50/6 (1875)
    },

    '3E004_0051' => {			# Décès Bannalec 3 E 4 51   1876-1882
	1876   => '1267140',            # Décès Bannalec 3 E 4/51/1 (1876)
	1877   => '1267141',            # Décès Bannalec 3 E 4/51/2 (1877)
	1878   => '1267142',            # Décès Bannalec 3 E 4/51/3 (1878)
	1879   => '1267143',            # Décès Bannalec 3 E 4/51/4 (1879)
	1880   => '1267144',            # Décès Bannalec 3 E 4/51/5 (1880)
	1881   => '1267145',            # Décès Bannalec 3 E 4/51/6 (1881)
	1882   => '1267146',            # Décès Bannalec 3 E 4/51/7 (1882)
    },

    '3E004_0052' => {			# Décès Bannalec 3 E 4 52   1883-1888
	1883   => '1267148',            # Décès Bannalec 3 E 4/52/1 (1883)
	1884   => '1267149',            # Décès Bannalec 3 E 4/52/2 (1884)
	1885   => '1267150',            # Décès Bannalec 3 E 4/52/3 (1885)
	1886   => '1267151',            # Décès Bannalec 3 E 4/52/4 (1886)
	1887   => '1267152',            # Décès Bannalec 3 E 4/52/5 (1887)
	1888   => '1267153',            # Décès Bannalec 3 E 4/52/6 (1888)
    },

    '3E004_0053' => {			# Décès Bannalec 3 E 4 53   1889-1894
	1889   => '1267155',            # Décès Bannalec 3 E 4/53/1 (1889)
	1890   => '1267156',            # Décès Bannalec 3 E 4/53/2 (1890)
	1891   => '1267157',            # Décès Bannalec 3 E 4/53/3 (1891)
	1892   => '1267158',            # Décès Bannalec 3 E 4/53/4 (1892)
	1893   => '1267159',            # Décès Bannalec 3 E 4/53/5 (1893)
	1894   => '1267160',            # Décès Bannalec 3 E 4/53/6 (1894)
    },

    '3E004_0054' => {			# Naissance Bannalec 3 E 4 54   1895-1898
	1895   => '1266811',            # Naissance Bannalec 3 E 4/54/1 (1895)
	1896   => '1266812',            # Naissance Bannalec 3 E 4/54/2 (1896)
	1897   => '1266813',            # Naissance Bannalec 3 E 4/54/3 (1897)
	1898   => '1266814',            # Naissance Bannalec 3 E 4/54/4 (1898)
    },

    '3E004_0055' => {			# Mariage Bannalec 3 E 4 55   1894-1898
	1894   => '1266988',            # Mariage Bannalec 3 E 4/55/1 (1894)
	1895   => '1266989',            # Mariage Bannalec 3 E 4/55/2 (1895)
	1896   => '1266990',            # Mariage Bannalec 3 E 4/55/3 (1896)
	1897   => '1266991',            # Mariage Bannalec 3 E 4/55/4 (1897)
	1898   => '1266992',            # Mariage Bannalec 3 E 4/55/5 (1898)
    },

    '3E004_0056' => {			# Décès Bannalec 3 E 4 56   1895-1900
	1895   => '1267162',            # Décès Bannalec 3 E 4/56/1 (1895)
	1896   => '1267163',            # Décès Bannalec 3 E 4/56/2 (1896)
	1897   => '1267164',            # Décès Bannalec 3 E 4/56/3 (1897)
	1898   => '1267165',            # Décès Bannalec 3 E 4/56/4 (1898)
	1899   => '1267166',            # Décès Bannalec 3 E 4/56/5 (1899)
	1900   => '1267167',            # Décès Bannalec 3 E 4/56/6 (1900)
    },

    '3E004_0057' => {			# Naissance Bannalec 3 E 4 57   1899-1902
	1899   => '1266816',            # Naissance Bannalec 3 E 4/57/1 (1899)
	1900   => '1266817',            # Naissance Bannalec 3 E 4/57/2 (1900)
	1901   => '1266818',            # Naissance Bannalec 3 E 4/57/3 (1901)
	1902   => '1266819',            # Naissance Bannalec 3 E 4/57/4 (1902)
    },

    '3E004_0058' => {			# Naissance Bannalec 3 E 4 58   1903-1905
	1903   => '1266821',            # Naissance Bannalec 3 E 4/58/1 (1903)
	1904   => '1266822',            # Naissance Bannalec 3 E 4/58/2 (1904)
	1905   => '1266823',            # Naissance Bannalec 3 E 4/58/3 (1905)
    },

    '3E004_0059' => {			# Mariage Bannalec 3 E 4 59   1899-1902
	1899   => '1266994',            # Mariage Bannalec 3 E 4/59/1 (1899)
	1900   => '1266995',            # Mariage Bannalec 3 E 4/59/2 (1900)
	1901   => '1266996',            # Mariage Bannalec 3 E 4/59/3 (1901)
	1902   => '1266997',            # Mariage Bannalec 3 E 4/59/4 (1902)
    },

    '3E004_0060' => {			# Mariage Bannalec 3 E 4 60   1903-1906
	1903   => '1266999',            # Mariage Bannalec 3 E 4/60/1 (1903)
	1904   => '1267000',            # Mariage Bannalec 3 E 4/60/2 (1904)
	1905   => '1267001',            # Mariage Bannalec 3 E 4/60/3 (1905)
	1906   => '1267002',            # Mariage Bannalec 3 E 4/60/4 (1906)
    },

    '3E004_0061' => {			# Décès Bannalec 3 E 4 61   1901-1905
	1901   => '1267169',            # Décès Bannalec 3 E 4/61/1 (1901)
	1902   => '1267170',            # Décès Bannalec 3 E 4/61/2 (1902)
	1903   => '1267171',            # Décès Bannalec 3 E 4/61/3 (1903)
	1904   => '1267172',            # Décès Bannalec 3 E 4/61/4 (1904)
	1905   => '1267173',            # Décès Bannalec 3 E 4/61/5 (1905)
    },

    '3E004_0062' => {			# Naissance Bannalec 3 E 4 62   1906-1908
	1906   => '1266825',            # Naissance Bannalec 3 E 4/62/1 (1906)
	1907   => '1266826',            # Naissance Bannalec 3 E 4/62/2 (1907)
	1908   => '1266827',            # Naissance Bannalec 3 E 4/62/3 (1908)
    },

    '3E004_0063' => {			# Mariage Bannalec 3 E 4 63   1907-1910
	1907   => '1267004',            # Mariage Bannalec 3 E 4/63/1 (1907)
	1908   => '1267005',            # Mariage Bannalec 3 E 4/63/2 (1908)
	1909   => '1267006',            # Mariage Bannalec 3 E 4/63/3 (1909)
	1910   => '1267007',            # Mariage Bannalec 3 E 4/63/4 (1910)
    },

    '3E004_0064' => {			# Naissance Bannalec 3 E 4 64   1909-1911
	1909   => '1266829',            # Naissance Bannalec 3 E 4/64/1 (1909)
	1910   => '1266830',            # Naissance Bannalec 3 E 4/64/2 (1910)
	1911   => '1266831',            # Naissance Bannalec 3 E 4/64/3 (1911)
    },

    '3E004_0065' => {			# Naissance Bannalec 3 E 4 65   1912-1915
	1912   => '1266833',            # Naissance Bannalec 3 E 4/65/1 (1912)
	1913   => '1266834',            # Naissance Bannalec 3 E 4/65/2 (1913)
	1914   => '1266835',            # Naissance Bannalec 3 E 4/65/3 (1914)
	1915   => '1266836',            # Naissance Bannalec 3 E 4/65/4 (1915)
    },

    '3E004_0066' => {			# Mariage Bannalec 3 E 4 66   1911-1914
	1911   => '1267009',            # Mariage Bannalec 3 E 4/66/1 (1911)
	1912   => '1267010',            # Mariage Bannalec 3 E 4/66/2 (1912)
	1913   => '1267011',            # Mariage Bannalec 3 E 4/66/3 (1913)
	1914   => '1267012',            # Mariage Bannalec 3 E 4/66/4 (1914)
    },

    '3E004_0067' => {			# Décès Bannalec 3 E 4 67   1906-1911
	1906   => '1267175',            # Décès Bannalec 3 E 4/67/1 (1906)
	1907   => '1267176',            # Décès Bannalec 3 E 4/67/2 (1907)
	1908   => '1267177',            # Décès Bannalec 3 E 4/67/3 (1908)
	1909   => '1267178',            # Décès Bannalec 3 E 4/67/4 (1909)
	1910   => '1267179',            # Décès Bannalec 3 E 4/67/5 (1910)
	1911   => '1267180',            # Décès Bannalec 3 E 4/67/6 (1911)
    },

    '3E004_0068' => {			# Naissance Bannalec 3 E 4 68   1916-1920
	1916   => '1266838',            # Naissance Bannalec 3 E 4/68/1 (1916)
	1917   => '1266839',            # Naissance Bannalec 3 E 4/68/2 (1917)
	1918   => '1266840',            # Naissance Bannalec 3 E 4/68/3 (1918)
	1919   => '1266841',            # Naissance Bannalec 3 E 4/68/4 (1919)
	1920   => '1266842',            # Naissance Bannalec 3 E 4/68/5 (1920)
    },

    '3E004_0069' => {			# Naissance Bannalec 3 E 4 69   1921-1925
	1921   => '1266844',            # Naissance Bannalec 3 E 4/69/1 (1921)
	1922   => '1266845',            # Naissance Bannalec 3 E 4/69/2 (1922)
	1923   => '1266846',            # Naissance Bannalec 3 E 4/69/3 (1923)
	1924   => '1266847',            # Naissance Bannalec 3 E 4/69/4 (1924)
	1925   => '1266848',            # Naissance Bannalec 3 E 4/69/5 (1925)
    },

    '3E004_0072' => {			# Mariage Bannalec 3 E 4 72   1915-1919
	1915   => '1267014',            # Mariage Bannalec 3 E 4/72/1 (1915)
	1916   => '1267015',            # Mariage Bannalec 3 E 4/72/2 (1916)
	1917   => '1267016',            # Mariage Bannalec 3 E 4/72/3 (1917)
	1918   => '1267017',            # Mariage Bannalec 3 E 4/72/4 (1918)
	1919   => '1267018',            # Mariage Bannalec 3 E 4/72/5 (1919)
    },

    '3E004_0073' => {			# Mariage Bannalec 3 E 4 73   1920-1923
	1920   => '1267020',            # Mariage Bannalec 3 E 4/73/1 (1920)
	1921   => '1267021',            # Mariage Bannalec 3 E 4/73/2 (1921)
	1922   => '1267022',            # Mariage Bannalec 3 E 4/73/3 (1922)
	1923   => '1267023',            # Mariage Bannalec 3 E 4/73/4 (1923)
    },

    '3E004_0074' => {			# Mariage Bannalec 3 E 4 74   1924-1927
	1924   => '1267025',            # Mariage Bannalec 3 E 4/74/1 (1924)
	1925   => '1267026',            # Mariage Bannalec 3 E 4/74/2 (1925)
	1926   => '1267027',            # Mariage Bannalec 3 E 4/74/3 (1926)
	1927   => '1267028',            # Mariage Bannalec 3 E 4/74/4 (1927)
    },

    '3E004_0075' => {			# Mariage Bannalec 3 E 4 75   1928-1931
	1928   => '1267030',            # Mariage Bannalec 3 E 4/75/1 (1928)
	1929   => '1267031',            # Mariage Bannalec 3 E 4/75/2 (1929)
	1930   => '1267032',            # Mariage Bannalec 3 E 4/75/3 (1930)
	1931   => '1267033',            # Mariage Bannalec 3 E 4/75/4 (1931)
    },

    '3E004_0076' => {			# Mariage Bannalec 3 E 4 76   1932-1936
	1932   => '1267035',            # Mariage Bannalec 3 E 4/76/1 (1932)
	1933   => '1267036',            # Mariage Bannalec 3 E 4/76/2 (1933)
	1934   => '1267037',            # Mariage Bannalec 3 E 4/76/3 (1934)
	1935   => '1267038',            # Mariage Bannalec 3 E 4/76/4 (1935)
	1936   => '1267039',            # Mariage Bannalec 3 E 4/76/5 (1936)
    },

    '3E004_0077' => {			# Décès Bannalec 3 E 4 77   1912-1917
	1912   => '1267182',            # Décès Bannalec 3 E 4/77/1 (1912)
	1913   => '1267183',            # Décès Bannalec 3 E 4/77/2 (1913)
	1914   => '1267184',            # Décès Bannalec 3 E 4/77/3 (1914)
	1915   => '1267185',            # Décès Bannalec 3 E 4/77/4 (1915)
	1916   => '1267186',            # Décès Bannalec 3 E 4/77/5 (1916)
	1917   => '1267187',            # Décès Bannalec 3 E 4/77/6 (1917)
    },

    '3E004_0078' => {			# Décès Bannalec 3 E 4 78   1918-1922
	1918   => '1267189',            # Décès Bannalec 3 E 4/78/1 (1918)
	1919   => '1267190',            # Décès Bannalec 3 E 4/78/2 (1919)
	1920   => '1267191',            # Décès Bannalec 3 E 4/78/3 (1920)
	1921   => '1267192',            # Décès Bannalec 3 E 4/78/4 (1921)
	1922   => '1267193',            # Décès Bannalec 3 E 4/78/5 (1922)
    },

    '3E004_0079' => {			# Décès Bannalec 3 E 4 79   1923-1929
	1923   => '1267195',            # Décès Bannalec 3 E 4/79/1 (1923)
	1924   => '1267196',            # Décès Bannalec 3 E 4/79/2 (1924)
	1925   => '1267197',            # Décès Bannalec 3 E 4/79/3 (1925)
	1926   => '1267198',            # Décès Bannalec 3 E 4/79/4 (1926)
	1927   => '1267199',            # Décès Bannalec 3 E 4/79/5 (1927)
	1928   => '1267200',            # Décès Bannalec 3 E 4/79/6 (1928)
	1929   => '1267201',            # Décès Bannalec 3 E 4/79/7 (1929)
    },

    '3E004_0080' => {			# Décès Bannalec 3 E 4 80   1930-1936
	1930   => '1267203',            # Décès Bannalec 3 E 4/80/1 (1930)
	1931   => '1267204',            # Décès Bannalec 3 E 4/80/2 (1931)
	1932   => '1267205',            # Décès Bannalec 3 E 4/80/3 (1932)
	1933   => '1267206',            # Décès Bannalec 3 E 4/80/4 (1933)
	1934   => '1267207',            # Décès Bannalec 3 E 4/80/5 (1934)
	1935   => '1267208',            # Décès Bannalec 3 E 4/80/6 (1935)
	1936   => '1267209',            # Décès Bannalec 3 E 4/80/7 (1936)
    },


    # NMD Beuzec-Conq
    '3E010_0009' => {			# Naissance Beuzec-Conq 3 E 10 9   AN02-AN10
	'AN02' => '1268926',            # Naissance Beuzec-Conq 3 E 10/9/1 (1793 - an II)
	'AN03' => '1268927',            # Naissance Beuzec-Conq 3 E 10/9/2 (an III)
	'AN04' => '1268928',            # Naissance Beuzec-Conq 3 E 10/9/3 (an IV)
	'AN05' => '1268929',            # Naissance Beuzec-Conq 3 E 10/9/4 (an V)
	'AN06' => '1268930',            # Naissance Beuzec-Conq 3 E 10/9/5 (an VI)
	'AN07' => '1268931',            # Naissance Beuzec-Conq 3 E 10/9/6 (an VII)
	'AN08' => '1268932',            # Naissance Beuzec-Conq 3 E 10/9/7 (an VIII)
	'AN09' => '1268933',            # Naissance Beuzec-Conq 3 E 10/9/8 (an IX)
	'AN10' => '1268934',            # Naissance Beuzec-Conq 3 E 10/9/9 (an X)
    },

    '3E010_0010' => {			# Naissance Beuzec-Conq 3 E 10 10   AN11-1812
	'AN11' => '1268936',            # Naissance Beuzec-Conq 3 E 10/10/1 (an XI)
	'AN12' => '1268937',            # Naissance Beuzec-Conq 3 E 10/10/2 (an XII)
	'AN13' => '1268938',            # Naissance Beuzec-Conq 3 E 10/10/3 (an XIII)
	'AN14' => '1268939',            # Naissance Beuzec-Conq 3 E 10/10/4 (an XIV - 1806)
	1807   => '1268940',            # Naissance Beuzec-Conq 3 E 10/10/5 (1807)
	1808   => '1268941',            # Naissance Beuzec-Conq 3 E 10/10/6 (1808)
	1809   => '1268942',            # Naissance Beuzec-Conq 3 E 10/10/7 (1809)
	1810   => '1268943',            # Naissance Beuzec-Conq 3 E 10/10/8 (1810)
	1811   => '1268944',            # Naissance Beuzec-Conq 3 E 10/10/9 (1811)
	1812   => '1268945',            # Naissance Beuzec-Conq 3 E 10/10/10 (1812)
    },

    '3E010_0011' => {			# Naissance Beuzec-Conq 3 E 10 11   1813-1822
	1813   => '1268947',            # Naissance Beuzec-Conq 3 E 10/11/1 (1813)
	1814   => '1268948',            # Naissance Beuzec-Conq 3 E 10/11/2 (1814)
	1815   => '1268949',            # Naissance Beuzec-Conq 3 E 10/11/3 (1815)
	1816   => '1268950',            # Naissance Beuzec-Conq 3 E 10/11/4 (1816)
	1817   => '1268951',            # Naissance Beuzec-Conq 3 E 10/11/5 (1817)
	1818   => '1268952',            # Naissance Beuzec-Conq 3 E 10/11/6 (1818)
	1819   => '1268953',            # Naissance Beuzec-Conq 3 E 10/11/7 (1819)
	1820   => '1268954',            # Naissance Beuzec-Conq 3 E 10/11/8 (1820)
	1821   => '1268955',            # Naissance Beuzec-Conq 3 E 10/11/9 (1821)
	1822   => '1268956',            # Naissance Beuzec-Conq 3 E 10/11/10 (1822)
    },

    '3E010_0012' => {			# Naissance Beuzec-Conq 3 E 10 12   1823-1832
	1823   => '1268958',            # Naissance Beuzec-Conq 3 E 10/12/1 (1823)
	1824   => '1268959',            # Naissance Beuzec-Conq 3 E 10/12/2 (1824)
	1825   => '1268960',            # Naissance Beuzec-Conq 3 E 10/12/3 (1825)
	1826   => '1268961',            # Naissance Beuzec-Conq 3 E 10/12/4 (1826)
	1827   => '1268962',            # Naissance Beuzec-Conq 3 E 10/12/5 (1827)
	1828   => '1268963',            # Naissance Beuzec-Conq 3 E 10/12/6 (1828)
	1829   => '1268964',            # Naissance Beuzec-Conq 3 E 10/12/7 (1829)
	1830   => '1268965',            # Naissance Beuzec-Conq 3 E 10/12/8 (1830)
	1831   => '1268966',            # Naissance Beuzec-Conq 3 E 10/12/9 (1831)
	1832   => '1268967',            # Naissance Beuzec-Conq 3 E 10/12/10 (1832)
    },

    '3E010_0013' => {			# Naissance Beuzec-Conq 3 E 10 13   1833-1842
	1833   => '1268969',            # Naissance Beuzec-Conq 3 E 10/13/1 (1833)
	1834   => '1268970',            # Naissance Beuzec-Conq 3 E 10/13/2 (1834)
	1835   => '1268971',            # Naissance Beuzec-Conq 3 E 10/13/3 (1835)
	1836   => '1268972',            # Naissance Beuzec-Conq 3 E 10/13/4 (1836)
	1837   => '1268973',            # Naissance Beuzec-Conq 3 E 10/13/5 (1837)
	1838   => '1268974',            # Naissance Beuzec-Conq 3 E 10/13/6 (1838)
	1839   => '1268975',            # Naissance Beuzec-Conq 3 E 10/13/7 (1839)
	1840   => '1268976',            # Naissance Beuzec-Conq 3 E 10/13/8 (1840)
	1841   => '1268977',            # Naissance Beuzec-Conq 3 E 10/13/9 (1841)
	1842   => '1268978',            # Naissance Beuzec-Conq 3 E 10/13/10 (1842)
    },

    '3E010_0014' => {			# Naissance Beuzec-Conq 3 E 10 14   1843-1852
	1843   => '1268980',            # Naissance Beuzec-Conq 3 E 10/14/1 (1843)
	1844   => '1268981',            # Naissance Beuzec-Conq 3 E 10/14/2 (1844)
	1845   => '1268982',            # Naissance Beuzec-Conq 3 E 10/14/3 (1845)
	1846   => '1268983',            # Naissance Beuzec-Conq 3 E 10/14/4 (1846)
	1847   => '1268984',            # Naissance Beuzec-Conq 3 E 10/14/5 (1847)
	1848   => '1268985',            # Naissance Beuzec-Conq 3 E 10/14/6 (1848)
	1849   => '1268986',            # Naissance Beuzec-Conq 3 E 10/14/7 (1849)
	1850   => '1268987',            # Naissance Beuzec-Conq 3 E 10/14/8 (1850)
	1851   => '1268988',            # Naissance Beuzec-Conq 3 E 10/14/9 (1851)
	1852   => '1268989',            # Naissance Beuzec-Conq 3 E 10/14/10 (1852)
    },

    '3E010_0015' => {			# Naissance Beuzec-Conq 3 E 10 15   1853-1862
	1853   => '1268991',            # Naissance Beuzec-Conq 3 E 10/15/1 (1853)
	1854   => '1268992',            # Naissance Beuzec-Conq 3 E 10/15/2 (1854)
	1855   => '1268993',            # Naissance Beuzec-Conq 3 E 10/15/3 (1855)
	1856   => '1268994',            # Naissance Beuzec-Conq 3 E 10/15/4 (1856)
	1857   => '1268995',            # Naissance Beuzec-Conq 3 E 10/15/5 (1857)
	1858   => '1268996',            # Naissance Beuzec-Conq 3 E 10/15/6 (1858)
	1859   => '1268997',            # Naissance Beuzec-Conq 3 E 10/15/7 (1859)
	1860   => '1268998',            # Naissance Beuzec-Conq 3 E 10/15/8 (1860)
	1861   => '1268999',            # Naissance Beuzec-Conq 3 E 10/15/9 (1861)
	1862   => '1269000',            # Naissance Beuzec-Conq 3 E 10/15/10 (1862)
    },

    '3E010_0016' => {			# Naissance Beuzec-Conq 3 E 10 16   1863-1869
	1863   => '1269002',            # Naissance Beuzec-Conq 3 E 10/16/1 (1863)
	1864   => '1269003',            # Naissance Beuzec-Conq 3 E 10/16/2 (1864)
	1865   => '1269004',            # Naissance Beuzec-Conq 3 E 10/16/3 (1865)
	1866   => '1269005',            # Naissance Beuzec-Conq 3 E 10/16/4 (1866)
	1867   => '1269006',            # Naissance Beuzec-Conq 3 E 10/16/5 (1867)
	1868   => '1269007',            # Naissance Beuzec-Conq 3 E 10/16/6 (1868)
	1869   => '1269008',            # Naissance Beuzec-Conq 3 E 10/16/7 (1869)
    },

    '3E010_0017' => {			# Naissance Beuzec-Conq 3 E 10 17   1870-1882
	1870   => '1269010',            # Naissance Beuzec-Conq 3 E 10/17/1 (1870)
	1871   => '1269011',            # Naissance Beuzec-Conq 3 E 10/17/2 (1871)
	1872   => '1269012',            # Naissance Beuzec-Conq 3 E 10/17/3 (1872)
	1873   => '1269013',            # Naissance Beuzec-Conq 3 E 10/17/4 (1873)
	1874   => '1269014',            # Naissance Beuzec-Conq 3 E 10/17/5 (1874)
	1875   => '1269015',            # Naissance Beuzec-Conq 3 E 10/17/6 (1875)
	1876   => '1269016',            # Naissance Beuzec-Conq 3 E 10/17/7 (1876)
	1877   => '1269017',            # Naissance Beuzec-Conq 3 E 10/17/8 (1877)
	1878   => '1269018',            # Naissance Beuzec-Conq 3 E 10/17/9 (1878)
	1879   => '1269019',            # Naissance Beuzec-Conq 3 E 10/17/10 (1879)
	1880   => '1269020',            # Naissance Beuzec-Conq 3 E 10/17/11 (1880)
	1881   => '1269021',            # Naissance Beuzec-Conq 3 E 10/17/12 (1881)
	1882   => '1269022',            # Naissance Beuzec-Conq 3 E 10/17/13 (1882)
    },

    '3E010_0018' => {			# Naissance Beuzec-Conq 3 E 10 18   1883-1890
	1883   => '1269024',            # Naissance Beuzec-Conq 3 E 10/18/1 (1883)
	1884   => '1269025',            # Naissance Beuzec-Conq 3 E 10/18/2 (1884)
	1885   => '1269026',            # Naissance Beuzec-Conq 3 E 10/18/3 (1885)
	1886   => '1269027',            # Naissance Beuzec-Conq 3 E 10/18/4 (1886)
	1887   => '1269028',            # Naissance Beuzec-Conq 3 E 10/18/5 (1887)
	1888   => '1269029',            # Naissance Beuzec-Conq 3 E 10/18/6 (1888)
	1889   => '1269030',            # Naissance Beuzec-Conq 3 E 10/18/7 (1889)
	1890   => '1269031',            # Naissance Beuzec-Conq 3 E 10/18/8 (1890)
    },

    '3E010_0019' => {			# Mariage Beuzec-Conq 3 E 10 19   AN02-AN10
	'AN02' => '1269086',            # Mariage Beuzec-Conq 3 E 10/19/1 (1793 - an II)
	'AN03' => '1269087',            # Mariage Beuzec-Conq 3 E 10/19/2 (an III)
	'AN04' => '1269088',            # Mariage Beuzec-Conq 3 E 10/19/3 (an IV)
	'AN05' => '1269089',            # Mariage Beuzec-Conq 3 E 10/19/4 (an V)
	'AN06' => '1269090',            # Mariage Beuzec-Conq 3 E 10/19/5 (an VI)
	'AN09' => '1269091',            # Mariage Beuzec-Conq 3 E 10/19/6 (an IX)
	'AN10' => '1269092',            # Mariage Beuzec-Conq 3 E 10/19/7 (an X)
    },

    '3E010_0020' => {			# Mariage Beuzec-Conq 3 E 10 20   AN11-1812
	'AN11' => '1269094',            # Mariage Beuzec-Conq 3 E 10/20/1 (an XI)
	'AN12' => '1269095',            # Mariage Beuzec-Conq 3 E 10/20/2 (an XII)
	'AN13' => '1269096',            # Mariage Beuzec-Conq 3 E 10/20/3 (an XIII)
	'AN14' => '1269097',            # Mariage Beuzec-Conq 3 E 10/20/4 (an XIV - 1806)
	1807   => '1269098',            # Mariage Beuzec-Conq 3 E 10/20/5 (1807)
	1808   => '1269099',            # Mariage Beuzec-Conq 3 E 10/20/6 (1808)
	1809   => '1269100',            # Mariage Beuzec-Conq 3 E 10/20/7 (1809)
	1810   => '1269101',            # Mariage Beuzec-Conq 3 E 10/20/8 (1810)
	1811   => '1269102',            # Mariage Beuzec-Conq 3 E 10/20/9 (1811)
	1812   => '1269103',            # Mariage Beuzec-Conq 3 E 10/20/10 (1812)
    },

    '3E010_0021' => {			# Mariage Beuzec-Conq 3 E 10 21   1813-1822
	1813   => '1269105',            # Mariage Beuzec-Conq 3 E 10/21/1 (1813)
	1814   => '1269106',            # Mariage Beuzec-Conq 3 E 10/21/2 (1814)
	1815   => '1269107',            # Mariage Beuzec-Conq 3 E 10/21/3 (1815)
	1816   => '1269108',            # Mariage Beuzec-Conq 3 E 10/21/4 (1816)
	1817   => '1269109',            # Mariage Beuzec-Conq 3 E 10/21/5 (1817)
	1818   => '1269110',            # Mariage Beuzec-Conq 3 E 10/21/6 (1818)
	1819   => '1269111',            # Mariage Beuzec-Conq 3 E 10/21/7 (1819)
	1820   => '1269112',            # Mariage Beuzec-Conq 3 E 10/21/8 (1820)
	1821   => '1269113',            # Mariage Beuzec-Conq 3 E 10/21/9 (1821)
	1822   => '1269114',            # Mariage Beuzec-Conq 3 E 10/21/10 (1822)
    },

    '3E010_0022' => {			# Mariage Beuzec-Conq 3 E 10 22   1823-1832
	1823   => '1269116',            # Mariage Beuzec-Conq 3 E 10/22/1 (1823)
	1824   => '1269117',            # Mariage Beuzec-Conq 3 E 10/22/2 (1824)
	1825   => '1269118',            # Mariage Beuzec-Conq 3 E 10/22/3 (1825)
	1826   => '1269119',            # Mariage Beuzec-Conq 3 E 10/22/4 (1826)
	1827   => '1269120',            # Mariage Beuzec-Conq 3 E 10/22/5 (1827)
	1828   => '1269121',            # Mariage Beuzec-Conq 3 E 10/22/6 (1828)
	1829   => '1269122',            # Mariage Beuzec-Conq 3 E 10/22/7 (1829)
	1830   => '1269123',            # Mariage Beuzec-Conq 3 E 10/22/8 (1830)
	1831   => '1269124',            # Mariage Beuzec-Conq 3 E 10/22/9 (1831)
	1832   => '1269125',            # Mariage Beuzec-Conq 3 E 10/22/10 (1832)
    },

    '3E010_0023' => {			# Mariage Beuzec-Conq 3 E 10 23   1833-1842
	1833   => '1269127',            # Mariage Beuzec-Conq 3 E 10/23/1 (1833)
	1834   => '1269128',            # Mariage Beuzec-Conq 3 E 10/23/2 (1834)
	1835   => '1269129',            # Mariage Beuzec-Conq 3 E 10/23/3 (1835)
	1836   => '1269130',            # Mariage Beuzec-Conq 3 E 10/23/4 (1836)
	1837   => '1269131',            # Mariage Beuzec-Conq 3 E 10/23/5 (1837)
	1838   => '1269132',            # Mariage Beuzec-Conq 3 E 10/23/6 (1838)
	1839   => '1269133',            # Mariage Beuzec-Conq 3 E 10/23/7 (1839)
	1840   => '1269134',            # Mariage Beuzec-Conq 3 E 10/23/8 (1840)
	1841   => '1269135',            # Mariage Beuzec-Conq 3 E 10/23/9 (1841)
	1842   => '1269136',            # Mariage Beuzec-Conq 3 E 10/23/10 (1842)
    },

    '3E010_0024' => {			# Mariage Beuzec-Conq 3 E 10 24   1843-1852
	1843   => '1269138',            # Mariage Beuzec-Conq 3 E 10/24/1 (1843)
	1844   => '1269139',            # Mariage Beuzec-Conq 3 E 10/24/2 (1844)
	1845   => '1269140',            # Mariage Beuzec-Conq 3 E 10/24/3 (1845)
	1846   => '1269141',            # Mariage Beuzec-Conq 3 E 10/24/4 (1846)
	1847   => '1269142',            # Mariage Beuzec-Conq 3 E 10/24/5 (1847)
	1848   => '1269143',            # Mariage Beuzec-Conq 3 E 10/24/6 (1848)
	1849   => '1269144',            # Mariage Beuzec-Conq 3 E 10/24/7 (1849)
	1850   => '1269145',            # Mariage Beuzec-Conq 3 E 10/24/8 (1850)
	1851   => '1269146',            # Mariage Beuzec-Conq 3 E 10/24/9 (1851)
	1852   => '1269147',            # Mariage Beuzec-Conq 3 E 10/24/10 (1852)
    },

    '3E010_0025' => {			# Mariage Beuzec-Conq 3 E 10 25   1853-1862
	1853   => '1269149',            # Mariage Beuzec-Conq 3 E 10/25/1 (1853)
	1854   => '1269150',            # Mariage Beuzec-Conq 3 E 10/25/2 (1854)
	1855   => '1269151',            # Mariage Beuzec-Conq 3 E 10/25/3 (1855)
	1856   => '1269152',            # Mariage Beuzec-Conq 3 E 10/25/4 (1856)
	1857   => '1269153',            # Mariage Beuzec-Conq 3 E 10/25/5 (1857)
	1858   => '1269154',            # Mariage Beuzec-Conq 3 E 10/25/6 (1858)
	1859   => '1269155',            # Mariage Beuzec-Conq 3 E 10/25/7 (1859)
	1860   => '1269156',            # Mariage Beuzec-Conq 3 E 10/25/8 (1860)
	1861   => '1269157',            # Mariage Beuzec-Conq 3 E 10/25/9 (1861)
	1862   => '1269158',            # Mariage Beuzec-Conq 3 E 10/25/10 (1862)
    },

    '3E010_0026' => {			# Mariage Beuzec-Conq 3 E 10 26   1863-1869
	1863   => '1269160',            # Mariage Beuzec-Conq 3 E 10/26/1 (1863)
	1864   => '1269161',            # Mariage Beuzec-Conq 3 E 10/26/2 (1864)
	1865   => '1269162',            # Mariage Beuzec-Conq 3 E 10/26/3 (1865)
	1866   => '1269163',            # Mariage Beuzec-Conq 3 E 10/26/4 (1866)
	1867   => '1269164',            # Mariage Beuzec-Conq 3 E 10/26/5 (1867)
	1868   => '1269165',            # Mariage Beuzec-Conq 3 E 10/26/6 (1868)
	1869   => '1269166',            # Mariage Beuzec-Conq 3 E 10/26/7 (1869)
    },

    '3E010_0027' => {			# Mariage Beuzec-Conq 3 E 10 27   1870-1888
	1870   => '1269168',            # Mariage Beuzec-Conq 3 E 10/27/1 (1870)
	1871   => '1269169',            # Mariage Beuzec-Conq 3 E 10/27/2 (1871)
	1872   => '1269170',            # Mariage Beuzec-Conq 3 E 10/27/3 (1872)
	1873   => '1269171',            # Mariage Beuzec-Conq 3 E 10/27/4 (1873)
	1874   => '1269172',            # Mariage Beuzec-Conq 3 E 10/27/5 (1874)
	1875   => '1269173',            # Mariage Beuzec-Conq 3 E 10/27/6 (1875)
	1876   => '1269174',            # Mariage Beuzec-Conq 3 E 10/27/7 (1876)
	1877   => '1269175',            # Mariage Beuzec-Conq 3 E 10/27/8 (1877)
	1878   => '1269176',            # Mariage Beuzec-Conq 3 E 10/27/9 (1878)
	1879   => '1269177',            # Mariage Beuzec-Conq 3 E 10/27/10 (1879)
	1880   => '1269178',            # Mariage Beuzec-Conq 3 E 10/27/11 (1880)
	1881   => '1269179',            # Mariage Beuzec-Conq 3 E 10/27/12 (1881)
	1882   => '1269180',            # Mariage Beuzec-Conq 3 E 10/27/13 (1882)
	1883   => '1269181',            # Mariage Beuzec-Conq 3 E 10/27/14 (1883)
	1884   => '1269182',            # Mariage Beuzec-Conq 3 E 10/27/15 (1884)
	1885   => '1269183',            # Mariage Beuzec-Conq 3 E 10/27/16 (1885)
	1886   => '1269184',            # Mariage Beuzec-Conq 3 E 10/27/17 (1886)
	1887   => '1269185',            # Mariage Beuzec-Conq 3 E 10/27/18 (1887)
	1888   => '1269186',            # Mariage Beuzec-Conq 3 E 10/27/19 (1888)
    },

    '3E010_0028' => {			# Décès Beuzec-Conq 3 E 10 28   AN02-AN10
	'AN02' => '1269252',            # Décès Beuzec-Conq 3 E 10/28/1 (1793 - an II)
	'AN03' => '1269253',            # Décès Beuzec-Conq 3 E 10/28/2 (an III)
	'AN04' => '1269254',            # Décès Beuzec-Conq 3 E 10/28/3 (an IV)
	'AN05' => '1269255',            # Décès Beuzec-Conq 3 E 10/28/4 (an V)
	'AN06' => '1269256',            # Décès Beuzec-Conq 3 E 10/28/5 (an VI)
	'AN07' => '1269257',            # Décès Beuzec-Conq 3 E 10/28/6 (an VII)
	'AN08' => '1269258',            # Décès Beuzec-Conq 3 E 10/28/7 (an VIII)
	'AN09' => '1269259',            # Décès Beuzec-Conq 3 E 10/28/8 (an IX)
	'AN10' => '1269260',            # Décès Beuzec-Conq 3 E 10/28/9 (an X)
    },

    '3E010_0029' => {			# Décès Beuzec-Conq 3 E 10 29   AN11-1812
	'AN11' => '1269262',            # Décès Beuzec-Conq 3 E 10/29/1 (an XI)
	'AN12' => '1269263',            # Décès Beuzec-Conq 3 E 10/29/2 (an XII)
	'AN13' => '1269264',            # Décès Beuzec-Conq 3 E 10/29/3 (an XIII)
	'AN14' => '1269265',            # Décès Beuzec-Conq 3 E 10/29/4 (an XIV - 1806)
	1807   => '1269266',            # Décès Beuzec-Conq 3 E 10/29/5 (1807)
	1808   => '1269267',            # Décès Beuzec-Conq 3 E 10/29/6 (1808)
	1809   => '1269268',            # Décès Beuzec-Conq 3 E 10/29/7 (1809)
	1810   => '1269269',            # Décès Beuzec-Conq 3 E 10/29/8 (1810)
	1811   => '1269270',            # Décès Beuzec-Conq 3 E 10/29/9 (1811)
	1812   => '1269271',            # Décès Beuzec-Conq 3 E 10/29/10 (1812)
    },

    '3E010_0030' => {			# Décès Beuzec-Conq 3 E 10 30   1813-1822
	1813   => '1269273',            # Décès Beuzec-Conq 3 E 10/30/1 (1813)
	1814   => '1269274',            # Décès Beuzec-Conq 3 E 10/30/2 (1814)
	1815   => '1269275',            # Décès Beuzec-Conq 3 E 10/30/3 (1815)
	1816   => '1269276',            # Décès Beuzec-Conq 3 E 10/30/4 (1816)
	1817   => '1269277',            # Décès Beuzec-Conq 3 E 10/30/5 (1817)
	1818   => '1269278',            # Décès Beuzec-Conq 3 E 10/30/6 (1818)
	1819   => '1269279',            # Décès Beuzec-Conq 3 E 10/30/7 (1819)
	1820   => '1269280',            # Décès Beuzec-Conq 3 E 10/30/8 (1820)
	1821   => '1269281',            # Décès Beuzec-Conq 3 E 10/30/9 (1821)
	1822   => '1269282',            # Décès Beuzec-Conq 3 E 10/30/10 (1822)
    },

    '3E010_0031' => {			# Décès Beuzec-Conq 3 E 10 31   1823-1832
	1823   => '1269284',            # Décès Beuzec-Conq 3 E 10/31/1 (1823)
	1824   => '1269285',            # Décès Beuzec-Conq 3 E 10/31/2 (1824)
	1825   => '1269286',            # Décès Beuzec-Conq 3 E 10/31/3 (1825)
	1826   => '1269287',            # Décès Beuzec-Conq 3 E 10/31/4 (1826)
	1827   => '1269288',            # Décès Beuzec-Conq 3 E 10/31/5 (1827)
	1828   => '1269289',            # Décès Beuzec-Conq 3 E 10/31/6 (1828)
	1829   => '1269290',            # Décès Beuzec-Conq 3 E 10/31/7 (1829)
	1830   => '1269291',            # Décès Beuzec-Conq 3 E 10/31/8 (1830)
	1831   => '1269292',            # Décès Beuzec-Conq 3 E 10/31/9 (1831)
	1832   => '1269293',            # Décès Beuzec-Conq 3 E 10/31/10 (1832)
    },

    '3E010_0032' => {			# Décès Beuzec-Conq 3 E 10 32   1833-1842
	1833   => '1269295',            # Décès Beuzec-Conq 3 E 10/32/1 (1833)
	1834   => '1269296',            # Décès Beuzec-Conq 3 E 10/32/2 (1834)
	1835   => '1269297',            # Décès Beuzec-Conq 3 E 10/32/3 (1835)
	1836   => '1269298',            # Décès Beuzec-Conq 3 E 10/32/4 (1836)
	1837   => '1269299',            # Décès Beuzec-Conq 3 E 10/32/5 (1837)
	1838   => '1269300',            # Décès Beuzec-Conq 3 E 10/32/6 (1838)
	1839   => '1269301',            # Décès Beuzec-Conq 3 E 10/32/7 (1839)
	1840   => '1269302',            # Décès Beuzec-Conq 3 E 10/32/8 (1840)
	1841   => '1269303',            # Décès Beuzec-Conq 3 E 10/32/9 (1841)
	1842   => '1269304',            # Décès Beuzec-Conq 3 E 10/32/10 (1842)
    },

    '3E010_0033' => {			# Décès Beuzec-Conq 3 E 10 33   1843-1852
	1843   => '1269306',            # Décès Beuzec-Conq 3 E 10/33/1 (1843)
	1844   => '1269307',            # Décès Beuzec-Conq 3 E 10/33/2 (1844)
	1845   => '1269308',            # Décès Beuzec-Conq 3 E 10/33/3 (1845)
	1846   => '1269309',            # Décès Beuzec-Conq 3 E 10/33/4 (1846)
	1847   => '1269310',            # Décès Beuzec-Conq 3 E 10/33/5 (1847)
	1848   => '1269311',            # Décès Beuzec-Conq 3 E 10/33/6 (1848)
	1849   => '1269312',            # Décès Beuzec-Conq 3 E 10/33/7 (1849)
	1850   => '1269313',            # Décès Beuzec-Conq 3 E 10/33/8 (1850)
	1851   => '1269314',            # Décès Beuzec-Conq 3 E 10/33/9 (1851)
	1852   => '1269315',            # Décès Beuzec-Conq 3 E 10/33/10 (1852)
    },

    '3E010_0034' => {			# Décès Beuzec-Conq 3 E 10 34   1853-1862
	1853   => '1269317',            # Décès Beuzec-Conq 3 E 10/34/1 (1853)
	1854   => '1269318',            # Décès Beuzec-Conq 3 E 10/34/2 (1854)
	1855   => '1269319',            # Décès Beuzec-Conq 3 E 10/34/3 (1855)
	1856   => '1269320',            # Décès Beuzec-Conq 3 E 10/34/4 (1856)
	1857   => '1269321',            # Décès Beuzec-Conq 3 E 10/34/5 (1857)
	1858   => '1269322',            # Décès Beuzec-Conq 3 E 10/34/6 (1858)
	1859   => '1269323',            # Décès Beuzec-Conq 3 E 10/34/7 (1859)
	1860   => '1269324',            # Décès Beuzec-Conq 3 E 10/34/8 (1860)
	1861   => '1269325',            # Décès Beuzec-Conq 3 E 10/34/9 (1861)
	1862   => '1269326',            # Décès Beuzec-Conq 3 E 10/34/10 (1862)
    },

    '3E010_0035' => {			# Décès Beuzec-Conq 3 E 10 35   1863-1869
	1863   => '1269328',            # Décès Beuzec-Conq 3 E 10/35/1 (1863)
	1864   => '1269329',            # Décès Beuzec-Conq 3 E 10/35/2 (1864)
	1865   => '1269330',            # Décès Beuzec-Conq 3 E 10/35/3 (1865)
	1866   => '1269331',            # Décès Beuzec-Conq 3 E 10/35/4 (1866)
	1867   => '1269332',            # Décès Beuzec-Conq 3 E 10/35/5 (1867)
	1868   => '1269333',            # Décès Beuzec-Conq 3 E 10/35/6 (1868)
	1869   => '1269334',            # Décès Beuzec-Conq 3 E 10/35/7 (1869)
    },

    '3E010_0036' => {			# Décès Beuzec-Conq 3 E 10 36   1870-1884
	1870   => '1269336',            # Décès Beuzec-Conq 3 E 10/36/1 (1870)
	1871   => '1269337',            # Décès Beuzec-Conq 3 E 10/36/2 (1871)
	1872   => '1269338',            # Décès Beuzec-Conq 3 E 10/36/3 (1872)
	1873   => '1269339',            # Décès Beuzec-Conq 3 E 10/36/4 (1873)
	1874   => '1269340',            # Décès Beuzec-Conq 3 E 10/36/5 (1874)
	1875   => '1269341',            # Décès Beuzec-Conq 3 E 10/36/6 (1875)
	1876   => '1269342',            # Décès Beuzec-Conq 3 E 10/36/7 (1876)
	1877   => '1269343',            # Décès Beuzec-Conq 3 E 10/36/8 (1877)
	1878   => '1269344',            # Décès Beuzec-Conq 3 E 10/36/9 (1878)
	1879   => '1269345',            # Décès Beuzec-Conq 3 E 10/36/10 (1879)
	1880   => '1269346',            # Décès Beuzec-Conq 3 E 10/36/11 (1880)
	1881   => '1269347',            # Décès Beuzec-Conq 3 E 10/36/12 (1881)
	1882   => '1269348',            # Décès Beuzec-Conq 3 E 10/36/13 (1882)
	1883   => '1269349',            # Décès Beuzec-Conq 3 E 10/36/14 (1883)
	1884   => '1269350',            # Décès Beuzec-Conq 3 E 10/36/15 (1884)
    },

    '3E010_0037' => {			# Décès Beuzec-Conq 3 E 10 37   1885-1894
	1885   => '1269352',            # Décès Beuzec-Conq 3 E 10/37/1 (1885)
	1886   => '1269353',            # Décès Beuzec-Conq 3 E 10/37/2 (1886)
	1887   => '1269354',            # Décès Beuzec-Conq 3 E 10/37/3 (1887)
	1888   => '1269355',            # Décès Beuzec-Conq 3 E 10/37/4 (1888)
	1889   => '1269356',            # Décès Beuzec-Conq 3 E 10/37/5 (1889)
	1890   => '1269357',            # Décès Beuzec-Conq 3 E 10/37/6 (1890)
	1891   => '1269358',            # Décès Beuzec-Conq 3 E 10/37/7 (1891)
	1892   => '1269359',            # Décès Beuzec-Conq 3 E 10/37/8 (1892)
	1893   => '1269360',            # Décès Beuzec-Conq 3 E 10/37/9 (1893)
	1894   => '1269361',            # Décès Beuzec-Conq 3 E 10/37/10 (1894)
    },

    '3E010_0038' => {			# Naissance Beuzec-Conq 3 E 10 38   1891-1896
	1891   => '1269033',            # Naissance Beuzec-Conq 3 E 10/38/1 (1891)
	1892   => '1269034',            # Naissance Beuzec-Conq 3 E 10/38/2 (1892)
	1893   => '1269035',            # Naissance Beuzec-Conq 3 E 10/38/3 (1893)
	1894   => '1269036',            # Naissance Beuzec-Conq 3 E 10/38/4 (1894)
	1895   => '1269037',            # Naissance Beuzec-Conq 3 E 10/38/5 (1895)
	1896   => '1269038',            # Naissance Beuzec-Conq 3 E 10/38/6 (1896)
    },

    '3E010_0039' => {			# Mariage Beuzec-Conq 3 E 10 39   1889-1899
	1889   => '1269188',            # Mariage Beuzec-Conq 3 E 10/39/1 (1889)
	1890   => '1269189',            # Mariage Beuzec-Conq 3 E 10/39/2 (1890)
	1891   => '1269190',            # Mariage Beuzec-Conq 3 E 10/39/3 (1891)
	1892   => '1269191',            # Mariage Beuzec-Conq 3 E 10/39/4 (1892)
	1893   => '1269192',            # Mariage Beuzec-Conq 3 E 10/39/5 (1893)
	1894   => '1269193',            # Mariage Beuzec-Conq 3 E 10/39/6 (1894)
	1895   => '1269194',            # Mariage Beuzec-Conq 3 E 10/39/7 (1895)
	1896   => '1269195',            # Mariage Beuzec-Conq 3 E 10/39/8 (1896)
	1897   => '1269196',            # Mariage Beuzec-Conq 3 E 10/39/9 (1897)
	1898   => '1269197',            # Mariage Beuzec-Conq 3 E 10/39/10 (1898)
	1899   => '1269198',            # Mariage Beuzec-Conq 3 E 10/39/11 (1899)
    },

    '3E010_0040' => {			# Naissance Beuzec-Conq 3 E 10 40   1897-1903
	1897   => '1269040',            # Naissance Beuzec-Conq 3 E 10/40/1 (1897)
	1898   => '1269041',            # Naissance Beuzec-Conq 3 E 10/40/2 (1898)
	1899   => '1269042',            # Naissance Beuzec-Conq 3 E 10/40/3 (1899)
	1900   => '1269043',            # Naissance Beuzec-Conq 3 E 10/40/4 (1900)
	1901   => '1269044',            # Naissance Beuzec-Conq 3 E 10/40/5 (1901)
	1902   => '1269045',            # Naissance Beuzec-Conq 3 E 10/40/6 (1902)
	1903   => '1269046',            # Naissance Beuzec-Conq 3 E 10/40/7 (1903)
    },

    '3E010_0041' => {			# Décès Beuzec-Conq 3 E 10 41   1895-1904
	1895   => '1269363',            # Décès Beuzec-Conq 3 E 10/41/1 (1895)
	1896   => '1269364',            # Décès Beuzec-Conq 3 E 10/41/2 (1896)
	1897   => '1269365',            # Décès Beuzec-Conq 3 E 10/41/3 (1897)
	1898   => '1269366',            # Décès Beuzec-Conq 3 E 10/41/4 (1898)
	1899   => '1269367',            # Décès Beuzec-Conq 3 E 10/41/5 (1899)
	1900   => '1269368',            # Décès Beuzec-Conq 3 E 10/41/6 (1900)
	1901   => '1269369',            # Décès Beuzec-Conq 3 E 10/41/7 (1901)
	1902   => '1269370',            # Décès Beuzec-Conq 3 E 10/41/8 (1902)
	1903   => '1269371',            # Décès Beuzec-Conq 3 E 10/41/9 (1903)
	1904   => '1269372',            # Décès Beuzec-Conq 3 E 10/41/10 (1904)
    },

    '3E010_0042' => {			# Mariage Beuzec-Conq 3 E 10 42   1900-1908
	1900   => '1269200',            # Mariage Beuzec-Conq 3 E 10/42/1 (1900)
	1901   => '1269201',            # Mariage Beuzec-Conq 3 E 10/42/2 (1901)
	1902   => '1269202',            # Mariage Beuzec-Conq 3 E 10/42/3 (1902)
	1903   => '1269203',            # Mariage Beuzec-Conq 3 E 10/42/4 (1903)
	1904   => '1269204',            # Mariage Beuzec-Conq 3 E 10/42/5 (1904)
	1905   => '1269205',            # Mariage Beuzec-Conq 3 E 10/42/6 (1905)
	1906   => '1269206',            # Mariage Beuzec-Conq 3 E 10/42/7 (1906)
	1907   => '1269207',            # Mariage Beuzec-Conq 3 E 10/42/8 (1907)
	1908   => '1269208',            # Mariage Beuzec-Conq 3 E 10/42/9 (1908)
    },

    '3E010_0043' => {			# Naissance Beuzec-Conq 3 E 10 43   1904-1909
	1904   => '1269048',            # Naissance Beuzec-Conq 3 E 10/43/1 (1904)
	1905   => '1269049',            # Naissance Beuzec-Conq 3 E 10/43/2 (1905)
	1906   => '1269050',            # Naissance Beuzec-Conq 3 E 10/43/3 (1906)
	1907   => '1269051',            # Naissance Beuzec-Conq 3 E 10/43/4 (1907)
	1908   => '1269052',            # Naissance Beuzec-Conq 3 E 10/43/5 (1908)
	1909   => '1269053',            # Naissance Beuzec-Conq 3 E 10/43/6 (1909)
    },

    '3E010_0044' => {			# Naissance Beuzec-Conq 3 E 10 44   1910-1915
	1910   => '1269055',            # Naissance Beuzec-Conq 3 E 10/44/1 (1910)
	1911   => '1269056',            # Naissance Beuzec-Conq 3 E 10/44/2 (1911)
	1912   => '1269057',            # Naissance Beuzec-Conq 3 E 10/44/3 (1912)
	1913   => '1269058',            # Naissance Beuzec-Conq 3 E 10/44/4 (1913)
	1914   => '1269059',            # Naissance Beuzec-Conq 3 E 10/44/5 (1914)
	1915   => '1269060',            # Naissance Beuzec-Conq 3 E 10/44/6 (1915)
    },

    '3E010_0045' => {			# Décès Beuzec-Conq 3 E 10 45   1905-1914
	1905   => '1269374',            # Décès Beuzec-Conq 3 E 10/45/1 (1905)
	1906   => '1269375',            # Décès Beuzec-Conq 3 E 10/45/2 (1906)
	1907   => '1269376',            # Décès Beuzec-Conq 3 E 10/45/3 (1907)
	1908   => '1269377',            # Décès Beuzec-Conq 3 E 10/45/4 (1908)
	1909   => '1269378',            # Décès Beuzec-Conq 3 E 10/45/5 (1909)
	1910   => '1269379',            # Décès Beuzec-Conq 3 E 10/45/6 (1910)
	1911   => '1269380',            # Décès Beuzec-Conq 3 E 10/45/7 (1911)
	1912   => '1269381',            # Décès Beuzec-Conq 3 E 10/45/8 (1912)
	1913   => '1269382',            # Décès Beuzec-Conq 3 E 10/45/9 (1913)
	1914   => '1269383',            # Décès Beuzec-Conq 3 E 10/45/10 (1914)
    },

    '3E010_0046' => {			# Naissance Beuzec-Conq 3 E 10 46   1916-1925
	1916   => '1269062',            # Naissance Beuzec-Conq 3 E 10/46/1 (1916)
	1917   => '1269063',            # Naissance Beuzec-Conq 3 E 10/46/2 (1917)
	1918   => '1269064',            # Naissance Beuzec-Conq 3 E 10/46/3 (1918)
	1919   => '1269065',            # Naissance Beuzec-Conq 3 E 10/46/4 (1919)
	1920   => '1269066',            # Naissance Beuzec-Conq 3 E 10/46/5 (1920)
	1921   => '1269067',            # Naissance Beuzec-Conq 3 E 10/46/6 (1921)
	1922   => '1269068',            # Naissance Beuzec-Conq 3 E 10/46/7 (1922)
	1923   => '1269069',            # Naissance Beuzec-Conq 3 E 10/46/8 (1923)
	1924   => '1269070',            # Naissance Beuzec-Conq 3 E 10/46/9 (1924)
	1925   => '1269071',            # Naissance Beuzec-Conq 3 E 10/46/10 (1925)
    },

    '3E010_0048' => {			# Mariage Beuzec-Conq 3 E 10 48   1909-1918
	1909   => '1269210',            # Mariage Beuzec-Conq 3 E 10/48/1 (1909)
	1910   => '1269211',            # Mariage Beuzec-Conq 3 E 10/48/2 (1910)
	1911   => '1269212',            # Mariage Beuzec-Conq 3 E 10/48/3 (1911)
	1912   => '1269213',            # Mariage Beuzec-Conq 3 E 10/48/4 (1912)
	1913   => '1269214',            # Mariage Beuzec-Conq 3 E 10/48/5 (1913)
	1914   => '1269215',            # Mariage Beuzec-Conq 3 E 10/48/6 (1914)
	1915   => '1269216',            # Mariage Beuzec-Conq 3 E 10/48/7 (1915)
	1916   => '1269217',            # Mariage Beuzec-Conq 3 E 10/48/8 (1916)
	1917   => '1269218',            # Mariage Beuzec-Conq 3 E 10/48/9 (1917)
	1918   => '1269219',            # Mariage Beuzec-Conq 3 E 10/48/10 (1918)
    },

    '3E010_0049' => {			# Mariage Beuzec-Conq 3 E 10 49   1919-1926
	1919   => '1269221',            # Mariage Beuzec-Conq 3 E 10/49/1 (1919)
	1920   => '1269222',            # Mariage Beuzec-Conq 3 E 10/49/2 (1920)
	1921   => '1269223',            # Mariage Beuzec-Conq 3 E 10/49/3 (1921)
	1922   => '1269224',            # Mariage Beuzec-Conq 3 E 10/49/4 (1922)
	1923   => '1269225',            # Mariage Beuzec-Conq 3 E 10/49/5 (1923)
	1924   => '1269226',            # Mariage Beuzec-Conq 3 E 10/49/6 (1924)
	1925   => '1269227',            # Mariage Beuzec-Conq 3 E 10/49/7 (1925)
	1926   => '1269228',            # Mariage Beuzec-Conq 3 E 10/49/8 (1926)
    },

    '3E010_0050' => {			# Mariage Beuzec-Conq 3 E 10 50   1927-1934
	1927   => '1269230',            # Mariage Beuzec-Conq 3 E 10/50/1 (1927)
	1928   => '1269231',            # Mariage Beuzec-Conq 3 E 10/50/2 (1928)
	1929   => '1269232',            # Mariage Beuzec-Conq 3 E 10/50/3 (1929)
	1930   => '1269233',            # Mariage Beuzec-Conq 3 E 10/50/4 (1930)
	1931   => '1269234',            # Mariage Beuzec-Conq 3 E 10/50/5 (1931)
	1932   => '1269235',            # Mariage Beuzec-Conq 3 E 10/50/6 (1932)
	1933   => '1269236',            # Mariage Beuzec-Conq 3 E 10/50/7 (1933)
	1934   => '1269237',            # Mariage Beuzec-Conq 3 E 10/50/8 (1934)
	1935   => '1269238',            # Mariage Beuzec-Conq 3 E 10/50/9 (1935)
	1936   => '1269239',            # Mariage Beuzec-Conq 3 E 10/50/10 (1936)
    },

    '3E010_0051' => {			# Décès Beuzec-Conq 3 E 10 51   1915-1924
	1915   => '1269385',            # Décès Beuzec-Conq 3 E 10/51/1 (1915)
	1916   => '1269386',            # Décès Beuzec-Conq 3 E 10/51/2 (1916)
	1917   => '1269387',            # Décès Beuzec-Conq 3 E 10/51/3 (1917)
	1918   => '1269388',            # Décès Beuzec-Conq 3 E 10/51/4 (1918)
	1919   => '1269389',            # Décès Beuzec-Conq 3 E 10/51/5 (1919)
	1920   => '1269390',            # Décès Beuzec-Conq 3 E 10/51/6 (1920)
	1921   => '1269391',            # Décès Beuzec-Conq 3 E 10/51/7 (1921)
	1922   => '1269392',            # Décès Beuzec-Conq 3 E 10/51/8 (1922)
	1923   => '1269393',            # Décès Beuzec-Conq 3 E 10/51/9 (1923)
	1924   => '1269394',            # Décès Beuzec-Conq 3 E 10/51/10 (1924)
    },

    '3E010_0052' => {			# Décès Beuzec-Conq 3 E 10 52   1925-1936
	1925   => '1269396',            # Décès Beuzec-Conq 3 E 10/52/1 (1925)
	1926   => '1269397',            # Décès Beuzec-Conq 3 E 10/52/2 (1926)
	1927   => '1269398',            # Décès Beuzec-Conq 3 E 10/52/3 (1927)
	1928   => '1269399',            # Décès Beuzec-Conq 3 E 10/52/4 (1928)
	1929   => '1269400',            # Décès Beuzec-Conq 3 E 10/52/5 (1929)
	1930   => '1269401',            # Décès Beuzec-Conq 3 E 10/52/6 (1930)
	1931   => '1269402',            # Décès Beuzec-Conq 3 E 10/52/7 (1931)
	1932   => '1269403',            # Décès Beuzec-Conq 3 E 10/52/8 (1932)
	1933   => '1269404',            # Décès Beuzec-Conq 3 E 10/52/9 (1933)
	1934   => '1269405',            # Décès Beuzec-Conq 3 E 10/52/10 (1934)
	1935   => '1269406',            # Décès Beuzec-Conq 3 E 10/52/11 (1935)
	1936   => '1269407',            # Décès Beuzec-Conq 3 E 10/52/12 (1936)
    },


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

    '3E037_0052' => {			# Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37 52   1924-1936
	1924   => '1275674',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/52/1 (1924)
	1925   => '1275675',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/52/2 (1925)
	1926   => '1275676',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/52/3 (1926)
	1927   => '1275677',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/52/4 (1927)
	1928   => '1275678',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/52/5 (1928)
	1929   => '1275679',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/52/6 (1929)
	1930   => '1275680',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/52/7 (1930)
	1931   => '1275681',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/52/8 (1931)
	1932   => '1275682',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/52/9 (1932)
	1933   => '1275683',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/52/10 (1933)
	1934   => '1275684',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/52/11 (1934)
	1935   => '1275685',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/52/12 (1935)
	1936   => '1275686',            # Mariage Carhaix (Carhaix-Plouguer, Finistère) 3 E 37/52/13 (1936)
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

    # NMD Châteauneuf-du-Faou
    '3E040_0011' => '652338.1276464',   # Naissance table des naissances table des mariages table des décès Châteauneuf-du-Faou 3 E 40 11 (1793-an X)
    '3E040_0012' => '652339.1276465',   # Naissance Châteauneuf-du-Faou 3 E 40 12 (An XI-1812)
    '3E040_0013' => '652340.1276466',   # Naissance Châteauneuf-du-Faou 3 E 40 13 (1813-1822)
    '3E040_0014' => '652341.1276467',   # Naissance Châteauneuf-du-Faou 3 E 40 14 (1823-1832)
    '3E040_0015' => '652342.1276468',   # Naissance Châteauneuf-du-Faou 3 E 40 15 (1833-1842)
    '3E040_0016' => '652343.1276469',   # Naissance Châteauneuf-du-Faou 3 E 40 16 (1843-1852)
    '3E040_0017' => '652344.1276470',   # Naissance Châteauneuf-du-Faou 3 E 40 17 (1853-1862)
    '3E040_0018' => '652345.1276471',   # Naissance Châteauneuf-du-Faou 3 E 40 18 (1863-1869)
    '3E040_0019' => '652346.1276472',   # Naissance Châteauneuf-du-Faou 3 E 40 19 (1870-1875)
    '3E040_0020' => '652347.1276473',   # Naissance Châteauneuf-du-Faou 3 E 40 20 (1876-1882)
    '3E040_0021' => '652348.1276474',   # Naissance Châteauneuf-du-Faou 3 E 40 21 (1883-1889)
    '3E040_0022' => '652349.1276529',   # Mariage publication de mariage promesse de mariage Châteauneuf-du-Faou 3 E 40 22 (1793-an X)
    '3E040_0023' => '652350.1276530',   # Mariage Châteauneuf-du-Faou 3 E 40 23 (An XI-1812)
    '3E040_0024' => '652351.1276531',   # Mariage Châteauneuf-du-Faou 3 E 40 24 (1813-1822)
    '3E040_0025' => '652352.1276532',   # Mariage Châteauneuf-du-Faou 3 E 40 25 (1823-1832)
    '3E040_0026' => '652353.1276533',   # Mariage Châteauneuf-du-Faou 3 E 40 26 (1833-1842)
    '3E040_0027' => '652354.1276534',   # Mariage Châteauneuf-du-Faou 3 E 40 27 (1843-1852)
    '3E040_0028' => '652355.1276535',   # Mariage Châteauneuf-du-Faou 3 E 40 28 (1853-1862)
    '3E040_0029' => '652356.1276536',   # Mariage Châteauneuf-du-Faou 3 E 40 29 (1863-1869)
    '3E040_0030' => '652357.1276537',   # Mariage Châteauneuf-du-Faou 3 E 40 30 (1870-1879)
    '3E040_0031' => '652358.1276538',   # Mariage Châteauneuf-du-Faou 3 E 40 31 (1880-1890)
    '3E040_0032' => '652359.1276591',   # Décès Châteauneuf-du-Faou 3 E 40 32 (1793-an X)
    '3E040_0033' => '652360.1276592',   # Décès Châteauneuf-du-Faou 3 E 40 33 (An XI-1812)
    '3E040_0034' => '652361.1276593',   # Décès Châteauneuf-du-Faou 3 E 40 34 (1813-1822)
    '3E040_0035' => '652362.1276594',   # Décès Châteauneuf-du-Faou 3 E 40 35 (1823-1832)
    '3E040_0036' => '652363.1276595',   # Décès Châteauneuf-du-Faou 3 E 40 36 (1833-1842)
    '3E040_0037' => '652364.1276596',   # Décès Châteauneuf-du-Faou 3 E 40 37 (1843-1852)
    '3E040_0038' => '652365.1276597',   # Décès Châteauneuf-du-Faou 3 E 40 38 (1853-1862)
    '3E040_0039' => '652366.1276598',   # Décès Châteauneuf-du-Faou 3 E 40 39 (1863-1869)
    '3E040_0040' => '652367.1276599',   # Décès Châteauneuf-du-Faou 3 E 40 40 (1870-1877)
    '3E040_0041' => '652368.1276600',   # Décès Châteauneuf-du-Faou 3 E 40 41 (1878-1887)
    '3E040_0042' => {			# Naissance Châteauneuf-du-Faou 3 E 40 42   1890-1896
	1890   => '1276476',            # Naissance Châteauneuf-du-Faou 3 E 40/42/1 (1890)
	1891   => '1276477',            # Naissance Châteauneuf-du-Faou 3 E 40/42/2 (1891)
	1892   => '1276478',            # Naissance Châteauneuf-du-Faou 3 E 40/42/3 (1892)
	1893   => '1276479',            # Naissance Châteauneuf-du-Faou 3 E 40/42/4 (1893)
	1894   => '1276480',            # Naissance Châteauneuf-du-Faou 3 E 40/42/5 (1894)
	1895   => '1276481',            # Naissance Châteauneuf-du-Faou 3 E 40/42/6 (1895)
	1896   => '1276482',            # Naissance Châteauneuf-du-Faou 3 E 40/42/7 (1896)
    },

    '3E040_0043' => {			# Mariage Châteauneuf-du-Faou 3 E 40 43   1891-1900
	1891   => '1276540',            # Mariage Châteauneuf-du-Faou 3 E 40/43/1 (1891)
	1892   => '1276541',            # Mariage Châteauneuf-du-Faou 3 E 40/43/2 (1892)
	1893   => '1276542',            # Mariage Châteauneuf-du-Faou 3 E 40/43/3 (1893)
	1894   => '1276543',            # Mariage Châteauneuf-du-Faou 3 E 40/43/4 (1894)
	1895   => '1276544',            # Mariage Châteauneuf-du-Faou 3 E 40/43/5 (1895)
	1896   => '1276545',            # Mariage Châteauneuf-du-Faou 3 E 40/43/6 (1896)
	1897   => '1276546',            # Mariage Châteauneuf-du-Faou 3 E 40/43/7 (1897)
	1898   => '1276547',            # Mariage Châteauneuf-du-Faou 3 E 40/43/8 (1898)
	1899   => '1276548',            # Mariage Châteauneuf-du-Faou 3 E 40/43/9 (1899)
	1900   => '1276549',            # Mariage Châteauneuf-du-Faou 3 E 40/43/10 (1900)
    },

    '3E040_0044' => {			# Décès Châteauneuf-du-Faou 3 E 40 44   1888-1897
	1888   => '1276602',            # Décès Châteauneuf-du-Faou 3 E 40/44/1 (1888)
	1889   => '1276603',            # Décès Châteauneuf-du-Faou 3 E 40/44/2 (1889)
	1890   => '1276604',            # Décès Châteauneuf-du-Faou 3 E 40/44/3 (1890)
	1891   => '1276605',            # Décès Châteauneuf-du-Faou 3 E 40/44/4 (1891)
	1892   => '1276606',            # Décès Châteauneuf-du-Faou 3 E 40/44/5 (1892)
	1893   => '1276607',            # Décès Châteauneuf-du-Faou 3 E 40/44/6 (1893)
	1894   => '1276608',            # Décès Châteauneuf-du-Faou 3 E 40/44/7 (1894)
	1895   => '1276609',            # Décès Châteauneuf-du-Faou 3 E 40/44/8 (1895)
	1896   => '1276610',            # Décès Châteauneuf-du-Faou 3 E 40/44/9 (1896)
	1897   => '1276611',            # Décès Châteauneuf-du-Faou 3 E 40/44/10 (1897)
    },

    '3E040_0045' => {			# Naissance Châteauneuf-du-Faou 3 E 40 45   1897-1903
	1897   => '1276484',            # Naissance Châteauneuf-du-Faou 3 E 40/45/1 (1897)
	1898   => '1276485',            # Naissance Châteauneuf-du-Faou 3 E 40/45/2 (1898)
	1899   => '1276486',            # Naissance Châteauneuf-du-Faou 3 E 40/45/3 (1899)
	1900   => '1276487',            # Naissance Châteauneuf-du-Faou 3 E 40/45/4 (1900)
	1901   => '1276488',            # Naissance Châteauneuf-du-Faou 3 E 40/45/5 (1901)
	1902   => '1276489',            # Naissance Châteauneuf-du-Faou 3 E 40/45/6 (1902)
	1903   => '1276490',            # Naissance Châteauneuf-du-Faou 3 E 40/45/7 (1903)
    },

    '3E040_0046' => {			# Décès Châteauneuf-du-Faou 3 E 40 46   1898-1907
	1898   => '1276613',            # Décès Châteauneuf-du-Faou 3 E 40/46/1 (1898)
	1899   => '1276614',            # Décès Châteauneuf-du-Faou 3 E 40/46/2 (1899)
	1900   => '1276615',            # Décès Châteauneuf-du-Faou 3 E 40/46/3 (1900)
	1901   => '1276616',            # Décès Châteauneuf-du-Faou 3 E 40/46/4 (1901)
	1902   => '1276617',            # Décès Châteauneuf-du-Faou 3 E 40/46/5 (1902)
	1903   => '1276618',            # Décès Châteauneuf-du-Faou 3 E 40/46/6 (1903)
	1904   => '1276619',            # Décès Châteauneuf-du-Faou 3 E 40/46/7 (1904)
	1905   => '1276620',            # Décès Châteauneuf-du-Faou 3 E 40/46/8 (1905)
	1906   => '1276621',            # Décès Châteauneuf-du-Faou 3 E 40/46/9 (1906)
	1907   => '1276622',            # Décès Châteauneuf-du-Faou 3 E 40/46/10 (1907)
    },

    '3E040_0047' => {			# Mariage Châteauneuf-du-Faou 3 E 40 47   1901-1909
	1901   => '1276551',            # Mariage Châteauneuf-du-Faou 3 E 40/47/1 (1901)
	1902   => '1276552',            # Mariage Châteauneuf-du-Faou 3 E 40/47/2 (1902)
	1903   => '1276553',            # Mariage Châteauneuf-du-Faou 3 E 40/47/3 (1903)
	1904   => '1276554',            # Mariage Châteauneuf-du-Faou 3 E 40/47/4 (1904)
	1905   => '1276555',            # Mariage Châteauneuf-du-Faou 3 E 40/47/5 (1905)
	1906   => '1276556',            # Mariage Châteauneuf-du-Faou 3 E 40/47/6 (1906)
	1907   => '1276557',            # Mariage Châteauneuf-du-Faou 3 E 40/47/7 (1907)
	1908   => '1276558',            # Mariage Châteauneuf-du-Faou 3 E 40/47/8 (1908)
	1909   => '1276559',            # Mariage Châteauneuf-du-Faou 3 E 40/47/9 (1909)
    },

    '3E040_0048' => {			# Naissance Châteauneuf-du-Faou 3 E 40 48   1904-1910
	1904   => '1276492',            # Naissance Châteauneuf-du-Faou 3 E 40/48/1 (1904)
	1905   => '1276493',            # Naissance Châteauneuf-du-Faou 3 E 40/48/2 (1905)
	1906   => '1276494',            # Naissance Châteauneuf-du-Faou 3 E 40/48/3 (1906)
	1907   => '1276495',            # Naissance Châteauneuf-du-Faou 3 E 40/48/4 (1907)
	1908   => '1276496',            # Naissance Châteauneuf-du-Faou 3 E 40/48/5 (1908)
	1909   => '1276497',            # Naissance Châteauneuf-du-Faou 3 E 40/48/6 (1909)
	1910   => '1276498',            # Naissance Châteauneuf-du-Faou 3 E 40/48/7 (1910)
    },

    '3E040_0049' => {			# Naissance Châteauneuf-du-Faou 3 E 40 49   1911-1917
	1911   => '1276500',            # Naissance Châteauneuf-du-Faou 3 E 40/49/1 (1911)
	1912   => '1276501',            # Naissance Châteauneuf-du-Faou 3 E 40/49/2 (1912)
	1913   => '1276502',            # Naissance Châteauneuf-du-Faou 3 E 40/49/3 (1913)
	1914   => '1276503',            # Naissance Châteauneuf-du-Faou 3 E 40/49/4 (1914)
	1915   => '1276504',            # Naissance Châteauneuf-du-Faou 3 E 40/49/5 (1915)
	1916   => '1276505',            # Naissance Châteauneuf-du-Faou 3 E 40/49/6 (1916)
	1917   => '1276506',            # Naissance Châteauneuf-du-Faou 3 E 40/49/7 (1917)
    },

    '3E040_0050' => {			# Naissance Châteauneuf-du-Faou 3 E 40 50   1918-1925
	1918   => '1276508',            # Naissance Châteauneuf-du-Faou 3 E 40/50/1 (1918)
	1919   => '1276509',            # Naissance Châteauneuf-du-Faou 3 E 40/50/2 (1919)
	1920   => '1276510',            # Naissance Châteauneuf-du-Faou 3 E 40/50/3 (1920)
	1921   => '1276511',            # Naissance Châteauneuf-du-Faou 3 E 40/50/4 (1921)
	1922   => '1276512',            # Naissance Châteauneuf-du-Faou 3 E 40/50/5 (1922)
	1923   => '1276513',            # Naissance Châteauneuf-du-Faou 3 E 40/50/6 (1923)
	1924   => '1276514',            # Naissance Châteauneuf-du-Faou 3 E 40/50/7 (1924)
	1925   => '1276515',            # Naissance Châteauneuf-du-Faou 3 E 40/50/8 (1925)
    },

    '3E040_0052' => {			# Mariage Châteauneuf-du-Faou 3 E 40 52   1910-1917
	1910   => '1276561',            # Mariage Châteauneuf-du-Faou 3 E 40/52/1 (1910)
	1911   => '1276562',            # Mariage Châteauneuf-du-Faou 3 E 40/52/2 (1911)
	1912   => '1276563',            # Mariage Châteauneuf-du-Faou 3 E 40/52/3 (1912)
	1913   => '1276564',            # Mariage Châteauneuf-du-Faou 3 E 40/52/4 (1913)
	1914   => '1276565',            # Mariage Châteauneuf-du-Faou 3 E 40/52/5 (1914)
	1915   => '1276566',            # Mariage Châteauneuf-du-Faou 3 E 40/52/6 (1915)
	1916   => '1276567',            # Mariage Châteauneuf-du-Faou 3 E 40/52/7 (1916)
	1917   => '1276568',            # Mariage Châteauneuf-du-Faou 3 E 40/52/8 (1917)
    },

    '3E040_0053' => {			# Mariage Châteauneuf-du-Faou 3 E 40 53   1918-1925
	1918   => '1276570',            # Mariage Châteauneuf-du-Faou 3 E 40/53/1 (1918)
	1919   => '1276571',            # Mariage Châteauneuf-du-Faou 3 E 40/53/2 (1919)
	1920   => '1276572',            # Mariage Châteauneuf-du-Faou 3 E 40/53/3 (1920)
	1921   => '1276573',            # Mariage Châteauneuf-du-Faou 3 E 40/53/4 (1921)
	1922   => '1276574',            # Mariage Châteauneuf-du-Faou 3 E 40/53/5 (1922)
	1923   => '1276575',            # Mariage Châteauneuf-du-Faou 3 E 40/53/6 (1923)
	1924   => '1276576',            # Mariage Châteauneuf-du-Faou 3 E 40/53/7 (1924)
	1925   => '1276577',            # Mariage Châteauneuf-du-Faou 3 E 40/53/8 (1925)
    },

    '3E040_0054' => {			# Mariage Châteauneuf-du-Faou 3 E 40 54   1926-1936
	1926   => '1276579',            # Mariage Châteauneuf-du-Faou 3 E 40/54/1 (1926)
	1927   => '1276580',            # Mariage Châteauneuf-du-Faou 3 E 40/54/2 (1927)
	1928   => '1276581',            # Mariage Châteauneuf-du-Faou 3 E 40/54/3 (1928)
	1929   => '1276582',            # Mariage Châteauneuf-du-Faou 3 E 40/54/4 (1929)
	1930   => '1276583',            # Mariage Châteauneuf-du-Faou 3 E 40/54/5 (1930)
	1931   => '1276584',            # Mariage Châteauneuf-du-Faou 3 E 40/54/6 (1931)
	1932   => '1276585',            # Mariage Châteauneuf-du-Faou 3 E 40/54/7 (1932)
	1933   => '1276586',            # Mariage Châteauneuf-du-Faou 3 E 40/54/8 (1933)
	1934   => '1276587',            # Mariage Châteauneuf-du-Faou 3 E 40/54/9 (1934)
	1935   => '1276588',            # Mariage Châteauneuf-du-Faou 3 E 40/54/10 (1935)
	1936   => '1276589',            # Mariage Châteauneuf-du-Faou 3 E 40/54/11 (1936)
    },

    '3E040_0055' => {			# Décès Châteauneuf-du-Faou 3 E 40 55   1908-1917
	1908   => '1276624',            # Décès Châteauneuf-du-Faou 3 E 40/55/1 (1908)
	1909   => '1276625',            # Décès Châteauneuf-du-Faou 3 E 40/55/2 (1909)
	1910   => '1276626',            # Décès Châteauneuf-du-Faou 3 E 40/55/3 (1910)
	1911   => '1276627',            # Décès Châteauneuf-du-Faou 3 E 40/55/4 (1911)
	1912   => '1276628',            # Décès Châteauneuf-du-Faou 3 E 40/55/5 (1912)
	1913   => '1276629',            # Décès Châteauneuf-du-Faou 3 E 40/55/6 (1913)
	1914   => '1276630',            # Décès Châteauneuf-du-Faou 3 E 40/55/7 (1914)
	1915   => '1276631',            # Décès Châteauneuf-du-Faou 3 E 40/55/8 (1915)
	1916   => '1276632',            # Décès Châteauneuf-du-Faou 3 E 40/55/9 (1916)
	1917   => '1276633',            # Décès Châteauneuf-du-Faou 3 E 40/55/10 (1917)
    },

    '3E040_0056' => {			# Décès Châteauneuf-du-Faou 3 E 40 56   1918-1927
	1918   => '1276635',            # Décès Châteauneuf-du-Faou 3 E 40/56/1 (1918)
	1919   => '1276636',            # Décès Châteauneuf-du-Faou 3 E 40/56/2 (1919)
	1920   => '1276637',            # Décès Châteauneuf-du-Faou 3 E 40/56/3 (1920)
	1921   => '1276638',            # Décès Châteauneuf-du-Faou 3 E 40/56/4 (1921)
	1922   => '1276639',            # Décès Châteauneuf-du-Faou 3 E 40/56/5 (1922)
	1923   => '1276640',            # Décès Châteauneuf-du-Faou 3 E 40/56/6 (1923)
	1924   => '1276641',            # Décès Châteauneuf-du-Faou 3 E 40/56/7 (1924)
	1925   => '1276642',            # Décès Châteauneuf-du-Faou 3 E 40/56/8 (1925)
	1926   => '1276643',            # Décès Châteauneuf-du-Faou 3 E 40/56/9 (1926)
	1927   => '1276644',            # Décès Châteauneuf-du-Faou 3 E 40/56/10 (1927)
    },

    '3E040_0057' => {			# Décès Châteauneuf-du-Faou 3 E 40 57   1928-1936
	1928   => '1276646',            # Décès Châteauneuf-du-Faou 3 E 40/57/1 (1928)
	1929   => '1276647',            # Décès Châteauneuf-du-Faou 3 E 40/57/2 (1929)
	1930   => '1276648',            # Décès Châteauneuf-du-Faou 3 E 40/57/3 (1930)
	1931   => '1276649',            # Décès Châteauneuf-du-Faou 3 E 40/57/4 (1931)
	1932   => '1276650',            # Décès Châteauneuf-du-Faou 3 E 40/57/5 (1932)
	1933   => '1276651',            # Décès Châteauneuf-du-Faou 3 E 40/57/6 (1933)
	1934   => '1276652',            # Décès Châteauneuf-du-Faou 3 E 40/57/7 (1934)
	1935   => '1276653',            # Décès Châteauneuf-du-Faou 3 E 40/57/8 (1935)
	1936   => '1276654',            # Décès Châteauneuf-du-Faou 3 E 40/57/9 (1936)
    },


    # NMD Cléden-Poher
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

    '3E042_0020' => {			# Mariage Cléden-Poher 3 E 42 20   AN10-AN10
	'AN02' => '1277336',            # Mariage Cléden-Poher 3 E 42/20/1 (1793 - an II)
	'AN03' => '1277337',            # Mariage Cléden-Poher 3 E 42/20/2 (an III)
	'AN04' => '1277338',            # Mariage Cléden-Poher 3 E 42/20/3 (an IV)
	'AN05' => '1277339',            # Mariage Cléden-Poher 3 E 42/20/4 (an V)
	'AN06' => '1277340',            # Mariage Cléden-Poher 3 E 42/20/5 (an VI)
	'AN07' => '1277341',            # Mariage Cléden-Poher 3 E 42/20/6 (an VII)
	'AN08' => '1277342',            # Mariage Cléden-Poher 3 E 42/20/7 (an VIII)
	'AN09' => '1277343',            # Mariage Cléden-Poher 3 E 42/20/8 (an IX)
	'AN10' => '1277344',            # Mariage Cléden-Poher 3 E 42/20/9 (an X)
    },

    '3E042_0021' => {			# Mariage Cléden-Poher 3 E 42 21   AN12-1822
	1807   => '1277350',            # Mariage Cléden-Poher 3 E 42/21/5 (1807)
	1808   => '1277351',            # Mariage Cléden-Poher 3 E 42/21/6 (1808)
	1809   => '1277352',            # Mariage Cléden-Poher 3 E 42/21/7 (1809)
	1810   => '1277353',            # Mariage Cléden-Poher 3 E 42/21/8 (1810)
	1811   => '1277354',            # Mariage Cléden-Poher 3 E 42/21/9 (1811)
	1812   => '1277355',            # Mariage Cléden-Poher 3 E 42/21/10 (1812)
	1813   => '1277356',            # Mariage Cléden-Poher 3 E 42/21/11 (1813)
	1814   => '1277357',            # Mariage Cléden-Poher 3 E 42/21/12 (1814)
	1815   => '1277358',            # Mariage Cléden-Poher 3 E 42/21/13 (1815)
	1816   => '1277359',            # Mariage Cléden-Poher 3 E 42/21/14 (1816)
	1817   => '1277360',            # Mariage Cléden-Poher 3 E 42/21/15 (1817)
	1818   => '1277361',            # Mariage Cléden-Poher 3 E 42/21/16 (1818)
	1819   => '1277362',            # Mariage Cléden-Poher 3 E 42/21/17 (1819)
	1820   => '1277363',            # Mariage Cléden-Poher 3 E 42/21/18 (1820)
	1821   => '1277364',            # Mariage Cléden-Poher 3 E 42/21/19 (1821)
	1822   => '1277365',            # Mariage Cléden-Poher 3 E 42/21/20 (1822)
	'AN11' => '1277346',            # Mariage Cléden-Poher 3 E 42/21/1 (an XI)
	'AN12' => '1277347',            # Mariage Cléden-Poher 3 E 42/21/2 (an XII)
	'AN13' => '1277348',            # Mariage Cléden-Poher 3 E 42/21/3 (an XIII)
	'AN14' => '1277349',            # Mariage Cléden-Poher 3 E 42/21/4 (an XIV - 1806)
    },

    '3E042_0022' => {			# Mariage Cléden-Poher 3 E 42 22   1823-1832
	1823   => '1277367',            # Mariage Cléden-Poher 3 E 42/22/1 (1823)
	1824   => '1277368',            # Mariage Cléden-Poher 3 E 42/22/2 (1824)
	1825   => '1277369',            # Mariage Cléden-Poher 3 E 42/22/3 (1825)
	1826   => '1277370',            # Mariage Cléden-Poher 3 E 42/22/4 (1826)
	1827   => '1277371',            # Mariage Cléden-Poher 3 E 42/22/5 (1827)
	1828   => '1277372',            # Mariage Cléden-Poher 3 E 42/22/6 (1828)
	1829   => '1277373',            # Mariage Cléden-Poher 3 E 42/22/7 (1829)
	1830   => '1277374',            # Mariage Cléden-Poher 3 E 42/22/8 (1830)
	1831   => '1277375',            # Mariage Cléden-Poher 3 E 42/22/9 (1831)
	1832   => '1277376',            # Mariage Cléden-Poher 3 E 42/22/10 (1832)
    },

    '3E042_0023' => {			# Mariage Cléden-Poher 3 E 42 23   1833-1842
	1833   => '1277378',            # Mariage Cléden-Poher 3 E 42/23/1 (1833)
	1834   => '1277379',            # Mariage Cléden-Poher 3 E 42/23/2 (1834)
	1835   => '1277380',            # Mariage Cléden-Poher 3 E 42/23/3 (1835)
	1836   => '1277381',            # Mariage Cléden-Poher 3 E 42/23/4 (1836)
	1837   => '1277382',            # Mariage Cléden-Poher 3 E 42/23/5 (1837)
	1838   => '1277383',            # Mariage Cléden-Poher 3 E 42/23/6 (1838)
	1839   => '1277384',            # Mariage Cléden-Poher 3 E 42/23/7 (1839)
	1840   => '1277385',            # Mariage Cléden-Poher 3 E 42/23/8 (1840)
	1841   => '1277386',            # Mariage Cléden-Poher 3 E 42/23/9 (1841)
	1842   => '1277387',            # Mariage Cléden-Poher 3 E 42/23/10 (1842)
    },

    '3E042_0024' => {			# Mariage Cléden-Poher 3 E 42 24   1843-1852
	1843   => '1277389',            # Mariage Cléden-Poher 3 E 42/24/1 (1843)
	1844   => '1277390',            # Mariage Cléden-Poher 3 E 42/24/2 (1844)
	1845   => '1277391',            # Mariage Cléden-Poher 3 E 42/24/3 (1845)
	1846   => '1277392',            # Mariage Cléden-Poher 3 E 42/24/4 (1846)
	1847   => '1277393',            # Mariage Cléden-Poher 3 E 42/24/5 (1847)
	1848   => '1277394',            # Mariage Cléden-Poher 3 E 42/24/6 (1848)
	1849   => '1277395',            # Mariage Cléden-Poher 3 E 42/24/7 (1849)
	1850   => '1277396',            # Mariage Cléden-Poher 3 E 42/24/8 (1850)
	1851   => '1277397',            # Mariage Cléden-Poher 3 E 42/24/9 (1851)
	1852   => '1277398',            # Mariage Cléden-Poher 3 E 42/24/10 (1852)
    },

    '3E042_0025' => {			# Mariage Cléden-Poher 3 E 42 25   1853-1862
	1853   => '1277400',            # Mariage Cléden-Poher 3 E 42/25/1 (1853)
	1854   => '1277401',            # Mariage Cléden-Poher 3 E 42/25/2 (1854)
	1855   => '1277402',            # Mariage Cléden-Poher 3 E 42/25/3 (1855)
	1856   => '1277403',            # Mariage Cléden-Poher 3 E 42/25/4 (1856)
	1857   => '1277404',            # Mariage Cléden-Poher 3 E 42/25/5 (1857)
	1858   => '1277405',            # Mariage Cléden-Poher 3 E 42/25/6 (1858)
	1859   => '1277406',            # Mariage Cléden-Poher 3 E 42/25/7 (1859)
	1860   => '1277407',            # Mariage Cléden-Poher 3 E 42/25/8 (1860)
	1861   => '1277408',            # Mariage Cléden-Poher 3 E 42/25/9 (1861)
	1862   => '1277409',            # Mariage Cléden-Poher 3 E 42/25/10 (1862)
    },

    '3E042_0026' => {			# Mariage Cléden-Poher 3 E 42 26   1863-1869
	1863   => '1277411',            # Mariage Cléden-Poher 3 E 42/26/1 (1863)
	1864   => '1277412',            # Mariage Cléden-Poher 3 E 42/26/2 (1864)
	1865   => '1277413',            # Mariage Cléden-Poher 3 E 42/26/3 (1865)
	1866   => '1277414',            # Mariage Cléden-Poher 3 E 42/26/4 (1866)
	1867   => '1277415',            # Mariage Cléden-Poher 3 E 42/26/5 (1867)
	1868   => '1277416',            # Mariage Cléden-Poher 3 E 42/26/6 (1868)
	1869   => '1277417',            # Mariage Cléden-Poher 3 E 42/26/7 (1869)
    },

    '3E042_0027' => {			# Mariage Cléden-Poher 3 E 42 27   1870-1885
	1870   => '1277419',            # Mariage Cléden-Poher 3 E 42/27/1 (1870)
	1871   => '1277420',            # Mariage Cléden-Poher 3 E 42/27/2 (1871)
	1872   => '1277421',            # Mariage Cléden-Poher 3 E 42/27/3 (1872)
	1873   => '1277422',            # Mariage Cléden-Poher 3 E 42/27/4 (1873)
	1874   => '1277423',            # Mariage Cléden-Poher 3 E 42/27/5 (1874)
	1875   => '1277424',            # Mariage Cléden-Poher 3 E 42/27/6 (1875)
	1876   => '1277425',            # Mariage Cléden-Poher 3 E 42/27/7 (1876)
	1877   => '1277426',            # Mariage Cléden-Poher 3 E 42/27/8 (1877)
	1878   => '1277427',            # Mariage Cléden-Poher 3 E 42/27/9 (1878)
	1879   => '1277428',            # Mariage Cléden-Poher 3 E 42/27/10 (1879)
	1880   => '1277429',            # Mariage Cléden-Poher 3 E 42/27/11 (1880)
	1881   => '1277430',            # Mariage Cléden-Poher 3 E 42/27/12 (1881)
	1882   => '1277431',            # Mariage Cléden-Poher 3 E 42/27/13 (1882)
	1883   => '1277432',            # Mariage Cléden-Poher 3 E 42/27/14 (1883)
	1884   => '1277433',            # Mariage Cléden-Poher 3 E 42/27/15 (1884)
	1885   => '1277434',            # Mariage Cléden-Poher 3 E 42/27/16 (1885)
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

    '3E042_0038' => {			# Mariage Cléden-Poher 3 E 42 38   1886-1903
	1886   => '1277436',            # Mariage Cléden-Poher 3 E 42/38/1 (1886)
	1887   => '1277437',            # Mariage Cléden-Poher 3 E 42/38/2 (1887)
	1888   => '1277438',            # Mariage Cléden-Poher 3 E 42/38/3 (1888)
	1889   => '1277439',            # Mariage Cléden-Poher 3 E 42/38/4 (1889)
	1890   => '1277440',            # Mariage Cléden-Poher 3 E 42/38/5 (1890)
	1891   => '1277441',            # Mariage Cléden-Poher 3 E 42/38/6 (1891)
	1892   => '1277442',            # Mariage Cléden-Poher 3 E 42/38/7 (1892)
	1893   => '1277443',            # Mariage Cléden-Poher 3 E 42/38/8 (1893)
	1894   => '1277444',            # Mariage Cléden-Poher 3 E 42/38/9 (1894)
	1895   => '1277445',            # Mariage Cléden-Poher 3 E 42/38/10 (1895)
	1896   => '1277446',            # Mariage Cléden-Poher 3 E 42/38/11 (1896)
	1897   => '1277447',            # Mariage Cléden-Poher 3 E 42/38/12 (1897)
	1898   => '1277448',            # Mariage Cléden-Poher 3 E 42/38/13 (1898)
	1899   => '1277449',            # Mariage Cléden-Poher 3 E 42/38/14 (1899)
	1900   => '1277450',            # Mariage Cléden-Poher 3 E 42/38/15 (1900)
	1901   => '1277451',            # Mariage Cléden-Poher 3 E 42/38/16 (1901)
	1902   => '1277452',            # Mariage Cléden-Poher 3 E 42/38/17 (1902)
	1903   => '1277453',            # Mariage Cléden-Poher 3 E 42/38/18 (1903)
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

    # NMD Concarneau
    '3E053_0011' => '652901.1281444',   # Naissance Concarneau 3 E 53 11 (1793-an X)
    '3E053_0012' => '652902.1281445',   # Naissance Concarneau 3 E 53 12 (An XI-1812)
    '3E053_0013' => '652903.1281446',   # Naissance Concarneau 3 E 53 13 (1813-1822)
    '3E053_0014' => '652904.1281447',   # Naissance Concarneau 3 E 53 14 (1823-1832)
    '3E053_0015' => '652905.1281448',   # Naissance Concarneau 3 E 53 15 (1833-1842)
    '3E053_0016' => '652906.1281449',   # Naissance Concarneau 3 E 53 16 (1843-1852)
    '3E053_0017' => '652907.1281450',   # Naissance Concarneau 3 E 53 17 (1853-1862)
    '3E053_0018' => '652908.1281451',   # Naissance Concarneau 3 E 53 18 (1863-1869)
    '3E053_0019' => '652909.1281452',   # Naissance Concarneau 3 E 53 19 (1870-1875)
    '3E053_0020' => '652910.1281453',   # Naissance Concarneau 3 E 53 20 (1876-1881)
    '3E053_0021' => '652911.1281454',   # Naissance Concarneau 3 E 53 21 (1882-1885)
    '3E053_0022' => '652912.1281455',   # Naissance Concarneau 3 E 53 22 (1886-1889)
    '3E053_0023' => '652913.1281456',   # Naissance Concarneau 3 E 53 23 (1890-1894)
    '3E053_0024' => '652914.1281514',   # Mariage Concarneau 3 E 53 24 (1793-an X)
    '3E053_0025' => '652915.1281515',   # Mariage Concarneau 3 E 53 25 (An XI-1812)
    '3E053_0026' => '652916.1281516',   # Mariage Concarneau 3 E 53 26 (1813-1821)
    '3E053_0027' => '652917.1281517',   # Mariage Concarneau 3 E 53 27 (1822-1832)
    '3E053_0028' => '652918.1281518',   # Mariage Concarneau 3 E 53 28 (1833-1842)
    '3E053_0029' => '652919.1281519',   # Mariage Concarneau 3 E 53 29 (1843-1852)
    '3E053_0030' => '652920.1281520',   # Mariage Concarneau 3 E 53 30 (1853-1862)
    '3E053_0031' => '652921.1281521',   # Mariage Concarneau 3 E 53 31 (1863-1869)
    '3E053_0032' => '652922.1281522',   # Mariage Concarneau 3 E 53 32 (1870-1878)
    '3E053_0033' => '652923.1281523',   # Mariage Concarneau 3 E 53 33 (1879-1885)
    '3E053_0034' => '652924.1281524',   # Mariage Concarneau 3 E 53 34 (1886-1890)
    '3E053_0035' => '652925.1281587',   # Décès Concarneau 3 E 53 35 (1793-an X)
    '3E053_0036' => '652926.1281588',   # Décès Concarneau 3 E 53 36 (An XI-1811)
    '3E053_0037' => '652927.1281589',   # Décès Concarneau 3 E 53 37 (1812-1822)
    '3E053_0038' => '652928.1281590',   # Décès Concarneau 3 E 53 38 (1823-1832)
    '3E053_0039' => '652929.1281591',   # Décès Concarneau 3 E 53 39 (1833-1842)
    '3E053_0040' => '652930.1281592',   # Décès Concarneau 3 E 53 40 (1843-1852)
    '3E053_0041' => '652931.1281593',   # Décès Concarneau 3 E 53 41 (1853-1862)
    '3E053_0042' => '652932.1281594',   # Décès Concarneau 3 E 53 42 (1863-1869)
    '3E053_0043' => '652933.1281595',   # Décès Concarneau 3 E 53 43 (1870-1877)
    '3E053_0044' => '652934.1281596',   # Décès Concarneau 3 E 53 44 (1878-1883)
    '3E053_0045' => '652935.1281597',   # Décès Concarneau 3 E 53 45 (1884-1887)
    '3E053_0046' => '652936.1281598',   # Décès Concarneau 3 E 53 46 (1888-1892)
    '3E053_0047' => '652937.1281457',   # Naissance Concarneau 3 E 53 47 (1895-1898)
    '3E053_0048' => '652938.1281525',   # Mariage Concarneau 3 E 53 48 (1891-1896)
    '3E053_0049' => '652939.1281599',   # Décès Concarneau 3 E 53 49 (1893-1896)
    '3E053_0050' => {			# Naissance Concarneau 3 E 53 50   1899-1902
	1899   => '1281459',            # Naissance Concarneau 3 E 53/50/1 (1899)
	1900   => '1281460',            # Naissance Concarneau 3 E 53/50/2 (1900)
	1901   => '1281461',            # Naissance Concarneau 3 E 53/50/3 (1901)
	1902   => '1281462',            # Naissance Concarneau 3 E 53/50/4 (1902)
    },

    '3E053_0051' => {			# Naissance Concarneau 3 E 53 51   1903-1906
	1903   => '1281464',            # Naissance Concarneau 3 E 53/51/1 (1903)
	1904   => '1281465',            # Naissance Concarneau 3 E 53/51/2 (1904)
	1905   => '1281466',            # Naissance Concarneau 3 E 53/51/3 (1905)
	1906   => '1281467',            # Naissance Concarneau 3 E 53/51/4 (1906)
    },

    '3E053_0052' => {			# Mariage Concarneau 3 E 53 52   1897-1901
	1897   => '1281527',            # Mariage Concarneau 3 E 53/52/1 (1897)
	1898   => '1281528',            # Mariage Concarneau 3 E 53/52/2 (1898)
	1899   => '1281529',            # Mariage Concarneau 3 E 53/52/3 (1899)
	1900   => '1281530',            # Mariage Concarneau 3 E 53/52/4 (1900)
	1901   => '1281531',            # Mariage Concarneau 3 E 53/52/5 (1901)
    },

    '3E053_0053' => {			# Mariage Concarneau 3 E 53 53   1902-1906
	1902   => '1281533',            # Mariage Concarneau 3 E 53/53/1 (1902)
	1903   => '1281534',            # Mariage Concarneau 3 E 53/53/2 (1903)
	1904   => '1281535',            # Mariage Concarneau 3 E 53/53/3 (1904)
	1905   => '1281536',            # Mariage Concarneau 3 E 53/53/4 (1905)
	1906   => '1281537',            # Mariage Concarneau 3 E 53/53/5 (1906)
    },

    '3E053_0054' => {			# Décès Concarneau 3 E 53 54   1897-1901
	1897   => '1281601',            # Décès Concarneau 3 E 53/54/1 (1897)
	1898   => '1281602',            # Décès Concarneau 3 E 53/54/2 (1898)
	1899   => '1281603',            # Décès Concarneau 3 E 53/54/3 (1899)
	1900   => '1281604',            # Décès Concarneau 3 E 53/54/4 (1900)
	1901   => '1281605',            # Décès Concarneau 3 E 53/54/5 (1901)
    },

    '3E053_0055' => {			# Décès Concarneau 3 E 53 55   1902-1907
	1902   => '1281607',            # Décès Concarneau 3 E 53/55/1 (1902)
	1903   => '1281608',            # Décès Concarneau 3 E 53/55/2 (1903)
	1904   => '1281609',            # Décès Concarneau 3 E 53/55/3 (1904)
	1905   => '1281610',            # Décès Concarneau 3 E 53/55/4 (1905)
	1906   => '1281611',            # Décès Concarneau 3 E 53/55/5 (1906)
	1907   => '1281612',            # Décès Concarneau 3 E 53/55/6 (1907)
    },

    '3E053_0056' => {			# Naissance Concarneau 3 E 53 56   1907-1910
	1907   => '1281469',            # Naissance Concarneau 3 E 53/56/1 (1907)
	1908   => '1281470',            # Naissance Concarneau 3 E 53/56/2 (1908)
	1909   => '1281471',            # Naissance Concarneau 3 E 53/56/3 (1909)
	1910   => '1281472',            # Naissance Concarneau 3 E 53/56/4 (1910)
    },

    '3E053_0057' => {			# Mariage Concarneau 3 E 53 57   1907-1910
	1907   => '1281539',            # Mariage Concarneau 3 E 53/57/1 (1907)
	1908   => '1281540',            # Mariage Concarneau 3 E 53/57/2 (1908)
	1909   => '1281541',            # Mariage Concarneau 3 E 53/57/3 (1909)
	1910   => '1281542',            # Mariage Concarneau 3 E 53/57/4 (1910)
    },

    '3E053_0058' => {			# Naissance Concarneau 3 E 53 58   1911-1915
	1911   => '1281474',            # Naissance Concarneau 3 E 53/58/1 (1911)
	1912   => '1281475',            # Naissance Concarneau 3 E 53/58/2 (1912)
	1913   => '1281476',            # Naissance Concarneau 3 E 53/58/3 (1913)
	1914   => '1281477',            # Naissance Concarneau 3 E 53/58/4 (1914)
	1915   => '1281478',            # Naissance Concarneau 3 E 53/58/5 (1915)
    },

    '3E053_0059' => {			# Naissance Concarneau 3 E 53 59   1916-1921
	1916   => '1281480',            # Naissance Concarneau 3 E 53/59/1 (1916)
	1917   => '1281481',            # Naissance Concarneau 3 E 53/59/2 (1917)
	1918   => '1281482',            # Naissance Concarneau 3 E 53/59/3 (1918)
	1919   => '1281483',            # Naissance Concarneau 3 E 53/59/4 (1919)
	1920   => '1281484',            # Naissance Concarneau 3 E 53/59/5 (1920)
	1921   => '1281485',            # Naissance Concarneau 3 E 53/59/6 (1921)
    },

    '3E053_0060' => {			# Naissance Concarneau 3 E 53 60   1922-1925
	1922   => '1281487',            # Naissance Concarneau 3 E 53/60/1 (1922)
	1923   => '1281488',            # Naissance Concarneau 3 E 53/60/2 (1923)
	1924   => '1281489',            # Naissance Concarneau 3 E 53/60/3 (1924)
	1925   => '1281490',            # Naissance Concarneau 3 E 53/60/4 (1925)
    },

    '3E053_0062' => {			# Mariage Concarneau 3 E 53 62   1911-1916
	1911   => '1281544',            # Mariage Concarneau 3 E 53/62/1 (1911)
	1912   => '1281545',            # Mariage Concarneau 3 E 53/62/2 (1912)
	1913   => '1281546',            # Mariage Concarneau 3 E 53/62/3 (1913)
	1914   => '1281547',            # Mariage Concarneau 3 E 53/62/4 (1914)
	1915   => '1281548',            # Mariage Concarneau 3 E 53/62/5 (1915)
	1916   => '1281549',            # Mariage Concarneau 3 E 53/62/6 (1916)
    },

    '3E053_0063' => {			# Mariage Concarneau 3 E 53 63   1917-1920
	1917   => '1281551',            # Mariage Concarneau 3 E 53/63/1 (1917)
	1918   => '1281552',            # Mariage Concarneau 3 E 53/63/2 (1918)
	1919   => '1281553',            # Mariage Concarneau 3 E 53/63/3 (1919)
	1920   => '1281554',            # Mariage Concarneau 3 E 53/63/4 (1920)
    },

    '3E053_0064' => {			# Mariage Concarneau 3 E 53 64   1921-1925
	1921   => '1281556',            # Mariage Concarneau 3 E 53/64/1 (1921)
	1922   => '1281557',            # Mariage Concarneau 3 E 53/64/2 (1922)
	1923   => '1281558',            # Mariage Concarneau 3 E 53/64/3 (1923)
	1924   => '1281559',            # Mariage Concarneau 3 E 53/64/4 (1924)
	1925   => '1281560',            # Mariage Concarneau 3 E 53/64/5 (1925)
    },

    '3E053_0065' => {			# Mariage Concarneau 3 E 53 65   1926-1930
	1926   => '1281562',            # Mariage Concarneau 3 E 53/65/1 (1926)
	1927   => '1281563',            # Mariage Concarneau 3 E 53/65/2 (1927)
	1928   => '1281564',            # Mariage Concarneau 3 E 53/65/3 (1928)
	1929   => '1281565',            # Mariage Concarneau 3 E 53/65/4 (1929)
	1930   => '1281566',            # Mariage Concarneau 3 E 53/65/5 (1930)
    },

    '3E053_0066' => {			# Mariage Concarneau 3 E 53 66   1931-1936
	1931   => '1281568',            # Mariage Concarneau 3 E 53/66/1 (1931)
	1932   => '1281569',            # Mariage Concarneau 3 E 53/66/2 (1932)
	1933   => '1281570',            # Mariage Concarneau 3 E 53/66/3 (1933)
	1934   => '1281571',            # Mariage Concarneau 3 E 53/66/4 (1934)
	1935   => '1281572',            # Mariage Concarneau 3 E 53/66/5 (1935)
	1936   => '1281573',            # Mariage Concarneau 3 E 53/66/6 (1936)
    },

    '3E053_0067' => {			# Décès Concarneau 3 E 53 67   1908-1913
	1908   => '1281614',            # Décès Concarneau 3 E 53/67/1 (1908)
	1909   => '1281615',            # Décès Concarneau 3 E 53/67/2 (1909)
	1910   => '1281616',            # Décès Concarneau 3 E 53/67/3 (1910)
	1911   => '1281617',            # Décès Concarneau 3 E 53/67/4 (1911)
	1912   => '1281618',            # Décès Concarneau 3 E 53/67/5 (1912)
	1913   => '1281619',            # Décès Concarneau 3 E 53/67/6 (1913)
    },

    '3E053_0068' => {			# Décès Concarneau 3 E 53 68   1914-1918
	1914   => '1281621',            # Décès Concarneau 3 E 53/68/1 (1914)
	1915   => '1281622',            # Décès Concarneau 3 E 53/68/2 (1915)
	1916   => '1281623',            # Décès Concarneau 3 E 53/68/3 (1916)
	1917   => '1281624',            # Décès Concarneau 3 E 53/68/4 (1917)
	1918   => '1281625',            # Décès Concarneau 3 E 53/68/5 (1918)
    },

    '3E053_0069' => {			# Décès Concarneau 3 E 53 69   1919-1922
	1919   => '1281627',            # Décès Concarneau 3 E 53/69/1 (1919)
	1920   => '1281628',            # Décès Concarneau 3 E 53/69/2 (1920)
	1921   => '1281629',            # Décès Concarneau 3 E 53/69/3 (1921)
	1922   => '1281630',            # Décès Concarneau 3 E 53/69/4 (1922)
    },

    '3E053_0070' => {			# Décès Concarneau 3 E 53 70   1923-1929
	1923   => '1281632',            # Décès Concarneau 3 E 53/70/1 (1923)
	1924   => '1281633',            # Décès Concarneau 3 E 53/70/2 (1924)
	1925   => '1281634',            # Décès Concarneau 3 E 53/70/3 (1925)
	1926   => '1281635',            # Décès Concarneau 3 E 53/70/4 (1926)
	1927   => '1281636',            # Décès Concarneau 3 E 53/70/5 (1927)
	1928   => '1281637',            # Décès Concarneau 3 E 53/70/6 (1928)
	1929   => '1281638',            # Décès Concarneau 3 E 53/70/7 (1929)
    },

    '3E053_0071' => {			# Décès Concarneau 3 E 53 71   1930-1936
	1930   => '1281640',            # Décès Concarneau 3 E 53/71/1 (1930)
	1931   => '1281641',            # Décès Concarneau 3 E 53/71/2 (1931)
	1932   => '1281642',            # Décès Concarneau 3 E 53/71/3 (1932)
	1933   => '1281643',            # Décès Concarneau 3 E 53/71/4 (1933)
	1934   => '1281644',            # Décès Concarneau 3 E 53/71/5 (1934)
	1935   => '1281645',            # Décès Concarneau 3 E 53/71/6 (1935)
	1936   => '1281646',            # Décès Concarneau 3 E 53/71/7 (1936)
    },


    # NMD Elliant
    '3E064_0006' => {			# Naissance Elliant 3 E 64 6   AN02-AN10
	'AN02' => '1285736',            # Naissance Elliant 3 E 64/6/1 (1793 - an II)
	'AN03' => '1285737',            # Naissance Elliant 3 E 64/6/2 (An III)
	'AN04' => '1285738',            # Naissance Elliant 3 E 64/6/3 (An IV)
	'AN05' => '1285739',            # Naissance Elliant 3 E 64/6/4 (An V)
	'AN06' => '1285740',            # Naissance Elliant 3 E 64/6/5 (An VI)
	'AN07' => '1285741',            # Naissance Elliant 3 E 64/6/6 (An VII)
	'AN08' => '1285742',            # Naissance Elliant 3 E 64/6/7 (An VIII)
	'AN09' => '1285743',            # Naissance Elliant 3 E 64/6/8 (An IX)
	'AN10' => '1285744',            # Naissance Elliant 3 E 64/6/9 (An X)
    },

    '3E064_0007' => {			# Naissance Elliant 3 E 64 7   AN11-1812
	'AN11' => '1285746',            # Naissance Elliant 3 E 64/7/1 (An XI)
	'AN12' => '1285747',            # Naissance Elliant 3 E 64/7/2 (An XII)
	'AN13' => '1285748',            # Naissance Elliant 3 E 64/7/3 (An XIII)
	'AN14' => '1285749',            # Naissance Elliant 3 E 64/7/4 (An XIV - 1806)
	1807   => '1285750',            # Naissance Elliant 3 E 64/7/5 (1807)
	1808   => '1285751',            # Naissance Elliant 3 E 64/7/6 (1808)
	1809   => '1285752',            # Naissance Elliant 3 E 64/7/7 (1809)
	1810   => '1285753',            # Naissance Elliant 3 E 64/7/8 (1810)
	1811   => '1285754',            # Naissance Elliant 3 E 64/7/9 (1811)
	1812   => '1285755',            # Naissance Elliant 3 E 64/7/10 (1812)
    },

    '3E064_0008' => {			# Naissance Elliant 3 E 64 8   1813-1822
	1813   => '1285757',            # Naissance Elliant 3 E 64/8/1 (1813)
	1814   => '1285758',            # Naissance Elliant 3 E 64/8/2 (1814)
	1815   => '1285759',            # Naissance Elliant 3 E 64/8/3 (1815)
	1816   => '1285760',            # Naissance Elliant 3 E 64/8/4 (1816)
	1817   => '1285761',            # Naissance Elliant 3 E 64/8/5 (1817)
	1818   => '1285762',            # Naissance Elliant 3 E 64/8/6 (1818)
	1819   => '1285763',            # Naissance Elliant 3 E 64/8/7 (1819)
	1820   => '1285764',            # Naissance Elliant 3 E 64/8/8 (1820)
	1821   => '1285765',            # Naissance Elliant 3 E 64/8/9 (1821)
	1822   => '1285766',            # Naissance Elliant 3 E 64/8/10 (1822)
    },

    '3E064_0009' => {			# Naissance Elliant 3 E 64 9   1823-1832
	1823   => '1285768',            # Naissance Elliant 3 E 64/9/1 (1823)
	1824   => '1285769',            # Naissance Elliant 3 E 64/9/2 (1824)
	1825   => '1285770',            # Naissance Elliant 3 E 64/9/3 (1825)
	1826   => '1285771',            # Naissance Elliant 3 E 64/9/4 (1826)
	1827   => '1285772',            # Naissance Elliant 3 E 64/9/5 (1827)
	1828   => '1285773',            # Naissance Elliant 3 E 64/9/6 (1828)
	1829   => '1285774',            # Naissance Elliant 3 E 64/9/7 (1829)
	1830   => '1285775',            # Naissance Elliant 3 E 64/9/8 (1830)
	1831   => '1285776',            # Naissance Elliant 3 E 64/9/9 (1831)
	1832   => '1285777',            # Naissance Elliant 3 E 64/9/10 (1832)
    },

    '3E064_0010' => {			# Naissance Elliant 3 E 64 10   1833-1842
	1833   => '1285779',            # Naissance Elliant 3 E 64/10/1 (1833)
	1834   => '1285780',            # Naissance Elliant 3 E 64/10/2 (1834)
	1835   => '1285781',            # Naissance Elliant 3 E 64/10/3 (1835)
	1836   => '1285782',            # Naissance Elliant 3 E 64/10/4 (1836)
	1837   => '1285783',            # Naissance Elliant 3 E 64/10/5 (1837)
	1838   => '1285784',            # Naissance Elliant 3 E 64/10/6 (1838)
	1839   => '1285785',            # Naissance Elliant 3 E 64/10/7 (1839)
	1840   => '1285786',            # Naissance Elliant 3 E 64/10/8 (1840)
	1841   => '1285787',            # Naissance Elliant 3 E 64/10/9 (1841)
	1842   => '1285788',            # Naissance Elliant 3 E 64/10/10 (1842)
    },

    '3E064_0011' => {			# Naissance Elliant 3 E 64 11   1843-1858
	1843   => '1285790',            # Naissance Elliant 3 E 64/11/1 (1843)
	1844   => '1285791',            # Naissance Elliant 3 E 64/11/2 (1844)
	1845   => '1285792',            # Naissance Elliant 3 E 64/11/3 (1845)
	1846   => '1285793',            # Naissance Elliant 3 E 64/11/4 (1846)
	1847   => '1285794',            # Naissance Elliant 3 E 64/11/5 (1847)
	1848   => '1285795',            # Naissance Elliant 3 E 64/11/6 (1848)
	1849   => '1285796',            # Naissance Elliant 3 E 64/11/7 (1849)
	1850   => '1285797',            # Naissance Elliant 3 E 64/11/8 (1850)
	1851   => '1285798',            # Naissance Elliant 3 E 64/11/9 (1851)
	1852   => '1285799',            # Naissance Elliant 3 E 64/11/10 (1852)
	1853   => '1285800',            # Naissance Elliant 3 E 64/11/11 (1853)
	1854   => '1285801',            # Naissance Elliant 3 E 64/11/12 (1854)
	1855   => '1285802',            # Naissance Elliant 3 E 64/11/13 (1855)
	1856   => '1285803',            # Naissance Elliant 3 E 64/11/14 (1856)
	1857   => '1285804',            # Naissance Elliant 3 E 64/11/15 (1857)
	1858   => '1285805',            # Naissance Elliant 3 E 64/11/16 (1858)
    },

    '3E064_0012' => {			# Naissance Elliant 3 E 64 12   1859-1869
	1859   => '1285807',            # Naissance Elliant 3 E 64/12/1 (1859)
	1860   => '1285808',            # Naissance Elliant 3 E 64/12/2 (1860)
	1861   => '1285809',            # Naissance Elliant 3 E 64/12/3 (1861)
	1862   => '1285810',            # Naissance Elliant 3 E 64/12/4 (1862)
	1863   => '1285811',            # Naissance Elliant 3 E 64/12/5 (1863)
	1864   => '1285812',            # Naissance Elliant 3 E 64/12/6 (1864)
	1865   => '1285813',            # Naissance Elliant 3 E 64/12/7 (1865)
	1866   => '1285814',            # Naissance Elliant 3 E 64/12/8 (1866)
	1867   => '1285815',            # Naissance Elliant 3 E 64/12/9 (1867)
	1868   => '1285816',            # Naissance Elliant 3 E 64/12/10 (1868)
	1869   => '1285817',            # Naissance Elliant 3 E 64/12/11 (1869)
    },

    '3E064_0013' => {			# Naissance Elliant 3 E 64 13   1870-1877
	1870   => '1285819',            # Naissance Elliant 3 E 64/13/1 (1870)
	1871   => '1285820',            # Naissance Elliant 3 E 64/13/2 (1871)
	1872   => '1285821',            # Naissance Elliant 3 E 64/13/3 (1872)
	1873   => '1285822',            # Naissance Elliant 3 E 64/13/4 (1873)
	1874   => '1285823',            # Naissance Elliant 3 E 64/13/5 (1874)
	1875   => '1285824',            # Naissance Elliant 3 E 64/13/6 (1875)
	1876   => '1285825',            # Naissance Elliant 3 E 64/13/7 (1876)
	1877   => '1285826',            # Naissance Elliant 3 E 64/13/8 (1877)
    },

    '3E064_0014' => {			# Naissance Elliant 3 E 64 14   1878-1887
	1878   => '1285828',            # Naissance Elliant 3 E 64/14/1 (1878)
	1879   => '1285829',            # Naissance Elliant 3 E 64/14/2 (1879)
	1880   => '1285830',            # Naissance Elliant 3 E 64/14/3 (1880)
	1881   => '1285831',            # Naissance Elliant 3 E 64/14/4 (1881)
	1882   => '1285832',            # Naissance Elliant 3 E 64/14/5 (1882)
	1883   => '1285833',            # Naissance Elliant 3 E 64/14/6 (1883)
	1884   => '1285834',            # Naissance Elliant 3 E 64/14/7 (1884)
	1885   => '1285835',            # Naissance Elliant 3 E 64/14/8 (1885)
	1886   => '1285836',            # Naissance Elliant 3 E 64/14/9 (1886)
	1887   => '1285837',            # Naissance Elliant 3 E 64/14/10 (1887)
    },

    '3E064_0015' => {			# Mariage Elliant 3 E 64 15   AN02-AN10
	'AN02' => '1285905',            # Mariage Elliant 3 E 64/15/1 (1793 - an II)
	'AN03' => '1285906',            # Mariage Elliant 3 E 64/15/2 (An III)
	'AN04' => '1285907',            # Mariage Elliant 3 E 64/15/3 (An IV)
	'AN05' => '1285908',            # Mariage Elliant 3 E 64/15/4 (An V)
	'AN06' => '1285909',            # Mariage Elliant 3 E 64/15/5 (An VI)
	'AN07' => '1285910',            # Mariage Elliant 3 E 64/15/6 (An VII)
	'AN08' => '1285911',            # Mariage Elliant 3 E 64/15/7 (An VIII)
	'AN09' => '1285912',            # Mariage Elliant 3 E 64/15/8 (An IX)
	'AN10' => '1285913',            # Mariage Elliant 3 E 64/15/9 (An X)
    },

    '3E064_0016' => {			# Mariage Elliant 3 E 64 16   AN11-1812
	'AN11' => '1285915',            # Mariage Elliant 3 E 64/16/1 (An XI)
	'AN12' => '1285916',            # Mariage Elliant 3 E 64/16/2 (An XII)
	'AN13' => '1285917',            # Mariage Elliant 3 E 64/16/3 (An XIII)
	'AN14' => '1285918',            # Mariage Elliant 3 E 64/16/4 (An XIV - 1806)
	1807   => '1285919',            # Mariage Elliant 3 E 64/16/5 (1807)
	1808   => '1285920',            # Mariage Elliant 3 E 64/16/6 (1808)
	1809   => '1285921',            # Mariage Elliant 3 E 64/16/7 (1809)
	1810   => '1285922',            # Mariage Elliant 3 E 64/16/8 (1810)
	1811   => '1285923',            # Mariage Elliant 3 E 64/16/9 (1811)
	1812   => '1285924',            # Mariage Elliant 3 E 64/16/10 (1812)
    },

    '3E064_0017' => {			# Mariage Elliant 3 E 64 17   1813-1822
	1813   => '1285926',            # Mariage Elliant 3 E 64/17/1 (1813)
	1814   => '1285927',            # Mariage Elliant 3 E 64/17/2 (1814)
	1815   => '1285928',            # Mariage Elliant 3 E 64/17/3 (1815)
	1816   => '1285929',            # Mariage Elliant 3 E 64/17/4 (1816)
	1817   => '1285930',            # Mariage Elliant 3 E 64/17/5 (1817)
	1818   => '1285931',            # Mariage Elliant 3 E 64/17/6 (1818)
	1819   => '1285932',            # Mariage Elliant 3 E 64/17/7 (1819)
	1820   => '1285933',            # Mariage Elliant 3 E 64/17/8 (1820)
	1821   => '1285934',            # Mariage Elliant 3 E 64/17/9 (1821)
	1822   => '1285935',            # Mariage Elliant 3 E 64/17/10 (1822)
    },

    '3E064_0018' => {			# Mariage Elliant 3 E 64 18   1823-1839
	1823   => '1285937',            # Mariage Elliant 3 E 64/18/1 (1823)
	1824   => '1285938',            # Mariage Elliant 3 E 64/18/2 (1824)
	1825   => '1285939',            # Mariage Elliant 3 E 64/18/3 (1825)
	1826   => '1285940',            # Mariage Elliant 3 E 64/18/4 (1826)
	1827   => '1285941',            # Mariage Elliant 3 E 64/18/5 (1827)
	1828   => '1285942',            # Mariage Elliant 3 E 64/18/6 (1828)
	1829   => '1285943',            # Mariage Elliant 3 E 64/18/7 (1829)
	1830   => '1285944',            # Mariage Elliant 3 E 64/18/8 (1830)
	1831   => '1285945',            # Mariage Elliant 3 E 64/18/9 (1831)
	1832   => '1285946',            # Mariage Elliant 3 E 64/18/10 (1832)
	1833   => '1285947',            # Mariage Elliant 3 E 64/18/11 (1833)
	1834   => '1285948',            # Mariage Elliant 3 E 64/18/12 (1834)
	1835   => '1285949',            # Mariage Elliant 3 E 64/18/13 (1835)
	1836   => '1285950',            # Mariage Elliant 3 E 64/18/14 (1836)
	1837   => '1285951',            # Mariage Elliant 3 E 64/18/15 (1837)
	1838   => '1285952',            # Mariage Elliant 3 E 64/18/16 (1838)
	1839   => '1285953',            # Mariage Elliant 3 E 64/18/17 (1839)
    },

    '3E064_0019' => {			# Mariage Elliant 3 E 64 19   1840-1852
	1840   => '1285955',            # Mariage Elliant 3 E 64/19/1 (1840)
	1841   => '1285956',            # Mariage Elliant 3 E 64/19/2 (1841)
	1842   => '1285957',            # Mariage Elliant 3 E 64/19/3 (1842)
	1843   => '1285958',            # Mariage Elliant 3 E 64/19/4 (1843)
	1844   => '1285959',            # Mariage Elliant 3 E 64/19/5 (1844)
	1845   => '1285960',            # Mariage Elliant 3 E 64/19/6 (1845)
	1846   => '1285961',            # Mariage Elliant 3 E 64/19/7 (1846)
	1847   => '1285962',            # Mariage Elliant 3 E 64/19/8 (1847)
	1848   => '1285963',            # Mariage Elliant 3 E 64/19/9 (1848)
	1849   => '1285964',            # Mariage Elliant 3 E 64/19/10 (1849)
	1850   => '1285965',            # Mariage Elliant 3 E 64/19/11 (1850)
	1851   => '1285966',            # Mariage Elliant 3 E 64/19/12 (1851)
	1852   => '1285967',            # Mariage Elliant 3 E 64/19/13 (1852)
    },

    '3E064_0020' => {			# Mariage Elliant 3 E 64 20   1853-1862
	1853   => '1285969',            # Mariage Elliant 3 E 64/20/1 (1853)
	1854   => '1285970',            # Mariage Elliant 3 E 64/20/2 (1854)
	1855   => '1285971',            # Mariage Elliant 3 E 64/20/3 (1855)
	1856   => '1285972',            # Mariage Elliant 3 E 64/20/4 (1856)
	1857   => '1285973',            # Mariage Elliant 3 E 64/20/5 (1857)
	1858   => '1285974',            # Mariage Elliant 3 E 64/20/6 (1858)
	1859   => '1285975',            # Mariage Elliant 3 E 64/20/7 (1859)
	1860   => '1285976',            # Mariage Elliant 3 E 64/20/8 (1860)
	1861   => '1285977',            # Mariage Elliant 3 E 64/20/9 (1861)
	1862   => '1285978',            # Mariage Elliant 3 E 64/20/10 (1862)
    },

    '3E064_0021' => {			# Mariage Elliant 3 E 64 21   1863-1869
	1863   => '1285980',            # Mariage Elliant 3 E 64/21/1 (1863)
	1864   => '1285981',            # Mariage Elliant 3 E 64/21/2 (1864)
	1865   => '1285982',            # Mariage Elliant 3 E 64/21/3 (1865)
	1866   => '1285983',            # Mariage Elliant 3 E 64/21/4 (1866)
	1867   => '1285984',            # Mariage Elliant 3 E 64/21/5 (1867)
	1868   => '1285985',            # Mariage Elliant 3 E 64/21/6 (1868)
	1869   => '1285986',            # Mariage Elliant 3 E 64/21/7 (1869)
    },

    '3E064_0022' => {			# Mariage Elliant 3 E 64 22   1870-1881
	1870   => '1285988',            # Mariage Elliant 3 E 64/22/1 (1870)
	1871   => '1285989',            # Mariage Elliant 3 E 64/22/2 (1871)
	1872   => '1285990',            # Mariage Elliant 3 E 64/22/3 (1872)
	1873   => '1285991',            # Mariage Elliant 3 E 64/22/4 (1873)
	1874   => '1285992',            # Mariage Elliant 3 E 64/22/5 (1874)
	1875   => '1285993',            # Mariage Elliant 3 E 64/22/6 (1875)
	1876   => '1285994',            # Mariage Elliant 3 E 64/22/7 (1876)
	1877   => '1285995',            # Mariage Elliant 3 E 64/22/8 (1877)
	1878   => '1285996',            # Mariage Elliant 3 E 64/22/9 (1878)
	1879   => '1285997',            # Mariage Elliant 3 E 64/22/10 (1879)
	1880   => '1285998',            # Mariage Elliant 3 E 64/22/11 (1880)
	1881   => '1285999',            # Mariage Elliant 3 E 64/22/12 (1881)
    },

    '3E064_0023' => {			# Mariage Elliant 3 E 64 23   1882-1894
	1882   => '1286001',            # Mariage Elliant 3 E 64/23/1 (1882)
	1883   => '1286002',            # Mariage Elliant 3 E 64/23/2 (1883)
	1884   => '1286003',            # Mariage Elliant 3 E 64/23/3 (1884)
	1885   => '1286004',            # Mariage Elliant 3 E 64/23/4 (1885)
	1886   => '1286005',            # Mariage Elliant 3 E 64/23/5 (1886)
	1887   => '1286006',            # Mariage Elliant 3 E 64/23/6 (1887)
	1888   => '1286007',            # Mariage Elliant 3 E 64/23/7 (1888)
	1889   => '1286008',            # Mariage Elliant 3 E 64/23/8 (1889)
	1890   => '1286009',            # Mariage Elliant 3 E 64/23/9 (1890)
	1891   => '1286010',            # Mariage Elliant 3 E 64/23/10 (1891)
	1892   => '1286011',            # Mariage Elliant 3 E 64/23/11 (1892)
	1893   => '1286012',            # Mariage Elliant 3 E 64/23/12 (1893)
	1894   => '1286013',            # Mariage Elliant 3 E 64/23/13 (1894)
    },

    '3E064_0024' => {			# Décès Elliant 3 E 64 24   AN02-AN10
	'AN02' => '1286072',            # Décès Elliant 3 E 64/24/1 (1793 - an II)
	'AN03' => '1286073',            # Décès Elliant 3 E 64/24/2 (An III)
	'AN04' => '1286074',            # Décès Elliant 3 E 64/24/3 (An IV)
	'AN05' => '1286075',            # Décès Elliant 3 E 64/24/4 (An V)
	'AN06' => '1286076',            # Décès Elliant 3 E 64/24/5 (An VI)
	'AN07' => '1286077',            # Décès Elliant 3 E 64/24/6 (An VII)
	'AN08' => '1286078',            # Décès Elliant 3 E 64/24/7 (An VIII)
	'AN09' => '1286079',            # Décès Elliant 3 E 64/24/8 (An IX)
	'AN10' => '1286080',            # Décès Elliant 3 E 64/24/9 (An X)
    },

    '3E064_0025' => {			# Décès Elliant 3 E 64 25   AN11-1818
	'AN11' => '1286082',            # Décès Elliant 3 E 64/25/1 (An XI)
	'AN12' => '1286083',            # Décès Elliant 3 E 64/25/2 (An XII)
	'AN13' => '1286084',            # Décès Elliant 3 E 64/25/3 (An XIII)
	'AN14' => '1286085',            # Décès Elliant 3 E 64/25/4 (An XIV - 1806)
	1807   => '1286086',            # Décès Elliant 3 E 64/25/5 (1807)
	1808   => '1286087',            # Décès Elliant 3 E 64/25/6 (1808)
	1809   => '1286088',            # Décès Elliant 3 E 64/25/7 (1809)
	1810   => '1286089',            # Décès Elliant 3 E 64/25/8 (1810)
	1811   => '1286090',            # Décès Elliant 3 E 64/25/9 (1811)
	1812   => '1286091',            # Décès Elliant 3 E 64/25/10 (1812)
	1813   => '1286092',            # Décès Elliant 3 E 64/25/11 (1813)
	1814   => '1286093',            # Décès Elliant 3 E 64/25/12 (1814)
	1815   => '1286094',            # Décès Elliant 3 E 64/25/13 (1815)
	1816   => '1286095',            # Décès Elliant 3 E 64/25/14 (1816)
	1817   => '1286096',            # Décès Elliant 3 E 64/25/15 (1817)
	1818   => '1286097',            # Décès Elliant 3 E 64/25/16 (1818)
    },

    '3E064_0026' => {			# Décès Elliant 3 E 64 26   1819-1832
	1819   => '1286099',            # Décès Elliant 3 E 64/26/1 (1819)
	1820   => '1286100',            # Décès Elliant 3 E 64/26/2 (1820)
	1821   => '1286101',            # Décès Elliant 3 E 64/26/3 (1821)
	1822   => '1286102',            # Décès Elliant 3 E 64/26/4 (1822)
	1823   => '1286103',            # Décès Elliant 3 E 64/26/5 (1823)
	1824   => '1286104',            # Décès Elliant 3 E 64/26/6 (1824)
	1825   => '1286105',            # Décès Elliant 3 E 64/26/7 (1825)
	1826   => '1286106',            # Décès Elliant 3 E 64/26/8 (1826)
	1827   => '1286107',            # Décès Elliant 3 E 64/26/9 (1827)
	1828   => '1286108',            # Décès Elliant 3 E 64/26/10 (1828)
	1829   => '1286109',            # Décès Elliant 3 E 64/26/11 (1829)
	1830   => '1286110',            # Décès Elliant 3 E 64/26/12 (1830)
	1831   => '1286111',            # Décès Elliant 3 E 64/26/13 (1831)
	1832   => '1286112',            # Décès Elliant 3 E 64/26/14 (1832)
    },

    '3E064_0027' => {			# Décès Elliant 3 E 64 27   1833-1842
	1833   => '1286114',            # Décès Elliant 3 E 64/27/1 (1833)
	1834   => '1286115',            # Décès Elliant 3 E 64/27/2 (1834)
	1835   => '1286116',            # Décès Elliant 3 E 64/27/3 (1835)
	1836   => '1286117',            # Décès Elliant 3 E 64/27/4 (1836)
	1837   => '1286118',            # Décès Elliant 3 E 64/27/5 (1837)
	1838   => '1286119',            # Décès Elliant 3 E 64/27/6 (1838)
	1839   => '1286120',            # Décès Elliant 3 E 64/27/7 (1839)
	1840   => '1286121',            # Décès Elliant 3 E 64/27/8 (1840)
	1841   => '1286122',            # Décès Elliant 3 E 64/27/9 (1841)
	1842   => '1286123',            # Décès Elliant 3 E 64/27/10 (1842)
    },

    '3E064_0028' => {			# Décès Elliant 3 E 64 28   1843-1852
	1843   => '1286125',            # Décès Elliant 3 E 64/28/1 (1843)
	1844   => '1286126',            # Décès Elliant 3 E 64/28/2 (1844)
	1845   => '1286127',            # Décès Elliant 3 E 64/28/3 (1845)
	1846   => '1286128',            # Décès Elliant 3 E 64/28/4 (1846)
	1847   => '1286129',            # Décès Elliant 3 E 64/28/5 (1847)
	1848   => '1286130',            # Décès Elliant 3 E 64/28/6 (1848)
	1849   => '1286131',            # Décès Elliant 3 E 64/28/7 (1849)
	1850   => '1286132',            # Décès Elliant 3 E 64/28/8 (1850)
	1851   => '1286133',            # Décès Elliant 3 E 64/28/9 (1851)
	1852   => '1286134',            # Décès Elliant 3 E 64/28/10 (1852)
    },

    '3E064_0029' => {			# Décès Elliant 3 E 64 29   1853-1862
	1853   => '1286136',            # Décès Elliant 3 E 64/29/1 (1853)
	1854   => '1286137',            # Décès Elliant 3 E 64/29/2 (1854)
	1855   => '1286138',            # Décès Elliant 3 E 64/29/3 (1855)
	1856   => '1286139',            # Décès Elliant 3 E 64/29/4 (1856)
	1857   => '1286140',            # Décès Elliant 3 E 64/29/5 (1857)
	1858   => '1286141',            # Décès Elliant 3 E 64/29/6 (1858)
	1859   => '1286142',            # Décès Elliant 3 E 64/29/7 (1859)
	1860   => '1286143',            # Décès Elliant 3 E 64/29/8 (1860)
	1861   => '1286144',            # Décès Elliant 3 E 64/29/9 (1861)
	1862   => '1286145',            # Décès Elliant 3 E 64/29/10 (1862)
    },

    '3E064_0030' => {			# Décès Elliant 3 E 64 30   1863-1869
	1863   => '1286147',            # Décès Elliant 3 E 64/30/1 (1863)
	1864   => '1286148',            # Décès Elliant 3 E 64/30/2 (1864)
	1865   => '1286149',            # Décès Elliant 3 E 64/30/3 (1865)
	1866   => '1286150',            # Décès Elliant 3 E 64/30/4 (1866)
	1867   => '1286151',            # Décès Elliant 3 E 64/30/5 (1867)
	1868   => '1286152',            # Décès Elliant 3 E 64/30/6 (1868)
	1869   => '1286153',            # Décès Elliant 3 E 64/30/7 (1869)
    },

    '3E064_0031' => {			# Décès Elliant 3 E 64 31   1870-1880
	1870   => '1286155',            # Décès Elliant 3 E 64/31/1 (1870)
	1871   => '1286156',            # Décès Elliant 3 E 64/31/2 (1871)
	1872   => '1286157',            # Décès Elliant 3 E 64/31/3 (1872)
	1873   => '1286158',            # Décès Elliant 3 E 64/31/4 (1873)
	1874   => '1286159',            # Décès Elliant 3 E 64/31/5 (1874)
	1875   => '1286160',            # Décès Elliant 3 E 64/31/6 (1875)
	1876   => '1286161',            # Décès Elliant 3 E 64/31/7 (1876)
	1877   => '1286162',            # Décès Elliant 3 E 64/31/8 (1877)
	1878   => '1286163',            # Décès Elliant 3 E 64/31/9 (1878)
	1879   => '1286164',            # Décès Elliant 3 E 64/31/10 (1879)
	1880   => '1286165',            # Décès Elliant 3 E 64/31/11 (1880)
    },

    '3E064_0032' => {			# Décès Elliant 3 E 64 32   1881-1893
	1881   => '1286167',            # Décès Elliant 3 E 64/32/1 (1881)
	1882   => '1286168',            # Décès Elliant 3 E 64/32/2 (1882)
	1883   => '1286169',            # Décès Elliant 3 E 64/32/3 (1883)
	1884   => '1286170',            # Décès Elliant 3 E 64/32/4 (1884)
	1885   => '1286171',            # Décès Elliant 3 E 64/32/5 (1885)
	1886   => '1286172',            # Décès Elliant 3 E 64/32/6 (1886)
	1887   => '1286173',            # Décès Elliant 3 E 64/32/7 (1887)
	1888   => '1286174',            # Décès Elliant 3 E 64/32/8 (1888)
	1889   => '1286175',            # Décès Elliant 3 E 64/32/9 (1889)
	1890   => '1286176',            # Décès Elliant 3 E 64/32/10 (1890)
	1891   => '1286177',            # Décès Elliant 3 E 64/32/11 (1891)
	1892   => '1286178',            # Décès Elliant 3 E 64/32/12 (1892)
	1893   => '1286179',            # Décès Elliant 3 E 64/32/13 (1893)
    },

    '3E064_0033' => {			# Naissance Elliant 3 E 64 33   1888-1895
	1888   => '1285839',            # Naissance Elliant 3 E 64/33/1 (1888)
	1889   => '1285840',            # Naissance Elliant 3 E 64/33/2 (1889)
	1890   => '1285841',            # Naissance Elliant 3 E 64/33/3 (1890)
	1891   => '1285842',            # Naissance Elliant 3 E 64/33/4 (1891)
	1892   => '1285843',            # Naissance Elliant 3 E 64/33/5 (1892)
	1893   => '1285844',            # Naissance Elliant 3 E 64/33/6 (1893)
	1894   => '1285845',            # Naissance Elliant 3 E 64/33/7 (1894)
	1895   => '1285846',            # Naissance Elliant 3 E 64/33/8 (1895)
    },

    '3E064_0034' => {			# Naissance Elliant 3 E 64 34   1896-1902
	1896   => '1285848',            # Naissance Elliant 3 E 64/34/1 (1896)
	1897   => '1285849',            # Naissance Elliant 3 E 64/34/2 (1897)
	1898   => '1285850',            # Naissance Elliant 3 E 64/34/3 (1898)
	1899   => '1285851',            # Naissance Elliant 3 E 64/34/4 (1899)
	1900   => '1285852',            # Naissance Elliant 3 E 64/34/5 (1900)
	1901   => '1285853',            # Naissance Elliant 3 E 64/34/6 (1901)
	1902   => '1285854',            # Naissance Elliant 3 E 64/34/7 (1902)
    },

    '3E064_0035' => {			# Mariage Elliant 3 E 64 35   1895-1906
	1895   => '1286015',            # Mariage Elliant 3 E 64/35/1 (1895)
	1896   => '1286016',            # Mariage Elliant 3 E 64/35/2 (1896)
	1897   => '1286017',            # Mariage Elliant 3 E 64/35/3 (1897)
	1898   => '1286018',            # Mariage Elliant 3 E 64/35/4 (1898)
	1899   => '1286019',            # Mariage Elliant 3 E 64/35/5 (1899)
	1900   => '1286020',            # Mariage Elliant 3 E 64/35/6 (1900)
	1901   => '1286021',            # Mariage Elliant 3 E 64/35/7 (1901)
	1902   => '1286022',            # Mariage Elliant 3 E 64/35/8 (1902)
	1903   => '1286023',            # Mariage Elliant 3 E 64/35/9 (1903)
	1904   => '1286024',            # Mariage Elliant 3 E 64/35/10 (1904)
	1905   => '1286025',            # Mariage Elliant 3 E 64/35/11 (1905)
	1906   => '1286026',            # Mariage Elliant 3 E 64/35/12 (1906)
    },

    '3E064_0036' => {			# Décès Elliant 3 E 64 36   1894-1904
	1894   => '1286181',            # Décès Elliant 3 E 64/36/1 (1894)
	1895   => '1286182',            # Décès Elliant 3 E 64/36/2 (1895)
	1896   => '1286183',            # Décès Elliant 3 E 64/36/3 (1896)
	1897   => '1286184',            # Décès Elliant 3 E 64/36/4 (1897)
	1898   => '1286185',            # Décès Elliant 3 E 64/36/5 (1898)
	1899   => '1286186',            # Décès Elliant 3 E 64/36/6 (1899)
	1900   => '1286187',            # Décès Elliant 3 E 64/36/7 (1900)
	1901   => '1286188',            # Décès Elliant 3 E 64/36/8 (1901)
	1902   => '1286189',            # Décès Elliant 3 E 64/36/9 (1902)
	1903   => '1286190',            # Décès Elliant 3 E 64/36/10 (1903)
	1904   => '1286191',            # Décès Elliant 3 E 64/36/11 (1904)
    },

    '3E064_0037' => {			# Naissance Elliant 3 E 64 37   1903-1909
	1903   => '1285856',            # Naissance Elliant 3 E 64/37/1 (1903)
	1904   => '1285857',            # Naissance Elliant 3 E 64/37/2 (1904)
	1905   => '1285858',            # Naissance Elliant 3 E 64/37/3 (1905)
	1906   => '1285859',            # Naissance Elliant 3 E 64/37/4 (1906)
	1907   => '1285860',            # Naissance Elliant 3 E 64/37/5 (1907)
	1908   => '1285861',            # Naissance Elliant 3 E 64/37/6 (1908)
	1909   => '1285862',            # Naissance Elliant 3 E 64/37/7 (1909)
    },

    '3E064_0038' => {			# Décès Elliant 3 E 64 38   1905-1915
	1905   => '1286193',            # Décès Elliant 3 E 64/38/1 (1905)
	1906   => '1286194',            # Décès Elliant 3 E 64/38/2 (1906)
	1907   => '1286195',            # Décès Elliant 3 E 64/38/3 (1907)
	1908   => '1286196',            # Décès Elliant 3 E 64/38/4 (1908)
	1909   => '1286197',            # Décès Elliant 3 E 64/38/5 (1909)
	1910   => '1286198',            # Décès Elliant 3 E 64/38/6 (1910)
	1911   => '1286199',            # Décès Elliant 3 E 64/38/7 (1911)
	1912   => '1286200',            # Décès Elliant 3 E 64/38/8 (1912)
	1913   => '1286201',            # Décès Elliant 3 E 64/38/9 (1913)
	1914   => '1286202',            # Décès Elliant 3 E 64/38/10 (1914)
	1915   => '1286203',            # Décès Elliant 3 E 64/38/11 (1915)
    },

    '3E064_0039' => {			# Naissance Elliant 3 E 64 39   1910-1917
	1910   => '1285864',            # Naissance Elliant 3 E 64/39/1 (1910)
	1911   => '1285865',            # Naissance Elliant 3 E 64/39/2 (1911)
	1912   => '1285866',            # Naissance Elliant 3 E 64/39/3 (1912)
	1913   => '1285867',            # Naissance Elliant 3 E 64/39/4 (1913)
	1914   => '1285868',            # Naissance Elliant 3 E 64/39/5 (1914)
	1915   => '1285869',            # Naissance Elliant 3 E 64/39/6 (1915)
	1916   => '1285870',            # Naissance Elliant 3 E 64/39/7 (1916)
	1917   => '1285871',            # Naissance Elliant 3 E 64/39/8 (1917)
    },

    '3E064_0040' => {			# Naissance Elliant 3 E 64 40   1918-1925
	1918   => '1285873',            # Naissance Elliant 3 E 64/40/1 (1918)
	1919   => '1285874',            # Naissance Elliant 3 E 64/40/2 (1919)
	1920   => '1285875',            # Naissance Elliant 3 E 64/40/3 (1920)
	1921   => '1285876',            # Naissance Elliant 3 E 64/40/4 (1921)
	1922   => '1285877',            # Naissance Elliant 3 E 64/40/5 (1922)
	1923   => '1285878',            # Naissance Elliant 3 E 64/40/6 (1923)
	1924   => '1285879',            # Naissance Elliant 3 E 64/40/7 (1924)
	1925   => '1285880',            # Naissance Elliant 3 E 64/40/8 (1925)
    },

    '3E064_0042' => {			# Mariage Elliant 3 E 64 42   1907-1918
	1907   => '1286028',            # Mariage Elliant 3 E 64/42/1 (1907)
	1908   => '1286029',            # Mariage Elliant 3 E 64/42/2 (1908)
	1909   => '1286030',            # Mariage Elliant 3 E 64/42/3 (1909)
	1910   => '1286031',            # Mariage Elliant 3 E 64/42/4 (1910)
	1911   => '1286032',            # Mariage Elliant 3 E 64/42/5 (1911)
	1912   => '1286033',            # Mariage Elliant 3 E 64/42/6 (1912)
	1913   => '1286034',            # Mariage Elliant 3 E 64/42/7 (1913)
	1914   => '1286035',            # Mariage Elliant 3 E 64/42/8 (1914)
	1915   => '1286036',            # Mariage Elliant 3 E 64/42/9 (1915)
	1916   => '1286037',            # Mariage Elliant 3 E 64/42/10 (1916)
	1917   => '1286038',            # Mariage Elliant 3 E 64/42/11 (1917)
	1918   => '1286039',            # Mariage Elliant 3 E 64/42/12 (1918)
    },

    '3E064_0043' => {			# Mariage Elliant 3 E 64 43   1919-1925
	1919   => '1286041',            # Mariage Elliant 3 E 64/43/1 (1919)
	1920   => '1286042',            # Mariage Elliant 3 E 64/43/2 (1920)
	1921   => '1286043',            # Mariage Elliant 3 E 64/43/3 (1921)
	1922   => '1286044',            # Mariage Elliant 3 E 64/43/4 (1922)
	1923   => '1286045',            # Mariage Elliant 3 E 64/43/5 (1923)
	1924   => '1286046',            # Mariage Elliant 3 E 64/43/6 (1924)
	1925   => '1286047',            # Mariage Elliant 3 E 64/43/7 (1925)
	1926   => '1286048',            # Mariage Elliant 3 E 64/43/8 (1926)
    },

    '3E064_0044' => {			# Mariage Elliant 3 E 64 44   1927-1936
	1927   => '1286050',            # Mariage Elliant 3 E 64/44/1 (1927)
	1928   => '1286051',            # Mariage Elliant 3 E 64/44/2 (1928)
	1929   => '1286052',            # Mariage Elliant 3 E 64/44/3 (1929)
	1930   => '1286053',            # Mariage Elliant 3 E 64/44/4 (1930)
	1931   => '1286054',            # Mariage Elliant 3 E 64/44/5 (1931)
	1932   => '1286055',            # Mariage Elliant 3 E 64/44/6 (1932)
	1933   => '1286056',            # Mariage Elliant 3 E 64/44/7 (1933)
	1934   => '1286057',            # Mariage Elliant 3 E 64/44/8 (1934)
	1935   => '1286058',            # Mariage Elliant 3 E 64/44/9 (1935)
	1936   => '1286059',            # Mariage Elliant 3 E 64/44/10 (1936)
    },

    '3E064_0045' => {			# Décès Elliant 3 E 64 45   1916-1923
	1916   => '1286205',            # Décès Elliant 3 E 64/45/1 (1916)
	1917   => '1286206',            # Décès Elliant 3 E 64/45/2 (1917)
	1918   => '1286207',            # Décès Elliant 3 E 64/45/3 (1918)
	1919   => '1286208',            # Décès Elliant 3 E 64/45/4 (1919)
	1920   => '1286209',            # Décès Elliant 3 E 64/45/5 (1920)
	1921   => '1286210',            # Décès Elliant 3 E 64/45/6 (1921)
	1922   => '1286211',            # Décès Elliant 3 E 64/45/7 (1922)
	1923   => '1286212',            # Décès Elliant 3 E 64/45/8 (1923)
    },

    '3E064_0046' => {			# Décès Elliant 3 E 64 46   1924-1936
	1924   => '1286214',            # Décès Elliant 3 E 64/46/1 (1924)
	1925   => '1286215',            # Décès Elliant 3 E 64/46/2 (1925)
	1926   => '1286216',            # Décès Elliant 3 E 64/46/3 (1926)
	1927   => '1286217',            # Décès Elliant 3 E 64/46/4 (1927)
	1928   => '1286218',            # Décès Elliant 3 E 64/46/5 (1928)
	1929   => '1286219',            # Décès Elliant 3 E 64/46/6 (1929)
	1930   => '1286220',            # Décès Elliant 3 E 64/46/7 (1930)
	1931   => '1286221',            # Décès Elliant 3 E 64/46/8 (1931)
	1932   => '1286222',            # Décès Elliant 3 E 64/46/9 (1932)
	1933   => '1286223',            # Décès Elliant 3 E 64/46/10 (1933)
	1934   => '1286224',            # Décès Elliant 3 E 64/46/11 (1934)
	1935   => '1286225',            # Décès Elliant 3 E 64/46/12 (1935)
	1936   => '1286226',            # Décès Elliant 3 E 64/46/13 (1936)
    },

    # NMD Fouesnant
    '3E073_0004' => '653740.1289235',   # Naissance Fouesnant 3 E 73 4 (1793-an X)
    '3E073_0005' => '653741.1289236',   # Naissance Fouesnant 3 E 73 5 (An XI-1812)
    '3E073_0006' => '653742.1289237',   # Naissance Fouesnant 3 E 73 6 (1813-1820, 1822)
    '3E073_0007' => '653743.1289238',   # Naissance Fouesnant 3 E 73 7 (1823, 1825-1832)
    '3E073_0008' => '653744.1289239',   # Naissance Fouesnant 3 E 73 8 (1833-1842)
    '3E073_0009' => '653745.1289240',   # Naissance Fouesnant 3 E 73 9 (1843-1852)
    '3E073_0010' => '653746.1289241',   # Naissance Fouesnant 3 E 73 10 (1853-1862)
    '3E073_0011' => '653747.1289242',   # Naissance Fouesnant 3 E 73 11 (1863-1869)
    '3E073_0012' => '653748.1289243',   # Naissance Fouesnant 3 E 73 12 (1870-1877)
    '3E073_0013' => '653749.1289244',   # Naissance Fouesnant 3 E 73 13 (1878-1886)
    '3E073_0014' => '653750.1289245',   # Naissance Fouesnant 3 E 73 14 (1887-1893)
    '3E073_0015' => '653751.1289297',   # Mariage divorce (acte préliminaire) Fouesnant 3 E 73 15 (1793-an X)
    '3E073_0016' => '653752.1289298',   # Mariage Fouesnant 3 E 73 16 (an XI-1807, 1809-1812)
    '3E073_0017' => '653753.1289299',   # Mariage Fouesnant 3 E 73 17 (1813-1821)
    '3E073_0018' => '653754.1289300',   # Mariage Fouesnant 3 E 73 18 (1823-1832)
    '3E073_0019' => '653755.1289301',   # Mariage Fouesnant 3 E 73 19 (1833-1842)
    '3E073_0020' => '653756.1289302',   # Mariage Fouesnant 3 E 73 20 (1843-1852)
    '3E073_0021' => '653757.1289303',   # Mariage Fouesnant 3 E 73 21 (1853-1862)
    '3E073_0022' => '653758.1289304',   # Mariage Fouesnant 3 E 73 22 (1863-1869)
    '3E073_0023' => '653759.1289305',   # Mariage Fouesnant 3 E 73 23 (1870-1879)
    '3E073_0024' => '653760.1289306',   # Mariage Fouesnant 3 E 73 24 (1880-1891)
    '3E073_0025' => '653761.1289367',   # Décès Fouesnant 3 E 73 25 (1793-an X)
    '3E073_0026' => '653762.1289368',   # Décès Fouesnant 3 E 73 26 (an XI-1807, 1810-1812)
    '3E073_0027' => '653763.1289369',   # Décès Fouesnant 3 E 73 27 (1813-1818, 1820, 1822)
    '3E073_0028' => '653764.1289370',   # Décès Fouesnant 3 E 73 28 (1823-1824, 1826-1832)
    '3E073_0029' => '653765.1289371',   # Décès Fouesnant 3 E 73 29 (1833-1842)
    '3E073_0030' => '653766.1289372',   # Décès Fouesnant 3 E 73 30 (1843-1852)
    '3E073_0031' => '653767.1289373',   # Décès Fouesnant 3 E 73 31 (1853-1862)
    '3E073_0032' => '653768.1289374',   # Décès Fouesnant 3 E 73 32 (1863-1869)
    '3E073_0033' => '653769.1289375',   # Décès Fouesnant 3 E 73 33 (1870-1880)
    '3E073_0034' => '653770.1289376',   # Décès Fouesnant 3 E 73 34 (1881-1890)
    '3E073_0035' => '653771.1289246',   # Naissance Fouesnant 3 E 73 35 (1894-1901)
    '3E073_0036' => '653772.1289377',   # Décès Fouesnant 3 E 73 36 (1891-1901)

    '3E073_0037' => {			# Mariage Fouesnant 3 E 73 37   1892-1902
	1892   => '1289308',            # Mariage Fouesnant 3 E 73/37/1 (1892)
	1893   => '1289309',            # Mariage Fouesnant 3 E 73/37/2 (1893)
	1894   => '1289310',            # Mariage Fouesnant 3 E 73/37/3 (1894)
	1895   => '1289311',            # Mariage Fouesnant 3 E 73/37/4 (1895)
	1896   => '1289312',            # Mariage Fouesnant 3 E 73/37/5 (1896)
	1897   => '1289313',            # Mariage Fouesnant 3 E 73/37/6 (1897)
	1898   => '1289314',            # Mariage Fouesnant 3 E 73/37/7 (1898)
	1899   => '1289315',            # Mariage Fouesnant 3 E 73/37/8 (1899)
	1900   => '1289316',            # Mariage Fouesnant 3 E 73/37/9 (1900)
	1901   => '1289317',            # Mariage Fouesnant 3 E 73/37/10 (1901)
	1902   => '1289318',            # Mariage Fouesnant 3 E 73/37/11 (1902)
    },

    '3E073_0038' => {			# Naissance Fouesnant 3 E 73 38   1878-1908
	1878   => '1289418',            # Naissance Fouesnant 3 E 73/38/1 (1878)
	1879   => '1289419',            # Naissance Fouesnant 3 E 73/38/2 (1879)
	1880   => '1289420',            # Naissance Fouesnant 3 E 73/38/3 (1880)
	1881   => '1289421',            # Naissance Fouesnant 3 E 73/38/4 (1881)
	1882   => '1289422',            # Naissance Fouesnant 3 E 73/38/5 (1882)
	1884   => '1289423',            # Naissance Fouesnant 3 E 73/38/6 (1884)
	1885   => '1289424',            # Naissance Fouesnant 3 E 73/38/7 (1885)
	1888   => '1289425',            # Naissance Fouesnant 3 E 73/38/8 (1888)
	1889   => '1289426',            # Naissance Fouesnant 3 E 73/38/9 (1889)
	1890   => '1289427',            # Naissance Fouesnant 3 E 73/38/10 (1890)
	1891   => '1289428',            # Naissance Fouesnant 3 E 73/38/11 (1891)
	1892   => '1289429',            # Naissance Fouesnant 3 E 73/38/12 (1892)
	1893   => '1289430',            # Naissance Fouesnant 3 E 73/38/13 (1893)
	1894   => '1289431',            # Naissance Fouesnant 3 E 73/38/14 (1894)
	1896   => '1289432',            # Naissance Fouesnant 3 E 73/38/15 (1896)
	1897   => '1289433',            # Naissance Fouesnant 3 E 73/38/16 (1897)
	1898   => '1289434',            # Naissance Fouesnant 3 E 73/38/17 (1898)
	1899   => '1289435',            # Naissance Fouesnant 3 E 73/38/18 (1899)
	1900   => '1289436',            # Naissance Fouesnant 3 E 73/38/19 (1900)
	1901   => '1289437',            # Naissance Fouesnant 3 E 73/38/20 (1901)
	1902   => '1289438',            # Naissance Fouesnant 3 E 73/38/21 (1902)
	1903   => '1289439',            # Naissance Fouesnant 3 E 73/38/22 (1903)
	1904   => '1289440',            # Naissance Fouesnant 3 E 73/38/23 (1904)
	1905   => '1289441',            # Naissance Fouesnant 3 E 73/38/24 (1905)
	1906   => '1289442',            # Naissance Fouesnant 3 E 73/38/25 (1906)
	1907   => '1289443',            # Naissance Fouesnant 3 E 73/38/26 (1907)
	1908   => '1289444',            # Naissance Fouesnant 3 E 73/38/27 (1908)
    },

    '3E073_0039' => {			# Mariage publication de mariage Fouesnant 3 E 73 39   1878-1908
	1878   => '1289446',            # Mariage publication de mariage Fouesnant 3 E 73/39/1 (1878)
	1879   => '1289447',            # Mariage publication de mariage Fouesnant 3 E 73/39/2 (1879)
	1880   => '1289448',            # Mariage publication de mariage Fouesnant 3 E 73/39/3 (1880)
	1881   => '1289449',            # Mariage publication de mariage Fouesnant 3 E 73/39/4 (1881)
	1882   => '1289450',            # Mariage publication de mariage Fouesnant 3 E 73/39/5 (1882)
	1884   => '1289451',            # Mariage publication de mariage Fouesnant 3 E 73/39/6 (1884)
	1885   => '1289452',            # Mariage publication de mariage Fouesnant 3 E 73/39/7 (1885)
	1888   => '1289453',            # Mariage publication de mariage Fouesnant 3 E 73/39/8 (1888)
	1889   => '1289454',            # Mariage publication de mariage Fouesnant 3 E 73/39/9 (1889)
	1890   => '1289455',            # Mariage publication de mariage Fouesnant 3 E 73/39/10 (1890)
	1891   => '1289456',            # Mariage publication de mariage Fouesnant 3 E 73/39/11 (1891)
	1892   => '1289457',            # Mariage publication de mariage Fouesnant 3 E 73/39/12 (1892)
	1893   => '1289458',            # Mariage publication de mariage Fouesnant 3 E 73/39/13 (1893)
	1894   => '1289459',            # Mariage publication de mariage Fouesnant 3 E 73/39/14 (1894)
	1896   => '1289460',            # Mariage publication de mariage Fouesnant 3 E 73/39/15 (1896)
	1897   => '1289461',            # Mariage publication de mariage Fouesnant 3 E 73/39/16 (1897)
	1898   => '1289462',            # Mariage publication de mariage Fouesnant 3 E 73/39/17 (1898)
	1899   => '1289463',            # Mariage publication de mariage Fouesnant 3 E 73/39/18 (1899)
	1900   => '1289464',            # Mariage publication de mariage Fouesnant 3 E 73/39/19 (1900)
	1901   => '1289465',            # Mariage publication de mariage Fouesnant 3 E 73/39/20 (1901)
	1902   => '1289466',            # Mariage publication de mariage Fouesnant 3 E 73/39/21 (1902)
	1903   => '1289467',            # Mariage publication de mariage Fouesnant 3 E 73/39/22 (1903)
	1904   => '1289468',            # Mariage publication de mariage Fouesnant 3 E 73/39/23 (1904)
	1905   => '1289469',            # Mariage publication de mariage Fouesnant 3 E 73/39/24 (1905)
	1906   => '1289470',            # Mariage publication de mariage Fouesnant 3 E 73/39/25 (1906)
	1907   => '1289471',            # Mariage publication de mariage Fouesnant 3 E 73/39/26 (1907)
	1908   => '1289472',            # Mariage publication de mariage Fouesnant 3 E 73/39/27 (1908)
    },

    '3E073_0040' => {			# Décès Fouesnant 3 E 73 40   1878-1908
	1878   => '1289474',            # Décès Fouesnant 3 E 73/40/1 (1878)
	1879   => '1289475',            # Décès Fouesnant 3 E 73/40/2 (1879)
	1880   => '1289476',            # Décès Fouesnant 3 E 73/40/3 (1880)
	1881   => '1289477',            # Décès Fouesnant 3 E 73/40/4 (1881)
	1882   => '1289478',            # Décès Fouesnant 3 E 73/40/5 (1882)
	1884   => '1289479',            # Décès Fouesnant 3 E 73/40/6 (1884)
	1885   => '1289480',            # Décès Fouesnant 3 E 73/40/7 (1885)
	1888   => '1289481',            # Décès Fouesnant 3 E 73/40/8 (1888)
	1889   => '1289482',            # Décès Fouesnant 3 E 73/40/9 (1889)
	1890   => '1289483',            # Décès Fouesnant 3 E 73/40/10 (1890)
	1891   => '1289484',            # Décès Fouesnant 3 E 73/40/11 (1891)
	1892   => '1289485',            # Décès Fouesnant 3 E 73/40/12 (1892)
	1893   => '1289486',            # Décès Fouesnant 3 E 73/40/13 (1893)
	1894   => '1289487',            # Décès Fouesnant 3 E 73/40/14 (1894)
	1896   => '1289488',            # Décès Fouesnant 3 E 73/40/15 (1896)
	1897   => '1289489',            # Décès Fouesnant 3 E 73/40/16 (1897)
	1898   => '1289490',            # Décès Fouesnant 3 E 73/40/17 (1898)
	1899   => '1289491',            # Décès Fouesnant 3 E 73/40/18 (1899)
	1900   => '1289492',            # Décès Fouesnant 3 E 73/40/19 (1900)
	1901   => '1289493',            # Décès Fouesnant 3 E 73/40/20 (1901)
	1902   => '1289494',            # Décès Fouesnant 3 E 73/40/21 (1902)
	1903   => '1289495',            # Décès Fouesnant 3 E 73/40/22 (1903)
	1904   => '1289496',            # Décès Fouesnant 3 E 73/40/23 (1904)
	1905   => '1289497',            # Décès Fouesnant 3 E 73/40/24 (1905)
	1906   => '1289498',            # Décès Fouesnant 3 E 73/40/25 (1906)
	1907   => '1289499',            # Décès Fouesnant 3 E 73/40/26 (1907)
	1908   => '1289500',            # Décès Fouesnant 3 E 73/40/27 (1908)
    },

    '3E073_0041' => {			# Naissance Fouesnant 3 E 73 41   1902-1909
	1902   => '1289248',            # Naissance Fouesnant 3 E 73/41/1 (1902)
	1903   => '1289249',            # Naissance Fouesnant 3 E 73/41/2 (1903)
	1904   => '1289250',            # Naissance Fouesnant 3 E 73/41/3 (1904)
	1905   => '1289251',            # Naissance Fouesnant 3 E 73/41/4 (1905)
	1906   => '1289252',            # Naissance Fouesnant 3 E 73/41/5 (1906)
	1907   => '1289253',            # Naissance Fouesnant 3 E 73/41/6 (1907)
	1908   => '1289254',            # Naissance Fouesnant 3 E 73/41/7 (1908)
	1909   => '1289255',            # Naissance Fouesnant 3 E 73/41/8 (1909)
    },

    '3E073_0042' => {			# Mariage Fouesnant 3 E 73 42   1903-1914
	1903   => '1289320',            # Mariage Fouesnant 3 E 73/42/1 (1903)
	1904   => '1289321',            # Mariage Fouesnant 3 E 73/42/2 (1904)
	1905   => '1289322',            # Mariage Fouesnant 3 E 73/42/3 (1905)
	1906   => '1289323',            # Mariage Fouesnant 3 E 73/42/4 (1906)
	1907   => '1289324',            # Mariage Fouesnant 3 E 73/42/5 (1907)
	1908   => '1289325',            # Mariage Fouesnant 3 E 73/42/6 (1908)
	1909   => '1289326',            # Mariage Fouesnant 3 E 73/42/7 (1909)
	1910   => '1289327',            # Mariage Fouesnant 3 E 73/42/8 (1910)
	1911   => '1289328',            # Mariage Fouesnant 3 E 73/42/9 (1911)
	1912   => '1289329',            # Mariage Fouesnant 3 E 73/42/10 (1912)
	1913   => '1289330',            # Mariage Fouesnant 3 E 73/42/11 (1913)
	1914   => '1289331',            # Mariage Fouesnant 3 E 73/42/12 (1914)
    },

    '3E073_0043' => {			# Décès Fouesnant 3 E 73 43   1902-1915
	1902   => '1289379',            # Décès Fouesnant 3 E 73/43/1 (1902)
	1903   => '1289380',            # Décès Fouesnant 3 E 73/43/2 (1903)
	1904   => '1289381',            # Décès Fouesnant 3 E 73/43/3 (1904)
	1905   => '1289382',            # Décès Fouesnant 3 E 73/43/4 (1905)
	1906   => '1289383',            # Décès Fouesnant 3 E 73/43/5 (1906)
	1907   => '1289384',            # Décès Fouesnant 3 E 73/43/6 (1907)
	1908   => '1289385',            # Décès Fouesnant 3 E 73/43/7 (1908)
	1909   => '1289386',            # Décès Fouesnant 3 E 73/43/8 (1909)
	1910   => '1289387',            # Décès Fouesnant 3 E 73/43/9 (1910)
	1911   => '1289388',            # Décès Fouesnant 3 E 73/43/10 (1911)
	1912   => '1289389',            # Décès Fouesnant 3 E 73/43/11 (1912)
	1913   => '1289390',            # Décès Fouesnant 3 E 73/43/12 (1913)
	1914   => '1289391',            # Décès Fouesnant 3 E 73/43/13 (1914)
	1915   => '1289392',            # Décès Fouesnant 3 E 73/43/14 (1915)
    },

    '3E073_0044' => {			# Naissance Fouesnant 3 E 73 44   1910-1917
	1910   => '1289257',            # Naissance Fouesnant 3 E 73/44/1 (1910)
	1911   => '1289258',            # Naissance Fouesnant 3 E 73/44/2 (1911)
	1912   => '1289259',            # Naissance Fouesnant 3 E 73/44/3 (1912)
	1913   => '1289260',            # Naissance Fouesnant 3 E 73/44/4 (1913)
	1914   => '1289261',            # Naissance Fouesnant 3 E 73/44/5 (1914)
	1915   => '1289262',            # Naissance Fouesnant 3 E 73/44/6 (1915)
	1916   => '1289263',            # Naissance Fouesnant 3 E 73/44/7 (1916)
	1917   => '1289264',            # Naissance Fouesnant 3 E 73/44/8 (1917)
    },

    '3E073_0045' => {			# Naissance Fouesnant 3 E 73 45   1918-1925
	1918   => '1289266',            # Naissance Fouesnant 3 E 73/45/1 (1918)
	1919   => '1289267',            # Naissance Fouesnant 3 E 73/45/2 (1919)
	1920   => '1289268',            # Naissance Fouesnant 3 E 73/45/3 (1920)
	1921   => '1289269',            # Naissance Fouesnant 3 E 73/45/4 (1921)
	1922   => '1289270',            # Naissance Fouesnant 3 E 73/45/5 (1922)
	1923   => '1289271',            # Naissance Fouesnant 3 E 73/45/6 (1923)
	1924   => '1289272',            # Naissance Fouesnant 3 E 73/45/7 (1924)
	1925   => '1289273',            # Naissance Fouesnant 3 E 73/45/8 (1925)
    },

    '3E073_0047' => {			# Mariage Fouesnant 3 E 73 47   1915-1924
	1915   => '1289333',            # Mariage Fouesnant 3 E 73/47/1 (1915)
	1916   => '1289334',            # Mariage Fouesnant 3 E 73/47/2 (1916)
	1917   => '1289335',            # Mariage Fouesnant 3 E 73/47/3 (1917)
	1918   => '1289336',            # Mariage Fouesnant 3 E 73/47/4 (1918)
	1919   => '1289337',            # Mariage Fouesnant 3 E 73/47/5 (1919)
	1920   => '1289338',            # Mariage Fouesnant 3 E 73/47/6 (1920)
	1921   => '1289339',            # Mariage Fouesnant 3 E 73/47/7 (1921)
	1922   => '1289340',            # Mariage Fouesnant 3 E 73/47/8 (1922)
	1923   => '1289341',            # Mariage Fouesnant 3 E 73/47/9 (1923)
	1924   => '1289342',            # Mariage Fouesnant 3 E 73/47/10 (1924)
    },

    '3E073_0048' => {			# Mariage Fouesnant 3 E 73 48   1925-1936
	1925   => '1289344',            # Mariage Fouesnant 3 E 73/48/1 (1925)
	1926   => '1289345',            # Mariage Fouesnant 3 E 73/48/2 (1926)
	1927   => '1289346',            # Mariage Fouesnant 3 E 73/48/3 (1927)
	1928   => '1289347',            # Mariage Fouesnant 3 E 73/48/4 (1928)
	1929   => '1289348',            # Mariage Fouesnant 3 E 73/48/5 (1929)
	1930   => '1289349',            # Mariage Fouesnant 3 E 73/48/6 (1930)
	1931   => '1289350',            # Mariage Fouesnant 3 E 73/48/7 (1931)
	1932   => '1289351',            # Mariage Fouesnant 3 E 73/48/8 (1932)
	1933   => '1289352',            # Mariage Fouesnant 3 E 73/48/9 (1933)
	1934   => '1289353',            # Mariage Fouesnant 3 E 73/48/10 (1934)
	1935   => '1289354',            # Mariage Fouesnant 3 E 73/48/11 (1935)
	1936   => '1289355',            # Mariage Fouesnant 3 E 73/48/12 (1936)
    },

    '3E073_0049' => {			# Décès Fouesnant 3 E 73 49   1916-1924
	1916   => '1289394',            # Décès Fouesnant 3 E 73/49/1 (1916)
	1917   => '1289395',            # Décès Fouesnant 3 E 73/49/2 (1917)
	1918   => '1289396',            # Décès Fouesnant 3 E 73/49/3 (1918)
	1919   => '1289397',            # Décès Fouesnant 3 E 73/49/4 (1919)
	1920   => '1289398',            # Décès Fouesnant 3 E 73/49/5 (1920)
	1921   => '1289399',            # Décès Fouesnant 3 E 73/49/6 (1921)
	1922   => '1289400',            # Décès Fouesnant 3 E 73/49/7 (1922)
	1923   => '1289401',            # Décès Fouesnant 3 E 73/49/8 (1923)
	1924   => '1289402',            # Décès Fouesnant 3 E 73/49/9 (1924)
    },

    '3E073_0050' => {			# Décès Fouesnant 3 E 73 50   1925-1936
	1925   => '1289404',            # Décès Fouesnant 3 E 73/50/1 (1925)
	1926   => '1289405',            # Décès Fouesnant 3 E 73/50/2 (1926)
	1927   => '1289406',            # Décès Fouesnant 3 E 73/50/3 (1927)
	1928   => '1289407',            # Décès Fouesnant 3 E 73/50/4 (1928)
	1929   => '1289408',            # Décès Fouesnant 3 E 73/50/5 (1929)
	1930   => '1289409',            # Décès Fouesnant 3 E 73/50/6 (1930)
	1931   => '1289410',            # Décès Fouesnant 3 E 73/50/7 (1931)
	1932   => '1289411',            # Décès Fouesnant 3 E 73/50/8 (1932)
	1933   => '1289412',            # Décès Fouesnant 3 E 73/50/9 (1933)
	1934   => '1289413',            # Décès Fouesnant 3 E 73/50/10 (1934)
	1935   => '1289414',            # Décès Fouesnant 3 E 73/50/11 (1935)
	1936   => '1289415',            # Décès Fouesnant 3 E 73/50/12 (1936)
    },

    # NMD Kergloff
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

    '3E106_0032' => {			# Mariage Kergloff 3 E 106 32   1918-1936
	1918   => '1302126',            # Mariage Kergloff 3 E 106/32/1 (1918)
	1919   => '1302127',            # Mariage Kergloff 3 E 106/32/2 (1919)
	1920   => '1302128',            # Mariage Kergloff 3 E 106/32/3 (1920)
	1921   => '1302129',            # Mariage Kergloff 3 E 106/32/4 (1921)
	1922   => '1302130',            # Mariage Kergloff 3 E 106/32/5 (1922)
	1923   => '1302131',            # Mariage Kergloff 3 E 106/32/6 (1923)
	1924   => '1302132',            # Mariage Kergloff 3 E 106/32/7 (1924)
	1925   => '1302133',            # Mariage Kergloff 3 E 106/32/8 (1925)
	1926   => '1302134',            # Mariage Kergloff 3 E 106/32/9 (1926)
	1927   => '1302135',            # Mariage Kergloff 3 E 106/32/10 (1927)
	1928   => '1302136',            # Mariage Kergloff 3 E 106/32/11 (1928)
	1929   => '1302137',            # Mariage Kergloff 3 E 106/32/12 (1929)
	1930   => '1302138',            # Mariage Kergloff 3 E 106/32/13 (1930)
	1931   => '1302139',            # Mariage Kergloff 3 E 106/32/14 (1931)
	1932   => '1302140',            # Mariage Kergloff 3 E 106/32/15 (1932)
	1933   => '1302141',            # Mariage Kergloff 3 E 106/32/16 (1933)
	1934   => '1302142',            # Mariage Kergloff 3 E 106/32/17 (1934)
	1935   => '1302143',            # Mariage Kergloff 3 E 106/32/18 (1935)
	1936   => '1302144',            # Mariage Kergloff 3 E 106/32/19 (1936)
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

    # NMD Kernével
    '3E109_0006' => {			# Naissance Kernével 3 E 109 6   AN02-AN10
	'AN02' => '1302796',            # Naissance Kernével 3 E 109/6/1 (1793 - an II)
	'AN03' => '1302797',            # Naissance Kernével 3 E 109/6/2 (an III)
	'AN04' => '1302798',            # Naissance Kernével 3 E 109/6/3 (an IV)
	'AN05' => '1302799',            # Naissance Kernével 3 E 109/6/4 (an V)
	'AN06' => '1302800',            # Naissance Kernével 3 E 109/6/5 (an VI)
	'AN07' => '1302801',            # Naissance Kernével 3 E 109/6/6 (an VII)
	'AN08' => '1302802',            # Naissance Kernével 3 E 109/6/7 (an VIII)
	'AN09' => '1302803',            # Naissance Kernével 3 E 109/6/8 (an IX)
	'AN10' => '1302804',            # Naissance Kernével 3 E 109/6/9 (an X)
    },

    '3E109_0007' => {			# Naissance Kernével 3 E 109 7   AN11-1812
	'AN11' => '1302806',            # Naissance Kernével 3 E 109/7/1 (an XI)
	'AN12' => '1302807',            # Naissance Kernével 3 E 109/7/2 (an XII)
	'AN13' => '1302808',            # Naissance Kernével 3 E 109/7/3 (an XIII)
	'AN14' => '1302809',            # Naissance Kernével 3 E 109/7/4 (an XIV - 1806)
	1807   => '1302810',            # Naissance Kernével 3 E 109/7/5 (1807)
	1808   => '1302811',            # Naissance Kernével 3 E 109/7/6 (1808)
	1809   => '1302812',            # Naissance Kernével 3 E 109/7/7 (1809)
	1810   => '1302813',            # Naissance Kernével 3 E 109/7/8 (1810)
	1811   => '1302814',            # Naissance Kernével 3 E 109/7/9 (1811)
	1812   => '1302815',            # Naissance Kernével 3 E 109/7/10 (1812)
    },

    '3E109_0008' => {			# Naissance Kernével 3 E 109 8   1813-1817
	1813   => '1302817',            # Naissance Kernével 3 E 109/8/1 (1813)
	1814   => '1302818',            # Naissance Kernével 3 E 109/8/2 (1814)
	1815   => '1302819',            # Naissance Kernével 3 E 109/8/3 (1815)
	1816   => '1302820',            # Naissance Kernével 3 E 109/8/4 (1816)
	1817   => '1302821',            # Naissance Kernével 3 E 109/8/5 (1817)
    },

    '3E109_0009' => {			# Naissance Kernével 3 E 109 9   1823-1832
	1823   => '1302828',            # Naissance Kernével 3 E 109/9/1 (1823)
	1824   => '1302829',            # Naissance Kernével 3 E 109/9/2 (1824)
	1825   => '1302830',            # Naissance Kernével 3 E 109/9/3 (1825)
	1826   => '1302831',            # Naissance Kernével 3 E 109/9/4 (1826)
	1827   => '1302832',            # Naissance Kernével 3 E 109/9/5 (1827)
	1828   => '1302833',            # Naissance Kernével 3 E 109/9/6 (1828)
	1829   => '1302834',            # Naissance Kernével 3 E 109/9/7 (1829)
	1830   => '1302835',            # Naissance Kernével 3 E 109/9/8 (1830)
	1831   => '1302836',            # Naissance Kernével 3 E 109/9/9 (1831)
	1832   => '1302837',            # Naissance Kernével 3 E 109/9/10 (1832)
    },

    '3E109_0010' => {			# Naissance Kernével 3 E 109 10   1833-1842
	1833   => '1302839',            # Naissance Kernével 3 E 109/10/1 (1833)
	1834   => '1302840',            # Naissance Kernével 3 E 109/10/2 (1834)
	1835   => '1302841',            # Naissance Kernével 3 E 109/10/3 (1835)
	1836   => '1302842',            # Naissance Kernével 3 E 109/10/4 (1836)
	1837   => '1302843',            # Naissance Kernével 3 E 109/10/5 (1837)
	1838   => '1302844',            # Naissance Kernével 3 E 109/10/6 (1838)
	1839   => '1302845',            # Naissance Kernével 3 E 109/10/7 (1839)
	1840   => '1302846',            # Naissance Kernével 3 E 109/10/8 (1840)
	1841   => '1302847',            # Naissance Kernével 3 E 109/10/9 (1841)
	1842   => '1302848',            # Naissance Kernével 3 E 109/10/10 (1842)
    },

    '3E109_0011' => {			# Naissance Kernével 3 E 109 11   1843-1852
	1843   => '1302850',            # Naissance Kernével 3 E 109/11/1 (1843)
	1844   => '1302851',            # Naissance Kernével 3 E 109/11/2 (1844)
	1845   => '1302852',            # Naissance Kernével 3 E 109/11/3 (1845)
	1846   => '1302853',            # Naissance Kernével 3 E 109/11/4 (1846)
	1847   => '1302854',            # Naissance Kernével 3 E 109/11/5 (1847)
	1848   => '1302855',            # Naissance Kernével 3 E 109/11/6 (1848)
	1849   => '1302856',            # Naissance Kernével 3 E 109/11/7 (1849)
	1850   => '1302857',            # Naissance Kernével 3 E 109/11/8 (1850)
	1851   => '1302858',            # Naissance Kernével 3 E 109/11/9 (1851)
	1852   => '1302859',            # Naissance Kernével 3 E 109/11/10 (1852)
    },

    '3E109_0012' => {			# Naissance Kernével 3 E 109 12   1853-1862
	1853   => '1302861',            # Naissance Kernével 3 E 109/12/1 (1853)
	1854   => '1302862',            # Naissance Kernével 3 E 109/12/2 (1854)
	1855   => '1302863',            # Naissance Kernével 3 E 109/12/3 (1855)
	1856   => '1302864',            # Naissance Kernével 3 E 109/12/4 (1856)
	1857   => '1302865',            # Naissance Kernével 3 E 109/12/5 (1857)
	1858   => '1302866',            # Naissance Kernével 3 E 109/12/6 (1858)
	1859   => '1302867',            # Naissance Kernével 3 E 109/12/7 (1859)
	1860   => '1302868',            # Naissance Kernével 3 E 109/12/8 (1860)
	1861   => '1302869',            # Naissance Kernével 3 E 109/12/9 (1861)
	1862   => '1302870',            # Naissance Kernével 3 E 109/12/10 (1862)
    },

    '3E109_0013' => {			# Naissance Kernével 3 E 109 13   1863-1869
	1863   => '1302872',            # Naissance Kernével 3 E 109/13/1 (1863)
	1864   => '1302873',            # Naissance Kernével 3 E 109/13/2 (1864)
	1865   => '1302874',            # Naissance Kernével 3 E 109/13/3 (1865)
	1866   => '1302875',            # Naissance Kernével 3 E 109/13/4 (1866)
	1867   => '1302876',            # Naissance Kernével 3 E 109/13/5 (1867)
	1868   => '1302877',            # Naissance Kernével 3 E 109/13/6 (1868)
	1869   => '1302878',            # Naissance Kernével 3 E 109/13/7 (1869)
    },

    '3E109_0014' => {			# Naissance Kernével 3 E 109 14   1870-1881
	1870   => '1302880',            # Naissance Kernével 3 E 109/14/1 (1870)
	1871   => '1302881',            # Naissance Kernével 3 E 109/14/2 (1871)
	1872   => '1302882',            # Naissance Kernével 3 E 109/14/3 (1872)
	1873   => '1302883',            # Naissance Kernével 3 E 109/14/4 (1873)
	1874   => '1302884',            # Naissance Kernével 3 E 109/14/5 (1874)
	1875   => '1302885',            # Naissance Kernével 3 E 109/14/6 (1875)
	1876   => '1302886',            # Naissance Kernével 3 E 109/14/7 (1876)
	1877   => '1302887',            # Naissance Kernével 3 E 109/14/8 (1877)
	1878   => '1302888',            # Naissance Kernével 3 E 109/14/9 (1878)
	1879   => '1302889',            # Naissance Kernével 3 E 109/14/10 (1879)
	1880   => '1302890',            # Naissance Kernével 3 E 109/14/11 (1880)
	1881   => '1302891',            # Naissance Kernével 3 E 109/14/12 (1881)
    },

    '3E109_0015' => {			# Naissance Kernével 3 E 109 15   1882-1890
	1882   => '1302893',            # Naissance Kernével 3 E 109/15/1 (1882)
	1883   => '1302894',            # Naissance Kernével 3 E 109/15/2 (1883)
	1884   => '1302895',            # Naissance Kernével 3 E 109/15/3 (1884)
	1885   => '1302896',            # Naissance Kernével 3 E 109/15/4 (1885)
	1886   => '1302897',            # Naissance Kernével 3 E 109/15/5 (1886)
	1887   => '1302898',            # Naissance Kernével 3 E 109/15/6 (1887)
	1888   => '1302899',            # Naissance Kernével 3 E 109/15/7 (1888)
	1889   => '1302900',            # Naissance Kernével 3 E 109/15/8 (1889)
	1890   => '1302901',            # Naissance Kernével 3 E 109/15/9 (1890)
    },

    '3E109_0016' => {			# Mariage promesse de mariage Kernével 3 E 109 16   AN02-AN10
	'AN02' => '1302955',            # Mariage promesse de mariage Kernével 3 E 109/16/1 (1793 - an II)
	'AN03' => '1302956',            # Mariage promesse de mariage Kernével 3 E 109/16/2 (an III)
	'AN04' => '1302957',            # Mariage promesse de mariage Kernével 3 E 109/16/3 (an IV)
	'AN05' => '1302958',            # Mariage promesse de mariage Kernével 3 E 109/16/4 (an V)
	'AN06' => '1302959',            # Mariage promesse de mariage Kernével 3 E 109/16/5 (an VI)
	'AN07' => '1302960',            # Mariage promesse de mariage Kernével 3 E 109/16/6 (an VII)
	'AN08' => '1302961',            # Mariage promesse de mariage Kernével 3 E 109/16/7 (an VIII)
	'AN09' => '1302962',            # Mariage promesse de mariage Kernével 3 E 109/16/8 (an IX)
	'AN10' => '1302963',            # Mariage promesse de mariage Kernével 3 E 109/16/9 (an X)
    },

    '3E109_0017' => {			# Mariage Kernével 3 E 109 17   AN11-1812
	'AN11' => '1302965',            # Mariage Kernével 3 E 109/17/1 (an XI)
	'AN12' => '1302966',            # Mariage Kernével 3 E 109/17/2 (an XII)
	'AN13' => '1302967',            # Mariage Kernével 3 E 109/17/3 (an XIII)
	'AN14' => '1302968',            # Mariage Kernével 3 E 109/17/4 (an XIV - 1806)
	1807   => '1302969',            # Mariage Kernével 3 E 109/17/5 (1807)
	1808   => '1302970',            # Mariage Kernével 3 E 109/17/6 (1808)
	1809   => '1302971',            # Mariage Kernével 3 E 109/17/7 (1809)
	1810   => '1302972',            # Mariage Kernével 3 E 109/17/8 (1810)
	1811   => '1302973',            # Mariage Kernével 3 E 109/17/9 (1811)
	1812   => '1302974',            # Mariage Kernével 3 E 109/17/10 (1812)
    },

    '3E109_0018' => {			# Mariage Kernével 3 E 109 18   1813-1823
	1813   => '1302976',            # Mariage Kernével 3 E 109/18/1 (1813)
	1814   => '1302977',            # Mariage Kernével 3 E 109/18/2 (1814)
	1815   => '1302978',            # Mariage Kernével 3 E 109/18/3 (1815)
	1816   => '1302979',            # Mariage Kernével 3 E 109/18/4 (1816)
	1817   => '1302980',            # Mariage Kernével 3 E 109/18/5 (1817)
	1818   => '1302981',            # Mariage Kernével 3 E 109/18/6 (1818)
	1819   => '1302982',            # Mariage Kernével 3 E 109/18/7 (1819)
	1820   => '1302983',            # Mariage Kernével 3 E 109/18/8 (1820)
	1821   => '1302984',            # Mariage Kernével 3 E 109/18/9 (1821)
	1822   => '1302985',            # Mariage Kernével 3 E 109/18/10 (1822)
	1823   => '1302986',            # Mariage Kernével 3 E 109/18/11 (1823)
    },

    '3E109_0019' => {			# Mariage Kernével 3 E 109 19   1824-1832
	1824   => '1302988',            # Mariage Kernével 3 E 109/19/1 (1824)
	1825   => '1302989',            # Mariage Kernével 3 E 109/19/2 (1825)
	1826   => '1302990',            # Mariage Kernével 3 E 109/19/3 (1826)
	1827   => '1302991',            # Mariage Kernével 3 E 109/19/4 (1827)
	1828   => '1302992',            # Mariage Kernével 3 E 109/19/5 (1828)
	1829   => '1302993',            # Mariage Kernével 3 E 109/19/6 (1829)
	1830   => '1302994',            # Mariage Kernével (Rosporden, Finistère) 3 E 109/19/7 (1830)
	1831   => '1302995',            # Mariage Kernével (Rosporden, Finistère) 3 E 109/19/8 (1831)
	1832   => '1302996',            # Mariage Kernével (Rosporden, Finistère) 3 E 109/19/9 (1832)
    },

    '3E109_0020' => {			# Mariage Kernével 3 E 109 20   1833-1842
	1833   => '1302998',            # Mariage Kernével 3 E 109/20/1 (1833)
	1834   => '1302999',            # Mariage Kernével 3 E 109/20/2 (1834)
	1835   => '1303000',            # Mariage Kernével 3 E 109/20/3 (1835)
	1836   => '1303001',            # Mariage Kernével 3 E 109/20/4 (1836)
	1837   => '1303002',            # Mariage Kernével 3 E 109/20/5 (1837)
	1838   => '1303003',            # Mariage Kernével 3 E 109/20/6 (1838)
	1839   => '1303004',            # Mariage Kernével 3 E 109/20/7 (1839)
	1840   => '1303005',            # Mariage Kernével 3 E 109/20/8 (1840)
	1841   => '1303006',            # Mariage Kernével 3 E 109/20/9 (1841)
	1842   => '1303007',            # Mariage Kernével 3 E 109/20/10 (1842)
    },

    '3E109_0021' => {			# Mariage Kernével 3 E 109 21   1843-1852
	1843   => '1303009',            # Mariage Kernével 3 E 109/21/1 (1843)
	1844   => '1303010',            # Mariage Kernével 3 E 109/21/2 (1844)
	1845   => '1303011',            # Mariage Kernével 3 E 109/21/3 (1845)
	1846   => '1303012',            # Mariage Kernével 3 E 109/21/4 (1846)
	1847   => '1303013',            # Mariage Kernével 3 E 109/21/5 (1847)
	1848   => '1303014',            # Mariage Kernével 3 E 109/21/6 (1848)
	1849   => '1303015',            # Mariage Kernével 3 E 109/21/7 (1849)
	1850   => '1303016',            # Mariage Kernével 3 E 109/21/8 (1850)
	1851   => '1303017',            # Mariage Kernével 3 E 109/21/9 (1851)
	1852   => '1303018',            # Mariage Kernével 3 E 109/21/10 (1852)
    },

    '3E109_0022' => {			# Mariage Kernével 3 E 109 22   1853-1862
	1853   => '1303020',            # Mariage Kernével 3 E 109/22/1 (1853)
	1854   => '1303021',            # Mariage Kernével 3 E 109/22/2 (1854)
	1855   => '1303022',            # Mariage Kernével 3 E 109/22/3 (1855)
	1856   => '1303023',            # Mariage Kernével 3 E 109/22/4 (1856)
	1857   => '1303024',            # Mariage Kernével 3 E 109/22/5 (1857)
	1858   => '1303025',            # Mariage Kernével 3 E 109/22/6 (1858)
	1859   => '1303026',            # Mariage Kernével 3 E 109/22/7 (1859)
	1860   => '1303027',            # Mariage Kernével 3 E 109/22/8 (1860)
	1861   => '1303028',            # Mariage Kernével 3 E 109/22/9 (1861)
	1862   => '1303029',            # Mariage Kernével 3 E 109/22/10 (1862)
    },

    '3E109_0023' => {			# Mariage Kernével 3 E 109 23   1863-1869
	1863   => '1303031',            # Mariage Kernével 3 E 109/23/1 (1863)
	1864   => '1303032',            # Mariage Kernével 3 E 109/23/2 (1864)
	1865   => '1303033',            # Mariage Kernével 3 E 109/23/3 (1865)
	1866   => '1303034',            # Mariage Kernével 3 E 109/23/4 (1866)
	1867   => '1303035',            # Mariage Kernével 3 E 109/23/5 (1867)
	1868   => '1303036',            # Mariage Kernével 3 E 109/23/6 (1868)
	1869   => '1303037',            # Mariage Kernével 3 E 109/23/7 (1869)
    },

    '3E109_0024' => {			# Mariage Kernével 3 E 109 24   1870-1884
	1870   => '1303039',            # Mariage Kernével 3 E 109/24/1 (1870)
	1871   => '1303040',            # Mariage Kernével 3 E 109/24/2 (1871)
	1872   => '1303041',            # Mariage Kernével 3 E 109/24/3 (1872)
	1873   => '1303042',            # Mariage Kernével 3 E 109/24/4 (1873)
	1874   => '1303043',            # Mariage Kernével 3 E 109/24/5 (1874)
	1875   => '1303044',            # Mariage Kernével 3 E 109/24/6 (1875)
	1876   => '1303045',            # Mariage Kernével 3 E 109/24/7 (1876)
	1877   => '1303046',            # Mariage Kernével 3 E 109/24/8 (1877)
	1878   => '1303047',            # Mariage Kernével 3 E 109/24/9 (1878)
	1879   => '1303048',            # Mariage Kernével 3 E 109/24/10 (1879)
	1880   => '1303049',            # Mariage Kernével 3 E 109/24/11 (1880)
	1881   => '1303050',            # Mariage Kernével 3 E 109/24/12 (1881)
	1882   => '1303051',            # Mariage Kernével 3 E 109/24/13 (1882)
	1883   => '1303052',            # Mariage Kernével 3 E 109/24/14 (1883)
	1884   => '1303053',            # Mariage Kernével 3 E 109/24/15 (1884)
    },

    '3E109_0025' => {			# Décès Kernével 3 E 109 25   AN02-AN10
	'AN02' => '1303123',            # Décès Kernével 3 E 109/25/1 (1793 - an II)
	'AN03' => '1303124',            # Décès Kernével 3 E 109/25/2 (an III)
	'AN04' => '1303125',            # Décès Kernével 3 E 109/25/3 (an IV)
	'AN05' => '1303126',            # Décès Kernével 3 E 109/25/4 (an V)
	'AN06' => '1303127',            # Décès Kernével 3 E 109/25/5 (an VI)
	'AN07' => '1303128',            # Décès Kernével 3 E 109/25/6 (an VII)
	'AN08' => '1303129',            # Décès Kernével 3 E 109/25/7 (an VIII)
	'AN09' => '1303130',            # Décès Kernével 3 E 109/25/8 (an IX)
	'AN10' => '1303131',            # Décès Kernével 3 E 109/25/9 (an X)
    },

    '3E109_0026' => {			# Décès Kernével 3 E 109 26   AN11-1812
	'AN11' => '1303133',            # Décès Kernével 3 E 109/26/1 (an XI)
	'AN12' => '1303134',            # Décès Kernével 3 E 109/26/2 (an XII)
	'AN13' => '1303135',            # Décès Kernével 3 E 109/26/3 (an XIII)
	'AN14' => '1303136',            # Décès Kernével 3 E 109/26/4 (an XIV - 1806)
	1807   => '1303137',            # Décès Kernével 3 E 109/26/5 (1807)
	1808   => '1303138',            # Décès Kernével 3 E 109/26/6 (1808)
	1809   => '1303139',            # Décès Kernével 3 E 109/26/7 (1809)
	1810   => '1303140',            # Décès Kernével 3 E 109/26/8 (1810)
	1811   => '1303141',            # Décès Kernével 3 E 109/26/9 (1811)
	1812   => '1303142',            # Décès Kernével 3 E 109/26/10 (1812)
    },

    '3E109_0027' => {			# Décès Kernével 3 E 109 27   1813-1822
	1813   => '1303144',            # Décès Kernével 3 E 109/27/1 (1813)
	1814   => '1303145',            # Décès Kernével 3 E 109/27/2 (1814)
	1815   => '1303146',            # Décès Kernével 3 E 109/27/3 (1815)
	1816   => '1303147',            # Décès Kernével 3 E 109/27/4 (1816)
	1817   => '1303148',            # Décès Kernével 3 E 109/27/5 (1817)
	1818   => '1303149',            # Décès Kernével 3 E 109/27/6 (1818)
	1819   => '1303150',            # Décès Kernével 3 E 109/27/7 (1819)
	1820   => '1303151',            # Décès Kernével 3 E 109/27/8 (1820)
	1821   => '1303152',            # Décès Kernével 3 E 109/27/9 (1821)
	1822   => '1303153',            # Décès Kernével 3 E 109/27/10 (1822)
    },

    '3E109_0028' => {			# Décès Kernével 3 E 109 28   1823-1832
	1823   => '1303155',            # Décès Kernével 3 E 109/28/1 (1823)
	1824   => '1303156',            # Décès Kernével 3 E 109/28/2 (1824)
	1825   => '1303157',            # Décès Kernével 3 E 109/28/3 (1825)
	1826   => '1303158',            # Décès Kernével 3 E 109/28/4 (1826)
	1827   => '1303159',            # Décès Kernével 3 E 109/28/5 (1827)
	1828   => '1303160',            # Décès Kernével 3 E 109/28/6 (1828)
	1829   => '1303161',            # Décès Kernével 3 E 109/28/7 (1829)
	1830   => '1303162',            # Décès Kernével 3 E 109/28/8 (1830)
	1831   => '1303163',            # Décès Kernével 3 E 109/28/9 (1831)
	1832   => '1303164',            # Décès Kernével 3 E 109/28/10 (1832)
    },

    '3E109_0029' => {			# Décès Kernével 3 E 109 29   1833-1842
	1833   => '1303166',            # Décès Kernével 3 E 109/29/1 (1833)
	1834   => '1303167',            # Décès Kernével 3 E 109/29/2 (1834)
	1835   => '1303168',            # Décès Kernével 3 E 109/29/3 (1835)
	1836   => '1303169',            # Décès Kernével 3 E 109/29/4 (1836)
	1837   => '1303170',            # Décès Kernével 3 E 109/29/5 (1837)
	1838   => '1303171',            # Décès Kernével 3 E 109/29/6 (1838)
	1839   => '1303172',            # Décès Kernével 3 E 109/29/7 (1839)
	1840   => '1303173',            # Décès Kernével 3 E 109/29/8 (1840)
	1841   => '1303174',            # Décès Kernével 3 E 109/29/9 (1841)
	1842   => '1303175',            # Décès Kernével 3 E 109/29/10 (1842)
    },

    '3E109_0030' => {			# Décès Kernével 3 E 109 30   1843-1852
	1843   => '1303177',            # Décès Kernével 3 E 109/30/1 (1843)
	1844   => '1303178',            # Décès Kernével 3 E 109/30/2 (1844)
	1845   => '1303179',            # Décès Kernével 3 E 109/30/3 (1845)
	1846   => '1303180',            # Décès Kernével 3 E 109/30/4 (1846)
	1847   => '1303181',            # Décès Kernével 3 E 109/30/5 (1847)
	1848   => '1303182',            # Décès Kernével 3 E 109/30/6 (1848)
	1849   => '1303183',            # Décès Kernével 3 E 109/30/7 (1849)
	1850   => '1303184',            # Décès Kernével 3 E 109/30/8 (1850)
	1851   => '1303185',            # Décès Kernével 3 E 109/30/9 (1851)
	1852   => '1303186',            # Décès Kernével 3 E 109/30/10 (1852)
    },

    '3E109_0031' => {			# Décès Kernével 3 E 109 31   1853-1862
	1853   => '1303188',            # Décès Kernével 3 E 109/31/1 (1853)
	1854   => '1303189',            # Décès Kernével 3 E 109/31/2 (1854)
	1855   => '1303190',            # Décès Kernével 3 E 109/31/3 (1855)
	1856   => '1303191',            # Décès Kernével 3 E 109/31/4 (1856)
	1857   => '1303192',            # Décès Kernével 3 E 109/31/5 (1857)
	1858   => '1303193',            # Décès Kernével 3 E 109/31/6 (1858)
	1859   => '1303194',            # Décès Kernével 3 E 109/31/7 (1859)
	1860   => '1303195',            # Décès Kernével 3 E 109/31/8 (1860)
	1861   => '1303196',            # Décès Kernével 3 E 109/31/9 (1861)
	1862   => '1303197',            # Décès Kernével 3 E 109/31/10 (1862)
    },

    '3E109_0032' => {			# Décès Kernével 3 E 109 32   1863-1869
	1863   => '1303199',            # Décès Kernével 3 E 109/32/1 (1863)
	1864   => '1303200',            # Décès Kernével 3 E 109/32/2 (1864)
	1865   => '1303201',            # Décès Kernével 3 E 109/32/3 (1865)
	1866   => '1303202',            # Décès Kernével 3 E 109/32/4 (1866)
	1867   => '1303203',            # Décès Kernével 3 E 109/32/5 (1867)
	1868   => '1303204',            # Décès Kernével 3 E 109/32/6 (1868)
	1869   => '1303205',            # Décès Kernével 3 E 109/32/7 (1869)
    },

    '3E109_0033' => {			# Décès Kernével 3 E 109 33   1870-1880
	1870   => '1303207',            # Décès Kernével 3 E 109/33/1 (1870)
	1871   => '1303208',            # Décès Kernével 3 E 109/33/2 (1871)
	1872   => '1303209',            # Décès Kernével 3 E 109/33/3 (1872)
	1873   => '1303210',            # Décès Kernével 3 E 109/33/4 (1873)
	1874   => '1303211',            # Décès Kernével 3 E 109/33/5 (1874)
	1875   => '1303212',            # Décès Kernével 3 E 109/33/6 (1875)
	1876   => '1303213',            # Décès Kernével 3 E 109/33/7 (1876)
	1877   => '1303214',            # Décès Kernével 3 E 109/33/8 (1877)
	1878   => '1303215',            # Décès Kernével 3 E 109/33/9 (1878)
	1879   => '1303216',            # Décès Kernével 3 E 109/33/10 (1879)
	1880   => '1303217',            # Décès Kernével 3 E 109/33/11 (1880)
    },

    '3E109_0034' => {			# Décès Kernével 3 E 109 34   1881-1893
	1881   => '1303219',            # Décès Kernével 3 E 109/34/1 (1881)
	1882   => '1303220',            # Décès Kernével 3 E 109/34/2 (1882)
	1883   => '1303221',            # Décès Kernével 3 E 109/34/3 (1883)
	1884   => '1303222',            # Décès Kernével 3 E 109/34/4 (1884)
	1885   => '1303223',            # Décès Kernével 3 E 109/34/5 (1885)
	1886   => '1303224',            # Décès Kernével 3 E 109/34/6 (1886)
	1887   => '1303225',            # Décès Kernével 3 E 109/34/7 (1887)
	1888   => '1303226',            # Décès Kernével 3 E 109/34/8 (1888)
	1889   => '1303227',            # Décès Kernével 3 E 109/34/9 (1889)
	1890   => '1303228',            # Décès Kernével 3 E 109/34/10 (1890)
	1891   => '1303229',            # Décès Kernével 3 E 109/34/11 (1891)
	1892   => '1303230',            # Décès Kernével 3 E 109/34/12 (1892)
	1893   => '1303231',            # Décès Kernével 3 E 109/34/13 (1893)
    },

    '3E109_0035' => {			# Naissance Kernével 3 E 109 35   1891-1900
	1891   => '1302903',            # Naissance Kernével 3 E 109/35/1 (1891)
	1892   => '1302904',            # Naissance Kernével 3 E 109/35/2 (1892)
	1893   => '1302905',            # Naissance Kernével 3 E 109/35/3 (1893)
	1894   => '1302906',            # Naissance Kernével 3 E 109/35/4 (1894)
	1895   => '1302907',            # Naissance Kernével 3 E 109/35/5 (1895)
	1896   => '1302908',            # Naissance Kernével 3 E 109/35/6 (1896)
	1897   => '1302909',            # Naissance Kernével 3 E 109/35/7 (1897)
	1898   => '1302910',            # Naissance Kernével 3 E 109/35/8 (1898)
	1899   => '1302911',            # Naissance Kernével 3 E 109/35/9 (1899)
	1900   => '1302912',            # Naissance Kernével 3 E 109/35/10 (1900)
    },

    '3E109_0036' => {			# Mariage Kernével 3 E 109 36   1885-1897
	1885   => '1303055',            # Mariage Kernével 3 E 109/36/1 (1885)
	1886   => '1303056',            # Mariage Kernével 3 E 109/36/2 (1886)
	1887   => '1303057',            # Mariage Kernével 3 E 109/36/3 (1887)
	1888   => '1303058',            # Mariage Kernével 3 E 109/36/4 (1888)
	1889   => '1303059',            # Mariage Kernével 3 E 109/36/5 (1889)
	1890   => '1303060',            # Mariage Kernével 3 E 109/36/6 (1890)
	1891   => '1303061',            # Mariage Kernével 3 E 109/36/7 (1891)
	1892   => '1303062',            # Mariage Kernével 3 E 109/36/8 (1892)
	1893   => '1303063',            # Mariage Kernével 3 E 109/36/9 (1893)
	1894   => '1303064',            # Mariage Kernével 3 E 109/36/10 (1894)
	1895   => '1303065',            # Mariage Kernével 3 E 109/36/11 (1895)
	1896   => '1303066',            # Mariage Kernével 3 E 109/36/12 (1896)
	1897   => '1303067',            # Mariage Kernével 3 E 109/36/13 (1897)
    },

    '3E109_0037' => {			# Décès Kernével 3 E 109 37   1894-1907
	1894   => '1303233',            # Décès Kernével 3 E 109/37/1 (1894)
	1895   => '1303234',            # Décès Kernével 3 E 109/37/2 (1895)
	1896   => '1303235',            # Décès Kernével 3 E 109/37/3 (1896)
	1897   => '1303236',            # Décès Kernével 3 E 109/37/4 (1897)
	1898   => '1303237',            # Décès Kernével 3 E 109/37/5 (1898)
	1899   => '1303238',            # Décès Kernével 3 E 109/37/6 (1899)
	1900   => '1303239',            # Décès Kernével 3 E 109/37/7 (1900)
	1901   => '1303240',            # Décès Kernével 3 E 109/37/8 (1901)
	1902   => '1303241',            # Décès Kernével 3 E 109/37/9 (1902)
	1903   => '1303242',            # Décès Kernével 3 E 109/37/10 (1903)
	1904   => '1303243',            # Décès Kernével 3 E 109/37/11 (1904)
	1905   => '1303244',            # Décès Kernével 3 E 109/37/12 (1905)
	1906   => '1303245',            # Décès Kernével 3 E 109/37/13 (1906)
	1907   => '1303246',            # Décès Kernével 3 E 109/37/14 (1907)
    },

    '3E109_0038' => {			# Mariage Kernével 3 E 109 38   1898-1908
	1898   => '1303069',            # Mariage Kernével 3 E 109/38/1 (1898)
	1899   => '1303070',            # Mariage Kernével 3 E 109/38/2 (1899)
	1900   => '1303071',            # Mariage Kernével 3 E 109/38/3 (1900)
	1901   => '1303072',            # Mariage Kernével 3 E 109/38/4 (1901)
	1902   => '1303073',            # Mariage Kernével 3 E 109/38/5 (1902)
	1903   => '1303074',            # Mariage Kernével 3 E 109/38/6 (1903)
	1904   => '1303075',            # Mariage Kernével 3 E 109/38/7 (1904)
	1905   => '1303076',            # Mariage Kernével 3 E 109/38/8 (1905)
	1906   => '1303077',            # Mariage Kernével 3 E 109/38/9 (1906)
	1907   => '1303078',            # Mariage Kernével 3 E 109/38/10 (1907)
	1908   => '1303079',            # Mariage Kernével 3 E 109/38/11 (1908)
    },

    '3E109_0039' => {			# Naissance Kernével 3 E 109 39   1901-1910
	1901   => '1302914',            # Naissance Kernével 3 E 109/39/1 (1901)
	1902   => '1302915',            # Naissance Kernével 3 E 109/39/2 (1902)
	1903   => '1302916',            # Naissance Kernével 3 E 109/39/3 (1903)
	1904   => '1302917',            # Naissance Kernével 3 E 109/39/4 (1904)
	1905   => '1302918',            # Naissance Kernével 3 E 109/39/5 (1905)
	1906   => '1302919',            # Naissance Kernével 3 E 109/39/6 (1906)
	1907   => '1302920',            # Naissance Kernével 3 E 109/39/7 (1907)
	1908   => '1302921',            # Naissance Kernével 3 E 109/39/8 (1908)
	1909   => '1302922',            # Naissance Kernével 3 E 109/39/9 (1909)
	1910   => '1302923',            # Naissance Kernével 3 E 109/39/10 (1910)
    },

    '3E109_0040' => {			# Naissance Kernével 3 E 109 40   1911-1920
	1911   => '1302925',            # Naissance Kernével 3 E 109/40/1 (1911)
	1912   => '1302926',            # Naissance Kernével 3 E 109/40/2 (1912)
	1913   => '1302927',            # Naissance Kernével 3 E 109/40/3 (1913)
	1914   => '1302928',            # Naissance Kernével 3 E 109/40/4 (1914)
	1915   => '1302929',            # Naissance Kernével 3 E 109/40/5 (1915)
	1916   => '1302930',            # Naissance Kernével 3 E 109/40/6 (1916)
	1917   => '1302931',            # Naissance Kernével 3 E 109/40/7 (1917)
	1918   => '1302932',            # Naissance Kernével 3 E 109/40/8 (1918)
	1919   => '1302933',            # Naissance Kernével 3 E 109/40/9 (1919)
	1920   => '1302934',            # Naissance Kernével 3 E 109/40/10 (1920)
    },

    '3E109_0041' => {			# Naissance Kernével 3 E 109 41   1921-1925
	1921   => '1302936',            # Naissance Kernével 3 E 109/41/1 (1921)
	1922   => '1302937',            # Naissance Kernével 3 E 109/41/2 (1922)
	1923   => '1302938',            # Naissance Kernével 3 E 109/41/3 (1923)
	1924   => '1302939',            # Naissance Kernével 3 E 109/41/4 (1924)
	1925   => '1302940',            # Naissance Kernével 3 E 109/41/5 (1925)
    },

    '3E109_0043' => {			# Mariage Kernével 3 E 109 43   1909-1920
	1909   => '1303081',            # Mariage Kernével 3 E 109/43/1 (1909)
	1910   => '1303082',            # Mariage Kernével 3 E 109/43/2 (1910)
	1911   => '1303083',            # Mariage Kernével 3 E 109/43/3 (1911)
	1912   => '1303084',            # Mariage Kernével 3 E 109/43/4 (1912)
	1913   => '1303085',            # Mariage Kernével 3 E 109/43/5 (1913)
	1914   => '1303086',            # Mariage Kernével 3 E 109/43/6 (1914)
	1915   => '1303087',            # Mariage Kernével 3 E 109/43/7 (1915)
	1916   => '1303088',            # Mariage Kernével 3 E 109/43/8 (1916)
	1917   => '1303089',            # Mariage Kernével 3 E 109/43/9 (1917)
	1918   => '1303090',            # Mariage Kernével 3 E 109/43/10 (1918)
	1919   => '1303091',            # Mariage Kernével 3 E 109/43/11 (1919)
	1920   => '1303092',            # Mariage Kernével 3 E 109/43/12 (1920)
    },

    '3E109_0044' => {			# Mariage Kernével 3 E 109 44   1921-1928
	1921   => '1303094',            # Mariage Kernével 3 E 109/44/1 (1921)
	1922   => '1303095',            # Mariage Kernével 3 E 109/44/2 (1922)
	1923   => '1303096',            # Mariage Kernével 3 E 109/44/3 (1923)
	1924   => '1303097',            # Mariage Kernével 3 E 109/44/4 (1924)
	1925   => '1303098',            # Mariage Kernével 3 E 109/44/5 (1925)
	1926   => '1303099',            # Mariage Kernével 3 E 109/44/6 (1926)
	1927   => '1303100',            # Mariage Kernével 3 E 109/44/7 (1927)
	1928   => '1303101',            # Mariage Kernével 3 E 109/44/8 (1928)
    },

    '3E109_0045' => {			# Mariage Kernével 3 E 109 45   1929-1936
	1929   => '1303103',            # Mariage Kernével 3 E 109/45/1 (1929)
	1930   => '1303104',            # Mariage Kernével 3 E 109/45/2 (1930)
	1931   => '1303105',            # Mariage Kernével 3 E 109/45/3 (1931)
	1932   => '1303106',            # Mariage Kernével 3 E 109/45/4 (1932)
	1933   => '1303107',            # Mariage Kernével 3 E 109/45/5 (1933)
	1934   => '1303108',            # Mariage Kernével 3 E 109/45/6 (1934)
	1935   => '1303109',            # Mariage Kernével 3 E 109/45/7 (1935)
	1936   => '1303110',            # Mariage Kernével 3 E 109/45/8 (1936)
    },

    '3E109_0046' => {			# Décès Kernével 3 E 109 46   1908-1920
	1908   => '1303248',            # Décès Kernével 3 E 109/46/1 (1908)
	1909   => '1303249',            # Décès Kernével 3 E 109/46/2 (1909)
	1910   => '1303250',            # Décès Kernével 3 E 109/46/3 (1910)
	1911   => '1303251',            # Décès Kernével 3 E 109/46/4 (1911)
	1912   => '1303252',            # Décès Kernével 3 E 109/46/5 (1912)
	1913   => '1303253',            # Décès Kernével 3 E 109/46/6 (1913)
	1914   => '1303254',            # Décès Kernével 3 E 109/46/7 (1914)
	1915   => '1303255',            # Décès Kernével 3 E 109/46/8 (1915)
	1916   => '1303256',            # Décès Kernével 3 E 109/46/9 (1916)
	1917   => '1303257',            # Décès Kernével 3 E 109/46/10 (1917)
	1918   => '1303258',            # Décès Kernével 3 E 109/46/11 (1918)
	1919   => '1303259',            # Décès Kernével 3 E 109/46/12 (1919)
	1920   => '1303260',            # Décès Kernével 3 E 109/46/13 (1920)
    },

    '3E109_0047' => {			# Décès Kernével 3 E 109 47   1921-1936
	1921   => '1303262',            # Décès Kernével 3 E 109/47/1 (1921)
	1922   => '1303263',            # Décès Kernével 3 E 109/47/2 (1922)
	1923   => '1303264',            # Décès Kernével 3 E 109/47/3 (1923)
	1924   => '1303265',            # Décès Kernével 3 E 109/47/4 (1924)
	1925   => '1303266',            # Décès Kernével 3 E 109/47/5 (1925)
	1926   => '1303267',            # Décès Kernével 3 E 109/47/6 (1926)
	1927   => '1303268',            # Décès Kernével 3 E 109/47/7 (1927)
	1928   => '1303269',            # Décès Kernével 3 E 109/47/8 (1928)
	1929   => '1303270',            # Décès Kernével 3 E 109/47/9 (1929)
	1930   => '1303271',            # Décès Kernével 3 E 109/47/10 (1930)
	1931   => '1303272',            # Décès Kernével 3 E 109/47/11 (1931)
	1932   => '1303273',            # Décès Kernével 3 E 109/47/12 (1932)
	1933   => '1303274',            # Décès Kernével 3 E 109/47/13 (1933)
	1934   => '1303275',            # Décès Kernével 3 E 109/47/14 (1934)
	1935   => '1303276',            # Décès Kernével 3 E 109/47/15 (1935)
	1936   => '1303277',            # Décès Kernével 3 E 109/47/16 (1936)
    },

    # NMD Landeleau
    '3E122_0006' => {			# Naissance Landeleau 3 E 122 6   AN02-1813
	'AN02' => '1307141',            # Naissance Landeleau 3 E 122/6/1 (1793-1er thermidor an II)
	# An 3-5 to be doble checked:
	'AN03' => '1307142',            # Naissance Landeleau 3 E 122/6/2 (19 frimaire-25 fructidor an III)
	'AN04' => '1307143',            # Naissance Landeleau 3 E 122/6/3 (an IV-12 messidor an V)
	'AN05' => '1307144',            # Naissance Landeleau 3 E 122/6/4 (18 messidor-3 thermidor an V)
	'AN06' => '1307145',            # Naissance Landeleau 3 E 122/6/5 (an VI)
	'AN07' => '1307146',            # Naissance Landeleau 3 E 122/6/6 (an VII)
	'AN08' => '1307147',            # Naissance Landeleau 3 E 122/6/7 (an VIII)
	'AN09' => '1307148',            # Naissance Landeleau 3 E 122/6/8 (an IX)
	'AN10' => '1307149',            # Naissance Landeleau 3 E 122/6/9 (an X)
	'AN11' => '1307150',            # Naissance Landeleau 3 E 122/6/10 (an XI)
	'AN12' => '1307151',            # Naissance Landeleau 3 E 122/6/11 (an XII)
	'AN13' => '1307152',            # Naissance Landeleau 3 E 122/6/12 (an XIII)
	'AN14' => '1307153',            # Naissance Landeleau 3 E 122/6/13 (an XIV - 1806)
	1807   => '1307154',            # Naissance Landeleau 3 E 122/6/14 (1807)
	1808   => '1307155',            # Naissance Landeleau 3 E 122/6/15 (1808)
	1809   => '1307156',            # Naissance Landeleau 3 E 122/6/16 (1809)
	1810   => '1307157',            # Naissance Landeleau 3 E 122/6/17 (1810)
	1811   => '1307158',            # Naissance Landeleau 3 E 122/6/18 (1811)
	1812   => '1307159',            # Naissance Landeleau 3 E 122/6/19 (1812)
	1813   => '1307160',            # Naissance Landeleau 3 E 122/6/20 (1813)
    },

    '3E122_0007' => {			# Naissance Landeleau 3 E 122 7   1814-1832
	1814   => '1307162',            # Naissance Landeleau 3 E 122/7/1 (1814)
	1815   => '1307163',            # Naissance Landeleau 3 E 122/7/2 (1815)
	1816   => '1307164',            # Naissance Landeleau 3 E 122/7/3 (1816)
	1817   => '1307165',            # Naissance Landeleau 3 E 122/7/4 (1817)
	1818   => '1307166',            # Naissance Landeleau 3 E 122/7/5 (1818)
	1819   => '1307167',            # Naissance Landeleau 3 E 122/7/6 (1819)
	1820   => '1307168',            # Naissance Landeleau 3 E 122/7/7 (1820)
	1821   => '1307169',            # Naissance Landeleau 3 E 122/7/8 (1821)
	1822   => '1307170',            # Naissance Landeleau 3 E 122/7/9 (1822)
	1823   => '1307171',            # Naissance Landeleau 3 E 122/7/10 (1823)
	1824   => '1307172',            # Naissance Landeleau 3 E 122/7/11 (1824)
	1825   => '1307173',            # Naissance Landeleau 3 E 122/7/12 (1825)
	1826   => '1307174',            # Naissance Landeleau 3 E 122/7/13 (1826)
	1827   => '1307175',            # Naissance Landeleau 3 E 122/7/14 (1827)
	1828   => '1307176',            # Naissance Landeleau 3 E 122/7/15 (1828)
	1829   => '1307177',            # Naissance Landeleau 3 E 122/7/16 (1829)
	1830   => '1307178',            # Naissance Landeleau 3 E 122/7/17 (1830)
	1831   => '1307179',            # Naissance Landeleau 3 E 122/7/18 (1831)
	1832   => '1307180',            # Naissance Landeleau 3 E 122/7/19 (1832)
    },

    '3E122_0008' => {			# Naissance Landeleau 3 E 122 8   1833-1842
	1833   => '1307182',            # Naissance Landeleau 3 E 122/8/1 (1833)
	1834   => '1307183',            # Naissance Landeleau 3 E 122/8/2 (1834)
	1835   => '1307184',            # Naissance Landeleau 3 E 122/8/3 (1835)
	1836   => '1307185',            # Naissance Landeleau 3 E 122/8/4 (1836)
	1837   => '1307186',            # Naissance Landeleau 3 E 122/8/5 (1837)
	1838   => '1307187',            # Naissance Landeleau 3 E 122/8/6 (1838)
	1839   => '1307188',            # Naissance Landeleau 3 E 122/8/7 (1839)
	1840   => '1307189',            # Naissance Landeleau 3 E 122/8/8 (1840)
	1841   => '1307190',            # Naissance Landeleau 3 E 122/8/9 (1841)
	1842   => '1307191',            # Naissance Landeleau 3 E 122/8/10 (1842)
    },

    '3E122_0009' => {			# Naissance Landeleau 3 E 122 9   1843-1852
	1843   => '1307193',            # Naissance Landeleau 3 E 122/9/1 (1843)
	1844   => '1307194',            # Naissance Landeleau 3 E 122/9/2 (1844)
	1845   => '1307195',            # Naissance Landeleau 3 E 122/9/3 (1845)
	1846   => '1307196',            # Naissance Landeleau 3 E 122/9/4 (1846)
	1847   => '1307197',            # Naissance Landeleau 3 E 122/9/5 (1847)
	1848   => '1307198',            # Naissance Landeleau 3 E 122/9/6 (1848)
	1849   => '1307199',            # Naissance Landeleau 3 E 122/9/7 (1849)
	1850   => '1307200',            # Naissance Landeleau 3 E 122/9/8 (1850)
	1851   => '1307201',            # Naissance Landeleau 3 E 122/9/9 (1851)
	1852   => '1307202',            # Naissance Landeleau 3 E 122/9/10 (1852)
    },

    '3E122_0010' => {			# Naissance Landeleau 3 E 122 10   1853-1862
	1853   => '1307204',            # Naissance Landeleau 3 E 122/10/1 (1853)
	1854   => '1307205',            # Naissance Landeleau 3 E 122/10/2 (1854)
	1855   => '1307206',            # Naissance Landeleau 3 E 122/10/3 (1855)
	1856   => '1307207',            # Naissance Landeleau 3 E 122/10/4 (1856)
	1857   => '1307208',            # Naissance Landeleau 3 E 122/10/5 (1857)
	1858   => '1307209',            # Naissance Landeleau 3 E 122/10/6 (1858)
	1859   => '1307210',            # Naissance Landeleau 3 E 122/10/7 (1859)
	1860   => '1307211',            # Naissance Landeleau 3 E 122/10/8 (1860)
	1861   => '1307212',            # Naissance Landeleau 3 E 122/10/9 (1861)
	1862   => '1307213',            # Naissance Landeleau 3 E 122/10/10 (1862)
    },

    '3E122_0011' => {			# Naissance Landeleau 3 E 122 11   1863-1869
	1863   => '1307215',            # Naissance Landeleau 3 E 122/11/1 (1863)
	1864   => '1307216',            # Naissance Landeleau 3 E 122/11/2 (1864)
	1865   => '1307217',            # Naissance Landeleau 3 E 122/11/3 (1865)
	1866   => '1307218',            # Naissance Landeleau 3 E 122/11/4 (1866)
	1867   => '1307219',            # Naissance Landeleau 3 E 122/11/5 (1867)
	1868   => '1307220',            # Naissance Landeleau 3 E 122/11/6 (1868)
	1869   => '1307221',            # Naissance Landeleau 3 E 122/11/7 (1869)
    },

    '3E122_0012' => {			# Naissance Landeleau 3 E 122 12   1870-1883
	1870   => '1307223',            # Naissance Landeleau 3 E 122/12/1 (1870)
	1871   => '1307224',            # Naissance Landeleau 3 E 122/12/2 (1871)
	1872   => '1307225',            # Naissance Landeleau 3 E 122/12/3 (1872)
	1873   => '1307226',            # Naissance Landeleau 3 E 122/12/4 (1873)
	1874   => '1307227',            # Naissance Landeleau 3 E 122/12/5 (1874)
	1875   => '1307228',            # Naissance Landeleau 3 E 122/12/6 (1875)
	1876   => '1307229',            # Naissance Landeleau 3 E 122/12/7 (1876)
	1877   => '1307230',            # Naissance Landeleau 3 E 122/12/8 (1877)
	1878   => '1307231',            # Naissance Landeleau 3 E 122/12/9 (1878)
	1879   => '1307232',            # Naissance Landeleau 3 E 122/12/10 (1879)
	1880   => '1307233',            # Naissance Landeleau 3 E 122/12/11 (1880)
	1881   => '1307234',            # Naissance Landeleau 3 E 122/12/12 (1881)
	1882   => '1307235',            # Naissance Landeleau 3 E 122/12/13 (1882)
	1883   => '1307236',            # Naissance Landeleau 3 E 122/12/14 (1883)
    },

    '3E122_0013' => {			# Naissance Landeleau 3 E 122 13   1884-1894
	1884   => '1307238',            # Naissance Landeleau 3 E 122/13/1 (1884)
	1885   => '1307239',            # Naissance Landeleau 3 E 122/13/2 (1885)
	1886   => '1307240',            # Naissance Landeleau 3 E 122/13/3 (1886)
	1887   => '1307241',            # Naissance Landeleau 3 E 122/13/4 (1887)
	1888   => '1307242',            # Naissance Landeleau 3 E 122/13/5 (1888)
	1889   => '1307243',            # Naissance Landeleau 3 E 122/13/6 (1889)
	1890   => '1307244',            # Naissance Landeleau 3 E 122/13/7 (1890)
	1891   => '1307245',            # Naissance Landeleau 3 E 122/13/8 (1891)
	1892   => '1307246',            # Naissance Landeleau 3 E 122/13/9 (1892)
	1893   => '1307247',            # Naissance Landeleau 3 E 122/13/10 (1893)
	1894   => '1307248',            # Naissance Landeleau 3 E 122/13/11 (1894)
    },

    '3E122_0014' => {			# Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122 14   AN06-1812
	'17 nivôse an III-25 vendémiaire an IV' => '1307297',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/2 (17 nivôse an III-25 vendémiaire an IV)
	1807   => '1307307',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/12 (1807)
	1808   => '1307308',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/13 (1808)
	1809   => '1307309',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/14 (1809)
	1810   => '1307310',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/15 (1810)
	1811   => '1307311',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/16 (1811)
	1812   => '1307312',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/17 (1812)
	'29 thermidor an V' => '1307299',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/4 (29 thermidor an V)
	'8 brumaire an IV-12 messidor an V (contient des publications de mariages)' => '1307298',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/3 (8 brumaire an IV-12 messidor an V (contient des publications de mariages))
	'AN06' => '1307300',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/5 (an VI)
	'AN09' => '1307301',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/6 (an IX (contient des promesses de mariages))
	'AN10' => '1307302',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/7 (an X)
	'AN11' => '1307303',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/8 (an XI)
	'AN12' => '1307304',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/9 (an XII)
	'AN13' => '1307305',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/10 (an XIII)
	'AN14' => '1307306',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/11 (an XIV - 1806)
	'Mariages : 1793-6 brumaire an III (contient des publications et promesses de mariages) ; naissances : 5 thermidor an II-5 frimaire an III' => '1307296',            # Mariage naissance publication de mariage promesse de mariage Landeleau 3 E 122/14/1 (Mariages : 1793-6 brumaire an III (contient des publications et promesses de mariages) ; naissances : 5 thermidor an II-5 frimaire an III)
    },

    '3E122_0015' => {			# Mariage Landeleau 3 E 122 15   1813-1827
	1813   => '1307314',            # Mariage Landeleau 3 E 122/15/1 (1813)
	1814   => '1307315',            # Mariage Landeleau 3 E 122/15/2 (1814)
	1815   => '1307316',            # Mariage Landeleau 3 E 122/15/3 (1815)
	1816   => '1307317',            # Mariage Landeleau 3 E 122/15/4 (1816)
	1817   => '1307318',            # Mariage Landeleau 3 E 122/15/5 (1817)
	1818   => '1307319',            # Mariage Landeleau 3 E 122/15/6 (1818)
	1819   => '1307320',            # Mariage Landeleau 3 E 122/15/7 (1819)
	1820   => '1307321',            # Mariage Landeleau 3 E 122/15/8 (1820)
	1821   => '1307322',            # Mariage Landeleau 3 E 122/15/9 (1821)
	1822   => '1307323',            # Mariage Landeleau 3 E 122/15/10 (1822)
	1823   => '1307324',            # Mariage Landeleau 3 E 122/15/11 (1823)
	1824   => '1307325',            # Mariage Landeleau 3 E 122/15/12 (1824)
	1825   => '1307326',            # Mariage Landeleau 3 E 122/15/13 (1825)
	1826   => '1307327',            # Mariage Landeleau 3 E 122/15/14 (1826)
	1827   => '1307328',            # Mariage Landeleau 3 E 122/15/15 (1827)
	1828   => '1307329',            # Mariage Landeleau 3 E 122/15/16 (1828)
	1829   => '1307330',            # Mariage Landeleau 3 E 122/15/17 (1829)
	1830   => '1307331',            # Mariage Landeleau 3 E 122/15/18 (1830)
	1831   => '1307332',            # Mariage Landeleau 3 E 122/15/19 (1831)
	1832   => '1307333',            # Mariage Landeleau 3 E 122/15/20 (1832)
    },

    '3E122_0016' => {			# Mariage Landeleau 3 E 122 16   1833-1842
	1833   => '1307335',            # Mariage Landeleau 3 E 122/16/1 (1833)
	1834   => '1307336',            # Mariage Landeleau 3 E 122/16/2 (1834)
	1835   => '1307337',            # Mariage Landeleau 3 E 122/16/3 (1835)
	1836   => '1307338',            # Mariage Landeleau 3 E 122/16/4 (1836)
	1837   => '1307339',            # Mariage Landeleau 3 E 122/16/5 (1837)
	1838   => '1307340',            # Mariage Landeleau 3 E 122/16/6 (1838)
	1839   => '1307341',            # Mariage Landeleau 3 E 122/16/7 (1839)
	1840   => '1307342',            # Mariage Landeleau 3 E 122/16/8 (1840)
	1841   => '1307343',            # Mariage Landeleau 3 E 122/16/9 (1841)
	1842   => '1307344',            # Mariage Landeleau 3 E 122/16/10 (1842)
    },

    '3E122_0017' => {			# Mariage Landeleau 3 E 122 17   1843-1852
	1843   => '1307346',            # Mariage Landeleau 3 E 122/17/1 (1843)
	1844   => '1307347',            # Mariage Landeleau 3 E 122/17/2 (1844)
	1845   => '1307348',            # Mariage Landeleau 3 E 122/17/3 (1845)
	1846   => '1307349',            # Mariage Landeleau 3 E 122/17/4 (1846)
	1847   => '1307350',            # Mariage Landeleau 3 E 122/17/5 (1847)
	1848   => '1307351',            # Mariage Landeleau 3 E 122/17/6 (1848)
	1849   => '1307352',            # Mariage Landeleau 3 E 122/17/7 (1849)
	1850   => '1307353',            # Mariage Landeleau 3 E 122/17/8 (1850)
	1851   => '1307354',            # Mariage Landeleau 3 E 122/17/9 (1851)
	1852   => '1307355',            # Mariage Landeleau 3 E 122/17/10 (1852)
    },

    '3E122_0018' => {			# Mariage Landeleau 3 E 122 18   1853-1862
	1853   => '1307357',            # Mariage Landeleau 3 E 122/18/1 (1853)
	1854   => '1307358',            # Mariage Landeleau 3 E 122/18/2 (1854)
	1855   => '1307359',            # Mariage Landeleau 3 E 122/18/3 (1855)
	1856   => '1307360',            # Mariage Landeleau 3 E 122/18/4 (1856)
	1857   => '1307361',            # Mariage Landeleau 3 E 122/18/5 (1857)
	1858   => '1307362',            # Mariage Landeleau 3 E 122/18/6 (1858)
	1859   => '1307363',            # Mariage Landeleau 3 E 122/18/7 (1859)
	1860   => '1307364',            # Mariage Landeleau 3 E 122/18/8 (1860)
	1861   => '1307365',            # Mariage Landeleau 3 E 122/18/9 (1861)
	1862   => '1307366',            # Mariage Landeleau 3 E 122/18/10 (1862)
    },

    '3E122_0019' => {			# Mariage Landeleau 3 E 122 19   1863-1869
	1863   => '1307368',            # Mariage Landeleau 3 E 122/19/1 (1863)
	1864   => '1307369',            # Mariage Landeleau 3 E 122/19/2 (1864)
	1865   => '1307370',            # Mariage Landeleau 3 E 122/19/3 (1865)
	1866   => '1307371',            # Mariage Landeleau 3 E 122/19/4 (1866)
	1867   => '1307372',            # Mariage Landeleau 3 E 122/19/5 (1867)
	1868   => '1307373',            # Mariage Landeleau 3 E 122/19/6 (1868)
	1869   => '1307374',            # Mariage Landeleau 3 E 122/19/7 (1869)
    },

    '3E122_0020' => {			# Mariage Landeleau 3 E 122 20   1870-1885
	1870   => '1307376',            # Mariage Landeleau 3 E 122/20/1 (1870)
	1871   => '1307377',            # Mariage Landeleau 3 E 122/20/2 (1871)
	1872   => '1307378',            # Mariage Landeleau 3 E 122/20/3 (1872)
	1873   => '1307379',            # Mariage Landeleau 3 E 122/20/4 (1873)
	1874   => '1307380',            # Mariage Landeleau 3 E 122/20/5 (1874)
	1875   => '1307381',            # Mariage Landeleau 3 E 122/20/6 (1875)
	1876   => '1307382',            # Mariage Landeleau 3 E 122/20/7 (1876)
	1877   => '1307383',            # Mariage Landeleau 3 E 122/20/8 (1877)
	1878   => '1307384',            # Mariage Landeleau 3 E 122/20/9 (1878)
	1879   => '1307385',            # Mariage Landeleau 3 E 122/20/10 (1879)
	1880   => '1307386',            # Mariage Landeleau 3 E 122/20/11 (1880)
	1881   => '1307387',            # Mariage Landeleau 3 E 122/20/12 (1881)
	1882   => '1307388',            # Mariage Landeleau 3 E 122/20/13 (1882)
	1883   => '1307389',            # Mariage Landeleau 3 E 122/20/14 (1883)
	1884   => '1307390',            # Mariage Landeleau 3 E 122/20/15 (1884)
	1885   => '1307391',            # Mariage Landeleau 3 E 122/20/16 (1885)
    },

    '3E122_0021' => {			# Décès Landeleau 3 E 122 21   AN06-1812
	'1793-21 frimaire an III' => '1307447',            # Décès Landeleau 3 E 122/21/1 (1793-21 frimaire an III)
	1807   => '1307460',            # Décès Landeleau 3 E 122/21/14 (1807)
	1808   => '1307461',            # Décès Landeleau 3 E 122/21/15 (1808)
	1809   => '1307462',            # Décès Landeleau 3 E 122/21/16 (1809)
	1810   => '1307463',            # Décès Landeleau 3 E 122/21/17 (1810)
	1811   => '1307464',            # Décès Landeleau 3 E 122/21/18 (1811)
	1812   => '1307465',            # Décès Landeleau 3 E 122/21/19 (1812)
	'AN06' => '1307451',            # Décès Landeleau 3 E 122/21/5 (an VI)
	'AN07' => '1307452',            # Décès Landeleau 3 E 122/21/6 (an VII)
	'AN08' => '1307453',            # Décès Landeleau 3 E 122/21/7 (an VIII)
	'AN09' => '1307454',            # Décès Landeleau 3 E 122/21/8 (an IX)
	'AN10' => '1307455',            # Décès Landeleau 3 E 122/21/9 (an X)
	'AN11' => '1307456',            # Décès Landeleau 3 E 122/21/10 (an XI)
	'AN12' => '1307457',            # Décès Landeleau 3 E 122/21/11 (an XII)
	'AN13' => '1307458',            # Décès Landeleau 3 E 122/21/12 (an XIII)
	'AN14' => '1307459',            # Décès Landeleau 3 E 122/21/13 (an XIV - 1806)
	'an IV-15 messidor an V' => '1307449',            # Décès Landeleau 3 E 122/21/3 (an IV-15 messidor an V)
    },

    '3E122_0022' => {			# Décès Landeleau 3 E 122 22   1813-1832
	1813   => '1307467',            # Décès Landeleau 3 E 122/22/1 (1813)
	1814   => '1307468',            # Décès Landeleau 3 E 122/22/2 (1814)
	1815   => '1307469',            # Décès Landeleau 3 E 122/22/3 (1815)
	1816   => '1307470',            # Décès Landeleau 3 E 122/22/4 (1816)
	1817   => '1307471',            # Décès Landeleau 3 E 122/22/5 (1817)
	1818   => '1307472',            # Décès Landeleau 3 E 122/22/6 (1818)
	1819   => '1307473',            # Décès Landeleau 3 E 122/22/7 (1819)
	1820   => '1307474',            # Décès Landeleau 3 E 122/22/8 (1820)
	1821   => '1307475',            # Décès Landeleau 3 E 122/22/9 (1821)
	1823   => '1307477',            # Décès Landeleau 3 E 122/22/11 (1823)
	1824   => '1307478',            # Décès Landeleau 3 E 122/22/12 (1824)
	1825   => '1307479',            # Décès Landeleau 3 E 122/22/13 (1825)
	1826   => '1307480',            # Décès Landeleau 3 E 122/22/14 (1826)
	1827   => '1307481',            # Décès Landeleau 3 E 122/22/15 (1827)
	1828   => '1307482',            # Décès Landeleau 3 E 122/22/16 (1828)
	1829   => '1307483',            # Décès Landeleau 3 E 122/22/17 (1829)
	1830   => '1307484',            # Décès Landeleau 3 E 122/22/18 (1830)
	1831   => '1307485',            # Décès Landeleau 3 E 122/22/19 (1831)
	1832   => '1307486',            # Décès Landeleau 3 E 122/22/20 (1832)
    },

    '3E122_0023' => {			# Décès Landeleau 3 E 122 23   1833-1842
	1833   => '1307488',            # Décès Landeleau 3 E 122/23/1 (1833)
	1834   => '1307489',            # Décès Landeleau 3 E 122/23/2 (1834)
	1835   => '1307490',            # Décès Landeleau 3 E 122/23/3 (1835)
	1836   => '1307491',            # Décès Landeleau 3 E 122/23/4 (1836)
	1837   => '1307492',            # Décès Landeleau 3 E 122/23/5 (1837)
	1838   => '1307493',            # Décès Landeleau 3 E 122/23/6 (1838)
	1839   => '1307494',            # Décès Landeleau 3 E 122/23/7 (1839)
	1840   => '1307495',            # Décès Landeleau 3 E 122/23/8 (1840)
	1841   => '1307496',            # Décès Landeleau 3 E 122/23/9 (1841)
	1842   => '1307497',            # Décès Landeleau 3 E 122/23/10 (1842)
    },

    '3E122_0024' => {			# Décès Landeleau 3 E 122 24   1843-1852
	1843   => '1307499',            # Décès Landeleau 3 E 122/24/1 (1843)
	1844   => '1307500',            # Décès Landeleau 3 E 122/24/2 (1844)
	1845   => '1307501',            # Décès Landeleau 3 E 122/24/3 (1845)
	1846   => '1307502',            # Décès Landeleau 3 E 122/24/4 (1846)
	1847   => '1307503',            # Décès Landeleau 3 E 122/24/5 (1847)
	1848   => '1307504',            # Décès Landeleau 3 E 122/24/6 (1848)
	1849   => '1307505',            # Décès Landeleau 3 E 122/24/7 (1849)
	1850   => '1307506',            # Décès Landeleau 3 E 122/24/8 (1850)
	1851   => '1307507',            # Décès Landeleau 3 E 122/24/9 (1851)
	1852   => '1307508',            # Décès Landeleau 3 E 122/24/10 (1852)
    },

    '3E122_0025' => {			# Décès Landeleau 3 E 122 25   1853-1862
	1853   => '1307510',            # Décès Landeleau 3 E 122/25/1 (1853)
	1854   => '1307511',            # Décès Landeleau 3 E 122/25/2 (1854)
	1855   => '1307512',            # Décès Landeleau 3 E 122/25/3 (1855)
	1856   => '1307513',            # Décès Landeleau 3 E 122/25/4 (1856)
	1857   => '1307514',            # Décès Landeleau 3 E 122/25/5 (1857)
	1858   => '1307515',            # Décès Landeleau 3 E 122/25/6 (1858)
	1859   => '1307516',            # Décès Landeleau 3 E 122/25/7 (1859)
	1860   => '1307517',            # Décès Landeleau 3 E 122/25/8 (1860)
	1861   => '1307518',            # Décès Landeleau 3 E 122/25/9 (1861)
	1862   => '1307519',            # Décès Landeleau 3 E 122/25/10 (1862)
    },

    '3E122_0026' => {			# Décès Landeleau 3 E 122 26   1863-1869
	1863   => '1307521',            # Décès Landeleau 3 E 122/26/1 (1863)
	1864   => '1307522',            # Décès Landeleau 3 E 122/26/2 (1864)
	1865   => '1307523',            # Décès Landeleau 3 E 122/26/3 (1865)
	1866   => '1307524',            # Décès Landeleau 3 E 122/26/4 (1866)
	1867   => '1307525',            # Décès Landeleau 3 E 122/26/5 (1867)
	1868   => '1307526',            # Décès Landeleau 3 E 122/26/6 (1868)
	1869   => '1307527',            # Décès Landeleau 3 E 122/26/7 (1869)
    },

    '3E122_0027' => {			# Décès Landeleau 3 E 122 27   1870-1886
	1870   => '1307529',            # Décès Landeleau 3 E 122/27/1 (1870)
	1871   => '1307530',            # Décès Landeleau 3 E 122/27/2 (1871)
	1872   => '1307531',            # Décès Landeleau 3 E 122/27/3 (1872)
	1873   => '1307532',            # Décès Landeleau 3 E 122/27/4 (1873)
	1874   => '1307533',            # Décès Landeleau 3 E 122/27/5 (1874)
	1875   => '1307534',            # Décès Landeleau 3 E 122/27/6 (1875)
	1876   => '1307535',            # Décès Landeleau 3 E 122/27/7 (1876)
	1877   => '1307536',            # Décès Landeleau 3 E 122/27/8 (1877)
	1878   => '1307537',            # Décès Landeleau 3 E 122/27/9 (1878)
	1879   => '1307538',            # Décès Landeleau 3 E 122/27/10 (1879)
	1880   => '1307539',            # Décès Landeleau 3 E 122/27/11 (1880)
	1881   => '1307540',            # Décès Landeleau 3 E 122/27/12 (1881)
	1882   => '1307541',            # Décès Landeleau 3 E 122/27/13 (1882)
	1883   => '1307542',            # Décès Landeleau 3 E 122/27/14 (1883)
	1884   => '1307543',            # Décès Landeleau 3 E 122/27/15 (1884)
	1885   => '1307544',            # Décès Landeleau 3 E 122/27/16 (1885)
	1886   => '1307545',            # Décès Landeleau 3 E 122/27/17 (1886)
    },

    '3E122_0028' => {			# Naissance Landeleau 3 E 122 28   1895-1906
	1895   => '1307250',            # Naissance Landeleau 3 E 122/28/1 (1895)
	1896   => '1307251',            # Naissance Landeleau 3 E 122/28/2 (1896)
	1897   => '1307252',            # Naissance Landeleau 3 E 122/28/3 (1897)
	1898   => '1307253',            # Naissance Landeleau 3 E 122/28/4 (1898)
	1899   => '1307254',            # Naissance Landeleau 3 E 122/28/5 (1899)
	1900   => '1307255',            # Naissance Landeleau 3 E 122/28/6 (1900)
	1901   => '1307256',            # Naissance Landeleau 3 E 122/28/7 (1901)
	1902   => '1307257',            # Naissance Landeleau 3 E 122/28/8 (1902)
	1903   => '1307258',            # Naissance Landeleau 3 E 122/28/9 (1903)
	1904   => '1307259',            # Naissance Landeleau 3 E 122/28/10 (1904)
	1905   => '1307260',            # Naissance Landeleau 3 E 122/28/11 (1905)
	1906   => '1307261',            # Naissance Landeleau 3 E 122/28/12 (1906)
    },

    '3E122_0029' => {			# Mariage Landeleau 3 E 122 29   1886-1902
	1886   => '1307393',            # Mariage Landeleau 3 E 122/29/1 (1886)
	1887   => '1307394',            # Mariage Landeleau 3 E 122/29/2 (1887)
	1888   => '1307395',            # Mariage Landeleau 3 E 122/29/3 (1888)
	1889   => '1307396',            # Mariage Landeleau 3 E 122/29/4 (1889)
	1890   => '1307397',            # Mariage Landeleau 3 E 122/29/5 (1890)
	1891   => '1307398',            # Mariage Landeleau 3 E 122/29/6 (1891)
	1892   => '1307399',            # Mariage Landeleau 3 E 122/29/7 (1892)
	1893   => '1307400',            # Mariage Landeleau 3 E 122/29/8 (1893)
	1894   => '1307401',            # Mariage Landeleau 3 E 122/29/9 (1894)
	1895   => '1307402',            # Mariage Landeleau 3 E 122/29/10 (1895)
	1896   => '1307403',            # Mariage Landeleau 3 E 122/29/11 (1896)
	1897   => '1307404',            # Mariage Landeleau 3 E 122/29/12 (1897)
	1898   => '1307405',            # Mariage Landeleau 3 E 122/29/13 (1898)
	1899   => '1307406',            # Mariage Landeleau 3 E 122/29/14 (1899)
	1900   => '1307407',            # Mariage Landeleau 3 E 122/29/15 (1900)
	1901   => '1307408',            # Mariage Landeleau 3 E 122/29/16 (1901)
	1902   => '1307409',            # Mariage Landeleau 3 E 122/29/17 (1902)
    },

    '3E122_0030' => {			# Décès Landeleau 3 E 122 30   1887-1903
	1887   => '1307547',            # Décès Landeleau 3 E 122/30/1 (1887)
	1888   => '1307548',            # Décès Landeleau 3 E 122/30/2 (1888)
	1889   => '1307549',            # Décès Landeleau 3 E 122/30/3 (1889)
	1890   => '1307550',            # Décès Landeleau 3 E 122/30/4 (1890)
	1891   => '1307551',            # Décès Landeleau 3 E 122/30/5 (1891)
	1892   => '1307552',            # Décès Landeleau 3 E 122/30/6 (1892)
	1893   => '1307553',            # Décès Landeleau 3 E 122/30/7 (1893)
	1894   => '1307554',            # Décès Landeleau 3 E 122/30/8 (1894)
	1895   => '1307555',            # Décès Landeleau 3 E 122/30/9 (1895)
	1896   => '1307556',            # Décès Landeleau 3 E 122/30/10 (1896)
	1897   => '1307557',            # Décès Landeleau 3 E 122/30/11 (1897)
	1898   => '1307558',            # Décès Landeleau 3 E 122/30/12 (1898)
	1899   => '1307559',            # Décès Landeleau 3 E 122/30/13 (1899)
	1900   => '1307560',            # Décès Landeleau 3 E 122/30/14 (1900)
	1901   => '1307561',            # Décès Landeleau 3 E 122/30/15 (1901)
	1902   => '1307562',            # Décès Landeleau 3 E 122/30/16 (1902)
	1903   => '1307563',            # Décès Landeleau 3 E 122/30/17 (1903)
    },

    '3E122_0031' => {			# Naissance Landeleau 3 E 122 31   1907-1921
	1907   => '1307263',            # Naissance Landeleau 3 E 122/31/1 (1907)
	1908   => '1307264',            # Naissance Landeleau 3 E 122/31/2 (1908)
	1909   => '1307265',            # Naissance Landeleau 3 E 122/31/3 (1909)
	1910   => '1307266',            # Naissance Landeleau 3 E 122/31/4 (1910)
	1911   => '1307267',            # Naissance Landeleau 3 E 122/31/5 (1911)
	1912   => '1307268',            # Naissance Landeleau 3 E 122/31/6 (1912)
	1913   => '1307269',            # Naissance Landeleau 3 E 122/31/7 (1913)
	1914   => '1307270',            # Naissance Landeleau 3 E 122/31/8 (1914)
	1915   => '1307271',            # Naissance Landeleau 3 E 122/31/9 (1915)
	1916   => '1307272',            # Naissance Landeleau 3 E 122/31/10 (1916)
	1917   => '1307273',            # Naissance Landeleau 3 E 122/31/11 (1917)
	1918   => '1307274',            # Naissance Landeleau 3 E 122/31/12 (1918)
	1919   => '1307275',            # Naissance Landeleau 3 E 122/31/13 (1919)
	1920   => '1307276',            # Naissance Landeleau 3 E 122/31/14 (1920)
	1921   => '1307277',            # Naissance Landeleau 3 E 122/31/15 (1921)
    },

    '3E122_0032' => {			# Naissance Landeleau 3 E 122 32   1922-1925
	1922   => '1307279',            # Naissance Landeleau 3 E 122/32/1 (1922)
	1923   => '1307280',            # Naissance Landeleau 3 E 122/32/2 (1923)
	1924   => '1307281',            # Naissance Landeleau 3 E 122/32/3 (1924)
	1925   => '1307282',            # Naissance Landeleau 3 E 122/32/4 (1925)
    },

    '3E122_0033' => {			# Mariage Landeleau 3 E 122 33   1903-1918
	1903   => '1307411',            # Mariage Landeleau 3 E 122/33/1 (1903)
	1904   => '1307412',            # Mariage Landeleau 3 E 122/33/2 (1904)
	1905   => '1307413',            # Mariage Landeleau 3 E 122/33/3 (1905)
	1906   => '1307414',            # Mariage Landeleau 3 E 122/33/4 (1906)
	1907   => '1307415',            # Mariage Landeleau 3 E 122/33/5 (1907)
	1908   => '1307416',            # Mariage Landeleau 3 E 122/33/6 (1908)
	1909   => '1307417',            # Mariage Landeleau 3 E 122/33/7 (1909)
	1910   => '1307418',            # Mariage Landeleau 3 E 122/33/8 (1910)
	1911   => '1307419',            # Mariage Landeleau 3 E 122/33/9 (1911)
	1913   => '1307420',            # Mariage Landeleau 3 E 122/33/10 (1913)
	1914   => '1307421',            # Mariage Landeleau 3 E 122/33/11 (1914)
	1915   => '1307422',            # Mariage Landeleau 3 E 122/33/12 (1915)
	1916   => '1307423',            # Mariage Landeleau 3 E 122/33/13 (1916)
	1917   => '1307424',            # Mariage Landeleau 3 E 122/33/14 (1917)
	1918   => '1307425',            # Mariage Landeleau 3 E 122/33/15 (1918)
    },

    '3E122_0034' => {			# Mariage Landeleau 3 E 122 34   1919-1936
	1919   => '1307427',            # Mariage Landeleau 3 E 122/34/1 (1919)
	1920   => '1307428',            # Mariage Landeleau 3 E 122/34/2 (1920)
	1921   => '1307429',            # Mariage Landeleau 3 E 122/34/3 (1921)
	1922   => '1307430',            # Mariage Landeleau 3 E 122/34/4 (1922)
	1923   => '1307431',            # Mariage Landeleau 3 E 122/34/5 (1923)
	1924   => '1307432',            # Mariage Landeleau 3 E 122/34/6 (1924)
	1925   => '1307433',            # Mariage Landeleau 3 E 122/34/7 (1925)
	1926   => '1307434',            # Mariage Landeleau 3 E 122/34/8 (1926)
	1927   => '1307435',            # Mariage Landeleau 3 E 122/34/9 (1927)
	1928   => '1307436',            # Mariage Landeleau 3 E 122/34/10 (1928)
	1929   => '1307437',            # Mariage Landeleau 3 E 122/34/11 (1929)
	1930   => '1307438',            # Mariage Landeleau 3 E 122/34/12 (1930)
	1931   => '1307439',            # Mariage Landeleau 3 E 122/34/13 (1931)
	1932   => '1307440',            # Mariage Landeleau 3 E 122/34/14 (1932)
	1933   => '1307441',            # Mariage Landeleau 3 E 122/34/15 (1933)
	1934   => '1307442',            # Mariage Landeleau 3 E 122/34/16 (1934)
	1935   => '1307443',            # Mariage Landeleau 3 E 122/34/17 (1935)
	1936   => '1307444',            # Mariage Landeleau 3 E 122/34/18 (1936)
    },

    '3E122_0035' => {			# Décès Landeleau 3 E 122 35   1904-1919
	1904   => '1307565',            # Décès Landeleau 3 E 122/35/1 (1904)
	1905   => '1307566',            # Décès Landeleau 3 E 122/35/2 (1905)
	1906   => '1307567',            # Décès Landeleau 3 E 122/35/3 (1906)
	1907   => '1307568',            # Décès Landeleau 3 E 122/35/4 (1907)
	1908   => '1307569',            # Décès Landeleau 3 E 122/35/5 (1908)
	1909   => '1307570',            # Décès Landeleau 3 E 122/35/6 (1909)
	1910   => '1307571',            # Décès Landeleau 3 E 122/35/7 (1910)
	1911   => '1307572',            # Décès Landeleau 3 E 122/35/8 (1911)
	1912   => '1307573',            # Décès Landeleau 3 E 122/35/9 (1912)
	1913   => '1307574',            # Décès Landeleau 3 E 122/35/10 (1913)
	1914   => '1307575',            # Décès Landeleau 3 E 122/35/11 (1914)
	1915   => '1307576',            # Décès Landeleau 3 E 122/35/12 (1915)
	1916   => '1307577',            # Décès Landeleau 3 E 122/35/13 (1916)
	1917   => '1307578',            # Décès Landeleau 3 E 122/35/14 (1917)
	1918   => '1307579',            # Décès Landeleau 3 E 122/35/15 (1918)
	1919   => '1307580',            # Décès Landeleau 3 E 122/35/16 (1919)
    },

    '3E122_0036' => {			# Décès Landeleau 3 E 122 36   1920-1936
	1920   => '1307582',            # Décès Landeleau 3 E 122/36/1 (1920)
	1921   => '1307583',            # Décès Landeleau 3 E 122/36/2 (1921)
	1922   => '1307584',            # Décès Landeleau 3 E 122/36/3 (1922)
	1923   => '1307585',            # Décès Landeleau 3 E 122/36/4 (1923)
	1924   => '1307586',            # Décès Landeleau 3 E 122/36/5 (1924)
	1925   => '1307587',            # Décès Landeleau 3 E 122/36/6 (1925)
	1926   => '1307588',            # Décès Landeleau 3 E 122/36/7 (1926)
	1927   => '1307589',            # Décès Landeleau 3 E 122/36/8 (1927)
	1928   => '1307590',            # Décès Landeleau 3 E 122/36/9 (1928)
	1929   => '1307591',            # Décès Landeleau 3 E 122/36/10 (1929)
	1930   => '1307592',            # Décès Landeleau 3 E 122/36/11 (1930)
	1931   => '1307593',            # Décès Landeleau 3 E 122/36/12 (1931)
	1932   => '1307594',            # Décès Landeleau 3 E 122/36/13 (1932)
	1933   => '1307595',            # Décès Landeleau 3 E 122/36/14 (1933)
	1934   => '1307596',            # Décès Landeleau 3 E 122/36/15 (1934)
	1935   => '1307597',            # Décès Landeleau 3 E 122/36/16 (1935)
	1936   => '1307598',            # Décès Landeleau 3 E 122/36/17 (1936)
    },


    # NMD Laz
    '3E148_0006' => '656328.1314145',   # Naissance Laz 3 E 148 6 (1793-1812)
    '3E148_0007' => '656329.1314146',   # Naissance Laz 3 E 148 7 (1813-1822)
    '3E148_0008' => '656330.1314147',   # Naissance Laz 3 E 148 8 (1823-1832)
    '3E148_0009' => '656331.1314148',   # Naissance Laz 3 E 148 9 (1833-1842)
    '3E148_0010' => '656332.1314149',   # Naissance Laz 3 E 148 10 (1843-1852)
    '3E148_0011' => '656333.1314150',   # Naissance Laz 3 E 148 11 (1853-1862)
    '3E148_0012' => '656334.1314151',   # Naissance Laz 3 E 148 12 (1863-1869)
    '3E148_0013' => '656335.1314152',   # Naissance Laz 3 E 148 13 (1870-1890)
    '3E148_0014' => '656336.1314203',   # Mariage Laz 3 E 148 14 (1793-an VI, an IX-1812)
    '3E148_0015' => '656337.1314204',   # Mariage Laz 3 E 148 15 (1813-1822)
    '3E148_0016' => '656338.1314205',   # Mariage Laz 3 E 148 16 (1823-1832)
    '3E148_0017' => '656339.1314206',   # Mariage Laz 3 E 148 17 (1833-1842)
    '3E148_0018' => '656340.1314207',   # Mariage Laz 3 E 148 18 (1843-1852)
    '3E148_0019' => '656341.1314208',   # Mariage Laz 3 E 148 19 (1853-1862)
    '3E148_0020' => '656342.1314209',   # Mariage Laz 3 E 148 20 (1863-1869)
    '3E148_0021' => '656343.1314210',   # Mariage Laz 3 E 148 21 (1870-1890)
    '3E148_0022' => '656344.1314261',   # Décès Laz 3 E 148 22 (1793-1812)
    '3E148_0023' => '656345.1314262',   # Décès Laz 3 E 148 23 (1813-1822)
    '3E148_0024' => '656346.1314263',   # Décès Laz 3 E 148 24 (1823-1832)
    '3E148_0025' => '656347.1314264',   # Décès Laz 3 E 148 25 (1833-1842)
    '3E148_0026' => '656348.1314265',   # Décès Laz 3 E 148 26 (1843-1852)
    '3E148_0027' => '656349.1314266',   # Décès Laz 3 E 148 27 (1853-1862)
    '3E148_0028' => '656350.1314267',   # Décès Laz 3 E 148 28 (1863-1869)
    '3E148_0029' => '656351.1314268',   # Décès Laz 3 E 148 29 (1870-1888)
    '3E148_0030' => {			# Naissance Laz 3 E 148 30   1891-1906
	1891   => '1314154',            # Naissance Laz 3 E 148/30/1 (1891)
	1892   => '1314155',            # Naissance Laz 3 E 148/30/2 (1892)
	1893   => '1314156',            # Naissance Laz 3 E 148/30/3 (1893)
	1894   => '1314157',            # Naissance Laz 3 E 148/30/4 (1894)
	1895   => '1314158',            # Naissance Laz 3 E 148/30/5 (1895)
	1896   => '1314159',            # Naissance Laz 3 E 148/30/6 (1896)
	1897   => '1314160',            # Naissance Laz 3 E 148/30/7 (1897)
	1898   => '1314161',            # Naissance Laz 3 E 148/30/8 (1898)
	1899   => '1314162',            # Naissance Laz 3 E 148/30/9 (1899)
	1900   => '1314163',            # Naissance Laz 3 E 148/30/10 (1900)
	1901   => '1314164',            # Naissance Laz 3 E 148/30/11 (1901)
	1902   => '1314165',            # Naissance Laz 3 E 148/30/12 (1902)
	1903   => '1314166',            # Naissance Laz 3 E 148/30/13 (1903)
	1904   => '1314167',            # Naissance Laz 3 E 148/30/14 (1904)
	1905   => '1314168',            # Naissance Laz 3 E 148/30/15 (1905)
	1906   => '1314169',            # Naissance Laz 3 E 148/30/16 (1906)
    },

    '3E148_0031' => {			# Décès Laz 3 E 148 31   1889-1904
	1889   => '1314270',            # Décès Laz 3 E 148/31/1 (1889)
	1890   => '1314271',            # Décès Laz 3 E 148/31/2 (1890)
	1891   => '1314272',            # Décès Laz 3 E 148/31/3 (1891)
	1892   => '1314273',            # Décès Laz 3 E 148/31/4 (1892)
	1893   => '1314274',            # Décès Laz 3 E 148/31/5 (1893)
	1894   => '1314275',            # Décès Laz 3 E 148/31/6 (1894)
	1895   => '1314276',            # Décès Laz 3 E 148/31/7 (1895)
	1896   => '1314277',            # Décès Laz 3 E 148/31/8 (1896)
	1897   => '1314278',            # Décès Laz 3 E 148/31/9 (1897)
	1898   => '1314279',            # Décès Laz 3 E 148/31/10 (1898)
	1899   => '1314280',            # Décès Laz 3 E 148/31/11 (1899)
	1900   => '1314281',            # Décès Laz 3 E 148/31/12 (1900)
	1901   => '1314282',            # Décès Laz 3 E 148/31/13 (1901)
	1902   => '1314283',            # Décès Laz 3 E 148/31/14 (1902)
	1903   => '1314284',            # Décès Laz 3 E 148/31/15 (1903)
	1904   => '1314285',            # Décès Laz 3 E 148/31/16 (1904)
    },

    '3E148_0032' => {			# Mariage Laz 3 E 148 32   1891-1907
	1891   => '1314212',            # Mariage Laz 3 E 148/32/1 (1891)
	1892   => '1314213',            # Mariage Laz 3 E 148/32/2 (1892)
	1893   => '1314214',            # Mariage Laz 3 E 148/32/3 (1893)
	1894   => '1314215',            # Mariage Laz 3 E 148/32/4 (1894)
	1895   => '1314216',            # Mariage Laz 3 E 148/32/5 (1895)
	1896   => '1314217',            # Mariage Laz 3 E 148/32/6 (1896)
	1897   => '1314218',            # Mariage Laz 3 E 148/32/7 (1897)
	1898   => '1314219',            # Mariage Laz 3 E 148/32/8 (1898)
	1899   => '1314220',            # Mariage Laz 3 E 148/32/9 (1899)
	1900   => '1314221',            # Mariage Laz 3 E 148/32/10 (1900)
	1901   => '1314222',            # Mariage Laz 3 E 148/32/11 (1901)
	1902   => '1314223',            # Mariage Laz 3 E 148/32/12 (1902)
	1903   => '1314224',            # Mariage Laz 3 E 148/32/13 (1903)
	1904   => '1314225',            # Mariage Laz 3 E 148/32/14 (1904)
	1905   => '1314226',            # Mariage Laz 3 E 148/32/15 (1905)
	1906   => '1314227',            # Mariage Laz 3 E 148/32/16 (1906)
	1907   => '1314228',            # Mariage Laz 3 E 148/32/17 (1907)
    },

    '3E148_0033' => {			# Naissance Laz 3 E 148 33   1907-1918
	1907   => '1314171',            # Naissance Laz 3 E 148/33/1 (1907)
	1908   => '1314172',            # Naissance Laz 3 E 148/33/2 (1908)
	1909   => '1314173',            # Naissance Laz 3 E 148/33/3 (1909)
	1910   => '1314174',            # Naissance Laz 3 E 148/33/4 (1910)
	1911   => '1314175',            # Naissance Laz 3 E 148/33/5 (1911)
	1912   => '1314176',            # Naissance Laz 3 E 148/33/6 (1912)
	1913   => '1314177',            # Naissance Laz 3 E 148/33/7 (1913)
	1914   => '1314178',            # Naissance Laz 3 E 148/33/8 (1914)
	1915   => '1314179',            # Naissance Laz 3 E 148/33/9 (1915)
	1916   => '1314180',            # Naissance Laz 3 E 148/33/10 (1916)
	1917   => '1314181',            # Naissance Laz 3 E 148/33/11 (1917)
	1918   => '1314182',            # Naissance Laz 3 E 148/33/12 (1918)
    },

    '3E148_0034' => {			# Naissance Laz 3 E 148 34   1919-1925
	1919   => '1314184',            # Naissance Laz 3 E 148/34/1 (1919)
	1920   => '1314185',            # Naissance Laz 3 E 148/34/2 (1920)
	1921   => '1314186',            # Naissance Laz 3 E 148/34/3 (1921)
	1922   => '1314187',            # Naissance Laz 3 E 148/34/4 (1922)
	1923   => '1314188',            # Naissance Laz 3 E 148/34/5 (1923)
	1924   => '1314189',            # Naissance Laz 3 E 148/34/6 (1924)
	1925   => '1314190',            # Naissance Laz 3 E 148/34/7 (1925)
    },

    '3E148_0035' => {			# Mariage Laz 3 E 148 35   1908-1919
	1908   => '1314230',            # Mariage Laz 3 E 148/35/1 (1908)
	1909   => '1314231',            # Mariage Laz 3 E 148/35/2 (1909)
	1910   => '1314232',            # Mariage Laz 3 E 148/35/3 (1910)
	1911   => '1314233',            # Mariage Laz 3 E 148/35/4 (1911)
	1912   => '1314234',            # Mariage Laz 3 E 148/35/5 (1912)
	1913   => '1314235',            # Mariage Laz 3 E 148/35/6 (1913)
	1914   => '1314236',            # Mariage Laz 3 E 148/35/7 (1914)
	1915   => '1314237',            # Mariage Laz 3 E 148/35/8 (1915)
	1916   => '1314238',            # Mariage Laz 3 E 148/35/9 (1916)
	1917   => '1314239',            # Mariage Laz 3 E 148/35/10 (1917)
	1918   => '1314240',            # Mariage Laz 3 E 148/35/11 (1918)
	1919   => '1314241',            # Mariage Laz 3 E 148/35/12 (1919)
    },

    '3E148_0036' => {			# Mariage Laz 3 E 148 36   1920-1936
	1920   => '1314243',            # Mariage Laz 3 E 148/36/1 (1920)
	1921   => '1314244',            # Mariage Laz 3 E 148/36/2 (1921)
	1922   => '1314245',            # Mariage Laz 3 E 148/36/3 (1922)
	1923   => '1314246',            # Mariage Laz 3 E 148/36/4 (1923)
	1924   => '1314247',            # Mariage Laz 3 E 148/36/5 (1924)
	1925   => '1314248',            # Mariage Laz 3 E 148/36/6 (1925)
	1926   => '1314249',            # Mariage Laz 3 E 148/36/7 (1926)
	1927   => '1314250',            # Mariage Laz 3 E 148/36/8 (1927)
	1928   => '1314251',            # Mariage Laz 3 E 148/36/9 (1928)
	1929   => '1314252',            # Mariage Laz 3 E 148/36/10 (1929)
	1930   => '1314253',            # Mariage Laz 3 E 148/36/11 (1930)
	1931   => '1314254',            # Mariage Laz 3 E 148/36/12 (1931)
	1932   => '1314255',            # Mariage Laz 3 E 148/36/13 (1932)
	1933   => '1314256',            # Mariage Laz 3 E 148/36/14 (1933)
	1934   => '1314257',            # Mariage Laz 3 E 148/36/15 (1934)
	1935   => '1314258',            # Mariage Laz 3 E 148/36/16 (1935)
	1936   => '1314259',            # Mariage Laz 3 E 148/36/17 (1936)
    },

    '3E148_0037' => {			# Décès Laz 3 E 148 37   1905-1918
	1905   => '1314287',            # Décès Laz 3 E 148/37/1 (1905)
	1906   => '1314288',            # Décès Laz 3 E 148/37/2 (1906)
	1907   => '1314289',            # Décès Laz 3 E 148/37/3 (1907)
	1908   => '1314290',            # Décès Laz 3 E 148/37/4 (1908)
	1909   => '1314291',            # Décès Laz 3 E 148/37/5 (1909)
	1910   => '1314292',            # Décès Laz 3 E 148/37/6 (1910)
	1911   => '1314293',            # Décès Laz 3 E 148/37/7 (1911)
	1912   => '1314294',            # Décès Laz 3 E 148/37/8 (1912)
	1913   => '1314295',            # Décès Laz 3 E 148/37/9 (1913)
	1914   => '1314296',            # Décès Laz 3 E 148/37/10 (1914)
	1915   => '1314297',            # Décès Laz 3 E 148/37/11 (1915)
	1916   => '1314298',            # Décès Laz 3 E 148/37/12 (1916)
	1917   => '1314299',            # Décès Laz 3 E 148/37/13 (1917)
	1918   => '1314300',            # Décès Laz 3 E 148/37/14 (1918)
    },

    '3E148_0038' => {			# Décès Laz 3 E 148 38   1919-1936
	1919   => '1314302',            # Décès Laz 3 E 148/38/1 (1919)
	1920   => '1314303',            # Décès Laz 3 E 148/38/2 (1920)
	1921   => '1314304',            # Décès Laz 3 E 148/38/3 (1921)
	1922   => '1314305',            # Décès Laz 3 E 148/38/4 (1922)
	1923   => '1314306',            # Décès Laz 3 E 148/38/5 (1923)
	1924   => '1314307',            # Décès Laz 3 E 148/38/6 (1924)
	1925   => '1314308',            # Décès Laz 3 E 148/38/7 (1925)
	1926   => '1314309',            # Décès Laz 3 E 148/38/8 (1926)
	1927   => '1314310',            # Décès Laz 3 E 148/38/9 (1927)
	1928   => '1314311',            # Décès Laz 3 E 148/38/10 (1928)
	1929   => '1314312',            # Décès Laz 3 E 148/38/11 (1929)
	1930   => '1314313',            # Décès Laz 3 E 148/38/12 (1930)
	1931   => '1314314',            # Décès Laz 3 E 148/38/13 (1931)
	1932   => '1314315',            # Décès Laz 3 E 148/38/14 (1932)
	1933   => '1314316',            # Décès Laz 3 E 148/38/15 (1933)
	1934   => '1314317',            # Décès Laz 3 E 148/38/16 (1934)
	1935   => '1314318',            # Décès Laz 3 E 148/38/17 (1935)
	1936   => '1314319',            # Décès Laz 3 E 148/38/18 (1936)
    },

    # NMD Leuhan
    '3E151_0006' => {			# Naissance Leuhan 3 E 151 6   AN02-1812
	'AN02' => '1315020',            # Naissance Leuhan 3 E 151/6/1 (an II)
	'AN03' => '1315021',            # Naissance Leuhan 3 E 151/6/2 (an III)
	'AN04' => '1315022',            # Naissance Leuhan 3 E 151/6/3 (an IV)
	'AN05' => '1315023',            # Naissance Leuhan 3 E 151/6/4 (an V)
	'AN06' => '1315024',            # Naissance Leuhan 3 E 151/6/5 (an VI)
	'AN07' => '1315025',            # Naissance Leuhan 3 E 151/6/6 (an VII)
	'AN09' => '1315026',            # Naissance Leuhan 3 E 151/6/7 (an IX)
	'AN10' => '1315027',            # Naissance Leuhan 3 E 151/6/8 (an X)
	'AN11' => '1315028',            # Naissance Leuhan 3 E 151/6/9 (an XI)
	'AN12' => '1315029',            # Naissance Leuhan 3 E 151/6/10 (an XII)
	'AN13' => '1315030',            # Naissance Leuhan 3 E 151/6/11 (an XIII)
	'AN14' => '1315031',            # Naissance Leuhan 3 E 151/6/12 (an XIV - 1806)
	1807   => '1315032',            # Naissance Leuhan 3 E 151/6/13 (1807)
	1808   => '1315033',            # Naissance Leuhan 3 E 151/6/14 (1808)
	1809   => '1315034',            # Naissance Leuhan 3 E 151/6/15 (1809)
	1810   => '1315035',            # Naissance Leuhan 3 E 151/6/16 (1810)
	1811   => '1315036',            # Naissance Leuhan 3 E 151/6/17 (1811)
	1812   => '1315037',            # Naissance Leuhan 3 E 151/6/18 (1812)
    },

    '3E151_0007' => {			# Naissance Leuhan 3 E 151 7   1813-1822
	1813   => '1315039',            # Naissance Leuhan 3 E 151/7/1 (1813)
	1814   => '1315040',            # Naissance Leuhan 3 E 151/7/2 (1814)
	1815   => '1315041',            # Naissance Leuhan 3 E 151/7/3 (1815)
	1816   => '1315042',            # Naissance Leuhan 3 E 151/7/4 (1816)
	1817   => '1315043',            # Naissance Leuhan 3 E 151/7/5 (1817)
	1818   => '1315044',            # Naissance Leuhan 3 E 151/7/6 (1818)
	1819   => '1315045',            # Naissance Leuhan 3 E 151/7/7 (1819)
	1820   => '1315046',            # Naissance Leuhan 3 E 151/7/8 (1820)
	1821   => '1315047',            # Naissance Leuhan 3 E 151/7/9 (1821)
	1822   => '1315048',            # Naissance Leuhan 3 E 151/7/10 (1822)
    },

    '3E151_0008' => {			# Naissance Leuhan 3 E 151 8   1823-1832
	1823   => '1315050',            # Naissance Leuhan 3 E 151/8/1 (1823)
	1824   => '1315051',            # Naissance Leuhan 3 E 151/8/2 (1824)
	1825   => '1315052',            # Naissance Leuhan 3 E 151/8/3 (1825)
	1826   => '1315053',            # Naissance Leuhan 3 E 151/8/4 (1826)
	1827   => '1315054',            # Naissance Leuhan 3 E 151/8/5 (1827)
	1828   => '1315055',            # Naissance Leuhan 3 E 151/8/6 (1828)
	1829   => '1315056',            # Naissance Leuhan 3 E 151/8/7 (1829)
	1830   => '1315057',            # Naissance Leuhan 3 E 151/8/8 (1830)
	1831   => '1315058',            # Naissance Leuhan 3 E 151/8/9 (1831)
	1832   => '1315059',            # Naissance Leuhan 3 E 151/8/10 (1832)
    },

    '3E151_0009' => {			# Naissance Leuhan 3 E 151 9   1833-1842
	1833   => '1315061',            # Naissance Leuhan 3 E 151/9/1 (1833)
	1834   => '1315062',            # Naissance Leuhan 3 E 151/9/2 (1834)
	1835   => '1315063',            # Naissance Leuhan 3 E 151/9/3 (1835)
	1836   => '1315064',            # Naissance Leuhan 3 E 151/9/4 (1836)
	1837   => '1315065',            # Naissance Leuhan 3 E 151/9/5 (1837)
	1838   => '1315066',            # Naissance Leuhan 3 E 151/9/6 (1838)
	1839   => '1315067',            # Naissance Leuhan 3 E 151/9/7 (1839)
	1840   => '1315068',            # Naissance Leuhan 3 E 151/9/8 (1840)
	1841   => '1315069',            # Naissance Leuhan 3 E 151/9/9 (1841)
	1842   => '1315070',            # Naissance Leuhan 3 E 151/9/10 (1842)
    },

    '3E151_0010' => {			# Naissance Leuhan 3 E 151 10   1843-1852
	1843   => '1315072',            # Naissance Leuhan 3 E 151/10/1 (1843)
	1844   => '1315073',            # Naissance Leuhan 3 E 151/10/2 (1844)
	1845   => '1315074',            # Naissance Leuhan 3 E 151/10/3 (1845)
	1846   => '1315075',            # Naissance Leuhan 3 E 151/10/4 (1846)
	1847   => '1315076',            # Naissance Leuhan 3 E 151/10/5 (1847)
	1848   => '1315077',            # Naissance Leuhan 3 E 151/10/6 (1848)
	1849   => '1315078',            # Naissance Leuhan 3 E 151/10/7 (1849)
	1850   => '1315079',            # Naissance Leuhan 3 E 151/10/8 (1850)
	1851   => '1315080',            # Naissance Leuhan 3 E 151/10/9 (1851)
	1852   => '1315081',            # Naissance Leuhan 3 E 151/10/10 (1852)
    },

    '3E151_0011' => {			# Naissance Leuhan 3 E 151 11   1853-1862
	1853   => '1315083',            # Naissance Leuhan 3 E 151/11/1 (1853)
	1854   => '1315084',            # Naissance Leuhan 3 E 151/11/2 (1854)
	1855   => '1315085',            # Naissance Leuhan 3 E 151/11/3 (1855)
	1856   => '1315086',            # Naissance Leuhan 3 E 151/11/4 (1856)
	1857   => '1315087',            # Naissance Leuhan 3 E 151/11/5 (1857)
	1858   => '1315088',            # Naissance Leuhan 3 E 151/11/6 (1858)
	1859   => '1315089',            # Naissance Leuhan 3 E 151/11/7 (1859)
	1860   => '1315090',            # Naissance Leuhan 3 E 151/11/8 (1860)
	1861   => '1315091',            # Naissance Leuhan 3 E 151/11/9 (1861)
	1862   => '1315092',            # Naissance Leuhan 3 E 151/11/10 (1862)
    },

    '3E151_0012' => {			# Naissance Leuhan 3 E 151 12   1863-1869
	1863   => '1315094',            # Naissance Leuhan 3 E 151/12/1 (1863)
	1864   => '1315095',            # Naissance Leuhan 3 E 151/12/2 (1864)
	1865   => '1315096',            # Naissance Leuhan 3 E 151/12/3 (1865)
	1866   => '1315097',            # Naissance Leuhan 3 E 151/12/4 (1866)
	1867   => '1315098',            # Naissance Leuhan 3 E 151/12/5 (1867)
	1868   => '1315099',            # Naissance Leuhan 3 E 151/12/6 (1868)
	1869   => '1315100',            # Naissance Leuhan 3 E 151/12/7 (1869)
    },

    '3E151_0013' => {			# Naissance Leuhan 3 E 151 13   1870-1884
	1870   => '1315102',            # Naissance Leuhan 3 E 151/13/1 (1870)
	1871   => '1315103',            # Naissance Leuhan 3 E 151/13/2 (1871)
	1872   => '1315104',            # Naissance Leuhan 3 E 151/13/3 (1872)
	1873   => '1315105',            # Naissance Leuhan 3 E 151/13/4 (1873)
	1874   => '1315106',            # Naissance Leuhan 3 E 151/13/5 (1874)
	1875   => '1315107',            # Naissance Leuhan 3 E 151/13/6 (1875)
	1876   => '1315108',            # Naissance Leuhan 3 E 151/13/7 (1876)
	1877   => '1315109',            # Naissance Leuhan 3 E 151/13/8 (1877)
	1878   => '1315110',            # Naissance Leuhan 3 E 151/13/9 (1878)
	1879   => '1315111',            # Naissance Leuhan 3 E 151/13/10 (1879)
	1880   => '1315112',            # Naissance Leuhan 3 E 151/13/11 (1880)
	1881   => '1315113',            # Naissance Leuhan 3 E 151/13/12 (1881)
	1882   => '1315114',            # Naissance Leuhan 3 E 151/13/13 (1882)
	1883   => '1315115',            # Naissance Leuhan 3 E 151/13/14 (1883)
	1884   => '1315116',            # Naissance Leuhan 3 E 151/13/15 (1884)
    },

    '3E151_0014' => {			# Mariage Leuhan 3 E 151 14   AN02-1812
	'AN02' => '1315175',            # Mariage Leuhan 3 E 151/14/1 (an II)
	'AN03' => '1315176',            # Mariage Leuhan 3 E 151/14/2 (an III)
	'AN04' => '1315177',            # Mariage Leuhan 3 E 151/14/3 (an IV)
	'AN05' => '1315178',            # Mariage Leuhan 3 E 151/14/4 (an V)
	'AN06' => '1315179',            # Mariage Leuhan 3 E 151/14/5 (an VI)
	'AN09' => '1315180',            # Mariage Leuhan 3 E 151/14/6 (an IX)
	'AN10' => '1315181',            # Mariage Leuhan 3 E 151/14/7 (an X)
	'AN11' => '1315182',            # Mariage Leuhan 3 E 151/14/8 (an XI)
	'AN12' => '1315183',            # Mariage Leuhan 3 E 151/14/9 (an XII)
	'AN13' => '1315184',            # Mariage Leuhan 3 E 151/14/10 (an XIII)
	'AN14' => '1315185',            # Mariage Leuhan 3 E 151/14/11 (an XIV - 1806)
	1807   => '1315186',            # Mariage Leuhan 3 E 151/14/12 (1807)
	1808   => '1315187',            # Mariage Leuhan 3 E 151/14/13 (1808)
	1809   => '1315188',            # Mariage Leuhan 3 E 151/14/14 (1809)
	1810   => '1315189',            # Mariage Leuhan 3 E 151/14/15 (1810)
	1811   => '1315190',            # Mariage Leuhan 3 E 151/14/16 (1811)
	1812   => '1315191',            # Mariage Leuhan 3 E 151/14/17 (1812)
    },

    '3E151_0015' => {			# Mariage Leuhan 3 E 151 15   1813-1822
	1813   => '1315193',            # Mariage Leuhan 3 E 151/15/1 (1813)
	1814   => '1315194',            # Mariage Leuhan 3 E 151/15/2 (1814)
	1815   => '1315195',            # Mariage Leuhan 3 E 151/15/3 (1815)
	1816   => '1315196',            # Mariage Leuhan 3 E 151/15/4 (1816)
	1817   => '1315197',            # Mariage Leuhan 3 E 151/15/5 (1817)
	1818   => '1315198',            # Mariage Leuhan 3 E 151/15/6 (1818)
	1819   => '1315199',            # Mariage Leuhan 3 E 151/15/7 (1819)
	1820   => '1315200',            # Mariage Leuhan 3 E 151/15/8 (1820)
	1821   => '1315201',            # Mariage Leuhan 3 E 151/15/9 (1821)
	1822   => '1315202',            # Mariage Leuhan 3 E 151/15/10 (1822)
    },

    '3E151_0016' => {			# Mariage Leuhan 3 E 151 16   1823-1832
	1823   => '1315204',            # Mariage Leuhan 3 E 151/16/1 (1823)
	1824   => '1315205',            # Mariage Leuhan 3 E 151/16/2 (1824)
	1825   => '1315206',            # Mariage Leuhan 3 E 151/16/3 (1825)
	1826   => '1315207',            # Mariage Leuhan 3 E 151/16/4 (1826)
	1827   => '1315208',            # Mariage Leuhan 3 E 151/16/5 (1827)
	1828   => '1315209',            # Mariage Leuhan 3 E 151/16/6 (1828)
	1829   => '1315210',            # Mariage Leuhan 3 E 151/16/7 (1829)
	1830   => '1315211',            # Mariage Leuhan 3 E 151/16/8 (1830)
	1831   => '1315212',            # Mariage Leuhan 3 E 151/16/9 (1831)
	1832   => '1315213',            # Mariage Leuhan 3 E 151/16/10 (1832)
    },

    '3E151_0017' => {			# Mariage Leuhan 3 E 151 17   1833-1842
	1833   => '1315215',            # Mariage Leuhan 3 E 151/17/1 (1833)
	1834   => '1315216',            # Mariage Leuhan 3 E 151/17/2 (1834)
	1835   => '1315217',            # Mariage Leuhan 3 E 151/17/3 (1835)
	1836   => '1315218',            # Mariage Leuhan 3 E 151/17/4 (1836)
	1837   => '1315219',            # Mariage Leuhan 3 E 151/17/5 (1837)
	1838   => '1315220',            # Mariage Leuhan 3 E 151/17/6 (1838)
	1839   => '1315221',            # Mariage Leuhan 3 E 151/17/7 (1839)
	1840   => '1315222',            # Mariage Leuhan 3 E 151/17/8 (1840)
	1841   => '1315223',            # Mariage Leuhan 3 E 151/17/9 (1841)
	1842   => '1315224',            # Mariage Leuhan 3 E 151/17/10 (1842)
    },

    '3E151_0018' => {			# Mariage Leuhan 3 E 151 18   1843-1852
	1843   => '1315226',            # Mariage Leuhan 3 E 151/18/1 (1843)
	1844   => '1315227',            # Mariage Leuhan 3 E 151/18/2 (1844)
	1845   => '1315228',            # Mariage Leuhan 3 E 151/18/3 (1845)
	1846   => '1315229',            # Mariage Leuhan 3 E 151/18/4 (1846)
	1847   => '1315230',            # Mariage Leuhan 3 E 151/18/5 (1847)
	1848   => '1315231',            # Mariage Leuhan 3 E 151/18/6 (1848)
	1849   => '1315232',            # Mariage Leuhan 3 E 151/18/7 (1849)
	1850   => '1315233',            # Mariage Leuhan 3 E 151/18/8 (1850)
	1851   => '1315234',            # Mariage Leuhan 3 E 151/18/9 (1851)
	1852   => '1315235',            # Mariage Leuhan 3 E 151/18/10 (1852)
    },

    '3E151_0019' => {			# Mariage Leuhan 3 E 151 19   1853-1862
	1853   => '1315237',            # Mariage Leuhan 3 E 151/19/1 (1853)
	1854   => '1315238',            # Mariage Leuhan 3 E 151/19/2 (1854)
	1855   => '1315239',            # Mariage Leuhan 3 E 151/19/3 (1855)
	1856   => '1315240',            # Mariage Leuhan 3 E 151/19/4 (1856)
	1857   => '1315241',            # Mariage Leuhan 3 E 151/19/5 (1857)
	1858   => '1315242',            # Mariage Leuhan 3 E 151/19/6 (1858)
	1859   => '1315243',            # Mariage Leuhan 3 E 151/19/7 (1859)
	1860   => '1315244',            # Mariage Leuhan 3 E 151/19/8 (1860)
	1861   => '1315245',            # Mariage Leuhan 3 E 151/19/9 (1861)
	1862   => '1315246',            # Mariage Leuhan 3 E 151/19/10 (1862)
    },

    '3E151_0020' => {			# Mariage Leuhan 3 E 151 20   1863-1869
	1863   => '1315248',            # Mariage Leuhan 3 E 151/20/1 (1863)
	1864   => '1315249',            # Mariage Leuhan 3 E 151/20/2 (1864)
	1865   => '1315250',            # Mariage Leuhan 3 E 151/20/3 (1865)
	1866   => '1315251',            # Mariage Leuhan 3 E 151/20/4 (1866)
	1867   => '1315252',            # Mariage Leuhan 3 E 151/20/5 (1867)
	1868   => '1315253',            # Mariage Leuhan 3 E 151/20/6 (1868)
	1869   => '1315254',            # Mariage Leuhan 3 E 151/20/7 (1869)
    },

    '3E151_0021' => {			# Mariage Leuhan 3 E 151 21   1870-1885
	1870   => '1315256',            # Mariage Leuhan 3 E 151/21/1 (1870)
	1871   => '1315257',            # Mariage Leuhan 3 E 151/21/2 (1871)
	1872   => '1315258',            # Mariage Leuhan 3 E 151/21/3 (1872)
	1873   => '1315259',            # Mariage Leuhan 3 E 151/21/4 (1873)
	1874   => '1315260',            # Mariage Leuhan 3 E 151/21/5 (1874)
	1875   => '1315261',            # Mariage Leuhan 3 E 151/21/6 (1875)
	1876   => '1315262',            # Mariage Leuhan 3 E 151/21/7 (1876)
	1877   => '1315263',            # Mariage Leuhan 3 E 151/21/8 (1877)
	1878   => '1315264',            # Mariage Leuhan 3 E 151/21/9 (1878)
	1879   => '1315265',            # Mariage Leuhan 3 E 151/21/10 (1879)
	1880   => '1315266',            # Mariage Leuhan 3 E 151/21/11 (1880)
	1881   => '1315267',            # Mariage Leuhan 3 E 151/21/12 (1881)
	1882   => '1315268',            # Mariage Leuhan 3 E 151/21/13 (1882)
	1883   => '1315269',            # Mariage Leuhan 3 E 151/21/14 (1883)
	1884   => '1315270',            # Mariage Leuhan 3 E 151/21/15 (1884)
	1885   => '1315271',            # Mariage Leuhan 3 E 151/21/16 (1885)
    },

    '3E151_0022' => {			# Décès Leuhan 3 E 151 22   AN02-1812
	'AN02' => '1315328',            # Décès Leuhan 3 E 151/22/1 (an II)
	'AN03' => '1315329',            # Décès Leuhan 3 E 151/22/2 (an III)
	'AN04' => '1315330',            # Décès Leuhan 3 E 151/22/3 (an IV)
	'AN05' => '1315331',            # Décès Leuhan 3 E 151/22/4 (an V)
	'AN06' => '1315332',            # Décès Leuhan 3 E 151/22/5 (an VI)
	'AN07' => '1315333',            # Décès Leuhan 3 E 151/22/6 (an VII)
	'AN08' => '1315334',            # Décès Leuhan 3 E 151/22/7 (an VIII)
	'AN09' => '1315335',            # Décès Leuhan 3 E 151/22/8 (an IX)
	'AN10' => '1315336',            # Décès Leuhan 3 E 151/22/9 (an X)
	'AN11' => '1315337',            # Décès Leuhan 3 E 151/22/10 (an XI)
	'AN12' => '1315338',            # Décès Leuhan 3 E 151/22/11 (an XII)
	'AN13' => '1315339',            # Décès Leuhan 3 E 151/22/12 (an XIII)
	'AN14' => '1315340',            # Décès Leuhan 3 E 151/22/13 (an XIV - 1806)
	1807   => '1315341',            # Décès Leuhan 3 E 151/22/14 (1807)
	1808   => '1315342',            # Décès Leuhan 3 E 151/22/15 (1808)
	1809   => '1315343',            # Décès Leuhan 3 E 151/22/16 (1809)
	1810   => '1315344',            # Décès Leuhan 3 E 151/22/17 (1810)
	1811   => '1315345',            # Décès Leuhan 3 E 151/22/18 (1811)
	1812   => '1315346',            # Décès Leuhan 3 E 151/22/19 (1812)
    },

    '3E151_0023' => {			# Décès Leuhan 3 E 151 23   1813-1822
	1813   => '1315348',            # Décès Leuhan 3 E 151/23/1 (1813)
	1814   => '1315349',            # Décès Leuhan 3 E 151/23/2 (1814)
	1815   => '1315350',            # Décès Leuhan 3 E 151/23/3 (1815)
	1816   => '1315351',            # Décès Leuhan 3 E 151/23/4 (1816)
	1817   => '1315352',            # Décès Leuhan 3 E 151/23/5 (1817)
	1818   => '1315353',            # Décès Leuhan 3 E 151/23/6 (1818)
	1819   => '1315354',            # Décès Leuhan 3 E 151/23/7 (1819)
	1820   => '1315355',            # Décès Leuhan 3 E 151/23/8 (1820)
	1821   => '1315356',            # Décès Leuhan 3 E 151/23/9 (1821)
	1822   => '1315357',            # Décès Leuhan 3 E 151/23/10 (1822)
    },

    '3E151_0024' => {			# Décès Leuhan 3 E 151 24   1823-1832
	1823   => '1315359',            # Décès Leuhan 3 E 151/24/1 (1823)
	1824   => '1315360',            # Décès Leuhan 3 E 151/24/2 (1824)
	1825   => '1315361',            # Décès Leuhan 3 E 151/24/3 (1825)
	1826   => '1315362',            # Décès Leuhan 3 E 151/24/4 (1826)
	1827   => '1315363',            # Décès Leuhan 3 E 151/24/5 (1827)
	1828   => '1315364',            # Décès Leuhan 3 E 151/24/6 (1828)
	1829   => '1315365',            # Décès Leuhan 3 E 151/24/7 (1829)
	1830   => '1315366',            # Décès Leuhan 3 E 151/24/8 (1830)
	1831   => '1315367',            # Décès Leuhan 3 E 151/24/9 (1831)
	1832   => '1315368',            # Décès Leuhan 3 E 151/24/10 (1832)
    },

    '3E151_0025' => {			# Décès Leuhan 3 E 151 25   1833-1842
	1833   => '1315370',            # Décès Leuhan 3 E 151/25/1 (1833)
	1834   => '1315371',            # Décès Leuhan 3 E 151/25/2 (1834)
	1835   => '1315372',            # Décès Leuhan 3 E 151/25/3 (1835)
	1836   => '1315373',            # Décès Leuhan 3 E 151/25/4 (1836)
	1837   => '1315374',            # Décès Leuhan 3 E 151/25/5 (1837)
	1838   => '1315375',            # Décès Leuhan 3 E 151/25/6 (1838)
	1839   => '1315376',            # Décès Leuhan 3 E 151/25/7 (1839)
	1840   => '1315377',            # Décès Leuhan 3 E 151/25/8 (1840)
	1841   => '1315378',            # Décès Leuhan 3 E 151/25/9 (1841)
	1842   => '1315379',            # Décès Leuhan 3 E 151/25/10 (1842)
    },

    '3E151_0026' => {			# Décès Leuhan 3 E 151 26   1843-1852
	1843   => '1315381',            # Décès Leuhan 3 E 151/26/1 (1843)
	1844   => '1315382',            # Décès Leuhan 3 E 151/26/2 (1844)
	1845   => '1315383',            # Décès Leuhan 3 E 151/26/3 (1845)
	1846   => '1315384',            # Décès Leuhan 3 E 151/26/4 (1846)
	1847   => '1315385',            # Décès Leuhan 3 E 151/26/5 (1847)
	1848   => '1315386',            # Décès Leuhan 3 E 151/26/6 (1848)
	1849   => '1315387',            # Décès Leuhan 3 E 151/26/7 (1849)
	1850   => '1315388',            # Décès Leuhan 3 E 151/26/8 (1850)
	1851   => '1315389',            # Décès Leuhan 3 E 151/26/9 (1851)
	1852   => '1315390',            # Décès Leuhan 3 E 151/26/10 (1852)
    },

    '3E151_0027' => {			# Décès Leuhan 3 E 151 27   1853-1862
	1853   => '1315392',            # Décès Leuhan 3 E 151/27/1 (1853)
	1854   => '1315393',            # Décès Leuhan 3 E 151/27/2 (1854)
	1855   => '1315394',            # Décès Leuhan 3 E 151/27/3 (1855)
	1856   => '1315395',            # Décès Leuhan 3 E 151/27/4 (1856)
	1857   => '1315396',            # Décès Leuhan 3 E 151/27/5 (1857)
	1858   => '1315397',            # Décès Leuhan 3 E 151/27/6 (1858)
	1859   => '1315398',            # Décès Leuhan 3 E 151/27/7 (1859)
	1860   => '1315399',            # Décès Leuhan 3 E 151/27/8 (1860)
	1861   => '1315400',            # Décès Leuhan 3 E 151/27/9 (1861)
	1862   => '1315401',            # Décès Leuhan 3 E 151/27/10 (1862)
    },

    '3E151_0028' => {			# Décès Leuhan 3 E 151 28   1863-1869
	1863   => '1315403',            # Décès Leuhan 3 E 151/28/1 (1863)
	1864   => '1315404',            # Décès Leuhan 3 E 151/28/2 (1864)
	1865   => '1315405',            # Décès Leuhan 3 E 151/28/3 (1865)
	1866   => '1315406',            # Décès Leuhan 3 E 151/28/4 (1866)
	1867   => '1315407',            # Décès Leuhan 3 E 151/28/5 (1867)
	1868   => '1315408',            # Décès Leuhan 3 E 151/28/6 (1868)
	1869   => '1315409',            # Décès Leuhan 3 E 151/28/7 (1869)
    },

    '3E151_0029' => {			# Décès Leuhan 3 E 151 29   1870-1883
	1870   => '1315411',            # Décès Leuhan 3 E 151/29/1 (1870)
	1871   => '1315412',            # Décès Leuhan 3 E 151/29/2 (1871)
	1872   => '1315413',            # Décès Leuhan 3 E 151/29/3 (1872)
	1873   => '1315414',            # Décès Leuhan 3 E 151/29/4 (1873)
	1874   => '1315415',            # Décès Leuhan 3 E 151/29/5 (1874)
	1875   => '1315416',            # Décès Leuhan 3 E 151/29/6 (1875)
	1876   => '1315417',            # Décès Leuhan 3 E 151/29/7 (1876)
	1877   => '1315418',            # Décès Leuhan 3 E 151/29/8 (1877)
	1878   => '1315419',            # Décès Leuhan 3 E 151/29/9 (1878)
	1879   => '1315420',            # Décès Leuhan 3 E 151/29/10 (1879)
	1880   => '1315421',            # Décès Leuhan 3 E 151/29/11 (1880)
	1881   => '1315422',            # Décès Leuhan 3 E 151/29/12 (1881)
	1882   => '1315423',            # Décès Leuhan 3 E 151/29/13 (1882)
	1883   => '1315424',            # Décès Leuhan 3 E 151/29/14 (1883)
    },

    '3E151_0030' => {			# Naissance Leuhan 3 E 151 30   1885-1897
	1885   => '1315118',            # Naissance Leuhan 3 E 151/30/1 (1885)
	1886   => '1315119',            # Naissance Leuhan 3 E 151/30/2 (1886)
	1887   => '1315120',            # Naissance Leuhan 3 E 151/30/3 (1887)
	1888   => '1315121',            # Naissance Leuhan 3 E 151/30/4 (1888)
	1889   => '1315122',            # Naissance Leuhan 3 E 151/30/5 (1889)
	1890   => '1315123',            # Naissance Leuhan 3 E 151/30/6 (1890)
	1891   => '1315124',            # Naissance Leuhan 3 E 151/30/7 (1891)
	1892   => '1315125',            # Naissance Leuhan 3 E 151/30/8 (1892)
	1893   => '1315126',            # Naissance Leuhan 3 E 151/30/9 (1893)
	1894   => '1315127',            # Naissance Leuhan 3 E 151/30/10 (1894)
	1895   => '1315128',            # Naissance Leuhan 3 E 151/30/11 (1895)
	1896   => '1315129',            # Naissance Leuhan 3 E 151/30/12 (1896)
	1897   => '1315130',            # Naissance Leuhan 3 E 151/30/13 (1897)
    },

    '3E151_0031' => {			# Décès Leuhan 3 E 151 31   1884-1897
	1884   => '1315426',            # Décès Leuhan 3 E 151/31/1 (1884)
	1885   => '1315427',            # Décès Leuhan 3 E 151/31/2 (1885)
	1886   => '1315428',            # Décès Leuhan 3 E 151/31/3 (1886)
	1887   => '1315429',            # Décès Leuhan 3 E 151/31/4 (1887)
	1888   => '1315430',            # Décès Leuhan 3 E 151/31/5 (1888)
	1889   => '1315431',            # Décès Leuhan 3 E 151/31/6 (1889)
	1890   => '1315432',            # Décès Leuhan 3 E 151/31/7 (1890)
	1891   => '1315433',            # Décès Leuhan 3 E 151/31/8 (1891)
	1892   => '1315434',            # Décès Leuhan 3 E 151/31/9 (1892)
	1893   => '1315435',            # Décès Leuhan 3 E 151/31/10 (1893)
	1894   => '1315436',            # Décès Leuhan 3 E 151/31/11 (1894)
	1895   => '1315437',            # Décès Leuhan 3 E 151/31/12 (1895)
	1896   => '1315438',            # Décès Leuhan 3 E 151/31/13 (1896)
	1897   => '1315439',            # Décès Leuhan 3 E 151/31/14 (1897)
    },

    '3E151_0032' => {			# Mariage Leuhan 3 E 151 32   1886-1902
	1886   => '1315273',            # Mariage Leuhan 3 E 151/32/1 (1886)
	1887   => '1315274',            # Mariage Leuhan 3 E 151/32/2 (1887)
	1888   => '1315275',            # Mariage Leuhan 3 E 151/32/3 (1888)
	1889   => '1315276',            # Mariage Leuhan 3 E 151/32/4 (1889)
	1890   => '1315277',            # Mariage Leuhan 3 E 151/32/5 (1890)
	1891   => '1315278',            # Mariage Leuhan 3 E 151/32/6 (1891)
	1892   => '1315279',            # Mariage Leuhan 3 E 151/32/7 (1892)
	1893   => '1315280',            # Mariage Leuhan 3 E 151/32/8 (1893)
	1894   => '1315281',            # Mariage Leuhan 3 E 151/32/9 (1894)
	1895   => '1315282',            # Mariage Leuhan 3 E 151/32/10 (1895)
	1896   => '1315283',            # Mariage Leuhan 3 E 151/32/11 (1896)
	1897   => '1315284',            # Mariage Leuhan 3 E 151/32/12 (1897)
	1898   => '1315285',            # Mariage Leuhan 3 E 151/32/13 (1898)
	1899   => '1315286',            # Mariage Leuhan 3 E 151/32/14 (1899)
	1900   => '1315287',            # Mariage Leuhan 3 E 151/32/15 (1900)
	1901   => '1315288',            # Mariage Leuhan 3 E 151/32/16 (1901)
	1902   => '1315289',            # Mariage Leuhan 3 E 151/32/17 (1902)
    },

    '3E151_0033' => {			# Naissance Leuhan 3 E 151 33   1898-1909
	1898   => '1315132',            # Naissance Leuhan 3 E 151/33/1 (1898)
	1899   => '1315133',            # Naissance Leuhan 3 E 151/33/2 (1899)
	1900   => '1315134',            # Naissance Leuhan 3 E 151/33/3 (1900)
	1901   => '1315135',            # Naissance Leuhan 3 E 151/33/4 (1901)
	1902   => '1315136',            # Naissance Leuhan 3 E 151/33/5 (1902)
	1903   => '1315137',            # Naissance Leuhan 3 E 151/33/6 (1903)
	1904   => '1315138',            # Naissance Leuhan 3 E 151/33/7 (1904)
	1905   => '1315139',            # Naissance Leuhan 3 E 151/33/8 (1905)
	1906   => '1315140',            # Naissance Leuhan 3 E 151/33/9 (1906)
	1907   => '1315141',            # Naissance Leuhan 3 E 151/33/10 (1907)
	1908   => '1315142',            # Naissance Leuhan 3 E 151/33/11 (1908)
	1909   => '1315143',            # Naissance Leuhan 3 E 151/33/12 (1909)
    },

    '3E151_0034' => {			# Décès Leuhan 3 E 151 34   1898-1909
	1898   => '1315441',            # Décès Leuhan 3 E 151/34/1 (1898)
	1899   => '1315442',            # Décès Leuhan 3 E 151/34/2 (1899)
	1900   => '1315443',            # Décès Leuhan 3 E 151/34/3 (1900)
	1901   => '1315444',            # Décès Leuhan 3 E 151/34/4 (1901)
	1902   => '1315445',            # Décès Leuhan 3 E 151/34/5 (1902)
	1903   => '1315446',            # Décès Leuhan 3 E 151/34/6 (1903)
	1904   => '1315447',            # Décès Leuhan 3 E 151/34/7 (1904)
	1905   => '1315448',            # Décès Leuhan 3 E 151/34/8 (1905)
	1906   => '1315449',            # Décès Leuhan 3 E 151/34/9 (1906)
	1907   => '1315450',            # Décès Leuhan 3 E 151/34/10 (1907)
	1908   => '1315451',            # Décès Leuhan 3 E 151/34/11 (1908)
	1909   => '1315452',            # Décès Leuhan 3 E 151/34/12 (1909)
    },

    '3E151_0035' => {			# Naissance Leuhan 3 E 151 35   1910-1921
	1910   => '1315145',            # Naissance Leuhan 3 E 151/35/1 (1910)
	1911   => '1315146',            # Naissance Leuhan 3 E 151/35/2 (1911)
	1912   => '1315147',            # Naissance Leuhan 3 E 151/35/3 (1912)
	1913   => '1315148',            # Naissance Leuhan 3 E 151/35/4 (1913)
	1914   => '1315149',            # Naissance Leuhan 3 E 151/35/5 (1914)
	1915   => '1315150',            # Naissance Leuhan 3 E 151/35/6 (1915)
	1916   => '1315151',            # Naissance Leuhan 3 E 151/35/7 (1916)
	1917   => '1315152',            # Naissance Leuhan 3 E 151/35/8 (1917)
	1918   => '1315153',            # Naissance Leuhan 3 E 151/35/9 (1918)
	1919   => '1315154',            # Naissance Leuhan 3 E 151/35/10 (1919)
	1920   => '1315155',            # Naissance Leuhan 3 E 151/35/11 (1920)
	1921   => '1315156',            # Naissance Leuhan 3 E 151/35/12 (1921)
    },

    '3E151_0036' => {			# Naissance Leuhan 3 E 151 36   1922-1925
	1922   => '1315158',            # Naissance Leuhan 3 E 151/36/1 (1922)
	1923   => '1315159',            # Naissance Leuhan 3 E 151/36/2 (1923)
	1924   => '1315160',            # Naissance Leuhan 3 E 151/36/3 (1924)
	1925   => '1315161',            # Naissance Leuhan 3 E 151/36/4 (1925)
    },

    '3E151_0037' => {			# Mariage Leuhan 3 E 151 37   1903-1918
	1903   => '1315291',            # Mariage Leuhan 3 E 151/37/1 (1903)
	1904   => '1315292',            # Mariage Leuhan 3 E 151/37/2 (1904)
	1905   => '1315293',            # Mariage Leuhan 3 E 151/37/3 (1905)
	1906   => '1315294',            # Mariage Leuhan 3 E 151/37/4 (1906)
	1907   => '1315295',            # Mariage Leuhan 3 E 151/37/5 (1907)
	1908   => '1315296',            # Mariage Leuhan 3 E 151/37/6 (1908)
	1909   => '1315297',            # Mariage Leuhan 3 E 151/37/7 (1909)
	1910   => '1315298',            # Mariage Leuhan 3 E 151/37/8 (1910)
	1911   => '1315299',            # Mariage Leuhan 3 E 151/37/9 (1911)
	1912   => '1315300',            # Mariage Leuhan 3 E 151/37/10 (1912)
	1913   => '1315301',            # Mariage Leuhan 3 E 151/37/11 (1913)
	1914   => '1315302',            # Mariage Leuhan 3 E 151/37/12 (1914)
	1915   => '1315303',            # Mariage Leuhan 3 E 151/37/13 (1915)
	1916   => '1315304',            # Mariage Leuhan 3 E 151/37/14 (1916)
	1917   => '1315305',            # Mariage Leuhan 3 E 151/37/15 (1917)
	1918   => '1315306',            # Mariage Leuhan 3 E 151/37/16 (1918)
    },

    '3E151_0038' => {			# Mariage Leuhan 3 E 151 38   1919-1936
	1919   => '1315308',            # Mariage Leuhan 3 E 151/38/1 (1919)
	1920   => '1315309',            # Mariage Leuhan 3 E 151/38/2 (1920)
	1921   => '1315310',            # Mariage Leuhan 3 E 151/38/3 (1921)
	1922   => '1315311',            # Mariage Leuhan 3 E 151/38/4 (1922)
	1923   => '1315312',            # Mariage Leuhan 3 E 151/38/5 (1923)
	1924   => '1315313',            # Mariage Leuhan 3 E 151/38/6 (1924)
	1925   => '1315314',            # Mariage Leuhan 3 E 151/38/7 (1925)
	1926   => '1315315',            # Mariage Leuhan 3 E 151/38/8 (1926)
	1927   => '1315316',            # Mariage Leuhan 3 E 151/38/9 (1927)
	1928   => '1315317',            # Mariage Leuhan 3 E 151/38/10 (1928)
	1929   => '1315318',            # Mariage Leuhan 3 E 151/38/11 (1929)
	1930   => '1315319',            # Mariage Leuhan 3 E 151/38/12 (1930)
	1931   => '1315320',            # Mariage Leuhan 3 E 151/38/13 (1931)
	1932   => '1315321',            # Mariage Leuhan 3 E 151/38/14 (1932)
	1933   => '1315322',            # Mariage Leuhan 3 E 151/38/15 (1933)
	1934   => '1315323',            # Mariage Leuhan 3 E 151/38/16 (1934)
	1935   => '1315324',            # Mariage Leuhan 3 E 151/38/17 (1935)
	1936   => '1315325',            # Mariage Leuhan 3 E 151/38/18 (1936)
    },

    '3E151_0039' => {			# Décès Leuhan 3 E 151 39   1910-1920
	1910   => '1315454',            # Décès Leuhan 3 E 151/39/1 (1910)
	1911   => '1315455',            # Décès Leuhan 3 E 151/39/2 (1911)
	1912   => '1315456',            # Décès Leuhan 3 E 151/39/3 (1912)
	1913   => '1315457',            # Décès Leuhan 3 E 151/39/4 (1913)
	1914   => '1315458',            # Décès Leuhan 3 E 151/39/5 (1914)
	1915   => '1315459',            # Décès Leuhan 3 E 151/39/6 (1915)
	1916   => '1315460',            # Décès Leuhan 3 E 151/39/7 (1916)
	1917   => '1315461',            # Décès Leuhan 3 E 151/39/8 (1917)
	1918   => '1315462',            # Décès Leuhan 3 E 151/39/9 (1918)
	1919   => '1315463',            # Décès Leuhan 3 E 151/39/10 (1919)
	1920   => '1315464',            # Décès Leuhan 3 E 151/39/11 (1920)
    },

    '3E151_0040' => {			# Décès Leuhan 3 E 151 40   1921-1936
	1921   => '1315466',            # Décès Leuhan 3 E 151/40/1 (1921)
	1922   => '1315467',            # Décès Leuhan 3 E 151/40/2 (1922)
	1923   => '1315468',            # Décès Leuhan 3 E 151/40/3 (1923)
	1924   => '1315469',            # Décès Leuhan 3 E 151/40/4 (1924)
	1925   => '1315470',            # Décès Leuhan 3 E 151/40/5 (1925)
	1926   => '1315471',            # Décès Leuhan 3 E 151/40/6 (1926)
	1927   => '1315472',            # Décès Leuhan 3 E 151/40/7 (1927)
	1928   => '1315473',            # Décès Leuhan 3 E 151/40/8 (1928)
	1929   => '1315474',            # Décès Leuhan 3 E 151/40/9 (1929)
	1930   => '1315475',            # Décès Leuhan 3 E 151/40/10 (1930)
	1931   => '1315476',            # Décès Leuhan 3 E 151/40/11 (1931)
	1932   => '1315477',            # Décès Leuhan 3 E 151/40/12 (1932)
	1933   => '1315478',            # Décès Leuhan 3 E 151/40/13 (1933)
	1934   => '1315479',            # Décès Leuhan 3 E 151/40/14 (1934)
	1935   => '1315480',            # Décès Leuhan 3 E 151/40/15 (1935)
	1936   => '1315481',            # Décès Leuhan 3 E 151/40/16 (1936)
    },

    # NMD Locmaria-Berrien
    '3E158_0005' => {			# Naissance Locmaria-Berrien 3 E 158 5   AN02-1812
	'AN02' => '1316406',            # Naissance Locmaria-Berrien 3 E 158/5/1 (1793 - an II)
	'AN03' => '1316407',            # Naissance Locmaria-Berrien 3 E 158/5/2 (an III)
	'AN04' => '1316408',            # Naissance Locmaria-Berrien 3 E 158/5/3 (an IV)
	'AN05' => '1316409',            # Naissance Locmaria-Berrien 3 E 158/5/4 (an V)
	'AN06' => '1316410',            # Naissance Locmaria-Berrien 3 E 158/5/5 (an VI)
	'AN07' => '1316411',            # Naissance Locmaria-Berrien 3 E 158/5/6 (an VII)
	'AN08' => '1316412',            # Naissance Locmaria-Berrien 3 E 158/5/7 (an VIII)
	'AN09' => '1316413',            # Naissance Locmaria-Berrien 3 E 158/5/8 (an IX)
	'AN10' => '1316414',            # Naissance Locmaria-Berrien 3 E 158/5/9 (an X)
	'AN11' => '1316415',            # Naissance Locmaria-Berrien 3 E 158/5/10 (an XI)
	'AN12' => '1316416',            # Naissance Locmaria-Berrien 3 E 158/5/11 (an XII)
	'AN13' => '1316417',            # Naissance Locmaria-Berrien 3 E 158/5/12 (an XIII)
	'AN14' => '1316418',            # Naissance Locmaria-Berrien 3 E 158/5/13 (an XIV - 1806)
	1807   => '1316419',            # Naissance Locmaria-Berrien 3 E 158/5/14 (1807)
	1808   => '1316420',            # Naissance Locmaria-Berrien 3 E 158/5/15 (1808)
	1809   => '1316421',            # Naissance Locmaria-Berrien 3 E 158/5/16 (1809)
	1810   => '1316422',            # Naissance Locmaria-Berrien 3 E 158/5/17 (1810)
	1811   => '1316423',            # Naissance Locmaria-Berrien 3 E 158/5/18 (1811)
	1812   => '1316424',            # Naissance Locmaria-Berrien 3 E 158/5/19 (1812)
    },

    '3E158_0006' => {			# Naissance Locmaria-Berrien 3 E 158 6   1813-1832
	1813   => '1316426',            # Naissance Locmaria-Berrien 3 E 158/6/1 (1813)
	1814   => '1316427',            # Naissance Locmaria-Berrien 3 E 158/6/2 (1814)
	1815   => '1316428',            # Naissance Locmaria-Berrien 3 E 158/6/3 (1815)
	1816   => '1316429',            # Naissance Locmaria-Berrien 3 E 158/6/4 (1816)
	1817   => '1316430',            # Naissance Locmaria-Berrien 3 E 158/6/5 (1817)
	1818   => '1316431',            # Naissance Locmaria-Berrien 3 E 158/6/6 (1818)
	1819   => '1316432',            # Naissance Locmaria-Berrien 3 E 158/6/7 (1819)
	1820   => '1316433',            # Naissance Locmaria-Berrien 3 E 158/6/8 (1820)
	1821   => '1316434',            # Naissance Locmaria-Berrien 3 E 158/6/9 (1821)
	1822   => '1316435',            # Naissance Locmaria-Berrien 3 E 158/6/10 (1822)
	1823   => '1316436',            # Naissance Locmaria-Berrien 3 E 158/6/11 (1823)
	1824   => '1316437',            # Naissance Locmaria-Berrien 3 E 158/6/12 (1824)
	1825   => '1316438',            # Naissance Locmaria-Berrien 3 E 158/6/13 (1825)
	1826   => '1316439',            # Naissance Locmaria-Berrien 3 E 158/6/14 (1826)
	1827   => '1316440',            # Naissance Locmaria-Berrien 3 E 158/6/15 (1827)
	1828   => '1316441',            # Naissance Locmaria-Berrien 3 E 158/6/16 (1828)
	1829   => '1316442',            # Naissance Locmaria-Berrien 3 E 158/6/17 (1829)
	1830   => '1316443',            # Naissance Locmaria-Berrien 3 E 158/6/18 (1830)
	1831   => '1316444',            # Naissance Locmaria-Berrien 3 E 158/6/19 (1831)
	1832   => '1316445',            # Naissance Locmaria-Berrien 3 E 158/6/20 (1832)
	1823   => '1316436',            # Naissance Locmaria-Berrien 3 E 158/6/11 (1823)
	1824   => '1316437',            # Naissance Locmaria-Berrien 3 E 158/6/12 (1824)
	1825   => '1316438',            # Naissance Locmaria-Berrien 3 E 158/6/13 (1825)
	1826   => '1316439',            # Naissance Locmaria-Berrien 3 E 158/6/14 (1826)
	1827   => '1316440',            # Naissance Locmaria-Berrien 3 E 158/6/15 (1827)
	1828   => '1316441',            # Naissance Locmaria-Berrien 3 E 158/6/16 (1828)
	1829   => '1316442',            # Naissance Locmaria-Berrien 3 E 158/6/17 (1829)
	1830   => '1316443',            # Naissance Locmaria-Berrien 3 E 158/6/18 (1830)
	1831   => '1316444',            # Naissance Locmaria-Berrien 3 E 158/6/19 (1831)
	1832   => '1316445',            # Naissance Locmaria-Berrien 3 E 158/6/20 (1832)
    },

    '3E158_0007' => {			# Naissance Locmaria-Berrien 3 E 158 7   1833-1842
	1833   => '1316447',            # Naissance Locmaria-Berrien 3 E 158/7/1 (1833)
	1834   => '1316448',            # Naissance Locmaria-Berrien 3 E 158/7/2 (1834)
	1835   => '1316449',            # Naissance Locmaria-Berrien 3 E 158/7/3 (1835)
	1836   => '1316450',            # Naissance Locmaria-Berrien 3 E 158/7/4 (1836)
	1837   => '1316451',            # Naissance Locmaria-Berrien 3 E 158/7/5 (1837)
	1838   => '1316452',            # Naissance Locmaria-Berrien 3 E 158/7/6 (1838)
	1839   => '1316453',            # Naissance Locmaria-Berrien 3 E 158/7/7 (1839)
	1840   => '1316454',            # Naissance Locmaria-Berrien 3 E 158/7/8 (1840)
	1841   => '1316455',            # Naissance Locmaria-Berrien 3 E 158/7/9 (1841)
	1842   => '1316456',            # Naissance Locmaria-Berrien 3 E 158/7/10 (1842)
    },

    '3E158_0008' => {			# Naissance Locmaria-Berrien 3 E 158 8   1843-1852
	1843   => '1316458',            # Naissance Locmaria-Berrien 3 E 158/8/1 (1843)
	1844   => '1316459',            # Naissance Locmaria-Berrien 3 E 158/8/2 (1844)
	1845   => '1316460',            # Naissance Locmaria-Berrien 3 E 158/8/3 (1845)
	1846   => '1316461',            # Naissance Locmaria-Berrien 3 E 158/8/4 (1846)
	1847   => '1316462',            # Naissance Locmaria-Berrien 3 E 158/8/5 (1847)
	1848   => '1316463',            # Naissance Locmaria-Berrien 3 E 158/8/6 (1848)
	1849   => '1316464',            # Naissance Locmaria-Berrien 3 E 158/8/7 (1849)
	1850   => '1316465',            # Naissance Locmaria-Berrien 3 E 158/8/8 (1850)
	1851   => '1316466',            # Naissance Locmaria-Berrien 3 E 158/8/9 (1851)
	1852   => '1316467',            # Naissance Locmaria-Berrien 3 E 158/8/10 (1852)
    },

    '3E158_0009' => {			# Naissance Locmaria-Berrien 3 E 158 9   1853-1862
	1853   => '1316469',            # Naissance Locmaria-Berrien 3 E 158/9/1 (1853)
	1854   => '1316470',            # Naissance Locmaria-Berrien 3 E 158/9/2 (1854)
	1855   => '1316471',            # Naissance Locmaria-Berrien 3 E 158/9/3 (1855)
	1856   => '1316472',            # Naissance Locmaria-Berrien 3 E 158/9/4 (1856)
	1857   => '1316473',            # Naissance Locmaria-Berrien 3 E 158/9/5 (1857)
	1858   => '1316474',            # Naissance Locmaria-Berrien 3 E 158/9/6 (1858)
	1859   => '1316475',            # Naissance Locmaria-Berrien 3 E 158/9/7 (1859)
	1860   => '1316476',            # Naissance Locmaria-Berrien 3 E 158/9/8 (1860)
	1861   => '1316477',            # Naissance Locmaria-Berrien 3 E 158/9/9 (1861)
	1862   => '1316478',            # Naissance Locmaria-Berrien 3 E 158/9/10 (1862)
    },

    '3E158_0010' => {			# Naissance Locmaria-Berrien 3 E 158 10   1863-1869
	1863   => '1316480',            # Naissance Locmaria-Berrien 3 E 158/10/1 (1863)
	1864   => '1316481',            # Naissance Locmaria-Berrien 3 E 158/10/2 (1864)
	1865   => '1316482',            # Naissance Locmaria-Berrien 3 E 158/10/3 (1865)
	1866   => '1316483',            # Naissance Locmaria-Berrien 3 E 158/10/4 (1866)
	1867   => '1316484',            # Naissance Locmaria-Berrien 3 E 158/10/5 (1867)
	1868   => '1316485',            # Naissance Locmaria-Berrien 3 E 158/10/6 (1868)
	1869   => '1316486',            # Naissance Locmaria-Berrien 3 E 158/10/7 (1869)
    },

    '3E158_0011' => {			# Naissance Locmaria-Berrien 3 E 158 11   1870-1882
	1870   => '1316488',            # Naissance Locmaria-Berrien 3 E 158/11/1 (1870)
	1871   => '1316489',            # Naissance Locmaria-Berrien 3 E 158/11/2 (1871)
	1872   => '1316490',            # Naissance Locmaria-Berrien 3 E 158/11/3 (1872)
	1873   => '1316491',            # Naissance Locmaria-Berrien 3 E 158/11/4 (1873)
	1874   => '1316492',            # Naissance Locmaria-Berrien 3 E 158/11/5 (1874)
	1875   => '1316493',            # Naissance Locmaria-Berrien 3 E 158/11/6 (1875)
	1876   => '1316494',            # Naissance Locmaria-Berrien 3 E 158/11/7 (1876)
	1877   => '1316495',            # Naissance Locmaria-Berrien 3 E 158/11/8 (1877)
	1878   => '1316496',            # Naissance Locmaria-Berrien 3 E 158/11/9 (1878)
	1879   => '1316497',            # Naissance Locmaria-Berrien 3 E 158/11/10 (1879)
	1880   => '1316498',            # Naissance Locmaria-Berrien 3 E 158/11/11 (1880)
	1881   => '1316499',            # Naissance Locmaria-Berrien 3 E 158/11/12 (1881)
	1882   => '1316500',            # Naissance Locmaria-Berrien 3 E 158/11/13 (1882)
    },

    '3E158_0012' => {			# Mariage Locmaria-Berrien 3 E 158 12   AN02-1813
	'AN02' => '1316560',            # Mariage Locmaria-Berrien 3 E 158/12/1 (1793 - an II)
	'AN03' => '1316561',            # Mariage Locmaria-Berrien 3 E 158/12/2 (an III)
	'AN04' => '1316562',            # Mariage Locmaria-Berrien 3 E 158/12/3 (an IV)
	'AN05' => '1316563',            # Mariage Locmaria-Berrien 3 E 158/12/4 (an V)
	'AN06' => '1316564',            # Mariage Locmaria-Berrien 3 E 158/12/5 (an VI)
	'AN09' => '1316565',            # Mariage Locmaria-Berrien 3 E 158/12/6 (an IX)
	'AN10' => '1316566',            # Mariage Locmaria-Berrien 3 E 158/12/7 (an X)
	'AN11' => '1316567',            # Mariage Locmaria-Berrien 3 E 158/12/8 (an XI)
	'AN12' => '1316568',            # Mariage Locmaria-Berrien 3 E 158/12/9 (an XII)
	'AN13' => '1316569',            # Mariage Locmaria-Berrien 3 E 158/12/10 (an XIII)
	'AN14' => '1316570',            # Mariage Locmaria-Berrien 3 E 158/12/11 (an XIV - 1806)
	1807   => '1316571',            # Mariage Locmaria-Berrien 3 E 158/12/12 (1807)
	1808   => '1316572',            # Mariage Locmaria-Berrien 3 E 158/12/13 (1808)
	1809   => '1316573',            # Mariage Locmaria-Berrien 3 E 158/12/14 (1809)
	1810   => '1316574',            # Mariage Locmaria-Berrien 3 E 158/12/15 (1810)
	1811   => '1316575',            # Mariage Locmaria-Berrien 3 E 158/12/16 (1811)
	1812   => '1316576',            # Mariage Locmaria-Berrien 3 E 158/12/17 (1812)
	1813   => '1316577',            # Mariage Locmaria-Berrien 3 E 158/12/18 (1813)
    },

    '3E158_0013' => {			# Mariage Locmaria-Berrien 3 E 158 13   1814-1832
	1814   => '1316579',            # Mariage Locmaria-Berrien 3 E 158/13/1 (1814)
	1815   => '1316580',            # Mariage Locmaria-Berrien 3 E 158/13/2 (1815)
	1816   => '1316581',            # Mariage Locmaria-Berrien 3 E 158/13/3 (1816)
	1817   => '1316582',            # Mariage Locmaria-Berrien 3 E 158/13/4 (1817)
	1818   => '1316583',            # Mariage Locmaria-Berrien 3 E 158/13/5 (1818)
	1819   => '1316584',            # Mariage Locmaria-Berrien 3 E 158/13/6 (1819)
	1820   => '1316585',            # Mariage Locmaria-Berrien 3 E 158/13/7 (1820)
	1821   => '1316586',            # Mariage Locmaria-Berrien 3 E 158/13/8 (1821)
	1822   => '1316587',            # Mariage Locmaria-Berrien 3 E 158/13/9 (1822)
	1823   => '1316588',            # Mariage Locmaria-Berrien 3 E 158/13/10 (1823)
	1824   => '1316589',            # Mariage Locmaria-Berrien 3 E 158/13/11 (1824)
	1825   => '1316590',            # Mariage Locmaria-Berrien 3 E 158/13/12 (1825)
	1826   => '1316591',            # Mariage Locmaria-Berrien 3 E 158/13/13 (1826)
	1827   => '1316592',            # Mariage Locmaria-Berrien 3 E 158/13/14 (1827)
	1828   => '1316593',            # Mariage Locmaria-Berrien 3 E 158/13/15 (1828)
	1829   => '1316594',            # Mariage Locmaria-Berrien 3 E 158/13/16 (1829)
	1830   => '1316595',            # Mariage Locmaria-Berrien 3 E 158/13/17 (1830)
	1831   => '1316596',            # Mariage Locmaria-Berrien 3 E 158/13/18 (1831)
	1832   => '1316597',            # Mariage Locmaria-Berrien 3 E 158/13/19 (1832)
    },

    '3E158_0014' => {			# Mariage Locmaria-Berrien 3 E 158 14   1833-1842
	1833   => '1316599',            # Mariage Locmaria-Berrien 3 E 158/14/1 (1833)
	1834   => '1316600',            # Mariage Locmaria-Berrien 3 E 158/14/2 (1834)
	1835   => '1316601',            # Mariage Locmaria-Berrien 3 E 158/14/3 (1835)
	1836   => '1316602',            # Mariage Locmaria-Berrien 3 E 158/14/4 (1836)
	1837   => '1316603',            # Mariage Locmaria-Berrien 3 E 158/14/5 (1837)
	1838   => '1316604',            # Mariage Locmaria-Berrien 3 E 158/14/6 (1838)
	1839   => '1316605',            # Mariage Locmaria-Berrien 3 E 158/14/7 (1839)
	1840   => '1316606',            # Mariage Locmaria-Berrien 3 E 158/14/8 (1840)
	1841   => '1316607',            # Mariage Locmaria-Berrien 3 E 158/14/9 (1841)
	1842   => '1316608',            # Mariage Locmaria-Berrien 3 E 158/14/10 (1842)
    },

    '3E158_0015' => {			# Mariage Locmaria-Berrien 3 E 158 15   1843-1852
	1843   => '1316610',            # Mariage Locmaria-Berrien 3 E 158/15/1 (1843)
	1844   => '1316611',            # Mariage Locmaria-Berrien 3 E 158/15/2 (1844)
	1845   => '1316612',            # Mariage Locmaria-Berrien 3 E 158/15/3 (1845)
	1846   => '1316613',            # Mariage Locmaria-Berrien 3 E 158/15/4 (1846)
	1847   => '1316614',            # Mariage Locmaria-Berrien 3 E 158/15/5 (1847)
	1848   => '1316615',            # Mariage Locmaria-Berrien 3 E 158/15/6 (1848)
	1849   => '1316616',            # Mariage Locmaria-Berrien 3 E 158/15/7 (1849)
	1850   => '1316617',            # Mariage Locmaria-Berrien 3 E 158/15/8 (1850)
	1851   => '1316618',            # Mariage Locmaria-Berrien 3 E 158/15/9 (1851)
	1852   => '1316619',            # Mariage Locmaria-Berrien 3 E 158/15/10 (1852)
    },

    '3E158_0016' => {			# Mariage Locmaria-Berrien 3 E 158 16   1853-1862
	1853   => '1316621',            # Mariage Locmaria-Berrien 3 E 158/16/1 (1853)
	1854   => '1316622',            # Mariage Locmaria-Berrien 3 E 158/16/2 (1854)
	1855   => '1316623',            # Mariage Locmaria-Berrien 3 E 158/16/3 (1855)
	1856   => '1316624',            # Mariage Locmaria-Berrien 3 E 158/16/4 (1856)
	1857   => '1316625',            # Mariage Locmaria-Berrien 3 E 158/16/5 (1857)
	1858   => '1316626',            # Mariage Locmaria-Berrien 3 E 158/16/6 (1858)
	1859   => '1316627',            # Mariage Locmaria-Berrien 3 E 158/16/7 (1859)
	1860   => '1316628',            # Mariage Locmaria-Berrien 3 E 158/16/8 (1860)
	1861   => '1316629',            # Mariage Locmaria-Berrien 3 E 158/16/9 (1861)
	1862   => '1316630',            # Mariage Locmaria-Berrien 3 E 158/16/10 (1862)
    },

    '3E158_0017' => {			# Mariage Locmaria-Berrien 3 E 158 17   1863-1869
	1863   => '1316632',            # Mariage Locmaria-Berrien 3 E 158/17/1 (1863)
	1864   => '1316633',            # Mariage Locmaria-Berrien 3 E 158/17/2 (1864)
	1865   => '1316634',            # Mariage Locmaria-Berrien 3 E 158/17/3 (1865)
	1866   => '1316635',            # Mariage Locmaria-Berrien 3 E 158/17/4 (1866)
	1867   => '1316636',            # Mariage Locmaria-Berrien 3 E 158/17/5 (1867)
	1868   => '1316637',            # Mariage Locmaria-Berrien 3 E 158/17/6 (1868)
	1869   => '1316638',            # Mariage Locmaria-Berrien 3 E 158/17/7 (1869)
    },

    '3E158_0018' => {			# Mariage Locmaria-Berrien 3 E 158 18   1870-1890
	1870   => '1316640',            # Mariage Locmaria-Berrien 3 E 158/18/1 (1870)
	1871   => '1316641',            # Mariage Locmaria-Berrien 3 E 158/18/2 (1871)
	1872   => '1316642',            # Mariage Locmaria-Berrien 3 E 158/18/3 (1872)
	1873   => '1316643',            # Mariage Locmaria-Berrien 3 E 158/18/4 (1873)
	1874   => '1316644',            # Mariage Locmaria-Berrien 3 E 158/18/5 (1874)
	1875   => '1316645',            # Mariage Locmaria-Berrien 3 E 158/18/6 (1875)
	1876   => '1316646',            # Mariage Locmaria-Berrien 3 E 158/18/7 (1876)
	1877   => '1316647',            # Mariage Locmaria-Berrien 3 E 158/18/8 (1877)
	1878   => '1316648',            # Mariage Locmaria-Berrien 3 E 158/18/9 (1878)
	1879   => '1316649',            # Mariage Locmaria-Berrien 3 E 158/18/10 (1879)
	1880   => '1316650',            # Mariage Locmaria-Berrien 3 E 158/18/11 (1880)
	1881   => '1316651',            # Mariage Locmaria-Berrien 3 E 158/18/12 (1881)
	1882   => '1316652',            # Mariage Locmaria-Berrien 3 E 158/18/13 (1882)
	1883   => '1316653',            # Mariage Locmaria-Berrien 3 E 158/18/14 (1883)
	1884   => '1316654',            # Mariage Locmaria-Berrien 3 E 158/18/15 (1884)
	1885   => '1316655',            # Mariage Locmaria-Berrien 3 E 158/18/16 (1885)
	1886   => '1316656',            # Mariage Locmaria-Berrien 3 E 158/18/17 (1886)
	1887   => '1316657',            # Mariage Locmaria-Berrien 3 E 158/18/18 (1887)
	1888   => '1316658',            # Mariage Locmaria-Berrien 3 E 158/18/19 (1888)
	1889   => '1316659',            # Mariage Locmaria-Berrien 3 E 158/18/20 (1889)
	1890   => '1316660',            # Mariage Locmaria-Berrien 3 E 158/18/21 (1890)
    },

    '3E158_0019' => {			# Décès Locmaria-Berrien 3 E 158 19   AN02-1812
	'AN02' => '1316711',            # Décès Locmaria-Berrien 3 E 158/19/1 (1793 - an II)
	'AN03' => '1316712',            # Décès Locmaria-Berrien 3 E 158/19/2 (an III)
	'AN04' => '1316713',            # Décès Locmaria-Berrien 3 E 158/19/3 (an IV)
	'AN05' => '1316714',            # Décès Locmaria-Berrien 3 E 158/19/4 (an V)
	'AN06' => '1316715',            # Décès Locmaria-Berrien 3 E 158/19/5 (an VI)
	'AN07' => '1316716',            # Décès Locmaria-Berrien 3 E 158/19/6 (an VII)
	'AN08' => '1316717',            # Décès Locmaria-Berrien 3 E 158/19/7 (an VIII)
	'AN09' => '1316718',            # Décès Locmaria-Berrien 3 E 158/19/8 (an IX)
	'AN10' => '1316719',            # Décès Locmaria-Berrien 3 E 158/19/9 (an X)
	'AN11' => '1316720',            # Décès Locmaria-Berrien 3 E 158/19/10 (an XI)
	'AN12' => '1316721',            # Décès Locmaria-Berrien 3 E 158/19/11 (an XII)
	'AN13' => '1316722',            # Décès Locmaria-Berrien 3 E 158/19/12 (an XIII)
	'AN14' => '1316723',            # Décès Locmaria-Berrien 3 E 158/19/13 (an XIV - 1806)
	1807   => '1316724',            # Décès Locmaria-Berrien 3 E 158/19/14 (1807)
	1808   => '1316725',            # Décès Locmaria-Berrien 3 E 158/19/15 (1808)
	1809   => '1316726',            # Décès Locmaria-Berrien 3 E 158/19/16 (1809)
	1810   => '1316727',            # Décès Locmaria-Berrien 3 E 158/19/17 (1810)
	1811   => '1316728',            # Décès Locmaria-Berrien 3 E 158/19/18 (1811)
	1812   => '1316729',            # Décès Locmaria-Berrien 3 E 158/19/19 (1812)
    },

    '3E158_0020' => {			# Décès Locmaria-Berrien 3 E 158 20   1813-1832
	1813   => '1316731',            # Décès Locmaria-Berrien 3 E 158/20/1 (1813)
	1814   => '1316732',            # Décès Locmaria-Berrien 3 E 158/20/2 (1814)
	1815   => '1316733',            # Décès Locmaria-Berrien 3 E 158/20/3 (1815)
	1816   => '1316734',            # Décès Locmaria-Berrien 3 E 158/20/4 (1816)
	1817   => '1316735',            # Décès Locmaria-Berrien 3 E 158/20/5 (1817)
	1818   => '1316736',            # Décès Locmaria-Berrien 3 E 158/20/6 (1818)
	1819   => '1316737',            # Décès Locmaria-Berrien 3 E 158/20/7 (1819)
	1820   => '1316738',            # Décès Locmaria-Berrien 3 E 158/20/8 (1820)
	1821   => '1316739',            # Décès Locmaria-Berrien 3 E 158/20/9 (1821)
	1822   => '1316740',            # Décès Locmaria-Berrien 3 E 158/20/10 (1822)
	1823   => '1316741',            # Décès Locmaria-Berrien 3 E 158/20/11 (1823)
	1824   => '1316742',            # Décès Locmaria-Berrien 3 E 158/20/12 (1824)
	1825   => '1316743',            # Décès Locmaria-Berrien 3 E 158/20/13 (1825)
	1826   => '1316744',            # Décès Locmaria-Berrien 3 E 158/20/14 (1826)
	1827   => '1316745',            # Décès Locmaria-Berrien 3 E 158/20/15 (1827)
	1828   => '1316746',            # Décès Locmaria-Berrien 3 E 158/20/16 (1828)
	1829   => '1316747',            # Décès Locmaria-Berrien 3 E 158/20/17 (1829)
	1830   => '1316748',            # Décès Locmaria-Berrien 3 E 158/20/18 (1830)
	1831   => '1316749',            # Décès Locmaria-Berrien 3 E 158/20/19 (1831)
	1832   => '1316750',            # Décès Locmaria-Berrien 3 E 158/20/20 (1832)
    },

    '3E158_0021' => {			# Décès Locmaria-Berrien 3 E 158 21   1833-1842
	1833   => '1316752',            # Décès Locmaria-Berrien 3 E 158/21/1 (1833)
	1834   => '1316753',            # Décès Locmaria-Berrien 3 E 158/21/2 (1834)
	1835   => '1316754',            # Décès Locmaria-Berrien 3 E 158/21/3 (1835)
	1836   => '1316755',            # Décès Locmaria-Berrien 3 E 158/21/4 (1836)
	1837   => '1316756',            # Décès Locmaria-Berrien 3 E 158/21/5 (1837)
	1838   => '1316757',            # Décès Locmaria-Berrien 3 E 158/21/6 (1838)
	1839   => '1316758',            # Décès Locmaria-Berrien 3 E 158/21/7 (1839)
	1840   => '1316759',            # Décès Locmaria-Berrien 3 E 158/21/8 (1840)
	1841   => '1316760',            # Décès Locmaria-Berrien 3 E 158/21/9 (1841)
	1842   => '1316761',            # Décès Locmaria-Berrien 3 E 158/21/10 (1842)
    },

    '3E158_0022' => {			# Décès Locmaria-Berrien 3 E 158 22   1843-1852
	1843   => '1316763',            # Décès Locmaria-Berrien 3 E 158/22/1 (1843)
	1844   => '1316764',            # Décès Locmaria-Berrien 3 E 158/22/2 (1844)
	1845   => '1316765',            # Décès Locmaria-Berrien 3 E 158/22/3 (1845)
	1846   => '1316766',            # Décès Locmaria-Berrien 3 E 158/22/4 (1846)
	1847   => '1316767',            # Décès Locmaria-Berrien 3 E 158/22/5 (1847)
	1848   => '1316768',            # Décès Locmaria-Berrien 3 E 158/22/6 (1848)
	1849   => '1316769',            # Décès Locmaria-Berrien 3 E 158/22/7 (1849)
	1850   => '1316770',            # Décès Locmaria-Berrien 3 E 158/22/8 (1850)
	1851   => '1316771',            # Décès Locmaria-Berrien 3 E 158/22/9 (1851)
	1852   => '1316772',            # Décès Locmaria-Berrien 3 E 158/22/10 (1852)
    },

    '3E158_0023' => {			# Décès Locmaria-Berrien 3 E 158 23   1853-1862
	1853   => '1316774',            # Décès Locmaria-Berrien 3 E 158/23/1 (1853)
	1854   => '1316775',            # Décès Locmaria-Berrien 3 E 158/23/2 (1854)
	1855   => '1316776',            # Décès Locmaria-Berrien 3 E 158/23/3 (1855)
	1856   => '1316777',            # Décès Locmaria-Berrien 3 E 158/23/4 (1856)
	1857   => '1316778',            # Décès Locmaria-Berrien 3 E 158/23/5 (1857)
	1858   => '1316779',            # Décès Locmaria-Berrien 3 E 158/23/6 (1858)
	1859   => '1316780',            # Décès Locmaria-Berrien 3 E 158/23/7 (1859)
	1860   => '1316781',            # Décès Locmaria-Berrien 3 E 158/23/8 (1860)
	1861   => '1316782',            # Décès Locmaria-Berrien 3 E 158/23/9 (1861)
	1862   => '1316783',            # Décès Locmaria-Berrien 3 E 158/23/10 (1862)
    },

    '3E158_0024' => {			# Décès Locmaria-Berrien 3 E 158 24   1863-1869
	1863   => '1316785',            # Décès Locmaria-Berrien 3 E 158/24/1 (1863)
	1864   => '1316786',            # Décès Locmaria-Berrien 3 E 158/24/2 (1864)
	1865   => '1316787',            # Décès Locmaria-Berrien 3 E 158/24/3 (1865)
	1866   => '1316788',            # Décès Locmaria-Berrien 3 E 158/24/4 (1866)
	1867   => '1316789',            # Décès Locmaria-Berrien 3 E 158/24/5 (1867)
	1868   => '1316790',            # Décès Locmaria-Berrien 3 E 158/24/6 (1868)
	1869   => '1316791',            # Décès Locmaria-Berrien 3 E 158/24/7 (1869)
    },

    '3E158_0025' => {			# Décès Locmaria-Berrien 3 E 158 25   1870-1887
	1870   => '1316793',            # Décès Locmaria-Berrien 3 E 158/25/1 (1870)
	1871   => '1316794',            # Décès Locmaria-Berrien 3 E 158/25/2 (1871)
	1872   => '1316795',            # Décès Locmaria-Berrien 3 E 158/25/3 (1872)
	1873   => '1316796',            # Décès Locmaria-Berrien 3 E 158/25/4 (1873)
	1874   => '1316797',            # Décès Locmaria-Berrien 3 E 158/25/5 (1874)
	1875   => '1316798',            # Décès Locmaria-Berrien 3 E 158/25/6 (1875)
	1876   => '1316799',            # Décès Locmaria-Berrien 3 E 158/25/7 (1876)
	1877   => '1316800',            # Décès Locmaria-Berrien 3 E 158/25/8 (1877)
	1878   => '1316801',            # Décès Locmaria-Berrien 3 E 158/25/9 (1878)
	1879   => '1316802',            # Décès Locmaria-Berrien 3 E 158/25/10 (1879)
	1880   => '1316803',            # Décès Locmaria-Berrien 3 E 158/25/11 (1880)
	1881   => '1316804',            # Décès Locmaria-Berrien 3 E 158/25/12 (1881)
	1882   => '1316805',            # Décès Locmaria-Berrien 3 E 158/25/13 (1882)
	1883   => '1316806',            # Décès Locmaria-Berrien 3 E 158/25/14 (1883)
	1884   => '1316807',            # Décès Locmaria-Berrien 3 E 158/25/15 (1884)
	1885   => '1316808',            # Décès Locmaria-Berrien 3 E 158/25/16 (1885)
	1886   => '1316809',            # Décès Locmaria-Berrien 3 E 158/25/17 (1886)
	1887   => '1316810',            # Décès Locmaria-Berrien 3 E 158/25/18 (1887)
    },

    '3E158_0026' => {			# Naissance Locmaria-Berrien 3 E 158 26   1883-1899
	1883   => '1316502',            # Naissance Locmaria-Berrien 3 E 158/26/1 (1883)
	1884   => '1316503',            # Naissance Locmaria-Berrien 3 E 158/26/2 (1884)
	1885   => '1316504',            # Naissance Locmaria-Berrien 3 E 158/26/3 (1885)
	1886   => '1316505',            # Naissance Locmaria-Berrien 3 E 158/26/4 (1886)
	1887   => '1316506',            # Naissance Locmaria-Berrien 3 E 158/26/5 (1887)
	1888   => '1316507',            # Naissance Locmaria-Berrien 3 E 158/26/6 (1888)
	1889   => '1316508',            # Naissance Locmaria-Berrien 3 E 158/26/7 (1889)
	1890   => '1316509',            # Naissance Locmaria-Berrien 3 E 158/26/8 (1890)
	1891   => '1316510',            # Naissance Locmaria-Berrien 3 E 158/26/9 (1891)
	1892   => '1316511',            # Naissance Locmaria-Berrien 3 E 158/26/10 (1892)
	1893   => '1316512',            # Naissance Locmaria-Berrien 3 E 158/26/11 (1893)
	1894   => '1316513',            # Naissance Locmaria-Berrien 3 E 158/26/12 (1894)
	1895   => '1316514',            # Naissance Locmaria-Berrien 3 E 158/26/13 (1895)
	1896   => '1316515',            # Naissance Locmaria-Berrien 3 E 158/26/14 (1896)
	1897   => '1316516',            # Naissance Locmaria-Berrien 3 E 158/26/15 (1897)
	1898   => '1316517',            # Naissance Locmaria-Berrien 3 E 158/26/16 (1898)
	1899   => '1316518',            # Naissance Locmaria-Berrien 3 E 158/26/17 (1899)
    },

    '3E158_0027' => {			# Naissance Locmaria-Berrien 3 E 158 27   1900-1918
	1900   => '1316520',            # Naissance Locmaria-Berrien 3 E 158/27/1 (1900)
	1901   => '1316521',            # Naissance Locmaria-Berrien 3 E 158/27/2 (1901)
	1902   => '1316522',            # Naissance Locmaria-Berrien 3 E 158/27/3 (1902)
	1903   => '1316523',            # Naissance Locmaria-Berrien 3 E 158/27/4 (1903)
	1904   => '1316524',            # Naissance Locmaria-Berrien 3 E 158/27/5 (1904)
	1905   => '1316525',            # Naissance Locmaria-Berrien 3 E 158/27/6 (1905)
	1906   => '1316526',            # Naissance Locmaria-Berrien 3 E 158/27/7 (1906)
	1907   => '1316527',            # Naissance Locmaria-Berrien 3 E 158/27/8 (1907)
	1908   => '1316528',            # Naissance Locmaria-Berrien 3 E 158/27/9 (1908)
	1909   => '1316529',            # Naissance Locmaria-Berrien 3 E 158/27/10 (1909)
	1910   => '1316530',            # Naissance Locmaria-Berrien 3 E 158/27/11 (1910)
	1911   => '1316531',            # Naissance Locmaria-Berrien 3 E 158/27/12 (1911)
	1912   => '1316532',            # Naissance Locmaria-Berrien 3 E 158/27/13 (1912)
	1913   => '1316533',            # Naissance Locmaria-Berrien 3 E 158/27/14 (1913)
	1914   => '1316534',            # Naissance Locmaria-Berrien 3 E 158/27/15 (1914)
	1915   => '1316535',            # Naissance Locmaria-Berrien 3 E 158/27/16 (1915)
	1916   => '1316536',            # Naissance Locmaria-Berrien 3 E 158/27/17 (1916)
	1917   => '1316537',            # Naissance Locmaria-Berrien 3 E 158/27/18 (1917)
	1918   => '1316538',            # Naissance Locmaria-Berrien 3 E 158/27/19 (1918)
    },

    '3E158_0028' => {			# Naissance Locmaria-Berrien 3 E 158 28   1919-1925
	1919   => '1316540',            # Naissance Locmaria-Berrien 3 E 158/28/1 (1919)
	1920   => '1316541',            # Naissance Locmaria-Berrien 3 E 158/28/2 (1920)
	1921   => '1316542',            # Naissance Locmaria-Berrien 3 E 158/28/3 (1921)
	1922   => '1316543',            # Naissance Locmaria-Berrien 3 E 158/28/4 (1922)
	1923   => '1316544',            # Naissance Locmaria-Berrien 3 E 158/28/5 (1923)
	1924   => '1316545',            # Naissance Locmaria-Berrien 3 E 158/28/6 (1924)
	1925   => '1316546',            # Naissance Locmaria-Berrien 3 E 158/28/7 (1925)
    },

    '3E158_0029' => {			# Mariage Locmaria-Berrien 3 E 158 29   1891-1911
	1891   => '1316662',            # Mariage Locmaria-Berrien 3 E 158/29/1 (1891)
	1892   => '1316663',            # Mariage Locmaria-Berrien 3 E 158/29/2 (1892)
	1893   => '1316664',            # Mariage Locmaria-Berrien 3 E 158/29/3 (1893)
	1894   => '1316665',            # Mariage Locmaria-Berrien 3 E 158/29/4 (1894)
	1895   => '1316666',            # Mariage Locmaria-Berrien 3 E 158/29/5 (1895)
	1896   => '1316667',            # Mariage Locmaria-Berrien 3 E 158/29/6 (1896)
	1897   => '1316668',            # Mariage Locmaria-Berrien 3 E 158/29/7 (1897)
	1898   => '1316669',            # Mariage Locmaria-Berrien 3 E 158/29/8 (1898)
	1899   => '1316670',            # Mariage Locmaria-Berrien 3 E 158/29/9 (1899)
	1900   => '1316671',            # Mariage Locmaria-Berrien 3 E 158/29/10 (1900)
	1901   => '1316672',            # Mariage Locmaria-Berrien 3 E 158/29/11 (1901)
	1902   => '1316673',            # Mariage Locmaria-Berrien 3 E 158/29/12 (1902)
	1903   => '1316674',            # Mariage Locmaria-Berrien 3 E 158/29/13 (1903)
	1904   => '1316675',            # Mariage Locmaria-Berrien 3 E 158/29/14 (1904)
	1905   => '1316676',            # Mariage Locmaria-Berrien 3 E 158/29/15 (1905)
	1906   => '1316677',            # Mariage Locmaria-Berrien 3 E 158/29/16 (1906)
	1907   => '1316678',            # Mariage Locmaria-Berrien 3 E 158/29/17 (1907)
	1908   => '1316679',            # Mariage Locmaria-Berrien 3 E 158/29/18 (1908)
	1909   => '1316680',            # Mariage Locmaria-Berrien 3 E 158/29/19 (1909)
	1910   => '1316681',            # Mariage Locmaria-Berrien 3 E 158/29/20 (1910)
	1911   => '1316682',            # Mariage Locmaria-Berrien 3 E 158/29/21 (1911)
    },

    '3E158_0030' => {			# Mariage Locmaria-Berrien 3 E 158 30   1912-1936
	1912   => '1316684',            # Mariage Locmaria-Berrien 3 E 158/30/1 (1912)
	1913   => '1316685',            # Mariage Locmaria-Berrien 3 E 158/30/2 (1913)
	1914   => '1316686',            # Mariage Locmaria-Berrien 3 E 158/30/3 (1914)
	1915   => '1316687',            # Mariage Locmaria-Berrien 3 E 158/30/4 (1915)
	1916   => '1316688',            # Mariage Locmaria-Berrien 3 E 158/30/5 (1916)
	1917   => '1316689',            # Mariage Locmaria-Berrien 3 E 158/30/6 (1917)
	1918   => '1316690',            # Mariage Locmaria-Berrien 3 E 158/30/7 (1918)
	1919   => '1316691',            # Mariage Locmaria-Berrien 3 E 158/30/8 (1919)
	1920   => '1316692',            # Mariage Locmaria-Berrien 3 E 158/30/9 (1920)
	1921   => '1316693',            # Mariage Locmaria-Berrien 3 E 158/30/10 (1921)
	1922   => '1316694',            # Mariage Locmaria-Berrien 3 E 158/30/11 (1922)
	1923   => '1316695',            # Mariage Locmaria-Berrien 3 E 158/30/12 (1923)
	1924   => '1316696',            # Mariage Locmaria-Berrien 3 E 158/30/13 (1924)
	1925   => '1316697',            # Mariage Locmaria-Berrien 3 E 158/30/14 (1925)
	1926   => '1316698',            # Mariage Locmaria-Berrien 3 E 158/30/15 (1926)
	1927   => '1316699',            # Mariage Locmaria-Berrien 3 E 158/30/16 (1927)
	1928   => '1316700',            # Mariage Locmaria-Berrien 3 E 158/30/17 (1928)
	1929   => '1316701',            # Mariage Locmaria-Berrien 3 E 158/30/18 (1929)
	1930   => '1316702',            # Mariage Locmaria-Berrien 3 E 158/30/19 (1930)
	1931   => '1316703',            # Mariage Locmaria-Berrien 3 E 158/30/20 (1931)
	1932   => '1316704',            # Mariage Locmaria-Berrien 3 E 158/30/21 (1932)
	1933   => '1316705',            # Mariage Locmaria-Berrien 3 E 158/30/22 (1933)
	1934   => '1316706',            # Mariage Locmaria-Berrien 3 E 158/30/23 (1934)
	1935   => '1316707',            # Mariage Locmaria-Berrien 3 E 158/30/24 (1935)
	1936   => '1316708',            # Mariage Locmaria-Berrien 3 E 158/30/25 (1936)
    },

    '3E158_0031' => {			# Décès Locmaria-Berrien 3 E 158 31   1888-1911
	1888   => '1316812',            # Décès Locmaria-Berrien 3 E 158/31/1 (1888)
	1889   => '1316813',            # Décès Locmaria-Berrien 3 E 158/31/2 (1889)
	1890   => '1316814',            # Décès Locmaria-Berrien 3 E 158/31/3 (1890)
	1891   => '1316815',            # Décès Locmaria-Berrien 3 E 158/31/4 (1891)
	1892   => '1316816',            # Décès Locmaria-Berrien 3 E 158/31/5 (1892)
	1893   => '1316817',            # Décès Locmaria-Berrien 3 E 158/31/6 (1893)
	1894   => '1316818',            # Décès Locmaria-Berrien 3 E 158/31/7 (1894)
	1895   => '1316819',            # Décès Locmaria-Berrien 3 E 158/31/8 (1895)
	1896   => '1316820',            # Décès Locmaria-Berrien 3 E 158/31/9 (1896)
	1897   => '1316821',            # Décès Locmaria-Berrien 3 E 158/31/10 (1897)
	1898   => '1316822',            # Décès Locmaria-Berrien 3 E 158/31/11 (1898)
	1899   => '1316823',            # Décès Locmaria-Berrien 3 E 158/31/12 (1899)
	1900   => '1316824',            # Décès Locmaria-Berrien 3 E 158/31/13 (1900)
	1901   => '1316825',            # Décès Locmaria-Berrien 3 E 158/31/14 (1901)
	1902   => '1316826',            # Décès Locmaria-Berrien 3 E 158/31/15 (1902)
	1903   => '1316827',            # Décès Locmaria-Berrien 3 E 158/31/16 (1903)
	1904   => '1316828',            # Décès Locmaria-Berrien 3 E 158/31/17 (1904)
	1905   => '1316829',            # Décès Locmaria-Berrien 3 E 158/31/18 (1905)
	1906   => '1316830',            # Décès Locmaria-Berrien 3 E 158/31/19 (1906)
	1907   => '1316831',            # Décès Locmaria-Berrien 3 E 158/31/20 (1907)
	1908   => '1316832',            # Décès Locmaria-Berrien 3 E 158/31/21 (1908)
	1909   => '1316833',            # Décès Locmaria-Berrien 3 E 158/31/22 (1909)
	1910   => '1316834',            # Décès Locmaria-Berrien 3 E 158/31/23 (1910)
	1911   => '1316835',            # Décès Locmaria-Berrien 3 E 158/31/24 (1911)
    },

    '3E158_0032' => {			# Décès Locmaria-Berrien 3 E 158 32   1912-1936
	1912   => '1316837',            # Décès Locmaria-Berrien 3 E 158/32/1 (1912)
	1913   => '1316838',            # Décès Locmaria-Berrien 3 E 158/32/2 (1913)
	1914   => '1316839',            # Décès Locmaria-Berrien 3 E 158/32/3 (1914)
	1915   => '1316840',            # Décès Locmaria-Berrien 3 E 158/32/4 (1915)
	1916   => '1316841',            # Décès Locmaria-Berrien 3 E 158/32/5 (1916)
	1917   => '1316842',            # Décès Locmaria-Berrien 3 E 158/32/6 (1917)
	1918   => '1316843',            # Décès Locmaria-Berrien 3 E 158/32/7 (1918)
	1919   => '1316844',            # Décès Locmaria-Berrien 3 E 158/32/8 (1919)
	1920   => '1316845',            # Décès Locmaria-Berrien 3 E 158/32/9 (1920)
	1921   => '1316846',            # Décès Locmaria-Berrien 3 E 158/32/10 (1921)
	1922   => '1316847',            # Décès Locmaria-Berrien 3 E 158/32/11 (1922)
	1923   => '1316848',            # Décès Locmaria-Berrien 3 E 158/32/12 (1923)
	1924   => '1316849',            # Décès Locmaria-Berrien 3 E 158/32/13 (1924)
	1925   => '1316850',            # Décès Locmaria-Berrien 3 E 158/32/14 (1925)
	1926   => '1316851',            # Décès Locmaria-Berrien 3 E 158/32/15 (1926)
	1927   => '1316852',            # Décès Locmaria-Berrien 3 E 158/32/16 (1927)
	1928   => '1316853',            # Décès Locmaria-Berrien 3 E 158/32/17 (1928)
	1929   => '1316854',            # Décès Locmaria-Berrien 3 E 158/32/18 (1929)
	1930   => '1316855',            # Décès Locmaria-Berrien 3 E 158/32/19 (1930)
	1931   => '1316856',            # Décès Locmaria-Berrien 3 E 158/32/20 (1931)
	1932   => '1316857',            # Décès Locmaria-Berrien 3 E 158/32/21 (1932)
	1933   => '1316858',            # Décès Locmaria-Berrien 3 E 158/32/22 (1933)
	1934   => '1316859',            # Décès Locmaria-Berrien 3 E 158/32/23 (1934)
	1935   => '1316860',            # Décès Locmaria-Berrien 3 E 158/32/24 (1935)
	1936   => '1316861',            # Décès Locmaria-Berrien 3 E 158/32/25 (1936)
    },

    # NMD Melgven
    '3E177_0005' => '657111.1323001',            # Naissance Melgven 3 E 177 5 (1793-1811)
    '3E177_0006' => '657112.1323002',            # Naissance Melgven 3 E 177 6 (1812-1832)
    '3E177_0007' => '657113.1323003',            # Naissance Melgven 3 E 177 7 (1833-1852)
    '3E177_0008' => '657114.1323004',            # Naissance Melgven 3 E 177 8 (1853-1862)
    '3E177_0009' => '657115.1323005',            # Naissance Melgven 3 E 177 9 (1863-1869)
    '3E177_0010' => '657116.1323006',            # Naissance Melgven 3 E 177 10 (1870-1881)
    '3E177_0011' => '657117.1323007',            # Naissance Melgven 3 E 177 11 (1882-1892)
    '3E177_0012' => '657118.1323049',            # Mariage publication de mariage promesse de mariage Melgven 3 E 177 12 (1793-an VI, an IX-1812)
    '3E177_0013' => '657119.1323050',            # Mariage Melgven 3 E 177 13 (1813-1832)
    '3E177_0014' => '657120.1323051',            # Mariage Melgven 3 E 177 14 (1833-1852)
    '3E177_0015' => '657121.1323052',            # Mariage Melgven 3 E 177 15 (1853-1862)
    '3E177_0016' => '657122.1323053',            # Mariage Melgven 3 E 177 16 (1863-1869)
    '3E177_0017' => '657123.1323054',            # Mariage Melgven 3 E 177 17 (1870-1881)
    '3E177_0018' => '657124.1323055',            # Mariage Melgven 3 E 177 18 (1882-1893)
    '3E177_0019' => '657125.1323116',            # Décès Melgven 3 E 177 19 (1793-an II, an IV-an V (incomplets), an VI-an VIII (incomplet), an IX-1812)
    '3E177_0020' => '657126.1323117',            # Décès Melgven 3 E 177 20 (1813-1832)
    '3E177_0021' => '657127.1323118',            # Décès Melgven 3 E 177 21 (1833-1852)
    '3E177_0022' => '657128.1323119',            # Décès Melgven 3 E 177 22 (1853-1862)
    '3E177_0023' => '657129.1323120',            # Décès Melgven 3 E 177 23 (1863-1869)
    '3E177_0024' => '657130.1323121',            # Décès Melgven 3 E 177 24 (1870-1887)
    '3E177_0025' => '657131.1323008',            # Naissance Melgven 3 E 177 25 (1893-1901)
    '3E177_0026' => '657132.1323122',            # Décès Melgven 3 E 177 26 (1888-1901)
    '3E177_0027' => {			# Mariage Melgven 3 E 177 27   1894-1904
	1894   => '1323057',            # Mariage Melgven 3 E 177/27/1 (1894)
	1895   => '1323058',            # Mariage Melgven 3 E 177/27/2 (1895)
	1896   => '1323059',            # Mariage Melgven 3 E 177/27/3 (1896)
	1897   => '1323060',            # Mariage Melgven 3 E 177/27/4 (1897)
	1898   => '1323061',            # Mariage Melgven 3 E 177/27/5 (1898)
	1899   => '1323062',            # Mariage Melgven 3 E 177/27/6 (1899)
	1900   => '1323063',            # Mariage Melgven 3 E 177/27/7 (1900)
	1901   => '1323064',            # Mariage Melgven 3 E 177/27/8 (1901)
	1902   => '1323065',            # Mariage Melgven 3 E 177/27/9 (1902)
	1903   => '1323066',            # Mariage Melgven 3 E 177/27/10 (1903)
	1904   => '1323067',            # Mariage Melgven 3 E 177/27/11 (1904)
    },

    '3E177_0028' => {			# Naissance Melgven 3 E 177 28   1902-1911
	1902   => '1323010',            # Naissance Melgven 3 E 177/28/1 (1902)
	1903   => '1323011',            # Naissance Melgven 3 E 177/28/2 (1903)
	1904   => '1323012',            # Naissance Melgven 3 E 177/28/3 (1904)
	1905   => '1323013',            # Naissance Melgven 3 E 177/28/4 (1905)
	1906   => '1323014',            # Naissance Melgven 3 E 177/28/5 (1906)
	1907   => '1323015',            # Naissance Melgven 3 E 177/28/6 (1907)
	1908   => '1323016',            # Naissance Melgven 3 E 177/28/7 (1908)
	1909   => '1323017',            # Naissance Melgven 3 E 177/28/8 (1909)
	1910   => '1323018',            # Naissance Melgven 3 E 177/28/9 (1910)
	1911   => '1323019',            # Naissance Melgven 3 E 177/28/10 (1911)
    },

    '3E177_0029' => {			# Mariage Melgven 3 E 177 29   1905-1913
	1905   => '1323069',            # Mariage Melgven 3 E 177/29/1 (1905)
	1906   => '1323070',            # Mariage Melgven 3 E 177/29/2 (1906)
	1907   => '1323071',            # Mariage Melgven 3 E 177/29/3 (1907)
	1908   => '1323072',            # Mariage Melgven 3 E 177/29/4 (1908)
	1909   => '1323073',            # Mariage Melgven 3 E 177/29/5 (1909)
	1910   => '1323074',            # Mariage Melgven 3 E 177/29/6 (1910)
	1911   => '1323075',            # Mariage Melgven 3 E 177/29/7 (1911)
	1912   => '1323076',            # Mariage Melgven 3 E 177/29/8 (1912)
	1913   => '1323077',            # Mariage Melgven 3 E 177/29/9 (1913)
    },

    '3E177_0030' => {			# Décès Melgven 3 E 177 30   1902-1915
	1902   => '1323124',            # Décès Melgven 3 E 177/30/1 (1902)
	1903   => '1323125',            # Décès Melgven 3 E 177/30/2 (1903)
	1904   => '1323126',            # Décès Melgven 3 E 177/30/3 (1904)
	1905   => '1323127',            # Décès Melgven 3 E 177/30/4 (1905)
	1906   => '1323128',            # Décès Melgven 3 E 177/30/5 (1906)
	1907   => '1323129',            # Décès Melgven 3 E 177/30/6 (1907)
	1908   => '1323130',            # Décès Melgven 3 E 177/30/7 (1908)
	1909   => '1323131',            # Décès Melgven 3 E 177/30/8 (1909)
	1910   => '1323132',            # Décès Melgven 3 E 177/30/9 (1910)
	1911   => '1323133',            # Décès Melgven 3 E 177/30/10 (1911)
	1912   => '1323134',            # Décès Melgven 3 E 177/30/11 (1912)
	1913   => '1323135',            # Décès Melgven 3 E 177/30/12 (1913)
	1914   => '1323136',            # Décès Melgven 3 E 177/30/13 (1914)
	1915   => '1323137',            # Décès Melgven 3 E 177/30/14 (1915)
    },

    '3E177_0031' => {			# Naissance Melgven 3 E 177 31   1912-1921
	1912   => '1323021',            # Naissance Melgven 3 E 177/31/1 (1912)
	1913   => '1323022',            # Naissance Melgven 3 E 177/31/2 (1913)
	1914   => '1323023',            # Naissance Melgven 3 E 177/31/3 (1914)
	1915   => '1323024',            # Naissance Melgven 3 E 177/31/4 (1915)
	1916   => '1323025',            # Naissance Melgven 3 E 177/31/5 (1916)
	1917   => '1323026',            # Naissance Melgven 3 E 177/31/6 (1917)
	1918   => '1323027',            # Naissance Melgven 3 E 177/31/7 (1918)
	1919   => '1323028',            # Naissance Melgven 3 E 177/31/8 (1919)
	1920   => '1323029',            # Naissance Melgven 3 E 177/31/9 (1920)
	1921   => '1323030',            # Naissance Melgven 3 E 177/31/10 (1921)
    },

    '3E177_0032' => {			# Naissance Melgven 3 E 177 32   1922-1925
	1922   => '1323032',            # Naissance Melgven 3 E 177/32/1 (1922)
	1923   => '1323033',            # Naissance Melgven 3 E 177/32/2 (1923)
	1924   => '1323034',            # Naissance Melgven 3 E 177/32/3 (1924)
	1925   => '1323035',            # Naissance Melgven 3 E 177/32/4 (1925)
    },

    '3E177_0034' => {			# Mariage Melgven 3 E 177 34   1914-1921
	1914   => '1323079',            # Mariage Melgven 3 E 177/34/1 (1914)
	1915   => '1323080',            # Mariage Melgven 3 E 177/34/2 (1915)
	1916   => '1323081',            # Mariage Melgven 3 E 177/34/3 (1916)
	1917   => '1323082',            # Mariage Melgven 3 E 177/34/4 (1917)
	1918   => '1323083',            # Mariage Melgven 3 E 177/34/5 (1918)
	1919   => '1323084',            # Mariage Melgven 3 E 177/34/6 (1919)
	1920   => '1323085',            # Mariage Melgven 3 E 177/34/7 (1920)
	1921   => '1323086',            # Mariage Melgven 3 E 177/34/8 (1921)
    },

    '3E177_0035' => {			# Mariage Melgven 3 E 177 35   1922-1929
	1922   => '1323088',            # Mariage Melgven 3 E 177/35/1 (1922)
	1923   => '1323089',            # Mariage Melgven 3 E 177/35/2 (1923)
	1924   => '1323090',            # Mariage Melgven 3 E 177/35/3 (1924)
	1925   => '1323091',            # Mariage Melgven 3 E 177/35/4 (1925)
	1926   => '1323092',            # Mariage Melgven 3 E 177/35/5 (1926)
	1927   => '1323093',            # Mariage Melgven 3 E 177/35/6 (1927)
	1928   => '1323094',            # Mariage Melgven 3 E 177/35/7 (1928)
	1929   => '1323095',            # Mariage Melgven 3 E 177/35/8 (1929)
    },

    '3E177_0036' => {			# Mariage Melgven 3 E 177 36   1930-1936
	1930   => '1323097',            # Mariage Melgven 3 E 177/36/1 (1930)
	1931   => '1323098',            # Mariage Melgven 3 E 177/36/2 (1931)
	1932   => '1323099',            # Mariage Melgven 3 E 177/36/3 (1932)
	1933   => '1323100',            # Mariage Melgven 3 E 177/36/4 (1933)
	1934   => '1323101',            # Mariage Melgven 3 E 177/36/5 (1934)
	1935   => '1323102',            # Mariage Melgven 3 E 177/36/6 (1935)
	1936   => '1323103',            # Mariage Melgven 3 E 177/36/7 (1936)
    },

    '3E177_0037' => {			# Décès Melgven 3 E 177 37   1916-1924
	1916   => '1323139',            # Décès Melgven 3 E 177/37/1 (1916)
	1917   => '1323140',            # Décès Melgven 3 E 177/37/2 (1917)
	1918   => '1323141',            # Décès Melgven 3 E 177/37/3 (1918)
	1919   => '1323142',            # Décès Melgven 3 E 177/37/4 (1919)
	1920   => '1323143',            # Décès Melgven 3 E 177/37/5 (1920)
	1921   => '1323144',            # Décès Melgven 3 E 177/37/6 (1921)
	1922   => '1323145',            # Décès Melgven 3 E 177/37/7 (1922)
	1923   => '1323146',            # Décès Melgven 3 E 177/37/8 (1923)
	1924   => '1323147',            # Décès Melgven 3 E 177/37/9 (1924)
    },

    '3E177_0038' => {			# Décès Melgven 3 E 177 38   1925-1936
	1925   => '1323149',            # Décès Melgven 3 E 177/38/1 (1925)
	1926   => '1323150',            # Décès Melgven 3 E 177/38/2 (1926)
	1927   => '1323151',            # Décès Melgven 3 E 177/38/3 (1927)
	1928   => '1323152',            # Décès Melgven 3 E 177/38/4 (1928)
	1929   => '1323153',            # Décès Melgven 3 E 177/38/5 (1929)
	1930   => '1323154',            # Décès Melgven 3 E 177/38/6 (1930)
	1931   => '1323155',            # Décès Melgven 3 E 177/38/7 (1931)
	1932   => '1323156',            # Décès Melgven 3 E 177/38/8 (1932)
	1933   => '1323157',            # Décès Melgven 3 E 177/38/9 (1933)
	1934   => '1323158',            # Décès Melgven 3 E 177/38/10 (1934)
	1935   => '1323159',            # Décès Melgven 3 E 177/38/11 (1935)
	1936   => '1323160',            # Décès Melgven 3 E 177/38/12 (1936)
    },

    # NMD Morlaix
    '3E188_0126' => '',			# Décès Morlaix (1857-1858) : BUG/FIXME: n'apparait plus avec le nouveau site !

    # NMD Motreff
    '3E189_0004' => '657659.1324612',   # Naissance Motreff 3 E 189 4 (1793-1812)
    '3E189_0005' => '657660.1324613',   # Naissance Motreff 3 E 189 5 (1813-1832)
    '3E189_0006' => '657661.1324614',   # Naissance Motreff 3 E 189 6 (1833-1842)
    '3E189_0007' => '657662.1324615',   # Naissance Motreff 3 E 189 7 (1843-1852)
    '3E189_0008' => '657663.1324616',   # Naissance Motreff 3 E 189 8 (1853-1862)
    '3E189_0009' => '657664.1324617',   # Naissance Motreff 3 E 189 9 (1863-1869)
    '3E189_0010' => '657665.1324618',   # Naissance Motreff 3 E 189 10 (1870-1885)
    '3E189_0011' => '657666.1324675',   # Mariage promesse de mariage Motreff 3 E 189 11 (1793-1812)
    '3E189_0012' => '657667.1324676',   # Mariage Motreff 3 E 189 12 (1813-1832)
    '3E189_0013' => '657668.1324677',   # Mariage Motreff 3 E 189 13 (1833-1842)
    '3E189_0014' => '657669.1324678',   # Mariage Motreff 3 E 189 14 (1843-1852)
    '3E189_0015' => '657670.1324679',   # Mariage Motreff 3 E 189 15 (1853-1862)
    '3E189_0016' => '657671.1324680',   # Mariage Motreff 3 E 189 16 (1863-1869)
    '3E189_0017' => '657672.1324681',   # Mariage Motreff 3 E 189 17 (1870-1887)
    '3E189_0018' => '657673.1324735',   # Décès Motreff 3 E 189 18 (1793-1812)
    '3E189_0019' => '657674.1324736',   # Décès Motreff 3 E 189 19 (1813-1832)
    '3E189_0020' => '657675.1324737',   # Décès Motreff 3 E 189 20 (1833-1842)
    '3E189_0021' => '657676.1324738',   # Décès Motreff 3 E 189 21 (1843-1852)
    '3E189_0022' => '657677.1324739',   # Décès Motreff 3 E 189 22 (1853-1862)
    '3E189_0023' => '657678.1324740',   # Décès Motreff 3 E 189 23 (1863-1869)
    '3E189_0024' => '657679.1324741',   # Décès Motreff 3 E 189 24 (1870-1889)
    '3E189_0025' => {			# Naissance Motreff 3 E 189 25   1886-1900
	1886   => '1324620',            # Naissance Motreff 3 E 189/25/1 (1886)
	1887   => '1324621',            # Naissance Motreff 3 E 189/25/2 (1887)
	1888   => '1324622',            # Naissance Motreff 3 E 189/25/3 (1888)
	1889   => '1324623',            # Naissance Motreff 3 E 189/25/4 (1889)
	1890   => '1324624',            # Naissance Motreff 3 E 189/25/5 (1890)
	1891   => '1324625',            # Naissance Motreff 3 E 189/25/6 (1891)
	1892   => '1324626',            # Naissance Motreff 3 E 189/25/7 (1892)
	1893   => '1324627',            # Naissance Motreff 3 E 189/25/8 (1893)
	1894   => '1324628',            # Naissance Motreff 3 E 189/25/9 (1894)
	1895   => '1324629',            # Naissance Motreff 3 E 189/25/10 (1895)
	1896   => '1324630',            # Naissance Motreff 3 E 189/25/11 (1896)
	1897   => '1324631',            # Naissance Motreff 3 E 189/25/12 (1897)
	1898   => '1324632',            # Naissance Motreff 3 E 189/25/13 (1898)
	1899   => '1324633',            # Naissance Motreff 3 E 189/25/14 (1899)
	1900   => '1324634',            # Naissance Motreff 3 E 189/25/15 (1900)
    },

    '3E189_0026' => {			# Mariage Motreff 3 E 189 26   1888-1905
	1888   => '1324683',            # Mariage Motreff 3 E 189/26/1 (1888)
	1889   => '1324684',            # Mariage Motreff 3 E 189/26/2 (1889)
	1890   => '1324685',            # Mariage Motreff 3 E 189/26/3 (1890)
	1891   => '1324686',            # Mariage Motreff 3 E 189/26/4 (1891)
	1892   => '1324687',            # Mariage Motreff 3 E 189/26/5 (1892)
	1893   => '1324688',            # Mariage Motreff 3 E 189/26/6 (1893)
	1894   => '1324689',            # Mariage Motreff 3 E 189/26/7 (1894)
	1895   => '1324690',            # Mariage Motreff 3 E 189/26/8 (1895)
	1896   => '1324691',            # Mariage Motreff 3 E 189/26/9 (1896)
	1897   => '1324692',            # Mariage Motreff 3 E 189/26/10 (1897)
	1898   => '1324693',            # Mariage Motreff 3 E 189/26/11 (1898)
	1899   => '1324694',            # Mariage Motreff 3 E 189/26/12 (1899)
	1900   => '1324695',            # Mariage Motreff 3 E 189/26/13 (1900)
	1901   => '1324696',            # Mariage Motreff 3 E 189/26/14 (1901)
	1902   => '1324697',            # Mariage Motreff 3 E 189/26/15 (1902)
	1903   => '1324698',            # Mariage Motreff 3 E 189/26/16 (1903)
	1904   => '1324699',            # Mariage Motreff 3 E 189/26/17 (1904)
	1905   => '1324700',            # Mariage Motreff 3 E 189/26/18 (1905)
    },

    '3E189_0027' => {			# Décès Motreff 3 E 189 27   1890-1907
	1890   => '1324743',            # Décès Motreff 3 E 189/27/1 (1890)
	1891   => '1324744',            # Décès Motreff 3 E 189/27/2 (1891)
	1892   => '1324745',            # Décès Motreff 3 E 189/27/3 (1892)
	1893   => '1324746',            # Décès Motreff 3 E 189/27/4 (1893)
	1894   => '1324747',            # Décès Motreff 3 E 189/27/5 (1894)
	1895   => '1324748',            # Décès Motreff 3 E 189/27/6 (1895)
	1896   => '1324749',            # Décès Motreff 3 E 189/27/7 (1896)
	1897   => '1324750',            # Décès Motreff 3 E 189/27/8 (1897)
	1898   => '1324751',            # Décès Motreff 3 E 189/27/9 (1898)
	1899   => '1324752',            # Décès Motreff 3 E 189/27/10 (1899)
	1900   => '1324753',            # Décès Motreff 3 E 189/27/11 (1900)
	1901   => '1324754',            # Décès Motreff 3 E 189/27/12 (1901)
	1902   => '1324755',            # Décès Motreff 3 E 189/27/13 (1902)
	1903   => '1324756',            # Décès Motreff 3 E 189/27/14 (1903)
	1904   => '1324757',            # Décès Motreff 3 E 189/27/15 (1904)
	1905   => '1324758',            # Décès Motreff 3 E 189/27/16 (1905)
	1906   => '1324759',            # Décès Motreff 3 E 189/27/17 (1906)
	1907   => '1324760',            # Décès Motreff 3 E 189/27/18 (1907)
    },

    '3E189_0028' => {			# Naissance Motreff 3 E 189 28   1901-1911
	1901   => '1324636',            # Naissance Motreff 3 E 189/28/1 (1901)
	1902   => '1324637',            # Naissance Motreff 3 E 189/28/2 (1902)
	1903   => '1324638',            # Naissance Motreff 3 E 189/28/3 (1903)
	1904   => '1324639',            # Naissance Motreff 3 E 189/28/4 (1904)
	1905   => '1324640',            # Naissance Motreff 3 E 189/28/5 (1905)
	1906   => '1324641',            # Naissance Motreff 3 E 189/28/6 (1906)
	1907   => '1324642',            # Naissance Motreff 3 E 189/28/7 (1907)
	1908   => '1324643',            # Naissance Motreff 3 E 189/28/8 (1908)
	1909   => '1324644',            # Naissance Motreff 3 E 189/28/9 (1909)
	1910   => '1324645',            # Naissance Motreff 3 E 189/28/10 (1910)
	1911   => '1324646',            # Naissance Motreff 3 E 189/28/11 (1911)
    },

    '3E189_0029' => {			# Naissance Motreff 3 E 189 29   1912-1923
	1912   => '1324648',            # Naissance Motreff 3 E 189/29/1 (1912)
	1913   => '1324649',            # Naissance Motreff 3 E 189/29/2 (1913)
	1914   => '1324650',            # Naissance Motreff 3 E 189/29/3 (1914)
	1915   => '1324651',            # Naissance Motreff 3 E 189/29/4 (1915)
	1916   => '1324652',            # Naissance Motreff 3 E 189/29/5 (1916)
	1917   => '1324653',            # Naissance Motreff 3 E 189/29/6 (1917)
	1918   => '1324654',            # Naissance Motreff 3 E 189/29/7 (1918)
	1919   => '1324655',            # Naissance Motreff 3 E 189/29/8 (1919)
	1920   => '1324656',            # Naissance Motreff 3 E 189/29/9 (1920)
	1921   => '1324657',            # Naissance Motreff 3 E 189/29/10 (1921)
	1922   => '1324658',            # Naissance Motreff 3 E 189/29/11 (1922)
	1923   => '1324659',            # Naissance Motreff 3 E 189/29/12 (1923)
    },

    '3E189_0030' => {			# Naissance Motreff 3 E 189 30   1924-1925
	1924   => '1324661',            # Naissance Motreff 3 E 189/30/1 (1924)
	1925   => '1324662',            # Naissance Motreff 3 E 189/30/2 (1925)
    },

    '3E189_0031' => {			# Mariage Motreff 3 E 189 31   1906-1918
	1906   => '1324702',            # Mariage Motreff 3 E 189/31/1 (1906)
	1907   => '1324703',            # Mariage Motreff 3 E 189/31/2 (1907)
	1908   => '1324704',            # Mariage Motreff 3 E 189/31/3 (1908)
	1909   => '1324705',            # Mariage Motreff 3 E 189/31/4 (1909)
	1910   => '1324706',            # Mariage Motreff 3 E 189/31/5 (1910)
	1911   => '1324707',            # Mariage Motreff 3 E 189/31/6 (1911)
	1912   => '1324708',            # Mariage Motreff 3 E 189/31/7 (1912)
	1913   => '1324709',            # Mariage Motreff 3 E 189/31/8 (1913)
	1914   => '1324710',            # Mariage Motreff 3 E 189/31/9 (1914)
	1915   => '1324711',            # Mariage Motreff 3 E 189/31/10 (1915)
	1916   => '1324712',            # Mariage Motreff 3 E 189/31/11 (1916)
	1917   => '1324713',            # Mariage Motreff 3 E 189/31/12 (1917)
	1918   => '1324714',            # Mariage Motreff 3 E 189/31/13 (1918)
    },

    '3E189_0032' => {			# Mariage Motreff 3 E 189 32   1919-1936
	1919   => '1324716',            # Mariage Motreff 3 E 189/32/1 (1919)
	1920   => '1324717',            # Mariage Motreff 3 E 189/32/2 (1920)
	1921   => '1324718',            # Mariage Motreff 3 E 189/32/3 (1921)
	1922   => '1324719',            # Mariage Motreff 3 E 189/32/4 (1922)
	1923   => '1324720',            # Mariage Motreff 3 E 189/32/5 (1923)
	1924   => '1324721',            # Mariage Motreff 3 E 189/32/6 (1924)
	1925   => '1324722',            # Mariage Motreff 3 E 189/32/7 (1925)
	1926   => '1324723',            # Mariage Motreff 3 E 189/32/8 (1926)
	1927   => '1324724',            # Mariage Motreff 3 E 189/32/9 (1927)
	1928   => '1324725',            # Mariage Motreff 3 E 189/32/10 (1928)
	1929   => '1324726',            # Mariage Motreff 3 E 189/32/11 (1929)
	1930   => '1324727',            # Mariage Motreff 3 E 189/32/12 (1930)
	1931   => '1324728',            # Mariage Motreff 3 E 189/32/13 (1931)
	1932   => '1324729',            # Mariage Motreff 3 E 189/32/14 (1932)
	1933   => '1324730',            # Mariage Motreff 3 E 189/32/15 (1933)
	1934   => '1324731',            # Mariage Motreff 3 E 189/32/16 (1934)
	1935   => '1324732',            # Mariage Motreff 3 E 189/32/17 (1935)
	1936   => '1324733',            # Mariage Motreff 3 E 189/32/18 (1936)
    },

    '3E189_0033' => {			# Décès Motreff 3 E 189 33   1908-1920
	1908   => '1324762',            # Décès Motreff 3 E 189/33/1 (1908)
	1909   => '1324763',            # Décès Motreff 3 E 189/33/2 (1909)
	1910   => '1324764',            # Décès Motreff 3 E 189/33/3 (1910)
	1911   => '1324765',            # Décès Motreff 3 E 189/33/4 (1911)
	1912   => '1324766',            # Décès Motreff 3 E 189/33/5 (1912)
	1913   => '1324767',            # Décès Motreff 3 E 189/33/6 (1913)
	1914   => '1324768',            # Décès Motreff 3 E 189/33/7 (1914)
	1915   => '1324769',            # Décès Motreff 3 E 189/33/8 (1915)
	1916   => '1324770',            # Décès Motreff 3 E 189/33/9 (1916)
	1917   => '1324771',            # Décès Motreff 3 E 189/33/10 (1917)
	1918   => '1324772',            # Décès Motreff 3 E 189/33/11 (1918)
	1919   => '1324773',            # Décès Motreff 3 E 189/33/12 (1919)
	1920   => '1324774',            # Décès Motreff 3 E 189/33/13 (1920)
    },

    '3E189_0034' => {			# Décès Motreff 3 E 189 34   1921-1936
	1921   => '1324776',            # Décès Motreff 3 E 189/34/1 (1921)
	1922   => '1324777',            # Décès Motreff 3 E 189/34/2 (1922)
	1923   => '1324778',            # Décès Motreff 3 E 189/34/3 (1923)
	1924   => '1324779',            # Décès Motreff 3 E 189/34/4 (1924)
	1925   => '1324780',            # Décès Motreff 3 E 189/34/5 (1925)
	1926   => '1324781',            # Décès Motreff 3 E 189/34/6 (1926)
	1927   => '1324782',            # Décès Motreff 3 E 189/34/7 (1927)
	1928   => '1324783',            # Décès Motreff 3 E 189/34/8 (1928)
	1929   => '1324784',            # Décès Motreff 3 E 189/34/9 (1929)
	1930   => '1324785',            # Décès Motreff 3 E 189/34/10 (1930)
	1931   => '1324786',            # Décès Motreff 3 E 189/34/11 (1931)
	1932   => '1324787',            # Décès Motreff 3 E 189/34/12 (1932)
	1933   => '1324788',            # Décès Motreff 3 E 189/34/13 (1933)
	1934   => '1324789',            # Décès Motreff 3 E 189/34/14 (1934)
	1935   => '1324790',            # Décès Motreff 3 E 189/34/15 (1935)
	1936   => '1324791',            # Décès Motreff 3 E 189/34/16 (1936)
    },

    # NMD Plonévez-du-Faou
    '3E214_0009' => '658669.1333278',   # Naissance Plonévez-du-Faou 3 E 214 9 (1793-an X)
    '3E214_0010' => '658670.1333279',   # Naissance Plonévez-du-Faou 3 E 214 10 (An XI-1812)
    '3E214_0011' => '658671.1333280',   # Naissance Plonévez-du-Faou 3 E 214 11 (1813-1822)
    '3E214_0012' => '658672.1333281',   # Naissance Plonévez-du-Faou 3 E 214 12 (1823-1832)
    '3E214_0013' => '658673.1333282',   # Naissance Plonévez-du-Faou 3 E 214 13 (1833-1842)
    '3E214_0014' => '658674.1333283',   # Naissance Plonévez-du-Faou 3 E 214 14 (1843-1852)
    '3E214_0015' => '658675.1333284',   # Naissance Plonévez-du-Faou 3 E 214 15 (1853-1862)
    '3E214_0016' => '658676.1333285',   # Naissance Plonévez-du-Faou 3 E 214 16 (1863-1869)
    '3E214_0017' => '658677.1333286',   # Naissance Plonévez-du-Faou 3 E 214 17 (1870-1875)
    '3E214_0018' => '658678.1333287',   # Naissance Plonévez-du-Faou 3 E 214 18 (1876-1881)
    '3E214_0019' => '658679.1333288',   # Naissance Plonévez-du-Faou 3 E 214 19 (1882-1888)
    '3E214_0020' => '658680.1333347',   # Mariage promesse de mariage Plonévez-du-Faou 3 E 214 20 (1793-an X)
    '3E214_0021' => '658681.1333348',   # Mariage Plonévez-du-Faou 3 E 214 21 (An XI-1812)
    '3E214_0022' => '658682.1333349',   # Mariage Plonévez-du-Faou 3 E 214 22 (1813-1822)
    '3E214_0023' => '658683.1333350',   # Mariage Plonévez-du-Faou 3 E 214 23 (1823-1832)
    '3E214_0024' => '658684.1333351',   # Mariage Plonévez-du-Faou 3 E 214 24 (1833-1842)
    '3E214_0025' => '658685.1333352',   # Mariage Plonévez-du-Faou 3 E 214 25 (1843-1852)
    '3E214_0026' => '658686.1333353',   # Mariage Plonévez-du-Faou 3 E 214 26 (1853-1862)
    '3E214_0027' => '658687.1333354',   # Mariage Plonévez-du-Faou 3 E 214 27 (1863-1869)
    '3E214_0028' => '658688.1333355',   # Mariage Plonévez-du-Faou 3 E 214 28 (1870-1879)
    '3E214_0029' => '658689.1333356',   # Mariage Plonévez-du-Faou 3 E 214 29 (1880-1891)
    '3E214_0030' => '658690.1333418',   # Décès Plonévez-du-Faou 3 E 214 30 (1793-an X)
    '3E214_0031' => '658691.1333419',   # Décès Plonévez-du-Faou 3 E 214 31 (An XI-1812)
    '3E214_0032' => '658692.1333420',   # Décès Plonévez-du-Faou 3 E 214 32 (1813-1822)
    '3E214_0033' => '658693.1333421',   # Décès Plonévez-du-Faou 3 E 214 33 (1823-1832)
    '3E214_0034' => '658694.1333422',   # Décès Plonévez-du-Faou 3 E 214 34 (1833-1842)
    '3E214_0035' => '658695.1333423',   # Décès Plonévez-du-Faou 3 E 214 35 (1843-1852)
    '3E214_0036' => '658696.1333424',   # Décès Plonévez-du-Faou 3 E 214 36 (1853-1862)
    '3E214_0037' => '658697.1333425',   # Décès Plonévez-du-Faou 3 E 214 37 (1863-1869)
    '3E214_0038' => '658698.1333426',   # Décès Plonévez-du-Faou 3 E 214 38 (1870-1878)
    '3E214_0039' => '658699.1333427',   # Décès Plonévez-du-Faou 3 E 214 39 (1879-1887)
    '3E214_0040' => '658700.1333289',   # Naissance Plonévez-du-Faou 3 E 214 40 (1889-1895)
    '3E214_0041' => '658701.1333428',   # Décès Plonévez-du-Faou 3 E 214 41 (1888-1897)
    '3E214_0042' => {			# Naissance Plonévez-du-Faou 3 E 214 42   1896-1902
	1896   => '1333291',            # Naissance Plonévez-du-Faou 3 E 214/42/1 (1896)
	1897   => '1333292',            # Naissance Plonévez-du-Faou 3 E 214/42/2 (1897)
	1898   => '1333293',            # Naissance Plonévez-du-Faou 3 E 214/42/3 (1898)
	1899   => '1333294',            # Naissance Plonévez-du-Faou 3 E 214/42/4 (1899)
	1900   => '1333295',            # Naissance Plonévez-du-Faou 3 E 214/42/5 (1900)
	1901   => '1333296',            # Naissance Plonévez-du-Faou 3 E 214/42/6 (1901)
	1902   => '1333297',            # Naissance Plonévez-du-Faou 3 E 214/42/7 (1902)
    },

    '3E214_0043' => {			# Mariage Plonévez-du-Faou 3 E 214 43   1892-1902
	1892   => '1333358',            # Mariage Plonévez-du-Faou 3 E 214/43/1 (1892)
	1893   => '1333359',            # Mariage Plonévez-du-Faou 3 E 214/43/2 (1893)
	1894   => '1333360',            # Mariage Plonévez-du-Faou 3 E 214/43/3 (1894)
	1895   => '1333361',            # Mariage Plonévez-du-Faou 3 E 214/43/4 (1895)
	1896   => '1333362',            # Mariage Plonévez-du-Faou 3 E 214/43/5 (1896)
	1897   => '1333363',            # Mariage Plonévez-du-Faou 3 E 214/43/6 (1897)
	1898   => '1333364',            # Mariage Plonévez-du-Faou 3 E 214/43/7 (1898)
	1899   => '1333365',            # Mariage Plonévez-du-Faou 3 E 214/43/8 (1899)
	1900   => '1333366',            # Mariage Plonévez-du-Faou 3 E 214/43/9 (1900)
	1901   => '1333367',            # Mariage Plonévez-du-Faou 3 E 214/43/10 (1901)
	1902   => '1333368',            # Mariage Plonévez-du-Faou 3 E 214/43/11 (1902)
    },

    '3E214_0044' => {			# Décès Plonévez-du-Faou 3 E 214 44   1898-1907
	1898   => '1333430',            # Décès Plonévez-du-Faou 3 E 214/44/1 (1898)
	1899   => '1333431',            # Décès Plonévez-du-Faou 3 E 214/44/2 (1899)
	1900   => '1333432',            # Décès Plonévez-du-Faou 3 E 214/44/3 (1900)
	1901   => '1333433',            # Décès Plonévez-du-Faou 3 E 214/44/4 (1901)
	1902   => '1333434',            # Décès Plonévez-du-Faou 3 E 214/44/5 (1902)
	1903   => '1333435',            # Décès Plonévez-du-Faou 3 E 214/44/6 (1903)
	1904   => '1333436',            # Décès Plonévez-du-Faou 3 E 214/44/7 (1904)
	1905   => '1333437',            # Décès Plonévez-du-Faou 3 E 214/44/8 (1905)
	1906   => '1333438',            # Décès Plonévez-du-Faou 3 E 214/44/9 (1906)
	1907   => '1333439',            # Décès Plonévez-du-Faou 3 E 214/44/10 (1907)
    },

    '3E214_0045' => {			# Naissance Plonévez-du-Faou 3 E 214 45   1903-1908
	1903   => '1333299',            # Naissance Plonévez-du-Faou 3 E 214/45/1 (1903)
	1904   => '1333300',            # Naissance Plonévez-du-Faou 3 E 214/45/2 (1904)
	1905   => '1333301',            # Naissance Plonévez-du-Faou 3 E 214/45/3 (1905)
	1906   => '1333302',            # Naissance Plonévez-du-Faou 3 E 214/45/4 (1906)
	1907   => '1333303',            # Naissance Plonévez-du-Faou 3 E 214/45/5 (1907)
	1908   => '1333304',            # Naissance Plonévez-du-Faou 3 E 214/45/6 (1908)
    },

    '3E214_0046' => {			# Mariage Plonévez-du-Faou 3 E 214 46   1903-1910
	1903   => '1333370',            # Mariage Plonévez-du-Faou 3 E 214/46/1 (1903)
	1904   => '1333371',            # Mariage Plonévez-du-Faou 3 E 214/46/2 (1904)
	1905   => '1333372',            # Mariage Plonévez-du-Faou 3 E 214/46/3 (1905)
	1906   => '1333373',            # Mariage Plonévez-du-Faou 3 E 214/46/4 (1906)
	1907   => '1333374',            # Mariage Plonévez-du-Faou 3 E 214/46/5 (1907)
	1908   => '1333375',            # Mariage Plonévez-du-Faou 3 E 214/46/6 (1908)
	1909   => '1333376',            # Mariage Plonévez-du-Faou 3 E 214/46/7 (1909)
	1910   => '1333377',            # Mariage Plonévez-du-Faou 3 E 214/46/8 (1910)
    },

    '3E214_0047' => {			# Naissance Plonévez-du-Faou 3 E 214 47   1909-1913
	1909   => '1333306',            # Naissance Plonévez-du-Faou 3 E 214/47/1 (1909)
	1910   => '1333307',            # Naissance Plonévez-du-Faou 3 E 214/47/2 (1910)
	1911   => '1333308',            # Naissance Plonévez-du-Faou 3 E 214/47/3 (1911)
	1912   => '1333309',            # Naissance Plonévez-du-Faou 3 E 214/47/4 (1912)
	1913   => '1333310',            # Naissance Plonévez-du-Faou 3 E 214/47/5 (1913)
    },

    '3E214_0048' => {			# Naissance Plonévez-du-Faou 3 E 214 48   1914-1920
	1914   => '1333312',            # Naissance Plonévez-du-Faou 3 E 214/48/1 (1914)
	1915   => '1333313',            # Naissance Plonévez-du-Faou 3 E 214/48/2 (1915)
	1916   => '1333314',            # Naissance Plonévez-du-Faou 3 E 214/48/3 (1916)
	1917   => '1333315',            # Naissance Plonévez-du-Faou 3 E 214/48/4 (1917)
	1918   => '1333316',            # Naissance Plonévez-du-Faou 3 E 214/48/5 (1918)
	1919   => '1333317',            # Naissance Plonévez-du-Faou 3 E 214/48/6 (1919)
	1920   => '1333318',            # Naissance Plonévez-du-Faou 3 E 214/48/7 (1920)
    },

    '3E214_0049' => {			# Naissance Plonévez-du-Faou 3 E 214 49   1921-1925
	1921   => '1333320',            # Naissance Plonévez-du-Faou 3 E 214/49/1 (1921)
	1922   => '1333321',            # Naissance Plonévez-du-Faou 3 E 214/49/2 (1922)
	1923   => '1333322',            # Naissance Plonévez-du-Faou 3 E 214/49/3 (1923)
	1924   => '1333323',            # Naissance Plonévez-du-Faou 3 E 214/49/4 (1924)
	1925   => '1333324',            # Naissance Plonévez-du-Faou 3 E 214/49/5 (1925)
    },

    '3E214_0051' => {			# Mariage Plonévez-du-Faou 3 E 214 51   1911-1918
	1911   => '1333379',            # Mariage Plonévez-du-Faou 3 E 214/51/1 (1911)
	1912   => '1333380',            # Mariage Plonévez-du-Faou 3 E 214/51/2 (1912)
	1913   => '1333381',            # Mariage Plonévez-du-Faou 3 E 214/51/3 (1913)
	1914   => '1333382',            # Mariage Plonévez-du-Faou 3 E 214/51/4 (1914)
	1915   => '1333383',            # Mariage Plonévez-du-Faou 3 E 214/51/5 (1915)
	1916   => '1333384',            # Mariage Plonévez-du-Faou 3 E 214/51/6 (1916)
	1917   => '1333385',            # Mariage Plonévez-du-Faou 3 E 214/51/7 (1917)
	1918   => '1333386',            # Mariage Plonévez-du-Faou 3 E 214/51/8 (1918)
    },

    '3E214_0052' => {			# Mariage Plonévez-du-Faou 3 E 214 52   1919-1925
	1919   => '1333388',            # Mariage Plonévez-du-Faou 3 E 214/52/1 (1919)
	1920   => '1333389',            # Mariage Plonévez-du-Faou 3 E 214/52/2 (1920)
	1921   => '1333390',            # Mariage Plonévez-du-Faou 3 E 214/52/3 (1921)
	1922   => '1333391',            # Mariage Plonévez-du-Faou 3 E 214/52/4 (1922)
	1923   => '1333392',            # Mariage Plonévez-du-Faou 3 E 214/52/5 (1923)
	1924   => '1333393',            # Mariage Plonévez-du-Faou 3 E 214/52/6 (1924)
	1925   => '1333394',            # Mariage Plonévez-du-Faou 3 E 214/52/7 (1925)
    },

    '3E214_0053' => {			# Mariage Plonévez-du-Faou 3 E 214 53   1926-1934
	1926   => '1333396',            # Mariage Plonévez-du-Faou 3 E 214/53/1 (1926)
	1927   => '1333397',            # Mariage Plonévez-du-Faou 3 E 214/53/2 (1927)
	1928   => '1333398',            # Mariage Plonévez-du-Faou 3 E 214/53/3 (1928)
	1929   => '1333399',            # Mariage Plonévez-du-Faou 3 E 214/53/4 (1929)
	1930   => '1333400',            # Mariage Plonévez-du-Faou 3 E 214/53/5 (1930)
	1931   => '1333401',            # Mariage Plonévez-du-Faou 3 E 214/53/6 (1931)
	1932   => '1333402',            # Mariage Plonévez-du-Faou 3 E 214/53/7 (1932)
	1933   => '1333403',            # Mariage Plonévez-du-Faou 3 E 214/53/8 (1933)
	1934   => '1333404',            # Mariage Plonévez-du-Faou 3 E 214/53/9 (1934)
    },

    '3E214_0054' => {			# Décès Plonévez-du-Faou 3 E 214 54   1908-1916
	1908   => '1333441',            # Décès Plonévez-du-Faou 3 E 214/54/1 (1908)
	1909   => '1333442',            # Décès Plonévez-du-Faou 3 E 214/54/2 (1909)
	1910   => '1333443',            # Décès Plonévez-du-Faou 3 E 214/54/3 (1910)
	1911   => '1333444',            # Décès Plonévez-du-Faou 3 E 214/54/4 (1911)
	1912   => '1333445',            # Décès Plonévez-du-Faou 3 E 214/54/5 (1912)
	1913   => '1333446',            # Décès Plonévez-du-Faou 3 E 214/54/6 (1913)
	1914   => '1333447',            # Décès Plonévez-du-Faou 3 E 214/54/7 (1914)
	1915   => '1333448',            # Décès Plonévez-du-Faou 3 E 214/54/8 (1915)
	1916   => '1333449',            # Décès Plonévez-du-Faou 3 E 214/54/9 (1916)
    },

    '3E214_0055' => {			# Décès Plonévez-du-Faou 3 E 214 55   1917-1924
	1917   => '1333451',            # Décès Plonévez-du-Faou 3 E 214/55/1 (1917)
	1918   => '1333452',            # Décès Plonévez-du-Faou 3 E 214/55/2 (1918)
	1919   => '1333453',            # Décès Plonévez-du-Faou 3 E 214/55/3 (1919)
	1920   => '1333454',            # Décès Plonévez-du-Faou 3 E 214/55/4 (1920)
	1921   => '1333455',            # Décès Plonévez-du-Faou 3 E 214/55/5 (1921)
	1922   => '1333456',            # Décès Plonévez-du-Faou 3 E 214/55/6 (1922)
	1923   => '1333457',            # Décès Plonévez-du-Faou 3 E 214/55/7 (1923)
	1924   => '1333458',            # Décès Plonévez-du-Faou 3 E 214/55/8 (1924)
    },

    '3E214_0056' => {			# Décès Plonévez-du-Faou 3 E 214 56   1925-1936
	1925   => '1333460',            # Décès Plonévez-du-Faou 3 E 214/56/1 (1925)
	1926   => '1333461',            # Décès Plonévez-du-Faou 3 E 214/56/2 (1926)
	1927   => '1333462',            # Décès Plonévez-du-Faou 3 E 214/56/3 (1927)
	1928   => '1333463',            # Décès Plonévez-du-Faou 3 E 214/56/4 (1928)
	1929   => '1333464',            # Décès Plonévez-du-Faou 3 E 214/56/5 (1929)
	1930   => '1333465',            # Décès Plonévez-du-Faou 3 E 214/56/6 (1930)
	1931   => '1333466',            # Décès Plonévez-du-Faou 3 E 214/56/7 (1931)
	1932   => '1333467',            # Décès Plonévez-du-Faou 3 E 214/56/8 (1932)
	1933   => '1333468',            # Décès Plonévez-du-Faou 3 E 214/56/9 (1933)
	1934   => '1333469',            # Décès Plonévez-du-Faou 3 E 214/56/10 (1934)
	1935   => '1333470',            # Décès Plonévez-du-Faou 3 E 214/56/11 (1935)
	1936   => '1333471',            # Décès Plonévez-du-Faou 3 E 214/56/12 (1936)
    },


    # NMD Plouguer
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
	1820   => '1340622',            # Naissance Plouguer 3 E 234/6/8 (1820)
	1821   => '1340623',            # Naissance Plouguer 3 E 234/6/9 (1821)
	1822   => '1340624',            # Naissance Plouguer 3 E 234/6/10 (1822)
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

    '3E234_0011' => {			# Mariage promesse de mariage Plouguer 3 E 234 11   AN02-1812
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
	1812   => '1340767',            # Mariage promesse de mariage Plouguer 3 E 234/11/19 (1812)
    },

    '3E234_0012' => {			# Mariage Plouguer 3 E 234 12   1813-1832
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
	1832   => '1340788',            # Mariage Plouguer 3 E 234/12/20 (1832)
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
	1820   => '1340930',            # Décès Plouguer 3 E 234/19/8 (1820)
	1821   => '1340931',            # Décès Plouguer 3 E 234/19/9 (1821)
	1822   => '1340932',            # Décès Plouguer 3 E 234/19/10 (1822)
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

    '3E234_0032' => {			# Mariage Plouguer 3 E 234 32   1918-1936
	1918   => '1340882',            # Mariage Plouguer 3 E 234/32/1 (1918)
	1919   => '1340883',            # Mariage Plouguer 3 E 234/32/2 (1919)
	1920   => '1340884',            # Mariage Plouguer 3 E 234/32/3 (1920)
	1921   => '1340885',            # Mariage Plouguer 3 E 234/32/4 (1921)
	1922   => '1340886',            # Mariage Plouguer 3 E 234/32/5 (1922)
	1923   => '1340887',            # Mariage Plouguer 3 E 234/32/6 (1923)
	1924   => '1340888',            # Mariage Plouguer 3 E 234/32/7 (1924)
	1925   => '1340889',            # Mariage Plouguer 3 E 234/32/8 (1925)
	1926   => '1340890',            # Mariage Plouguer 3 E 234/32/9 (1926)
	1927   => '1340891',            # Mariage Plouguer 3 E 234/32/10 (1927)
	1928   => '1340892',            # Mariage Plouguer 3 E 234/32/11 (1928)
	1929   => '1340893',            # Mariage Plouguer 3 E 234/32/12 (1929)
	1930   => '1340894',            # Mariage Plouguer 3 E 234/32/13 (1930)
	1931   => '1340895',            # Mariage Plouguer 3 E 234/32/14 (1931)
	1932   => '1340896',            # Mariage Plouguer 3 E 234/32/15 (1932)
	1933   => '1340897',            # Mariage Plouguer 3 E 234/32/16 (1933)
	1934   => '1340898',            # Mariage Plouguer 3 E 234/32/17 (1934)
	1935   => '1340899',            # Mariage Plouguer 3 E 234/32/18 (1935)
	1936   => '1340900',            # Mariage Plouguer 3 E 234/32/19 (1936)
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

    # NMD Poullaouen
    '3E270_0006' => '1039200.1354573',  # Naissance Poullaouen 3 E 270 6 (1793-an X)
    '3E270_0007' => '1039201.1354574',  # Naissance Poullaouen 3 E 270 7 (An XI-1812)
    '3E270_0008' => '1039202.1354575',  # Naissance Poullaouen 3 E 270 8 (1813-1822)
    '3E270_0009' => '1039203.1354576',  # Naissance Poullaouen 3 E 270 9 (1823-1832)
    '3E270_0010' => '1039204.1354577',  # Naissance Poullaouen 3 E 270 10 (1833-1842)
    '3E270_0011' => '1039205.1354578',  # Naissance Poullaouen 3 E 270 11 (1843-1852)
    '3E270_0012' => '1039206.1354579',  # Naissance Poullaouen 3 E 270 12 (1853-1862)
    '3E270_0013' => '1039207.1354580',  # Naissance Poullaouen 3 E 270 13 (1863-1869)
    '3E270_0014' => '1039208.1354581',  # Naissance Poullaouen 3 E 270 14 (1870-1878)
    '3E270_0015' => '1039209.1354582',  # Naissance Poullaouen 3 E 270 15 (1879-1887)
    '3E270_0016' => '1039210.1354631',  # Mariage promesse de mariage Poullaouen 3 E 270 16 (1793-an VI, an VIII-an X)
    '3E270_0017' => '1039211.1354632',  # Mariage Poullaouen 3 E 270 17 (An XI-1812)
    '3E270_0018' => '1039212.1354633',  # Mariage Poullaouen 3 E 270 18 (1813-1822)
    '3E270_0019' => '1039213.1354634',  # Mariage Poullaouen 3 E 270 19 (1823-1832)
    '3E270_0020' => '1039214.1354635',  # Mariage Poullaouen 3 E 270 20 (1833-1842)
    '3E270_0021' => '1039215.1354636',  # Mariage Poullaouen 3 E 270 21 (1843-1852)
    '3E270_0022' => '1039216.1354637',  # Mariage Poullaouen 3 E 270 22 (1853-1862)
    '3E270_0023' => '1039217.1354638',  # Mariage Poullaouen 3 E 270 23 (1863-1869)
    '3E270_0024' => '1039218.1354639',  # Mariage Poullaouen 3 E 270 24 (1870-1881)
    '3E270_0025' => '1039219.1354689',  # Décès Poullaouen 3 E 270 25 (1793-an X)
    '3E270_0026' => '1039220.1354690',  # Décès Poullaouen 3 E 270 26 (An XI-1812)
    '3E270_0027' => '1039221.1354691',  # Décès Poullaouen 3 E 270 27 (1813-1822)
    '3E270_0028' => '1039222.1354692',  # Décès Poullaouen 3 E 270 28 (1823-1832)
    '3E270_0029' => '1039223.1354693',  # Décès Poullaouen 3 E 270 29 (1833-1842)
    '3E270_0030' => '1039224.1354694',  # Décès Poullaouen 3 E 270 30 (1843-1852)
    '3E270_0031' => '1039225.1354695',  # Décès Poullaouen 3 E 270 31 (1853-1862)
    '3E270_0032' => '1039226.1354696',  # Décès Poullaouen 3 E 270 32 (1863-1869)
    '3E270_0033' => '1039227.1354697',  # Décès Poullaouen 3 E 270 33 (1870-1878)
    '3E270_0034' => '1039228.1354698',  # Décès Poullaouen 3 E 270 34 (1879-1889)
    '3E270_0035' => '1039229.1354583',  # Naissance Poullaouen 3 E 270 35 (1888-1895)
    '3E270_0036' => '1039230.1354640',  # Mariage Poullaouen 3 E 270 36 (1882-1893)
    '3E270_0037' => '1039231.1354699',  # Décès Poullaouen 3 E 270 37 (1890-1898)
    '3E270_0038' => {			# Naissance Poullaouen 3 E 270 38   1896-1903
	1896   => '1354585',            # Naissance Poullaouen 3 E 270/38/1 (1896)
	1897   => '1354586',            # Naissance Poullaouen 3 E 270/38/2 (1897)
	1898   => '1354587',            # Naissance Poullaouen 3 E 270/38/3 (1898)
	1899   => '1354588',            # Naissance Poullaouen 3 E 270/38/4 (1899)
	1900   => '1354589',            # Naissance Poullaouen 3 E 270/38/5 (1900)
	1901   => '1354590',            # Naissance Poullaouen 3 E 270/38/6 (1901)
	1902   => '1354591',            # Naissance Poullaouen 3 E 270/38/7 (1902)
	1903   => '1354592',            # Naissance Poullaouen 3 E 270/38/8 (1903)
    },

    '3E270_0039' => {			# Mariage Poullaouen 3 E 270 39   1894-1904
	1894   => '1354642',            # Mariage Poullaouen 3 E 270/39/1 (1894)
	1895   => '1354643',            # Mariage Poullaouen 3 E 270/39/2 (1895)
	1896   => '1354644',            # Mariage Poullaouen 3 E 270/39/3 (1896)
	1897   => '1354645',            # Mariage Poullaouen 3 E 270/39/4 (1897)
	1898   => '1354646',            # Mariage Poullaouen 3 E 270/39/5 (1898)
	1899   => '1354647',            # Mariage Poullaouen 3 E 270/39/6 (1899)
	1900   => '1354648',            # Mariage Poullaouen 3 E 270/39/7 (1900)
	1901   => '1354649',            # Mariage Poullaouen 3 E 270/39/8 (1901)
	1902   => '1354650',            # Mariage Poullaouen 3 E 270/39/9 (1902)
	1903   => '1354651',            # Mariage Poullaouen 3 E 270/39/10 (1903)
	1904   => '1354652',            # Mariage Poullaouen 3 E 270/39/11 (1904)
    },

    '3E270_0040' => {			# Décès Poullaouen 3 E 270 40   1899-1908
	1899   => '1354701',            # Décès Poullaouen 3 E 270/40/1 (1899)
	1900   => '1354702',            # Décès Poullaouen 3 E 270/40/2 (1900)
	1901   => '1354703',            # Décès Poullaouen 3 E 270/40/3 (1901)
	1902   => '1354704',            # Décès Poullaouen 3 E 270/40/4 (1902)
	1903   => '1354705',            # Décès Poullaouen 3 E 270/40/5 (1903)
	1904   => '1354706',            # Décès Poullaouen 3 E 270/40/6 (1904)
	1905   => '1354707',            # Décès Poullaouen 3 E 270/40/7 (1905)
	1906   => '1354708',            # Décès Poullaouen 3 E 270/40/8 (1906)
	1907   => '1354709',            # Décès Poullaouen 3 E 270/40/9 (1907)
	1908   => '1354710',            # Décès Poullaouen 3 E 270/40/10 (1908)
    },

    '3E270_0041' => {			# Naissance Poullaouen 3 E 270 41   1904-1911
	1904   => '1354594',            # Naissance Poullaouen 3 E 270/41/1 (1904)
	1905   => '1354595',            # Naissance Poullaouen 3 E 270/41/2 (1905)
	1906   => '1354596',            # Naissance Poullaouen 3 E 270/41/3 (1906)
	1907   => '1354597',            # Naissance Poullaouen 3 E 270/41/4 (1907)
	1908   => '1354598',            # Naissance Poullaouen 3 E 270/41/5 (1908)
	1909   => '1354599',            # Naissance Poullaouen 3 E 270/41/6 (1909)
	1910   => '1354600',            # Naissance Poullaouen 3 E 270/41/7 (1910)
	1911   => '1354601',            # Naissance Poullaouen 3 E 270/41/8 (1911)
    },

    '3E270_0042' => {			# Naissance Poullaouen 3 E 270 42   1912-1919
	1912   => '1354603',            # Naissance Poullaouen 3 E 270/42/1 (1912)
	1913   => '1354604',            # Naissance Poullaouen 3 E 270/42/2 (1913)
	1914   => '1354605',            # Naissance Poullaouen 3 E 270/42/3 (1914)
	1915   => '1354606',            # Naissance Poullaouen 3 E 270/42/4 (1915)
	1916   => '1354607',            # Naissance Poullaouen 3 E 270/42/5 (1916)
	1917   => '1354608',            # Naissance Poullaouen 3 E 270/42/6 (1917)
	1918   => '1354609',            # Naissance Poullaouen 3 E 270/42/7 (1918)
	1919   => '1354610',            # Naissance Poullaouen 3 E 270/42/8 (1919)
    },

    '3E270_0043' => {			# Naissance Poullaouen 3 E 270 43   1920-1925
	1920   => '1354612',            # Naissance Poullaouen 3 E 270/43/1 (1920)
	1921   => '1354613',            # Naissance Poullaouen 3 E 270/43/2 (1921)
	1922   => '1354614',            # Naissance Poullaouen 3 E 270/43/3 (1922)
	1923   => '1354615',            # Naissance Poullaouen 3 E 270/43/4 (1923)
	1924   => '1354616',            # Naissance Poullaouen 3 E 270/43/5 (1924)
	1925   => '1354617',            # Naissance Poullaouen 3 E 270/43/6 (1925)
    },

    '3E270_0045' => {			# Mariage Poullaouen 3 E 270 45   1905-1913
	1905   => '1354654',            # Mariage Poullaouen 3 E 270/45/1 (1905)
	1906   => '1354655',            # Mariage Poullaouen 3 E 270/45/2 (1906)
	1907   => '1354656',            # Mariage Poullaouen 3 E 270/45/3 (1907)
	1908   => '1354657',            # Mariage Poullaouen 3 E 270/45/4 (1908)
	1909   => '1354658',            # Mariage Poullaouen 3 E 270/45/5 (1909)
	1910   => '1354659',            # Mariage Poullaouen 3 E 270/45/6 (1910)
	1911   => '1354660',            # Mariage Poullaouen 3 E 270/45/7 (1911)
	1912   => '1354661',            # Mariage Poullaouen 3 E 270/45/8 (1912)
	1913   => '1354662',            # Mariage Poullaouen 3 E 270/45/9 (1913)
    },

    '3E270_0046' => {			# Mariage Poullaouen 3 E 270 46   1914-1923
	1914   => '1354664',            # Mariage Poullaouen 3 E 270/46/1 (1914)
	1915   => '1354665',            # Mariage Poullaouen 3 E 270/46/2 (1915)
	1916   => '1354666',            # Mariage Poullaouen 3 E 270/46/3 (1916)
	1917   => '1354667',            # Mariage Poullaouen 3 E 270/46/4 (1917)
	1918   => '1354668',            # Mariage Poullaouen 3 E 270/46/5 (1918)
	1919   => '1354669',            # Mariage Poullaouen 3 E 270/46/6 (1919)
	1920   => '1354670',            # Mariage Poullaouen 3 E 270/46/7 (1920)
	1921   => '1354671',            # Mariage Poullaouen 3 E 270/46/8 (1921)
	1922   => '1354672',            # Mariage Poullaouen 3 E 270/46/9 (1922)
	1923   => '1354673',            # Mariage Poullaouen 3 E 270/46/10 (1923)
    },

    '3E270_0047' => {			# Mariage Poullaouen 3 E 270 47   1924-1936
	1924   => '1354675',            # Mariage Poullaouen 3 E 270/47/1 (1924)
	1925   => '1354676',            # Mariage Poullaouen 3 E 270/47/2 (1925)
	1926   => '1354677',            # Mariage Poullaouen 3 E 270/47/3 (1926)
	1927   => '1354678',            # Mariage Poullaouen 3 E 270/47/4 (1927)
	1928   => '1354679',            # Mariage Poullaouen 3 E 270/47/5 (1928)
	1929   => '1354680',            # Mariage Poullaouen 3 E 270/47/6 (1929)
	1930   => '1354681',            # Mariage Poullaouen 3 E 270/47/7 (1930)
	1931   => '1354682',            # Mariage Poullaouen 3 E 270/47/8 (1931)
	1932   => '1354683',            # Mariage Poullaouen 3 E 270/47/10 (1932)
	1933   => '1354684',            # Mariage Poullaouen 3 E 270/47/11 (1933)
	1934   => '1354685',            # Mariage Poullaouen 3 E 270/47/12 (1934)
	1935   => '1354686',            # Mariage Poullaouen 3 E 270/47/13 (1935)
	1936   => '1354687',            # Mariage Poullaouen 3 E 270/47/14 (1936)
    },

    '3E270_0048' => {			# Décès Poullaouen 3 E 270 48   1909-1916
	1909   => '1354712',            # Décès Poullaouen 3 E 270/48/1 (1909)
	1910   => '1354713',            # Décès Poullaouen 3 E 270/48/2 (1910)
	1911   => '1354714',            # Décès Poullaouen 3 E 270/48/3 (1911)
	1912   => '1354715',            # Décès Poullaouen 3 E 270/48/4 (1912)
	1913   => '1354716',            # Décès Poullaouen 3 E 270/48/5 (1913)
	1914   => '1354717',            # Décès Poullaouen 3 E 270/48/6 (1914)
	1915   => '1354718',            # Décès Poullaouen 3 E 270/48/7 (1915)
	1916   => '1354719',            # Décès Poullaouen 3 E 270/48/8 (1916)
    },

    '3E270_0049' => {			# Décès Poullaouen 3 E 270 49   1917-1925
	1917   => '1354721',            # Décès Poullaouen 3 E 270/49/1 (1917)
	1918   => '1354722',            # Décès Poullaouen 3 E 270/49/2 (1918)
	1919   => '1354723',            # Décès Poullaouen 3 E 270/49/3 (1919)
	1920   => '1354724',            # Décès Poullaouen 3 E 270/49/4 (1920)
	1921   => '1354725',            # Décès Poullaouen 3 E 270/49/5 (1921)
	1922   => '1354726',            # Décès Poullaouen 3 E 270/49/6 (1922)
	1923   => '1354727',            # Décès Poullaouen 3 E 270/49/7 (1923)
	1924   => '1354728',            # Décès Poullaouen 3 E 270/49/8 (1924)
	1925   => '1354729',            # Décès Poullaouen 3 E 270/49/9 (1925)
    },

    '3E270_0050' => {			# Décès Poullaouen 3 E 270 50   1926-1936
	1926   => '1354731',            # Décès Poullaouen 3 E 270/50/1 (1926)
	1927   => '1354732',            # Décès Poullaouen 3 E 270/50/2 (1927)
	1928   => '1354733',            # Décès Poullaouen 3 E 270/50/3 (1928)
	1929   => '1354734',            # Décès Poullaouen 3 E 270/50/4 (1929)
	1930   => '1354735',            # Décès Poullaouen 3 E 270/50/5 (1930)
	1931   => '1354736',            # Décès Poullaouen 3 E 270/50/6 (1931)
	1932   => '1354737',            # Décès Poullaouen 3 E 270/50/7 (1932)
	1933   => '1354738',            # Décès Poullaouen 3 E 270/50/8 (1933)
	1934   => '1354739',            # Décès Poullaouen 3 E 270/50/9 (1934)
	1935   => '1354740',            # Décès Poullaouen 3 E 270/50/10 (1935)
	1936   => '1354741',            # Décès Poullaouen 3 E 270/50/11 (1936)
    },

    # NMD Rosnoën
    '3E296_0005' => '1039969.1359576',            # Naissance Rosnoën 3 E 296 5 (1793-1812)
    '3E296_0006' => '1039970.1359577',            # Naissance Rosnoën 3 E 296 6 (1813-1822)
    '3E296_0007' => '1039971.1359578',            # Naissance Rosnoën 3 E 296 7 (1823-1832)
    '3E296_0008' => '1039972.1359579',            # Naissance Rosnoën 3 E 296 8 (1833-1842)
    '3E296_0009' => '1039973.1359580',            # Naissance Rosnoën 3 E 296 9 (1843-1852)
    '3E296_0010' => '1039974.1359581',            # Naissance Rosnoën 3 E 296 10 (1853-1862)
    '3E296_0011' => '1039975.1359582',            # Naissance Rosnoën 3 E 296 11 (1863-1869)
    '3E296_0012' => '1039976.1359583',            # Naissance Rosnoën 3 E 296 12 (1870-1884)
    '3E296_0013' => '1039977.1359626',            # Mariage publication de mariage promesse de mariage Rosnoën 3 E 296 13 (1793-an VI, an IX-1812)
    '3E296_0014' => '1039978.1359627',            # Mariage Rosnoën 3 E 296 14 (1813-1822)
    '3E296_0015' => '1039979.1359628',            # Mariage Rosnoën 3 E 296 15 (1823-1832)
    '3E296_0016' => '1039980.1359629',            # Mariage Rosnoën 3 E 296 16 (1833-1842)
    '3E296_0017' => '1039981.1359630',            # Mariage Rosnoën 3 E 296 17 (1843-1852)
    '3E296_0018' => '1039982.1359631',            # Mariage Rosnoën 3 E 296 18 (1853-1862)
    '3E296_0019' => '1039983.1359632',            # Mariage Rosnoën 3 E 296 19 (1863-1869)
    '3E296_0020' => '1039984.1359633',            # Mariage Rosnoën 3 E 296 20 (1870-1885)
    '3E296_0021' => '1039985.1359673',            # Décès Rosnoën 3 E 296 21 (1793-1812)
    '3E296_0022' => '1039986.1359674',            # Décès Rosnoën 3 E 296 22 (1813-1822)
    '3E296_0023' => '1039987.1359675',            # Décès Rosnoën 3 E 296 23 (1823-1832)
    '3E296_0024' => '1039988.1359676',            # Décès Rosnoën 3 E 296 24 (1833-1842)
    '3E296_0025' => '1039989.1359677',            # Décès Rosnoën 3 E 296 25 (1843-1852)
    '3E296_0026' => '1039990.1359678',            # Décès Rosnoën 3 E 296 26 (1853-1862)
    '3E296_0027' => '1039991.1359679',            # Décès Rosnoën 3 E 296 27 (1863-1869)
    '3E296_0028' => '1039992.1359680',            # Décès Rosnoën 3 E 296 28 (1870-1884)
    '3E296_0029' => '1039993.1359584',            # Naissance Rosnoën 3 E 296 29 (1885-1898)
    '3E296_0030' => '1039994.1359634',            # Mariage Rosnoën 3 E 296 30 (1886-1901)
    '3E296_0031' => '1039995.1359681',            # Décès Rosnoën 3 E 296 31 (1885-1898)
    '3E296_0032' => {			# Naissance Rosnoën 3 E 296 32   1899-1916
	1899   => '1359586',            # Naissance Rosnoën 3 E 296/32/1 (1899)
	1900   => '1359587',            # Naissance Rosnoën 3 E 296/32/2 (1900)
	1901   => '1359588',            # Naissance Rosnoën 3 E 296/32/3 (1901)
	1902   => '1359589',            # Naissance Rosnoën 3 E 296/32/4 (1902)
	1903   => '1359590',            # Naissance Rosnoën 3 E 296/32/5 (1903)
	1904   => '1359591',            # Naissance Rosnoën 3 E 296/32/6 (1904)
	1905   => '1359592',            # Naissance Rosnoën 3 E 296/32/7 (1905)
	1906   => '1359593',            # Naissance Rosnoën 3 E 296/32/8 (1906)
	1907   => '1359594',            # Naissance Rosnoën 3 E 296/32/9 (1907)
	1908   => '1359595',            # Naissance Rosnoën 3 E 296/32/10 (1908)
	1909   => '1359596',            # Naissance Rosnoën 3 E 296/32/11 (1909)
	1910   => '1359597',            # Naissance Rosnoën 3 E 296/32/12 (1910)
	1911   => '1359598',            # Naissance Rosnoën 3 E 296/32/13 (1911)
	1912   => '1359599',            # Naissance Rosnoën 3 E 296/32/14 (1912)
	1913   => '1359600',            # Naissance Rosnoën 3 E 296/32/15 (1913)
	1914   => '1359601',            # Naissance Rosnoën 3 E 296/32/16 (1914)
	1915   => '1359602',            # Naissance Rosnoën 3 E 296/32/17 (1915)
	1916   => '1359603',            # Naissance Rosnoën 3 E 296/32/18 (1916)
    },

    '3E296_0033' => {			# Naissance Rosnoën 3 E 296 33   1917-1925
	1917   => '1359605',            # Naissance Rosnoën 3 E 296/33/1 (1917)
	1918   => '1359606',            # Naissance Rosnoën 3 E 296/33/2 (1918)
	1919   => '1359607',            # Naissance Rosnoën 3 E 296/33/3 (1919)
	1920   => '1359608',            # Naissance Rosnoën 3 E 296/33/4 (1920)
	1921   => '1359609',            # Naissance Rosnoën 3 E 296/33/5 (1921)
	1922   => '1359610',            # Naissance Rosnoën 3 E 296/33/6 (1922)
	1923   => '1359611',            # Naissance Rosnoën 3 E 296/33/7 (1923)
	1924   => '1359612',            # Naissance Rosnoën 3 E 296/33/8 (1924)
	1925   => '1359613',            # Naissance Rosnoën 3 E 296/33/9 (1925)
    },

    '3E296_0034' => {			# Mariage Rosnoën 3 E 296 34   1902-1919
	1902   => '1359636',            # Mariage Rosnoën 3 E 296/34/1 (1902)
	1903   => '1359637',            # Mariage Rosnoën 3 E 296/34/2 (1903)
	1904   => '1359638',            # Mariage Rosnoën 3 E 296/34/3 (1904)
	1905   => '1359639',            # Mariage Rosnoën 3 E 296/34/4 (1905)
	1906   => '1359640',            # Mariage Rosnoën 3 E 296/34/5 (1906)
	1907   => '1359641',            # Mariage Rosnoën 3 E 296/34/6 (1907)
	1908   => '1359642',            # Mariage Rosnoën 3 E 296/34/7 (1908)
	1909   => '1359643',            # Mariage Rosnoën 3 E 296/34/8 (1909)
	1910   => '1359644',            # Mariage Rosnoën 3 E 296/34/9 (1910)
	1911   => '1359645',            # Mariage Rosnoën 3 E 296/34/10 (1911)
	1912   => '1359646',            # Mariage Rosnoën 3 E 296/34/11 (1912)
	1913   => '1359647',            # Mariage Rosnoën 3 E 296/34/12 (1913)
	1914   => '1359648',            # Mariage Rosnoën 3 E 296/34/13 (1914)
	1915   => '1359649',            # Mariage Rosnoën 3 E 296/34/14 (1915)
	1916   => '1359650',            # Mariage Rosnoën 3 E 296/34/15 (1916)
	1917   => '1359651',            # Mariage Rosnoën 3 E 296/34/16 (1917)
	1918   => '1359652',            # Mariage Rosnoën 3 E 296/34/17 (1918)
	1919   => '1359653',            # Mariage Rosnoën 3 E 296/34/18 (1919)
    },

    '3E296_0035' => {			# Mariage Rosnoën 3 E 296 35   1920-1936
	1920   => '1359655',            # Mariage Rosnoën 3 E 296/35/1 (1920)
	1921   => '1359656',            # Mariage Rosnoën 3 E 296/35/2 (1921)
	1922   => '1359657',            # Mariage Rosnoën 3 E 296/35/3 (1922)
	1923   => '1359658',            # Mariage Rosnoën 3 E 296/35/4 (1923)
	1924   => '1359659',            # Mariage Rosnoën 3 E 296/35/5 (1924)
	1925   => '1359660',            # Mariage Rosnoën 3 E 296/35/6 (1925)
	1926   => '1359661',            # Mariage Rosnoën 3 E 296/35/7 (1926)
	1927   => '1359662',            # Mariage Rosnoën 3 E 296/35/8 (1927)
	1928   => '1359663',            # Mariage Rosnoën 3 E 296/35/9 (1928)
	1929   => '1359664',            # Mariage Rosnoën 3 E 296/35/10 (1929)
	1930   => '1359665',            # Mariage Rosnoën 3 E 296/35/11 (1930)
	1931   => '1359666',            # Mariage Rosnoën 3 E 296/35/12 (1931)
	1932   => '1359667',            # Mariage Rosnoën 3 E 296/35/13 (1932)
	1933   => '1359668',            # Mariage Rosnoën 3 E 296/35/14 (1933)
	1934   => '1359669',            # Mariage Rosnoën 3 E 296/35/15 (1934)
	1935   => '1359670',            # Mariage Rosnoën 3 E 296/35/16 (1935)
	1936   => '1359671',            # Mariage Rosnoën 3 E 296/35/17 (1936)
    },

    '3E296_0036' => {			# Décès Rosnoën 3 E 296 36   1899-1917
	1899   => '1359683',            # Décès Rosnoën 3 E 296/36/1 (1899)
	1900   => '1359684',            # Décès Rosnoën 3 E 296/36/2 (1900)
	1901   => '1359685',            # Décès Rosnoën 3 E 296/36/3 (1901)
	1902   => '1359686',            # Décès Rosnoën 3 E 296/36/4 (1902)
	1903   => '1359687',            # Décès Rosnoën 3 E 296/36/5 (1903)
	1904   => '1359688',            # Décès Rosnoën 3 E 296/36/6 (1904)
	1905   => '1359689',            # Décès Rosnoën 3 E 296/36/7 (1905)
	1906   => '1359690',            # Décès Rosnoën 3 E 296/36/8 (1906)
	1907   => '1359691',            # Décès Rosnoën 3 E 296/36/9 (1907)
	1908   => '1359692',            # Décès Rosnoën 3 E 296/36/10 (1908)
	1909   => '1359693',            # Décès Rosnoën 3 E 296/36/11 (1909)
	1910   => '1359694',            # Décès Rosnoën 3 E 296/36/12 (1910)
	1911   => '1359695',            # Décès Rosnoën 3 E 296/36/13 (1911)
	1912   => '1359696',            # Décès Rosnoën 3 E 296/36/14 (1912)
	1913   => '1359697',            # Décès Rosnoën 3 E 296/36/15 (1913)
	1914   => '1359698',            # Décès Rosnoën 3 E 296/36/16 (1914)
	1915   => '1359699',            # Décès Rosnoën 3 E 296/36/17 (1915)
	1916   => '1359700',            # Décès Rosnoën 3 E 296/36/18 (1916)
	1917   => '1359701',            # Décès Rosnoën 3 E 296/36/19 (1917)
    },

    '3E296_0037' => {			# Décès Rosnoën 3 E 296 37   1918-1936
	1918   => '1359703',            # Décès Rosnoën 3 E 296/37/1 (1918)
	1919   => '1359704',            # Décès Rosnoën 3 E 296/37/2 (1919)
	1920   => '1359705',            # Décès Rosnoën 3 E 296/37/3 (1920)
	1921   => '1359706',            # Décès Rosnoën 3 E 296/37/4 (1921)
	1922   => '1359707',            # Décès Rosnoën 3 E 296/37/5 (1922)
	1923   => '1359708',            # Décès Rosnoën 3 E 296/37/6 (1923)
	1924   => '1359709',            # Décès Rosnoën 3 E 296/37/7 (1924)
	1925   => '1359710',            # Décès Rosnoën 3 E 296/37/8 (1925)
	1926   => '1359711',            # Décès Rosnoën 3 E 296/37/9 (1926)
	1927   => '1359712',            # Décès Rosnoën 3 E 296/37/10 (1927)
	1928   => '1359713',            # Décès Rosnoën 3 E 296/37/11 (1928)
	1929   => '1359714',            # Décès Rosnoën 3 E 296/37/12 (1929)
	1930   => '1359715',            # Décès Rosnoën 3 E 296/37/13 (1930)
	1931   => '1359716',            # Décès Rosnoën 3 E 296/37/14 (1931)
	1932   => '1359717',            # Décès Rosnoën 3 E 296/37/15 (1932)
	1933   => '1359718',            # Décès Rosnoën 3 E 296/37/16 (1933)
	1934   => '1359719',            # Décès Rosnoën 3 E 296/37/17 (1934)
	1935   => '1359720',            # Décès Rosnoën 3 E 296/37/18 (1935)
	1936   => '1359721',            # Décès Rosnoën 3 E 296/37/19 (1936)
    },

    # NMD Quéménéven
    '3E272_0005' => {			# Naissance Quéménéven 3 E 272 5   AN02-1812
	'AN02' => '1355251',            # Naissance Quéménéven 3 E 272/5/1 (1793 - an II)
	'AN03' => '1355252',            # Naissance Quéménéven 3 E 272/5/2 (an III)
	'AN04' => '1355253',            # Naissance Quéménéven 3 E 272/5/3 (an IV)
	'AN05' => '1355254',            # Naissance Quéménéven 3 E 272/5/4 (an V)
	'AN06' => '1355255',            # Naissance Quéménéven 3 E 272/5/5 (an VI)
	'AN07' => '1355256',            # Naissance Quéménéven 3 E 272/5/6 (an VII)
	'AN08' => '1355257',            # Naissance Quéménéven 3 E 272/5/7 (an VIII)
	'AN09' => '1355258',            # Naissance Quéménéven 3 E 272/5/8 (an IX)
	'AN10' => '1355259',            # Naissance Quéménéven 3 E 272/5/9 (an X)
	'AN11' => '1355260',            # Naissance Quéménéven 3 E 272/5/10 (an XI)
	'AN12' => '1355261',            # Naissance Quéménéven 3 E 272/5/11 (an XII)
	'AN13' => '1355262',            # Naissance Quéménéven 3 E 272/5/12 (an XIII)
	'AN14' => '1355263',            # Naissance Quéménéven 3 E 272/5/13 (an XIV - 1806)
	1807   => '1355264',            # Naissance Quéménéven 3 E 272/5/14 (1807)
	1808   => '1355265',            # Naissance Quéménéven 3 E 272/5/15 (1808)
	1809   => '1355266',            # Naissance Quéménéven 3 E 272/5/16 (1809)
	1810   => '1355267',            # Naissance Quéménéven 3 E 272/5/17 (1810)
	1811   => '1355268',            # Naissance Quéménéven 3 E 272/5/18 (1811)
	1812   => '1355269',            # Naissance Quéménéven 3 E 272/5/19 (1812)
    },

    '3E272_0006' => {			# Naissance Quéménéven 3 E 272 6   1813-1832
	1813   => '1355271',            # Naissance Quéménéven 3 E 272/6/1 (1813)
	1814   => '1355272',            # Naissance Quéménéven 3 E 272/6/2 (1814)
	1815   => '1355273',            # Naissance Quéménéven 3 E 272/6/3 (1815)
	1816   => '1355274',            # Naissance Quéménéven 3 E 272/6/4 (1816)
	1817   => '1355275',            # Naissance Quéménéven 3 E 272/6/5 (1817)
	1818   => '1355276',            # Naissance Quéménéven 3 E 272/6/6 (1818)
	1819   => '1355277',            # Naissance Quéménéven 3 E 272/6/7 (1819)
	1820   => '1355278',            # Naissance Quéménéven 3 E 272/6/8 (1820)
	1821   => '1355279',            # Naissance Quéménéven 3 E 272/6/9 (1821)
	1822   => '1355280',            # Naissance Quéménéven 3 E 272/6/10 (1822)
	1823   => '1355281',            # Naissance Quéménéven 3 E 272/6/11 (1823)
	1824   => '1355282',            # Naissance Quéménéven 3 E 272/6/12 (1824)
	1825   => '1355283',            # Naissance Quéménéven 3 E 272/6/13 (1825)
	1826   => '1355284',            # Naissance Quéménéven 3 E 272/6/14 (1826)
	1827   => '1355285',            # Naissance Quéménéven 3 E 272/6/15 (1827)
	1828   => '1355286',            # Naissance Quéménéven 3 E 272/6/16 (1828)
	1829   => '1355287',            # Naissance Quéménéven 3 E 272/6/17 (1829)
	1830   => '1355288',            # Naissance Quéménéven 3 E 272/6/18 (1830)
	1831   => '1355289',            # Naissance Quéménéven 3 E 272/6/19 (1831)
	1832   => '1355290',            # Naissance Quéménéven 3 E 272/6/20 (1832)
    },

    '3E272_0007' => {			# Naissance Quéménéven 3 E 272 7   1833-1842
	1833   => '1355292',            # Naissance Quéménéven 3 E 272/7/1 (1833)
	1834   => '1355293',            # Naissance Quéménéven 3 E 272/7/2 (1834)
	1835   => '1355294',            # Naissance Quéménéven 3 E 272/7/3 (1835)
	1836   => '1355295',            # Naissance Quéménéven 3 E 272/7/4 (1836)
	1837   => '1355296',            # Naissance Quéménéven 3 E 272/7/5 (1837)
	1838   => '1355297',            # Naissance Quéménéven 3 E 272/7/6 (1838)
	1839   => '1355298',            # Naissance Quéménéven 3 E 272/7/7 (1839)
	1840   => '1355299',            # Naissance Quéménéven 3 E 272/7/8 (1840)
	1841   => '1355300',            # Naissance Quéménéven 3 E 272/7/9 (1841)
	1842   => '1355301',            # Naissance Quéménéven 3 E 272/7/10 (1842)
    },

    '3E272_0008' => {			# Naissance Quéménéven 3 E 272 8   1843-1852
	1843   => '1355303',            # Naissance Quéménéven 3 E 272/8/1 (1843)
	1844   => '1355304',            # Naissance Quéménéven 3 E 272/8/2 (1844)
	1845   => '1355305',            # Naissance Quéménéven 3 E 272/8/3 (1845)
	1846   => '1355306',            # Naissance Quéménéven 3 E 272/8/4 (1846)
	1847   => '1355307',            # Naissance Quéménéven 3 E 272/8/5 (1847)
	1848   => '1355308',            # Naissance Quéménéven 3 E 272/8/6 (1848)
	1849   => '1355309',            # Naissance Quéménéven 3 E 272/8/7 (1849)
	1850   => '1355310',            # Naissance Quéménéven 3 E 272/8/8 (1850)
	1851   => '1355311',            # Naissance Quéménéven 3 E 272/8/9 (1851)
	1852   => '1355312',            # Naissance Quéménéven 3 E 272/8/10 (1852)
    },

    '3E272_0009' => {			# Naissance Quéménéven 3 E 272 9   1853-1862
	1853   => '1355314',            # Naissance Quéménéven 3 E 272/9/1 (1853)
	1854   => '1355315',            # Naissance Quéménéven 3 E 272/9/2 (1854)
	1855   => '1355316',            # Naissance Quéménéven 3 E 272/9/3 (1855)
	1856   => '1355317',            # Naissance Quéménéven 3 E 272/9/4 (1856)
	1857   => '1355318',            # Naissance Quéménéven 3 E 272/9/5 (1857)
	1858   => '1355319',            # Naissance Quéménéven 3 E 272/9/6 (1858)
	1859   => '1355320',            # Naissance Quéménéven 3 E 272/9/7 (1859)
	1860   => '1355321',            # Naissance Quéménéven 3 E 272/9/8 (1860)
	1861   => '1355322',            # Naissance Quéménéven 3 E 272/9/9 (1861)
	1862   => '1355323',            # Naissance Quéménéven 3 E 272/9/10 (1862)
    },

    '3E272_0010' => {			# Naissance Quéménéven 3 E 272 10   1863-1869
	1863   => '1355325',            # Naissance Quéménéven 3 E 272/10/1 (1863)
	1864   => '1355326',            # Naissance Quéménéven 3 E 272/10/2 (1864)
	1865   => '1355327',            # Naissance Quéménéven 3 E 272/10/3 (1865)
	1866   => '1355328',            # Naissance Quéménéven 3 E 272/10/4 (1866)
	1867   => '1355329',            # Naissance Quéménéven 3 E 272/10/5 (1867)
	1868   => '1355330',            # Naissance Quéménéven 3 E 272/10/6 (1868)
	1869   => '1355331',            # Naissance Quéménéven 3 E 272/10/7 (1869)
    },

    '3E272_0011' => {			# Naissance Quéménéven 3 E 272 11   1870-1883
	1870   => '1355333',            # Naissance Quéménéven 3 E 272/11/1 (1870)
	1871   => '1355334',            # Naissance Quéménéven 3 E 272/11/2 (1871)
	1872   => '1355335',            # Naissance Quéménéven 3 E 272/11/3 (1872)
	1873   => '1355336',            # Naissance Quéménéven 3 E 272/11/4 (1873)
	1874   => '1355337',            # Naissance Quéménéven 3 E 272/11/5 (1874)
	1875   => '1355338',            # Naissance Quéménéven 3 E 272/11/6 (1875)
	1876   => '1355339',            # Naissance Quéménéven 3 E 272/11/7 (1876)
	1877   => '1355340',            # Naissance Quéménéven 3 E 272/11/8 (1877)
	1878   => '1355341',            # Naissance Quéménéven 3 E 272/11/9 (1878)
	1879   => '1355342',            # Naissance Quéménéven 3 E 272/11/10 (1879)
	1880   => '1355343',            # Naissance Quéménéven 3 E 272/11/11 (1880)
	1881   => '1355344',            # Naissance Quéménéven 3 E 272/11/12 (1881)
	1882   => '1355345',            # Naissance Quéménéven 3 E 272/11/13 (1882)
	1883   => '1355346',            # Naissance Quéménéven 3 E 272/11/14 (1883)
    },

    '3E272_0012' => {			# Naissance Quéménéven 3 E 272 12   1884-1894
	1884   => '1355348',            # Naissance Quéménéven 3 E 272/12/1 (1884)
	1885   => '1355349',            # Naissance Quéménéven 3 E 272/12/2 (1885)
	1886   => '1355350',            # Naissance Quéménéven 3 E 272/12/3 (1886)
	1887   => '1355351',            # Naissance Quéménéven 3 E 272/12/4 (1887)
	1888   => '1355352',            # Naissance Quéménéven 3 E 272/12/5 (1888)
	1889   => '1355353',            # Naissance Quéménéven 3 E 272/12/6 (1889)
	1890   => '1355354',            # Naissance Quéménéven 3 E 272/12/7 (1890)
	1891   => '1355355',            # Naissance Quéménéven 3 E 272/12/8 (1891)
	1892   => '1355356',            # Naissance Quéménéven 3 E 272/12/9 (1892)
	1893   => '1355357',            # Naissance Quéménéven 3 E 272/12/10 (1893)
	1894   => '1355358',            # Naissance Quéménéven 3 E 272/12/11 (1894)
    },

    '3E272_0013' => {			# Mariage Quéménéven 3 E 272 13   AN02-1812
	'AN02' => '1355406',            # Mariage Quéménéven 3 E 272/13/1 (1793 - an II)
	'AN03' => '1355407',            # Mariage Quéménéven 3 E 272/13/2 (an III)
	'AN04' => '1355408',            # Mariage Quéménéven 3 E 272/13/3 (an IV)
	'AN05' => '1355409',            # Mariage Quéménéven 3 E 272/13/4 (an V)
	'AN06' => '1355410',            # Mariage Quéménéven 3 E 272/13/5 (an VI)
	'AN09' => '1355411',            # Mariage Quéménéven 3 E 272/13/6 (an IX)
	'AN10' => '1355412',            # Mariage Quéménéven 3 E 272/13/7 (an X)
	'AN11' => '1355413',            # Mariage Quéménéven 3 E 272/13/8 (an XI)
	'AN12' => '1355414',            # Mariage Quéménéven 3 E 272/13/9 (an XII)
	'AN13' => '1355415',            # Mariage Quéménéven 3 E 272/13/10 (an XIII)
	'AN14' => '1355416',            # Mariage Quéménéven 3 E 272/13/11 (an XIV - 1806)
	1807   => '1355417',            # Mariage Quéménéven 3 E 272/13/12 (1807)
	1808   => '1355418',            # Mariage Quéménéven 3 E 272/13/13 (1808)
	1809   => '1355419',            # Mariage Quéménéven 3 E 272/13/14 (1809)
	1810   => '1355420',            # Mariage Quéménéven 3 E 272/13/15 (1810)
	1811   => '1355421',            # Mariage Quéménéven 3 E 272/13/16 (1811)
	1812   => '1355422',            # Mariage Quéménéven 3 E 272/13/17 (1812)
    },

    '3E272_0014' => {			# Mariage Quéménéven 3 E 272 14   1813-1832
	1813   => '1355424',            # Mariage Quéménéven 3 E 272/14/1 (1813)
	1814   => '1355425',            # Mariage Quéménéven 3 E 272/14/2 (1814)
	1815   => '1355426',            # Mariage Quéménéven 3 E 272/14/3 (1815)
	1816   => '1355427',            # Mariage Quéménéven 3 E 272/14/4 (1816)
	1817   => '1355428',            # Mariage Quéménéven 3 E 272/14/5 (1817)
	1818   => '1355429',            # Mariage Quéménéven 3 E 272/14/6 (1818)
	1819   => '1355430',            # Mariage Quéménéven 3 E 272/14/7 (1819)
	1820   => '1355431',            # Mariage Quéménéven 3 E 272/14/8 (1820)
	1821   => '1355432',            # Mariage Quéménéven 3 E 272/14/9 (1821)
	1822   => '1355433',            # Mariage Quéménéven 3 E 272/14/10 (1822)
	1823   => '1355434',            # Mariage Quéménéven 3 E 272/14/11 (1823)
	1824   => '1355435',            # Mariage Quéménéven 3 E 272/14/12 (1824)
	1825   => '1355436',            # Mariage Quéménéven 3 E 272/14/13 (1825)
	1826   => '1355437',            # Mariage Quéménéven 3 E 272/14/14 (1826)
	1827   => '1355438',            # Mariage Quéménéven 3 E 272/14/15 (1827)
	1828   => '1355439',            # Mariage Quéménéven 3 E 272/14/16 (1828)
	1829   => '1355440',            # Mariage Quéménéven 3 E 272/14/17 (1829)
	1830   => '1355441',            # Mariage Quéménéven 3 E 272/14/18 (1830)
	1831   => '1355442',            # Mariage Quéménéven 3 E 272/14/19 (1831)
	1832   => '1355443',            # Mariage Quéménéven 3 E 272/14/20 (1832)
    },

    '3E272_0015' => {			# Mariage Quéménéven 3 E 272 15   1833-1842
	1833   => '1355445',            # Mariage Quéménéven 3 E 272/15/1 (1833)
	1834   => '1355446',            # Mariage Quéménéven 3 E 272/15/2 (1834)
	1835   => '1355447',            # Mariage Quéménéven 3 E 272/15/3 (1835)
	1836   => '1355448',            # Mariage Quéménéven 3 E 272/15/4 (1836)
	1837   => '1355449',            # Mariage Quéménéven 3 E 272/15/5 (1837)
	1838   => '1355450',            # Mariage Quéménéven 3 E 272/15/6 (1838)
	1839   => '1355451',            # Mariage Quéménéven 3 E 272/15/7 (1839)
	1840   => '1355452',            # Mariage Quéménéven 3 E 272/15/8 (1840)
	1841   => '1355453',            # Mariage Quéménéven 3 E 272/15/9 (1841)
	1842   => '1355454',            # Mariage Quéménéven 3 E 272/15/10 (1842)
    },

    '3E272_0016' => {			# Mariage Quéménéven 3 E 272 16   1843-1852
	1843   => '1355456',            # Mariage Quéménéven 3 E 272/16/1 (1843)
	1844   => '1355457',            # Mariage Quéménéven 3 E 272/16/2 (1844)
	1845   => '1355458',            # Mariage Quéménéven 3 E 272/16/3 (1845)
	1846   => '1355459',            # Mariage Quéménéven 3 E 272/16/4 (1846)
	1847   => '1355460',            # Mariage Quéménéven 3 E 272/16/5 (1847)
	1848   => '1355461',            # Mariage Quéménéven 3 E 272/16/6 (1848)
	1849   => '1355462',            # Mariage Quéménéven 3 E 272/16/7 (1849)
	1850   => '1355463',            # Mariage Quéménéven 3 E 272/16/8 (1850)
	1851   => '1355464',            # Mariage Quéménéven 3 E 272/16/9 (1851)
	1852   => '1355465',            # Mariage Quéménéven 3 E 272/16/10 (1852)
    },

    '3E272_0017' => {			# Mariage Quéménéven 3 E 272 17   1853-1862
	1853   => '1355467',            # Mariage Quéménéven 3 E 272/17/1 (1853)
	1854   => '1355468',            # Mariage Quéménéven 3 E 272/17/2 (1854)
	1855   => '1355469',            # Mariage Quéménéven 3 E 272/17/3 (1855)
	1856   => '1355470',            # Mariage Quéménéven 3 E 272/17/4 (1856)
	1857   => '1355471',            # Mariage Quéménéven 3 E 272/17/5 (1857)
	1858   => '1355472',            # Mariage Quéménéven 3 E 272/17/6 (1858)
	1859   => '1355473',            # Mariage Quéménéven 3 E 272/17/7 (1859)
	1860   => '1355474',            # Mariage Quéménéven 3 E 272/17/8 (1860)
	1861   => '1355475',            # Mariage Quéménéven 3 E 272/17/9 (1861)
	1862   => '1355476',            # Mariage Quéménéven 3 E 272/17/10 (1862)
    },

    '3E272_0018' => {			# Mariage Quéménéven 3 E 272 18   1863-1869
	1863   => '1355478',            # Mariage Quéménéven 3 E 272/18/1 (1863)
	1864   => '1355479',            # Mariage Quéménéven 3 E 272/18/2 (1864)
	1865   => '1355480',            # Mariage Quéménéven 3 E 272/18/3 (1865)
	1866   => '1355481',            # Mariage Quéménéven 3 E 272/18/4 (1866)
	1867   => '1355482',            # Mariage Quéménéven 3 E 272/18/5 (1867)
	1868   => '1355483',            # Mariage Quéménéven 3 E 272/18/6 (1868)
	1869   => '1355484',            # Mariage Quéménéven 3 E 272/18/7 (1869)
    },

    '3E272_0019' => {			# Mariage Quéménéven 3 E 272 19   1870-1884
	1870   => '1355486',            # Mariage Quéménéven 3 E 272/19/1 (1870)
	1871   => '1355487',            # Mariage Quéménéven 3 E 272/19/2 (1871)
	1872   => '1355488',            # Mariage Quéménéven 3 E 272/19/3 (1872)
	1873   => '1355489',            # Mariage Quéménéven 3 E 272/19/4 (1873)
	1874   => '1355490',            # Mariage Quéménéven 3 E 272/19/5 (1874)
	1875   => '1355491',            # Mariage Quéménéven 3 E 272/19/6 (1875)
	1876   => '1355492',            # Mariage Quéménéven 3 E 272/19/7 (1876)
	1877   => '1355493',            # Mariage Quéménéven 3 E 272/19/8 (1877)
	1878   => '1355494',            # Mariage Quéménéven 3 E 272/19/9 (1878)
	1879   => '1355495',            # Mariage Quéménéven 3 E 272/19/10 (1879)
	1880   => '1355496',            # Mariage Quéménéven 3 E 272/19/11 (1880)
	1881   => '1355497',            # Mariage Quéménéven 3 E 272/19/12 (1881)
	1882   => '1355498',            # Mariage Quéménéven 3 E 272/19/13 (1882)
	1883   => '1355499',            # Mariage Quéménéven 3 E 272/19/14 (1883)
	1884   => '1355500',            # Mariage Quéménéven 3 E 272/19/15 (1884)
    },

    '3E272_0020' => {			# Décès Quéménéven 3 E 272 20   AN02-1812
	'AN02' => '1355559',            # Décès Quéménéven 3 E 272/20/1 (1793 - an II)
	'AN03' => '1355560',            # Décès Quéménéven 3 E 272/20/2 (an III)
	'AN04' => '1355561',            # Décès Quéménéven 3 E 272/20/3 (an IV)
	'AN05' => '1355562',            # Décès Quéménéven 3 E 272/20/4 (an V)
	'AN06' => '1355563',            # Décès Quéménéven 3 E 272/20/5 (an VI)
	'AN07' => '1355564',            # Décès Quéménéven 3 E 272/20/6 (an VII)
	'AN08' => '1355565',            # Décès Quéménéven 3 E 272/20/7 (an VIII)
	'AN09' => '1355566',            # Décès Quéménéven 3 E 272/20/8 (an IX)
	'AN10' => '1355567',            # Décès Quéménéven 3 E 272/20/9 (an X)
	'AN11' => '1355568',            # Décès Quéménéven 3 E 272/20/10 (an XI)
	'AN12' => '1355569',            # Décès Quéménéven 3 E 272/20/11 (an XII)
	'AN13' => '1355570',            # Décès Quéménéven 3 E 272/20/12 (an XIII)
	'AN14' => '1355571',            # Décès Quéménéven 3 E 272/20/13 (an XIV - 1806)
	1807   => '1355572',            # Décès Quéménéven 3 E 272/20/14 (1807)
	1808   => '1355573',            # Décès Quéménéven 3 E 272/20/15 (1808)
	1809   => '1355574',            # Décès Quéménéven 3 E 272/20/16 (1809)
	1810   => '1355575',            # Décès Quéménéven 3 E 272/20/17 (1810)
	1811   => '1355576',            # Décès Quéménéven 3 E 272/20/18 (1811)
	1812   => '1355577',            # Décès Quéménéven 3 E 272/20/19 (1812)
    },

    '3E272_0021' => {			# Décès Quéménéven 3 E 272 21   1813-1832
	1813   => '1355579',            # Décès Quéménéven 3 E 272/21/1 (1813)
	1814   => '1355580',            # Décès Quéménéven 3 E 272/21/2 (1814)
	1815   => '1355581',            # Décès Quéménéven 3 E 272/21/3 (1815)
	1816   => '1355582',            # Décès Quéménéven 3 E 272/21/4 (1816)
	1817   => '1355583',            # Décès Quéménéven 3 E 272/21/5 (1817)
	1818   => '1355584',            # Décès Quéménéven 3 E 272/21/6 (1818)
	1819   => '1355585',            # Décès Quéménéven 3 E 272/21/7 (1819)
	1820   => '1355586',            # Décès Quéménéven 3 E 272/21/8 (1820)
	1821   => '1355587',            # Décès Quéménéven 3 E 272/21/9 (1821)
	1822   => '1355588',            # Décès Quéménéven 3 E 272/21/10 (1822)
	1823   => '1355589',            # Décès Quéménéven 3 E 272/21/11 (1823)
	1824   => '1355590',            # Décès Quéménéven 3 E 272/21/12 (1824)
	1825   => '1355591',            # Décès Quéménéven 3 E 272/21/13 (1825)
	1826   => '1355592',            # Décès Quéménéven 3 E 272/21/14 (1826)
	1827   => '1355593',            # Décès Quéménéven 3 E 272/21/15 (1827)
	1828   => '1355594',            # Décès Quéménéven 3 E 272/21/16 (1828)
	1829   => '1355595',            # Décès Quéménéven 3 E 272/21/17 (1829)
	1830   => '1355596',            # Décès Quéménéven 3 E 272/21/18 (1830)
	1831   => '1355597',            # Décès Quéménéven 3 E 272/21/19 (1831)
	1832   => '1355598',            # Décès Quéménéven 3 E 272/21/20 (1832)
    },

    '3E272_0022' => {			# Décès Quéménéven 3 E 272 22   1833-1842
	1833   => '1355600',            # Décès Quéménéven 3 E 272/22/1 (1833)
	1834   => '1355601',            # Décès Quéménéven 3 E 272/22/2 (1834)
	1835   => '1355602',            # Décès Quéménéven 3 E 272/22/3 (1835)
	1836   => '1355603',            # Décès Quéménéven 3 E 272/22/4 (1836)
	1837   => '1355604',            # Décès Quéménéven 3 E 272/22/5 (1837)
	1838   => '1355605',            # Décès Quéménéven 3 E 272/22/6 (1838)
	1839   => '1355606',            # Décès Quéménéven 3 E 272/22/7 (1839)
	1840   => '1355607',            # Décès Quéménéven 3 E 272/22/8 (1840)
	1841   => '1355608',            # Décès Quéménéven 3 E 272/22/9 (1841)
	1842   => '1355609',            # Décès Quéménéven 3 E 272/22/10 (1842)
    },

    '3E272_0023' => {			# Décès Quéménéven 3 E 272 23   1843-1852
	1843   => '1355611',            # Décès Quéménéven 3 E 272/23/1 (1843)
	1844   => '1355612',            # Décès Quéménéven 3 E 272/23/2 (1844)
	1845   => '1355613',            # Décès Quéménéven 3 E 272/23/3 (1845)
	1846   => '1355614',            # Décès Quéménéven 3 E 272/23/4 (1846)
	1847   => '1355615',            # Décès Quéménéven 3 E 272/23/5 (1847)
	1848   => '1355616',            # Décès Quéménéven 3 E 272/23/6 (1848)
	1849   => '1355617',            # Décès Quéménéven 3 E 272/23/7 (1849)
	1850   => '1355618',            # Décès Quéménéven 3 E 272/23/8 (1850)
	1851   => '1355619',            # Décès Quéménéven 3 E 272/23/9 (1851)
	1852   => '1355620',            # Décès Quéménéven 3 E 272/23/10 (1852)
    },

    '3E272_0024' => {			# Décès Quéménéven 3 E 272 24   1853-1862
	1853   => '1355622',            # Décès Quéménéven 3 E 272/24/1 (1853)
	1854   => '1355623',            # Décès Quéménéven 3 E 272/24/2 (1854)
	1855   => '1355624',            # Décès Quéménéven 3 E 272/24/3 (1855)
	1856   => '1355625',            # Décès Quéménéven 3 E 272/24/4 (1856)
	1857   => '1355626',            # Décès Quéménéven 3 E 272/24/5 (1857)
	1858   => '1355627',            # Décès Quéménéven 3 E 272/24/6 (1858)
	1859   => '1355628',            # Décès Quéménéven 3 E 272/24/7 (1859)
	1860   => '1355629',            # Décès Quéménéven 3 E 272/24/8 (1860)
	1861   => '1355630',            # Décès Quéménéven 3 E 272/24/9 (1861)
	1862   => '1355631',            # Décès Quéménéven 3 E 272/24/10 (1862)
    },

    '3E272_0025' => {			# Décès Quéménéven 3 E 272 25   1863-1869
	1863   => '1355633',            # Décès Quéménéven 3 E 272/25/1 (1863)
	1864   => '1355634',            # Décès Quéménéven 3 E 272/25/2 (1864)
	1865   => '1355635',            # Décès Quéménéven 3 E 272/25/3 (1865)
	1866   => '1355636',            # Décès Quéménéven 3 E 272/25/4 (1866)
	1867   => '1355637',            # Décès Quéménéven 3 E 272/25/5 (1867)
	1868   => '1355638',            # Décès Quéménéven 3 E 272/25/6 (1868)
	1869   => '1355639',            # Décès Quéménéven 3 E 272/25/7 (1869)
    },

    '3E272_0026' => {			# Décès Quéménéven 3 E 272 26   1870-1884
	1870   => '1355641',            # Décès Quéménéven 3 E 272/26/1 (1870)
	1871   => '1355642',            # Décès Quéménéven 3 E 272/26/2 (1871)
	1872   => '1355643',            # Décès Quéménéven 3 E 272/26/3 (1872)
	1873   => '1355644',            # Décès Quéménéven 3 E 272/26/4 (1873)
	1874   => '1355645',            # Décès Quéménéven 3 E 272/26/5 (1874)
	1875   => '1355646',            # Décès Quéménéven 3 E 272/26/6 (1875)
	1876   => '1355647',            # Décès Quéménéven 3 E 272/26/7 (1876)
	1877   => '1355648',            # Décès Quéménéven 3 E 272/26/8 (1877)
	1878   => '1355649',            # Décès Quéménéven 3 E 272/26/9 (1878)
	1879   => '1355650',            # Décès Quéménéven 3 E 272/26/10 (1879)
	1880   => '1355651',            # Décès Quéménéven 3 E 272/26/11 (1880)
	1881   => '1355652',            # Décès Quéménéven 3 E 272/26/12 (1881)
	1882   => '1355653',            # Décès Quéménéven 3 E 272/26/13 (1882)
	1883   => '1355654',            # Décès Quéménéven 3 E 272/26/14 (1883)
	1884   => '1355655',            # Décès Quéménéven 3 E 272/26/15 (1884)
    },

    '3E272_0027' => {			# Mariage Quéménéven 3 E 272 27   1885-1895
	1885   => '1355502',            # Mariage Quéménéven 3 E 272/27/1 (1885)
	1886   => '1355503',            # Mariage Quéménéven 3 E 272/27/2 (1886)
	1887   => '1355504',            # Mariage Quéménéven 3 E 272/27/3 (1887)
	1888   => '1355505',            # Mariage Quéménéven 3 E 272/27/4 (1888)
	1889   => '1355506',            # Mariage Quéménéven 3 E 272/27/5 (1889)
	1890   => '1355507',            # Mariage Quéménéven 3 E 272/27/6 (1890)
	1891   => '1355508',            # Mariage Quéménéven 3 E 272/27/7 (1891)
	1892   => '1355509',            # Mariage Quéménéven 3 E 272/27/8 (1892)
	1893   => '1355510',            # Mariage Quéménéven 3 E 272/27/9 (1893)
	1894   => '1355511',            # Mariage Quéménéven 3 E 272/27/10 (1894)
	1895   => '1355512',            # Mariage Quéménéven 3 E 272/27/11 (1895)
    },

    '3E272_0028' => {			# Décès Quéménéven 3 E 272 28   1885-1901
	1885   => '1355657',            # Décès Quéménéven 3 E 272/28/1 (1885)
	1886   => '1355658',            # Décès Quéménéven 3 E 272/28/2 (1886)
	1887   => '1355659',            # Décès Quéménéven 3 E 272/28/3 (1887)
	1888   => '1355660',            # Décès Quéménéven 3 E 272/28/4 (1888)
	1889   => '1355661',            # Décès Quéménéven 3 E 272/28/5 (1889)
	1890   => '1355662',            # Décès Quéménéven 3 E 272/28/6 (1890)
	1891   => '1355663',            # Décès Quéménéven 3 E 272/28/7 (1891)
	1892   => '1355664',            # Décès Quéménéven 3 E 272/28/8 (1892)
	1893   => '1355665',            # Décès Quéménéven 3 E 272/28/9 (1893)
	1894   => '1355666',            # Décès Quéménéven 3 E 272/28/10 (1894)
	1895   => '1355667',            # Décès Quéménéven 3 E 272/28/11 (1895)
	1896   => '1355668',            # Décès Quéménéven 3 E 272/28/12 (1896)
	1897   => '1355669',            # Décès Quéménéven 3 E 272/28/13 (1897)
	1898   => '1355670',            # Décès Quéménéven 3 E 272/28/14 (1898)
	1899   => '1355671',            # Décès Quéménéven 3 E 272/28/15 (1899)
	1900   => '1355672',            # Décès Quéménéven 3 E 272/28/16 (1900)
	1901   => '1355673',            # Décès Quéménéven 3 E 272/28/17 (1901)
    },

    '3E272_0029' => {			# Naissance Quéménéven 3 E 272 29   1895-1907
	1895   => '1355360',            # Naissance Quéménéven 3 E 272/29/1 (1895)
	1896   => '1355361',            # Naissance Quéménéven 3 E 272/29/2 (1896)
	1897   => '1355362',            # Naissance Quéménéven 3 E 272/29/3 (1897)
	1898   => '1355363',            # Naissance Quéménéven 3 E 272/29/4 (1898)
	1899   => '1355364',            # Naissance Quéménéven 3 E 272/29/5 (1899)
	1900   => '1355365',            # Naissance Quéménéven 3 E 272/29/6 (1900)
	1901   => '1355366',            # Naissance Quéménéven 3 E 272/29/7 (1901)
	1902   => '1355367',            # Naissance Quéménéven 3 E 272/29/8 (1902)
	1903   => '1355368',            # Naissance Quéménéven 3 E 272/29/9 (1903)
	1904   => '1355369',            # Naissance Quéménéven 3 E 272/29/10 (1904)
	1905   => '1355370',            # Naissance Quéménéven 3 E 272/29/11 (1905)
	1906   => '1355371',            # Naissance Quéménéven 3 E 272/29/12 (1906)
	1907   => '1355372',            # Naissance Quéménéven 3 E 272/29/13 (1907)
    },

    '3E272_0030' => {			# Mariage Quéménéven 3 E 272 30   1896-1908
	1896   => '1355514',            # Mariage Quéménéven 3 E 272/30/1 (1896)
	1897   => '1355515',            # Mariage Quéménéven 3 E 272/30/2 (1897)
	1898   => '1355516',            # Mariage Quéménéven 3 E 272/30/3 (1898)
	1899   => '1355517',            # Mariage Quéménéven 3 E 272/30/4 (1899)
	1900   => '1355518',            # Mariage Quéménéven 3 E 272/30/5 (1900)
	1901   => '1355519',            # Mariage Quéménéven 3 E 272/30/6 (1901)
	1902   => '1355520',            # Mariage Quéménéven 3 E 272/30/7 (1902)
	1903   => '1355521',            # Mariage Quéménéven 3 E 272/30/8 (1903)
	1904   => '1355522',            # Mariage Quéménéven 3 E 272/30/9 (1904)
	1905   => '1355523',            # Mariage Quéménéven 3 E 272/30/10 (1905)
	1906   => '1355524',            # Mariage Quéménéven 3 E 272/30/11 (1906)
	1907   => '1355525',            # Mariage Quéménéven 3 E 272/30/12 (1907)
	1908   => '1355526',            # Mariage Quéménéven 3 E 272/30/13 (1908)
    },

    '3E272_0031' => {			# Naissance Quéménéven 3 E 272 31   1908-1920
	1908   => '1355374',            # Naissance Quéménéven 3 E 272/31/1 (1908)
	1909   => '1355375',            # Naissance Quéménéven 3 E 272/31/2 (1909)
	1910   => '1355376',            # Naissance Quéménéven 3 E 272/31/3 (1910)
	1911   => '1355377',            # Naissance Quéménéven 3 E 272/31/4 (1911)
	1912   => '1355378',            # Naissance Quéménéven 3 E 272/31/5 (1912)
	1913   => '1355379',            # Naissance Quéménéven 3 E 272/31/6 (1913)
	1914   => '1355380',            # Naissance Quéménéven 3 E 272/31/7 (1914)
	1915   => '1355381',            # Naissance Quéménéven 3 E 272/31/8 (1915)
	1916   => '1355382',            # Naissance Quéménéven 3 E 272/31/9 (1916)
	1917   => '1355383',            # Naissance Quéménéven 3 E 272/31/10 (1917)
	1918   => '1355384',            # Naissance Quéménéven 3 E 272/31/11 (1918)
	1919   => '1355385',            # Naissance Quéménéven 3 E 272/31/12 (1919)
	1920   => '1355386',            # Naissance Quéménéven 3 E 272/31/13 (1920)
    },

    '3E272_0032' => {			# Naissance Quéménéven 3 E 272 32   1921-1925
	1921   => '1355388',            # Naissance Quéménéven 3 E 272/32/1 (1921)
	1922   => '1355389',            # Naissance Quéménéven 3 E 272/32/2 (1922)
	1923   => '1355390',            # Naissance Quéménéven 3 E 272/32/3 (1923)
	1924   => '1355391',            # Naissance Quéménéven 3 E 272/32/4 (1924)
	1925   => '1355392',            # Naissance Quéménéven 3 E 272/32/5 (1925)
    },

    '3E272_0033' => {			# Mariage Quéménéven 3 E 272 33   1909-1919
	1909   => '1355528',            # Mariage Quéménéven 3 E 272/33/1 (1909)
	1910   => '1355529',            # Mariage Quéménéven 3 E 272/33/2 (1910)
	1911   => '1355530',            # Mariage Quéménéven 3 E 272/33/3 (1911)
	1912   => '1355531',            # Mariage Quéménéven 3 E 272/33/4 (1912)
	1913   => '1355532',            # Mariage Quéménéven 3 E 272/33/5 (1913)
	1914   => '1355533',            # Mariage Quéménéven 3 E 272/33/6 (1914)
	1915   => '1355534',            # Mariage Quéménéven 3 E 272/33/7 (1915)
	1916   => '1355535',            # Mariage Quéménéven 3 E 272/33/8 (1916)
	1917   => '1355536',            # Mariage Quéménéven 3 E 272/33/9 (1917)
	1918   => '1355537',            # Mariage Quéménéven 3 E 272/33/10 (1918)
	1919   => '1355538',            # Mariage Quéménéven 3 E 272/33/11 (1919)
    },

    '3E272_0034' => {			# Mariage Quéménéven 3 E 272 34   1920-1936
	1920   => '1355540',            # Mariage Quéménéven 3 E 272/34/1 (1920)
	1921   => '1355541',            # Mariage Quéménéven 3 E 272/34/2 (1921)
	1922   => '1355542',            # Mariage Quéménéven 3 E 272/34/3 (1922)
	1923   => '1355543',            # Mariage Quéménéven 3 E 272/34/4 (1923)
	1924   => '1355544',            # Mariage Quéménéven 3 E 272/34/5 (1924)
	1925   => '1355545',            # Mariage Quéménéven 3 E 272/34/6 (1925)
	1926   => '1355546',            # Mariage Quéménéven 3 E 272/34/7 (1926)
	1927   => '1355547',            # Mariage Quéménéven 3 E 272/34/8 (1927)
	1928   => '1355548',            # Mariage Quéménéven 3 E 272/34/9 (1928)
	1929   => '1355549',            # Mariage Quéménéven 3 E 272/34/10 (1929)
	1930   => '1355550',            # Mariage Quéménéven 3 E 272/34/11 (1930)
	1931   => '1355551',            # Mariage Quéménéven 3 E 272/34/12 (1931)
	1932   => '1355552',            # Mariage Quéménéven 3 E 272/34/13 (1932)
	1933   => '1355553',            # Mariage Quéménéven 3 E 272/34/14 (1933)
	1934   => '1355554',            # Mariage Quéménéven 3 E 272/34/15 (1934)
	1935   => '1355555',            # Mariage Quéménéven 3 E 272/34/16 (1935)
	1936   => '1355556',            # Mariage Quéménéven 3 E 272/34/17 (1936)
    },

    '3E272_0035' => {			# Décès Quéménéven 3 E 272 35   1902-1919
	1902   => '1355675',            # Décès Quéménéven 3 E 272/35/1 (1902)
	1903   => '1355676',            # Décès Quéménéven 3 E 272/35/2 (1903)
	1904   => '1355677',            # Décès Quéménéven 3 E 272/35/3 (1904)
	1905   => '1355678',            # Décès Quéménéven 3 E 272/35/4 (1905)
	1906   => '1355679',            # Décès Quéménéven 3 E 272/35/5 (1906)
	1907   => '1355680',            # Décès Quéménéven 3 E 272/35/6 (1907)
	1908   => '1355681',            # Décès Quéménéven 3 E 272/35/7 (1908)
	1909   => '1355682',            # Décès Quéménéven 3 E 272/35/8 (1909)
	1910   => '1355683',            # Décès Quéménéven 3 E 272/35/9 (1910)
	1911   => '1355684',            # Décès Quéménéven 3 E 272/35/10 (1911)
	1912   => '1355685',            # Décès Quéménéven 3 E 272/35/11 (1912)
	1913   => '1355686',            # Décès Quéménéven 3 E 272/35/12 (1913)
	1914   => '1355687',            # Décès Quéménéven 3 E 272/35/13 (1914)
	1915   => '1355688',            # Décès Quéménéven 3 E 272/35/14 (1915)
	1916   => '1355689',            # Décès Quéménéven 3 E 272/35/15 (1916)
	1917   => '1355690',            # Décès Quéménéven 3 E 272/35/16 (1917)
	1918   => '1355691',            # Décès Quéménéven 3 E 272/35/17 (1918)
	1919   => '1355692',            # Décès Quéménéven 3 E 272/35/18 (1919)
    },

    '3E272_0036' => {			# Décès Quéménéven 3 E 272 36   1920-1936
	1920   => '1355694',            # Décès Quéménéven 3 E 272/36/1 (1920)
	1921   => '1355695',            # Décès Quéménéven 3 E 272/36/2 (1921)
	1922   => '1355696',            # Décès Quéménéven 3 E 272/36/3 (1922)
	1923   => '1355697',            # Décès Quéménéven 3 E 272/36/4 (1923)
	1924   => '1355698',            # Décès Quéménéven 3 E 272/36/5 (1924)
	1925   => '1355699',            # Décès Quéménéven 3 E 272/36/6 (1925)
	1926   => '1355700',            # Décès Quéménéven 3 E 272/36/7 (1926)
	1927   => '1355701',            # Décès Quéménéven 3 E 272/36/8 (1927)
	1928   => '1355702',            # Décès Quéménéven 3 E 272/36/9 (1928)
	1929   => '1355703',            # Décès Quéménéven 3 E 272/36/10 (1929)
	1930   => '1355704',            # Décès Quéménéven 3 E 272/36/11 (1930)
	1931   => '1355705',            # Décès Quéménéven 3 E 272/36/12 (1931)
	1932   => '1355706',            # Décès Quéménéven 3 E 272/36/13 (1932)
	1933   => '1355707',            # Décès Quéménéven 3 E 272/36/14 (1933)
	1934   => '1355708',            # Décès Quéménéven 3 E 272/36/15 (1934)
	1935   => '1355709',            # Décès Quéménéven 3 E 272/36/16 (1935)
	1936   => '1355710',            # Décès Quéménéven 3 E 272/36/17 (1936)
    },


    # NMD Saint-Goazec
    '3E307_0005' => {			# Naissance Saint-Goazec 3 E 307 5   AN02-1812
	'AN02' => '1362801',            # Naissance Saint-Goazec 3 E 307/5/1 (1793 - an II)
	'AN03' => '1362802',            # Naissance Saint-Goazec 3 E 307/5/2 (an III)
	'AN04' => '1362803',            # Naissance Saint-Goazec 3 E 307/5/3 (an IV)
	'AN05' => '1362804',            # Naissance Saint-Goazec 3 E 307/5/4 (an V)
	'AN06' => '1362805',            # Naissance Saint-Goazec 3 E 307/5/5 (an VI)
	'AN07' => '1362806',            # Naissance Saint-Goazec 3 E 307/5/6 (an VII)
	'AN08' => '1362807',            # Naissance Saint-Goazec 3 E 307/5/7 (an VIII)
	'AN09' => '1362808',            # Naissance Saint-Goazec 3 E 307/5/8 (an IX)
	'AN10' => '1362809',            # Naissance Saint-Goazec 3 E 307/5/9 (an X)
	'AN11' => '1362810',            # Naissance Saint-Goazec 3 E 307/5/10 (an XI)
	'AN12' => '1362811',            # Naissance Saint-Goazec 3 E 307/5/11 (an XII)
	'AN13' => '1362812',            # Naissance Saint-Goazec 3 E 307/5/12 (an XIII)
	'AN14' => '1362813',            # Naissance Saint-Goazec 3 E 307/5/13 (an XIV - 1806)
	1807   => '1362814',            # Naissance Saint-Goazec 3 E 307/5/14 (1807)
	1808   => '1362815',            # Naissance Saint-Goazec 3 E 307/5/15 (1808)
	1809   => '1362816',            # Naissance Saint-Goazec 3 E 307/5/16 (1809)
	1810   => '1362817',            # Naissance Saint-Goazec 3 E 307/5/17 (1810)
	1811   => '1362818',            # Naissance Saint-Goazec 3 E 307/5/18 (1811)
	1812   => '1362819',            # Naissance Saint-Goazec 3 E 307/5/19 (1812)
    },

    '3E307_0006' => {			# Naissance Saint-Goazec 3 E 307 6   1813-1822
	1813   => '1362821',            # Naissance Saint-Goazec 3 E 307/6/1 (1813)
	1814   => '1362822',            # Naissance Saint-Goazec 3 E 307/6/2 (1814)
	1815   => '1362823',            # Naissance Saint-Goazec 3 E 307/6/3 (1815)
	1816   => '1362824',            # Naissance Saint-Goazec 3 E 307/6/4 (1816)
	1817   => '1362825',            # Naissance Saint-Goazec 3 E 307/6/5 (1817)
	1818   => '1362826',            # Naissance Saint-Goazec 3 E 307/6/6 (1818)
	1819   => '1362827',            # Naissance Saint-Goazec 3 E 307/6/7 (1819)
	1820   => '1362828',            # Naissance Saint-Goazec 3 E 307/6/8 (1820)
	1821   => '1362829',            # Naissance Saint-Goazec 3 E 307/6/9 (1821)
	1822   => '1362830',            # Naissance Saint-Goazec 3 E 307/6/10 (1822)
    },

    '3E307_0007' => {			# Naissance Saint-Goazec 3 E 307 7   1823-1832
	1823   => '1362832',            # Naissance Saint-Goazec 3 E 307/7/1 (1823)
	1824   => '1362833',            # Naissance Saint-Goazec 3 E 307/7/2 (1824)
	1825   => '1362834',            # Naissance Saint-Goazec 3 E 307/7/3 (1825)
	1826   => '1362835',            # Naissance Saint-Goazec 3 E 307/7/4 (1826)
	1827   => '1362836',            # Naissance Saint-Goazec 3 E 307/7/5 (1827)
	1828   => '1362837',            # Naissance Saint-Goazec 3 E 307/7/6 (1828)
	1829   => '1362838',            # Naissance Saint-Goazec 3 E 307/7/7 (1829)
	1830   => '1362839',            # Naissance Saint-Goazec 3 E 307/7/8 (1830)
	1831   => '1362840',            # Naissance Saint-Goazec 3 E 307/7/9 (1831)
	1832   => '1362841',            # Naissance Saint-Goazec 3 E 307/7/10 (1832)
    },

    '3E307_0008' => {			# Naissance Saint-Goazec 3 E 307 8   1833-1842
	1833   => '1362843',            # Naissance Saint-Goazec 3 E 307/8/1 (1833)
	1834   => '1362844',            # Naissance Saint-Goazec 3 E 307/8/2 (1834)
	1835   => '1362845',            # Naissance Saint-Goazec 3 E 307/8/3 (1835)
	1836   => '1362846',            # Naissance Saint-Goazec 3 E 307/8/4 (1836)
	1837   => '1362847',            # Naissance Saint-Goazec 3 E 307/8/5 (1837)
	1838   => '1362848',            # Naissance Saint-Goazec 3 E 307/8/6 (1838)
	1839   => '1362849',            # Naissance Saint-Goazec 3 E 307/8/7 (1839)
	1840   => '1362850',            # Naissance Saint-Goazec 3 E 307/8/8 (1840)
	1841   => '1362851',            # Naissance Saint-Goazec 3 E 307/8/9 (1841)
	1842   => '1362852',            # Naissance Saint-Goazec 3 E 307/8/10 (1842)
    },

    '3E307_0009' => {			# Naissance Saint-Goazec 3 E 307 9   1843-1852
	1843   => '1362854',            # Naissance Saint-Goazec 3 E 307/9/1 (1843)
	1844   => '1362855',            # Naissance Saint-Goazec 3 E 307/9/2 (1844)
	1845   => '1362856',            # Naissance Saint-Goazec 3 E 307/9/3 (1845)
	1846   => '1362857',            # Naissance Saint-Goazec 3 E 307/9/4 (1846)
	1847   => '1362858',            # Naissance Saint-Goazec 3 E 307/9/5 (1847)
	1848   => '1362859',            # Naissance Saint-Goazec 3 E 307/9/6 (1848)
	1849   => '1362860',            # Naissance Saint-Goazec 3 E 307/9/7 (1849)
	1850   => '1362861',            # Naissance Saint-Goazec 3 E 307/9/8 (1850)
	1851   => '1362862',            # Naissance Saint-Goazec 3 E 307/9/9 (1851)
	1852   => '1362863',            # Naissance Saint-Goazec 3 E 307/9/10 (1852)
    },

    '3E307_0010' => {			# Naissance Saint-Goazec 3 E 307 10   1853-1862
	1853   => '1362865',            # Naissance Saint-Goazec 3 E 307/10/1 (1853)
	1854   => '1362866',            # Naissance Saint-Goazec 3 E 307/10/2 (1854)
	1855   => '1362867',            # Naissance Saint-Goazec 3 E 307/10/3 (1855)
	1856   => '1362868',            # Naissance Saint-Goazec 3 E 307/10/4 (1856)
	1857   => '1362869',            # Naissance Saint-Goazec 3 E 307/10/5 (1857)
	1858   => '1362870',            # Naissance Saint-Goazec 3 E 307/10/6 (1858)
	1859   => '1362871',            # Naissance Saint-Goazec 3 E 307/10/7 (1859)
	1860   => '1362872',            # Naissance Saint-Goazec 3 E 307/10/8 (1860)
	1861   => '1362873',            # Naissance Saint-Goazec 3 E 307/10/9 (1861)
	1862   => '1362874',            # Naissance Saint-Goazec 3 E 307/10/10 (1862)
    },

    '3E307_0011' => {			# Naissance Saint-Goazec 3 E 307 11   1863-1869
	1863   => '1362876',            # Naissance Saint-Goazec 3 E 307/11/1 (1863)
	1864   => '1362877',            # Naissance Saint-Goazec 3 E 307/11/2 (1864)
	1865   => '1362878',            # Naissance Saint-Goazec 3 E 307/11/3 (1865)
	1866   => '1362879',            # Naissance Saint-Goazec 3 E 307/11/4 (1866)
	1867   => '1362880',            # Naissance Saint-Goazec 3 E 307/11/5 (1867)
	1868   => '1362881',            # Naissance Saint-Goazec 3 E 307/11/6 (1868)
	1869   => '1362882',            # Naissance Saint-Goazec 3 E 307/11/7 (1869)
    },

    '3E307_0012' => {			# Naissance Saint-Goazec 3 E 307 12   1870-1881
	1870   => '1362884',            # Naissance Saint-Goazec 3 E 307/12/1 (1870)
	1871   => '1362885',            # Naissance Saint-Goazec 3 E 307/12/2 (1871)
	1872   => '1362886',            # Naissance Saint-Goazec 3 E 307/12/3 (1872)
	1873   => '1362887',            # Naissance Saint-Goazec 3 E 307/12/4 (1873)
	1874   => '1362888',            # Naissance Saint-Goazec 3 E 307/12/5 (1874)
	1875   => '1362889',            # Naissance Saint-Goazec 3 E 307/12/6 (1875)
	1876   => '1362890',            # Naissance Saint-Goazec 3 E 307/12/7 (1876)
	1877   => '1362891',            # Naissance Saint-Goazec 3 E 307/12/8 (1877)
	1878   => '1362892',            # Naissance Saint-Goazec 3 E 307/12/9 (1878)
	1879   => '1362893',            # Naissance Saint-Goazec 3 E 307/12/10 (1879)
	1880   => '1362894',            # Naissance Saint-Goazec 3 E 307/12/11 (1880)
	1881   => '1362895',            # Naissance Saint-Goazec 3 E 307/12/12 (1881)
    },

    '3E307_0013' => {			# Naissance Saint-Goazec 3 E 307 13   1882-1891
	1882   => '1362897',            # Naissance Saint-Goazec 3 E 307/13/1 (1882)
	1883   => '1362898',            # Naissance Saint-Goazec 3 E 307/13/2 (1883)
	1884   => '1362899',            # Naissance Saint-Goazec 3 E 307/13/3 (1884)
	1885   => '1362900',            # Naissance Saint-Goazec 3 E 307/13/4 (1885)
	1886   => '1362901',            # Naissance Saint-Goazec 3 E 307/13/5 (1886)
	1887   => '1362902',            # Naissance Saint-Goazec 3 E 307/13/6 (1887)
	1888   => '1362903',            # Naissance Saint-Goazec 3 E 307/13/7 (1888)
	1889   => '1362904',            # Naissance Saint-Goazec 3 E 307/13/8 (1889)
	1890   => '1362905',            # Naissance Saint-Goazec 3 E 307/13/9 (1890)
	1891   => '1362906',            # Naissance Saint-Goazec 3 E 307/13/10 (1891)
    },

    '3E307_0014' => {			# Mariage Saint-Goazec 3 E 307 14   AN02-1812
	'AN02' => '1362957',            # Mariage Saint-Goazec 3 E 307/14/1 (1793 - an II)
	'AN03' => '1362958',            # Mariage Saint-Goazec 3 E 307/14/2 (an III)
	'AN04' => '1362959',            # Mariage Saint-Goazec 3 E 307/14/3 (an IV)
	'AN05' => '1362960',            # Mariage Saint-Goazec 3 E 307/14/4 (an V)
	'AN06' => '1362961',            # Mariage Saint-Goazec 3 E 307/14/5 (an VI)
	'AN09' => '1362962',            # Mariage Saint-Goazec 3 E 307/14/6 (an IX)
	'AN10' => '1362963',            # Mariage Saint-Goazec 3 E 307/14/7 (an X)
	'AN11' => '1362964',            # Mariage Saint-Goazec 3 E 307/14/8 (an XI)
	'AN12' => '1362965',            # Mariage Saint-Goazec 3 E 307/14/9 (an XII)
	'AN13' => '1362966',            # Mariage Saint-Goazec 3 E 307/14/10 (an XIII)
	'AN14' => '1362967',            # Mariage Saint-Goazec 3 E 307/14/11 (an XIV - 1806)
	1807   => '1362968',            # Mariage Saint-Goazec 3 E 307/14/12 (1807)
	1808   => '1362969',            # Mariage Saint-Goazec 3 E 307/14/13 (1808)
	1809   => '1362970',            # Mariage Saint-Goazec 3 E 307/14/14 (1809)
	1810   => '1362971',            # Mariage Saint-Goazec 3 E 307/14/15 (1810)
	1811   => '1362972',            # Mariage Saint-Goazec 3 E 307/14/16 (1811)
	1812   => '1362973',            # Mariage Saint-Goazec 3 E 307/14/17 (1812)
    },

    '3E307_0015' => {			# Mariage Saint-Goazec 3 E 307 15   1813-1822
	1813   => '1362975',            # Mariage Saint-Goazec 3 E 307/15/1 (1813)
	1814   => '1362976',            # Mariage Saint-Goazec 3 E 307/15/2 (1814)
	1815   => '1362977',            # Mariage Saint-Goazec 3 E 307/15/3 (1815)
	1816   => '1362978',            # Mariage Saint-Goazec 3 E 307/15/4 (1816)
	1817   => '1362979',            # Mariage Saint-Goazec 3 E 307/15/5 (1817)
	1818   => '1362980',            # Mariage Saint-Goazec 3 E 307/15/6 (1818)
	1819   => '1362981',            # Mariage Saint-Goazec 3 E 307/15/7 (1819)
	1820   => '1362982',            # Mariage Saint-Goazec 3 E 307/15/8 (1820)
	1821   => '1362983',            # Mariage Saint-Goazec 3 E 307/15/9 (1821)
	1822   => '1362984',            # Mariage Saint-Goazec 3 E 307/15/10 (1822)
    },

    '3E307_0016' => {			# Mariage Saint-Goazec 3 E 307 16   1823-1832
	1823   => '1362986',            # Mariage Saint-Goazec 3 E 307/16/1 (1823)
	1824   => '1362987',            # Mariage Saint-Goazec 3 E 307/16/2 (1824)
	1825   => '1362988',            # Mariage Saint-Goazec 3 E 307/16/3 (1825)
	1826   => '1362989',            # Mariage Saint-Goazec 3 E 307/16/4 (1826)
	1827   => '1362990',            # Mariage Saint-Goazec 3 E 307/16/5 (1827)
	1828   => '1362991',            # Mariage Saint-Goazec 3 E 307/16/6 (1828)
	1829   => '1362992',            # Mariage Saint-Goazec 3 E 307/16/7 (1829)
	1830   => '1362993',            # Mariage Saint-Goazec 3 E 307/16/8 (1830)
	1831   => '1362994',            # Mariage Saint-Goazec 3 E 307/16/9 (1831)
	1832   => '1362995',            # Mariage Saint-Goazec 3 E 307/16/10 (1832)
    },

    '3E307_0017' => {			# Mariage Saint-Goazec 3 E 307 17   1833-1842
	1833   => '1362997',            # Mariage Saint-Goazec 3 E 307/17/1 (1833)
	1834   => '1362998',            # Mariage Saint-Goazec 3 E 307/17/2 (1834)
	1835   => '1362999',            # Mariage Saint-Goazec 3 E 307/17/3 (1835)
	1836   => '1363000',            # Mariage Saint-Goazec 3 E 307/17/4 (1836)
	1837   => '1363001',            # Mariage Saint-Goazec 3 E 307/17/5 (1837)
	1838   => '1363002',            # Mariage Saint-Goazec 3 E 307/17/6 (1838)
	1839   => '1363003',            # Mariage Saint-Goazec 3 E 307/17/7 (1839)
	1840   => '1363004',            # Mariage Saint-Goazec 3 E 307/17/8 (1840)
	1841   => '1363005',            # Mariage Saint-Goazec 3 E 307/17/9 (1841)
	1842   => '1363006',            # Mariage Saint-Goazec 3 E 307/17/10 (1842)
    },

    '3E307_0018' => {			# Mariage Saint-Goazec 3 E 307 18   1843-1852
	1843   => '1363008',            # Mariage Saint-Goazec 3 E 307/18/1 (1843)
	1844   => '1363009',            # Mariage Saint-Goazec 3 E 307/18/2 (1844)
	1845   => '1363010',            # Mariage Saint-Goazec 3 E 307/18/3 (1845)
	1846   => '1363011',            # Mariage Saint-Goazec 3 E 307/18/4 (1846)
	1847   => '1363012',            # Mariage Saint-Goazec 3 E 307/18/5 (1847)
	1848   => '1363013',            # Mariage Saint-Goazec 3 E 307/18/6 (1848)
	1849   => '1363014',            # Mariage Saint-Goazec 3 E 307/18/7 (1849)
	1850   => '1363015',            # Mariage Saint-Goazec 3 E 307/18/8 (1850)
	1851   => '1363016',            # Mariage Saint-Goazec 3 E 307/18/9 (1851)
	1852   => '1363017',            # Mariage Saint-Goazec 3 E 307/18/10 (1852)
    },

    '3E307_0019' => {			# Mariage Saint-Goazec 3 E 307 19   1853-1862
	1853   => '1363019',            # Mariage Saint-Goazec 3 E 307/19/1 (1853)
	1854   => '1363020',            # Mariage Saint-Goazec 3 E 307/19/2 (1854)
	1855   => '1363021',            # Mariage Saint-Goazec 3 E 307/19/3 (1855)
	1856   => '1363022',            # Mariage Saint-Goazec 3 E 307/19/4 (1856)
	1857   => '1363023',            # Mariage Saint-Goazec 3 E 307/19/5 (1857)
	1858   => '1363024',            # Mariage Saint-Goazec 3 E 307/19/6 (1858)
	1859   => '1363025',            # Mariage Saint-Goazec 3 E 307/19/7 (1859)
	1860   => '1363026',            # Mariage Saint-Goazec 3 E 307/19/8 (1860)
	1861   => '1363027',            # Mariage Saint-Goazec 3 E 307/19/9 (1861)
	1862   => '1363028',            # Mariage Saint-Goazec 3 E 307/19/10 (1862)
    },

    '3E307_0020' => {			# Mariage Saint-Goazec 3 E 307 20   1863-1869
	1863   => '1363030',            # Mariage Saint-Goazec 3 E 307/20/1 (1863)
	1864   => '1363031',            # Mariage Saint-Goazec 3 E 307/20/2 (1864)
	1865   => '1363032',            # Mariage Saint-Goazec 3 E 307/20/3 (1865)
	1866   => '1363033',            # Mariage Saint-Goazec 3 E 307/20/4 (1866)
	1867   => '1363034',            # Mariage Saint-Goazec 3 E 307/20/5 (1867)
	1868   => '1363035',            # Mariage Saint-Goazec 3 E 307/20/6 (1868)
	1869   => '1363036',            # Mariage Saint-Goazec 3 E 307/20/7 (1869)
    },

    '3E307_0021' => {			# Mariage Saint-Goazec 3 E 307 21   1870-1887
	1870   => '1363038',            # Mariage Saint-Goazec 3 E 307/21/1 (1870)
	1871   => '1363039',            # Mariage Saint-Goazec 3 E 307/21/2 (1871)
	1872   => '1363040',            # Mariage Saint-Goazec 3 E 307/21/3 (1872)
	1873   => '1363041',            # Mariage Saint-Goazec 3 E 307/21/4 (1873)
	1874   => '1363042',            # Mariage Saint-Goazec 3 E 307/21/5 (1874)
	1875   => '1363043',            # Mariage Saint-Goazec 3 E 307/21/6 (1875)
	1876   => '1363044',            # Mariage Saint-Goazec 3 E 307/21/7 (1876)
	1877   => '1363045',            # Mariage Saint-Goazec 3 E 307/21/8 (1877)
	1878   => '1363046',            # Mariage Saint-Goazec 3 E 307/21/9 (1878)
	1879   => '1363047',            # Mariage Saint-Goazec 3 E 307/21/10 (1879)
	1880   => '1363048',            # Mariage Saint-Goazec 3 E 307/21/11 (1880)
	1881   => '1363049',            # Mariage Saint-Goazec 3 E 307/21/12 (1881)
	1882   => '1363050',            # Mariage Saint-Goazec 3 E 307/21/13 (1882)
	1883   => '1363051',            # Mariage Saint-Goazec 3 E 307/21/14 (1883)
	1884   => '1363052',            # Mariage Saint-Goazec 3 E 307/21/15 (1884)
	1885   => '1363053',            # Mariage Saint-Goazec 3 E 307/21/16 (1885)
	1886   => '1363054',            # Mariage Saint-Goazec 3 E 307/21/17 (1886)
	1887   => '1363055',            # Mariage Saint-Goazec 3 E 307/21/18 (1887)
    },

    '3E307_0022' => {			# Décès Saint-Goazec 3 E 307 22   AN02-1812
	'AN02' => '1363110',            # Décès Saint-Goazec 3 E 307/22/1 (1793 - an II)
	'AN03' => '1363111',            # Décès Saint-Goazec 3 E 307/22/2 (an III)
	'AN04' => '1363112',            # Décès Saint-Goazec 3 E 307/22/3 (an IV)
	'AN05' => '1363113',            # Décès Saint-Goazec 3 E 307/22/4 (an V)
	'AN06' => '1363114',            # Décès Saint-Goazec 3 E 307/22/5 (an VI)
	'AN07' => '1363115',            # Décès Saint-Goazec 3 E 307/22/6 (an VII)
	'AN08' => '1363116',            # Décès Saint-Goazec 3 E 307/22/7 (an VIII)
	'AN09' => '1363117',            # Décès Saint-Goazec 3 E 307/22/8 (an IX)
	'AN10' => '1363118',            # Décès Saint-Goazec 3 E 307/22/9 (an X)
	'AN11' => '1363119',            # Décès Saint-Goazec 3 E 307/22/10 (an XI)
	'AN12' => '1363120',            # Décès Saint-Goazec 3 E 307/22/11 (an XII)
	'AN13' => '1363121',            # Décès Saint-Goazec 3 E 307/22/12 (an XIII)
	'AN14' => '1363122',            # Décès Saint-Goazec 3 E 307/22/13 (an XIV - 1806)
	1807   => '1363123',            # Décès Saint-Goazec 3 E 307/22/14 (1807)
	1808   => '1363124',            # Décès Saint-Goazec 3 E 307/22/15 (1808)
	1809   => '1363125',            # Décès Saint-Goazec 3 E 307/22/16 (1809)
	1810   => '1363126',            # Décès Saint-Goazec 3 E 307/22/17 (1810)
	1811   => '1363127',            # Décès Saint-Goazec 3 E 307/22/18 (1811)
	1812   => '1363128',            # Décès Saint-Goazec 3 E 307/22/19 (1812)
    },

    '3E307_0023' => {			# Décès Saint-Goazec 3 E 307 23   1813-1817
	1813   => '1363130',            # Décès Saint-Goazec 3 E 307/23/1 (1813)
	1814   => '1363131',            # Décès Saint-Goazec 3 E 307/23/2 (1814)
	1815   => '1363132',            # Décès Saint-Goazec 3 E 307/23/3 (1815)
	1816   => '1363133',            # Décès Saint-Goazec 3 E 307/23/4 (1816)
	1817   => '1363134',            # Décès Saint-Goazec 3 E 307/23/5 (1817)
	1818   => '1363135',            # Décès Saint-Goazec 3 E 307/23/6 (1818)
	1819   => '1363136',            # Décès Saint-Goazec 3 E 307/23/7 (1819)
	1820   => '1363137',            # Décès Saint-Goazec 3 E 307/23/8 (1820)
	1821   => '1363138',            # Décès Saint-Goazec 3 E 307/23/9 (1821)
	1822   => '1363139',            # Décès Saint-Goazec 3 E 307/23/10 (1822)
    },

    '3E307_0024' => {			# Décès Saint-Goazec 3 E 307 24   1823-1832
	1823   => '1363141',            # Décès Saint-Goazec 3 E 307/24/1 (1823)
	1824   => '1363142',            # Décès Saint-Goazec 3 E 307/24/2 (1824)
	1825   => '1363143',            # Décès Saint-Goazec 3 E 307/24/3 (1825)
	1826   => '1363144',            # Décès Saint-Goazec 3 E 307/24/4 (1826)
	1827   => '1363145',            # Décès Saint-Goazec 3 E 307/24/5 (1827)
	1828   => '1363146',            # Décès Saint-Goazec 3 E 307/24/6 (1828)
	1829   => '1363147',            # Décès Saint-Goazec 3 E 307/24/7 (1829)
	1830   => '1363148',            # Décès Saint-Goazec 3 E 307/24/8 (1830)
	1831   => '1363149',            # Décès Saint-Goazec 3 E 307/24/9 (1831)
	1832   => '1363150',            # Décès Saint-Goazec 3 E 307/24/10 (1832)
    },

    '3E307_0025' => {			# Décès Saint-Goazec 3 E 307 25   1833-1842
	1833   => '1363152',            # Décès Saint-Goazec 3 E 307/25/1 (1833)
	1834   => '1363153',            # Décès Saint-Goazec 3 E 307/25/2 (1834)
	1835   => '1363154',            # Décès Saint-Goazec 3 E 307/25/3 (1835)
	1836   => '1363155',            # Décès Saint-Goazec 3 E 307/25/4 (1836)
	1837   => '1363156',            # Décès Saint-Goazec 3 E 307/25/5 (1837)
	1838   => '1363157',            # Décès Saint-Goazec 3 E 307/25/6 (1838)
	1839   => '1363158',            # Décès Saint-Goazec 3 E 307/25/7 (1839)
	1840   => '1363159',            # Décès Saint-Goazec 3 E 307/25/8 (1840)
	1841   => '1363160',            # Décès Saint-Goazec 3 E 307/25/9 (1841)
	1842   => '1363161',            # Décès Saint-Goazec 3 E 307/25/10 (1842)
    },

    '3E307_0026' => {			# Décès Saint-Goazec 3 E 307 26   1843-1852
	1843   => '1363163',            # Décès Saint-Goazec 3 E 307/26/1 (1843)
	1844   => '1363164',            # Décès Saint-Goazec 3 E 307/26/2 (1844)
	1845   => '1363165',            # Décès Saint-Goazec 3 E 307/26/3 (1845)
	1846   => '1363166',            # Décès Saint-Goazec 3 E 307/26/4 (1846)
	1847   => '1363167',            # Décès Saint-Goazec 3 E 307/26/5 (1847)
	1848   => '1363168',            # Décès Saint-Goazec 3 E 307/26/6 (1848)
	1849   => '1363169',            # Décès Saint-Goazec 3 E 307/26/7 (1849)
	1850   => '1363170',            # Décès Saint-Goazec 3 E 307/26/8 (1850)
	1851   => '1363171',            # Décès Saint-Goazec 3 E 307/26/9 (1851)
	1852   => '1363172',            # Décès Saint-Goazec 3 E 307/26/10 (1852)
    },

    '3E307_0027' => {			# Décès Saint-Goazec 3 E 307 27   1853-1862
	1853   => '1363174',            # Décès Saint-Goazec 3 E 307/27/1 (1853)
	1854   => '1363175',            # Décès Saint-Goazec 3 E 307/27/2 (1854)
	1855   => '1363176',            # Décès Saint-Goazec 3 E 307/27/3 (1855)
	1856   => '1363177',            # Décès Saint-Goazec 3 E 307/27/4 (1856)
	1857   => '1363178',            # Décès Saint-Goazec 3 E 307/27/5 (1857)
	1858   => '1363179',            # Décès Saint-Goazec 3 E 307/27/6 (1858)
	1859   => '1363180',            # Décès Saint-Goazec 3 E 307/27/7 (1859)
	1860   => '1363181',            # Décès Saint-Goazec 3 E 307/27/8 (1860)
	1861   => '1363182',            # Décès Saint-Goazec 3 E 307/27/9 (1861)
	1862   => '1363183',            # Décès Saint-Goazec 3 E 307/27/10 (1862)
    },

    '3E307_0028' => {			# Décès Saint-Goazec 3 E 307 28   1863-1869
	1863   => '1363185',            # Décès Saint-Goazec 3 E 307/28/1 (1863)
	1864   => '1363186',            # Décès Saint-Goazec 3 E 307/28/2 (1864)
	1865   => '1363187',            # Décès Saint-Goazec 3 E 307/28/3 (1865)
	1866   => '1363188',            # Décès Saint-Goazec 3 E 307/28/4 (1866)
	1867   => '1363189',            # Décès Saint-Goazec 3 E 307/28/5 (1867)
	1868   => '1363190',            # Décès Saint-Goazec 3 E 307/28/6 (1868)
	1869   => '1363191',            # Décès Saint-Goazec 3 E 307/28/7 (1869)
    },

    '3E307_0029' => {			# Décès Saint-Goazec 3 E 307 29   1870-1886
	1870   => '1363193',            # Décès Saint-Goazec 3 E 307/29/1 (1870)
	1871   => '1363194',            # Décès Saint-Goazec 3 E 307/29/2 (1871)
	1872   => '1363195',            # Décès Saint-Goazec 3 E 307/29/3 (1872)
	1873   => '1363196',            # Décès Saint-Goazec 3 E 307/29/4 (1873)
	1874   => '1363197',            # Décès Saint-Goazec 3 E 307/29/5 (1874)
	1875   => '1363198',            # Décès Saint-Goazec 3 E 307/29/6 (1875)
	1876   => '1363199',            # Décès Saint-Goazec 3 E 307/29/7 (1876)
	1877   => '1363200',            # Décès Saint-Goazec 3 E 307/29/8 (1877)
	1878   => '1363201',            # Décès Saint-Goazec 3 E 307/29/9 (1878)
	1879   => '1363202',            # Décès Saint-Goazec 3 E 307/29/10 (1879)
	1880   => '1363203',            # Décès Saint-Goazec 3 E 307/29/11 (1880)
	1881   => '1363204',            # Décès Saint-Goazec 3 E 307/29/12 (1881)
	1882   => '1363205',            # Décès Saint-Goazec 3 E 307/29/13 (1882)
	1883   => '1363206',            # Décès Saint-Goazec 3 E 307/29/14 (1883)
	1884   => '1363207',            # Décès Saint-Goazec 3 E 307/29/15 (1884)
	1885   => '1363208',            # Décès Saint-Goazec 3 E 307/29/16 (1885)
	1886   => '1363209',            # Décès Saint-Goazec 3 E 307/29/17 (1886)
    },

    '3E307_0030' => {			# Naissance Saint-Goazec 3 E 307 30   1892-1906
	1892   => '1362908',            # Naissance Saint-Goazec 3 E 307/30/1 (1892)
	1893   => '1362909',            # Naissance Saint-Goazec 3 E 307/30/2 (1893)
	1894   => '1362910',            # Naissance Saint-Goazec 3 E 307/30/3 (1894)
	1895   => '1362911',            # Naissance Saint-Goazec 3 E 307/30/4 (1895)
	1896   => '1362912',            # Naissance Saint-Goazec 3 E 307/30/5 (1896)
	1897   => '1362913',            # Naissance Saint-Goazec 3 E 307/30/6 (1897)
	1898   => '1362914',            # Naissance Saint-Goazec 3 E 307/30/7 (1898)
	1899   => '1362915',            # Naissance Saint-Goazec 3 E 307/30/8 (1899)
	1900   => '1362916',            # Naissance Saint-Goazec 3 E 307/30/9 (1900)
	1901   => '1362917',            # Naissance Saint-Goazec 3 E 307/30/10 (1901)
	1902   => '1362918',            # Naissance Saint-Goazec 3 E 307/30/11 (1902)
	1903   => '1362919',            # Naissance Saint-Goazec 3 E 307/30/12 (1903)
	1904   => '1362920',            # Naissance Saint-Goazec 3 E 307/30/13 (1904)
	1905   => '1362921',            # Naissance Saint-Goazec 3 E 307/30/14 (1905)
	1906   => '1362922',            # Naissance Saint-Goazec 3 E 307/30/15 (1906)
    },

    '3E307_0031' => {			# Mariage Saint-Goazec 3 E 307 31   1888-1904
	1888   => '1363057',            # Mariage Saint-Goazec 3 E 307/31/1 (1888)
	1889   => '1363058',            # Mariage Saint-Goazec 3 E 307/31/2 (1889)
	1890   => '1363059',            # Mariage Saint-Goazec 3 E 307/31/3 (1890)
	1891   => '1363060',            # Mariage Saint-Goazec 3 E 307/31/4 (1891)
	1892   => '1363061',            # Mariage Saint-Goazec 3 E 307/31/5 (1892)
	1893   => '1363062',            # Mariage Saint-Goazec 3 E 307/31/6 (1893)
	1894   => '1363063',            # Mariage Saint-Goazec 3 E 307/31/7 (1894)
	1895   => '1363064',            # Mariage Saint-Goazec 3 E 307/31/8 (1895)
	1896   => '1363065',            # Mariage Saint-Goazec 3 E 307/31/9 (1896)
	1897   => '1363066',            # Mariage Saint-Goazec 3 E 307/31/10 (1897)
	1898   => '1363067',            # Mariage Saint-Goazec 3 E 307/31/11 (1898)
	1899   => '1363068',            # Mariage Saint-Goazec 3 E 307/31/12 (1899)
	1900   => '1363069',            # Mariage Saint-Goazec 3 E 307/31/13 (1900)
	1901   => '1363070',            # Mariage Saint-Goazec 3 E 307/31/14 (1901)
	1902   => '1363071',            # Mariage Saint-Goazec 3 E 307/31/15 (1902)
	1903   => '1363072',            # Mariage Saint-Goazec 3 E 307/31/16 (1903)
	1904   => '1363073',            # Mariage Saint-Goazec 3 E 307/31/17 (1904)
    },

    '3E307_0032' => {			# Décès Saint-Goazec 3 E 307 32   1887-1902
	1887   => '1363211',            # Décès Saint-Goazec 3 E 307/32/1 (1887)
	1888   => '1363212',            # Décès Saint-Goazec 3 E 307/32/2 (1888)
	1889   => '1363213',            # Décès Saint-Goazec 3 E 307/32/3 (1889)
	1890   => '1363214',            # Décès Saint-Goazec 3 E 307/32/4 (1890)
	1891   => '1363215',            # Décès Saint-Goazec 3 E 307/32/5 (1891)
	1892   => '1363216',            # Décès Saint-Goazec 3 E 307/32/6 (1892)
	1893   => '1363217',            # Décès Saint-Goazec 3 E 307/32/7 (1893)
	1894   => '1363218',            # Décès Saint-Goazec 3 E 307/32/8 (1894)
	1895   => '1363219',            # Décès Saint-Goazec 3 E 307/32/9 (1895)
	1896   => '1363220',            # Décès Saint-Goazec 3 E 307/32/10 (1896)
	1897   => '1363221',            # Décès Saint-Goazec 3 E 307/32/11 (1897)
	1898   => '1363222',            # Décès Saint-Goazec 3 E 307/32/12 (1898)
	1899   => '1363223',            # Décès Saint-Goazec 3 E 307/32/13 (1899)
	1900   => '1363224',            # Décès Saint-Goazec 3 E 307/32/14 (1900)
	1901   => '1363225',            # Décès Saint-Goazec 3 E 307/32/15 (1901)
	1902   => '1363226',            # Décès Saint-Goazec 3 E 307/32/16 (1902)
    },

    '3E307_0033' => {			# Naissance Saint-Goazec 3 E 307 33   1907-1919
	1907   => '1362924',            # Naissance Saint-Goazec 3 E 307/33/1 (1907)
	1908   => '1362925',            # Naissance Saint-Goazec 3 E 307/33/2 (1908)
	1909   => '1362926',            # Naissance Saint-Goazec 3 E 307/33/3 (1909)
	1910   => '1362927',            # Naissance Saint-Goazec 3 E 307/33/4 (1910)
	1911   => '1362928',            # Naissance Saint-Goazec 3 E 307/33/5 (1911)
	1912   => '1362929',            # Naissance Saint-Goazec 3 E 307/33/6 (1912)
	1913   => '1362930',            # Naissance Saint-Goazec 3 E 307/33/7 (1913)
	1914   => '1362931',            # Naissance Saint-Goazec 3 E 307/33/8 (1914)
	1915   => '1362932',            # Naissance Saint-Goazec 3 E 307/33/9 (1915)
	1916   => '1362933',            # Naissance Saint-Goazec 3 E 307/33/10 (1916)
	1917   => '1362934',            # Naissance Saint-Goazec 3 E 307/33/11 (1917)
	1918   => '1362935',            # Naissance Saint-Goazec 3 E 307/33/12 (1918)
	1919   => '1362936',            # Naissance Saint-Goazec 3 E 307/33/13 (1919)
    },

    '3E307_0034' => {			# Naissance Saint-Goazec 3 E 307 34   1920-1925
	1920   => '1362938',            # Naissance Saint-Goazec 3 E 307/34/1 (1920)
	1921   => '1362939',            # Naissance Saint-Goazec 3 E 307/34/2 (1921)
	1922   => '1362940',            # Naissance Saint-Goazec 3 E 307/34/3 (1922)
	1923   => '1362941',            # Naissance Saint-Goazec 3 E 307/34/4 (1923)
	1924   => '1362942',            # Naissance Saint-Goazec 3 E 307/34/5 (1924)
	1925   => '1362943',            # Naissance Saint-Goazec 3 E 307/34/6 (1925)
    },

    '3E307_0035' => {			# Mariage Saint-Goazec 3 E 307 35   1905-1918
	1905   => '1363075',            # Mariage Saint-Goazec 3 E 307/35/1 (1905)
	1906   => '1363076',            # Mariage Saint-Goazec 3 E 307/35/2 (1906)
	1907   => '1363077',            # Mariage Saint-Goazec 3 E 307/35/3 (1907)
	1908   => '1363078',            # Mariage Saint-Goazec 3 E 307/35/4 (1908)
	1909   => '1363079',            # Mariage Saint-Goazec 3 E 307/35/5 (1909)
	1910   => '1363080',            # Mariage Saint-Goazec 3 E 307/35/6 (1910)
	1911   => '1363081',            # Mariage Saint-Goazec 3 E 307/35/7 (1911)
	1912   => '1363082',            # Mariage Saint-Goazec 3 E 307/35/8 (1912)
	1913   => '1363083',            # Mariage Saint-Goazec 3 E 307/35/9 (1913)
	1914   => '1363084',            # Mariage Saint-Goazec 3 E 307/35/10 (1914)
	1915   => '1363085',            # Mariage Saint-Goazec 3 E 307/35/11 (1915)
	1916   => '1363086',            # Mariage Saint-Goazec 3 E 307/35/12 (1916)
	1917   => '1363087',            # Mariage Saint-Goazec 3 E 307/35/13 (1917)
	1918   => '1363088',            # Mariage Saint-Goazec 3 E 307/35/14 (1918)
    },

    '3E307_0036' => {			# Mariage Saint-Goazec 3 E 307 36   1919-1936
	1919   => '1363090',            # Mariage Saint-Goazec 3 E 307/36/1 (1919)
	1920   => '1363091',            # Mariage Saint-Goazec 3 E 307/36/2 (1920)
	1921   => '1363092',            # Mariage Saint-Goazec 3 E 307/36/3 (1921)
	1922   => '1363093',            # Mariage Saint-Goazec 3 E 307/36/4 (1922)
	1923   => '1363094',            # Mariage Saint-Goazec 3 E 307/36/5 (1923)
	1924   => '1363095',            # Mariage Saint-Goazec 3 E 307/36/6 (1924)
	1925   => '1363096',            # Mariage Saint-Goazec 3 E 307/36/7 (1925)
	1926   => '1363097',            # Mariage Saint-Goazec 3 E 307/36/8 (1926)
	1927   => '1363098',            # Mariage Saint-Goazec 3 E 307/36/9 (1927)
	1928   => '1363099',            # Mariage Saint-Goazec 3 E 307/36/10 (1928)
	1929   => '1363100',            # Mariage Saint-Goazec 3 E 307/36/11 (1929)
	1930   => '1363101',            # Mariage Saint-Goazec 3 E 307/36/12 (1930)
	1931   => '1363102',            # Mariage Saint-Goazec 3 E 307/36/13 (1931)
	1932   => '1363103',            # Mariage Saint-Goazec 3 E 307/36/14 (1932)
	1933   => '1363104',            # Mariage Saint-Goazec 3 E 307/36/15 (1933)
	1934   => '1363105',            # Mariage Saint-Goazec 3 E 307/36/16 (1934)
	1935   => '1363106',            # Mariage Saint-Goazec 3 E 307/36/17 (1935)
	1936   => '1363107',            # Mariage Saint-Goazec 3 E 307/36/18 (1936)
    },

    '3E307_0037' => {			# Décès Saint-Goazec 3 E 307 37   1903-1917
	1903   => '1363228',            # Décès Saint-Goazec 3 E 307/37/1 (1903)
	1904   => '1363229',            # Décès Saint-Goazec 3 E 307/37/2 (1904)
	1905   => '1363230',            # Décès Saint-Goazec 3 E 307/37/3 (1905)
	1906   => '1363231',            # Décès Saint-Goazec 3 E 307/37/4 (1906)
	1907   => '1363232',            # Décès Saint-Goazec 3 E 307/37/5 (1907)
	1908   => '1363233',            # Décès Saint-Goazec 3 E 307/37/6 (1908)
	1909   => '1363234',            # Décès Saint-Goazec 3 E 307/37/7 (1909)
	1910   => '1363235',            # Décès Saint-Goazec 3 E 307/37/8 (1910)
	1911   => '1363236',            # Décès Saint-Goazec 3 E 307/37/9 (1911)
	1912   => '1363237',            # Décès Saint-Goazec 3 E 307/37/10 (1912)
	1913   => '1363238',            # Décès Saint-Goazec 3 E 307/37/11 (1913)
	1914   => '1363239',            # Décès Saint-Goazec 3 E 307/37/12 (1914)
	1915   => '1363240',            # Décès Saint-Goazec 3 E 307/37/13 (1915)
	1916   => '1363241',            # Décès Saint-Goazec 3 E 307/37/14 (1916)
	1917   => '1363242',            # Décès Saint-Goazec 3 E 307/37/15 (1917)
    },

    '3E307_0038' => {			# Décès Saint-Goazec 3 E 307 38   1918-1936
	1918   => '1363244',            # Décès Saint-Goazec 3 E 307/38/1 (1918)
	1919   => '1363245',            # Décès Saint-Goazec 3 E 307/38/2 (1919)
	1920   => '1363246',            # Décès Saint-Goazec 3 E 307/38/3 (1920)
	1921   => '1363247',            # Décès Saint-Goazec 3 E 307/38/4 (1921)
	1922   => '1363248',            # Décès Saint-Goazec 3 E 307/38/5 (1922)
	1923   => '1363249',            # Décès Saint-Goazec 3 E 307/38/6 (1923)
	1924   => '1363250',            # Décès Saint-Goazec 3 E 307/38/7 (1924)
	1925   => '1363251',            # Décès Saint-Goazec 3 E 307/38/8 (1925)
	1926   => '1363252',            # Décès Saint-Goazec 3 E 307/38/9 (1926)
	1927   => '1363253',            # Décès Saint-Goazec 3 E 307/38/10 (1927)
	1928   => '1363254',            # Décès Saint-Goazec 3 E 307/38/11 (1928)
	1929   => '1363255',            # Décès Saint-Goazec 3 E 307/38/12 (1929)
	1930   => '1363256',            # Décès Saint-Goazec 3 E 307/38/13 (1930)
	1931   => '1363257',            # Décès Saint-Goazec 3 E 307/38/14 (1931)
	1932   => '1363258',            # Décès Saint-Goazec 3 E 307/38/15 (1932)
	1933   => '1363259',            # Décès Saint-Goazec 3 E 307/38/16 (1933)
	1934   => '1363260',            # Décès Saint-Goazec 3 E 307/38/17 (1934)
	1935   => '1363261',            # Décès Saint-Goazec 3 E 307/38/18 (1935)
	1936   => '1363262',            # Décès Saint-Goazec 3 E 307/38/19 (1936)
    },

    # NMD Saint-Hernin
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

    '3E309_0034' => {			# Mariage Saint-Hernin 3 E 309 34   1920-1936
	1920   => '1634750',            # Mariage Saint-Hernin 3 E 309/34/1 (1920)
	1921   => '1634751',            # Mariage Saint-Hernin 3 E 309/34/2 (1921)
	1922   => '1634752',            # Mariage Saint-Hernin 3 E 309/34/3 (1922)
	1923   => '1634753',            # Mariage Saint-Hernin 3 E 309/34/4 (1923)
	1924   => '1634754',            # Mariage Saint-Hernin 3 E 309/34/5 (1924)
	1925   => '1634755',            # Mariage Saint-Hernin 3 E 309/34/6 (1925)
	1926   => '1634756',            # Mariage Saint-Hernin 3 E 309/34/7 (1926)
	1927   => '1634757',            # Mariage Saint-Hernin 3 E 309/34/8 (1927)
	1928   => '1634758',            # Mariage Saint-Hernin 3 E 309/34/9 (1928)
	1929   => '1634759',            # Mariage Saint-Hernin 3 E 309/34/10 (1929)
	1930   => '1634760',            # Mariage Saint-Hernin 3 E 309/34/11 (1930)
	1931   => '1634761',            # Mariage Saint-Hernin 3 E 309/34/12 (1931)
	1932   => '1634762',            # Mariage Saint-Hernin 3 E 309/34/13 (1932)
	1933   => '1634763',            # Mariage Saint-Hernin 3 E 309/34/14 (1933)
	1934   => '1634764',            # Mariage Saint-Hernin 3 E 309/34/15 (1934)
	1935   => '1634765',            # Mariage Saint-Hernin 3 E 309/34/16 (1935)
	1936   => '1634766',            # Mariage Saint-Hernin 3 E 309/34/17 (1936)
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


    # NMD Saint-Thurien
    '3E335_0002' => {			# Naissance Saint-Thurien 3 E 335 2   AN02-1812
	'AN02' => '1369589',            # Naissance Saint-Thurien 3 E 335/2/1 (1793 - an II)
	'AN03' => '1369590',            # Naissance Saint-Thurien 3 E 335/2/2 (an III)
	'AN04' => '1369591',            # Naissance Saint-Thurien 3 E 335/2/3 (an IV)
	'AN05' => '1369592',            # Naissance Saint-Thurien 3 E 335/2/4 (an V)
	'AN06' => '1369593',            # Naissance Saint-Thurien 3 E 335/2/5 (an VI)
	'AN07' => '1369594',            # Naissance Saint-Thurien 3 E 335/2/6 (an VII)
	'AN08' => '1369595',            # Naissance Saint-Thurien 3 E 335/2/7 (an VIII)
	'AN09' => '1369596',            # Naissance Saint-Thurien 3 E 335/2/8 (an IX)
	'AN10' => '1369597',            # Naissance Saint-Thurien 3 E 335/2/9 (an X)
	'AN11' => '1369598',            # Naissance Saint-Thurien 3 E 335/2/10 (an XI)
	'AN12' => '1369599',            # Naissance Saint-Thurien 3 E 335/2/11 (an XII)
	'AN13' => '1369600',            # Naissance Saint-Thurien 3 E 335/2/12 (an XIII)
	'AN14' => '1369601',            # Naissance Saint-Thurien 3 E 335/2/13 (an XIV - 1806)
	1807   => '1369602',            # Naissance Saint-Thurien 3 E 335/2/14 (1807)
	1808   => '1369603',            # Naissance Saint-Thurien 3 E 335/2/15 (1808)
	1809   => '1369604',            # Naissance Saint-Thurien 3 E 335/2/16 (1809)
	1810   => '1369605',            # Naissance Saint-Thurien 3 E 335/2/17 (1810)
	1811   => '1369606',            # Naissance Saint-Thurien 3 E 335/2/18 (1811)
	1812   => '1369607',            # Naissance Saint-Thurien 3 E 335/2/19 (1812)
    },

    '3E335_0003' => {			# Naissance Saint-Thurien 3 E 335 3   1813-1822
	1813   => '1369609',            # Naissance Saint-Thurien 3 E 335/3/1 (1813)
	1814   => '1369610',            # Naissance Saint-Thurien 3 E 335/3/2 (1814)
	1815   => '1369611',            # Naissance Saint-Thurien 3 E 335/3/3 (1815)
	1816   => '1369612',            # Naissance Saint-Thurien 3 E 335/3/4 (1816)
	1817   => '1369613',            # Naissance Saint-Thurien 3 E 335/3/5 (1817)
	1818   => '1369614',            # Naissance Saint-Thurien 3 E 335/3/6 (1818)
	1819   => '1369615',            # Naissance Saint-Thurien 3 E 335/3/7 (1819)
	1820   => '1369616',            # Naissance Saint-Thurien 3 E 335/3/8 (1820)
	1821   => '1369617',            # Naissance Saint-Thurien 3 E 335/3/9 (1821)
	1822   => '1369618',            # Naissance Saint-Thurien 3 E 335/3/10 (1822)
    },

    '3E335_0004' => {			# Naissance Saint-Thurien 3 E 335 4   1823-1832
	1823   => '1369620',            # Naissance Saint-Thurien 3 E 335/4/1 (1823)
	1824   => '1369621',            # Naissance Saint-Thurien 3 E 335/4/2 (1824)
	1825   => '1369622',            # Naissance Saint-Thurien 3 E 335/4/3 (1825)
	1826   => '1369623',            # Naissance Saint-Thurien 3 E 335/4/4 (1826)
	1827   => '1369624',            # Naissance Saint-Thurien 3 E 335/4/5 (1827)
	1828   => '1369625',            # Naissance Saint-Thurien 3 E 335/4/6 (1828)
	1829   => '1369626',            # Naissance Saint-Thurien 3 E 335/4/7 (1829)
	1830   => '1369627',            # Naissance Saint-Thurien 3 E 335/4/8 (1830)
	1831   => '1369628',            # Naissance Saint-Thurien 3 E 335/4/9 (1831)
	1832   => '1369629',            # Naissance Saint-Thurien 3 E 335/4/10 (1832)
    },

    '3E335_0005' => {			# Naissance Saint-Thurien 3 E 335 5   1833-1842
	1833   => '1369631',            # Naissance Saint-Thurien 3 E 335/5/1 (1833)
	1834   => '1369632',            # Naissance Saint-Thurien 3 E 335/5/2 (1834)
	1835   => '1369633',            # Naissance Saint-Thurien 3 E 335/5/3 (1835)
	1836   => '1369634',            # Naissance Saint-Thurien 3 E 335/5/4 (1836)
	1837   => '1369635',            # Naissance Saint-Thurien 3 E 335/5/5 (1837)
	1838   => '1369636',            # Naissance Saint-Thurien 3 E 335/5/6 (1838)
	1839   => '1369637',            # Naissance Saint-Thurien 3 E 335/5/7 (1839)
	1840   => '1369638',            # Naissance Saint-Thurien 3 E 335/5/8 (1840)
	1841   => '1369639',            # Naissance Saint-Thurien 3 E 335/5/9 (1841)
	1842   => '1369640',            # Naissance Saint-Thurien 3 E 335/5/10 (1842)
    },

    '3E335_0006' => {			# Naissance Saint-Thurien 3 E 335 6   1843-1852
	1843   => '1369642',            # Naissance Saint-Thurien 3 E 335/6/1 (1843)
	1844   => '1369643',            # Naissance Saint-Thurien 3 E 335/6/2 (1844)
	1845   => '1369644',            # Naissance Saint-Thurien 3 E 335/6/3 (1845)
	1846   => '1369645',            # Naissance Saint-Thurien 3 E 335/6/4 (1846)
	1847   => '1369646',            # Naissance Saint-Thurien 3 E 335/6/5 (1847)
	1848   => '1369647',            # Naissance Saint-Thurien 3 E 335/6/6 (1848)
	1849   => '1369648',            # Naissance Saint-Thurien 3 E 335/6/7 (1849)
	1850   => '1369649',            # Naissance Saint-Thurien 3 E 335/6/8 (1850)
	1851   => '1369650',            # Naissance Saint-Thurien 3 E 335/6/9 (1851)
	1852   => '1369651',            # Naissance Saint-Thurien 3 E 335/6/10 (1852)
    },

    '3E335_0007' => {			# Naissance Saint-Thurien 3 E 335 7   1853-1862
	1853   => '1369653',            # Naissance Saint-Thurien 3 E 335/7/1 (1853)
	1854   => '1369654',            # Naissance Saint-Thurien 3 E 335/7/2 (1854)
	1855   => '1369655',            # Naissance Saint-Thurien 3 E 335/7/3 (1855)
	1856   => '1369656',            # Naissance Saint-Thurien 3 E 335/7/4 (1856)
	1857   => '1369657',            # Naissance Saint-Thurien 3 E 335/7/5 (1857)
	1858   => '1369658',            # Naissance Saint-Thurien 3 E 335/7/6 (1858)
	1859   => '1369659',            # Naissance Saint-Thurien 3 E 335/7/7 (1859)
	1860   => '1369660',            # Naissance Saint-Thurien 3 E 335/7/8 (1860)
	1861   => '1369661',            # Naissance Saint-Thurien 3 E 335/7/9 (1861)
	1862   => '1369662',            # Naissance Saint-Thurien 3 E 335/7/10 (1862)
    },

    '3E335_0008' => {			# Naissance Saint-Thurien 3 E 335 8   1863-1869
	1863   => '1369664',            # Naissance Saint-Thurien 3 E 335/8/1 (1863)
	1864   => '1369665',            # Naissance Saint-Thurien 3 E 335/8/2 (1864)
	1865   => '1369666',            # Naissance Saint-Thurien 3 E 335/8/3 (1865)
	1866   => '1369667',            # Naissance Saint-Thurien 3 E 335/8/4 (1866)
	1867   => '1369668',            # Naissance Saint-Thurien 3 E 335/8/5 (1867)
	1868   => '1369669',            # Naissance Saint-Thurien 3 E 335/8/6 (1868)
	1869   => '1369670',            # Naissance Saint-Thurien 3 E 335/8/7 (1869)
    },

    '3E335_0009' => {			# Naissance Saint-Thurien 3 E 335 9   1870-1885
	1870   => '1369672',            # Naissance Saint-Thurien 3 E 335/9/1 (1870)
	1871   => '1369673',            # Naissance Saint-Thurien 3 E 335/9/2 (1871)
	1872   => '1369674',            # Naissance Saint-Thurien 3 E 335/9/3 (1872)
	1873   => '1369675',            # Naissance Saint-Thurien 3 E 335/9/4 (1873)
	1874   => '1369676',            # Naissance Saint-Thurien 3 E 335/9/5 (1874)
	1875   => '1369677',            # Naissance Saint-Thurien 3 E 335/9/6 (1875)
	1876   => '1369678',            # Naissance Saint-Thurien 3 E 335/9/7 (1876)
	1877   => '1369679',            # Naissance Saint-Thurien 3 E 335/9/8 (1877)
	1878   => '1369680',            # Naissance Saint-Thurien 3 E 335/9/9 (1878)
	1879   => '1369681',            # Naissance Saint-Thurien 3 E 335/9/10 (1879)
	1880   => '1369682',            # Naissance Saint-Thurien 3 E 335/9/11 (1880)
	1881   => '1369683',            # Naissance Saint-Thurien 3 E 335/9/12 (1881)
	1882   => '1369684',            # Naissance Saint-Thurien 3 E 335/9/13 (1882)
	1883   => '1369685',            # Naissance Saint-Thurien 3 E 335/9/14 (1883)
	1884   => '1369686',            # Naissance Saint-Thurien 3 E 335/9/15 (1884)
	1885   => '1369687',            # Naissance Saint-Thurien 3 E 335/9/16 (1885)
    },

    '3E335_0010' => {			# Mariage promesse de mariage Saint-Thurien 3 E 335 10   AN02-1812
	'AN02' => '1369745',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/1 (1793 - an II)
	'AN03' => '1369746',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/2 (an III)
	'AN04' => '1369747',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/3 (an IV)
	'AN05' => '1369748',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/4 (an V)
	'AN07' => '1369749',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/5 (an VII)
	'AN09' => '1369750',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/6 (an IX)
	'AN10' => '1369751',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/7 (an X)
	'AN11' => '1369752',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/8 (an XI)
	'AN12' => '1369753',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/9 (an XII)
	'AN13' => '1369754',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/10 (an XIII)
	'AN14' => '1369755',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/11 (an XIV - 1806)
	1807   => '1369756',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/12 (1807)
	1808   => '1369757',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/13 (1808)
	1809   => '1369758',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/14 (1809)
	1810   => '1369759',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/15 (1810)
	1811   => '1369760',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/16 (1811)
	1812   => '1369761',            # Mariage promesse de mariage Saint-Thurien 3 E 335/10/17 (1812)
    },

    '3E335_0011' => {			# Mariage Saint-Thurien 3 E 335 11   1813-1822
	1813   => '1369763',            # Mariage Saint-Thurien 3 E 335/11/1 (1813)
	1814   => '1369764',            # Mariage Saint-Thurien 3 E 335/11/2 (1814)
	1815   => '1369765',            # Mariage Saint-Thurien 3 E 335/11/3 (1815)
	1816   => '1369766',            # Mariage Saint-Thurien 3 E 335/11/4 (1816)
	1817   => '1369767',            # Mariage Saint-Thurien 3 E 335/11/5 (1817)
	1818   => '1369768',            # Mariage Saint-Thurien 3 E 335/11/6 (1818)
	1819   => '1369769',            # Mariage Saint-Thurien 3 E 335/11/7 (1819)
	1820   => '1369770',            # Mariage Saint-Thurien 3 E 335/11/8 (1820)
	1821   => '1369771',            # Mariage Saint-Thurien 3 E 335/11/9 (1821)
	1822   => '1369772',            # Mariage Saint-Thurien 3 E 335/11/10 (1822)
    },

    '3E335_0012' => {			# Mariage Saint-Thurien 3 E 335 12   1823-1832
	1823   => '1369774',            # Mariage Saint-Thurien 3 E 335/12/1 (1823)
	1824   => '1369775',            # Mariage Saint-Thurien 3 E 335/12/2 (1824)
	1825   => '1369776',            # Mariage Saint-Thurien 3 E 335/12/3 (1825)
	1826   => '1369777',            # Mariage Saint-Thurien 3 E 335/12/4 (1826)
	1827   => '1369778',            # Mariage Saint-Thurien 3 E 335/12/5 (1827)
	1828   => '1369779',            # Mariage Saint-Thurien 3 E 335/12/6 (1828)
	1829   => '1369780',            # Mariage Saint-Thurien 3 E 335/12/7 (1829)
	1830   => '1369781',            # Mariage Saint-Thurien 3 E 335/12/8 (1830)
	1831   => '1369782',            # Mariage Saint-Thurien 3 E 335/12/9 (1831)
	1832   => '1369783',            # Mariage Saint-Thurien 3 E 335/12/10 (1832)
    },

    '3E335_0013' => {			# Mariage Saint-Thurien 3 E 335 13   1833-1842
	1833   => '1369785',            # Mariage Saint-Thurien 3 E 335/13/1 (1833)
	1834   => '1369786',            # Mariage Saint-Thurien 3 E 335/13/2 (1834)
	1835   => '1369787',            # Mariage Saint-Thurien 3 E 335/13/3 (1835)
	1836   => '1369788',            # Mariage Saint-Thurien 3 E 335/13/4 (1836)
	1837   => '1369789',            # Mariage Saint-Thurien 3 E 335/13/5 (1837)
	1838   => '1369790',            # Mariage Saint-Thurien 3 E 335/13/6 (1838)
	1839   => '1369791',            # Mariage Saint-Thurien 3 E 335/13/7 (1839)
	1840   => '1369792',            # Mariage Saint-Thurien 3 E 335/13/8 (1840)
	1841   => '1369793',            # Mariage Saint-Thurien 3 E 335/13/9 (1841)
	1842   => '1369794',            # Mariage Saint-Thurien 3 E 335/13/10 (1842)
    },

    '3E335_0014' => {			# Mariage Saint-Thurien 3 E 335 14   1843-1852
	1843   => '1369796',            # Mariage Saint-Thurien 3 E 335/14/1 (1843)
	1844   => '1369797',            # Mariage Saint-Thurien 3 E 335/14/2 (1844)
	1845   => '1369798',            # Mariage Saint-Thurien 3 E 335/14/3 (1845)
	1846   => '1369799',            # Mariage Saint-Thurien 3 E 335/14/4 (1846)
	1847   => '1369800',            # Mariage Saint-Thurien 3 E 335/14/5 (1847)
	1848   => '1369801',            # Mariage Saint-Thurien 3 E 335/14/6 (1848)
	1849   => '1369802',            # Mariage Saint-Thurien 3 E 335/14/7 (1849)
	1850   => '1369803',            # Mariage Saint-Thurien 3 E 335/14/8 (1850)
	1851   => '1369804',            # Mariage Saint-Thurien 3 E 335/14/9 (1851)
	1852   => '1369805',            # Mariage Saint-Thurien 3 E 335/14/10 (1852)
    },

    '3E335_0015' => {			# Mariage Saint-Thurien 3 E 335 15   1853-1862
	1853   => '1369807',            # Mariage Saint-Thurien 3 E 335/15/1 (1853)
	1854   => '1369808',            # Mariage Saint-Thurien 3 E 335/15/2 (1854)
	1855   => '1369809',            # Mariage Saint-Thurien 3 E 335/15/3 (1855)
	1856   => '1369810',            # Mariage Saint-Thurien 3 E 335/15/4 (1856)
	1857   => '1369811',            # Mariage Saint-Thurien 3 E 335/15/5 (1857)
	1858   => '1369812',            # Mariage Saint-Thurien 3 E 335/15/6 (1858)
	1859   => '1369813',            # Mariage Saint-Thurien 3 E 335/15/7 (1859)
	1860   => '1369814',            # Mariage Saint-Thurien 3 E 335/15/8 (1860)
	1861   => '1369815',            # Mariage Saint-Thurien 3 E 335/15/9 (1861)
	1862   => '1369816',            # Mariage Saint-Thurien 3 E 335/15/10 (1862)
    },

    '3E335_0016' => {			# Mariage Saint-Thurien 3 E 335 16   1863-1869
	1863   => '1369818',            # Mariage Saint-Thurien 3 E 335/16/1 (1863)
	1864   => '1369819',            # Mariage Saint-Thurien 3 E 335/16/2 (1864)
	1865   => '1369820',            # Mariage Saint-Thurien 3 E 335/16/3 (1865)
	1866   => '1369821',            # Mariage Saint-Thurien 3 E 335/16/4 (1866)
	1867   => '1369822',            # Mariage Saint-Thurien 3 E 335/16/5 (1867)
	1868   => '1369823',            # Mariage Saint-Thurien 3 E 335/16/6 (1868)
	1869   => '1369824',            # Mariage Saint-Thurien 3 E 335/16/7 (1869)
    },

    '3E335_0017' => {			# Mariage Saint-Thurien 3 E 335 17   1870-1888
	1870   => '1369826',            # Mariage Saint-Thurien 3 E 335/17/1 (1870)
	1871   => '1369827',            # Mariage Saint-Thurien 3 E 335/17/2 (1871)
	1872   => '1369828',            # Mariage Saint-Thurien 3 E 335/17/3 (1872)
	1873   => '1369829',            # Mariage Saint-Thurien 3 E 335/17/4 (1873)
	1874   => '1369830',            # Mariage Saint-Thurien 3 E 335/17/5 (1874)
	1875   => '1369831',            # Mariage Saint-Thurien 3 E 335/17/6 (1875)
	1876   => '1369832',            # Mariage Saint-Thurien 3 E 335/17/7 (1876)
	1877   => '1369833',            # Mariage Saint-Thurien 3 E 335/17/8 (1877)
	1878   => '1369834',            # Mariage Saint-Thurien 3 E 335/17/9 (1878)
	1879   => '1369835',            # Mariage Saint-Thurien 3 E 335/17/10 (1879)
	1880   => '1369836',            # Mariage Saint-Thurien 3 E 335/17/11 (1880)
	1881   => '1369837',            # Mariage Saint-Thurien 3 E 335/17/12 (1881)
	1882   => '1369838',            # Mariage Saint-Thurien 3 E 335/17/13 (1882)
	1883   => '1369839',            # Mariage Saint-Thurien 3 E 335/17/14 (1883)
	1884   => '1369840',            # Mariage Saint-Thurien 3 E 335/17/15 (1884)
	1885   => '1369841',            # Mariage Saint-Thurien 3 E 335/17/16 (1885)
	1886   => '1369842',            # Mariage Saint-Thurien 3 E 335/17/17 (1886)
	1887   => '1369843',            # Mariage Saint-Thurien 3 E 335/17/18 (1887)
	1888   => '1369844',            # Mariage Saint-Thurien 3 E 335/17/19 (1888)
    },

    '3E335_0018' => {			# Décès Saint-Thurien 3 E 335 18   AN02-1812
	'AN02' => '1369898',            # Décès Saint-Thurien 3 E 335/18/1 (1793 - an II)
	'AN03' => '1369899',            # Décès Saint-Thurien 3 E 335/18/2 (an III)
	'AN04' => '1369900',            # Décès Saint-Thurien 3 E 335/18/3 (an IV)
	'AN05' => '1369901',            # Décès Saint-Thurien 3 E 335/18/4 (an V)
	'AN06' => '1369902',            # Décès Saint-Thurien 3 E 335/18/5 (an VI)
	'AN07' => '1369903',            # Décès Saint-Thurien 3 E 335/18/6 (an VII)
	'AN08' => '1369904',            # Décès Saint-Thurien 3 E 335/18/7 (an VIII)
	'AN09' => '1369905',            # Décès Saint-Thurien 3 E 335/18/8 (an IX)
	'AN10' => '1369906',            # Décès Saint-Thurien 3 E 335/18/9 (an X)
	'AN11' => '1369907',            # Décès Saint-Thurien 3 E 335/18/10 (an XI)
	'AN12' => '1369908',            # Décès Saint-Thurien 3 E 335/18/11 (an XII)
	'AN13' => '1369909',            # Décès Saint-Thurien 3 E 335/18/12 (an XIII)
	'AN14' => '1369910',            # Décès Saint-Thurien 3 E 335/18/13 (an XIV - 1806)
	1807   => '1369911',            # Décès Saint-Thurien 3 E 335/18/14 (1807)
	1808   => '1369912',            # Décès Saint-Thurien 3 E 335/18/15 (1808)
	1809   => '1369913',            # Décès Saint-Thurien 3 E 335/18/16 (1809)
	1810   => '1369914',            # Décès Saint-Thurien 3 E 335/18/17 (1810)
	1811   => '1369915',            # Décès Saint-Thurien 3 E 335/18/18 (1811)
	1812   => '1369916',            # Décès Saint-Thurien 3 E 335/18/19 (1812)
    },


    '3E335_0019' => {			# Décès Saint-Thurien 3 E 335 19   1813-1822
	1813   => '1369918',            # Décès Saint-Thurien 3 E 335/19/1 (1813)
	1814   => '1369919',            # Décès Saint-Thurien 3 E 335/19/2 (1814)
	1815   => '1369920',            # Décès Saint-Thurien 3 E 335/19/3 (1815)
	1816   => '1369921',            # Décès Saint-Thurien 3 E 335/19/4 (1816)
	1817   => '1369922',            # Décès Saint-Thurien 3 E 335/19/5 (1817)
	1818   => '1369923',            # Décès Saint-Thurien 3 E 335/19/6 (1818)
	1819   => '1369924',            # Décès Saint-Thurien 3 E 335/19/7 (1819)
	1820   => '1369925',            # Décès Saint-Thurien 3 E 335/19/8 (1820)
	1821   => '1369926',            # Décès Saint-Thurien 3 E 335/19/9 (1821)
	1822   => '1369927',            # Décès Saint-Thurien 3 E 335/19/10 (1822)
    },

    '3E335_0020' => {			# Décès Saint-Thurien 3 E 335 20   1823-1832
	1823   => '1369929',            # Décès Saint-Thurien 3 E 335/20/1 (1823)
	1824   => '1369930',            # Décès Saint-Thurien 3 E 335/20/2 (1824)
	1825   => '1369931',            # Décès Saint-Thurien 3 E 335/20/3 (1825)
	1826   => '1369932',            # Décès Saint-Thurien 3 E 335/20/4 (1826)
	1827   => '1369933',            # Décès Saint-Thurien 3 E 335/20/5 (1827)
	1828   => '1369934',            # Décès Saint-Thurien 3 E 335/20/6 (1828)
	1829   => '1369935',            # Décès Saint-Thurien 3 E 335/20/7 (1829)
	1830   => '1369936',            # Décès Saint-Thurien 3 E 335/20/8 (1830)
	1831   => '1369937',            # Décès Saint-Thurien 3 E 335/20/9 (1831)
	1832   => '1369938',            # Décès Saint-Thurien 3 E 335/20/10 (1832)
    },

    '3E335_0021' => {			# Décès Saint-Thurien 3 E 335 21   1833-1842
	1833   => '1369940',            # Décès Saint-Thurien 3 E 335/21/1 (1833)
	1834   => '1369941',            # Décès Saint-Thurien 3 E 335/21/2 (1834)
	1835   => '1369942',            # Décès Saint-Thurien 3 E 335/21/3 (1835)
	1836   => '1369943',            # Décès Saint-Thurien 3 E 335/21/4 (1836)
	1837   => '1369944',            # Décès Saint-Thurien 3 E 335/21/5 (1837)
	1838   => '1369945',            # Décès Saint-Thurien 3 E 335/21/6 (1838)
	1839   => '1369946',            # Décès Saint-Thurien 3 E 335/21/7 (1839)
	1840   => '1369947',            # Décès Saint-Thurien 3 E 335/21/8 (1840)
	1841   => '1369948',            # Décès Saint-Thurien 3 E 335/21/9 (1841)
	1842   => '1369949',            # Décès Saint-Thurien 3 E 335/21/10 (1842)
    },

    '3E335_0022' => {			# Décès Saint-Thurien 3 E 335 22   1843-1852
	1843   => '1369951',            # Décès Saint-Thurien 3 E 335/22/1 (1843)
	1844   => '1369952',            # Décès Saint-Thurien 3 E 335/22/2 (1844)
	1845   => '1369953',            # Décès Saint-Thurien 3 E 335/22/3 (1845)
	1846   => '1369954',            # Décès Saint-Thurien 3 E 335/22/4 (1846)
	1847   => '1369955',            # Décès Saint-Thurien 3 E 335/22/5 (1847)
	1848   => '1369956',            # Décès Saint-Thurien 3 E 335/22/6 (1848)
	1849   => '1369957',            # Décès Saint-Thurien 3 E 335/22/7 (1849)
	1850   => '1369958',            # Décès Saint-Thurien 3 E 335/22/8 (1850)
	1851   => '1369959',            # Décès Saint-Thurien 3 E 335/22/9 (1851)
	1852   => '1369960',            # Décès Saint-Thurien 3 E 335/22/10 (1852)
    },

    '3E335_0023' => {			# Décès Saint-Thurien 3 E 335 23   1853-1862
	1853   => '1369962',            # Décès Saint-Thurien 3 E 335/23/1 (1853)
	1854   => '1369963',            # Décès Saint-Thurien 3 E 335/23/2 (1854)
	1855   => '1369964',            # Décès Saint-Thurien 3 E 335/23/3 (1855)
	1856   => '1369965',            # Décès Saint-Thurien 3 E 335/23/4 (1856)
	1857   => '1369966',            # Décès Saint-Thurien 3 E 335/23/5 (1857)
	1858   => '1369967',            # Décès Saint-Thurien 3 E 335/23/6 (1858)
	1859   => '1369968',            # Décès Saint-Thurien 3 E 335/23/7 (1859)
	1860   => '1369969',            # Décès Saint-Thurien 3 E 335/23/8 (1860)
	1861   => '1369970',            # Décès Saint-Thurien 3 E 335/23/9 (1861)
	1862   => '1369971',            # Décès Saint-Thurien 3 E 335/23/10 (1862)
    },

    '3E335_0024' => {			# Décès Saint-Thurien 3 E 335 24   1863-1869
	1863   => '1369973',            # Décès Saint-Thurien 3 E 335/24/1 (1863)
	1864   => '1369974',            # Décès Saint-Thurien 3 E 335/24/2 (1864)
	1865   => '1369975',            # Décès Saint-Thurien 3 E 335/24/3 (1865)
	1866   => '1369976',            # Décès Saint-Thurien 3 E 335/24/4 (1866)
	1867   => '1369977',            # Décès Saint-Thurien 3 E 335/24/5 (1867)
	1868   => '1369978',            # Décès Saint-Thurien 3 E 335/24/6 (1868)
	1869   => '1369979',            # Décès Saint-Thurien 3 E 335/24/7 (1869)
    },

    '3E335_0025' => {			# Décès Saint-Thurien 3 E 335 25   1870-1887
	1870   => '1369981',            # Décès Saint-Thurien 3 E 335/25/1 (1870)
	1871   => '1369982',            # Décès Saint-Thurien 3 E 335/25/2 (1871)
	1872   => '1369983',            # Décès Saint-Thurien 3 E 335/25/3 (1872)
	1873   => '1369984',            # Décès Saint-Thurien 3 E 335/25/4 (1873)
	1874   => '1369985',            # Décès Saint-Thurien 3 E 335/25/5 (1874)
	1875   => '1369986',            # Décès Saint-Thurien 3 E 335/25/6 (1875)
	1876   => '1369987',            # Décès Saint-Thurien 3 E 335/25/7 (1876)
	1877   => '1369988',            # Décès Saint-Thurien 3 E 335/25/8 (1877)
	1878   => '1369989',            # Décès Saint-Thurien 3 E 335/25/9 (1878)
	1879   => '1369990',            # Décès Saint-Thurien 3 E 335/25/10 (1879)
	1880   => '1369991',            # Décès Saint-Thurien 3 E 335/25/11 (1880)
	1881   => '1369992',            # Décès Saint-Thurien 3 E 335/25/12 (1881)
	1882   => '1369993',            # Décès Saint-Thurien 3 E 335/25/13 (1882)
	1883   => '1369994',            # Décès Saint-Thurien 3 E 335/25/14 (1883)
	1884   => '1369995',            # Décès Saint-Thurien 3 E 335/25/15 (1884)
	1885   => '1369996',            # Décès Saint-Thurien 3 E 335/25/16 (1885)
	1886   => '1369997',            # Décès Saint-Thurien 3 E 335/25/17 (1886)
	1887   => '1369998',            # Décès Saint-Thurien 3 E 335/25/18 (1887)
    },

    '3E335_0026' => {			# Naissance Saint-Thurien 3 E 335 26   1886-1898
	1886   => '1369689',            # Naissance Saint-Thurien 3 E 335/26/1 (1886)
	1887   => '1369690',            # Naissance Saint-Thurien 3 E 335/26/2 (1887)
	1888   => '1369691',            # Naissance Saint-Thurien 3 E 335/26/3 (1888)
	1889   => '1369692',            # Naissance Saint-Thurien 3 E 335/26/4 (1889)
	1890   => '1369693',            # Naissance Saint-Thurien 3 E 335/26/5 (1890)
	1891   => '1369694',            # Naissance Saint-Thurien 3 E 335/26/6 (1891)
	1892   => '1369695',            # Naissance Saint-Thurien 3 E 335/26/7 (1892)
	1893   => '1369696',            # Naissance Saint-Thurien 3 E 335/26/8 (1893)
	1894   => '1369697',            # Naissance Saint-Thurien 3 E 335/26/9 (1894)
	1895   => '1369698',            # Naissance Saint-Thurien 3 E 335/26/10 (1895)
	1896   => '1369699',            # Naissance Saint-Thurien 3 E 335/26/11 (1896)
	1897   => '1369700',            # Naissance Saint-Thurien 3 E 335/26/12 (1897)
	1898   => '1369701',            # Naissance Saint-Thurien 3 E 335/26/13 (1898)
    },

    '3E335_0027' => {			# Mariage Saint-Thurien 3 E 335 27   1889-1906
	1889   => '1369846',            # Mariage Saint-Thurien 3 E 335/27/1 (1889)
	1890   => '1369847',            # Mariage Saint-Thurien 3 E 335/27/2 (1890)
	1891   => '1369848',            # Mariage Saint-Thurien 3 E 335/27/3 (1891)
	1892   => '1369849',            # Mariage Saint-Thurien 3 E 335/27/4 (1892)
	1893   => '1369850',            # Mariage Saint-Thurien 3 E 335/27/5 (1893)
	1894   => '1369851',            # Mariage Saint-Thurien 3 E 335/27/6 (1894)
	1895   => '1369852',            # Mariage Saint-Thurien 3 E 335/27/7 (1895)
	1896   => '1369853',            # Mariage Saint-Thurien 3 E 335/27/8 (1896)
	1897   => '1369854',            # Mariage Saint-Thurien 3 E 335/27/9 (1897)
	1898   => '1369855',            # Mariage Saint-Thurien 3 E 335/27/10 (1898)
	1899   => '1369856',            # Mariage Saint-Thurien 3 E 335/27/11 (1899)
	1900   => '1369857',            # Mariage Saint-Thurien 3 E 335/27/12 (1900)
	1901   => '1369858',            # Mariage Saint-Thurien 3 E 335/27/13 (1901)
	1902   => '1369859',            # Mariage Saint-Thurien 3 E 335/27/14 (1902)
	1903   => '1369860',            # Mariage Saint-Thurien 3 E 335/27/15 (1903)
	1904   => '1369861',            # Mariage Saint-Thurien 3 E 335/27/16 (1904)
	1905   => '1369862',            # Mariage Saint-Thurien 3 E 335/27/17 (1905)
	1906   => '1369863',            # Mariage Saint-Thurien 3 E 335/27/18 (1906)
    },

    '3E335_0028' => {			# Décès Saint-Thurien 3 E 335 28   1888-1904
	1888   => '1370000',            # Décès Saint-Thurien 3 E 335/28/1 (1888)
	1889   => '1370001',            # Décès Saint-Thurien 3 E 335/28/2 (1889)
	1890   => '1370002',            # Décès Saint-Thurien 3 E 335/28/3 (1890)
	1891   => '1370003',            # Décès Saint-Thurien 3 E 335/28/4 (1891)
	1892   => '1370004',            # Décès Saint-Thurien 3 E 335/28/5 (1892)
	1893   => '1370005',            # Décès Saint-Thurien 3 E 335/28/6 (1893)
	1894   => '1370006',            # Décès Saint-Thurien 3 E 335/28/7 (1894)
	1895   => '1370007',            # Décès Saint-Thurien 3 E 335/28/8 (1895)
	1896   => '1370008',            # Décès Saint-Thurien 3 E 335/28/9 (1896)
	1897   => '1370009',            # Décès Saint-Thurien 3 E 335/28/10 (1897)
	1898   => '1370010',            # Décès Saint-Thurien 3 E 335/28/11 (1898)
	1899   => '1370011',            # Décès Saint-Thurien 3 E 335/28/12 (1899)
	1900   => '1370012',            # Décès Saint-Thurien 3 E 335/28/13 (1900)
	1901   => '1370013',            # Décès Saint-Thurien 3 E 335/28/14 (1901)
	1902   => '1370014',            # Décès Saint-Thurien 3 E 335/28/15 (1902)
	1903   => '1370015',            # Décès Saint-Thurien 3 E 335/28/16 (1903)
	1904   => '1370016',            # Décès Saint-Thurien 3 E 335/28/17 (1904)
    },

    '3E335_0029' => {			# Naissance Saint-Thurien 3 E 335 29   1899-1910
	1899   => '1369703',            # Naissance Saint-Thurien 3 E 335/29/1 (1899)
	1900   => '1369704',            # Naissance Saint-Thurien 3 E 335/29/2 (1900)
	1901   => '1369705',            # Naissance Saint-Thurien 3 E 335/29/3 (1901)
	1902   => '1369706',            # Naissance Saint-Thurien 3 E 335/29/4 (1902)
	1903   => '1369707',            # Naissance Saint-Thurien 3 E 335/29/5 (1903)
	1904   => '1369708',            # Naissance Saint-Thurien 3 E 335/29/6 (1904)
	1905   => '1369709',            # Naissance Saint-Thurien 3 E 335/29/7 (1905)
	1906   => '1369710',            # Naissance Saint-Thurien 3 E 335/29/8 (1906)
	1907   => '1369711',            # Naissance Saint-Thurien 3 E 335/29/9 (1907)
	1908   => '1369712',            # Naissance Saint-Thurien 3 E 335/29/10 (1908)
	1909   => '1369713',            # Naissance Saint-Thurien 3 E 335/29/11 (1909)
	1910   => '1369714',            # Naissance Saint-Thurien 3 E 335/29/12 (1910)
    },

    '3E335_0030' => {			# Naissance Saint-Thurien 3 E 335 30   1911-1921
	1911   => '1369716',            # Naissance Saint-Thurien 3 E 335/30/1 (1911)
	1912   => '1369717',            # Naissance Saint-Thurien 3 E 335/30/2 (1912)
	1913   => '1369718',            # Naissance Saint-Thurien 3 E 335/30/3 (1913)
	1914   => '1369719',            # Naissance Saint-Thurien 3 E 335/30/4 (1914)
	1915   => '1369720',            # Naissance Saint-Thurien 3 E 335/30/5 (1915)
	1916   => '1369721',            # Naissance Saint-Thurien 3 E 335/30/6 (1916)
	1917   => '1369722',            # Naissance Saint-Thurien 3 E 335/30/7 (1917)
	1918   => '1369723',            # Naissance Saint-Thurien 3 E 335/30/8 (1918)
	1919   => '1369724',            # Naissance Saint-Thurien 3 E 335/30/9 (1919)
	1920   => '1369725',            # Naissance Saint-Thurien 3 E 335/30/10 (1920)
	1921   => '1369726',            # Naissance Saint-Thurien 3 E 335/30/11 (1921)
    },

    '3E335_0031' => {			# Naissance Saint-Thurien 3 E 335 31   1922-1925
	1922   => '1369728',            # Naissance Saint-Thurien 3 E 335/31/1 (1922)
	1923   => '1369729',            # Naissance Saint-Thurien 3 E 335/31/2 (1923)
	1924   => '1369730',            # Naissance Saint-Thurien 3 E 335/31/3 (1924)
	1925   => '1369731',            # Naissance Saint-Thurien 3 E 335/31/4 (1925)
    },

    '3E335_0032' => {			# Mariage Saint-Thurien 3 E 335 32   1907-1921
	1907   => '1369865',            # Mariage Saint-Thurien 3 E 335/32/1 (1907)
	1908   => '1369866',            # Mariage Saint-Thurien 3 E 335/32/2 (1908)
	1909   => '1369867',            # Mariage Saint-Thurien 3 E 335/32/3 (1909)
	1910   => '1369868',            # Mariage Saint-Thurien 3 E 335/32/4 (1910)
	1911   => '1369869',            # Mariage Saint-Thurien 3 E 335/32/5 (1911)
	1912   => '1369870',            # Mariage Saint-Thurien 3 E 335/32/6 (1912)
	1913   => '1369871',            # Mariage Saint-Thurien 3 E 335/32/7 (1913)
	1914   => '1369872',            # Mariage Saint-Thurien 3 E 335/32/8 (1914)
	1915   => '1369873',            # Mariage Saint-Thurien 3 E 335/32/9 (1915)
	1916   => '1369874',            # Mariage Saint-Thurien 3 E 335/32/10 (1916)
	1917   => '1369875',            # Mariage Saint-Thurien 3 E 335/32/11 (1917)
	1918   => '1369876',            # Mariage Saint-Thurien 3 E 335/32/12 (1918)
	1919   => '1369877',            # Mariage Saint-Thurien 3 E 335/32/13 (1919)
	1920   => '1369878',            # Mariage Saint-Thurien 3 E 335/32/14 (1920)
	1921   => '1369879',            # Mariage Saint-Thurien 3 E 335/32/15 (1921)
    },

    '3E335_0033' => {			# Mariage Saint-Thurien 3 E 335 33   1922-1936
	1922   => '1369881',            # Mariage Saint-Thurien 3 E 335/33/1 (1922)
	1923   => '1369882',            # Mariage Saint-Thurien 3 E 335/33/2 (1923)
	1924   => '1369883',            # Mariage Saint-Thurien 3 E 335/33/3 (1924)
	1925   => '1369884',            # Mariage Saint-Thurien 3 E 335/33/4 (1925)
	1926   => '1369885',            # Mariage Saint-Thurien 3 E 335/33/5 (1926)
	1927   => '1369886',            # Mariage Saint-Thurien 3 E 335/33/6 (1927)
	1928   => '1369887',            # Mariage Saint-Thurien 3 E 335/33/7 (1928)
	1929   => '1369888',            # Mariage Saint-Thurien 3 E 335/33/8 (1929)
	1930   => '1369889',            # Mariage Saint-Thurien 3 E 335/33/9 (1930)
	1931   => '1369890',            # Mariage Saint-Thurien 3 E 335/33/10 (1931)
	1932   => '1369891',            # Mariage Saint-Thurien 3 E 335/33/11 (1932)
	1933   => '1369892',            # Mariage Saint-Thurien 3 E 335/33/12 (1933)
	1934   => '1369893',            # Mariage Saint-Thurien 3 E 335/33/13 (1934)
	1935   => '1369894',            # Mariage Saint-Thurien 3 E 335/33/14 (1935)
	1936   => '1369895',            # Mariage Saint-Thurien 3 E 335/33/15 (1936)
    },

    '3E335_0034' => {			# Décès Saint-Thurien 3 E 335 34   1905-1919
	1905   => '1370018',            # Décès Saint-Thurien 3 E 335/34/1 (1905)
	1906   => '1370019',            # Décès Saint-Thurien 3 E 335/34/2 (1906)
	1907   => '1370020',            # Décès Saint-Thurien 3 E 335/34/3 (1907)
	1908   => '1370021',            # Décès Saint-Thurien 3 E 335/34/4 (1908)
	1909   => '1370022',            # Décès Saint-Thurien 3 E 335/34/5 (1909)
	1910   => '1370023',            # Décès Saint-Thurien 3 E 335/34/6 (1910)
	1911   => '1370024',            # Décès Saint-Thurien 3 E 335/34/7 (1911)
	1912   => '1370025',            # Décès Saint-Thurien 3 E 335/34/8 (1912)
	1913   => '1370026',            # Décès Saint-Thurien 3 E 335/34/9 (1913)
	1914   => '1370027',            # Décès Saint-Thurien 3 E 335/34/10 (1914)
	1915   => '1370028',            # Décès Saint-Thurien 3 E 335/34/11 (1915)
	1916   => '1370029',            # Décès Saint-Thurien 3 E 335/34/12 (1916)
	1917   => '1370030',            # Décès Saint-Thurien 3 E 335/34/13 (1917)
	1918   => '1370031',            # Décès Saint-Thurien 3 E 335/34/14 (1918)
	1919   => '1370032',            # Décès Saint-Thurien 3 E 335/34/15 (1919)
    },

    '3E335_0035' => {			# Décès Saint-Thurien 3 E 335 35   1920-1936
	1920   => '1370034',            # Décès Saint-Thurien 3 E 335/35/1 (1920)
	1921   => '1370035',            # Décès Saint-Thurien 3 E 335/35/2 (1921)
	1922   => '1370036',            # Décès Saint-Thurien 3 E 335/35/3 (1922)
	1923   => '1370037',            # Décès Saint-Thurien 3 E 335/35/4 (1923)
	1924   => '1370038',            # Décès Saint-Thurien 3 E 335/35/5 (1924)
	1925   => '1370039',            # Décès Saint-Thurien 3 E 335/35/6 (1925)
	1926   => '1370040',            # Décès Saint-Thurien 3 E 335/35/7 (1926)
	1927   => '1370041',            # Décès Saint-Thurien 3 E 335/35/8 (1927)
	1928   => '1370042',            # Décès Saint-Thurien 3 E 335/35/9 (1928)
	1929   => '1370043',            # Décès Saint-Thurien 3 E 335/35/10 (1929)
	1930   => '1370044',            # Décès Saint-Thurien 3 E 335/35/11 (1930)
	1931   => '1370045',            # Décès Saint-Thurien 3 E 335/35/12 (1931)
	1932   => '1370046',            # Décès Saint-Thurien 3 E 335/35/13 (1932)
	1933   => '1370047',            # Décès Saint-Thurien 3 E 335/35/14 (1933)
	1934   => '1370048',            # Décès Saint-Thurien 3 E 335/35/15 (1934)
	1935   => '1370049',            # Décès Saint-Thurien 3 E 335/35/16 (1935)
	1936   => '1370050',            # Décès Saint-Thurien 3 E 335/35/17 (1936)
    },

    # NMD Saint-Yvi
    '3E339_0004' => {			# Naissance Saint-Yvi 3 E 339 4   AN02-AN10
	'AN02' => '1370901',            # Naissance Saint-Yvi 3 E 339/4/1 (1793 - an II)
	'AN03' => '1370902',            # Naissance Saint-Yvi 3 E 339/4/2 (an III)
	'AN04' => '1370903',            # Naissance Saint-Yvi 3 E 339/4/3 (an IV)
	'AN05' => '1370904',            # Naissance Saint-Yvi 3 E 339/4/4 (an V)
	'AN06' => '1370905',            # Naissance Saint-Yvi 3 E 339/4/5 (an VI)
	'AN07' => '1370906',            # Naissance Saint-Yvi 3 E 339/4/6 (an VII)
	'AN08' => '1370907',            # Naissance Saint-Yvi 3 E 339/4/7 (an VIII)
	'AN09' => '1370908',            # Naissance Saint-Yvi 3 E 339/4/8 (an IX)
	'AN10' => '1370909',            # Naissance Saint-Yvi 3 E 339/4/9 (an X)
    },

    '3E339_0005' => {			# Naissance Saint-Yvi 3 E 339 5   AN11-1812
	'AN11' => '1370911',            # Naissance Saint-Yvi 3 E 339/5/1 (an XI)
	'AN12' => '1370912',            # Naissance Saint-Yvi 3 E 339/5/2 (an XII)
	'AN13' => '1370913',            # Naissance Saint-Yvi 3 E 339/5/3 (an XIII)
	'AN14' => '1370914',            # Naissance Saint-Yvi 3 E 339/5/4 (an XIV - 1806)
	1807   => '1370915',            # Naissance Saint-Yvi 3 E 339/5/5 (1807)
	1808   => '1370916',            # Naissance Saint-Yvi 3 E 339/5/6 (1808)
	1809   => '1370917',            # Naissance Saint-Yvi 3 E 339/5/7 (1809)
	1810   => '1370918',            # Naissance Saint-Yvi 3 E 339/5/8 (1810)
	1811   => '1370919',            # Naissance Saint-Yvi 3 E 339/5/9 (1811)
	1812   => '1370920',            # Naissance Saint-Yvi 3 E 339/5/10 (1812)
    },

    '3E339_0006' => {			# Naissance Saint-Yvi 3 E 339 6   1813-1822
	1813   => '1370922',            # Naissance Saint-Yvi 3 E 339/6/1 (1813)
	1814   => '1370923',            # Naissance Saint-Yvi 3 E 339/6/2 (1814)
	1815   => '1370924',            # Naissance Saint-Yvi 3 E 339/6/3 (1815)
	1816   => '1370925',            # Naissance Saint-Yvi 3 E 339/6/4 (1816)
	1817   => '1370926',            # Naissance Saint-Yvi 3 E 339/6/5 (1817)
	1818   => '1370927',            # Naissance Saint-Yvi 3 E 339/6/6 (1818)
	1820   => '1370928',            # Naissance Saint-Yvi 3 E 339/6/7 (1820)
	1821   => '1370929',            # Naissance Saint-Yvi 3 E 339/6/8 (1821)
	1822   => '1370930',            # Naissance Saint-Yvi 3 E 339/6/9 (1822)
    },

    '3E339_0007' => {			# Naissance Saint-Yvi 3 E 339 7   1823-1832
	1823   => '1370932',            # Naissance Saint-Yvi 3 E 339/7/1 (1823)
	1824   => '1370933',            # Naissance Saint-Yvi 3 E 339/7/2 (1824)
	1825   => '1370934',            # Naissance Saint-Yvi 3 E 339/7/3 (1825)
	1826   => '1370935',            # Naissance Saint-Yvi 3 E 339/7/4 (1826)
	1827   => '1370936',            # Naissance Saint-Yvi 3 E 339/7/5 (1827)
	1828   => '1370937',            # Naissance Saint-Yvi 3 E 339/7/6 (1828)
	1829   => '1370938',            # Naissance Saint-Yvi 3 E 339/7/7 (1829)
	1830   => '1370939',            # Naissance Saint-Yvi 3 E 339/7/8 (1830)
	1831   => '1370940',            # Naissance Saint-Yvi 3 E 339/7/9 (1831)
	1832   => '1370941',            # Naissance Saint-Yvi 3 E 339/7/10 (1832)
    },

    '3E339_0008' => {			# Naissance Saint-Yvi 3 E 339 8   1833-1842
	1833   => '1370943',            # Naissance Saint-Yvi 3 E 339/8/1 (1833)
	1834   => '1370944',            # Naissance Saint-Yvi 3 E 339/8/2 (1834)
	1835   => '1370945',            # Naissance Saint-Yvi 3 E 339/8/3 (1835)
	1836   => '1370946',            # Naissance Saint-Yvi 3 E 339/8/4 (1836)
	1837   => '1370947',            # Naissance Saint-Yvi 3 E 339/8/5 (1837)
	1838   => '1370948',            # Naissance Saint-Yvi 3 E 339/8/6 (1838)
	1839   => '1370949',            # Naissance Saint-Yvi 3 E 339/8/7 (1839)
	1840   => '1370950',            # Naissance Saint-Yvi 3 E 339/8/8 (1840)
	1841   => '1370951',            # Naissance Saint-Yvi 3 E 339/8/9 (1841)
	1842   => '1370952',            # Naissance Saint-Yvi 3 E 339/8/10 (1842)
    },

    '3E339_0009' => {			# Naissance Saint-Yvi 3 E 339 9   1843-1852
	1843   => '1370954',            # Naissance Saint-Yvi 3 E 339/9/1 (1843)
	1844   => '1370955',            # Naissance Saint-Yvi 3 E 339/9/2 (1844)
	1845   => '1370956',            # Naissance Saint-Yvi 3 E 339/9/3 (1845)
	1846   => '1370957',            # Naissance Saint-Yvi 3 E 339/9/4 (1846)
	1847   => '1370958',            # Naissance Saint-Yvi 3 E 339/9/5 (1847)
	1848   => '1370959',            # Naissance Saint-Yvi 3 E 339/9/6 (1848)
	1849   => '1370960',            # Naissance Saint-Yvi 3 E 339/9/7 (1849)
	1850   => '1370961',            # Naissance Saint-Yvi 3 E 339/9/8 (1850)
	1851   => '1370962',            # Naissance Saint-Yvi 3 E 339/9/9 (1851)
	1852   => '1370963',            # Naissance Saint-Yvi 3 E 339/9/10 (1852)
    },

    '3E339_0010' => {			# Naissance Saint-Yvi 3 E 339 10   1853-1862
	1853   => '1370965',            # Naissance Saint-Yvi 3 E 339/10/1 (1853)
	1854   => '1370966',            # Naissance Saint-Yvi 3 E 339/10/2 (1854)
	1855   => '1370967',            # Naissance Saint-Yvi 3 E 339/10/3 (1855)
	1856   => '1370968',            # Naissance Saint-Yvi 3 E 339/10/4 (1856)
	1857   => '1370969',            # Naissance Saint-Yvi 3 E 339/10/5 (1857)
	1858   => '1370970',            # Naissance Saint-Yvi 3 E 339/10/6 (1858)
	1859   => '1370971',            # Naissance Saint-Yvi 3 E 339/10/7 (1859)
	1860   => '1370972',            # Naissance Saint-Yvi 3 E 339/10/8 (1860)
	1861   => '1370973',            # Naissance Saint-Yvi 3 E 339/10/9 (1861)
	1862   => '1370974',            # Naissance Saint-Yvi 3 E 339/10/10 (1862)
    },

    '3E339_0011' => {			# Naissance Saint-Yvi 3 E 339 11   1863-1869
	1863   => '1370976',            # Naissance Saint-Yvi 3 E 339/11/1 (1863)
	1864   => '1370977',            # Naissance Saint-Yvi 3 E 339/11/2 (1864)
	1865   => '1370978',            # Naissance Saint-Yvi 3 E 339/11/3 (1865)
	1866   => '1370979',            # Naissance Saint-Yvi 3 E 339/11/4 (1866)
	1867   => '1370980',            # Naissance Saint-Yvi 3 E 339/11/5 (1867)
	1868   => '1370981',            # Naissance Saint-Yvi 3 E 339/11/6 (1868)
	1869   => '1370982',            # Naissance Saint-Yvi 3 E 339/11/7 (1869)
    },

    '3E339_0012' => {			# Naissance Saint-Yvi 3 E 339 12   1870-1883
	1870   => '1370984',            # Naissance Saint-Yvi 3 E 339/12/1 (1870)
	1871   => '1370985',            # Naissance Saint-Yvi 3 E 339/12/2 (1871)
	1872   => '1370986',            # Naissance Saint-Yvi 3 E 339/12/3 (1872)
	1873   => '1370987',            # Naissance Saint-Yvi 3 E 339/12/4 (1873)
	1874   => '1370988',            # Naissance Saint-Yvi 3 E 339/12/5 (1874)
	1875   => '1370989',            # Naissance Saint-Yvi 3 E 339/12/6 (1875)
	1876   => '1370990',            # Naissance Saint-Yvi 3 E 339/12/7 (1876)
	1877   => '1370991',            # Naissance Saint-Yvi 3 E 339/12/8 (1877)
	1878   => '1370992',            # Naissance Saint-Yvi 3 E 339/12/9 (1878)
	1879   => '1370993',            # Naissance Saint-Yvi 3 E 339/12/10 (1879)
	1880   => '1370994',            # Naissance Saint-Yvi 3 E 339/12/11 (1880)
	1881   => '1370995',            # Naissance Saint-Yvi 3 E 339/12/12 (1881)
	1882   => '1370996',            # Naissance Saint-Yvi 3 E 339/12/13 (1882)
	1883   => '1370997',            # Naissance Saint-Yvi 3 E 339/12/14 (1883)
    },

    '3E339_0013' => {			# Naissance Saint-Yvi 3 E 339 13   1884-1894
	1884   => '1370999',            # Naissance Saint-Yvi 3 E 339/13/1 (1884)
	1885   => '1371000',            # Naissance Saint-Yvi 3 E 339/13/2 (1885)
	1886   => '1371001',            # Naissance Saint-Yvi 3 E 339/13/3 (1886)
	1887   => '1371002',            # Naissance Saint-Yvi 3 E 339/13/4 (1887)
	1888   => '1371003',            # Naissance Saint-Yvi 3 E 339/13/5 (1888)
	1889   => '1371004',            # Naissance Saint-Yvi 3 E 339/13/6 (1889)
	1890   => '1371005',            # Naissance Saint-Yvi 3 E 339/13/7 (1890)
	1891   => '1371006',            # Naissance Saint-Yvi 3 E 339/13/8 (1891)
	1892   => '1371007',            # Naissance Saint-Yvi 3 E 339/13/9 (1892)
	1893   => '1371008',            # Naissance Saint-Yvi 3 E 339/13/10 (1893)
	1894   => '1371009',            # Naissance Saint-Yvi 3 E 339/13/11 (1894)
    },

    '3E339_0014' => {			# Mariage Saint-Yvi 3 E 339 14   AN02-AN10
	'AN02' => '1371057',            # Mariage Saint-Yvi 3 E 339/14/1 (1793 - an II)
	'AN03' => '1371058',            # Mariage Saint-Yvi 3 E 339/14/2 (an III)
	'AN04' => '1371059',            # Mariage Saint-Yvi 3 E 339/14/3 (an IV)
	'AN05' => '1371060',            # Mariage Saint-Yvi 3 E 339/14/4 (an V)
	'AN06' => '1371061',            # Mariage Saint-Yvi 3 E 339/14/5 (an VI)
	'AN07' => '1371062',            # Mariage Saint-Yvi 3 E 339/14/6 (an VII)
	'AN08' => '1371063',            # Mariage Saint-Yvi 3 E 339/14/7 (an VIII)
	'AN09' => '1371064',            # Mariage Saint-Yvi 3 E 339/14/8 (an IX)
	'AN10' => '1371065',            # Mariage Saint-Yvi 3 E 339/14/9 (an X)
    },

    '3E339_0015' => {			# Mariage Saint-Yvi 3 E 339 15   AN11-1812
	'AN11' => '1371067',            # Mariage Saint-Yvi 3 E 339/15/1 (an XI)
	'AN12' => '1371068',            # Mariage Saint-Yvi 3 E 339/15/2 (an XII)
	'AN13' => '1371069',            # Mariage Saint-Yvi 3 E 339/15/3 (an XIII)
	'AN14' => '1371070',            # Mariage Saint-Yvi 3 E 339/15/4 (an XIV - 1806)
	1807   => '1371071',            # Mariage Saint-Yvi 3 E 339/15/5 (1807)
	1808   => '1371072',            # Mariage Saint-Yvi 3 E 339/15/6 (1808)
	1809   => '1371073',            # Mariage Saint-Yvi 3 E 339/15/7 (1809)
	1810   => '1371074',            # Mariage Saint-Yvi 3 E 339/15/8 (1810)
	1811   => '1371075',            # Mariage Saint-Yvi 3 E 339/15/9 (1811)
	1812   => '1371076',            # Mariage Saint-Yvi 3 E 339/15/10 (1812)
    },

    '3E339_0016' => {			# Mariage Saint-Yvi 3 E 339 16   1813-1822
	1813   => '1371078',            # Mariage Saint-Yvi 3 E 339/16/1 (1813)
	1814   => '1371079',            # Mariage Saint-Yvi 3 E 339/16/2 (1814)
	1815   => '1371080',            # Mariage Saint-Yvi 3 E 339/16/3 (1815)
	1816   => '1371081',            # Mariage Saint-Yvi 3 E 339/16/4 (1816)
	1817   => '1371082',            # Mariage Saint-Yvi 3 E 339/16/5 (1817)
	1818   => '1371083',            # Mariage Saint-Yvi 3 E 339/16/6 (1818)
	1819   => '1371084',            # Mariage Saint-Yvi 3 E 339/16/7 (1819)
	1820   => '1371085',            # Mariage Saint-Yvi 3 E 339/16/8 (1820)
	1822   => '1371086',            # Mariage Saint-Yvi 3 E 339/16/9 (1822)
    },

    '3E339_0017' => {			# Mariage Saint-Yvi 3 E 339 17   1823-1832
	1823   => '1371088',            # Mariage Saint-Yvi 3 E 339/17/1 (1823)
	1824   => '1371089',            # Mariage Saint-Yvi 3 E 339/17/2 (1824)
	1825   => '1371090',            # Mariage Saint-Yvi 3 E 339/17/3 (1825)
	1826   => '1371091',            # Mariage Saint-Yvi 3 E 339/17/4 (1826)
	1827   => '1371092',            # Mariage Saint-Yvi 3 E 339/17/5 (1827)
	1828   => '1371093',            # Mariage Saint-Yvi 3 E 339/17/6 (1828)
	1829   => '1371094',            # Mariage Saint-Yvi 3 E 339/17/7 (1829)
	1830   => '1371095',            # Mariage Saint-Yvi 3 E 339/17/8 (1830)
	1831   => '1371096',            # Mariage Saint-Yvi 3 E 339/17/9 (1831)
	1832   => '1371097',            # Mariage Saint-Yvi 3 E 339/17/10 (1832)
    },

    '3E339_0018' => {			# Mariage Saint-Yvi 3 E 339 18   1833-1842
	1833   => '1371099',            # Mariage Saint-Yvi 3 E 339/18/1 (1833)
	1834   => '1371100',            # Mariage Saint-Yvi 3 E 339/18/2 (1834)
	1835   => '1371101',            # Mariage Saint-Yvi 3 E 339/18/3 (1835)
	1836   => '1371102',            # Mariage Saint-Yvi 3 E 339/18/4 (1836)
	1837   => '1371103',            # Mariage Saint-Yvi 3 E 339/18/5 (1837)
	1838   => '1371104',            # Mariage Saint-Yvi 3 E 339/18/6 (1838)
	1839   => '1371105',            # Mariage Saint-Yvi 3 E 339/18/7 (1839)
	1840   => '1371106',            # Mariage Saint-Yvi 3 E 339/18/8 (1840)
	1841   => '1371107',            # Mariage Saint-Yvi 3 E 339/18/9 (1841)
	1842   => '1371108',            # Mariage Saint-Yvi 3 E 339/18/10 (1842)
    },

    '3E339_0019' => {			# Mariage Saint-Yvi 3 E 339 19   1843-1852
	1843   => '1371110',            # Mariage Saint-Yvi 3 E 339/19/1 (1843)
	1844   => '1371111',            # Mariage Saint-Yvi 3 E 339/19/2 (1844)
	1845   => '1371112',            # Mariage Saint-Yvi 3 E 339/19/3 (1845)
	1846   => '1371113',            # Mariage Saint-Yvi 3 E 339/19/4 (1846)
	1847   => '1371114',            # Mariage Saint-Yvi 3 E 339/19/5 (1847)
	1848   => '1371115',            # Mariage Saint-Yvi 3 E 339/19/6 (1848)
	1849   => '1371116',            # Mariage Saint-Yvi 3 E 339/19/7 (1849)
	1850   => '1371117',            # Mariage Saint-Yvi 3 E 339/19/8 (1850)
	1851   => '1371118',            # Mariage Saint-Yvi 3 E 339/19/9 (1851)
	1852   => '1371119',            # Mariage Saint-Yvi 3 E 339/19/10 (1852)
    },

    '3E339_0020' => {			# Mariage Saint-Yvi 3 E 339 20   1853-1862
	1853   => '1371121',            # Mariage Saint-Yvi 3 E 339/20/1 (1853)
	1854   => '1371122',            # Mariage Saint-Yvi 3 E 339/20/2 (1854)
	1855   => '1371123',            # Mariage Saint-Yvi 3 E 339/20/3 (1855)
	1856   => '1371124',            # Mariage Saint-Yvi 3 E 339/20/4 (1856)
	1857   => '1371125',            # Mariage Saint-Yvi 3 E 339/20/5 (1857)
	1858   => '1371126',            # Mariage Saint-Yvi 3 E 339/20/6 (1858)
	1859   => '1371127',            # Mariage Saint-Yvi 3 E 339/20/7 (1859)
	1860   => '1371128',            # Mariage Saint-Yvi 3 E 339/20/8 (1860)
	1861   => '1371129',            # Mariage Saint-Yvi 3 E 339/20/9 (1861)
	1862   => '1371130',            # Mariage Saint-Yvi 3 E 339/20/10 (1862)
    },

    '3E339_0021' => {			# Mariage Saint-Yvi 3 E 339 21   1863-1869
	1863   => '1371132',            # Mariage Saint-Yvi 3 E 339/21/1 (1863)
	1864   => '1371133',            # Mariage Saint-Yvi 3 E 339/21/2 (1864)
	1865   => '1371134',            # Mariage Saint-Yvi 3 E 339/21/3 (1865)
	1866   => '1371135',            # Mariage Saint-Yvi 3 E 339/21/4 (1866)
	1867   => '1371136',            # Mariage Saint-Yvi 3 E 339/21/5 (1867)
	1868   => '1371137',            # Mariage Saint-Yvi 3 E 339/21/6 (1868)
	1869   => '1371138',            # Mariage Saint-Yvi 3 E 339/21/7 (1869)
    },

    '3E339_0022' => {			# Mariage Saint-Yvi 3 E 339 22   1870-1885
	1870   => '1371140',            # Mariage Saint-Yvi 3 E 339/22/1 (1870)
	1871   => '1371141',            # Mariage Saint-Yvi 3 E 339/22/2 (1871)
	1872   => '1371142',            # Mariage Saint-Yvi 3 E 339/22/3 (1872)
	1873   => '1371143',            # Mariage Saint-Yvi 3 E 339/22/4 (1873)
	1874   => '1371144',            # Mariage Saint-Yvi 3 E 339/22/5 (1874)
	1875   => '1371145',            # Mariage Saint-Yvi 3 E 339/22/6 (1875)
	1876   => '1371146',            # Mariage Saint-Yvi 3 E 339/22/7 (1876)
	1877   => '1371147',            # Mariage Saint-Yvi 3 E 339/22/8 (1877)
	1878   => '1371148',            # Mariage Saint-Yvi 3 E 339/22/9 (1878)
	1879   => '1371149',            # Mariage Saint-Yvi 3 E 339/22/10 (1879)
	1880   => '1371150',            # Mariage Saint-Yvi 3 E 339/22/11 (1880)
	1881   => '1371151',            # Mariage Saint-Yvi 3 E 339/22/12 (1881)
	1882   => '1371152',            # Mariage Saint-Yvi 3 E 339/22/13 (1882)
	1883   => '1371153',            # Mariage Saint-Yvi 3 E 339/22/14 (1883)
	1884   => '1371154',            # Mariage Saint-Yvi 3 E 339/22/15 (1884)
	1885   => '1371155',            # Mariage Saint-Yvi 3 E 339/22/16 (1885)
    },

    '3E339_0023' => {			# Décès Saint-Yvi 3 E 339 23   AN02-AN10
	'AN02' => '1371212',            # Décès Saint-Yvi 3 E 339/23/1 (1793 - an II)
	'AN03' => '1371213',            # Décès Saint-Yvi 3 E 339/23/2 (an III)
	'AN04' => '1371214',            # Décès Saint-Yvi 3 E 339/23/3 (an IV)
	'AN05' => '1371215',            # Décès Saint-Yvi 3 E 339/23/4 (an V)
	'AN06' => '1371216',            # Décès Saint-Yvi 3 E 339/23/5 (an VI)
	'AN07' => '1371217',            # Décès Saint-Yvi 3 E 339/23/6 (an VII)
	'AN08' => '1371218',            # Décès Saint-Yvi 3 E 339/23/7 (an VIII)
	'AN09' => '1371219',            # Décès Saint-Yvi 3 E 339/23/8 (an IX)
	'AN10' => '1371220',            # Décès Saint-Yvi 3 E 339/23/9 (an X)
    },

    '3E339_0024' => {			# Décès Saint-Yvi 3 E 339 24   AN11-1812
	'AN11' => '1371222',            # Décès Saint-Yvi 3 E 339/24/1 (an XI)
	'AN12' => '1371223',            # Décès Saint-Yvi 3 E 339/24/2 (an XII)
	'AN13' => '1371224',            # Décès Saint-Yvi 3 E 339/24/3 (an XIII)
	'AN14' => '1371225',            # Décès Saint-Yvi 3 E 339/24/4 (an XIV - 1806)
	1807   => '1371226',            # Décès Saint-Yvi 3 E 339/24/5 (1807)
	1808   => '1371227',            # Décès Saint-Yvi 3 E 339/24/6 (1808)
	1809   => '1371228',            # Décès Saint-Yvi 3 E 339/24/7 (1809)
	1810   => '1371229',            # Décès Saint-Yvi 3 E 339/24/8 (1810)
	1811   => '1371230',            # Décès Saint-Yvi 3 E 339/24/9 (1811)
	1812   => '1371231',            # Décès Saint-Yvi 3 E 339/24/10 (1812)
    },

    '3E339_0025' => {			# Décès Saint-Yvi 3 E 339 25   1813-1822
	1813   => '1371233',            # Décès Saint-Yvi 3 E 339/25/1 (1813)
	1814   => '1371234',            # Décès Saint-Yvi 3 E 339/25/2 (1814)
	1815   => '1371235',            # Décès Saint-Yvi 3 E 339/25/3 (1815)
	1816   => '1371236',            # Décès Saint-Yvi 3 E 339/25/4 (1816)
	1817   => '1371237',            # Décès Saint-Yvi 3 E 339/25/5 (1817)
	1818   => '1371238',            # Décès Saint-Yvi 3 E 339/25/6 (1818)
	1819   => '1371239',            # Décès Saint-Yvi 3 E 339/25/7 (1819)
	1820   => '1371240',            # Décès Saint-Yvi 3 E 339/25/8 (1820)
	1821   => '1371241',            # Décès Saint-Yvi 3 E 339/25/9 (1821)
	1822   => '1371242',            # Décès Saint-Yvi 3 E 339/25/10 (1822)
    },

    '3E339_0026' => {			# Décès Saint-Yvi 3 E 339 26   1823-1832
	1823   => '1371244',            # Décès Saint-Yvi 3 E 339/26/1 (1823)
	1824   => '1371245',            # Décès Saint-Yvi 3 E 339/26/2 (1824)
	1825   => '1371246',            # Décès Saint-Yvi 3 E 339/26/3 (1825)
	1826   => '1371247',            # Décès Saint-Yvi 3 E 339/26/4 (1826)
	1827   => '1371248',            # Décès Saint-Yvi 3 E 339/26/5 (1827)
	1828   => '1371249',            # Décès Saint-Yvi 3 E 339/26/6 (1828)
	1829   => '1371250',            # Décès Saint-Yvi 3 E 339/26/7 (1829)
	1830   => '1371251',            # Décès Saint-Yvi 3 E 339/26/8 (1830)
	1831   => '1371252',            # Décès Saint-Yvi 3 E 339/26/9 (1831)
	1832   => '1371253',            # Décès Saint-Yvi 3 E 339/26/10 (1832)
    },

    '3E339_0027' => {			# Décès Saint-Yvi 3 E 339 27   1833-1842
	1833   => '1371255',            # Décès Saint-Yvi 3 E 339/27/1 (1833)
	1834   => '1371256',            # Décès Saint-Yvi 3 E 339/27/2 (1834)
	1835   => '1371257',            # Décès Saint-Yvi 3 E 339/27/3 (1835)
	1836   => '1371258',            # Décès Saint-Yvi 3 E 339/27/4 (1836)
	1837   => '1371259',            # Décès Saint-Yvi 3 E 339/27/5 (1837)
	1838   => '1371260',            # Décès Saint-Yvi 3 E 339/27/6 (1838)
	1839   => '1371261',            # Décès Saint-Yvi 3 E 339/27/7 (1839)
	1840   => '1371262',            # Décès Saint-Yvi 3 E 339/27/8 (1840)
	1841   => '1371263',            # Décès Saint-Yvi 3 E 339/27/9 (1841)
	1842   => '1371264',            # Décès Saint-Yvi 3 E 339/27/10 (1842)
    },

    '3E339_0028' => {			# Décès Saint-Yvi 3 E 339 28   1843-1852
	1843   => '1371266',            # Décès Saint-Yvi 3 E 339/28/1 (1843)
	1844   => '1371267',            # Décès Saint-Yvi 3 E 339/28/2 (1844)
	1845   => '1371268',            # Décès Saint-Yvi 3 E 339/28/3 (1845)
	1846   => '1371269',            # Décès Saint-Yvi 3 E 339/28/4 (1846)
	1847   => '1371270',            # Décès Saint-Yvi 3 E 339/28/5 (1847)
	1848   => '1371271',            # Décès Saint-Yvi 3 E 339/28/6 (1848)
	1849   => '1371272',            # Décès Saint-Yvi 3 E 339/28/7 (1849)
	1850   => '1371273',            # Décès Saint-Yvi 3 E 339/28/8 (1850)
	1851   => '1371274',            # Décès Saint-Yvi 3 E 339/28/9 (1851)
	1852   => '1371275',            # Décès Saint-Yvi 3 E 339/28/10 (1852)
    },

    '3E339_0029' => {			# Décès Saint-Yvi 3 E 339 29   1853-1862
	1853   => '1371277',            # Décès Saint-Yvi 3 E 339/29/1 (1853)
	1854   => '1371278',            # Décès Saint-Yvi 3 E 339/29/2 (1854)
	1855   => '1371279',            # Décès Saint-Yvi 3 E 339/29/3 (1855)
	1856   => '1371280',            # Décès Saint-Yvi 3 E 339/29/4 (1856)
	1857   => '1371281',            # Décès Saint-Yvi 3 E 339/29/5 (1857)
	1858   => '1371282',            # Décès Saint-Yvi 3 E 339/29/6 (1858)
	1859   => '1371283',            # Décès Saint-Yvi 3 E 339/29/7 (1859)
	1860   => '1371284',            # Décès Saint-Yvi 3 E 339/29/8 (1860)
	1861   => '1371285',            # Décès Saint-Yvi 3 E 339/29/9 (1861)
	1862   => '1371286',            # Décès Saint-Yvi 3 E 339/29/10 (1862)
    },

    '3E339_0030' => {			# Décès Saint-Yvi 3 E 339 30   1863-1869
	1863   => '1371288',            # Décès Saint-Yvi 3 E 339/30/1 (1863)
	1864   => '1371289',            # Décès Saint-Yvi 3 E 339/30/2 (1864)
	1865   => '1371290',            # Décès Saint-Yvi 3 E 339/30/3 (1865)
	1866   => '1371291',            # Décès Saint-Yvi 3 E 339/30/4 (1866)
	1867   => '1371292',            # Décès Saint-Yvi 3 E 339/30/5 (1867)
	1868   => '1371293',            # Décès Saint-Yvi 3 E 339/30/6 (1868)
	1869   => '1371294',            # Décès Saint-Yvi 3 E 339/30/7 (1869)
    },

    '3E339_0031' => {			# Décès Saint-Yvi 3 E 339 31   1870-1883
	1870   => '1371296',            # Décès Saint-Yvi 3 E 339/31/1 (1870)
	1871   => '1371297',            # Décès Saint-Yvi 3 E 339/31/2 (1871)
	1872   => '1371298',            # Décès Saint-Yvi 3 E 339/31/3 (1872)
	1873   => '1371299',            # Décès Saint-Yvi 3 E 339/31/4 (1873)
	1874   => '1371300',            # Décès Saint-Yvi 3 E 339/31/5 (1874)
	1875   => '1371301',            # Décès Saint-Yvi 3 E 339/31/6 (1875)
	1876   => '1371302',            # Décès Saint-Yvi 3 E 339/31/7 (1876)
	1877   => '1371303',            # Décès Saint-Yvi 3 E 339/31/8 (1877)
	1878   => '1371304',            # Décès Saint-Yvi 3 E 339/31/9 (1878)
	1879   => '1371305',            # Décès Saint-Yvi 3 E 339/31/10 (1879)
	1880   => '1371306',            # Décès Saint-Yvi 3 E 339/31/11 (1880)
	1881   => '1371307',            # Décès Saint-Yvi 3 E 339/31/12 (1881)
	1882   => '1371308',            # Décès Saint-Yvi 3 E 339/31/13 (1882)
	1883   => '1371309',            # Décès Saint-Yvi 3 E 339/31/14 (1883)
    },

    '3E339_0032' => {			# Décès Saint-Yvi 3 E 339 32   1884-1895
	1884   => '1371311',            # Décès Saint-Yvi 3 E 339/32/1 (1884)
	1885   => '1371312',            # Décès Saint-Yvi 3 E 339/32/2 (1885)
	1886   => '1371313',            # Décès Saint-Yvi 3 E 339/32/3 (1886)
	1887   => '1371314',            # Décès Saint-Yvi 3 E 339/32/4 (1887)
	1888   => '1371315',            # Décès Saint-Yvi 3 E 339/32/5 (1888)
	1889   => '1371316',            # Décès Saint-Yvi 3 E 339/32/6 (1889)
	1890   => '1371317',            # Décès Saint-Yvi 3 E 339/32/7 (1890)
	1891   => '1371318',            # Décès Saint-Yvi 3 E 339/32/8 (1891)
	1892   => '1371319',            # Décès Saint-Yvi 3 E 339/32/9 (1892)
	1893   => '1371320',            # Décès Saint-Yvi 3 E 339/32/10 (1893)
	1894   => '1371321',            # Décès Saint-Yvi 3 E 339/32/11 (1894)
	1895   => '1371322',            # Décès Saint-Yvi 3 E 339/32/12 (1895)
    },

    '3E339_0033' => {			# Mariage Saint-Yvi 3 E 339 33   1886-1903
	1886   => '1371157',            # Mariage Saint-Yvi 3 E 339/33/1 (1886)
	1887   => '1371158',            # Mariage Saint-Yvi 3 E 339/33/2 (1887)
	1888   => '1371159',            # Mariage Saint-Yvi 3 E 339/33/3 (1888)
	1889   => '1371160',            # Mariage Saint-Yvi 3 E 339/33/4 (1889)
	1890   => '1371161',            # Mariage Saint-Yvi 3 E 339/33/5 (1890)
	1891   => '1371162',            # Mariage Saint-Yvi 3 E 339/33/6 (1891)
	1892   => '1371163',            # Mariage Saint-Yvi 3 E 339/33/7 (1892)
	1893   => '1371164',            # Mariage Saint-Yvi 3 E 339/33/8 (1893)
	1894   => '1371165',            # Mariage Saint-Yvi 3 E 339/33/9 (1894)
	1895   => '1371166',            # Mariage Saint-Yvi 3 E 339/33/10 (1895)
	1896   => '1371167',            # Mariage Saint-Yvi 3 E 339/33/11 (1896)
	1897   => '1371168',            # Mariage Saint-Yvi 3 E 339/33/12 (1897)
	1898   => '1371169',            # Mariage Saint-Yvi 3 E 339/33/13 (1898)
	1899   => '1371170',            # Mariage Saint-Yvi 3 E 339/33/14 (1899)
	1900   => '1371171',            # Mariage Saint-Yvi 3 E 339/33/15 (1900)
	1901   => '1371172',            # Mariage Saint-Yvi 3 E 339/33/16 (1901)
	1902   => '1371173',            # Mariage Saint-Yvi 3 E 339/33/17 (1902)
	1903   => '1371174',            # Mariage Saint-Yvi 3 E 339/33/18 (1903)
    },

    '3E339_0034' => {			# Naissance Saint-Yvi 3 E 339 34   1895-1907
	1895   => '1371011',            # Naissance Saint-Yvi 3 E 339/34/1 (1895)
	1896   => '1371012',            # Naissance Saint-Yvi 3 E 339/34/2 (1896)
	1897   => '1371013',            # Naissance Saint-Yvi 3 E 339/34/3 (1897)
	1898   => '1371014',            # Naissance Saint-Yvi 3 E 339/34/4 (1898)
	1899   => '1371015',            # Naissance Saint-Yvi 3 E 339/34/5 (1899)
	1900   => '1371016',            # Naissance Saint-Yvi 3 E 339/34/6 (1900)
	1901   => '1371017',            # Naissance Saint-Yvi 3 E 339/34/7 (1901)
	1902   => '1371018',            # Naissance Saint-Yvi 3 E 339/34/8 (1902)
	1903   => '1371019',            # Naissance Saint-Yvi 3 E 339/34/9 (1903)
	1904   => '1371020',            # Naissance Saint-Yvi 3 E 339/34/10 (1904)
	1905   => '1371021',            # Naissance Saint-Yvi 3 E 339/34/11 (1905)
	1906   => '1371022',            # Naissance Saint-Yvi 3 E 339/34/12 (1906)
	1907   => '1371023',            # Naissance Saint-Yvi 3 E 339/34/13 (1907)
    },

    '3E339_0035' => {			# Décès Saint-Yvi 3 E 339 35   1896-1913
	1896   => '1371324',            # Décès Saint-Yvi 3 E 339/35/1 (1896)
	1897   => '1371325',            # Décès Saint-Yvi 3 E 339/35/2 (1897)
	1898   => '1371326',            # Décès Saint-Yvi 3 E 339/35/3 (1898)
	1899   => '1371327',            # Décès Saint-Yvi 3 E 339/35/4 (1899)
	1900   => '1371328',            # Décès Saint-Yvi 3 E 339/35/5 (1900)
	1901   => '1371329',            # Décès Saint-Yvi 3 E 339/35/6 (1901)
	1902   => '1371330',            # Décès Saint-Yvi 3 E 339/35/7 (1902)
	1903   => '1371331',            # Décès Saint-Yvi 3 E 339/35/8 (1903)
	1904   => '1371332',            # Décès Saint-Yvi 3 E 339/35/9 (1904)
	1905   => '1371333',            # Décès Saint-Yvi 3 E 339/35/10 (1905)
	1906   => '1371334',            # Décès Saint-Yvi 3 E 339/35/11 (1906)
	1907   => '1371335',            # Décès Saint-Yvi 3 E 339/35/12 (1907)
	1908   => '1371336',            # Décès Saint-Yvi 3 E 339/35/13 (1908)
	1909   => '1371337',            # Décès Saint-Yvi 3 E 339/35/14 (1909)
	1910   => '1371338',            # Décès Saint-Yvi 3 E 339/35/15 (1910)
	1911   => '1371339',            # Décès Saint-Yvi 3 E 339/35/16 (1911)
	1912   => '1371340',            # Décès Saint-Yvi 3 E 339/35/17 (1912)
	1913   => '1371341',            # Décès Saint-Yvi 3 E 339/35/18 (1913)
    },

    '3E339_0036' => {			# Naissance Saint-Yvi 3 E 339 36   1908-1921
	1908   => '1371025',            # Naissance Saint-Yvi 3 E 339/36/1 (1908)
	1909   => '1371026',            # Naissance Saint-Yvi 3 E 339/36/2 (1909)
	1910   => '1371027',            # Naissance Saint-Yvi 3 E 339/36/3 (1910)
	1911   => '1371028',            # Naissance Saint-Yvi 3 E 339/36/4 (1911)
	1912   => '1371029',            # Naissance Saint-Yvi 3 E 339/36/5 (1912)
	1913   => '1371030',            # Naissance Saint-Yvi 3 E 339/36/6 (1913)
	1914   => '1371031',            # Naissance Saint-Yvi 3 E 339/36/7 (1914)
	1915   => '1371032',            # Naissance Saint-Yvi 3 E 339/36/8 (1915)
	1916   => '1371033',            # Naissance Saint-Yvi 3 E 339/36/9 (1916)
	1917   => '1371034',            # Naissance Saint-Yvi 3 E 339/36/10 (1917)
	1918   => '1371035',            # Naissance Saint-Yvi 3 E 339/36/11 (1918)
	1919   => '1371036',            # Naissance Saint-Yvi 3 E 339/36/12 (1919)
	1920   => '1371037',            # Naissance Saint-Yvi 3 E 339/36/13 (1920)
	1921   => '1371038',            # Naissance Saint-Yvi 3 E 339/36/14 (1921)
    },

    '3E339_0037' => {			# Naissance Saint-Yvi 3 E 339 37   1922-1925
	1922   => '1371040',            # Naissance Saint-Yvi 3 E 339/37/1 (1922)
	1923   => '1371041',            # Naissance Saint-Yvi 3 E 339/37/2 (1923)
	1924   => '1371042',            # Naissance Saint-Yvi 3 E 339/37/3 (1924)
	1925   => '1371043',            # Naissance Saint-Yvi 3 E 339/37/4 (1925)
    },

    '3E339_0038' => {			# Mariage Saint-Yvi 3 E 339 38   1904-1919
	1904   => '1371176',            # Mariage Saint-Yvi 3 E 339/38/1 (1904)
	1905   => '1371177',            # Mariage Saint-Yvi 3 E 339/38/2 (1905)
	1906   => '1371178',            # Mariage Saint-Yvi 3 E 339/38/3 (1906)
	1907   => '1371179',            # Mariage Saint-Yvi 3 E 339/38/4 (1907)
	1908   => '1371180',            # Mariage Saint-Yvi 3 E 339/38/5 (1908)
	1909   => '1371181',            # Mariage Saint-Yvi 3 E 339/38/6 (1909)
	1910   => '1371182',            # Mariage Saint-Yvi 3 E 339/38/7 (1910)
	1911   => '1371183',            # Mariage Saint-Yvi 3 E 339/38/8 (1911)
	1912   => '1371184',            # Mariage Saint-Yvi 3 E 339/38/9 (1912)
	1913   => '1371185',            # Mariage Saint-Yvi 3 E 339/38/10 (1913)
	1914   => '1371186',            # Mariage Saint-Yvi 3 E 339/38/11 (1914)
	1915   => '1371187',            # Mariage Saint-Yvi 3 E 339/38/12 (1915)
	1916   => '1371188',            # Mariage Saint-Yvi 3 E 339/38/13 (1916)
	1917   => '1371189',            # Mariage Saint-Yvi 3 E 339/38/14 (1917)
	1918   => '1371190',            # Mariage Saint-Yvi 3 E 339/38/15 (1918)
	1919   => '1371191',            # Mariage Saint-Yvi 3 E 339/38/16 (1919)
    },

    '3E339_0039' => {			# Mariage Saint-Yvi 3 E 339 39   1920-1936
	1920   => '1371193',            # Mariage Saint-Yvi 3 E 339/39/1 (1920)
	1921   => '1371194',            # Mariage Saint-Yvi 3 E 339/39/2 (1921)
	1922   => '1371195',            # Mariage Saint-Yvi 3 E 339/39/3 (1922)
	1923   => '1371196',            # Mariage Saint-Yvi 3 E 339/39/4 (1923)
	1924   => '1371197',            # Mariage Saint-Yvi 3 E 339/39/5 (1924)
	1925   => '1371198',            # Mariage Saint-Yvi 3 E 339/39/6 (1925)
	1926   => '1371199',            # Mariage Saint-Yvi 3 E 339/39/7 (1926)
	1927   => '1371200',            # Mariage Saint-Yvi 3 E 339/39/8 (1927)
	1928   => '1371201',            # Mariage Saint-Yvi 3 E 339/39/9 (1928)
	1929   => '1371202',            # Mariage Saint-Yvi 3 E 339/39/10 (1929)
	1930   => '1371203',            # Mariage Saint-Yvi 3 E 339/39/11 (1930)
	1931   => '1371204',            # Mariage Saint-Yvi 3 E 339/39/12 (1931)
	1932   => '1371205',            # Mariage Saint-Yvi 3 E 339/39/13 (1932)
	1933   => '1371206',            # Mariage Saint-Yvi 3 E 339/39/14 (1933)
	1934   => '1371207',            # Mariage Saint-Yvi 3 E 339/39/15 (1934)
	1935   => '1371208',            # Mariage Saint-Yvi 3 E 339/39/16 (1935)
	1936   => '1371209',            # Mariage Saint-Yvi 3 E 339/39/17 (1936)
    },

    '3E339_0040' => {			# Décès Saint-Yvi 3 E 339 40   1914-1936
	1914   => '1371343',            # Décès Saint-Yvi 3 E 339/40/1 (1914)
	1915   => '1371344',            # Décès Saint-Yvi 3 E 339/40/2 (1915)
	1916   => '1371345',            # Décès Saint-Yvi 3 E 339/40/3 (1916)
	1917   => '1371346',            # Décès Saint-Yvi 3 E 339/40/4 (1917)
	1918   => '1371347',            # Décès Saint-Yvi 3 E 339/40/5 (1918)
	1919   => '1371348',            # Décès Saint-Yvi 3 E 339/40/6 (1919)
	1920   => '1371349',            # Décès Saint-Yvi 3 E 339/40/7 (1920)
	1921   => '1371350',            # Décès Saint-Yvi 3 E 339/40/8 (1921)
	1922   => '1371351',            # Décès Saint-Yvi 3 E 339/40/9 (1922)
	1923   => '1371352',            # Décès Saint-Yvi 3 E 339/40/10 (1923)
	1924   => '1371353',            # Décès Saint-Yvi 3 E 339/40/11 (1924)
	1925   => '1371354',            # Décès Saint-Yvi 3 E 339/40/12 (1925)
	1926   => '1371355',            # Décès Saint-Yvi 3 E 339/40/13 (1926)
	1927   => '1371356',            # Décès Saint-Yvi 3 E 339/40/14 (1927)
	1928   => '1371357',            # Décès Saint-Yvi 3 E 339/40/15 (1928)
	1929   => '1371358',            # Décès Saint-Yvi 3 E 339/40/16 (1929)
	1930   => '1371359',            # Décès Saint-Yvi 3 E 339/40/17 (1930)
	1931   => '1371360',            # Décès Saint-Yvi 3 E 339/40/18 (1931)
	1932   => '1371361',            # Décès Saint-Yvi 3 E 339/40/19 (1932)
	1933   => '1371362',            # Décès Saint-Yvi 3 E 339/40/20 (1933)
	1934   => '1371363',            # Décès Saint-Yvi 3 E 339/40/21 (1934)
	1935   => '1371364',            # Décès Saint-Yvi 3 E 339/40/22 (1935)
	1936   => '1371365',            # Décès Saint-Yvi 3 E 339/40/23 (1936)
    },

    # NMD Scaër
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

    '3E344_0015' => {			# Naissance Scaër 3 E 344 15   1813-1822
	1813   => '1371681',            # Naissance Scaër 3 E 344/15/1 (1813)
	1814   => '1371682',            # Naissance Scaër 3 E 344/15/2 (1814)
	1815   => '1371683',            # Naissance Scaër 3 E 344/15/3 (1815)
	1816   => '1371684',            # Naissance Scaër 3 E 344/15/4 (1816)
	1817   => '1371685',            # Naissance Scaër 3 E 344/15/5 (1817)
	1818   => '1371686',            # Naissance Scaër 3 E 344/15/6 (1818)
	1819   => '1371687',            # Naissance Scaër 3 E 344/15/7 (1819)
	1820   => '1371688',            # Naissance Scaër 3 E 344/15/8 (1820)
	1821   => '1371689',            # Naissance Scaër 3 E 344/15/9 (1821)
	1822   => '1371690',            # Naissance Scaër 3 E 344/15/10 (1822)
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

    '3E344_0027' => {			# Mariage Scaër 3 E 344 27   1823-1832
	1823   => '1371855',            # Mariage Scaër 3 E 344/27/1 (1823)
	1824   => '1371856',            # Mariage Scaër 3 E 344/27/2 (1824)
	1825   => '1371857',            # Mariage Scaër 3 E 344/27/3 (1825)
	1826   => '1371858',            # Mariage Scaër 3 E 344/27/4 (1826)
	1827   => '1371859',            # Mariage Scaër 3 E 344/27/5 (1827)
	1828   => '1371860',            # Mariage Scaër 3 E 344/27/6 (1828)
	1829   => '1371861',            # Mariage Scaër 3 E 344/27/7 (1829)
	1830   => '1371862',            # Mariage Scaër 3 E 344/27/8 (1830)
	1831   => '1371863',            # Mariage Scaër 3 E 344/27/9 (1831)
	1832   => '1371864',            # Mariage Scaër 3 E 344/27/10 (1832)
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

    '3E344_0034' => {			# Décès Scaër 3 E 344 34   AN02-AN10
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

    '3E344_0036' => {			# Décès Scaër 3 E 344 36   1813-1822
	1813   => '1372006',            # Décès Scaër 3 E 344/36/1 (1813)
	1814   => '1372007',            # Décès Scaër 3 E 344/36/2 (1814)
	1815   => '1372008',            # Décès Scaër 3 E 344/36/3 (1815)
	1816   => '1372009',            # Décès Scaër 3 E 344/36/4 (1816)
	1817   => '1372010',            # Décès Scaër 3 E 344/36/5 (1817)
	1818   => '1372011',            # Décès Scaër 3 E 344/36/6 (1818)
	1819   => '1372012',            # Décès Scaër 3 E 344/36/7 (1819)
	1820   => '1372013',            # Décès Scaër 3 E 344/36/8 (1820)
	1821   => '1372014',            # Décès Scaër 3 E 344/36/9 (1821)
	1822   => '1372015',            # Décès Scaër 3 E 344/36/10 (1822)
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

    '3E344_0058' => {			# Mariage Scaër 3 E 344 58   1925-1930
	1925   => '1371968',            # Mariage Scaër 3 E 344/58/1 (1925)
	1926   => '1371969',            # Mariage Scaër 3 E 344/58/2 (1926)
	1927   => '1371970',            # Mariage Scaër 3 E 344/58/3 (1927)
	1928   => '1371971',            # Mariage Scaër 3 E 344/58/4 (1928)
	1929   => '1371972',            # Mariage Scaër 3 E 344/58/5 (1929)
	1930   => '1371973',            # Mariage Scaër 3 E 344/58/6 (1930)
    },

    '3E344_0059' => {			# Mariage Scaër 3 E 344 59   1931-1936
	1931   => '1371975',            # Mariage Scaër 3 E 344/59/1 (1931)
	1932   => '1371976',            # Mariage Scaër 3 E 344/59/2 (1932)
	1933   => '1371977',            # Mariage Scaër 3 E 344/59/3 (1933)
	1934   => '1371978',            # Mariage Scaër 3 E 344/59/4 (1934)
	1935   => '1371979',            # Mariage Scaër 3 E 344/59/5 (1935)
	1936   => '1371980',            # Mariage Scaër 3 E 344/59/6 (1936)
    },

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

    # NMD Spézet
    # https://recherche.archives.finistere.fr/archive/resultats/etatcivil/n:138?REch_commune_Libel=Spézet+%28Finistère%29%7C&REch_commune_Md5=b6713734e42457b28f4773f547444ce7%7C&Rech_typologie%5B0%5D=Naissance&type=etatcivil
    '3E348_0012' => {			# Naissance Spézet 3 E 348 12   AN02-AN10
	'AN02' => '1373156',            # Naissance Spézet 3 E 348/12/1 (1793 - an II)
	'AN03' => '1373157',            # Naissance Spézet 3 E 348/12/2 (an III)
	'AN04' => '1373158',            # Naissance Spézet 3 E 348/12/3 (an IV)
	'AN05' => '1373159',            # Naissance Spézet 3 E 348/12/4 (an V)
	'AN06' => '1373160',            # Naissance Spézet 3 E 348/12/5 (an VI)
	'AN07' => '1373161',            # Naissance Spézet 3 E 348/12/6 (an VII)
	'AN08' => '1373162',            # Naissance Spézet 3 E 348/12/7 (an VIII)
	'AN09' => '1373163',            # Naissance Spézet 3 E 348/12/8 (an IX)
	'AN10' => '1373164',            # Naissance Spézet 3 E 348/12/9 (an X)
    },

    '3E348_0013' => {			# Naissances Spezet  3 E 348 13		an XI-1812
	999999 => 'dummy',              # Just so that perl-mode indents correctly :-(
	'AN11' => '1373166',            # Naissance Spézet 3 E 348/13/1 (an XI)
	'AN12' => '1373167',            # Naissance Spézet 3 E 348/13/2 (an XII)
	'AN13' => '1373168',            # Naissance Spézet 3 E 348/13/3 (an XIII)
	'AN14' => '1373169',            # Naissance Spézet 3 E 348/13/4 (an XIV)
	1807   => '1373170',            # Naissance Spézet 3 E 348/13/5 (1807)
	1808   => '1373171',            # Naissance Spézet 3 E 348/13/6 (1808)
	1809   => '1373172',            # Naissance Spézet 3 E 348/13/7 (1809)
	1810   => '1373173',            # Naissance Spézet 3 E 348/13/8 (1810)
	1811   => '1373174',            # Naissance Spézet 3 E 348/13/9 (1811)
	1812   => '1373175',            # Naissance Spézet 3 E 348/13/10 (1812)
    },

    '3E348_0014' => {			# Naissance Spézet 3 E 348 14   1813-1822
	1813   => '1373177',            # Naissance Spézet 3 E 348/14/1 (1813)
	1814   => '1373178',            # Naissance Spézet 3 E 348/14/2 (1814)
	1815   => '1373179',            # Naissance Spézet 3 E 348/14/3 (1815)
	1816   => '1373180',            # Naissance Spézet 3 E 348/14/4 (1816)
	1817   => '1373181',            # Naissance Spézet 3 E 348/14/5 (1817)
	1818   => '1373182',            # Naissance Spézet 3 E 348/14/6 (1818)
	1819   => '1373183',            # Naissance Spézet 3 E 348/14/7 (1819)
	1820   => '1373184',            # Naissance Spézet 3 E 348/14/8 (1820)
	1821   => '1373185',            # Naissance Spézet 3 E 348/14/9 (1821)
	1822   => '1373186',            # Naissance Spézet 3 E 348/14/10 (1822)
    },

    '3E348_0015' => {			# Naissance Spézet 3 E 348 15   1823-1832
	1823   => '1373188',            # Naissance Spézet 3 E 348/15/1 (1823)
	1824   => '1373189',            # Naissance Spézet 3 E 348/15/2 (1824)
	1825   => '1373190',            # Naissance Spézet 3 E 348/15/3 (1825)
	1826   => '1373191',            # Naissance Spézet 3 E 348/15/4 (1826)
	1827   => '1373192',            # Naissance Spézet 3 E 348/15/5 (1827)
	1828   => '1373193',            # Naissance Spézet 3 E 348/15/6 (1828)
	1829   => '1373194',            # Naissance Spézet 3 E 348/15/7 (1829)
	1830   => '1373195',            # Naissance Spézet 3 E 348/15/8 (1830)
	1831   => '1373196',            # Naissance Spézet 3 E 348/15/9 (1831)
	1832   => '1373197',            # Naissance Spézet 3 E 348/15/10 (1832)
    },

    '3E348_0016' => {			# Naissance Spézet 3 E 348 16   1833-1842
	1833   => '1373199',            # Naissance Spézet 3 E 348/16/1 (1833)
	1834   => '1373200',            # Naissance Spézet 3 E 348/16/2 (1834)
	1835   => '1373201',            # Naissance Spézet 3 E 348/16/3 (1835)
	1836   => '1373202',            # Naissance Spézet 3 E 348/16/4 (1836)
	1837   => '1373203',            # Naissance Spézet 3 E 348/16/5 (1837)
	1838   => '1373204',            # Naissance Spézet 3 E 348/16/6 (1838)
	1839   => '1373205',            # Naissance Spézet 3 E 348/16/7 (1839)
	1840   => '1373206',            # Naissance Spézet 3 E 348/16/8 (1840)
	1841   => '1373207',            # Naissance Spézet 3 E 348/16/9 (1841)
	1842   => '1373208',            # Naissance Spézet 3 E 348/16/10 (1842)
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

    '3E348_0018' => {			# Naissance Spézet 3 E 348 18   1853-1862
	1853   => '1373221',            # Naissance Spézet 3 E 348/18/1 (1853)
	1854   => '1373222',            # Naissance Spézet 3 E 348/18/2 (1854)
	1855   => '1373223',            # Naissance Spézet 3 E 348/18/3 (1855)
	1856   => '1373224',            # Naissance Spézet 3 E 348/18/4 (1856)
	1857   => '1373225',            # Naissance Spézet 3 E 348/18/5 (1857)
	1858   => '1373226',            # Naissance Spézet 3 E 348/18/6 (1858)
	1859   => '1373227',            # Naissance Spézet 3 E 348/18/7 (1859)
	1860   => '1373228',            # Naissance Spézet 3 E 348/18/8 (1860)
	1861   => '1373229',            # Naissance Spézet 3 E 348/18/9 (1861)
	1862   => '1373230',            # Naissance Spézet 3 E 348/18/10 (1862)
    },

    '3E348_0019' => {			# Naissance Spézet 3 E 348 19   1863-1869
	1863   => '1373232',            # Naissance Spézet 3 E 348/19/1 (1863)
	1864   => '1373233',            # Naissance Spézet 3 E 348/19/2 (1864)
	1865   => '1373234',            # Naissance Spézet 3 E 348/19/3 (1865)
	1866   => '1373235',            # Naissance Spézet 3 E 348/19/4 (1866)
	1867   => '1373236',            # Naissance Spézet 3 E 348/19/5 (1867)
	1868   => '1373237',            # Naissance Spézet 3 E 348/19/6 (1868)
	1869   => '1373238',            # Naissance Spézet 3 E 348/19/7 (1869)
    },

    '3E348_0020' => {			# Naissance Spézet 3 E 348 20   1870-1877
	1870   => '1373240',            # Naissance Spézet 3 E 348/20/1 (1870)
	1871   => '1373241',            # Naissance Spézet 3 E 348/20/2 (1871)
	1872   => '1373242',            # Naissance Spézet 3 E 348/20/3 (1872)
	1873   => '1373243',            # Naissance Spézet 3 E 348/20/4 (1873)
	1874   => '1373244',            # Naissance Spézet 3 E 348/20/5 (1874)
	1875   => '1373245',            # Naissance Spézet 3 E 348/20/6 (1875)
	1876   => '1373246',            # Naissance Spézet 3 E 348/20/7 (1876)
	1877   => '1373247',            # Naissance Spézet 3 E 348/20/8 (1877)
    },

    '3E348_0021' => {			# Naissance Spézet 3 E 348 21   1878-1886
	1878   => '1373249',            # Naissance Spézet 3 E 348/21/1 (1878)
	1879   => '1373250',            # Naissance Spézet 3 E 348/21/2 (1879)
	1880   => '1373251',            # Naissance Spézet 3 E 348/21/3 (1880)
	1881   => '1373252',            # Naissance Spézet 3 E 348/21/4 (1881)
	1882   => '1373253',            # Naissance Spézet 3 E 348/21/5 (1882)
	1883   => '1373254',            # Naissance Spézet 3 E 348/21/6 (1883)
	1884   => '1373255',            # Naissance Spézet 3 E 348/21/7 (1884)
	1885   => '1373256',            # Naissance Spézet 3 E 348/21/8 (1885)
	1886   => '1373257',            # Naissance Spézet 3 E 348/21/9 (1886)
    },

    '3E348_0022' => {			# Mariage publication de mariage promesse de mariage Spézet 3 E 348 22   AN02-AN09
	'AN01' => '1373318',            # Mariage publication de mariage promesse de mariage Spézet 3 E 348/22/1 (1793-an II (contient également des publications de mariages))
	'AN03' => '1373319',            # Mariage publication de mariage promesse de mariage Spézet 3 E 348/22/2 (an III (contient également des publications de mariages))
	'AN04' => '1373320',            # Mariage publication de mariage promesse de mariage Spézet 3 E 348/22/3 (an IV (contient également des publications de mariages))
	'AN05' => '1373321',            # Mariage publication de mariage promesse de mariage Spézet 3 E 348/22/4 (an V)
	'AN06' => '1373322',            # Mariage publication de mariage promesse de mariage Spézet 3 E 348/22/5 (an VI (contient uniquement des promesses de mariages))
	'AN09' => '1373323',            # Mariage publication de mariage promesse de mariage Spézet 3 E 348/22/6 (an IX)
    },

    '3E348_0023' => {			# Mariage Spézet 3 E 348 23   AN12-1812
	'AN12' => '1373325',            # Mariage Spézet 3 E 348/23/1 (an XII)
	'AN13' => '1373326',            # Mariage Spézet 3 E 348/23/2 (an XIII (contient un acte de 1806))
	'AN14' => '1373327',            # Mariage Spézet 3 E 348/23/3 (an XIV - 1806)
	1807   => '1373328',            # Mariage Spézet 3 E 348/23/4 (1807)
	1808   => '1373329',            # Mariage Spézet 3 E 348/23/5 (1808)
	1809   => '1373330',            # Mariage Spézet 3 E 348/23/6 (1809)
	1810   => '1373331',            # Mariage Spézet 3 E 348/23/7 (1810)
	1811   => '1373332',            # Mariage Spézet 3 E 348/23/8 (1811)
	1812   => '1373333',            # Mariage Spézet 3 E 348/23/9 (1812)
    },

    '3E348_0024' => {			# Mariage Spézet 3 E 348 24   1813-1822
	1813   => '1373335',            # Mariage Spézet 3 E 348/24/1 (1813)
	1814   => '1373336',            # Mariage Spézet 3 E 348/24/2 (1814)
	1815   => '1373337',            # Mariage Spézet 3 E 348/24/3 (1815)
	1816   => '1373338',            # Mariage Spézet 3 E 348/24/4 (1816)
	1817   => '1373339',            # Mariage Spézet 3 E 348/24/5 (1817)
	1818   => '1373340',            # Mariage Spézet 3 E 348/24/6 (1818)
	1819   => '1373341',            # Mariage Spézet 3 E 348/24/7 (1819)
	1820   => '1373342',            # Mariage Spézet 3 E 348/24/8 (1820)
	1821   => '1373343',            # Mariage Spézet 3 E 348/24/9 (1821)
	1822   => '1373344',            # Mariage Spézet 3 E 348/24/10 (1822)
    },

    '3E348_0025' => {			# Mariage Spézet 3 E 348 25   1823-1832
	1823   => '1373346',            # Mariage Spézet 3 E 348/25/1 (1823)
	1824   => '1373347',            # Mariage Spézet 3 E 348/25/2 (1824)
	1825   => '1373348',            # Mariage Spézet 3 E 348/25/3 (1825)
	1826   => '1373349',            # Mariage Spézet 3 E 348/25/4 (1826)
	1827   => '1373350',            # Mariage Spézet 3 E 348/25/5 (1827)
	1828   => '1373351',            # Mariage Spézet 3 E 348/25/6 (1828)
	1829   => '1373352',            # Mariage Spézet 3 E 348/25/7 (1829)
	1830   => '1373353',            # Mariage Spézet 3 E 348/25/8 (1830)
	1831   => '1373354',            # Mariage Spézet 3 E 348/25/9 (1831)
	1832   => '1373355',            # Mariage Spézet 3 E 348/25/10 (1832)
    },

    '3E348_0026' => {			# Mariage Spézet 3 E 348 26   1833-1842
	1833   => '1373357',            # Mariage Spézet 3 E 348/26/1 (1833)
	1834   => '1373358',            # Mariage Spézet 3 E 348/26/2 (1834)
	1835   => '1373359',            # Mariage Spézet 3 E 348/26/3 (1835)
	1836   => '1373360',            # Mariage Spézet 3 E 348/26/4 (1836)
	1837   => '1373361',            # Mariage Spézet 3 E 348/26/5 (1837)
	1838   => '1373362',            # Mariage Spézet 3 E 348/26/6 (1838)
	1839   => '1373363',            # Mariage Spézet 3 E 348/26/7 (1839)
	1840   => '1373364',            # Mariage Spézet 3 E 348/26/8 (1840)
	1841   => '1373365',            # Mariage Spézet 3 E 348/26/9 (1841)
	1842   => '1373366',            # Mariage Spézet 3 E 348/26/10 (1842)
    },

    '3E348_0027' => {			# Mariage Spézet 3 E 348 27   1843-1852
	1843   => '1373368',            # Mariage Spézet 3 E 348/27/1 (1843)
	1844   => '1373369',            # Mariage Spézet 3 E 348/27/2 (1844)
	1845   => '1373370',            # Mariage Spézet 3 E 348/27/3 (1845)
	1846   => '1373371',            # Mariage Spézet 3 E 348/27/4 (1846)
	1847   => '1373372',            # Mariage Spézet 3 E 348/27/5 (1847)
	1848   => '1373373',            # Mariage Spézet 3 E 348/27/6 (1848)
	1849   => '1373374',            # Mariage Spézet 3 E 348/27/7 (1849)
	1850   => '1373375',            # Mariage Spézet 3 E 348/27/8 (1850)
	1851   => '1373376',            # Mariage Spézet 3 E 348/27/9 (1851)
	1852   => '1373377',            # Mariage Spézet 3 E 348/27/10 (1852)
    },

    '3E348_0028' => {			# Mariage Spézet 3 E 348 28   1853-1862
	1853   => '1373379',            # Mariage Spézet 3 E 348/28/1 (1853)
	1854   => '1373380',            # Mariage Spézet 3 E 348/28/2 (1854)
	1855   => '1373381',            # Mariage Spézet 3 E 348/28/3 (1855)
	1856   => '1373382',            # Mariage Spézet 3 E 348/28/4 (1856)
	1857   => '1373383',            # Mariage Spézet 3 E 348/28/5 (1857)
	1858   => '1373384',            # Mariage Spézet 3 E 348/28/6 (1858)
	1859   => '1373385',            # Mariage Spézet 3 E 348/28/7 (1859)
	1860   => '1373386',            # Mariage Spézet 3 E 348/28/8 (1860)
	1861   => '1373387',            # Mariage Spézet 3 E 348/28/9 (1861)
	1862   => '1373388',            # Mariage Spézet 3 E 348/28/10 (1862)
    },

    '3E348_0029' => {			# Mariage Spézet 3 E 348 29   1863-1869
	1863   => '1373390',            # Mariage Spézet 3 E 348/29/1 (1863)
	1864   => '1373391',            # Mariage Spézet 3 E 348/29/2 (1864)
	1865   => '1373392',            # Mariage Spézet 3 E 348/29/3 (1865)
	1866   => '1373393',            # Mariage Spézet 3 E 348/29/4 (1866)
	1867   => '1373394',            # Mariage Spézet 3 E 348/29/5 (1867)
	1868   => '1373395',            # Mariage Spézet 3 E 348/29/6 (1868)
	1869   => '1373396',            # Mariage Spézet 3 E 348/29/7 (1869)
    },

    '3E348_0030' => {			# Mariage Spézet 3 E 348 30   1870-1882
	1870   => '1373398',            # Mariage Spézet 3 E 348/30/1 (1870)
	1871   => '1373399',            # Mariage Spézet 3 E 348/30/2 (1871)
	1872   => '1373400',            # Mariage Spézet 3 E 348/30/3 (1872)
	1873   => '1373401',            # Mariage Spézet 3 E 348/30/4 (1873)
	1874   => '1373402',            # Mariage Spézet 3 E 348/30/5 (1874)
	1875   => '1373403',            # Mariage Spézet 3 E 348/30/6 (1875)
	1876   => '1373404',            # Mariage Spézet 3 E 348/30/7 (1876)
	1877   => '1373405',            # Mariage Spézet 3 E 348/30/8 (1877)
	1878   => '1373406',            # Mariage Spézet 3 E 348/30/9 (1878)
	1879   => '1373407',            # Mariage Spézet 3 E 348/30/10 (1879)
	1880   => '1373408',            # Mariage Spézet 3 E 348/30/11 (1880)
	1881   => '1373409',            # Mariage Spézet 3 E 348/30/12 (1881)
	1882   => '1373410',            # Mariage Spézet 3 E 348/30/13 (1882)
    },

    '3E348_0031' => {			# Décès Spézet 3 E 348 31   AN02-AN10
	'AN02' => '1373473',            # Décès Spézet 3 E 348/31/1 (1793 - an II)
	'AN03' => '1373474',            # Décès Spézet 3 E 348/31/2 (an III)
	'AN04' => '1373475',            # Décès Spézet 3 E 348/31/3 (an IV)
	'AN05' => '1373476',            # Décès Spézet 3 E 348/31/4 (an V)
	'AN06' => '1373477',            # Décès Spézet 3 E 348/31/5 (an VI)
	'AN07' => '1373478',            # Décès Spézet 3 E 348/31/6 (an VII)
	'AN08' => '1373479',            # Décès Spézet 3 E 348/31/7 (an VIII)
	'AN09' => '1373480',            # Décès Spézet 3 E 348/31/8 (an IX)
	'AN10' => '1373481',            # Décès Spézet 3 E 348/31/9 (an X)
    },

    '3E348_0032' => {			# Décès Spézet 3 E 348 32   AN11-1812
	'AN11' => '1373483',            # Décès Spézet 3 E 348/32/1 (an XI)
	'AN12' => '1373484',            # Décès Spézet 3 E 348/32/2 (an XII)
	'AN13' => '1373485',            # Décès Spézet 3 E 348/32/3 (an XIII)
	'AN14' => '1373486',            # Décès Spézet 3 E 348/32/4 (an XIV - 1806)
	1807   => '1373487',            # Décès Spézet 3 E 348/32/5 (1807)
	1808   => '1373488',            # Décès Spézet 3 E 348/32/6 (1808)
	1809   => '1373489',            # Décès Spézet 3 E 348/32/7 (1809)
	1810   => '1373490',            # Décès Spézet 3 E 348/32/8 (1810)
	1811   => '1373491',            # Décès Spézet 3 E 348/32/9 (1811)
	1812   => '1373492',            # Décès Spézet 3 E 348/32/10 (1812)
    },

    '3E348_0033' => {			# Décès Spézet 3 E 348 33   1813-1822
	1813   => '1373494',            # Décès Spézet 3 E 348/33/1 (1813)
	1814   => '1373495',            # Décès Spézet 3 E 348/33/2 (1814)
	1815   => '1373496',            # Décès Spézet 3 E 348/33/3 (1815)
	1816   => '1373497',            # Décès Spézet 3 E 348/33/4 (1816)
	1817   => '1373498',            # Décès Spézet 3 E 348/33/5 (1817)
	1818   => '1373499',            # Décès Spézet 3 E 348/33/6 (1818)
	1819   => '1373500',            # Décès Spézet 3 E 348/33/7 (1819)
	1820   => '1373501',            # Décès Spézet 3 E 348/33/8 (1820)
	1821   => '1373502',            # Décès Spézet 3 E 348/33/9 (1821)
	1822   => '1373503',            # Décès Spézet 3 E 348/33/10 (1822)
    },

    '3E348_0034' => {			# Décès Spézet 3 E 348 34   1823-1832
	1823   => '1373505',            # Décès Spézet 3 E 348/34/1 (1823)
	1824   => '1373506',            # Décès Spézet 3 E 348/34/2 (1824)
	1825   => '1373507',            # Décès Spézet 3 E 348/34/3 (1825)
	1826   => '1373508',            # Décès Spézet 3 E 348/34/4 (1826)
	1827   => '1373509',            # Décès Spézet 3 E 348/34/5 (1827)
	1828   => '1373510',            # Décès Spézet 3 E 348/34/6 (1828)
	1829   => '1373511',            # Décès Spézet 3 E 348/34/7 (1829)
	1830   => '1373512',            # Décès Spézet 3 E 348/34/8 (1830)
	1831   => '1373513',            # Décès Spézet 3 E 348/34/9 (1831)
	1832   => '1373514',            # Décès Spézet 3 E 348/34/10 (1832)
    },

    '3E348_0035' => {			# Décès Spézet 3 E 348 35   1833-1842
	1833   => '1373516',            # Décès Spézet 3 E 348/35/1 (1833)
	1834   => '1373517',            # Décès Spézet 3 E 348/35/2 (1834)
	1835   => '1373518',            # Décès Spézet 3 E 348/35/3 (1835)
	1836   => '1373519',            # Décès Spézet 3 E 348/35/4 (1836)
	1837   => '1373520',            # Décès Spézet 3 E 348/35/5 (1837)
	1838   => '1373521',            # Décès Spézet 3 E 348/35/6 (1838)
	1839   => '1373522',            # Décès Spézet 3 E 348/35/7 (1839)
	1840   => '1373523',            # Décès Spézet 3 E 348/35/8 (1840)
	1841   => '1373524',            # Décès Spézet 3 E 348/35/9 (1841)
	1842   => '1373525',            # Décès Spézet 3 E 348/35/10 (1842)
    },

    '3E348_0036' => {			# Décès Spézet 3 E 348 36   1843-1852
	1843   => '1373527',            # Décès Spézet 3 E 348/36/1 (1843)
	1844   => '1373528',            # Décès Spézet 3 E 348/36/2 (1844)
	1845   => '1373529',            # Décès Spézet 3 E 348/36/3 (1845)
	1846   => '1373530',            # Décès Spézet 3 E 348/36/4 (1846)
	1847   => '1373531',            # Décès Spézet 3 E 348/36/5 (1847)
	1848   => '1373532',            # Décès Spézet 3 E 348/36/6 (1848)
	1849   => '1373533',            # Décès Spézet 3 E 348/36/7 (1849)
	1850   => '1373534',            # Décès Spézet 3 E 348/36/8 (1850)
	1851   => '1373535',            # Décès Spézet 3 E 348/36/9 (1851)
	1852   => '1373536',            # Décès Spézet 3 E 348/36/10 (1852)
    },

    '3E348_0037' => {			# Décès Spézet 3 E 348 37   1853-1862
	1853   => '1373538',            # Décès Spézet 3 E 348/37/1 (1853)
	1854   => '1373539',            # Décès Spézet 3 E 348/37/2 (1854)
	1855   => '1373540',            # Décès Spézet 3 E 348/37/3 (1855)
	1856   => '1373541',            # Décès Spézet 3 E 348/37/4 (1856)
	1857   => '1373542',            # Décès Spézet 3 E 348/37/5 (1857)
	1858   => '1373543',            # Décès Spézet 3 E 348/37/6 (1858)
	1859   => '1373544',            # Décès Spézet 3 E 348/37/7 (1859)
	1860   => '1373545',            # Décès Spézet 3 E 348/37/8 (1860)
	1861   => '1373546',            # Décès Spézet 3 E 348/37/9 (1861)
	1862   => '1373547',            # Décès Spézet 3 E 348/37/10 (1862)
    },

    '3E348_0038' => {			# Décès Spézet 3 E 348 38   1863-1869
	1863   => '1373549',            # Décès Spézet 3 E 348/38/1 (1863)
	1864   => '1373550',            # Décès Spézet 3 E 348/38/2 (1864)
	1865   => '1373551',            # Décès Spézet 3 E 348/38/3 (1865)
	1866   => '1373552',            # Décès Spézet 3 E 348/38/4 (1866)
	1867   => '1373553',            # Décès Spézet 3 E 348/38/5 (1867)
	1868   => '1373554',            # Décès Spézet 3 E 348/38/6 (1868)
	1869   => '1373555',            # Décès Spézet 3 E 348/38/7 (1869)
    },

    '3E348_0039' => {			# Décès Spézet 3 E 348 39   1870-1879
	1870   => '1373557',            # Décès Spézet 3 E 348/39/1 (1870)
	1871   => '1373558',            # Décès Spézet 3 E 348/39/2 (1871)
	1872   => '1373559',            # Décès Spézet 3 E 348/39/3 (1872)
	1873   => '1373560',            # Décès Spézet 3 E 348/39/4 (1873)
	1874   => '1373561',            # Décès Spézet 3 E 348/39/5 (1874)
	1875   => '1373562',            # Décès Spézet 3 E 348/39/6 (1875)
	1876   => '1373563',            # Décès Spézet 3 E 348/39/7 (1876)
	1877   => '1373564',            # Décès Spézet 3 E 348/39/8 (1877)
	1878   => '1373565',            # Décès Spézet 3 E 348/39/9 (1878)
	1879   => '1373566',            # Décès Spézet 3 E 348/39/10 (1879)
    },

    '3E348_0040' => {			# Décès Spézet 3 E 348 40   1880-1889
	1880   => '1373568',            # Décès Spézet 3 E 348/40/1 (1880)
	1881   => '1373569',            # Décès Spézet 3 E 348/40/2 (1881)
	1882   => '1373570',            # Décès Spézet 3 E 348/40/3 (1882)
	1883   => '1373571',            # Décès Spézet 3 E 348/40/4 (1883)
	1884   => '1373572',            # Décès Spézet 3 E 348/40/5 (1884)
	1885   => '1373573',            # Décès Spézet 3 E 348/40/6 (1885)
	1886   => '1373574',            # Décès Spézet 3 E 348/40/7 (1886)
	1887   => '1373575',            # Décès Spézet 3 E 348/40/8 (1887)
	1888   => '1373576',            # Décès Spézet 3 E 348/40/9 (1888)
	1889   => '1373577',            # Décès Spézet 3 E 348/40/10 (1889)
    },

    '3E348_0041' => {			# Naissance Spézet 3 E 348 41   1887-1895
	1887   => '1373259',            # Naissance Spézet 3 E 348/41/1 (1887)
	1888   => '1373260',            # Naissance Spézet 3 E 348/41/2 (1888)
	1889   => '1373261',            # Naissance Spézet 3 E 348/41/3 (1889)
	1890   => '1373262',            # Naissance Spézet 3 E 348/41/4 (1890)
	1891   => '1373263',            # Naissance Spézet 3 E 348/41/5 (1891)
	1892   => '1373264',            # Naissance Spézet 3 E 348/41/6 (1892)
	1893   => '1373265',            # Naissance Spézet 3 E 348/41/7 (1893)
	1894   => '1373266',            # Naissance Spézet 3 E 348/41/8 (1894)
	1895   => '1373267',            # Naissance Spézet 3 E 348/41/9 (1895)
    },

    '3E348_0042' => {			# Mariage Spézet 3 E 348 42   1888-1895
	1883   => '1373412',            # Mariage Spézet 3 E 348/42/1 (1883)
	1884   => '1373413',            # Mariage Spézet 3 E 348/42/2 (1884)
	1885   => '1373414',            # Mariage Spézet 3 E 348/42/3 (1885)
	1886   => '1373415',            # Mariage Spézet 3 E 348/42/4 (1886)
	1887   => '1373416',            # Mariage Spézet 3 E 348/42/5 (1887)
	1888   => '1373417',            # Mariage Spézet 3 E 348/42/6 (1888)
	1889   => '1373418',            # Mariage Spézet 3 E 348/42/7 (1889)
	1890   => '1373419',            # Mariage Spézet 3 E 348/42/8 (1890)
	1891   => '1373420',            # Mariage Spézet 3 E 348/42/9 (1891)
	1892   => '1373421',            # Mariage Spézet 3 E 348/42/10 (1892)
	1893   => '1373422',            # Mariage Spézet 3 E 348/42/11 (1893)
	1894   => '1373423',            # Mariage Spézet 3 E 348/42/12 (1894)
	1895   => '1373424',            # Mariage Spézet 3 E 348/42/13 (1895)
    },

    '3E348_0043' => {			# Décès Spézet 3 E 348 43   1890-1899
	1890   => '1373579',            # Décès Spézet 3 E 348/43/1 (1890)
	1891   => '1373580',            # Décès Spézet 3 E 348/43/2 (1891)
	1892   => '1373581',            # Décès Spézet 3 E 348/43/3 (1892)
	1893   => '1373582',            # Décès Spézet 3 E 348/43/4 (1893)
	1894   => '1373583',            # Décès Spézet 3 E 348/43/5 (1894)
	1895   => '1373584',            # Décès Spézet 3 E 348/43/6 (1895)
	1896   => '1373585',            # Décès Spézet 3 E 348/43/7 (1896)
	1897   => '1373586',            # Décès Spézet 3 E 348/43/8 (1897)
	1898   => '1373587',            # Décès Spézet 3 E 348/43/9 (1898)
	1899   => '1373588',            # Décès Spézet 3 E 348/43/10 (1899)
    },

    '3E348_0044' => {			# Naissance Spézet 3 E 348 44   1896-1902
	1896   => '1373269',            # Naissance Spézet 3 E 348/44/1 (1896)
	1897   => '1373270',            # Naissance Spézet 3 E 348/44/2 (1897)
	1898   => '1373271',            # Naissance Spézet 3 E 348/44/3 (1898)
	1899   => '1373272',            # Naissance Spézet 3 E 348/44/4 (1899)
	1900   => '1373273',            # Naissance Spézet 3 E 348/44/5 (1900)
	1901   => '1373274',            # Naissance Spézet 3 E 348/44/6 (1901)
	1902   => '1373275',            # Naissance Spézet 3 E 348/44/7 (1902)
    },

    '3E348_0045' => {			# Mariage Spézet 3 E 348 45   1896-1905
	1896   => '1373426',            # Mariage Spézet 3 E 348/45/1 (1896)
	1897   => '1373427',            # Mariage Spézet 3 E 348/45/2 (1897)
	1898   => '1373428',            # Mariage Spézet 3 E 348/45/3 (1898)
	1899   => '1373429',            # Mariage Spézet 3 E 348/45/4 (1899)
	1900   => '1373430',            # Mariage Spézet 3 E 348/45/5 (1900)
	1901   => '1373431',            # Mariage Spézet 3 E 348/45/6 (1901)
	1902   => '1373432',            # Mariage Spézet 3 E 348/45/7 (1902)
	1903   => '1373433',            # Mariage Spézet 3 E 348/45/8 (1903)
	1904   => '1373434',            # Mariage Spézet 3 E 348/45/9 (1904)
	1905   => '1373435',            # Mariage Spézet 3 E 348/45/10 (1905)
    },

    '3E348_0046' => {			# Décès Spézet 3 E 348 46   1900-1907
	1900   => '1373590',            # Décès Spézet 3 E 348/46/1 (1900)
	1901   => '1373591',            # Décès Spézet 3 E 348/46/2 (1901)
	1902   => '1373592',            # Décès Spézet 3 E 348/46/3 (1902)
	1903   => '1373593',            # Décès Spézet 3 E 348/46/4 (1903)
	1904   => '1373594',            # Décès Spézet 3 E 348/46/5 (1904)
	1905   => '1373595',            # Décès Spézet 3 E 348/46/6 (1905)
	1906   => '1373596',            # Décès Spézet 3 E 348/46/7 (1906)
	1907   => '1373597',            # Décès Spézet 3 E 348/46/8 (1907)
    },

    '3E348_0047' => {			# Naissance Spézet 3 E 348 47   1903-1909
	1903   => '1373277',            # Naissance Spézet 3 E 348/47/1 (1903)
	1904   => '1373278',            # Naissance Spézet 3 E 348/47/2 (1904)
	1905   => '1373279',            # Naissance Spézet 3 E 348/47/3 (1905)
	1906   => '1373280',            # Naissance Spézet 3 E 348/47/4 (1906)
	1907   => '1373281',            # Naissance Spézet 3 E 348/47/5 (1907)
	1908   => '1373282',            # Naissance Spézet 3 E 348/47/6 (1908)
	1909   => '1373283',            # Naissance Spézet 3 E 348/47/7 (1909)
    },

    '3E348_0048' => {			# Naissance Spézet 3 E 348 48   1910-1916
	1910   => '1373285',            # Naissance Spézet 3 E 348/48/1 (1910)
	1911   => '1373286',            # Naissance Spézet 3 E 348/48/2 (1911)
	1912   => '1373287',            # Naissance Spézet 3 E 348/48/3 (1912)
	1913   => '1373288',            # Naissance Spézet 3 E 348/48/4 (1913)
	1914   => '1373289',            # Naissance Spézet 3 E 348/48/5 (1914)
	1915   => '1373290',            # Naissance Spézet 3 E 348/48/6 (1915)
	1916   => '1373291',            # Naissance Spézet 3 E 348/48/7 (1916)
    },

    '3E348_0049' => {			# Naissance Spézet 3 E 348 49   1917-1923
	1917   => '1373293',            # Naissance Spézet 3 E 348/49/1 (1917)
	1918   => '1373294',            # Naissance Spézet 3 E 348/49/2 (1918)
	1919   => '1373295',            # Naissance Spézet 3 E 348/49/3 (1919)
	1920   => '1373296',            # Naissance Spézet 3 E 348/49/4 (1920)
	1921   => '1373297',            # Naissance Spézet 3 E 348/49/5 (1921)
	1922   => '1373298',            # Naissance Spézet 3 E 348/49/6 (1922)
	1923   => '1373299',            # Naissance Spézet 3 E 348/49/7 (1923)
    },

    '3E348_0050' => {			# Naissance Spézet 3 E 348 50   1924-1925
	1924   => '1373301',            # Naissance Spézet 3 E 348/50/1 (1924)
	1925   => '1373302',            # Naissance Spézet 3 E 348/50/2 (1925)
    },

    '3E348_0052' => {			# Mariage Spézet 3 E 348 52   1906-1914
	1906   => '1373437',            # Mariage Spézet 3 E 348/52/1 (1906)
	1907   => '1373438',            # Mariage Spézet 3 E 348/52/2 (1907)
	1908   => '1373439',            # Mariage Spézet 3 E 348/52/3 (1908)
	1909   => '1373440',            # Mariage Spézet 3 E 348/52/4 (1909)
	1910   => '1373441',            # Mariage Spézet 3 E 348/52/5 (1910)
	1911   => '1373442',            # Mariage Spézet 3 E 348/52/6 (1911)
	1912   => '1373443',            # Mariage Spézet 3 E 348/52/7 (1912)
	1913   => '1373444',            # Mariage Spézet 3 E 348/52/8 (1913)
	1914   => '1373445',            # Mariage Spézet 3 E 348/52/9 (1914)
    },

    '3E348_0053' => {			# Mariage Spézet 3 E 348 53   1915-1924
	1915   => '1373447',            # Mariage Spézet 3 E 348/53/1 (1915)
	1916   => '1373448',            # Mariage Spézet 3 E 348/53/2 (1916)
	1917   => '1373449',            # Mariage Spézet 3 E 348/53/3 (1917)
	1918   => '1373450',            # Mariage Spézet 3 E 348/53/4 (1918)
	1919   => '1373451',            # Mariage Spézet 3 E 348/53/5 (1919)
	1920   => '1373452',            # Mariage Spézet 3 E 348/53/6 (1920)
	1921   => '1373453',            # Mariage Spézet 3 E 348/53/7 (1921)
	1922   => '1373454',            # Mariage Spézet 3 E 348/53/8 (1922)
	1923   => '1373455',            # Mariage Spézet 3 E 348/53/9 (1923)
	1924   => '1373456',            # Mariage Spézet 3 E 348/53/10 (1924)
    },

    '3E348_0054' => {			# Mariage Spézet 3 E 348 54   1925-1936
	1925   => '1373458',            # Mariage Spézet 3 E 348/54/1 (1925)
	1926   => '1373459',            # Mariage Spézet 3 E 348/54/2 (1926)
	1927   => '1373460',            # Mariage Spézet 3 E 348/54/3 (1927)
	1928   => '1373461',            # Mariage Spézet 3 E 348/54/4 (1928)
	1929   => '1373462',            # Mariage Spézet 3 E 348/54/5 (1929)
	1930   => '1373463',            # Mariage Spézet 3 E 348/54/6 (1930)
	1931   => '1373464',            # Mariage Spézet 3 E 348/54/7 (1931)
	1932   => '1373465',            # Mariage Spézet 3 E 348/54/8 (1932)
	1933   => '1373466',            # Mariage Spézet 3 E 348/54/9 (1933)
	1934   => '1373467',            # Mariage Spézet 3 E 348/54/10 (1934)
	1935   => '1373468',            # Mariage Spézet 3 E 348/54/11 (1935)
	1936   => '1373469',            # Mariage Spézet 3 E 348/54/12 (1936)
    },

    '3E348_0055' => {			# Décès Spézet 3 E 348 55   1908-1915
	1908   => '1373599',            # Décès Spézet 3 E 348/55/1 (1908)
	1909   => '1373600',            # Décès Spézet 3 E 348/55/2 (1909)
	1910   => '1373601',            # Décès Spézet 3 E 348/55/3 (1910)
	1911   => '1373602',            # Décès Spézet 3 E 348/55/4 (1911)
	1912   => '1373603',            # Décès Spézet 3 E 348/55/5 (1912)
	1913   => '1373604',            # Décès Spézet 3 E 348/55/6 (1913)
	1914   => '1373605',            # Décès Spézet 3 E 348/55/7 (1914)
	1915   => '1373606',            # Décès Spézet 3 E 348/55/8 (1915)
    },

    '3E348_0056' => {			# Décès Spézet 3 E 348 56   1916-1923
	1916   => '1373608',            # Décès Spézet 3 E 348/56/1 (1916)
	1917   => '1373609',            # Décès Spézet 3 E 348/56/2 (1917)
	1918   => '1373610',            # Décès Spézet 3 E 348/56/3 (1918)
	1919   => '1373611',            # Décès Spézet 3 E 348/56/4 (1919)
	1920   => '1373612',            # Décès Spézet 3 E 348/56/5 (1920)
	1921   => '1373613',            # Décès Spézet 3 E 348/56/6 (1921)
	1922   => '1373614',            # Décès Spézet 3 E 348/56/7 (1922)
	1923   => '1373615',            # Décès Spézet 3 E 348/56/8 (1923)
    },

    '3E348_0057' => {			# Décès Spézet 3 E 348 57   1924-1936
	1924   => '1373617',            # Décès Spézet 3 E 348/57/1 (1924)
	1925   => '1373618',            # Décès Spézet 3 E 348/57/2 (1925)
	1926   => '1373619',            # Décès Spézet 3 E 348/57/3 (1926)
	1927   => '1373620',            # Décès Spézet 3 E 348/57/4 (1927)
	1928   => '1373621',            # Décès Spézet 3 E 348/57/5 (1928)
	1929   => '1373622',            # Décès Spézet 3 E 348/57/6 (1929)
	1930   => '1373623',            # Décès Spézet 3 E 348/57/7 (1930)
	1931   => '1373624',            # Décès Spézet 3 E 348/57/8 (1931)
	1932   => '1373625',            # Décès Spézet 3 E 348/57/9 (1932)
	1933   => '1373626',            # Décès Spézet 3 E 348/57/10 (1933)
	1934   => '1373627',            # Décès Spézet 3 E 348/57/11 (1934)
	1935   => '1373628',            # Décès Spézet 3 E 348/57/12 (1935)
	1936   => '1373629',            # Décès Spézet 3 E 348/57/13 (1936)
    },

    # NMD Tourc'h
    # https://recherche.archives.finistere.fr/archive/resultats/etatcivil/n:138?REch_commune_Libel=Tourch+%28Finistère%29%7C&REch_commune_Md5=b6713734e42457b28f4773f547444ce7%7C&Rech_typologie%5B0%5D=Naissance&type=etatcivil
    '3E351_0003' => {			# Naissance Tourc'h 3 E 351 3   an II-1812
	'AN02' => '1374309',            # Naissance Tourc'h 3 E 351/3/1 (an II)
	'AN03' => '1374310',            # Naissance Tourc'h 3 E 351/3/2 (an III)
	'AN04' => '1374311',            # Naissance Tourc'h 3 E 351/3/3 (an IV)
	'AN05' => '1374312',            # Naissance Tourc'h 3 E 351/3/4 (an V)
	'AN06' => '1374313',            # Naissance Tourc'h 3 E 351/3/5 (an VI)
	'AN07' => '1374314',            # Naissance Tourc'h 3 E 351/3/6 (an VII)
	'AN08' => '1374315',            # Naissance Tourc'h 3 E 351/3/7 (an VIII)
	'AN09' => '1374316',            # Naissance Tourc'h 3 E 351/3/8 (an IX)
	'AN10' => '1374317',            # Naissance Tourc'h 3 E 351/3/9 (an X)
	'AN11' => '1374318',            # Naissance Tourc'h 3 E 351/3/10 (an XI)
	'AN12' => '1374319',            # Naissance Tourc'h 3 E 351/3/11 (an XII)
	'AN13' => '1374320',            # Naissance Tourc'h 3 E 351/3/12 (an XIII)
	'AN14' => '1374321',            # Naissance Tourc'h 3 E 351/3/13 (an XIV - 1806)
	1807   => '1374322',            # Naissance Tourc'h 3 E 351/3/14 (1807)
	1808   => '1374323',            # Naissance Tourc'h 3 E 351/3/15 (1808)
	1809   => '1374324',            # Naissance Tourc'h 3 E 351/3/16 (1809)
	1810   => '1374325',            # Naissance Tourc'h 3 E 351/3/17 (1810)
	1811   => '1374326',            # Naissance Tourc'h 3 E 351/3/18 (1811)
	1812   => '1374327',            # Naissance Tourc'h 3 E 351/3/19 (1812)
    },

    '3E351_0004' => {			# Naissance Tourc'h 3 E 351 4   1813-1822
	1813   => '1374329',            # Naissance Tourc'h 3 E 351/4/1 (1813)
	1814   => '1374330',            # Naissance Tourc'h 3 E 351/4/2 (1814)
	1815   => '1374331',            # Naissance Tourc'h 3 E 351/4/3 (1815)
	1816   => '1374332',            # Naissance Tourc'h 3 E 351/4/4 (1816)
	1817   => '1374333',            # Naissance Tourc'h 3 E 351/4/5 (1817)
	1818   => '1374334',            # Naissance Tourc'h 3 E 351/4/6 (1818)
	1819   => '1374335',            # Naissance Tourc'h 3 E 351/4/7 (1819)
	1820   => '1374336',            # Naissance Tourc'h 3 E 351/4/8 (1820)
	1821   => '1374337',            # Naissance Tourc'h 3 E 351/4/9 (1821)
	1822   => '1374338',            # Naissance Tourc'h 3 E 351/4/10 (1822)
    },

    '3E351_0005' => {			# Naissance Tourc'h 3 E 351 5   1823-1832
	1823   => '1374340',            # Naissance Tourc'h 3 E 351/5/1 (1823)
	1824   => '1374341',            # Naissance Tourc'h 3 E 351/5/2 (1824)
	1825   => '1374342',            # Naissance Tourc'h 3 E 351/5/3 (1825)
	1826   => '1374343',            # Naissance Tourc'h 3 E 351/5/4 (1826)
	1827   => '1374344',            # Naissance Tourc'h 3 E 351/5/5 (1827)
	1828   => '1374345',            # Naissance Tourc'h 3 E 351/5/6 (1828)
	1829   => '1374346',            # Naissance Tourc'h 3 E 351/5/7 (1829)
	1830   => '1374347',            # Naissance Tourc'h 3 E 351/5/8 (1830)
	1831   => '1374348',            # Naissance Tourc'h 3 E 351/5/9 (1831)
	1832   => '1374349',            # Naissance Tourc'h 3 E 351/5/10 (1832)
    },

    '3E351_0006' => {			# Naissance Tourc'h 3 E 351 6   1833-1842
	1833   => '1374351',            # Naissance Tourc'h 3 E 351/6/1 (1833)
	1834   => '1374352',            # Naissance Tourc'h 3 E 351/6/2 (1834)
	1835   => '1374353',            # Naissance Tourc'h 3 E 351/6/3 (1835)
	1836   => '1374354',            # Naissance Tourc'h 3 E 351/6/4 (1836)
	1837   => '1374355',            # Naissance Tourc'h 3 E 351/6/5 (1837)
	1838   => '1374356',            # Naissance Tourc'h 3 E 351/6/6 (1838)
	1839   => '1374357',            # Naissance Tourc'h 3 E 351/6/7 (1839)
	1840   => '1374358',            # Naissance Tourc'h 3 E 351/6/8 (1840)
	1841   => '1374359',            # Naissance Tourc'h 3 E 351/6/9 (1841)
	1842   => '1374360',            # Naissance Tourc'h 3 E 351/6/10 (1842)
    },

    '3E351_0007' => {			# Naissance Tourc'h 3 E 351 7   1843-1852
	1843   => '1374362',            # Naissance Tourc'h 3 E 351/7/1 (1843)
	1844   => '1374363',            # Naissance Tourc'h 3 E 351/7/2 (1844)
	1845   => '1374364',            # Naissance Tourc'h 3 E 351/7/3 (1845)
	1846   => '1374365',            # Naissance Tourc'h 3 E 351/7/4 (1846)
	1847   => '1374366',            # Naissance Tourc'h 3 E 351/7/5 (1847)
	1848   => '1374367',            # Naissance Tourc'h 3 E 351/7/6 (1848)
	1849   => '1374368',            # Naissance Tourc'h 3 E 351/7/7 (1849)
	1850   => '1374369',            # Naissance Tourc'h 3 E 351/7/8 (1850)
	1851   => '1374370',            # Naissance Tourc'h 3 E 351/7/9 (1851)
	1852   => '1374371',            # Naissance Tourc'h 3 E 351/7/10 (1852)
    },

    '3E351_0008' => {			# Naissance Tourc'h 3 E 351 8   1853-1862
	1853   => '1374373',            # Naissance Tourc'h 3 E 351/8/1 (1853)
	1854   => '1374374',            # Naissance Tourc'h 3 E 351/8/2 (1854)
	1855   => '1374375',            # Naissance Tourc'h 3 E 351/8/3 (1855)
	1856   => '1374376',            # Naissance Tourc'h 3 E 351/8/4 (1856)
	1857   => '1374377',            # Naissance Tourc'h 3 E 351/8/5 (1857)
	1858   => '1374378',            # Naissance Tourc'h 3 E 351/8/6 (1858)
	1859   => '1374379',            # Naissance Tourc'h 3 E 351/8/7 (1859)
	1860   => '1374380',            # Naissance Tourc'h 3 E 351/8/8 (1860)
	1861   => '1374381',            # Naissance Tourc'h 3 E 351/8/9 (1861)
	1862   => '1374382',            # Naissance Tourc'h 3 E 351/8/10 (1862)
    },

    '3E351_0009' => {			# Naissance Tourc'h 3 E 351 9   1863-1869
	1863   => '1374384',            # Naissance Tourc'h 3 E 351/9/1 (1863)
	1864   => '1374385',            # Naissance Tourc'h 3 E 351/9/2 (1864)
	1865   => '1374386',            # Naissance Tourc'h 3 E 351/9/3 (1865)
	1866   => '1374387',            # Naissance Tourc'h 3 E 351/9/4 (1866)
	1867   => '1374388',            # Naissance Tourc'h 3 E 351/9/5 (1867)
	1868   => '1374389',            # Naissance Tourc'h 3 E 351/9/6 (1868)
	1869   => '1374390',            # Naissance Tourc'h 3 E 351/9/7 (1869)
    },

    '3E351_0010' => {			# Naissance Tourc'h 3 E 351 10   1870-1883
	1870   => '1374392',            # Naissance Tourc'h 3 E 351/10/1 (1870)
	1871   => '1374393',            # Naissance Tourc'h 3 E 351/10/2 (1871)
	1872   => '1374394',            # Naissance Tourc'h 3 E 351/10/3 (1872)
	1873   => '1374395',            # Naissance Tourc'h 3 E 351/10/4 (1873)
	1874   => '1374396',            # Naissance Tourc'h 3 E 351/10/5 (1874)
	1875   => '1374397',            # Naissance Tourc'h 3 E 351/10/6 (1875)
	1876   => '1374398',            # Naissance Tourc'h 3 E 351/10/7 (1876)
	1877   => '1374399',            # Naissance Tourc'h 3 E 351/10/8 (1877)
	1878   => '1374400',            # Naissance Tourc'h 3 E 351/10/9 (1878)
	1879   => '1374401',            # Naissance Tourc'h 3 E 351/10/10 (1879)
	1880   => '1374402',            # Naissance Tourc'h 3 E 351/10/11 (1880)
	1881   => '1374403',            # Naissance Tourc'h 3 E 351/10/12 (1881)
	1882   => '1374404',            # Naissance Tourc'h 3 E 351/10/13 (1882)
	1883   => '1374405',            # Naissance Tourc'h 3 E 351/10/14 (1883)
    },

    '3E351_0011' => {			# Mariage publication de mariage promesse de mariage Tourc'h 3 E 351 11   AN02-1793-1812
	'1793-an IV (contient uniquement des publications de mariages)' => '1374467',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/4 (1793-an IV (contient uniquement des publications de mariages))
	'AN02' => '1374464',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/1 (1793 - an II)
	'AN03' => '1374465',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/2 (an III)
	'AN04' => '1374466',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/3 (an IV)
	'AN05' => '1374468',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/5 (an V)
	'AN06' => '1374469',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/6 (an VI (contient également des promesses de mariages))
	'AN07' => '1374470',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/7 (an VII (contient également des promesses de mariages))
	'AN08' => '1374471',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/8 (an VIII (contient également des promesses de mariages))
	'AN09' => '1374472',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/9 (an IX)
	'AN10' => '1374473',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/10 (an X)
	'AN11' => '1374474',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/11 (an XI)
	1807   => '1374478',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/15 (1807)
	1808   => '1374479',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/16 (1808)
	1809   => '1374480',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/17 (1809)
	1810   => '1374481',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/18 (1810)
	1811   => '1374482',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/19 (1811)
	1812   => '1374483',            # Mariage publication de mariage promesse de mariage Tourc'h 3 E 351/11/20 (1812)
    },

    '3E351_0012' => {			# Mariage Tourc'h 3 E 351 12   1813-1822
	1813   => '1374485',            # Mariage Tourc'h 3 E 351/12/1 (1813)
	1814   => '1374486',            # Mariage Tourc'h 3 E 351/12/2 (1814)
	1815   => '1374487',            # Mariage Tourc'h 3 E 351/12/3 (1815)
	1816   => '1374488',            # Mariage Tourc'h 3 E 351/12/4 (1816)
	1817   => '1374489',            # Mariage Tourc'h 3 E 351/12/5 (1817)
	1818   => '1374490',            # Mariage Tourc'h 3 E 351/12/6 (1818)
	1819   => '1374491',            # Mariage Tourc'h 3 E 351/12/7 (1819)
	1820   => '1374492',            # Mariage Tourc'h 3 E 351/12/8 (1820)
	1821   => '1374493',            # Mariage Tourc'h 3 E 351/12/9 (1821)
	1822   => '1374494',            # Mariage Tourc'h 3 E 351/12/10 (1822)
    },

    '3E351_0013' => {			# Mariage Tourc'h 3 E 351 13   1823-1832
	1823   => '1374496',            # Mariage Tourc'h 3 E 351/13/1 (1823)
	1824   => '1374497',            # Mariage Tourc'h 3 E 351/13/2 (1824)
	1825   => '1374498',            # Mariage Tourc'h 3 E 351/13/3 (1825)
	1826   => '1374499',            # Mariage Tourc'h 3 E 351/13/4 (1826)
	1827   => '1374500',            # Mariage Tourc'h 3 E 351/13/5 (1827)
	1828   => '1374501',            # Mariage Tourc'h 3 E 351/13/6 (1828)
	1829   => '1374502',            # Mariage Tourc'h 3 E 351/13/7 (1829)
	1830   => '1374503',            # Mariage Tourc'h 3 E 351/13/8 (1830)
	1831   => '1374504',            # Mariage Tourc'h 3 E 351/13/9 (1831)
	1832   => '1374505',            # Mariage Tourc'h 3 E 351/13/10 (1832)
    },

    '3E351_0014' => {			# Mariage Tourc'h 3 E 351 14   1833-1842
	1833   => '1374507',            # Mariage Tourc'h 3 E 351/14/1 (1833)
	1834   => '1374508',            # Mariage Tourc'h 3 E 351/14/2 (1834)
	1835   => '1374509',            # Mariage Tourc'h 3 E 351/14/3 (1835)
	1836   => '1374510',            # Mariage Tourc'h 3 E 351/14/4 (1836)
	1837   => '1374511',            # Mariage Tourc'h 3 E 351/14/5 (1837)
	1838   => '1374512',            # Mariage Tourc'h 3 E 351/14/6 (1838)
	1839   => '1374513',            # Mariage Tourc'h 3 E 351/14/7 (1839)
	1840   => '1374514',            # Mariage Tourc'h 3 E 351/14/8 (1840)
	1841   => '1374515',            # Mariage Tourc'h 3 E 351/14/9 (1841)
	1842   => '1374516',            # Mariage Tourc'h 3 E 351/14/10 (1842)
    },

    '3E351_0015' => {			# Mariage Tourc'h 3 E 351 15   1843-1852
	1843   => '1374518',            # Mariage Tourc'h 3 E 351/15/1 (1843)
	1844   => '1374519',            # Mariage Tourc'h 3 E 351/15/2 (1844)
	1845   => '1374520',            # Mariage Tourc'h 3 E 351/15/3 (1845)
	1846   => '1374521',            # Mariage Tourc'h 3 E 351/15/4 (1846)
	1847   => '1374522',            # Mariage Tourc'h 3 E 351/15/5 (1847)
	1848   => '1374523',            # Mariage Tourc'h 3 E 351/15/6 (1848)
	1849   => '1374524',            # Mariage Tourc'h 3 E 351/15/7 (1849)
	1850   => '1374525',            # Mariage Tourc'h 3 E 351/15/8 (1850)
	1851   => '1374526',            # Mariage Tourc'h 3 E 351/15/9 (1851)
	1852   => '1374527',            # Mariage Tourc'h 3 E 351/15/10 (1852)
    },

    '3E351_0016' => {			# Mariage Tourc'h 3 E 351 16   1853-1862
	1853   => '1374529',            # Mariage Tourc'h 3 E 351/16/1 (1853)
	1854   => '1374530',            # Mariage Tourc'h 3 E 351/16/2 (1854)
	1855   => '1374531',            # Mariage Tourc'h 3 E 351/16/3 (1855)
	1856   => '1374532',            # Mariage Tourc'h 3 E 351/16/4 (1856)
	1857   => '1374533',            # Mariage Tourc'h 3 E 351/16/5 (1857)
	1858   => '1374534',            # Mariage Tourc'h 3 E 351/16/6 (1858)
	1859   => '1374535',            # Mariage Tourc'h 3 E 351/16/7 (1859)
	1860   => '1374536',            # Mariage Tourc'h 3 E 351/16/8 (1860)
	1861   => '1374537',            # Mariage Tourc'h 3 E 351/16/9 (1861)
	1862   => '1374538',            # Mariage Tourc'h 3 E 351/16/10 (1862)
    },

    '3E351_0017' => {			# Mariage Tourc'h 3 E 351 17   1863-1869
	1863   => '1374540',            # Mariage Tourc'h 3 E 351/17/1 (1863)
	1864   => '1374541',            # Mariage Tourc'h 3 E 351/17/2 (1864)
	1865   => '1374542',            # Mariage Tourc'h 3 E 351/17/3 (1865)
	1866   => '1374543',            # Mariage Tourc'h 3 E 351/17/4 (1866)
	1867   => '1374544',            # Mariage Tourc'h 3 E 351/17/5 (1867)
	1868   => '1374545',            # Mariage Tourc'h 3 E 351/17/6 (1868)
	1869   => '1374546',            # Mariage Tourc'h 3 E 351/17/7 (1869)
    },

    '3E351_0018' => {			# Mariage Tourc'h 3 E 351 18   1870-1889
	1870   => '1374548',            # Mariage Tourc'h 3 E 351/18/1 (1870)
	1871   => '1374549',            # Mariage Tourc'h 3 E 351/18/2 (1871)
	1872   => '1374550',            # Mariage Tourc'h 3 E 351/18/3 (1872)
	1873   => '1374551',            # Mariage Tourc'h 3 E 351/18/4 (1873)
	1874   => '1374552',            # Mariage Tourc'h 3 E 351/18/5 (1874)
	1875   => '1374553',            # Mariage Tourc'h 3 E 351/18/6 (1875)
	1876   => '1374554',            # Mariage Tourc'h 3 E 351/18/7 (1876)
	1877   => '1374555',            # Mariage Tourc'h 3 E 351/18/8 (1877)
	1878   => '1374556',            # Mariage Tourc'h 3 E 351/18/9 (1878)
	1879   => '1374557',            # Mariage Tourc'h 3 E 351/18/10 (1879)
	1880   => '1374558',            # Mariage Tourc'h 3 E 351/18/11 (1880)
	1881   => '1374559',            # Mariage Tourc'h 3 E 351/18/12 (1881)
	1882   => '1374560',            # Mariage Tourc'h 3 E 351/18/13 (1882)
	1883   => '1374561',            # Mariage Tourc'h 3 E 351/18/14 (1883)
	1884   => '1374562',            # Mariage Tourc'h 3 E 351/18/15 (1884)
	1885   => '1374563',            # Mariage Tourc'h 3 E 351/18/16 (1885)
	1886   => '1374564',            # Mariage Tourc'h 3 E 351/18/17 (1886)
	1887   => '1374565',            # Mariage Tourc'h 3 E 351/18/18 (1887)
	1888   => '1374566',            # Mariage Tourc'h 3 E 351/18/19 (1888)
	1889   => '1374567',            # Mariage Tourc'h 3 E 351/18/20 (1889)
    },

    '3E351_0019' => {			# Décès Tourc'h 3 E 351 19   AN02-1812
	'AN02' => '1374620',            # Décès Tourc'h 3 E 351/19/1 (1793 - an II)
	'AN03' => '1374621',            # Décès Tourc'h 3 E 351/19/2 (an III)
	'AN04' => '1374622',            # Décès Tourc'h 3 E 351/19/3 (an IV)
	'AN05' => '1374623',            # Décès Tourc'h 3 E 351/19/4 (an V)
	'AN06' => '1374624',            # Décès Tourc'h 3 E 351/19/5 (an VI)
	'AN07' => '1374625',            # Décès Tourc'h 3 E 351/19/6 (an VII)
	'AN08' => '1374626',            # Décès Tourc'h 3 E 351/19/7 (an VIII)
	'AN09' => '1374627',            # Décès Tourc'h 3 E 351/19/8 (an IX)
	'AN10' => '1374628',            # Décès Tourc'h 3 E 351/19/9 (an X)
	'AN11' => '1374629',            # Décès Tourc'h 3 E 351/19/10 (an XI)
	'AN12' => '1374630',            # Décès Tourc'h 3 E 351/19/11 (an XII)
	'AN13' => '1374631',            # Décès Tourc'h 3 E 351/19/12 (an XIII)
	'AN14' => '1374632',            # Décès Tourc'h 3 E 351/19/13 (an XIV - 1806)
	1807   => '1374633',            # Décès Tourc'h 3 E 351/19/14 (1807)
	1808   => '1374634',            # Décès Tourc'h 3 E 351/19/15 (1808)
	1809   => '1374635',            # Décès Tourc'h 3 E 351/19/16 (1809)
	1810   => '1374636',            # Décès Tourc'h 3 E 351/19/17 (1810)
	1811   => '1374637',            # Décès Tourc'h 3 E 351/19/18 (1811)
	1812   => '1374638',            # Décès Tourc'h 3 E 351/19/19 (1812)
    },

    '3E351_0020' => {			# Décès Tourc'h 3 E 351 20   1813-1822
	1813   => '1374640',            # Décès Tourc'h 3 E 351/20/1 (1813)
	1814   => '1374641',            # Décès Tourc'h 3 E 351/20/2 (1814)
	1815   => '1374642',            # Décès Tourc'h 3 E 351/20/3 (1815)
	1816   => '1374643',            # Décès Tourc'h 3 E 351/20/4 (1816)
	1817   => '1374644',            # Décès Tourc'h 3 E 351/20/5 (1817)
	1818   => '1374645',            # Décès Tourc'h 3 E 351/20/6 (1818)
	1819   => '1374646',            # Décès Tourc'h 3 E 351/20/7 (1819)
	1820   => '1374647',            # Décès Tourc'h 3 E 351/20/8 (1820)
	1821   => '1374648',            # Décès Tourc'h 3 E 351/20/9 (1821)
	1822   => '1374649',            # Décès Tourc'h 3 E 351/20/10 (1822)
    },

    '3E351_0021' => {			# Décès Tourc'h 3 E 351 21   1823-1832
	1823   => '1374651',            # Décès Tourc'h 3 E 351/21/1 (1823)
	1824   => '1374652',            # Décès Tourc'h 3 E 351/21/2 (1824)
	1825   => '1374653',            # Décès Tourc'h 3 E 351/21/3 (1825)
	1826   => '1374654',            # Décès Tourc'h 3 E 351/21/4 (1826)
	1827   => '1374655',            # Décès Tourc'h 3 E 351/21/5 (1827)
	1828   => '1374656',            # Décès Tourc'h 3 E 351/21/6 (1828)
	1829   => '1374657',            # Décès Tourc'h 3 E 351/21/7 (1829)
	1830   => '1374658',            # Décès Tourc'h 3 E 351/21/8 (1830)
	1831   => '1374659',            # Décès Tourc'h 3 E 351/21/9 (1831)
	1832   => '1374660',            # Décès Tourc'h 3 E 351/21/10 (1832)
    },

    '3E351_0022' => {			# Décès Tourc'h 3 E 351 22   1833-1842
	1833   => '1374662',            # Décès Tourc'h 3 E 351/22/1 (1833)
	1834   => '1374663',            # Décès Tourc'h 3 E 351/22/2 (1834)
	1835   => '1374664',            # Décès Tourc'h 3 E 351/22/3 (1835)
	1836   => '1374665',            # Décès Tourc'h 3 E 351/22/4 (1836)
	1837   => '1374666',            # Décès Tourc'h 3 E 351/22/5 (1837)
	1838   => '1374667',            # Décès Tourc'h 3 E 351/22/6 (1838)
	1839   => '1374668',            # Décès Tourc'h 3 E 351/22/7 (1839)
	1840   => '1374669',            # Décès Tourc'h 3 E 351/22/8 (1840)
	1841   => '1374670',            # Décès Tourc'h 3 E 351/22/9 (1841)
	1842   => '1374671',            # Décès Tourc'h 3 E 351/22/10 (1842)
    },

    '3E351_0023' => {			# Décès Tourc'h 3 E 351 23   1843-1852
	1843   => '1374673',            # Décès Tourc'h 3 E 351/23/1 (1843)
	1844   => '1374674',            # Décès Tourc'h 3 E 351/23/2 (1844)
	1845   => '1374675',            # Décès Tourc'h 3 E 351/23/3 (1845)
	1846   => '1374676',            # Décès Tourc'h 3 E 351/23/4 (1846)
	1847   => '1374677',            # Décès Tourc'h 3 E 351/23/5 (1847)
	1848   => '1374678',            # Décès Tourc'h 3 E 351/23/6 (1848)
	1849   => '1374679',            # Décès Tourc'h 3 E 351/23/7 (1849)
	1850   => '1374680',            # Décès Tourc'h 3 E 351/23/8 (1850)
	1851   => '1374681',            # Décès Tourc'h 3 E 351/23/9 (1851)
	1852   => '1374682',            # Décès Tourc'h 3 E 351/23/10 (1852)
    },

    '3E351_0024' => {			# Décès Tourc'h 3 E 351 24   1853-1862
	1853   => '1374684',            # Décès Tourc'h 3 E 351/24/1 (1853)
	1854   => '1374685',            # Décès Tourc'h 3 E 351/24/2 (1854)
	1855   => '1374686',            # Décès Tourc'h 3 E 351/24/3 (1855)
	1856   => '1374687',            # Décès Tourc'h 3 E 351/24/4 (1856)
	1857   => '1374688',            # Décès Tourc'h 3 E 351/24/5 (1857)
	1858   => '1374689',            # Décès Tourc'h 3 E 351/24/6 (1858)
	1859   => '1374690',            # Décès Tourc'h 3 E 351/24/7 (1859)
	1860   => '1374691',            # Décès Tourc'h 3 E 351/24/8 (1860)
	1861   => '1374692',            # Décès Tourc'h 3 E 351/24/9 (1861)
	1862   => '1374693',            # Décès Tourc'h 3 E 351/24/10 (1862)
    },

    '3E351_0025' => {			# Décès Tourc'h 3 E 351 25   1863-1869
	1863   => '1374695',            # Décès Tourc'h 3 E 351/25/1 (1863)
	1864   => '1374696',            # Décès Tourc'h 3 E 351/25/2 (1864)
	1865   => '1374697',            # Décès Tourc'h 3 E 351/25/3 (1865)
	1866   => '1374698',            # Décès Tourc'h 3 E 351/25/4 (1866)
	1867   => '1374699',            # Décès Tourc'h 3 E 351/25/5 (1867)
	1868   => '1374700',            # Décès Tourc'h 3 E 351/25/6 (1868)
	1869   => '1374701',            # Décès Tourc'h 3 E 351/25/7 (1869)
    },

    '3E351_0026' => {			# Décès Tourc'h 3 E 351 26   1870-1889
	1870   => '1374703',            # Décès Tourc'h 3 E 351/26/1 (1870)
	1871   => '1374704',            # Décès Tourc'h 3 E 351/26/2 (1871)
	1872   => '1374705',            # Décès Tourc'h 3 E 351/26/3 (1872)
	1873   => '1374706',            # Décès Tourc'h 3 E 351/26/4 (1873)
	1874   => '1374707',            # Décès Tourc'h 3 E 351/26/5 (1874)
	1875   => '1374708',            # Décès Tourc'h 3 E 351/26/6 (1875)
	1876   => '1374709',            # Décès Tourc'h 3 E 351/26/7 (1876)
	1877   => '1374710',            # Décès Tourc'h 3 E 351/26/8 (1877)
	1878   => '1374711',            # Décès Tourc'h 3 E 351/26/9 (1878)
	1879   => '1374712',            # Décès Tourc'h 3 E 351/26/10 (1879)
	1880   => '1374713',            # Décès Tourc'h 3 E 351/26/11 (1880)
	1881   => '1374714',            # Décès Tourc'h 3 E 351/26/12 (1881)
	1882   => '1374715',            # Décès Tourc'h 3 E 351/26/13 (1882)
	1883   => '1374716',            # Décès Tourc'h 3 E 351/26/14 (1883)
	1884   => '1374717',            # Décès Tourc'h 3 E 351/26/15 (1884)
	1885   => '1374718',            # Décès Tourc'h 3 E 351/26/16 (1885)
	1886   => '1374719',            # Décès Tourc'h 3 E 351/26/17 (1886)
	1887   => '1374720',            # Décès Tourc'h 3 E 351/26/18 (1887)
	1888   => '1374721',            # Décès Tourc'h 3 E 351/26/19 (1888)
	1889   => '1374722',            # Décès Tourc'h 3 E 351/26/20 (1889)
    },

    '3E351_0027' => {			# Naissance Tourc'h 3 E 351 27   1884-1901
	1884   => '1374407',            # Naissance Tourc'h 3 E 351/27/1 (1884)
	1885   => '1374408',            # Naissance Tourc'h 3 E 351/27/2 (1885)
	1886   => '1374409',            # Naissance Tourc'h 3 E 351/27/3 (1886)
	1887   => '1374410',            # Naissance Tourc'h 3 E 351/27/4 (1887)
	1888   => '1374411',            # Naissance Tourc'h 3 E 351/27/5 (1888)
	1889   => '1374412',            # Naissance Tourc'h 3 E 351/27/6 (1889)
	1890   => '1374413',            # Naissance Tourc'h 3 E 351/27/7 (1890)
	1891   => '1374414',            # Naissance Tourc'h 3 E 351/27/8 (1891)
	1892   => '1374415',            # Naissance Tourc'h 3 E 351/27/9 (1892)
	1893   => '1374416',            # Naissance Tourc'h 3 E 351/27/10 (1893)
	1894   => '1374417',            # Naissance Tourc'h 3 E 351/27/11 (1894)
	1895   => '1374418',            # Naissance Tourc'h 3 E 351/27/12 (1895)
	1896   => '1374419',            # Naissance Tourc'h 3 E 351/27/13 (1896)
	1897   => '1374420',            # Naissance Tourc'h 3 E 351/27/14 (1897)
	1898   => '1374421',            # Naissance Tourc'h 3 E 351/27/15 (1898)
	1899   => '1374422',            # Naissance Tourc'h 3 E 351/27/16 (1899)
	1900   => '1374423',            # Naissance Tourc'h 3 E 351/27/17 (1900)
	1901   => '1374424',            # Naissance Tourc'h 3 E 351/27/18 (1901)
    },

    '3E351_0028' => {			# Mariage Tourc'h 3 E 351 28   1890-1908
	1890   => '1374569',            # Mariage Tourc'h 3 E 351/28/1 (1890)
	1891   => '1374570',            # Mariage Tourc'h 3 E 351/28/2 (1891)
	1892   => '1374571',            # Mariage Tourc'h 3 E 351/28/3 (1892)
	1893   => '1374572',            # Mariage Tourc'h 3 E 351/28/4 (1893)
	1894   => '1374573',            # Mariage Tourc'h 3 E 351/28/5 (1894)
	1895   => '1374574',            # Mariage Tourc'h 3 E 351/28/6 (1895)
	1896   => '1374575',            # Mariage Tourc'h 3 E 351/28/7 (1896)
	1897   => '1374576',            # Mariage Tourc'h 3 E 351/28/8 (1897)
	1898   => '1374577',            # Mariage Tourc'h 3 E 351/28/9 (1898)
	1899   => '1374578',            # Mariage Tourc'h 3 E 351/28/10 (1899)
	1900   => '1374579',            # Mariage Tourc'h 3 E 351/28/11 (1900)
	1901   => '1374580',            # Mariage Tourc'h 3 E 351/28/12 (1901)
	1902   => '1374581',            # Mariage Tourc'h 3 E 351/28/13 (1902)
	1903   => '1374582',            # Mariage Tourc'h 3 E 351/28/14 (1903)
	1904   => '1374583',            # Mariage Tourc'h 3 E 351/28/15 (1904)
	1905   => '1374584',            # Mariage Tourc'h 3 E 351/28/16 (1905)
	1906   => '1374585',            # Mariage Tourc'h 3 E 351/28/17 (1906)
	1907   => '1374586',            # Mariage Tourc'h 3 E 351/28/18 (1907)
	1908   => '1374587',            # Mariage Tourc'h 3 E 351/28/19 (1908)
    },

    '3E351_0029' => {			# Décès Tourc'h 3 E 351 29   1890-1913
	1890   => '1374724',            # Décès Tourc'h 3 E 351/29/1 (1890)
	1891   => '1374725',            # Décès Tourc'h 3 E 351/29/2 (1891)
	1892   => '1374726',            # Décès Tourc'h 3 E 351/29/3 (1892)
	1893   => '1374727',            # Décès Tourc'h 3 E 351/29/4 (1893)
	1894   => '1374728',            # Décès Tourc'h 3 E 351/29/5 (1894)
	1895   => '1374729',            # Décès Tourc'h 3 E 351/29/6 (1895)
	1896   => '1374730',            # Décès Tourc'h 3 E 351/29/7 (1896)
	1897   => '1374731',            # Décès Tourc'h 3 E 351/29/8 (1897)
	1898   => '1374732',            # Décès Tourc'h 3 E 351/29/9 (1898)
	1899   => '1374733',            # Décès Tourc'h 3 E 351/29/10 (1899)
	1900   => '1374734',            # Décès Tourc'h 3 E 351/29/11 (1900)
	1901   => '1374735',            # Décès Tourc'h 3 E 351/29/12 (1901)
	1902   => '1374736',            # Décès Tourc'h 3 E 351/29/13 (1902)
	1903   => '1374737',            # Décès Tourc'h 3 E 351/29/14 (1903)
	1904   => '1374738',            # Décès Tourc'h 3 E 351/29/15 (1904)
	1905   => '1374739',            # Décès Tourc'h 3 E 351/29/16 (1905)
	1906   => '1374740',            # Décès Tourc'h 3 E 351/29/17 (1906)
	1907   => '1374741',            # Décès Tourc'h 3 E 351/29/18 (1907)
	1908   => '1374742',            # Décès Tourc'h 3 E 351/29/19 (1908)
	1909   => '1374743',            # Décès Tourc'h 3 E 351/29/20 (1909)
	1910   => '1374744',            # Décès Tourc'h 3 E 351/29/21 (1910)
	1911   => '1374745',            # Décès Tourc'h 3 E 351/29/22 (1911)
	1912   => '1374746',            # Décès Tourc'h 3 E 351/29/23 (1912)
	1913   => '1374747',            # Décès Tourc'h 3 E 351/29/24 (1913)
    },

    '3E351_0030' => {			# Naissance Tourc'h 3 E 351 30   1902-1918
	1902   => '1374426',            # Naissance Tourc'h 3 E 351/30/1 (1902)
	1903   => '1374427',            # Naissance Tourc'h 3 E 351/30/2 (1903)
	1904   => '1374428',            # Naissance Tourc'h 3 E 351/30/3 (1904)
	1905   => '1374429',            # Naissance Tourc'h 3 E 351/30/4 (1905)
	1906   => '1374430',            # Naissance Tourc'h 3 E 351/30/5 (1906)
	1907   => '1374431',            # Naissance Tourc'h 3 E 351/30/6 (1907)
	1908   => '1374432',            # Naissance Tourc'h 3 E 351/30/7 (1908)
	1909   => '1374433',            # Naissance Tourc'h 3 E 351/30/8 (1909)
	1910   => '1374434',            # Naissance Tourc'h 3 E 351/30/9 (1910)
	1911   => '1374435',            # Naissance Tourc'h 3 E 351/30/10 (1911)
	1912   => '1374436',            # Naissance Tourc'h 3 E 351/30/11 (1912)
	1913   => '1374437',            # Naissance Tourc'h 3 E 351/30/12 (1913)
	1914   => '1374438',            # Naissance Tourc'h 3 E 351/30/13 (1914)
	1915   => '1374439',            # Naissance Tourc'h 3 E 351/30/14 (1915)
	1916   => '1374440',            # Naissance Tourc'h 3 E 351/30/15 (1916)
	1917   => '1374441',            # Naissance Tourc'h 3 E 351/30/16 (1917)
	1918   => '1374442',            # Naissance Tourc'h 3 E 351/30/17 (1918)
    },

    '3E351_0031' => {			# Naissance Tourc'h 3 E 351 31   1919-1925
	1919   => '1374444',            # Naissance Tourc'h 3 E 351/31/1 (1919)
	1920   => '1374445',            # Naissance Tourc'h 3 E 351/31/2 (1920)
	1921   => '1374446',            # Naissance Tourc'h 3 E 351/31/3 (1921)
	1922   => '1374447',            # Naissance Tourc'h 3 E 351/31/4 (1922)
	1923   => '1374448',            # Naissance Tourc'h 3 E 351/31/5 (1923)
	1924   => '1374449',            # Naissance Tourc'h 3 E 351/31/6 (1924)
	1925   => '1374450',            # Naissance Tourc'h 3 E 351/31/7 (1925)
    },

    '3E351_0032' => {			# Mariage Tourc'h 3 E 351 32   1909-1921
	1909   => '1374589',            # Mariage Tourc'h 3 E 351/32/1 (1909)
	1910   => '1374590',            # Mariage Tourc'h 3 E 351/32/2 (1910)
	1911   => '1374591',            # Mariage Tourc'h 3 E 351/32/3 (1911)
	1912   => '1374592',            # Mariage Tourc'h 3 E 351/32/4 (1912)
	1913   => '1374593',            # Mariage Tourc'h 3 E 351/32/5 (1913)
	1914   => '1374594',            # Mariage Tourc'h 3 E 351/32/6 (1914)
	1915   => '1374595',            # Mariage Tourc'h 3 E 351/32/7 (1915)
	1916   => '1374596',            # Mariage Tourc'h 3 E 351/32/8 (1916)
	1917   => '1374597',            # Mariage Tourc'h 3 E 351/32/9 (1917)
	1918   => '1374598',            # Mariage Tourc'h 3 E 351/32/10 (1918)
	1919   => '1374599',            # Mariage Tourc'h 3 E 351/32/11 (1919)
	1920   => '1374600',            # Mariage Tourc'h 3 E 351/32/12 (1920)
	1921   => '1374601',            # Mariage Tourc'h 3 E 351/32/13 (1921)
    },

    '3E351_0033' => {			# Mariage Tourc'h 3 E 351 33   1922-1936
	1922   => '1374603',            # Mariage Tourc'h 3 E 351/33/1 (1922)
	1923   => '1374604',            # Mariage Tourc'h 3 E 351/33/2 (1923)
	1924   => '1374605',            # Mariage Tourc'h 3 E 351/33/3 (1924)
	1925   => '1374606',            # Mariage Tourc'h 3 E 351/33/4 (1925)
	1926   => '1374607',            # Mariage Tourc'h 3 E 351/33/5 (1926)
	1927   => '1374608',            # Mariage Tourc'h 3 E 351/33/6 (1927)
	1928   => '1374609',            # Mariage Tourc'h 3 E 351/33/7 (1928)
	1929   => '1374610',            # Mariage Tourc'h 3 E 351/33/8 (1929)
	1930   => '1374611',            # Mariage Tourc'h 3 E 351/33/9 (1930)
	1931   => '1374612',            # Mariage Tourc'h 3 E 351/33/10 (1931)
	1932   => '1374613',            # Mariage Tourc'h 3 E 351/33/11 (1932)
	1933   => '1374614',            # Mariage Tourc'h 3 E 351/33/12 (1933)
	1934   => '1374615',            # Mariage Tourc'h 3 E 351/33/13 (1934)
	1935   => '1374616',            # Mariage Tourc'h 3 E 351/33/14 (1935)
	1936   => '1374617',            # Mariage Tourc'h 3 E 351/33/15 (1936)
    },

    '3E351_0034' => {			# Décès Tourc'h 3 E 351 34   1914-1936
	1914   => '1374749',            # Décès Tourc'h 3 E 351/34/1 (1914)
	1915   => '1374750',            # Décès Tourc'h 3 E 351/34/2 (1915)
	1916   => '1374751',            # Décès Tourc'h 3 E 351/34/3 (1916)
	1917   => '1374752',            # Décès Tourc'h 3 E 351/34/4 (1917)
	1918   => '1374753',            # Décès Tourc'h 3 E 351/34/5 (1918)
	1919   => '1374754',            # Décès Tourc'h 3 E 351/34/6 (1919)
	1920   => '1374755',            # Décès Tourc'h 3 E 351/34/7 (1920)
	1921   => '1374756',            # Décès Tourc'h 3 E 351/34/8 (1921)
	1922   => '1374757',            # Décès Tourc'h 3 E 351/34/9 (1922)
	1923   => '1374758',            # Décès Tourc'h 3 E 351/34/10 (1923)
	1924   => '1374759',            # Décès Tourc'h 3 E 351/34/11 (1924)
	1925   => '1374760',            # Décès Tourc'h 3 E 351/34/12 (1925)
	1926   => '1374761',            # Décès Tourc'h 3 E 351/34/13 (1926)
	1927   => '1374762',            # Décès Tourc'h 3 E 351/34/14 (1927)
	1928   => '1374763',            # Décès Tourc'h 3 E 351/34/15 (1928)
	1929   => '1374764',            # Décès Tourc'h 3 E 351/34/16 (1929)
	1930   => '1374765',            # Décès Tourc'h 3 E 351/34/17 (1930)
	1931   => '1374766',            # Décès Tourc'h 3 E 351/34/18 (1931)
	1932   => '1374767',            # Décès Tourc'h 3 E 351/34/19 (1932)
	1933   => '1374768',            # Décès Tourc'h 3 E 351/34/20 (1933)
	1934   => '1374769',            # Décès Tourc'h 3 E 351/34/21 (1934)
	1935   => '1374770',            # Décès Tourc'h 3 E 351/34/22 (1935)
	1936   => '1374771',            # Décès Tourc'h 3 E 351/34/23 (1936)
    },

    # Tables décennales :
    # TD Carhaix
    '5E_0026_001_01' => '1129355',            # Table décennale Carhaix 5 E 26/1/1 (An XI-1812)
    '5E_0026_001_02' => '1129356',            # Table décennale Carhaix 5 E 26/1/2 (1813-1822)
    '5E_0026_001_03' => '1129357',            # Table décennale Carhaix 5 E 26/1/3 (1823-1832)
    '5E_0026_001_04' => '1129358',            # Table décennale Carhaix 5 E 26/1/4 (1833-1842)
    '5E_0026_001_05' => '1129359',            # Table décennale Carhaix 5 E 26/1/5 (1843-1852)
    '5E_0026_001_06' => '1129360',            # Table décennale Carhaix 5 E 26/1/6 (1853-1862)
    '5E_0026_001_07' => '1129361',            # Table décennale Carhaix 5 E 26/1/7 (1863-1872)
    '5E_0026_002_01' => '1129363',            # Table décennale Carhaix 5 E 26/2/1 (1873-1882)
    '5E_0026_002_02' => '1129364',            # Table décennale Carhaix 5 E 26/2/2 (1883-1892)
    '5E_0026_002_03' => '1129365',            # Table décennale Carhaix 5 E 26/2/3 (1893-1902)
    '5E_0026_002_04' => '1129366',            # Table décennale Carhaix 5 E 26/2/4 (1903-1912)
    '5E_0026_002_05' => '1129367',            # Table décennale Carhaix 5 E 26/2/5 (1913-1922)
    '5E_0026_002_06' => '1129368',            # Table décennale Carhaix 5 E 26/2/6 (1923-1932)
    '5E_0026_003_01' => '1129370',            # Table décennale Carhaix 5 E 26/3/1 (1933-1942)
    '5E_0026_003_02' => '1129371',            # Table décennale Carhaix 5 E 26/3/2 (1943-1952)
    '5E_0026_003_03' => '1129372',            # Table décennale Carhaix 5 E 26/3/3 (1953-1962)
    '5E_0026_003_04' => '1129373',            # Table décennale Carhaix 5 E 26/3/4 (1963-1972)

    # TD Kergloff
    # https://recherche.archives.finistere.fr/archive/resultats/etatcivil/tableau?REch_commune_Libel=Kergloff+%28Finistère%29%7C&REch_commune_Md5=b514c4417f09b16bf87e6d3adcf13473%7C&Rech_typologie%5B0%5D=Table+d%C3%A9cennale&type=etatcivil
    '5E_0092_001_01' => '1130521',            # Table décennale Kergloff 5 E 92/1/1 (An XI-1812)
    '5E_0092_001_02' => '1130522',            # Table décennale Kergloff 5 E 92/1/2 (1813-1822)
    '5E_0092_001_03' => '1130523',            # Table décennale Kergloff 5 E 92/1/3 (1823-1832)
    '5E_0092_001_04' => '1130524',            # Table décennale Kergloff 5 E 92/1/4 (1833-1842)
    '5E_0092_001_05' => '1130525',            # Table décennale Kergloff 5 E 92/1/5 (1843-1852)
    '5E_0092_001_06' => '1130526',            # Table décennale Kergloff 5 E 92/1/6 (1853-1862)
    '5E_0092_001_07' => '1130527',            # Table décennale Kergloff 5 E 92/1/7 (1863-1872)
    '5E_0092_002_01' => '1130529',            # Table décennale Kergloff 5 E 92/2/1 (1873-1882)
    '5E_0092_002_02' => '1130530',            # Table décennale Kergloff 5 E 92/2/2 (1883-1892)
    '5E_0092_002_03' => '1130531',            # Table décennale Kergloff 5 E 92/2/3 (1893-1902)
    '5E_0092_003_01' => '1130533',            # Table décennale Kergloff 5 E 92/3/1 (1903-1912)
    '5E_0092_003_02' => '1130534',            # Table décennale Kergloff 5 E 92/3/2 (1913-1922)
    '5E_0092_003_03' => '1130535',            # Table décennale Kergloff 5 E 92/3/3 (1923-1932)
    '5E_0092_004_01' => '1130537',            # Table décennale Kergloff 5 E 92/4/1 (1933-1942)
    '5E_0092_004_02' => '1130538',            # Table décennale Kergloff 5 E 92/4/2 (1943-1952)
    '5E_0092_004_03' => '1130539',            # Table décennale Kergloff 5 E 92/4/3 (1953-1962)
    '5E_0092_004_04' => '1130540',            # Table décennale Kergloff 5 E 92/4/4 (1963-1972)

    # TD Kernével
    '5E_0095_001_01' => '1130566',            # Table décennale Kernével 5 E 95/1/1 (An XI-1812)
    '5E_0095_001_02' => '1130567',            # Table décennale Kernével 5 E 95/1/2 (1813-1822)
    '5E_0095_001_03' => '1130568',            # Table décennale Kernével 5 E 95/1/3 (1823-1832)
    '5E_0095_001_04' => '1130569',            # Table décennale Kernével 5 E 95/1/4 (1833-1842)
    '5E_0095_001_05' => '1130570',            # Table décennale Kernével 5 E 95/1/5 (1843-1852)
    '5E_0095_001_06' => '1130571',            # Table décennale Kernével 5 E 95/1/6 (1853-1862)
    '5E_0095_001_07' => '1130572',            # Table décennale Kernével 5 E 95/1/7 (1863-1872)
    '5E_0095_002_01' => '1130574',            # Table décennale Kernével 5 E 95/2/1 (1873-1882)
    '5E_0095_002_02' => '1130575',            # Table décennale Kernével 5 E 95/2/2 (1883-1892)
    '5E_0095_002_03' => '1130576',            # Table décennale Kernével 5 E 95/2/3 (1893-1902)
    '5E_0095_002_04' => '1130577',            # Table décennale Kernével 5 E 95/2/4 (1903-1912)
    '5E_0095_002_05' => '1130578',            # Table décennale Kernével 5 E 95/2/5 (1913-1922)
    '5E_0095_002_06' => '1130579',            # Table décennale Kernével 5 E 95/2/6 (1923-1932)
    '5E_0095_002_07' => '1130580',            # Table décennale Kernével 5 E 95/2/7 (1933-1942)
    '5E_0095_002_08' => '1130581',            # Table décennale Kernével 5 E 95/2/8 (1943-1952)
    '5E_0095_002_09' => '1130582',            # Table décennale Kernével 5 E 95/2/9 (1953-1962)
    '5E_0095_002_10' => '1130583',            # Table décennale Kernével 5 E 95/2/10 (1963-1972)

    # TD Motreff
    '5E_0157_001_01' => '1131615',            # Table décennale Motreff 5 E 157/1/1 (An XI-1812)
    '5E_0157_001_02' => '1131616',            # Table décennale Motreff 5 E 157/1/2 (1813-1822)
    '5E_0157_001_03' => '1131617',            # Table décennale Motreff 5 E 157/1/3 (1823-1832)
    '5E_0157_001_04' => '1131618',            # Table décennale Motreff 5 E 157/1/4 (1833-1842)
    '5E_0157_001_05' => '1131619',            # Table décennale Motreff 5 E 157/1/5 (1843-1852)
    '5E_0157_001_06' => '1131620',            # Table décennale Motreff 5 E 157/1/6 (1853-1862)
    '5E_0157_001_07' => '1131621',            # Table décennale Motreff 5 E 157/1/7 (1863-1872)
    '5E_0157_002_01' => '1131623',            # Table décennale Motreff 5 E 157/2/1 (1873-1882)
    '5E_0157_002_02' => '1131624',            # Table décennale Motreff 5 E 157/2/2 (1883-1892)
    '5E_0157_002_03' => '1131625',            # Table décennale Motreff 5 E 157/2/3 (1893-1902)
    '5E_0157_003_01' => '1131627',            # Table décennale Motreff 5 E 157/3/1 (1903-1912)
    '5E_0157_003_02' => '1131628',            # Table décennale Motreff 5 E 157/3/2 (1913-1922)
    '5E_0157_003_03' => '1131629',            # Table décennale Motreff 5 E 157/3/3 (1923-1932)
    '5E_0157_004_01' => '1131631',            # Table décennale Motreff 5 E 157/4/1 (1933-1942)
    '5E_0157_004_02' => '1131632',            # Table décennale Motreff 5 E 157/4/2 (1943-1952)
    '5E_0157_004_03' => '1131633',            # Table décennale Motreff 5 E 157/4/3 (1953-1962)
    '5E_0157_004_04' => '1131634',            # Table décennale Motreff 5 E 157/4/4 (1963-1972)

    # TD Plouguer
    '5E_0200_001_01' => '1132300',            # Table décennale Plouguer 5 E 200/1/1 (An XI-1812)
    '5E_0200_001_02' => '1132301',            # Table décennale Plouguer 5 E 200/1/2 (1813-1822)
    '5E_0200_001_03' => '1132302',            # Table décennale Plouguer 5 E 200/1/3 (1823-1832)
    '5E_0200_001_04' => '1132303',            # Table décennale Plouguer 5 E 200/1/4 (1833-1842)
    '5E_0200_001_05' => '1132304',            # Table décennale Plouguer 5 E 200/1/5 (1843-1852)
    '5E_0200_001_06' => '1132305',            # Table décennale Plouguer 5 E 200/1/6 (1853-1862)
    '5E_0200_001_07' => '1132306',            # Table décennale Plouguer 5 E 200/1/7 (1863-1872)
    '5E_0200_002_01' => '1132308',            # Table décennale Plouguer 5 E 200/2/1 (1873-1882)
    '5E_0200_002_02' => '1132309',            # Table décennale Plouguer 5 E 200/2/2 (1883-1892)
    '5E_0200_002_03' => '1132310',            # Table décennale Plouguer 5 E 200/2/3 (1893-1902)
    '5E_0200_002_04' => '1132311',            # Table décennale Plouguer 5 E 200/2/4 (1903-1912)
    '5E_0200_002_05' => '1132312',            # Table décennale Plouguer 5 E 200/2/5 (1913-1922)
    '5E_0200_002_06' => '1132313',            # Table décennale Plouguer 5 E 200/2/6 (1923-1932)
    '5E_0200_002_07' => '1132314',            # Table décennale Plouguer 5 E 200/2/7 (1933-1942)
    '5E_0200_002_08' => '1132315',            # Table décennale Plouguer 5 E 200/2/8 (1943-1952)

    # TD Saint-Hernin
    '5E_0258_001_01' => '1133266',            # Table décennale Saint-Hernin 5 E 258/1/1 (An XI-1812)
    '5E_0258_001_02' => '1133267',            # Table décennale Saint-Hernin 5 E 258/1/2 (1813-1822)
    '5E_0258_001_03' => '1133268',            # Table décennale Saint-Hernin 5 E 258/1/3 (1823-1832)
    '5E_0258_001_04' => '1133269',            # Table décennale Saint-Hernin 5 E 258/1/4 (1833-1842)
    '5E_0258_001_05' => '1133270',            # Table décennale Saint-Hernin 5 E 258/1/5 (1843-1852)
    '5E_0258_001_06' => '1133271',            # Table décennale Saint-Hernin 5 E 258/1/6 (1853-1862)
    '5E_0258_001_07' => '1133272',            # Table décennale Saint-Hernin 5 E 258/1/7 (1863-1872)
    '5E_0258_001_08' => '1133273',            # Table décennale Saint-Hernin 5 E 258/1/8 (1873-1882)
    '5E_0258_001_09' => '1133274',            # Table décennale Saint-Hernin 5 E 258/1/9 (1883-1892)
    '5E_0258_001_10' => '1133275',            # Table décennale Saint-Hernin 5 E 258/1/10 (1893-1902)
    '5E_0258_002_01' => '1133277',            # Table décennale Saint-Hernin 5 E 258/2/1 (1903-1912)
    '5E_0258_002_02' => '1133278',            # Table décennale Saint-Hernin 5 E 258/2/2 (1913-1922)
    '5E_0258_002_03' => '1133279',            # Table décennale Saint-Hernin 5 E 258/2/3 (1923-1932)
    '5E_0258_003_01' => '1133281',            # Table décennale Saint-Hernin 5 E 258/3/1 (1933-1942)
    '5E_0258_003_02' => '1133282',            # Table décennale Saint-Hernin 5 E 258/3/2 (1943-1952)
    '5E_0258_003_03' => '1133283',            # Table décennale Saint-Hernin 5 E 258/3/3 (1953-1962)
    '5E_0258_003_04' => '1133284',            # Table décennale Saint-Hernin 5 E 258/3/4 (1963-1972)

    # TD Scaër
    '5E_0283_001_01' => '1133694',            # Table décennale Scaër 5 E 283/1/1 (An XI-1812)
    '5E_0283_001_02' => '1133695',            # Table décennale Scaër 5 E 283/1/2 (1813-1822)
    '5E_0283_001_03' => '1133696',            # Table décennale Scaër 5 E 283/1/3 (1823-1832)
    '5E_0283_001_04' => '1133697',            # Table décennale Scaër 5 E 283/1/4 (1833-1842)
    '5E_0283_001_05' => '1133698',            # Table décennale Scaër 5 E 283/1/5 (1843-1852)
    '5E_0283_001_06' => '1133699',            # Table décennale Scaër 5 E 283/1/6 (1853-1862)
    '5E_0283_001_07' => '1133700',            # Table décennale Scaër 5 E 283/1/7 (1863-1872)
    '5E_0283_001_08' => '1133701',            # Table décennale Scaër 5 E 283/1/8 (1873-1882)
    '5E_0283_001_09' => '1133702',            # Table décennale Scaër 5 E 283/1/9 (1883-1892)
    '5E_0283_001_10' => '1133703',            # Table décennale Scaër 5 E 283/1/10 (1893-1902)
    '5E_0283_002_00' => '1044844.1133704',    # Table décennale Scaër 5 E 283 2 (1903-1912)
    '5E_0283_003_01' => '1133706',            # Table décennale Scaër 5 E 283/3/1 (1913-1922)
    '5E_0283_003_02' => '1133707',            # Table décennale Scaër 5 E 283/3/2 (1923-1932)
    '5E_0283_004_01' => '1133709',            # Table décennale Scaër 5 E 283/4/1 (1933-1942)
    '5E_0283_004_02' => '1133710',            # Table décennale Scaër 5 E 283/4/2 (1943-1952)
    '5E_0283_004_03' => '1133711',            # Table décennale Scaër 5 E 283/4/3 (1953-1962)

    # TD Spezet
    '5E_0287_001_01' => '1133783',            # Table décennale Spézet 5 E 287/1/1 (An XI-1812)
    '5E_0287_001_02' => '1133784',            # Table décennale Spézet 5 E 287/1/2 (1813-1822)
    '5E_0287_001_03' => '1133785',            # Table décennale Spézet 5 E 287/1/3 (1823-1832)
    '5E_0287_001_04' => '1133786',            # Table décennale Spézet 5 E 287/1/4 (1833-1842)
    '5E_0287_001_05' => '1133787',            # Table décennale Spézet 5 E 287/1/5 (1843-1852)
    '5E_0287_001_06' => '1133788',            # Table décennale Spézet 5 E 287/1/6 (1853-1862)
    '5E_0287_001_07' => '1133789',            # Table décennale Spézet 5 E 287/1/7 (1863-1872)
    '5E_0287_002_01' => '1133791',            # Table décennale Spézet 5 E 287/2/1 (1873-1882)
    '5E_0287_002_02' => '1133792',            # Table décennale Spézet 5 E 287/2/2 (1883-1892)
    '5E_0287_002_03' => '1133793',            # Table décennale Spézet 5 E 287/2/3 (1893-1902)
    '5E_0287_002_04' => '1133794',            # Table décennale Spézet 5 E 287/2/4 (1903-1912)
    '5E_0287_002_05' => '1133795',            # Table décennale Spézet 5 E 287/2/5 (1913-1922)
    '5E_0287_002_06' => '1133796',            # Table décennale Spézet 5 E 287/2/6 (1923-1932)
    '5E_0287_002_07' => '1133797',            # Table décennale Spézet 5 E 287/2/7 (1933-1942)
    '5E_0287_002_08' => '1133798',            # Table décennale Spézet 5 E 287/2/8 (1943-1952)
    '5E_0287_002_09' => '1133799',            # Table décennale Spézet 5 E 287/2/9 (1953-1962)
    '5E_0287_002_10' => '1133800',            # Table décennale Spézet 5 E 287/2/10 (1963-1972)

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

    # https://recherche.archives.finistere.fr/archives/archives/fonds/FRAD029_W_Enregistrement/view:fonds
    # Tables des successions:
    #========================
    # TDS Châteaulin
    '2023W_176' => '965723.1515189',     # TDS bureau de Châteaulin Volume n°26 | 1939-1947
    '2023W_177' => '965723.1515190',     # TDS bureau de Châteaulin Volume n°27 | 1947-1955
    '2023W_178' => '965723.1515191',     # TDS bureau de Châteaulin Volume n°27 | 1956-1963
    '2023W_179' => '965723.1515192',     # TDS bureau de Châteaulin Volume n°28 | 1963-1967
    # TDS Châteauneuf-du-Faou
    '1580W_004' => '965730.1515255',     # TDS bureau de Châteauneuf-du-Faou Volume n°29 | 1946-1954
    '1580W_005' => '965730.1515256',     # TDS bureau de Châteauneuf-du-Faou Volume n°30 | 1955-1960
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
	#some URLs are KO b/c of missing "img=", eg: https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/03E/3E106/3E106_0011?s=FRAD029_3E106_0011_00M_AN10_001.jpg&e=FRAD029_3E106_0011_00M_AN10_010.jpg&img=FRAD029_3E106_0011_00M_AN10_006.jpg (vue 6/10/)
	# => I think I badly pasted the URL or wrongly tried to shortenize it => I've the view number so just add img= as e= but replacing the view nb: img=FRAD029_3E106_0011_00M_AN10_006.jpg
	($id,$image) = m![^/]*/([^/?]*)\?.*(img=.*)\.jpg!;
    }
    # for new URL scheme:
    $image =~ s/img=/img:/;
    # Looks like *some* communal collections have simplified ID (eg: 1237EDEPOT_003 => 1237EDEPOT):
    $id =~ s/_00[0-9]$// if /EDEPOT_00/ && !/(1003|1008|1024|1164|1267)EDEPOT/;
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
