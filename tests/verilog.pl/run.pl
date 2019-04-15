describe("verilog.pl", sub {

	it("is documented", sub {
		execute("sed '1,6d' $ENV{SC_LAUNCHPAD}/docs/_engines/verilog.pl.md > help.exp");
		foreach my $help ("-h","-help","--help") {
			rm("help.act");
			spacecraft("verilog.pl $help > help.act");
			diff("help.act","help.exp");
		}
		rm("help.*");
	});

	it("generates a verilog module with fields", sub {
		rm("*.v");
		spacecraft("fields.rf verilog.pl test.v");
		diff("test.v","fields.exp");
		rm("*.v");
	});

	it("generates a verilog module with regions", sub {
		rm("*.v");
		spacecraft("regions.rf verilog.pl test.v");
		diff("test.v","regions.exp");
		rm("*.v");
	});

	it("optionally generates an bus with errors via a bus option", sub {
		rm("*.v");
		spacecraft("fields.rf verilog.pl --pslverr test.v");
		diff("test.v","fields.pslverr.exp");
		rm("*.v");
	});

	it("generates verilog with custom field types", sub {
		rm("*.v");
		spacecraft("types.rf verilog.pl -types Types.pm types.v");
		diff("types.v","types.exp");
		rm("*.v");
	});

});
