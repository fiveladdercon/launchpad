use lib "$ENV{SC_LAUNCHPAD}/tests";
use run;

&rm("dma.act");
&spacecraft("../../example/dma.rf data.pl dma.act");
&diff("dma.act","dma.exp");
&rm("dma.act");

&report("data.pl");