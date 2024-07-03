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
use Scalar::Util qw(looks_like_number);
use Math::CDF;
use FindBin;
use lib "$FindBin::Bin/../../lib";

my $file_1 = 'report_1720027215476.csv';

# Reads input.
my %yearly_counts = ();
my %by_year_age   = ();
my $reference_age;
open my $in_1, '<:utf8', $file_1;
while (<$in_1>) {
	chomp $_;
	my ($year, undef, $total, $under_20, $a_20_to_24, $a_25_to_29, $a_30_to_34, $a_35_to_39, $a_40_to_44, $unknown) = split ';', $_;
	next unless looks_like_number $year;
	die if exists $yearly_counts{$year};
	$yearly_counts{$year} = $total;
	$by_year_age{$year}->{'20 to 24 years'} = $a_20_to_24;
	$by_year_age{$year}->{'25 to 29 years'} = $a_25_to_29;
	$by_year_age{$year}->{'30 to 34 years'} = $a_30_to_34;
	$by_year_age{$year}->{'35 to 39 years'} = $a_35_to_39;
	$by_year_age{$year}->{'40 to 44 years'} = $a_40_to_44;
	# say $_;
}
close $in_1;

# Ouputs format required for raw births trend calculation.
my $vals;
for my $year (sort{$a <=> $b} keys %yearly_counts) {
	my $count = $yearly_counts{$year} // die;
	$vals .= ", $count" if $vals;
	$vals .= "$count" if !$vals;
}
say "Input string for raw births :";
say $vals;

# Outputs format required for trends by age groups calculation.
open my $out_1, '>:utf8', 'births_by_mother_age_group_year.csv';
say $out_1 "Age,Year,Births";
for my $year (sort{$a <=> $b} keys %by_year_age) {
	for my $age_group (sort keys %{$by_year_age{$year}}) {
		my $births = $by_year_age{$year}->{$age_group} // die;
		say $out_1 "$age_group,$year,$births";
	}
}
close $out_1;

my $file_2 = 'report_1720031748797.csv';

# Reads input.
open my $out_2, '>:utf8', 'women_age_groups_by_year.csv';
say $out_2 "Age,Year,Count";
open my $in_2, '<:utf8', $file_2;
while (<$in_2>) {
	chomp $_;
	my ($year, undef, $age, $count) = split ';', $_;
	next unless looks_like_number $year;
	say $out_2 "$age,$year,$count";
}
close $in_2;
close $out_2;