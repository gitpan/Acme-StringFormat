#!perl

use strict;
use warnings;

use Benchmark qw(:all);

my $fmt1 = '[%s]';
my $fmt2 = '[%s][%d]';
my $arg1 = 'foo';
my $arg2 = 10;

print "number of arguments: 1\n";
cmpthese timethese -1 => {
	'sprintf' => sub{
		my $s = sprintf $fmt1, $arg1;
	},
	'%' => sub{
		use Acme::StringFormat;
		my $s = $fmt1 % $arg1;
	},
};


print "number of arguments: 2\n";
cmpthese timethese -1 => {
	'sprintf' => sub{
		my $s = sprintf $fmt2, $arg1, $arg2;
	},
	'%' => sub{
		use Acme::StringFormat;
		my $s = $fmt2 % $arg1 % $arg2;
	},
};
