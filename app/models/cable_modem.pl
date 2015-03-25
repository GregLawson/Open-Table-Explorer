#!/usr/bin/perl
use warnings;
use strict;

use LWP::Simple;

my $httpaddr = "http://192.168.100.1/system.asp";

my %data;
my @keys = qw(ReceivePower TransmitPower);
my $content = LWP::Simple::get($httpaddr) or die "Couldn't get it!";
$content =~ s/\ //g;
$content =~ s/<(?:[^>'"]*|(['"]).*?\1)*>//gs;

# regex in html source order
if ($content =~ /Receive Power Level(.+?\n.*) dBmV/) { $data{ReceivePower} = $1$
if ($content =~ /Transmit Power Level(.+?\n.*) dBmV/) { $data{TransmitPower} = $

$data{ReceivePower} =~ s/^\s+//;
# $data{ReceivePower} =~ s/\s+$data{ReceivePower}//;
$data{TransmitPower} =~ s/^\s+//;
# $data{TransmitPower} =~ s/\s+$data{TransmitPower}//;

for (@keys) {
print "$_:" . $data{$_} . " ";
}


