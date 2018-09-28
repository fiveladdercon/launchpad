use lib "$ENV{SC_LAUNCHPAD}/tests";
use run;

&rm("*.act");

# Property Filtering

&spacecraft("property.rf filter.pl -p verilog data.pl | grep properties > property.act");
&diff("property.act","property.exp");

# Node Filtering

foreach my $audience ('customer_X','customer_Y','customer_Z','engineering') {
	&spacecraft("nodes.rf filter.pl -k $audience map.pl $audience.act");
	&diff("$audience.act","$audience.exp");
}

&spacecraft("nodes.rf filter.pl -k customer_X -k eng map.pl nodes.act");
&diff("nodes.act","nodes.exp");

# &rm("*.act");

&report("filter.pl");