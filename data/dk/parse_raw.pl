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

my $file_1 = '20247411316470922150FOD39816945355.csv';

# Reads input.
my %yearly_counts = ();
my %by_year_age   = ();
my $reference_age;
open my $in_1, '<:utf8', $file_1;
while (<$in_1>) {
	chomp $_;
	$_ =~ s/\"//g;
	my (undef, $age, @values) = split ',', $_;
	next unless $age && $age =~ /years/;
	$age =~ s/ years//;
	my $age_group = age_group_from_age($age);
	my $year = 2013;
	for my $value (@values) {
		$yearly_counts{$year} += $value;
		$by_year_age{$year}->{$age_group} += $value;
		$year++;
	}
	say $_;
}
close $in_1;

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

my $file_2 = '20247415110470942957BEFOLK254186788413.csv';

# Reads input.
my %pop = ();
open my $in_2, '<:utf8', $file_2;
while (<$in_2>) {
	chomp $_;
	my (undef, $age, @values) = split ',', $_;
	next unless $age && $age =~ /years/;
	$age =~ s/-/ to /;
	my $year = 2013;
	for my $value (@values) {
		$pop{$year}->{$age} = $value;
		$year++;
	}
}
close $in_2;

open my $out_2, '>:utf8', 'women_age_groups_by_year.csv';
say $out_2 "Age,Year,Count";
for my $year (sort{$a <=> $b} keys %pop) {
	for my $age (sort keys %{$pop{$year}}) {
		my $count = $pop{$year}->{$age} // die;
		say $out_2 "$age,$year,$count";
	}
}
close $out_2;