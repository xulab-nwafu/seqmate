#!/usr/bin/env perl
#===============================================================================
#
# Description: perform go enrichment analysis with ontologizer
#
# Copyright (c) 2017 Northwest A&F University
# Author: Qinhu Wang
# Email: wangqinhu@nwafu.edu.cn
#
#===============================================================================

use strict;
use warnings;
use Env;
use Data::Dumper;

if (@ARGV < 1) {
	die "Usage: $0 gene_id.txt\n e.g.: $0 de.up.txt\n";
}

my $id_list_full = $ARGV[0];
my $id_list = undef;
if ($id_list_full =~ /(\S+)\.\S+/) {
	$id_list = $1;
}

my $outdir = $ENV{"PWD"} . "/$id_list.goea";
my $home = $ENV{"HOME"};
my $app = "$home/sf/ontologizer/latest/Ontologizer.jar";
my $obo = "$home/db/gene_ontology/current/go-basic.obo";
my $ann = "$home/db/gene_ontology/current/SS.GO.ids";
my $pop = "$home/db/gene_ontology/current/SS.gene.txt";
my $cal = "Parent-Child-Union";
my $mtc = "Benjamini-Hochberg";

my $goea_log = `java -jar $app -g $obo -a $ann -c "$cal" -m "$mtc" -r 1000 -d 0.05 -i -n -p $pop -s $id_list_full -o $outdir 2>&1`;
my $dot_log1 = `dot -Tpng $outdir/view-$id_list-$cal-$mtc.dot -o$outdir/$id_list.png 2>&1`;
my $dot_log2 = `dot -Tpdf $outdir/view-$id_list-$cal-$mtc.dot -o$outdir/$id_list.pdf 2>&1`;

my $go = load_obo("$home/db/gene_ontology/current/go-basic.obo");
open (SUM, "$outdir/table-$id_list-$cal-$mtc.txt") or die "Cannot open $outdir/table-$id_list-$cal-$mtc.txt: $!\n";
open (RPT, ">$outdir/table-$id_list-$cal-$mtc.tmp") or die "Cannot open $outdir/table-$id_list-$cal-$mtc.tmp: $!\n";
while (<SUM>) {
	chomp;
	if (/^GO/) {
		my @w = split /\t/;
		s/\"//g;
		if (exists $go->{$w[0]}) {
			print RPT $_ . "\t" . $go->{$w[0]} . "\n";
		} else {
			print "unknown $w[0] in $obo\n";
		}
	} else {
		if (/^ID/) {
			print RPT $_ . "\tname.space\n";
		}
	}
}
close SUM;
close RPT;

my $mv_log = `mv $outdir/table-$id_list-$cal-$mtc.tmp $outdir/table-$id_list-$cal-$mtc.txt 2>&1`;

open (LOG, ">$outdir/goea-$id_list-$cal-$mtc.log") or die "Cannot open $outdir/goea-$id_list-$cal-$mtc.log: $!\n";
print LOG $goea_log;
print LOG $dot_log1;
print LOG $dot_log2;
print LOG $mv_log;
close LOG;

sub load_obo {
	my $obo = shift;
	my $go_id = '';
	my $go_ns = '';
	my %go = ("GO:0000000" => "root");
	open (OBO, $obo) or die "Cannot open $obo: $!\n";
	while (<OBO>) {
		chomp;
		if (/id\:\s(GO\:\d+)/) {
			$go_id = $1;
		}
		if (/namespace\:\s(\S+)/) {
			$go_ns = $1;
		}
		$go{$go_id} = $go_ns;
	}
	close OBO;
	return \%go;
}
