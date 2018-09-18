#-------------------------------------------------------------------------------
# Packages
#-------------------------------------------------------------------------------

use EngineAPI;
use EngineUtils;
use strict;

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

sub map {
	my $options = shift;
	my $region  = shift;
	while (my $node = $region->sc_get_next_child()) {
		my $is_field = $node->sc_is_field;
		
		printf "%010xhb\t%010xhb\t%-10s\t%-10s\t%s\n",
			$node->sc_get_address($options->{address}),
			$node->sc_get_size($options->{size}),
			$node->sc_is_region ? "-" : $node->sc_get_value,
			$node->sc_is_typed ? $node->sc_get_type : "-",
			$node->sc_get_identifier 
			if $is_field ? $options->{fields} : ($node->sc_is_named && $options->{regions});

		&map($options,$node) unless $is_field;
	}
}

#-------------------------------------------------------------------------------
# Command Line
#-------------------------------------------------------------------------------

my $OUTPUT;
my $OPTIONS = {
	address => '%hW',
	size    => '%hb',
	fields  => 1,
	regions => 1
};

while (@ARGV) {
	my $op = shift;
	if    ($op =~ /^-?-h(elp)?$/) { &uhelp;                      }
	elsif ($op eq "-address"    ) { $OPTIONS->{address} = shift; }
	elsif ($op eq "-size"       ) { $OPTIONS->{size}    = shift; }
	elsif ($op eq "-f"          ) { $OPTIONS->{regions} = 0;     }
	elsif ($op eq "-r"          ) { $OPTIONS->{fields}  = 0;     }
	else                          { $OUTPUT = $op;               }
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

&uopen($OUTPUT);

printf("#%-9s\t%-10s\t%-10s\t%-10s\t%s\n","Address","Size","Value","Type","Identifier");
&map($OPTIONS,&sc_get_space());

&uclose($OUTPUT);
