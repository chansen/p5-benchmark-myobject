package MyObject::HvInsideOutCachedId;

use strict;
use constant HAS_READONLY => !!Internals->can('SvREADONLY');

use Scalar::Util qw[refaddr];

my %Content_of;
my %ContentType_of;

sub new {
    @_ == 1 || die(q/Usage: / . __PACKAGE__ . q/->new()/);
    my $self = bless( \do{ my $o }, $_[0] ); 
      $$self = refaddr($self);

    if ( HAS_READONLY ) {
        Internals::SvREADONLY( $$self, 1 );
    }

    return $self;
}

sub get_content {
    @_ == 1 || die(q/Usage: $object->get_content()/);
    return $Content_of{ ${ $_[0] } };
}

sub set_content {
    @_ == 2 || die(q/Usage: $object->set_content(content)/);
    $Content_of{ ${ $_[0] } } = $_[1];
}

sub has_content {
    @_ == 1 || die(q/Usage: $object->has_content()/);
    return exists($Content_of{ ${ $_[0] } });
}

sub get_content_type {
    @_ == 1 || die(q/Usage: $object->get_content_type()/);
    return $ContentType_of{ ${ $_[0] } };
}

sub set_content_type {
    @_ == 2 || die(q/Usage: $object->set_content_type(content_type)/);
    $ContentType_of{ ${ $_[0] } } = $_[1];
}

sub has_content_type {
    @_ == 1 || die(q/Usage: $object->has_content_type()/);
    return exists($ContentType_of{ ${ $_[0] } });
}

sub DESTROY {
    delete $Content_of{ ${ $_[0] } };
    delete $ContentType_of{ ${ $_[0] } };
}

1;

