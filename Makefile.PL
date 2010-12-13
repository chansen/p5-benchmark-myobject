use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME => 'Benchmark::MyObject',
    DIR  => [ 'MyObject-HvInsideOutXS', 'MyObject-HvRefXS', 'MyObject-XS', ( $] < 5.006 ) ? () : qw(MyObject-AvInsideOutXS MyObject-AvRefXS) ],
);

sub MY::install { "install ::\n" };

