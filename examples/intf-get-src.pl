#!/usr/bin/perl
use strict; use warnings;

my $src = shift || die("Pass source IP");

use Net::Libdnet::Intf;
use Data::Dumper;

my $h = Net::Libdnet::Intf->new;
my $info = $h->getSrc($src);
print Dumper($info)."\n";
