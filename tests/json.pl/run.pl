describe("json.pl", sub {

	it("is documented", sub {
		execute("sed '1,6d' $ENV{SC_LAUNCHPAD}/docs/_engines/json.pl.md > help.exp");
		foreach my $help ("-h","-help","--help") {
			rm("help.act");
			spacecraft("json.pl $help > help.act");
			diff("help.act","help.exp");
		}
		rm("help.*");
	});

	it("outputs the model as a JSON object", sub {
		rm("*.act");
		spacecraft("-R -I ../../example ../../example/soc.rf json.pl -space 4 soc.act");
		diff("soc.act","soc.exp");
		rm("*.act");
	});

});
