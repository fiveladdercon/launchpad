describe("filter.pl", sub {

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

	describe("property filtering", sub {

		it("removes properties on nodes that match the command line pattern", sub {
			rm("*.act");
			spacecraft("property.rf filter.pl -p verilog data.pl | grep properties > property.act");
			diff("property.act","property.exp");
			rm("*.act");
		});

	});

	describe("node filtering", sub {

		it("removes nodes with -filter properties that don't match the command line pattern", sub {
			rm("*.act");
			foreach my $audience ('customer_X','customer_Y','customer_Z','engineering') {
				spacecraft("nodes.rf filter.pl -k $audience map.pl $audience.act");
				diff("$audience.act","$audience.exp");
				rm("*.act");
			}
		});

		it("supports multiple patterns on the command line", sub {
			rm("*.act");
			spacecraft("nodes.rf filter.pl -k customer_X -k eng map.pl nodes.act");
			diff("nodes.act","nodes.exp");
			rm("*.act");
		});

	});

});
