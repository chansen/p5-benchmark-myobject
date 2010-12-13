package MyObject::AvInsideOutXS;

use strict;
use constant HAS_READONLY => !!Internals->can('SvREADONLY');
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

mk_attribute 'content',      my @Content;
mk_attribute 'content_type', my @ContentType;

sub dump_refaddr {
    require Scalar::Util;
    warn sprintf '@Content refaddr: 0x%X', Scalar::Util::refaddr(\@Content);
}

my @_free;
my $_next = 0;

sub new {
    @_ == 1 || die(q/Usage: / . __PACKAGE__ . q/->new()/);
    my ($class) = @_;

    my $instance_id;
    if ( exists($_free[$_next]) ) {
        $instance_id = $_next;
        $_next = $_free[$_next];
        delete($_free[$instance_id]);
    }
    else {
        $instance_id = $_next++;
    }

    my $self = bless( \$instance_id, $class );

    if ( HAS_READONLY ) {
        Internals::SvREADONLY( $$self, 1 );
    }

    return $self;
}

sub DESTROY {
    my ($self) = @_;
    my $instance_id = $$self;

    delete($Content[$instance_id]);
    delete($ContentType[$instance_id]);

    $_free[$instance_id] = $_next;
    $_next = $instance_id;
}

1;

