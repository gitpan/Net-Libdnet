# $Id: Makefile.PL,v 1.3 2004/09/06 11:13:55 vman Exp $

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME' => 'Net::Libdnet',
    'VERSION_FROM'=> 'Libdnet.pm',
    'LIBS' => ['-ldnet'],
    'INC' => '-I/usr/local/include',
);
