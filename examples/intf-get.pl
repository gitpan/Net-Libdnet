#!/usr/bin/perl
use strict; use warnings;

use Net::Libdnet::Intf;
use Data::Dumper;

my $intf = shift || die("Pass interface");

my $h = Net::Libdnet::Intf->new;
my $info = $h->get($intf);
print Dumper($info)."\n";
