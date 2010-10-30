  use 5.006001;
  use ExtUtils::MakeMaker;
  # See lib/ExtUtils/MakeMaker.pm for details of how to influence
  # the contents of the Makefile that is written.
  WriteMakefile(
      NAME              => 'agordamon',
      VERSION_FROM      => 'lib/agordamon.pm', # finds $VERSION
      PREREQ_PM         => {}, # e.g., Module::Name => 1.1
      ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
         ( AUTHOR         => 'Christian Schneemann <schneemann@b1-systems.de>') : ()),
  );

