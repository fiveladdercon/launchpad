describe("structs.pl", sub {

	it("is documented", sub {
		execute("sed '1,7d' $ENV{SC_LAUNCHPAD}/docs/_engines/structs.pl.md > help.exp");
		foreach my $help ("-h","-help","--help") {
			rm("help.act");
			spacecraft("structs.pl $help > help.act");
			diff("help.act","help.exp");
		}
		rm("help.*");
	});

});
