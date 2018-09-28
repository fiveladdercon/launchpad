#-------------------------------------------------------------------------------
# Packages
#-------------------------------------------------------------------------------

use EngineAPI;
use EngineUtils;
use strict;

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

sub express {
	my $s = shift; return qr/$s/;
}

sub match {
	my $needle   = shift;
	my $haystack = shift;
	foreach my $pattern (@${haystack}) {
		return 1 if $needle =~ /$pattern/;
	}
	return 0;
}

sub filter {
	my $region = shift;
	my $keys   = shift;
	my $values = shift;
	while (my $node = $region->sc_get_next_child()) {
		while (my $key = $node->sc_get_next_property) {
			my $value = $node->sc_get_property($key);
			if ($key eq "filter") {
				if (&match($value,$values)) {
					$node->sc_drop_property($key);
				} else {
					$node = $node->sc_drop;
				}
			} elsif (&match($key,$keys)) {
				$node->sc_drop_property($key);
			}
			last unless $node; # Abort the loop when we've dropped the node
		}
		next unless $node; # Abort the iteration when we've dropped the node
		&filter($node,$keys,$values) if $node->sc_is_region;
	}
}

#-------------------------------------------------------------------------------
# Command Line
#-------------------------------------------------------------------------------

my @PROPS = ();
my @NODES = ();

while (@ARGV) {
	my $op = shift;
	if    ($op =~ /^-?-h(elp)?$/ ) { &uhelp;                      }
	elsif ($op =~ /^-?-k(eep)?/  ) { push @NODES, &express(shift); }
	else                           { push @PROPS, &express($op);   }
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

&filter(&sc_get_space(),\@PROPS,\@NODES);
