package KinderGarden::User;

use Moose;
use Carp;
use KinderGarden::Basic;

use vars qw/@fields/;
@fields = qw/id name email visited_at/;

has 'dbh' => ( is => 'rw', lazy_build => 1 );
sub _build_dbh { KinderGarden::Basic->dbh }

has @fields => ( is => 'rw', isa => 'Str' );
has 'not_found' => ( is => 'rw', isa => 'Bool' );

sub BUILD {
    my $self = shift;
    
    my $dbh = $self->dbh;
    
    return if ($self->id and length $self->name and length $self->email); # ->new from DBI row
    
    my $sth; my @binds;
    if ($self->id) {
        $sth = $dbh->prepare("SELECT * FROM user WHERE id = ?");
        @binds = ($self->id);
    } else {
        # only id is accepeted now
        croak 'FIXME';
    }
    
    $sth->execute(@binds);
    my $user = $sth->fetchrow_hashref;
    unless ($user) {
        $self->not_found(1);
        return;
    }
    foreach my $fld (keys %$user) {
        next unless grep { $fld eq $_ } @fields;
        $self->$fld($user->{$fld});
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;