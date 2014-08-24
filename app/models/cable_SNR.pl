#!/usr/bin/perl
use warnings;
use strict;

use LWP::Simple;

my $httpaddr = "http://192.168.100.1/signal.asp";


my %data;
my @keys = qw(SNR);
my $content = LWP::Simple::get($httpaddr) or die "Couldn't get it!";
$content =~ s/\ //g;
$content =~ s/<(?:[^>'"]*|(['"]).*?\1)*>//gs;

# regex in html source order
if ($content =~ /(.+?)dB\s/) { $data{SNR} = $1; }

$data{SNR} =~ s/^\s+//;

for (@keys) {
print "$_:" . $data{$_} . " ";
}
