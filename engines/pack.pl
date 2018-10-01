#-------------------------------------------------------------------------------
# Packages
#-------------------------------------------------------------------------------

use EngineAPI;
use EngineUtils;
use strict;

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

sub pack {
	my $region = shift;
	while (my $node = $region->sc_get_next_child) {
		if ($node->sc_is_region) {
			if ($node->sc_is_typed) {
				$node->sc_set_property("pack",$node->sc_get_type);
				$node->sc_set_type(undef);
			} elsif ($node->sc_has_property("pack")) {
				$node->sc_set_type($node->sc_get_property("pack"));
				$node->sc_drop_property("pack");
			}
			&pack($node);
		}
	}
}

#-------------------------------------------------------------------------------
# Command Line
#-------------------------------------------------------------------------------

while (@ARGV) {
	my $op = shift;
	if ($op =~ /^-?-h(elp)?$/) { &uhelp;                             }
	else                       { &uhelp("$op is an invalid option"); }
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

&pack(&sc_get_space);