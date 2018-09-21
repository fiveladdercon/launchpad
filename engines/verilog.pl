#-------------------------------------------------------------------------------
# Packages
#-------------------------------------------------------------------------------

use EngineAPI;
use EngineUtils;
use Verilog::Module;
use strict;

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

sub collect {
	my $region  = shift;
	my $regions = shift;
	my $fields  = shift;
	while (my $node = $region->sc_get_next_child) {
		if ($node->sc_is_field) {
			push @{$fields}, $node;
		} elsif ($node->sc_is_typed and not $node->sc_has_property("verilog:import")) {
			push @{$regions}, $node;
		} else {
			&collect($node,$regions,$fields);
		}
	}
}

sub list {
	foreach my $node (@_) { printf "%s\n", $node->sc_get_identifier(); }
}

#-------------------------------------------------------------------------------
# Command Line
#-------------------------------------------------------------------------------

while (@ARGV) {
	my $op = shift;
	if ($op =~ /^-?-h(elp)?$/) { &uhelp; }
}

my @REGIONS = ();
my @FIELDS  = ();

&collect(&sc_get_space(),\@REGIONS,\@FIELDS);

&list(@REGIONS);
&list(@FIELDS);


my $Module = new Module("bobo");

my $Block = $Module->block();
my $clk   = $Block->clock("clk");
my $rst   = $Block->reset("rst_n");
my $d     = $Block->reg("d")->clocked($clk,$rst)->output;
my $a     = $Block->wire("a")->input;
my $b     = $Block->wire("b")->input;
my $sel   = $Block->wire("sel")->input;
my $q     = $Block->wire("q");

$Block->assign($q,"$sel ? $a : $b");

$Block->always($d,$q);

print $Module->implementation;