sub usage { print <<'_';

Usage : map.pl [--help|-h] [OUTPUT]

  map.pl outputs named fields and regions in the space in a simple
  line based format for diffing and quickly checking the input.

  Output is sent to stdout unless an OUTPUT file is specified.

_
	&sc_error(@_) if @_; exit; 
}

#-------------------------------------------------------------------------------
# Packages
#-------------------------------------------------------------------------------

use EngineAPI;
use strict;

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

sub map {
	my $region  = shift;
	while (my $node = $region->sc_get_next_child()) {
		
		printf "%010xhb\t%010xhb\t%-10s\t%-10s\t%s\n",
			$node->sc_get_address("%d"),
			$node->sc_get_size("%d"),
			$node->sc_is_region ? "-" : $node->sc_get_value,
			$node->sc_is_typed ? $node->sc_get_type : "-",
			$node->sc_get_identifier 
			if $node->sc_is_named;

		&map($node) if $node->sc_is_region;
	}
}

#-------------------------------------------------------------------------------
# Command Line
#-------------------------------------------------------------------------------

my $OUTPUT;

while (@ARGV) {
	my $op = shift;
	if    ($op eq "--help") { &usage;        }
	elsif ($op eq "-h"    ) { &usage;        }
	else                    { $OUTPUT = $op; }
}

if ($OUTPUT) {
	open(OUTPUT,">$OUTPUT") or &sc_fatal("Can't open $OUTPUT for writting:$!");
	select OUTPUT;
}

printf("#%-9s\t%-10s\t%-10s\t%-10s\t%s\n","Address","Size","Value","Type","Identifier");
&map(&sc_get_space());

if ($OUTPUT) {
	close(OUTPUT);
}
