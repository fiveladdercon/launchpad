#-------------------------------------------------------------------------------
# Packages
#-------------------------------------------------------------------------------

use strict;
use lib (".");
use EngineAPI;
use EngineUtils;
use Verilog::Buses;
use Verilog::Fields;

#-------------------------------------------------------------------------------
package Slave;
#-------------------------------------------------------------------------------
#
#  A Slave is a Module that uses a Bus to access Fields and Regions
#
use base ('Module');

#------------------
# Engine Interface
#------------------

#
# $Slave = new Slave($Bus, $Space);
#
# A backstage method that returns a new instance of a Slave.
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $Space    = shift;
	my $Bus      = shift;
	my $Slave    = Module::new($class, $Space->sc_get_type || "space");

	# Add the Bus to the Module
	$Slave->{Bus} = $Bus;

	# Add the Decoder to the Bus
	$Bus->Decoder($Slave);

	# Add the Fields & Regions
	my @Fields = ();
	foreach my $Node (&bounded($Space)) {
		if ($Node->sc_is_field) {
			# Only declare Fields on this pass so Fields can reference
			# each other in their implementations.
			push @Fields, $Slave->Field($Node);
		} else {
			# Regions are implemented as we go
			$Bus->Region($Node);
		}
	}

	# Now implement the Fields
	foreach my $Field (@Fields) {
		$Field->implementation;
	}

	# Add the Return block to the Bus
	$Bus->Return;

	return $Slave;
}

#
# @nodes = &bounded($space);
#
# A backstage function that returns the nodes in the space that are 
# implemented inside the Module.  These are:
#
#  o Fields
#  o Typed Regions that are imported
#  o Untyped Regions that are not exported
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
		} elsif (not $node->sc_is_typed and $node->sc_has_property("verilog:export")) {
			push @nodes, $node;
		} else {
			push @nodes, &bounded($node);
		}
	}
	return @nodes;
}

#
# $Field = $Slave->Field($Node)
#
# A backstage method that returns an instance of the Type of Field
# specified by the supplied Node.  Throws a fatal if the node type
# has no implementation.
#
# The method also adds the Field's Port and Value Signals to the
# Slave so that Fields can connect with each other.
#
sub Field {
	my $Slave = shift;
	my $Node  = shift;
	my $name  = $Node->sc_get_identifier;
	my $Type  = $Node->sc_get_type;
	my $file  = $Node->sc_get_filename;
	my $line  = $Node->sc_get_lineno;
	my $Field;

	# Attempt to instantiate the specified Type.
	eval { $Field = $Type->new($Slave,$Node); } or 
		&sc_fatal("Field ${name} declared on line ${line} in ${file} has unknown type: ${Type}.");
	
	# Add the Port and Value to the list of Signals
	$Field->Port;
	$Field->Value;

	return $Field;
}

#-------------------------------------------------------------------------------
# Command Line
#-------------------------------------------------------------------------------
package main;

my $BUS;
my $TYPES;
my $OUTPUT;
my @ARGS = ();
my $DEBUG = 0;

while (@ARGV) {
	my $op = shift;
	if    ($op =~ /^-?-h(elp)?$/) { &uhelp;          }
	elsif ($op eq "-bus"        ) { $BUS    = shift; }
	elsif ($op eq "-types"      ) { $TYPES  = shift; }
	elsif ($op eq "-d") { $DEBUG = 1; }
	elsif ($op eq "-o"          ) { $OUTPUT = shift; }
	elsif ($op =~ /[.]v$/       ) { $OUTPUT = $op;   }
	else                          { push @ARGS, $op; }
}

if ($TYPES) {
	&uhelp("Type library $TYPES does not exist.") unless -e $TYPES;
	require $TYPES;
}

if ($BUS) {
	&uhelp("Bus $BUS does not exist.") unless -e $BUS;
	require $BUS;
} else {
	$BUS = 'APB';
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

my $Space = &sc_get_space();
my $Bus   = new $BUS($Space, @ARGS);
my $Slave = new Slave($Space, $Bus);

&uopen($OUTPUT);
print $Slave->declaration unless $DEBUG;
&uclose($OUTPUT);
