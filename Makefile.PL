# $Id: Makefile.PL,v 1.1 2007/10/12 15:38:55 drhyde Exp $

use ExtUtils::MakeMaker;

use strict;
$^W = 1;

WriteMakefile(
    NAME         => 'Devel::AssertLib',
    VERSION_FROM => 'lib/Devel/AssertLib.pm',
    PREREQ_PM    => {
        'Test::More'       => 0.62,  # too high? but it works
    },
);
