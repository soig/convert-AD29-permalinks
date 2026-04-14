# convert-AD29-permalinks

## Présentation

Convert old permalinks to new permalinks after upstream software change
Convertit les anciens permaliens (avant avril 2026) en nouveaux permaliens.
Les AD 29 ont changé de logiciel en avril 2026, ce qui a cassé tous les anciens permaliens.

Par exemple, un acte d'avril 1764 à Plouguer avait autrefois pour permalien :
* https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/03E/3E234/3E234_0004?img=FRAD029_1MIEC234_06_0052.jpg

Maintenant, c'est au choix :
* https://recherche.archives.finistere.fr/ark:/72506/659573.1340592/daoloc/0/48 (avec le numéro de vue, ici 48/207, comme le font les AD56 avec le même logiciel)
* https://recherche.archives.finistere.fr/ark:/72506/659573.1340592/img:FRAD029_1MIEC234_06_0052 (avec le numéro/nom de l'image, c'est ce que donne le bouton "permalien")

Ce script génère la 2e URL à partir de l'ancien permalien car :
* c'est plus logique, on obtient la même URL qu'avec le bouton "permalien"
* il est impossible de générer la 1e URL car il manque le numéro de vue

## Examples :

Tables décennales de Quimperlé 1933-1972 :
* Après : https://recherche.archives.finistere.fr/ark:/72506/1132985/img:FRAD029_5E_0241_006_03_000238
* Avant : https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/05E/5E_0241_006_03/?img=FRAD029_5E_0241_006_03_000238.jpg

Tables décennales de Spézet 1873-1972 :
* https://recherche.archives.finistere.fr/ark:/72506/1133798/img:FRAD029_5E_0287_002_08_000036
* https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/05E/5E_0287_002_08/?img=FRAD029_5E_0287_002_08_000036.jpg

Tables décennales de Scaër An XI-1902 :
* https://recherche.archives.finistere.fr/ark:/72506/1133694/img:FRAD029_5E_0283_001_01_000036
* https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/05E/5E_0283_001_01/?img=FRAD029_5E_0283_001_01_000036.jpg

Sépultures de Saint-Hernin de 1753-1792 :
* https://recherche.archives.finistere.fr/ark:/72506/1040259.1634656/img:FRAD029_3E309_05_0264
* https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/03E/3E309/3E309_0005?img=FRAD029_3E309_05_0264.jpg

Exemples avec la collection communale :
* https://recherche.archives.finistere.fr/ark:/72506/645578.1478934/img:FRAD029_1237EDEPOT_03_0118
* https://recherche.archives.finistere.fr/viewer/series/medias/collections/EDEPOT/1237EDEPOT/1237EDEPOT_003?img=FRAD029_1237EDEPOT_03_0118.jpg

Exemples avec un registre qui avait été découpé par an (URL plus compliquées avant 2026) :
* https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/03E/3E348/3E348_0050?s=FRAD029_3E348_0050_00N_1924_001.jpg&e=FRAD029_3E348_0050_00N_1924_028.jpg&img=FRAD029_3E348_0050_00N_1924_007.jpg&levelDescription=FRAD029_00003E348_pa-1203
* https://recherche.archives.finistere.fr/ark:/72506/1373301/img:FRAD029_3E348_0050_00N_1924_007
