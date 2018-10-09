describe("logical.pl", sub {

	it("is documented", sub {
		execute("sed '1,6d' $ENV{SC_LAUNCHPAD}/docs/_engines/logical.pl.md > help.exp");
		foreach my $help ("-h","-help","--help") {
			rm("help.act");
			spacecraft("logical.pl $help > help.act");
			diff("help.act","help.exp");
		}
		rm("help.*");
	});

});
