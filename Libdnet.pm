# $Id: Libdnet.pm,v 1.4 2004/09/06 14:47:31 vman Exp $

# Copyright (c) 2004 Vlad Manilici
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
# OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package Net::Libdnet;

use 5.006;
use strict;
use warnings;
use Carp;

require Exporter;
require DynaLoader;
use AutoLoader;

our @ISA = qw(Exporter DynaLoader);
our @EXPORT = qw(
	addr_cmp
	addr_bcast
	addr_net
	arp_add
	arp_delete
	arp_get
	intf_get
	intf_get_src
	intf_get_dst
	intf_set
	route_add
	route_delete
	route_get
);

# change major to one when the whole interface is implemented
our $VERSION = '0.01';

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.  If a constant is not found then control is passed
    # to the AUTOLOAD in AutoLoader.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "& not defined" if $constname eq 'constant';
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) {
	if ($! =~ /Invalid/ || $!{EINVAL}) {
	    $AutoLoader::AUTOLOAD = $AUTOLOAD;
	    goto &AutoLoader::AUTOLOAD;
	}
	else {
	    croak "Your vendor has not defined Net::Libdnet macro $constname";
	}
    }
    {
	no strict 'refs';
	# Fixed between 5.005_53 and 5.005_61
	if ($] >= 5.00561) {
	    *$AUTOLOAD = sub () { $val };
	}
	else {
	    *$AUTOLOAD = sub { $val };
	}
    }
    goto &$AUTOLOAD;
}

bootstrap Net::Libdnet $VERSION;

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Net::Libdnet - Perl interface to libdnet

=head1 SYNOPSIS

use Net::Libdnet;

=head1 DESCRIPTION

All the following functions return I<undef> and print a warning message
to the standard error when a problem occurs.

Some of the functions in the original I<dnet> were omited, because we
only deal with the string representation of addresses. We also avoid
passing handlers to the user, as we open and subsequently close them for
each request. Moreover, the XXX_loop() functions are not implemented yet.

=head2 Network addressing

=over

=item * B<addr_cmp($address_a, $address_b) -E<gt> $int_distance>

Compares network addresses a and b, returning an integer less than,
equal to, or greater than zero if a is found, respectively, to be
less than, equal to, or greater than b.  Both addresses must be of
the same address type.

=item * B<addr_bcast($address/netmask) -E<gt> $address_broadcast>

Computes the broadcast address for the specified network.

=item * B<addr_net($address/netmask) -E<gt> $address_network>

Computes the network address for the specified network.

=back

=head2 Address Resolution Protocol

=over

=item * B<arp_add($protocol_address, $hardware_address) -E<gt> 1>

Adds a new ARP entry.

=item * B<arp_delete($protocol_address) -E<gt> 1>

Deletes the ARP entry for the specified protocol address.

=item * B<arp_get($protocol_address) -E<gt> $hardware_address>

retrieves the ARP entry for the specified protocol address.

=back

=head2 Binary buffers

I<Not implemented yet.>

=head2 Ethernet

I<Not implemented yet.>

=head2 Firewalling

I<Not implemented yet.>

=head2 Network interfaces

Interfaces are manipulated as hashes with the following structure:

 {
     len => ... ,
     name => ... ,
     type => ... ,
     flags => ... ,
     mtu => ... ,
     addr => ... ,
     dst_addr => ... ,
     link_addr => ... ,
 #   alias_num => ... ,
 #   alias_addrs => ... ,
 };

Processing interface aliases is not implemented yet.

=over

=item * B<intf_get($name) -E<gt> %interface>

Retrieves an interface configuration entry, keyed on B<name>.

=item * B<intf_get_src($local_address) -E<gt> %interface>

Retrieves the configuration for the interface with the specified
primary address.

=item * B<intf_get_dst($remote_address) -E<gt> %interface>

Retrieves the configuration for the best interface with
which to reach the specified destination address.

=item * B<intf_set(%interface) -E<gt> 1>

I<Not implemented yet.>

Sets the interface configuration entry. Please retrieve first
the configuration, and do not build from scratch.

=back

=head2 Internet Protocol

I<Not implemented yet.>

=head2 Random number generation

I<Not implemented yet.>

=head2 Routing

=item * B<route_add($destination_address, $gateway_address) -E<gt> 1>

Adds a new route, to the specified destination prefix
over the given gateway.

=item * B<route_delete($destination_address) -E<gt> 1>

Deletes the routing table entry for the destination prefix.

=item * B<route_get($destination_address) -E<gt> $gateway_address>

Retrieves the routing table entry for the destination prefix.

=head1 TODO

intf_set, hash2intf

=head1 SEE ALSO

L<dnet(3)>

=cut
