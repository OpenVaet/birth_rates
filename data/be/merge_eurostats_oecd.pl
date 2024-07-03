#!/usr/bin/perl
use strict;
use warnings;
use v5.26;
use Data::Dumper;
use Data::Printer;
binmode STDOUT, ":utf8";
no autovivification;
use utf8;
use JSON;
use Math::Round qw(nearest);
use Math::CDF;
use FindBin;
use lib "$FindBin::Bin/../../lib";

my $file_1 = 'eurostat_consolidated_data.csv';

my %counts_2023 = ();

open my $in_1, '<:utf8', $file_1;
while (<$in_1>) {
	chomp $_;
	$_ =~ s/\"//g;
	my ($year, $age, $val) = split ',', $_;
	next unless $year eq '2023';
	$age =~ s/ years//;
	my $age_group = age_group_from_age($age);
	$counts_2023{$age_group} += $val;
}
close $in_1;

my $file_2   = '20240703_15_25_women_age_group_2013_2022.csv';
my $file_out = '20240703_15_25_women_age_group_2013_2023.csv';

open my $in_2, '<:utf8', $file_2;
open my $out, '>:utf8', $file_out;
while (<$in_2>) {
	chomp $_;
	my ($age_group, @vals) = split ',', $_;
	if ($age_group eq 'Age') {
		$_ .= ',2023';
		say $out $_;
	} else {
		my $val_2023 = $counts_2023{$age_group} // die;
		$_ .= ",$val_2023";
		say $out $_;
	}
}
close $in_2;
close $out;


sub age_group_from_age {
	my $age = shift;
	my $age_group;
	if ($age >= 15 && $age <= 19) {
		$age_group = '15 to 19 years'
	} elsif ($age >= 20 && $age <= 24) {
		$age_group = '20 to 24 years'
	} elsif ($age >= 25 && $age <= 29) {
		$age_group = '25 to 29 years'
	} elsif ($age >= 30 && $age <= 34) {
		$age_group = '30 to 34 years'
	} elsif ($age >= 35 && $age <= 39) {
		$age_group = '35 to 39 years'
	} elsif ($age >= 40 && $age <= 44) {
		$age_group = '40 to 44 years'
	} else {
		die;
	}
	return $age_group;
}