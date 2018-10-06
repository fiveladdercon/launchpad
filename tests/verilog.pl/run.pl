use lib "$ENV{SC_LAUNCHPAD}/tests";
use run;

&rm("*.v");

&spacecraft("test.rf verilog.pl test.v");
&diff("test.v","test.exp");
&rm("test.v");

&spacecraft("test.rf verilog.pl --pslverr test.v");
&diff("test.v","pslverr.exp");
&rm("test.v");

&spacecraft("types.rf verilog.pl -types Types.pm types.v");
&diff("types.v","types.exp");


&report("verilog.pl");