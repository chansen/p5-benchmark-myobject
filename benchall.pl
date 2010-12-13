#!/usr/bin/env perl -w

use strict;

use File::Glob ':glob';

my @bins = @ARGV
  ? grep { ( -f $_ && -x $_ ) || die(qq/$_: is not a executable file/) } @ARGV
  : -e "/opt/perl/" 
    ? glob('/opt/perl/*/bin/perl')
    : $^X;

sub run ($;$) {
    my ( $command, $fail_ok ) = @_;

    my $status = system($command);

    ( $fail_ok || $status == 0 )
      || die(qq/Couldn't execute command '$command': '$?'/);
}

run('make distclean') if -d 'blib';

foreach my $perl ( @bins ) {
    run("$perl Makefile.PL");
    run('make');
    run("$perl benchmark.pl >> myresult.txt");
    run('make distclean');
}

