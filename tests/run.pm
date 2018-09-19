package run;
use base qw(Exporter);

@EXPORT = qw(pass fail execute spacecraft diff rm report);

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

1;