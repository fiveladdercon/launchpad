#-------------------------------------------------------------------------------
# Packages
#-------------------------------------------------------------------------------

use strict;
use EngineAPI;
use EngineUtils;
use Verilog::Buses;

#-------------------------------------------------------------------------------
package Slave;
#-------------------------------------------------------------------------------
#
#  A Slave is a Module that uses a Bus to access Fields
#
use EngineAPI;
use Verilog::Module;
use Verilog::Fields;
use base ('Module');

#
# $Slave = new Slave($Bus);
#
# A public method that returns a new instance of a Slave.
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $Bus      = shift;
	my $space    = &sc_get_space();
	my $this     = Module::new($class,$space->sc_get_type || "bobo");

	$Bus->decoder($this);

	my @nodes = &bounded($space);

	foreach my $node (@nodes) {
		if ($node->sc_is_field) {
			my $name = $node->sc_get_identifier;
			my $Type = $node->sc_get_type;
			my $file = $node->sc_get_filename;
			my $line = $node->sc_get_lineno;
			eval { $this->{fields}->{$name} = $Type->new($this,$node); } or 
				&sc_fatal("Field $name declared on line $line in $file has unknown type: $Type.");
		}
	}

	foreach my $node (&bounded($space)) {
		if ($node->sc_is_field) {
			$this->{fields}->{$node->sc_get_identifier}->implementation;
		} else {
			$this->region($node);
		}
	}

	$Bus->return($this);

	return $this;
}

#
# @nodes = &bounded($space);
#
# A backstage function that returns the nodes in the space that are 
# implemented inside the Module.  These are:
#
#  o Fields
#  o Typed Regions that are not imported
#  o Named Childless Regions (i.e. RAMs and ROMS)
#
# Note that this is not a method of the Slave class, but just a regular
# old function.
#
sub bounded {
	my $region = shift;
	my @nodes  = ();
	while (my $node = $region->sc_get_next_child) {
		if ($node->sc_is_field) {
			push @nodes, $node;
		} elsif ($node->sc_is_typed and not $node->sc_has_property("verilog:import")) {
			push @nodes, $node;
		} elsif ($node->sc_is_named and not $node->sc_has_children) {
			push @nodes, $node;
		} else {
			push @nodes, &bounded($node);
		}
	}
	return @nodes;
}

sub region {
	my $this   = shift;
	my $region = shift;

	printf("REGION %s %s\n",$region->sc_get_identifier);
}

#-------------------------------------------------------------------------------
# Command Line
#-------------------------------------------------------------------------------
package main;

my $OUTPUT;
my $BUS;
my @TYPES   = ();
my %OPTIONS = (
	addrwidth  => 32,
	datawidth  => 32,
	optimize   => 0,
	register   => 0,
	errors     => 1,
	errorports => 0,
);

while (@ARGV) {
	my $op = shift;
	if    ($op =~ /^-?-h(elp)?$/) { &uhelp;                      }
	elsif ($op eq "-bus"        ) { $BUS = shift;                }
	elsif ($op eq "-type"       ) { push @TYPES, shift;          }
	elsif ($op eq "-addrwidth"  ) { $OPTIONS{addrwidth} = shift; }
	elsif ($op eq "-datawidth"  ) { $OPTIONS{datawidth} = shift; }
	elsif ($op eq "-optimize"   ) { $OPTIONS{optimize}  = 1;     }
	elsif ($op eq "-register"   ) { $OPTIONS{register}  = 1;     }
	else                          { $OUTPUT = $op;               }
}

my $Bus   = new APB(%OPTIONS);
my $Slave = new Slave($Bus);

&uopen($OUTPUT);
print $Slave->declaration;
&uclose($OUTPUT);
