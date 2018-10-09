package run;
use base qw(Exporter);

@EXPORT = qw(execute spacecraft diff rm fail describe it);

#
# Command Line Execution
#

sub execute {
	my $format = shift;
	my $cmd    = sprintf($format,@_);
	# print("$cmd\n");
	fail($cmd) if system("$cmd");
}

sub spacecraft {
	my $cmd = shift;
	my $ver = shift; $ver = $ver ? "-${ver}-x86_64" : "";
	execute("$ENV{SC_LAUNCHPAD}/bin/spacecraft${ver} -Q -u ${cmd}");
}

sub diff {
	my $left  = shift;
	my $right = shift;
	return fail("$left not found")  unless -e $left;
	return fail("$right not found") unless -e $right;
	execute("diff $left $right");
}

sub rm {
	execute("rm -rf @_");
}

#
# Mocha style testing:
#

binmode STDOUT, ":utf8";

my $LEVEL = 1;
my $TESTS = 0;
my $FAILS = 0;

sub fail {
	my $format = shift;
	printf "** \e[31mFAIL\e[0m : $format\n", @_;
	$FAILS++;
}

sub describe {
	my $string   = shift;
	my $callback = shift;
	my $TAB      = "  " x $LEVEL;
	printf("\n") if ($LEVEL == 1);
	printf("${TAB}\e[1m$string\e[0m\n");
	$LEVEL++;
	&$callback();
	$LEVEL--;
	return unless ($LEVEL == 1);
	$TESTS = ($TESTS == 1) ? "1 test" : "${TESTS} tests";
	if ($FAILS) {
		printf("\n${TAB}\e[31m\x{2717} ${FAILS} of ${TESTS} failed\e[0m\n\n");
		exit(1);
	} else {
		printf("\n${TAB}\e[32m\x{2713} ${TESTS} complete\e[0m\n\n");
		exit(0);
	}
}

sub it {
	my $string   = shift;
	my $callback = shift;
	my $baseline = $FAILS;
	my $TAB      = "  " x $LEVEL;
	&$callback(); $TESTS++;
	my $result   = ($FAILS != $baseline) ? "\e[31m\x{2717}" : "\e[32m\x{2713}";
	print ("${TAB}${result}\e[0m ${string}\n");
}


1;