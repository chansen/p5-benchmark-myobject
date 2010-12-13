package MyObject::HvRefEval;

use strict;

BEGIN {

    foreach my $attribute ( qw( content content_type ) ) {

        my $get = sprintf( <<'EOC', __PACKAGE__, ($attribute) x 3 );
        sub %s::get_%s {
            @_ == 1 || die(q/Usage: $object->get_%s()/);
            return $_[0]->{%s};
        };
EOC

        my $set = sprintf( <<'EOC', __PACKAGE__, ($attribute) x 4 );
        sub %s::set_%s {
            @_ == 2 || die(q/Usage: $object->set_%s(%s)/);
            $_[0]->{%s} = $_[1];
        };
EOC

        my $has = sprintf( <<'EOC', __PACKAGE__, ($attribute) x 3 );
        sub %s::has_%s {
            @_ == 1 || die(q/Usage: $object->has_%s()/);
            return exists($_[0]->{%s});
        };
EOC

        local $SIG{__DIE__};

        foreach ( $get, $set, $has ) {
            eval; die if $@;
        }
    }
}

sub new {
    @_ == 1 || die(q/Usage: / . __PACKAGE__ . q/->new()/);
    return bless( {}, $_[0] );
}

1;

