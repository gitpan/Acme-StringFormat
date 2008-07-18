#!perl

use strict;
use warnings;
use warnings FATAL => 'numeric';

use Test::More tests => 25;

eval{
	my $s = '[%s]' % 'foo';
};
like $@, qr/isn't numeric/, 'out of scope';

{
	use Acme::StringFormat;

	is 4   % 2,   0, 'iv % iv';
	is 4.2 % 2.1, 0, 'nv % nv';

	is '[%s]' % 'foo', '[foo]', 'pv % pv (in scope)';
	is '%s' %'foo', 'foo', 'pv % pv';

	is '[%d]' % 10, '[10]', 'pv % iv';
	is '[%.02f]' % 0.1, '[0.10]', 'pv % nv';

	is '[%s][%s]' % 'foo', '[foo][%s]', 'fmt*2 x arg*1';
	is '[%s][%s]' % 'foo' % 'bar', '[foo][bar]', 'fmt*2 x arg*2';

	{
		no warnings 'printf';

		is 'foo' % 'bar', 'foo', 'no parameters';
		is '[%%]' % 'foo', '[%]', '%';
	}
	is '[%%%s]' % 'foo', '[%foo]', '%%%s';

	{
		no Acme::StringFormat;

		eval{
			my $s = '[%s]' % 'foo';
		};
		like $@, qr/isn't numeric/, 'out of scope';
	}

	is '[%s]' % 'foo', '[foo]', 'pv % pv (in scope)';


	eval{
		my $s = in_func('[%s]', 'foo');
	};
	like $@, qr/isn't numeric/, 'out of scope (in func)';

	use Acme::StringFormat;

	is '[%s]' % 'foo', '[foo]', 'pv % pv (in deep scope)';

	no Acme::StringFormat;

	eval{
		my $s = in_func('[%s]', 'foo');
	};
	like $@, qr/isn't numeric/, 'out of scope';
}

# assign, refcount
{
	use Acme::StringFormat;
	my $f = '[%s]';
	my $s = 'foo';

	$f %= $s;
	is Internals::SvREFCNT($f), 1, 'refcnt of fmt';
	is Internals::SvREFCNT($s), 1, 'refcnt of arg';
	is $f, '[foo]', 'formated';

	$f = '[%s]';
	$f %= $f;
	is Internals::SvREFCNT($f), 1, 'refcnt of fmt (self assign)';
	is $f, '[[%s]]', 'formated';
}

eval{
	my $s = '[%s]' % 'foo';
};
like $@, qr/isn't numeric/, 'out of scope';

eval{
	use warnings FATAL => 'syntax';
	use Acme::StringFormat;
	my $s = 'foo' % '[%s]';
};
like $@, qr/mismatch/, 'arguments mismatch';

eval{
	use warnings FATAL => 'syntax';
	use Acme::StringFormat;
	my $s = '%%' % 'foo';
};
like $@, qr/mismatch/, 'arguments mismatch';


sub in_func{
	$_[0] % $_[1];
}
