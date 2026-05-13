#!/bin/perl
# Wrapper for emitting all in once for one commune : all military registrations, grouped by register
# Like gen-new-ids-nmd-all.pl but inline gen-new-ids-nmd.pl in order to have better output, readier to use
# FIXME: add options to select only N, M or D?

# WIP
# Class year can be 1874-1923 (depending on the office)

use strict;
#use Data::Dumper;
use File::Temp qw(tempfile);
use Getopt::Long;
use HTML::TableExtract;
use List::Util;

my ($year, $bureau);
GetOptions("annee=i"  => \$year,
           "bureau=s" => \$bureau)
    or die("Error in command line arguments\n");

# MD5SUM comes from the "REch_commune_Md5=" when doing a request on https://recherche.archives.finistere.fr/archive/resultats/etatcivil/n:138?
my %bureaux = (
    'Brest' => 'add9e871b619bc2d4431e6faa564285d',
    'Bureau de Brest' => 'add9e871b619bc2d4431e6faa564285d',
    'Bureau de Châteaulin' => 'a202ef72751c988058e79e98560dba6f',
    'Bureau de Crozon' => 'de8de572fd62ca44110124ebea5228a3',
    'Bureau de Quimper' => 'b1ab4a71b155f26873a4d66c5b58f2dc',
    'Bureau%20de%20Brest' => 'add9e871b619bc2d4431e6faa564285d',
    'Bureau%20de%20Châteaulin' => 'a202ef72751c988058e79e98560dba6f',
    'Bureau%20de%20Crozon' => 'de8de572fd62ca44110124ebea5228a3',
    'Bureau%20de%20Quimper' => 'b1ab4a71b155f26873a4d66c5b58f2dc',
    'Châteaulin' => 'a202ef72751c988058e79e98560dba6f',
    'Crozon' => 'de8de572fd62ca44110124ebea5228a3',
    'Quimper' => 'b1ab4a71b155f26873a4d66c5b58f2dc',
    # Crozon + Châteaulin => 'a202ef72751c988058e79e98560dba6'
    );

# No need to loop over all years for all offices (Crozon was not open for long):
# Crozon was between 1878 & 1897
# All others are between 1867-1925 ("1925" as of 2026, +1 every 1rst January)
my %years = (
    'Crozon' => [ 1874, 1897 ],
    'default' => [ 1867, 1925 ],
    );

my ($_fh, $filename) = tempfile();
END {
    unlink($filename);
}

# eg: https://recherche.archives.finistere.fr/archive/recherche/matricules/n:141?RECH_dateclassefacettes=1920&RECH_bureau_Libel=Bureau+de+Crozon%7C&RECH_bureau_Md5=de8de572fd62ca44110124ebea5228a3%7C&type=matricules
my $url = 'https://recherche.archives.finistere.fr/archive/recherche/matricules/n:141?Archives.RECH_Validfirst=&RECH_dateclassefacettes=%s&RECH_bureau_Libel=%s%7C&RECH_bureau_Md5=%s%7C&RECH_cote=&type=matricules';

my %results;
my @list = ($bureau) || qw(Brest Châteaulin Crozon Quimper);
foreach my $bureau (@list) {
    my $years2 = $years{$bureau} || $years{default};
    my ($begin_year, $end_year) = $year ? ($year, $year) : @$years2;

    my $md5 = $bureaux{$bureau};

    my $y = $begin_year;
    while ($y <= $end_year) {
	#warn ">> TRY " . sprintf($url, $y, $bureau, $md5) . "\n";
	process(sprintf($url, $y, $bureau, $md5));
	$y++;
    }
}

#use Data::Dumper; output("dump.pm", Data::Dumper->Dump([ \%results ], [ qw(results) ]));

# Output all:
foreach my $id (sort keys %results) {
    # print hash opening with comment:
    #print "    '$id' => $results{$id}\n";
    print $results{$id};
}

#========================
# From gen-new-ids-nmd.pl:
#!/bin/perl
# Generate the table for converting old permalinks to new ones

# From the old AD29 permalinks I'd in my tree:

sub process {
    my ($url) = @_;
    
    # Force 25 resultats per page:
    #$url .= "pagination_25";


    #warn ">> Using temp file: $filename\n";
    system('wget', '-q', '-O', $filename, $url);

    my $te = HTML::TableExtract->new(attribs => { id => 'resultats' }, keep_html => 1);
    $te->parse_file($filename);
    my ($table) = $te->tables;
    if (!$table) {
       warn ">> ERROR: No results for URL='$url'\n";
       return;
    }

    my $i;
    foreach my $row ($table->rows) {
	# rows are : Commune, desc, type, cote, link, actions…
	# eg: "Cléden-Poher (Finistère)", "1793 - an II", "naissance", "3 E 42/11/1", <link>

	#my ($commune, $desc, $type, $id, $link) = @$row;
	my ($desc, $reg_year, $id, $link) = @$row;
	$i++;
	next if $i == 1; # skip header line
	my ($ark) = $link =~ m!/ark:/72506/([^/]+)/!;
	my $mainID;
	if ($id =~ /^1 R \d+/) { # eg: '1 R 974'
	    $mainID = format_1R($id);
	    if ($desc =~ /Table alphabétique/) {
		# the web site bogusly returns the same register ID for both the actual register and the index.
		# People will mostly have permalinks on individual pages rather than on index
		# We still emit bogus/altered lines for index tables in case there's only that
		$mainID .= "_table";
		# Ignore tables: (comment next line if you want to emit those lines)
		next;
	    }
	} else {
	    warn ">> FAILED TO PARSE ID='$id'\n";
	}
	if ($link) {
	    ($link) = $link =~ m!<a href="(/ark[^"]*)"!;
	    #warn "--> ID(year) $id ==> '$mainID' -> '$reg_year' / '$ark' / $id ($desc)\n";
	    #$results{$mainID} = "    '$mainID' => '$ark',            # $id ($reg_year) ($desc)\n";
	    $results{$mainID} = "    '$mainID' => '$ark',            # $desc ($reg_year)\n";
	}
    }
}

sub format_1R {
    my ($id) = @_;
    # Normalize: '1 R 931' => '1R00931'
    $id =~ s!/! !g;
    sprintf("%s%s%05d", split(' ', $id)); # Ideally to doble check in old tree!
}

# From MDK::Common:
sub min  { my $n = shift; $_ < $n and $n = $_ foreach @_; $n }
sub max  { my $n = shift; $_ > $n and $n = $_ foreach @_; $n }
sub output { my $f = shift; open(my $F, ">$f") or die "output in file $f failed: $!\n"; print $F $_ foreach @_; 1 }
