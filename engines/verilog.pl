#-------------------------------------------------------------------------------
# Packages
#-------------------------------------------------------------------------------

use strict;
use lib (".");
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

#------------------
# Engine Interface
#------------------

#
# $Slave = new Slave($Bus);
#
# A backstage method that returns a new instance of a Slave.
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $Bus      = shift;
	my $Space    = &sc_get_space();
	my $Slave    = Module::new($class,$Space->sc_get_type || "space");

	$Bus->add_Decoder($Slave);

	my @Nodes = &bounded($Space);

	foreach my $Node (@Nodes) {
		if ($Node->sc_is_field) {
			my $name = $Node->sc_get_identifier;
			my $Type = $Node->sc_get_type;
			my $file = $Node->sc_get_filename;
			my $line = $Node->sc_get_lineno;
			eval { $Slave->{Fields}->{$name} = $Type->new($Slave,$Node); } or 
				&sc_fatal("Field ${name} declared on line ${line} in ${file} has unknown type: ${Type}.");
		}
	}

	foreach my $Node (@Nodes) {
		if ($Node->sc_is_field) {
			$Slave->{Fields}->{$Node->sc_get_identifier}->implementation;
		} else {
			$Slave->region($Node);
		}
	}

	$Bus->add_Return($Slave);

	return $Slave;
}

#
# @nodes = &bounded($space);
#
# A backstage function that returns the nodes in the space that are 
# implemented inside the Module.  These are:
#
#  o Fields
#  o Typed Regions that are not imported
#  o Untyped Regions that are exported
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

sub region {
	my $this   = shift;
	my $region = shift;

	printf("REGION %s %s\n",$region->sc_get_identifier);
}

#-------------------------------------------------------------------------------
# Command Line
#-------------------------------------------------------------------------------
package main;

my $BUS;
my $TYPES;
my $OUTPUT;
my @ARGS = ();

while (@ARGV) {
	my $op = shift;
	if    ($op =~ /^-?-h(elp)?$/) { &uhelp;          }
	elsif ($op =~ /[.]v$/       ) { $OUTPUT = $op;   }
	elsif ($op eq "-bus"        ) { $BUS    = shift; }
	elsif ($op eq "-types"      ) { $TYPES  = shift; }
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

my $Bus   = new $BUS(@ARGS);
my $Slave = new Slave($Bus);

&uopen($OUTPUT);
print $Slave->declaration;
&uclose($OUTPUT);
