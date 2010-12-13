package MyObject::HvRefAutoload;

use strict;
use vars q[$AUTOLOAD];

sub new {
    @_ == 1 || die(q/Usage: / . __PACKAGE__ . q/->new()/);
    return bless( {}, $_[0] );
}

sub DESTROY { }

sub AUTOLOAD {
    my ( $package, $method ) = ( $AUTOLOAD =~ /\A(.+)::([^:]+)\z/ );

    if ( my ( $op, $attribute ) = ( $method =~ /\A(get|set|has)_(foo|bar)\z/ ) ) {

        if ( $op eq 'get' ) {
            @_ == 1 || die(q/Usage: $object->get_/ . $attribute . q/()/);
            return $_[0]->{$attribute};
        }
        elsif ( $op eq 'has' ) {
            @_ == 1 || die(q/Usage: $object->has_/ . $attribute . q/()/);
            return exists($_[0]->{$attribute});
        }
        else {
            @_ == 2 || die(q/Usage: $object->set_/ . $attribute . qq/($attribute)/);
            $_[0]->{$attribute} = $_[1];
        }
    }
    else {
        die(qq/Can't locate object method "$method" via package "$package"/);
    }
}

1;

