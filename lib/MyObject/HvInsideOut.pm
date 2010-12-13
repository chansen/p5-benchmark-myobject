package MyObject::HvInsideOut;

use strict;
use constant HAS_READONLY => !!Internals->can('SvREADONLY');

use Scalar::Util qw[refaddr];

my %Content_of;
my %ContentType_of;

sub new {
    @_ == 1 || die(q/Usage: / . __PACKAGE__ . q/->new()/);
    my $self = bless( \do{ my $o }, $_[0] );

    if ( HAS_READONLY ) {
        Internals::SvREADONLY( $$self, 1 );
    }

    return $self;
}

sub get_content {
    @_ == 1 || die(q/Usage: $object->get_content()/);
    return $Content_of{ &refaddr };
}

sub set_content {
    @_ == 2 || die(q/Usage: $object->set_content(content)/);
    $Content_of{ refaddr($_[0]) } = $_[1];
}

sub has_content {
    @_ == 1 || die(q/Usage: $object->has_content(foo)/);
    return exists($Content_of{ refaddr($_[0]) });
}

sub get_content_type {
    @_ == 1 || die(q/Usage: $object->get_content_type()/);
    return $ContentType_of{ &refaddr };
}

sub set_content_type {
    @_ == 2 || die(q/Usage: $object->set_content_type(content_type)/);
    $ContentType_of{ refaddr($_[0]) } = $_[1];
}

sub has_content_type {
    @_ == 1 || die(q/Usage: $object->has_content_type(bar)/);
    return exists($ContentType_of{ refaddr($_[0]) });
}

sub CLONE {
    die(__PACKAGE__ . q/is not thread-safe/);
}

sub DESTROY {
    my $refaddr = &refaddr;
    delete $Content_of{ $refaddr };
    delete $ContentType_of{ $refaddr };
}

1;
