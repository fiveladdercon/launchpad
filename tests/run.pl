my $FAILS = 0;
my $TESTS = 0;

foreach my $test (glob("*/run*")) {
	my ($dir,$run) = split /\//, $test;
	chdir($dir);
	if ($run eq "run.pl") {
		$FAILS += system("perl $run");
	}
	chdir("..");
	$TESTS++;
}

printf("***********************************************\n");
printf("                                               \n");
printf("               \e[3%s E D\e[0m\n", $FAILS ? "1mF A I L" : "2mP A S S");
printf("                                               \n");
printf("***********************************************\n");
printf("%d tests, %d passed, %d failed\n",$TESTS,$TESTS-$FAILS,$FAILS);
