describe("data.pl", sub {

	it("is documented", sub {
		rm("*.act");
		execute("sed '1,6d' $ENV{SC_LAUNCHPAD}/docs/_engines/data.pl.md > help.exp");
		foreach my $help ("-h","-help","--help") {
			rm("help.act");
			spacecraft("data.pl $help > help.act");
			diff("help.act","help.exp");
		}
		rm("help.*");
	});

	it("dumps data from the model in tree format", sub {
		rm("*.act");
		spacecraft("../../example/dma.rf data.pl dma.act");
		diff("dma.act","dma.exp");
		rm("*.act");
	});

});
