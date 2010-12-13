package MyObject::XS;

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

sub CLONE {
    die(__PACKAGE__ . q/is not thread-safe/);
}

1;

