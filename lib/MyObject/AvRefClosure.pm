package MyObject::AvRefClosure;

use strict;

BEGIN {

    my $index = 0;

    foreach my $attribute ( qw( content content_type ) ) {

        my $slot = $index++;

        my $get = sub {
            @_ == 1 || die(q/Usage: $object->get_/ . $attribute . q/()/);
            return $_[0]->[$slot];
        };

        my $set = sub {
            @_ == 2 || die(q/Usage: $object->set_/ . $attribute . qq/($attribute)/);
            $_[0]->[$slot] = $_[1];
        };

        my $has = sub {
            @_ == 1 || die(q/Usage: $object->has_/ . $attribute . q/()/);
            return exists($_[0]->[$slot]);
        };

        no strict 'refs';
        *{ q/get_/ . $attribute } = $get;
        *{ q/set_/ . $attribute } = $set;
        *{ q/has_/ . $attribute } = $has;
    }
}

sub new {
    @_ == 1 || die(q/Usage: / . __PACKAGE__ . q/->new()/);
    return bless( [], $_[0] );
}

1;

