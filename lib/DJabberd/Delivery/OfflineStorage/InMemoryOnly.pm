package DJabberd::Delivery::OfflineStorage::InMemoryOnly;
use strict;
use base 'DJabberd::Delivery::OfflineStorage';
use warnings;
use Data::Dumper;

use vars qw($VERSION);
$VERSION = '0.05';


our $logger = DJabberd::Log->get_logger();


sub load_offline_messages {
    my ($self, $user, $cb) = @_;
    $logger->info("InMemoryOnly OfflineStorage load for: $user");
    $self->{'offline'} ||= {};
    my @messages = ();
    if (exists $self->{'offline'}{$user}) {
      foreach my $id (sort keys %{$self->{'offline'}{$user}}) {
        push @messages, {
          id => $id,
          packet => $self->{'offline'}{$user}{$id},
        };
      }
    }
    if ($cb) {
      $cb->(\@messages);
    } else {
      return \@messages;
    }
}


sub delete_offline_message {
    my ($self, $user, $id) = @_;
    $self->{'offline'} ||= {};
    $logger->info("InMemoryOnly OfflineStorage delete for: $id");
    # must remove it from $user too
    if (exists $self->{'offline'}->{$user}) {
      delete $self->{'offline'}->{$user}->{$id};
      delete $self->{'offline'}->{$user}
        unless keys %{$self->{'offline'}->{$user}};
    }
}


sub store_offline_message {
    my ($self, $user, $packet, $cb) = @_;
    $self->{offline} ||= {};
    $self->{offline_id} ||= 1;

    my $id = $self->{'offline_id'}++;
    $logger->info("InMemoryOnly OfflineStorage store for: $user/$id");
    $self->{'offline'}->{$user} ||= {};
    $self->{'offline'}->{$user}->{$id} = $packet;
    if ($cb) {
      $cb->();
    }
}

1;
