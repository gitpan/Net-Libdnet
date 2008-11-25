#!/usr/bin/perl
#
# $Id: dnet.pl 14 2008-11-25 21:37:59Z gomor $
#
use strict; use warnings;

my $opt = shift || die("Usage");
my $cmd = shift || die("Usage");
my $arg = "@ARGV";

use Net::Libdnet qw(:consts);

   if ($opt =~ /intf/i)  { intf_opt ($cmd, $arg) }
elsif ($opt =~ /route/i) { route_opt($cmd, $arg) }
elsif ($opt =~ /arp/i)   { arp_opt  ($cmd, $arg) }
elsif ($opt =~ /fw/i)    { fw_opt   ($cmd, $arg) }
elsif ($opt =~ /ip/i)    { ip_opt   ($cmd, $arg) }
elsif ($opt =~ /eth/i)   { eth_opt  ($cmd, $arg) }
#else { print_usage() }

#
# intf option handling
#
sub intf_opt {
   my ($cmd) = @_;
   use Net::Libdnet::Intf;
   my $h = Net::Libdnet::Intf->new;
   if ($cmd =~ /show/i) {
      $h->loop(\&intf_print);
   }
   elsif ($cmd =~ /get/i) {
      my $e = $h->get($arg);
      $e && intf_print($e);
   }
   elsif ($cmd =~ /set/i) {
      my $s = $h->set($arg);
      print $s ? "Success\n" : "Failed\n";
   }
   elsif ($cmd =~ /src/i) {
      my $e = $h->getSrc($arg);
      $e && intf_print($e);
   }
   elsif ($cmd =~ /dst/i) {
      my $e = $h->getDst($arg);
      $e && intf_print($e);
   }
   #else {
      #intf_usage();
   #}
}

sub flags2string {
   my ($flags) = @_;
   my $buf = '';
   if ($flags & INTF_FLAG_UP)          { $buf .= ",UP"          }
   if ($flags & INTF_FLAG_LOOPBACK)    { $buf .= ",LOOPBACK"    }
   if ($flags & INTF_FLAG_POINTOPOINT) { $buf .= ",POINTOPOINT" }
   if ($flags & INTF_FLAG_NOARP)       { $buf .= ",NOARP"       }
   if ($flags & INTF_FLAG_BROADCAST)   { $buf .= ",BROADCAST"   }
   if ($flags & INTF_FLAG_MULTICAST)   { $buf .= ",MULTICAST"   }
   $buf =~ s/^,//;
   $buf;
}

sub intf_print {
   my ($e, $data) = @_;
   printf("%s:", $e->{intf_name});
   printf(" flags=0x%x<%s>", $e->{intf_flags}, flags2string($e->{intf_flags}));
   if ($e->{intf_mtu} != 0) {
      printf(" mtu %d", $e->{intf_mtu});
   }
   printf("\n");
   if ($e->{intf_addr} && $e->{intf_dst_addr}) {
      printf("\tinet %s --> %s\n", $e->{intf_addr}, $e->{intf_dst_addr});
   }
   elsif ($e->{intf_addr}) {
      printf("\tinet %s\n", $e->{intf_addr});
   }
   if ($e->{intf_link_addr}) {
      printf("\tlink %s\n", $e->{intf_link_addr});
   }
   for (0..$e->{intf_alias_num}-1) {
      printf("\talias %s\n", $e->{intf_alias_addrs}->[$_]);
   }
}

#
# route handling
#

sub route_opt {
   my ($cmd) = @_;
   use Net::Libdnet::Route;
   my $h = Net::Libdnet::Route->new;
   if ($cmd =~ /show/i) {
      printf("%-30s %-30s\n", "Destination", "Gateway");
      $h->loop(\&route_print);
   }
   elsif ($cmd =~ /get/i) {
      my $e = $h->get($arg);
      print $e ? "Gateway: $e\n" : "Same subnet\n";
   }
   elsif ($cmd =~ /add/i) {
      my $s = $h->add(split(/ +/, $arg));
      print $s ? "Success\n" : "Failed\n";
   }
   elsif ($cmd =~ /delete/i) {
      my $s = $h->delete(split(/ +/, $arg));
      print $s ? "Success\n" : "Failed\n";
   }
   #else {
      #route_usage();
   #}
}

sub route_print {
   my ($e, $data) = @_;
   printf("%-30s %-30s\n", $e->{route_dst}, $e->{route_gw});
}

#
# arp handling
#

sub arp_opt {
   my ($cmd) = @_;
   use Net::Libdnet::Arp;
   my $h = Net::Libdnet::Arp->new;
   if ($cmd =~ /show/i) {
      $h->loop(\&arp_print);
   }
   elsif ($cmd =~ /get/i) {
      my $e = $h->get($arg);
      print $e ? "link: $e\n" : "No link found\n";
   }
   elsif ($cmd =~ /add/i) {
      my $s = $h->add(split(/ +/, $arg));
      print $s ? "Success\n" : "Failed\n";
   }
   elsif ($cmd =~ /delete/i) {
      my $s = $h->delete(split(/ +/, $arg));
      print $s ? "Success\n" : "Failed\n";
   }
   #else {
      #arp_usage();
   #}
}

sub arp_print {
   my ($e, $data) = @_;
   printf("%s at %s\n", $e->{arp_pa}, $e->{arp_ha});
}

#
# fw handling
#

sub fw_opt {
   my ($cmd) = @_;
   use Net::Libdnet::Fw;
   my $h = Net::Libdnet::Fw->new;
   if ($cmd =~ /show/i) {
      $h->loop(\&fw_print);
   }
   elsif ($cmd =~ /add/i) {
      my $s = $h->add($arg);
      print $s ? "Success\n" : "Failed\n";
   }
   elsif ($cmd =~ /delete/i) {
      my $s = $h->delete($arg);
      print $s ? "Success\n" : "Failed\n";
   }
   #else {
      #fw_usage();
   #}
}

sub fw_print {
   my ($e, $data) = @_;
   my $device = $e->{fw_device};
   my $op     = $e->{fw_op};
   my $dir    = $e->{fw_dir};
   my $proto  = $e->{fw_proto};
   my $src    = $e->{fw_src};
   my $dst    = $e->{fw_dst};
   my $sport  = $e->{fw_sport};
   my $dport  = $e->{fw_dport};
      if ($op == FW_OP_ALLOW) { $op = "allow" }
   elsif ($op == FW_OP_BLOCK) { $op = "block" }
      if ($dir == FW_DIR_IN)  { $dir = "in"  }
   elsif ($dir == FW_DIR_OUT) { $dir = "out" }
      if ($proto == 6)  { $proto = "tcp"  }
   elsif ($proto == 17) { $proto = "udp"  }
   elsif ($proto == 1)  { $proto = "icmp" }
   $src = $src.':'.join('-', @$sport);
   $dst = $dst.':'.join('-', @$dport);
   print "$op $dir $device $proto $src $dst\n";
}

#
# ip handling
#

sub ip_opt {
   my ($cmd) = @_;
   use Net::Libdnet::Ip;
   my $h = Net::Libdnet::Ip->new;
   $h->send($cmd);
}

#
# eth handling
#

sub eth_opt {
   my ($cmd, $arg) = @_;
   use Net::Libdnet::Eth;
   print "[$cmd] [$arg]\n";
   my $h = Net::Libdnet::Eth->new(device => $cmd);
   $h->send($arg);
}
