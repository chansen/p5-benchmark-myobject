package MyObject::IdGenerator;

use strict;
use constant HAS_READONLY => !!Internals->can('SvREADONLY');

my @Free = ( [] );
my @Next = ( 1 );

my $Id = bless( \do { my $instance_id = 0 }, __PACKAGE__ );

sub new {
    @_ == 1 || die(q/Usage: / . __PACKAGE__ . q/->new()/);
    my ($class) = @_;

    my $instance_id = $Id->next;
    $Free[$instance_id] = [];
    $Next[$instance_id] = 0;

    my $self = bless(\$instance_id, $class);

    if ( HAS_READONLY ) {
        Internals::SvREADONLY( $$self, 1 );
    }

    return $self
}

sub dump {
    my ($self) = @_;
    my $instance_id = $$self;
    require Data::Dump;
    #require Devel::Peek;
    #Devel::Peek::Dump($Free[$instance_id]);
    Data::Dump::dump($Free[$instance_id]);
    Data::Dump::dump($Next[$instance_id]);
}

sub next {
    @_ == 1 || die(q/$object->next()/);
    my ($self) = @_;

    my $instance_id = $$self;
    my $next_id     = $Next[$instance_id];

    if ( exists($Free[$instance_id][$next_id]) ) {
        $Next[$instance_id] = delete($Free[$instance_id][$next_id]);
    }
    else {
        $next_id = $Next[$instance_id]++;
    }

    return $next_id;
}

sub reclaim {
    @_ == 2 || die(q/$object->reclaim($id)/);
    my ($self, $release_id) = @_;

    my $instance_id = $$self;
    my $next_id     = $Next[$instance_id];

    if (1) {
        if (exists $Free[$instance_id][$next_id]) {
            $Free[$instance_id][$release_id] = $Free[$instance_id][$next_id];
            $Free[$instance_id][$next_id]    = $release_id;
        }
        else {
            $Free[$instance_id][$release_id] = $Next[$instance_id];
            $Next[$instance_id] = $release_id;
        }
    }
    if (0 eq 'lifo') {
        $Free[$instance_id][$release_id] = $Next[$instance_id];
        $Next[$instance_id] = $release_id;
    }
}

sub DESTROY {
    my ($self) = @_;

    my $instance_id = $$self;
    delete($Free[$instance_id]);
    delete($Next[$instance_id]);

    if ($Id) {
        $Id->reclaim($instance_id);
    }
}

1;
