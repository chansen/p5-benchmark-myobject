package MyObject::AvRef;

use strict;

sub INDEX_CONTENT      () { 0 }
sub INDEX_CONTENT_TYPE () { 1 }

sub new {
    @_ == 1 || die(q/Usage: / . __PACKAGE__ . q/->new()/);
    return bless( [], $_[0] );
}

sub get_content {
    @_ == 1 || die(q/Usage: $object->get_content()/);
    return $_[0]->[INDEX_CONTENT];
}

sub set_content {
    @_ == 2 || die(q/Usage: $object->set_content(content)/);
    $_[0]->[INDEX_CONTENT] = $_[1];
}

sub has_content {
    @_ == 1 || die(q/Usage: $object->has_content()/);
    return exists($_[0]->[INDEX_CONTENT]);
}

sub get_content_type {
    @_ == 1 || die(q/Usage: $object->get_content_type()/);
    return $_[0]->[INDEX_CONTENT_TYPE];
}

sub set_content_type {
    @_ == 2 || die(q/Usage: $object->set_content_type(content_type)/);
    $_[0]->[INDEX_CONTENT_TYPE] = $_[1];
}

sub has_content_type {
    @_ == 1 || die(q/Usage: $object->has_content_type()/);
    return exists($_[0]->[INDEX_CONTENT_TYPE]);
}

1;

