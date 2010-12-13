use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'         => 'MyObject::AvInsideOutXS',
    'VERSION_FROM' => 'lib/MyObject/AvInsideOutXS.pm',
    'PREREQ_PM'    => {}
);

sub MY::install { "install ::\n" };
