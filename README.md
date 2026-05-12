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

## Utilisations :

### Conversion au cas par cas

```
./convert-finistere.pl "https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/05E/5E_0241_006_03/?img=FRAD029_5E_0241_006_03_000238.jpg"
<<OLD URL: 'https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/05E/5E_0241_006_03/?img=FRAD029_5E_0241_006_03_000238.jpg'
>>NEW_URL=
https://recherche.archives.finistere.fr/ark:/72506/1132985/img:FRAD029_5E_0241_006_03_000238
```

Il suffit de remplacer manuellement l'ancienne URL par la nouvelle dans votre logiciel de généalogie.

### Conversion d'un fichier gramps

Je prends l'exemple de Gramps car c'est le logiciel que j'utilise, mais le principe est le même si vous avez un format texte sur lequel travailler.

Il faut d'abord sauvegarder sa base au format gramps (ce qui est fait également automatiquement quand on quitte Gramps).
Puis décompresser le fichier .gramps (qui est en fait compressé au format gzip) et lancer le convertisseur dessus :

```
zcat 'ma famille-2026-05-09-15-58-47.gramps' > G.gramps
./convert-finistere.pl G.gramps
```

Il suffit ensuite de réimporter le fichier dans un nouvel arbre et voila les liens ont été corrigés, que ce soit dans les notes ou dans les champs Internet.

Si on veut contrôller le résulat :
```
zcat 'ma famille-2026-05-09-15-58-47.gramps' > G.gramps
cp G.gramps{,.orig}
./convert-finistere.pl G.gramps
diff -u G.gramps{.orig,} | vim -
```

## Comment ajouter une nouvelle commune ?

### Comment rajouter un registre unique à la main

Si vous avez bien fait votre travail, vous avez le lien, le numéro de vue et le nom du registre :
Exemple d'un mariage du 1702-11-21 à Carhaix :
* https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/03E/3E037/3E037_0002/?img=FRAD029_3E037_02_0159.jpg
  * dans cette URL, il faut noter l'ancien identifiant, ici **``3E037_0002``**
* "Acte vue 199/363 en haut à droite"
* "BMS Carhaix - 1690-1714"

Il suffit d'aller sur https://recherche.archives.finistere.fr/archive/resultats/etatcivil/n:138 d'entrer Carhaix et la date de l'évènement (ou l'année du début du registre).
On obtient un lien : https://recherche.archives.finistere.fr/ark:/72506/652176.1275535/img:FRAD029_3E037_02_0159
Dans ce lien on retrouve :
* le nom de domaine des AD29 : ``recherche.archives.finistere.fr``
* l'identifiant unique ARK des AD29 : ``72506``
* le nouvel identifiant unique du registre dans les AD29 : **``652176.1275535``** (qui remplace donc l'ancien **``3E037_0002``**)
* le nom de l'image : ``img:FRAD029_3E037_02_0159``

C'est l'identifiant unique du registre qui nous intéresse ici.
Il suffit maintenant de rajouter une ligne dans `convert-finistere.pl` afin de convertir automatiquement toutes les permaliens de ce registre (avec un commentaire notant le type "BMS", la commune "Carhaix", la côte et la plage d'années concernées) :
```
    '3E037_0002' => '652176.1275535',	# BMS Carhaix  3 E 37/2		1690-1714
```

### Comment rajouter tous les registres NMD de la commune

Si la commune est déja listée dans le générateur :

```
./gen-new-ids-nmd-all2.pl Spézet > Spézet.txt
```


Si la commune n'est pas déja listée dans le générateur, il faut soit passer un paramètre MD5SUM (qui se retrouve sur le site des AD29), soit espérer que le nom de lieu est unique.

Pour obtenir l'argument MD5, il faut aller sur https://recherche.archives.finistere.fr/archive/resultats/etatcivil/n:138, taper "`Brest`" dans le champ "`Commune`", sélectionner "`Brest (Finistère)`" dans les choix proposé, presser le bouton de recherche, puis noter la nouvelle URL dans le navigateur :
* https://recherche.archives.finistere.fr/archive/resultats/etatcivil/n:138?REch_commune_Libel=Brest%20(Finist%C3%A8re)|&REch_commune_Md5=6f0c992f5656b2b59f520b3089463e94|&type=etatcivil

Dans cette addresse il y a le paramètre qui nous intéresse : "REch_commune_Md5=**6f0c992f5656b2b59f520b3089463e94**"
Il suffit maintenant de le passer en argument au script :

```
./gen-new-ids-nmd-all2.pl Brest 6f0c992f5656b2b59f520b3089463e94 > Brest.txt
```

Le résultat est dans le fichier texte dont il suffit de rajouter le contenu dans `convert-finistere.pl` (de préférence en gardant les côtes triées).


### Comment rajouter tous les registres NMD de la commune

Si la commune est déja listée dans le générateur :

```
./gen-new-ids-bms-all2.pl Névez
```


### Comment rajouter tous les tables décennales de la commune

Un générateur spécialisé est utilisé pour les TD :

```
./gen-new-ids-td.pl Kergloff > TD.Kergloff
```

### Comment rajouter tous les registres matricule d'une année


Générateur plus efficace:
```
# Tous les registres du bureau de Crozon pour l'année 1876 :
./gen-new-ids-matricule-all.pl --bureau=Crozon --annee=1876
# Tous les registres du bureau de Crozon :
./gen-new-ids-matricule-all.pl --bureau=Crozon
# Tous les registres du bureau de Brest pour l'année 1914 :
./gen-new-ids-matricule-all.pl --bureau=Brest --annee=1914 > matricule.Brest.1914
# Tous les registres de tous les bureaux pour l'année 1914 :
./gen-new-ids-matricule-all.pl --annee=1914 > matricule.all.1914
```

Ancien générateur:
Exemple pour 1914:
```
./gen-new-ids-matricule.pl "https://recherche.archives.finistere.fr/archive/resultats/matricules/n:141?RECH_dateclassefacettes=1914&type=matricules"
```
Exemple pour 1914, seulement le bureau de Brest:
```
https://recherche.archives.finistere.fr/archive/resultats/matricules/n:141?RECH_dateclassefacettes=1914&RECH_bureau_Libel=Bureau%20de%20Brest|&RECH_bureau_Md5=add9e871b619bc2d4431e6faa564285d|&type=matricules
```

## Limitations :

Lors du passage au nouveau site, ils se sont rendu comptes que certains registres étaient mal côtés. Ces registres ont donc été renommés et re-côtés.

> "Lors de la préparation de la migration vers notre nouveau moteur de recherche, nous nous sommes aperçus qu’il y avait une erreur d’affectation de certains lots numérisés pour Carhaix et Morlaix.
>
> Une partie de ces lots avaient été microfilmés, il y a longtemps, à partir d’originaux empruntés en mairie.
>
> Lors de la numérisation de ces microfilms, et leur publication en 2022, cette information avait été omise, et les lots correspondants avaient été raccrochés, à tort, aux collections départementales « 3 E » deces deux communes.
>
> Ceci explique pourquoi vous ne retrouvez pas en cotation « 3 E » certains lots de Carhaix. Il faut regarder côté collection communale « E Dépôt », aux dates équivalentes.
>
> Et même chose pour Morlaix, donc."

Il vous faudra donc manuellement corriger la côte du registre source dans vos notes dans votre logiciel de généalogie.

De plus, deux lots d'images ont souvent été agglomérés.
Les registres qui m'intéressent étaient dans le 1er lot mais à tester d'anciens permaliens sur le 2e lot. Les liens sont probablement bons mais à vérifier.
Dans tous les cas le numéro de vue est à corriger (par ex: la vue "187/201" devient "187/431")

## Exemples de nouvelle et d'ancienne adresses (différents cas que j'ai rencontré)

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
