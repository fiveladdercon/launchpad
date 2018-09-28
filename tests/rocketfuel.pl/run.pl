use lib "$ENV{SC_LAUNCHPAD}/tests";
use run;

# Dump the original and generate a duplicate
&spacecraft("-R -I ../../example ../../example/soc.rf data.pl soc.exp rocketfuel.pl act");
# Strip the path & lineno from the orignal
&execute("sed -i 's/..\\/..\\/example\\///; /lineno/d' soc.exp");
# Dump the duplicate
&spacecraft("-R -I act act/soc.rf data.pl soc.act");
# Strip the path & lineno from the duplicate
&execute("sed -i 's/act\\///; /lineno/d' soc.act");
# Diff the original & duplicate
&diff("soc.act","soc.exp");
# Clean up
&rm("soc.* act");

&report("rocketfuel.pl");