use 5.010_000;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME		=> 'Acme::StringFormat',
	AUTHOR		=> 'Goro Fuji  <gfuji (at) cpan.org >',
	VERSION_FROM	=> 'StringFormat.pm',
	ABSTRACT_FROM	=> 'StringFormat.pm',

	LICENSE		 => 'perl',

	clean		=> { FILES => 'Acme-StringFormat-*' },
);
