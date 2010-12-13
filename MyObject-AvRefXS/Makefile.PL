use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'         => 'MyObject::AvRefXS',
    'VERSION_FROM' => 'lib/MyObject/AvRefXS.pm',
    'PREREQ_PM'    => {}
);

sub MY::install { "install ::\n" };
