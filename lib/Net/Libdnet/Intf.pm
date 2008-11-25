#
# $Id: Intf.pm 13 2008-11-25 21:36:12Z gomor $
#
package Net::Libdnet::Intf;
use strict; use warnings;

require Class::Gomor::Array;
our @ISA = qw(Class::Gomor::Array);
our @AS  = qw(
   _handle
);
__PACKAGE__->cgBuildIndices;
__PACKAGE__->cgBuildAccessorsScalar(\@AS);

use Net::Libdnet qw(:intf);

sub new {
   my $self   = shift->SUPER::new(@_);
   my $handle = dnet_intf_open() or die("Intf::new: unable to open");
   $self->_handle($handle);
   $self;
}

sub get {
   my $self   = shift,
   my ($intf) = @_;
   dnet_intf_get($self->_handle, {intf_name => $intf});
}

sub getSrc {
   my $self  = shift,
   my ($src) = @_;
   dnet_intf_get_src($self->_handle, $src);
}

sub getDst {
   my $self  = shift,
   my ($dst) = @_;
   dnet_intf_get_dst($self->_handle, $dst);
}

sub set {
   my $self = shift;
   my ($h)  = @_;
   # XXX: write using only args on input, and put them into a hash
   dnet_intf_set($self->_handle, $h);
}

sub loop {
   my $self         = shift;
   my ($sub, $data) = @_;
   dnet_intf_loop($self->_handle, $sub, $data || \'');
}

sub DESTROY {
   my $self = shift;
   defined($self->_handle) && dnet_intf_close($self->_handle);
}

1;

__END__

=head1 NAME

Net::Libdnet::Intf - high level API to access libdnet intf_* functions

=head1 SYNOPSIS

XXX

=head1 DESCRIPTION

XXX

=head1 METHODS

=over 4

=item B<new>

=item B<get>

=item B<getSrc>

=item B<getDst>

=item B<set>

=item B<loop>

=back

=head1 AUTHOR

Patrice E<lt>GomoRE<gt> Auffret

=head1 COPYRIGHT AND LICENSE

You may distribute this module under the terms of the BSD license. See LICENSE file in the source distribution archive.

Copyright (c) 2008, Patrice <GomoR> Auffret

=cut
