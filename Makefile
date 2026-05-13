check:
	# check syntax:
	perl -cw convert-finistere.pl
	# check a regular NMD
	./convert-finistere.pl "https://recherche.archives.finistere.fr/viewer/series/medias/collections/E/03E/3E309/3E309_0020?img=FRAD029_3E309_20_0068.jpg" 2>&1|grep -o 'https://recherche.archives.finistere.fr/ark:/72506/1040464.1634768/img:FRAD029_3E309_20_0068'
	# check a registre matricule
	./convert-finistere.pl "https://recherche.archives.finistere.fr/viewer/series/medias/collections/R/01R/1R01289?img=FRAD029_1R_01289_0196.jpg" 2>&1|grep -o 'https://recherche.archives.finistere.fr/ark:/72506/835747.1076020/img:FRAD029_1R_01289_0196'
	# check a census
	./convert-finistere.pl "https://recherche.archives.finistere.fr/viewer/series/medias/collections/M/06M/6M01/6M0763?s=FRAD029_6M_0763_08_000001.jpg&amp;e=FRAD029_6M_0763_08_000025.jpg&amp;img=FRAD029_6M_0763_08_000003.jpg&amp;levelDescription=FRAD029_00000006M_pa-4828" 2>&1|grep -o 'https://recherche.archives.finistere.fr/ark:/72506/1145235/img:FRAD029_6M_0763_08_000003'
	@echo all OK


diff-td:
	diff -u gen-new-ids-nmd-all2.pl gen-new-ids-td.pl|vim  -
