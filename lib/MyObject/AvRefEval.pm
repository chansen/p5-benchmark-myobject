package MyObject::AvRefEval;

use strict;

BEGIN {

    my $index = 0;

    foreach my $attribute ( qw( content content_type ) ) {

        my $slot = $index++;

        my $get = sprintf( <<'EOC', __PACKAGE__, ($attribute) x 2, $slot );
        sub %s::get_%s {
            @_ == 1 || die(q/Usage: $object->get_%s()/);
            return $_[0]->[%u];
        };
EOC

        my $set = sprintf( <<'EOC', __PACKAGE__, ($attribute) x 3, $slot );
        sub %s::set_%s {
            @_ == 2 || die(q/Usage: $object->set_%s(%s)/);
            $_[0]->[%u] = $_[1];
        };
EOC

        my $has = sprintf( <<'EOC', __PACKAGE__, ($attribute) x 2, $slot );
        sub %s::has_%s {
            @_ == 1 || die(q/Usage: $object->has_%s()/);
            return exists($_[0]->[%u]);
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
    return bless( [], $_[0] );
}

1;

