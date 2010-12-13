package MyObject::PseudoHash;

use strict;

BEGIN {

    ( $] < 5.009 )
     || die(q/Pseudo-hashes was removed from Perl 5.009/);

    if ( $] >= 5.008 ) {
        require warnings;
        warnings->unimport('deprecated');
    }
}

my %attributes = (
    content      => 1,
    content_type => 2,
);

sub new {
    @_ == 1 || die(q/Usage: / . __PACKAGE__ . q/->new()/);
    return bless( [ \%attributes ], $_[0] );
}

sub get_content {
    @_ == 1 || die(q/Usage: $object->get_content()/);
    return $_[0]->{content};
}

sub set_content {
    @_ == 2 || die(q/Usage: $object->set_content(content)/);
    $_[0]->{content} = $_[1];
}

sub has_content {
    @_ == 1 || die(q/Usage: $object->has_content()/);
    return exists($_[0]->{content});
}

sub get_content_type {
    @_ == 1 || die(q/Usage: $object->get_content_type()/);
    return $_[0]->{content_type};
}

sub set_content_type {
    @_ == 2 || die(q/Usage: $object->set_content_type(content_type)/);
    $_[0]->{content_type} = $_[1];
}

sub has_content_type {
    @_ == 1 || die(q/Usage: $object->has_content_type()/);
    return exists($_[0]->{content_type});
}

1;

