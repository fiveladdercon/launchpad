describe("map.pl", sub {

	it("is documented", sub {
		execute("sed '1,6d' $ENV{SC_LAUNCHPAD}/docs/_engines/map.pl.md > help.exp");
		foreach my $help ("-h","-help","--help") {
			rm("help.act");
			spacecraft("map.pl $help > help.act");
			diff("help.act","help.exp");
		}
		rm("help.*");
	});

	it("outputs the model in a simple line based format", sub {
		rm("*.act");
		spacecraft("-R -I ../../example ../../example/soc.rf map.pl soc.act");
		diff("soc.act","soc.exp");
		rm("*.act");
	});

});
