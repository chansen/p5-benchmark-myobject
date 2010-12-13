#!/usr/bin/env perl -w

use strict;

BEGIN {
    if ( -d './blib' ) {
        require blib; blib->import;
    }
    else {
        require lib; lib->import('./lib');
    }
}

use Config      qw[%Config];
use MyBenchmark qw[cmpthese timestr timethese];

my @classes = qw[
    MyObject::AvInsideOut
    MyObject::AvRef
    MyObject::AvRefClosure
    MyObject::AvRefEval
    MyObject::HvRef
    MyObject::HvRefEval
    MyObject::HvRefClosure
];

{
    my @requires_Scalar_Util = qw[
        MyObject::HvInsideOut
        MyObject::HvInsideOutCachedId
    ];

    if ( eval { require Scalar::Util; 1; } ) {
        push @classes, @requires_Scalar_Util;
    }
    else {
        warn sprintf( "skipping %s (requires Scalar::Util)\n",
          join( ', ', @requires_Scalar_Util ) );
    }
}

{
    my @requires_Hash_Util_FieldHash = qw[
        MyObject::HvFieldHash
        MyObject::HvFieldHashCachedId
    ];

    if ( eval { require Hash::Util::FieldHash; 1; } ) {
        push @classes, @requires_Hash_Util_FieldHash;
    }
    else {
        warn sprintf( "skipping %s (requires Hash::Util::FieldHash)\n",
          join( ', ', @requires_Hash_Util_FieldHash ) );
    }
}

{
    if ( $] < 5.009 ) {
        push @classes, 'MyObject::PseudoHash';
    }
    else {
        warn "skipping MyObject::PseudoHash (Pseudo-hashes was removed from Perl 5.009)\n";
    }
}

{
    my @requires_compilation = qw[
        MyObject::AvInsideOutXS
        MyObject::AvRefXS
        MyObject::HvInsideOutXS
        MyObject::HvRefXS
        MyObject::XS
    ];

    my @skipping;

    foreach my $class ( @requires_compilation ) {

        eval "use $class; 1;";

        if ($@) {
            push( @skipping, $class );
        }
        else {
            push( @classes, $class );
        }
    }

    if ( @skipping ) {
        warn sprintf( "skipping %s (requires compiler and compilation)\n",
          join( ', ', @skipping ) );
    }
}

{
    if ( $] < 5.006 ) {
        my @skipping = grep { /^MyObject::(?:Av|PseudoHash)/ } @classes;

        if ( @skipping ) {
            warn sprintf( "skipping %s (requires exists() support on arrays)\n",
              join( ', ', @skipping ) );

            my %skip; @skip{@skipping} = (1) x @skipping;

            @classes = grep { !$skip{$_} } @classes;
        }
    }
}

sub do_sanity_check ($) {
    my ($class) = @_;

    my $object = $class->new;

    ( !$object->has_content )
      || die(qq/$class->has_content_type != false/);

    $object->set_content('content');

    ( $object->has_content )
      || die(qq/$class->has_content != true/);

    ( $object->get_content eq 'content' )
      || die(qq/$class->get_content ne 'content'/);

    ( !$object->has_content_type )
      || die(qq/$class->has_content != false/);

    $object->set_content_type('content_type');

    ( $object->has_content_type )
      || die(qq/$class->has_content_type != true/);

    ( $object->get_content_type eq 'content_type' )
      || die(qq/$class->get_content_type ne 'content_type'/);
}

sub mk_accessor_closure ($) {
    my ($class) = @_;

    my $object = $class->new;
       $object->set_content('content');

    return sub {
        ( $object->get_content eq 'content' )
          || die(qq/$class->get_content ne 'content'/);
    };
}

sub mk_mutator_closure ($) {
    my ($class) = @_;

    my $object = $class->new;

    return sub {
        $object->set_content('content');
    };
}

sub mk_predicate_closure ($) {
    my ($class) = @_;

    my $object = $class->new;
       $object->set_content('content');

    return sub {
        ( $object->has_content )
          || die(qq/$class->has_content != true/);
    };
}


my $bench = {};

foreach my $class ( @classes ) {

    eval "use $class; 1;"; die if $@;

    do_sanity_check($class);

    ( my $title = $class ) =~ s/^MyObject:://;
         $title =~ s/InsideOut/InOut/;
         $title =~ s/HvFieldHash/HvFHash/;
         $title =~ s/Autoload/Aload/;

    $bench->{ accessor  }->{$title} = mk_accessor_closure($class);
    $bench->{ mutator   }->{$title} = mk_mutator_closure($class);
    $bench->{ predicate }->{$title} = mk_predicate_closure($class);
}

my @vars = map { sprintf( '%s=%s', $_, defined($Config{$_}) ? $Config{$_} : 'undef' ) }
          grep { exists($Config{$_}) } ( 'optimize', $Config{usethreads} ? qw(use5005threads useithreads) : qw(usethreads), 'usemultiplicity' );

my $uname = qx/uname -prs/;
   $uname ||= sprintf( "%s %s", $Config{osname}, $Config{osvers} );

chomp($uname);

printf("\n$] %s (%s)\n\n", $uname, join(', ', @vars ) );

foreach my $method ( qw[accessor mutator predicate] ) {
    do_bench( $method, $bench->{$method} );
}

sub do_bench {
    my ( $method, $benchmarks ) = @_;

    printf( "\n-------| %s\n\n", ucfirst($method) );

    my $results = timethese( 4e6, $benchmarks, 'none' );

    foreach my $result ( sort keys %{ $results } ) {
        printf( "%-15s %s\n", $result, timestr( $results->{ $result } ) );
    }

    print("\n");

    cmpthese($results);
}

