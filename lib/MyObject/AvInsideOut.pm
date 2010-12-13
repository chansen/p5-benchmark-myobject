package MyObject::AvInsideOut;

use strict;
use constant HAS_READONLY => !!Internals->can('SvREADONLY');

use MyObject::IdGenerator qw[];

my @Content;
my @ContentType;

my $Id = MyObject::IdGenerator->new;

sub new {
    @_ == 1 || die(q/Usage: / . __PACKAGE__ . q/->new()/);
    my ($class) = @_;

    my $self = bless( \do { $Id->next }, $class );

    if ( HAS_READONLY ) {
        Internals::SvREADONLY( $$self, 1 );
    }

    return $self;
}

sub get_content {
    @_ == 1 || die(q/Usage: $object->get_content()/);
    return $Content[ ${ $_[0] } ];
}

sub set_content {
    @_ == 2 || die(q/Usage: $object->set_content(content)/);
    $Content[ ${ $_[0] } ] = $_[1];
}

sub has_content {
    @_ == 1 || die(q/Usage: $object->has_content()/);
    return exists($Content[ ${ $_[0] } ]);
}

sub get_content_type {
    @_ == 1 || die(q/Usage: $object->get_content_type()/);
    return $ContentType[ ${ $_[0] } ];
}

sub set_content_type {
    @_ == 2 || die(q/Usage: $object->set_content_type(content_type)/);
    $ContentType[ ${ $_[0] } ] = $_[1];
}

sub has_content_type {
    @_ == 1 || die(q/Usage: $object->has_content_type()/);
    return exists($ContentType[ ${ $_[0] } ]);
}

sub DESTROY {
    my ($self) = @_;
    my $instance_id = $$self;

    delete($Content[$instance_id]);
    delete($ContentType[$instance_id]);

    $Id->reclaim($instance_id);
}

1;

