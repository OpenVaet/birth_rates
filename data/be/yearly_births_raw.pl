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

my $file = 'yearly_births_raw.csv';

# Reads input.
my %yearly_counts = ();
my %by_year_age   = ();
my $reference_age;
open my $in, '<:utf8', $file;
while (<$in>) {
	chomp $_;
	my ($year, $age, $birth_year, $count) = split ',', $_;
	if ($age eq 'Total' || $age eq 'Totaal') {
		die if exists $yearly_counts{$year};
		$yearly_counts{$year} = $count;
	} else {
		next if $age eq '< 14' || $age eq '> 49' || $age eq 'Age' || $age eq 'Onbekend' || $age eq 'Inconnu';
		if (defined $age && length $age > 0) { die "[$age]" unless looks_like_number($age) }
		$reference_age = $age if $age;
		next if $reference_age < 15 || $reference_age > 44;
		my $age_group = age_group_from_age($reference_age);
		# say "$year, $reference_age, $birth_year, $count";
		$by_year_age{$year}->{$age_group} += $count;
	}
	# say $_;
}
close $in;

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
open my $out, '>:utf8', 'births_by_mother_age_group_year.csv';
say $out "Age,Year,Births";
for my $year (sort{$a <=> $b} keys %by_year_age) {
	for my $age_group (sort keys %{$by_year_age{$year}}) {
		my $births = $by_year_age{$year}->{$age_group} // die;
		say $out "$age_group,$year,$births";
	}
}
close $out;
# p%by_year_age;

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