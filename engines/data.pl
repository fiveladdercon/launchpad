#-------------------------------------------------------------------------------
# Packages
#-------------------------------------------------------------------------------

use EngineAPI;
use EngineUtils;
use strict;

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

sub description {
	my $node = shift;
	my $text = $node->sc_get_description();
	$text =~ s/\n/\\n/g;
	return $text;
}

sub properties {
	my $node = shift;
	my @properties = ();
	while (my $key = $node->sc_get_next_property()) {
		my $value = $node->sc_get_property($key);
		push @properties, $value ? "$key=$value" : "$key";
	}
	return join(" ",@properties);
}

sub data {
	my $TAB     = shift;
	my $region  = shift;
	my $options = shift;
	while (my $node = $region->sc_get_next_child()) {
		my $last = $node->sc_is_last_child();
		my $T    = $last ? "└" : "├";
		my $I    = $last ? " " : "│";
		if ($node->sc_is_field) {
			printf "${TAB}${T}─ FIELD\n";
			printf "${TAB}${I}    identifier  : %s\n", $node->sc_get_identifier("%v");
			printf "${TAB}${I}    address     : %s\n", $node->sc_get_address($options->{offset});
			printf "${TAB}${I}    span        : %s\n", $node->sc_get_span($options->{size});
			printf "${TAB}${I}    offset      : %s\n", $node->sc_get_offset($options->{offset});
			printf "${TAB}${I}    size        : %s\n", $node->sc_get_size($options->{size});
			printf "${TAB}${I}    value       : %s\n", $node->sc_get_value();
			printf "${TAB}${I}    name        : %s\n", $node->sc_get_name("%v");
			printf "${TAB}${I}    type        : %s\n", $node->sc_get_type();
			printf "${TAB}${I}    description : %s\n", &description($node);
			printf "${TAB}${I}    properties  : %s\n", &properties($node);
			printf "${TAB}${I}    filename    : %s\n", $node->sc_get_filename();
			printf "${TAB}${I}    lineno      : %s\n", $node->sc_get_lineno();
		} else {
			printf "${TAB}${T}─ REGION\n";
			printf "${TAB}${I}    identifier  : %s\n", $node->sc_get_identifier("%v");
			printf "${TAB}${I}    address     : %s\n", $node->sc_get_address($options->{offset});
			printf "${TAB}${I}    span        : %s\n", $node->sc_get_span($options->{size});
			printf "${TAB}${I}    offset      : %s\n", $node->sc_get_offset($options->{offset});
			printf "${TAB}${I}    size        : %s\n", $node->sc_get_size($options->{size});
			printf "${TAB}${I}    glob        : %s\n", $node->sc_get_glob("%v");
			printf "${TAB}${I}    name        : %s\n", $node->sc_get_name();
			printf "${TAB}${I}    type        : %s\n", $node->sc_get_type();
			printf "${TAB}${I}    description : %s\n", &description($node);
			printf "${TAB}${I}    properties  : %s\n", &properties($node);
			printf "${TAB}${I}    filename    : %s\n", $node->sc_get_filename();
			printf "${TAB}${I}    lineno      : %s\n", $node->sc_get_lineno();
			if ($node->sc_has_children) {
				printf "${TAB}${I}    children    : ┐\n";
				&data("${TAB}${I}                : ",$node,$options);
			}
		}
	}
}

#-------------------------------------------------------------------------------
# Command Line
#-------------------------------------------------------------------------------

my $OUTPUT;
my $OPTIONS = {
	offset  => "%hb (%U)",
	size    => "%hb (%U)",
};

while (@ARGV) {
	my $op = shift;
	if    ($op =~ /^-?-h(elp)?$/) { &uhelp;                     }
	elsif ($op eq "-offset"     ) { $OPTIONS->{offset} = shift; }
	elsif ($op eq "-size"       ) { $OPTIONS->{size}   = shift; }
	else                          { $OUTPUT = $op;              }
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

&uopen($OUTPUT);
&data("",&sc_get_space(),$OPTIONS);
&uclose($OUTPUT);