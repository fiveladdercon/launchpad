my $SUITES = 0;
my $FAILS  = 0;

foreach my $test (glob("*/run.pl")) {
	my ($suite) = split /\//, $test;
	chdir($suite);
	$FAILS++ if system("perl -I $ENV{SC_LAUNCHPAD}/tests -Mrun run.pl");
	$SUITES++;
	chdir("..");
}

binmode STDOUT, ":utf8";

$SUITES = ($SUITES == 1) ? "1 suite" : "${SUITES} suites";
if ($FAILS) {
	printf("  \e[31m\x{2717} ${FAILS} of ${SUITES} failed\e[0m\n\n");
	exit(1);
} else {
	printf("  \e[32m\x{2713} ${SUITES} complete\e[0m\n\n");
	exit(0);
}


# printf("***********************************************\n");
# printf("                                               \n");
# printf("               \e[3%s E D\e[0m\n", $FAILS ? "1mF A I L" : "2mP A S S");
# printf("                                               \n");
# printf("***********************************************\n");
# printf("%d tests, %d passed, %d failed\n",$TESTS,$TESTS-$FAILS,$FAILS);
