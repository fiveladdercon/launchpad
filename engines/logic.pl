#-------------------------------------------------------------------------------
# Packages
#-------------------------------------------------------------------------------

use EngineAPI;
use EngineUtils;
use strict;

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

sub properties {
	my $dest   = shift;
	my $source = shift;
	while (my $key = $source->sc_get_next_property) {
		$dest->sc_set_property($key,$source->sc_get_property($key));
	}
}

sub logical {
	my $dest   = shift;
	my $source = shift;
	my @spaces = ();
	while (my $node = $source->sc_get_next_child) {
		if ($node->sc_is_field) {
			my $field = $dest->sc_add_field(
				-offset      => $node->sc_get_address,
				-size        => $node->sc_get_size,
				-name        => $node->sc_get_identifier("%v"),
				-type        => $node->sc_get_type,
				-value       => $node->sc_get_value,
				-description => $node->sc_get_description,
				-filename    => $node->sc_get_filename,
				-lineno      => $node->sc_get_lineno,
			);
			&properties($field,$node);
		} elsif ($node->sc_is_named or $node->sc_is_typed or $node->sc_has_dimensions or $node->sc_has_properties) {
			my $region = $dest->sc_add_region(
				-offset      => $node->sc_get_address,
				-size        => $node->sc_get_size,
				-name        => $node->sc_get_identifier("%v"),
				-type        => $node->sc_get_type,
				-glob        => $node->sc_import("*","%v"),
				-description => $node->sc_get_description,
				-filename    => $node->sc_get_filename,
				-lineno      => $node->sc_get_lineno,
			);
			&properties($region,$node);
			push @spaces, [$region,$node->sc_get_children];
		} else {
			&logical($dest,$node);
		}
	}
	foreach my $space (@spaces) { &logical(@{$space}); }
}

#-------------------------------------------------------------------------------
# Command Line
#-------------------------------------------------------------------------------

my $OUTPUT;
my $OPTIONS = {
};

while (@ARGV) {
	my $op = shift;
	if    ($op =~ /^-?-h(elp)?$/) { &uhelp;        }
	else                          { $OUTPUT = $op; }
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

my $space    = &sc_get_space();
my $physical = $space->sc_get_children;
my $logical  = $space; $space->sc_unset_children;

&logical($logical,$physical);
