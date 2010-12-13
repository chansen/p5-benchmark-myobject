package MyObject::HvInsideOutXS;

use strict;
use constant HAS_READONLY => !!Internals->can('SvREADONLY');
use vars qw[@ISA $VERSION];

use Scalar::Util qw[refaddr];

BEGIN {
    $VERSION = 0.01;

    if ( $] >= 5.006 ) {
        require XSLoader; XSLoader::load( __PACKAGE__, $VERSION );
    }
    else {
        @ISA = ('DynaLoader');
        require DynaLoader; __PACKAGE__->bootstrap($VERSION);
    }
}

mk_attribute 'content',      my %Content_of;
mk_attribute 'content_type', my %ContentType_of;

sub dump_refaddr {
    require Scalar::Util;
    warn sprintf '@Content refaddr: 0x%X', Scalar::Util::refaddr(\%Content_of);
}

sub new {
    @_ == 1 || die(q/Usage: / . __PACKAGE__ . q/->new()/);
    my $self = bless( \do{ my $o }, $_[0] );

    if ( HAS_READONLY ) {
        Internals::SvREADONLY( $$self, 1 );
    }

    return $self;
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

