package MyObject::HvRefXS;

use strict;
use vars qw[@ISA $VERSION];

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

sub new {
    @_ == 1 || die(q/Usage: / . __PACKAGE__ . q/->new()/);
    return bless( {}, $_[0] );
}

1;
