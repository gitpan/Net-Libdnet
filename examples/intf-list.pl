#!/usr/bin/perl
use strict; use warnings;

use Net::Libdnet::Intf;
use Data::Dumper;

my $h = Net::Libdnet::Intf->new;
$h->loop(\&intf_show);

sub intf_show {
   my ($entry, $data) = @_;
   print Dumper($entry)."\n";
}
