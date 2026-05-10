check:
	perl -cw convert-finistere.pl

diff-td:
	diff -u gen-new-ids-nmd-all2.pl gen-new-ids-td.pl|vim  -
