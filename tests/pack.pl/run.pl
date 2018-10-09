describe("pack.pl", sub {

	it("is documented", sub {
		execute("sed '1,6d' $ENV{SC_LAUNCHPAD}/docs/_engines/pack.pl.md > help.exp");
		foreach my $help ("-h","-help","--help") {
			rm("help.act");
			spacecraft("pack.pl $help > help.act");
			diff("help.act","help.exp");
		}
		rm("help.*");
	});

});
