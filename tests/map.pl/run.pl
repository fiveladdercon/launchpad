use lib "$ENV{SC_LAUNCHPAD}/tests";
use run;

&rm("soc.act");
&spacecraft("-R -I ../../example ../../example/soc.rf map.pl soc.act");
&diff("soc.act","soc.exp");
&rm("soc.act");

&report("map.pl");