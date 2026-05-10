# convert-AD29-permalinks

## Présentation

Convert old permalinks to new permalinks after upstream software change
Convertit les anciens permaliens (avant avril 2026) en nouveaux permaliens.
Les AD 29 ont changé de logiciel en avril 2026, ce qui a cassé tous les anciens permaliens :
* https://archives.finistere.fr/actualites/nouveau-moteur-de-recherche-en-ligne

Par exemple, un acte d'avril 1764 à Plouguer avait autrefois pour permalien :
* https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/03E/3E234/3E234_0004?img=FRAD029_1MIEC234_06_0052.jpg

Maintenant, c'est au choix :
* https://recherche.archives.finistere.fr/ark:/72506/659573.1340592/daoloc/0/48 (avec le numéro de vue, ici 48/207, comme le font les AD56 avec le même logiciel)
* https://recherche.archives.finistere.fr/ark:/72506/659573.1340592/img:FRAD029_1MIEC234_06_0052 (avec le numéro/nom de l'image, c'est ce que donne le bouton "permalien")

Ce script génère la 2e URL à partir de l'ancien permalien car :
* c'est plus logique, on obtient la même URL qu'avec le bouton "permalien"
* il est impossible de générer la 1e URL car il manque le numéro de vue

## Limitations :

Lors du passage au nouveau site, ils se sont rendu comptes que certains registres étaient mal côtés. Ces registres ont donc été renommés et re-côtés.
```
"Lors de la préparation de la migration vers notre nouveau moteur de recherche, nous nous sommes aperçus qu’il y avait une erreur d’affectation de certains lots numérisés pour Carhaix et Morlaix.
Une partie de ces lots avaient été microfilmés, il y a longtemps, à partir d’originaux empruntés en mairie.
Lors de la numérisation de ces microfilms, et leur publication en 2022, cette information avait été omise, et les lots correspondants avaient été raccrochés, à tort, aux collections départementales « 3 E » deces deux communes.
Ceci explique pourquoi vous ne retrouvez pas en cotation « 3 E » certains lots de Carhaix. Il faut regarder côté collection communale « E Dépôt », aux dates équivalentes.
Et même chose pour Morlaix, donc."
```
Il vous faudra donc manuellement corriger la côte du registre source.

De plus, deux lots d'images ont souvent été agglomérés.
Les registres qui m'intéressent étaient dans le 1er lot mais à tester d'anciens permaliens sur le 2e lot. Les liens sont probablement bons mais à vérifier.
Dans tous les cas le numéro de vue est à corriger (par ex: la vue "187/201" devient "187/431")

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

Recensement Spézet 1936 :
* https://recherche.archives.finistere.fr/ark:/72506/1145865/img:FRAD029_6M_0833_06_000034
* https://recherche.archives.finistere.fr/viewer/series/medias/collections/M/06M/6M05/6M0833?s=FRAD029_6M_0833_06_000001.jpg&e=FRAD029_6M_0833_06_000062.jpg&img=FRAD029_6M_0833_06_000034.jpg&levelDescription=FRAD029_00000006M_pa-5362

Registre matricule :
* https://recherche.archives.finistere.fr/ark:/72506/836111.1076438/img:FRAD029_1R_01653_0291
* https://recherche.archives.finistere.fr/viewer/series/medias/collections/R/01R/1R01653?img=FRAD029_1R_01653_0291.jpg

Sépultures de Saint-Hernin de 1753-1792 :
* https://recherche.archives.finistere.fr/ark:/72506/1040259.1634656/img:FRAD029_3E309_05_0264
* https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/03E/3E309/3E309_0005?img=FRAD029_3E309_05_0264.jpg

Naissances calendrier républicain :
* https://recherche.archives.finistere.fr/ark:/72506/1373156/img:FRAD029_3E348_0012_00N_AN02_003
* https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/03E/3E348/3E348_0012?s=FRAD029_3E348_0012_00N_AN02_001.jpg&e=FRAD029_3E348_0012_00N_AN02_029.jpg&img=FRAD029_3E348_0012_00N_AN02_003.jpg&levelDescription=FRAD029_00003E348_pa-851

Exemples avec la collection communale : Sépultures de Saint-Hernin 1753-1787 :
* https://recherche.archives.finistere.fr/ark:/72506/645578.1478934/img:FRAD029_1237EDEPOT_03_0118
* https://recherche.archives.finistere.fr/viewer/series/medias/collections/EDEPOT/1237EDEPOT/1237EDEPOT_003?img=FRAD029_1237EDEPOT_03_0118.jpg

Exemples avec un registre qui avait été découpé par an (URL plus compliquées avant 2026) :
* https://recherche.archives.finistere.fr/ark:/72506/1373301/img:FRAD029_3E348_0050_00N_1924_007
* https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/03E/3E348/3E348_0050?s=FRAD029_3E348_0050_00N_1924_001.jpg&e=FRAD029_3E348_0050_00N_1924_028.jpg&img=FRAD029_3E348_0050_00N_1924_007.jpg&levelDescription=FRAD029_00003E348_pa-1203
