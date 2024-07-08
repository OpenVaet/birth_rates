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

my $file_1 = 'stadat-nep0003-22.1.1.3-en.csv';

# Reads input.
my %pop           = ();
my %yearly_counts = ();
my %by_year_age   = ();
my $section       = 0;
my @years         = (1980, 1990, 2001, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024);
open my $in_1, '<:utf8', $file_1 or die $!;
while (<$in_1>) {
	chomp $_;
	if ($_ =~ /Females/) {
		$section = 1;
	} elsif ($_ =~ /Total/) {
		$section = 0;
	}
	if ($section == 1) {
		next if $_ =~ /Females/;
		my ($age, @values) = split ';', $_;
		next if $age < 15 || $age > 44;
		my $age_group = age_group_from_age($age);
		my $enum = 0;
		for my $value (@values) {
			my $year = $years[$enum] // die;
			$enum++;
			next if $year < 2013 || $year > 2023;
			$pop{$year}->{$age_group} += $value;
		}
	}
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
		die "age : $age";
	}
	return $age_group;
}

open my $out_2, '>:utf8', 'women_age_groups_by_year.csv';
say $out_2 "Age,Year,Count";
for my $year (sort{$a <=> $b} keys %pop) {
	for my $age (sort keys %{$pop{$year}}) {
		my $count = $pop{$year}->{$age} // die;
		say $out_2 "$age,$year,$count";
	}
}
close $out_2;

my $file_2 = 'stadat-nep0008-22.1.1.8-en.csv';

# Reads input.
open my $in_2, '<:utf8', $file_2 or die $!;
while (<$in_2>) {
	chomp $_;
	$_ =~ s/\"//g;
	$_ =~ s/,/\./g;
	my ($year, @values) = split ';', $_;
	next unless $year && looks_like_number $year;
	next if $year < 2013 || $year > 2023;
	my @age_groups = ('15 to 19 years', '20 to 24 years', '25 to 29 years', '30 to 34 years', '35 to 39 years', '40 to 44 years');
	for my $value (@values) {
		my $age_group  = shift @age_groups;
		next unless $age_group;
		my $population = $pop{$year}->{$age_group} // next;
		my $flat_num   = nearest(1, $value * $population / 1000);
		$yearly_counts{$year} += $flat_num;
		$by_year_age{$year}->{$age_group} += $flat_num;
	}
}
close $in_2;

p%yearly_counts;

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

