package run;
use base qw(Exporter);

@EXPORT = qw(pass fail execute spacecraft diff rm report describe it);

$FAIL = 0;
$TEST = 0;

sub pass {
	my $format = shift;
	printf "** \e[32mPASS\e[0m : $format\n", @_;
}

sub fail {
	my $format = shift;
	printf "** \e[31mFAIL\e[0m : $format\n", @_;
	$FAIL++;
}

sub execute {
	my $format = shift;
	my $cmd    = sprintf($format,@_);
	# print("$cmd\n");
	&fail($cmd) if system("$cmd");
	$TEST++;
}

sub spacecraft {
	my $cmd = shift;
	my $ver = shift; $ver = $ver ? "-${ver}-x86_64" : "";
	&execute("$ENV{SC_LAUNCHPAD}/bin/spacecraft${ver} -Q -u ${cmd}");
}

sub diff {
	my $left  = shift;
	my $right = shift;
	return &fail("$left not found")  unless -e $left;
	return &fail("$right not found") unless -e $right;
	&execute("diff $left $right");
}

sub rm {
	&execute("rm -rf @_");
}

sub report {
	my $test = shift;
	if ($FAIL) {
		&fail("$test had %d failure%s.",$FAIL,$FAIL>1?"s":"");
		exit(1);
	} else {
		&pass("$test passed.");
		exit(0);
	}
}

#
# Mocha style testing:
#

binmode STDOUT, ":utf8";

my $LEVEL = 1;
my $TESTS = 0;

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
	if ($FAIL) {
		printf("\n${TAB}\e[31m\x{2717} ${FAIL} of ${TESTS} tests failed\e[0m\n\n");
		exit(1);
	} else {
		printf("\n${TAB}\e[32m\x{2713} ${TESTS} tests complete\e[0m\n\n");
		exit(0);
	}
}

sub it {
	my $string   = shift;
	my $callback = shift;
	my $baseline = $FAIL;
	my $TAB      = "  " x $LEVEL;
	&$callback(); $TESTS++;
	my $result   = ($FAIL != $baseline) ? "\e[31m\x{2717}" : "\e[32m\x{2713}";
	print ("${TAB}${result}\e[0m ${string}\n");
}

1;