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
	my $INDENT = shift;
	my $node   = shift;
	my $rf     = "";
	my $text   = $node->sc_get_description();
	if ($text) {
		my @lines = split /\n/, $text;  @lines = ($text) unless @lines;
		$rf .= "${INDENT}---\n";
		foreach my $line (@lines) { 
			$rf .= "${INDENT}$line\n"; 
		}
		$rf .= "${INDENT}---\n";
	}
	return $rf;
}

sub options {
	my $node = shift;
	my @properties = ();
	while (my $key = $node->sc_get_next_property()) {
		my $value = $node->sc_get_property($key); 
		$value = "\"".$value."\"" if $value =~ /\s/;
		push @properties, defined $value ? sprintf("-%s %s",$key,$value) : sprintf("-%s",$key);
	}
	return @properties;
}

sub rocketfuel {
	my $options = shift;
	my $region  = shift;
	my $level   = shift; $level = 0 unless defined $level;
	my $TAB     = $options->{tab};
	my $INDENT  = $TAB x $level;
	my $rf      = "";

	while (my $node = $region->sc_get_next_child()) {
		$rf .= &description($INDENT,$node);
		$rf .= $INDENT . $node->sc_get_offset($options->{offset});
		$rf .= $TAB    . $node->sc_get_size($options->{size});
		if ($node->sc_is_field) {
			$rf .= $TAB . $node->sc_get_value();
			$rf .= $TAB . $node->sc_get_name("%v");
			$rf .= $TAB . $node->sc_get_type();
		} else {
			my $glob = $node->sc_get_glob("%v");
			my $name = $node->sc_is_named() ? $node->sc_get_name("%") : "";
			my $type = $node->sc_get_type();

			$rf .= $TAB . $glob unless $glob eq "*";
			$rf .= $TAB . $name if $name;

			if ($type) {
				$rf .= $TAB . $type;
				&fuelsupply($options,$node,$type);
			} elsif ($node->sc_has_children) {
				$rf .= $TAB . "{\n\n";
				$rf .= &rocketfuel($options,$node,$level+1);
				$rf .= $INDENT . "}";
			} else {
				$rf .= $TAB . "{}";
			}
		}
		$rf .= $TAB . join($TAB,&options($node)) if $node->sc_has_properties();
		$rf .= ";\n\n\n";
	}
	return $rf;
}

sub fuelsupply {
	my $options = shift;
	my $space   = shift;
	my $type    = shift;
	my $output  = $options->{output}."/".$type.".rf";
	my $rf      = &rocketfuel($options,$space);

	if (not exists $options->{fueled}->{$type}) {
		&sc_note(2,"Writting $output");
		&uopen($output);
		print $rf;
		&uclose($output);
		$options->{fueled}->{$type} = 1;
	}
}

#-------------------------------------------------------------------------------
# Command Line
#-------------------------------------------------------------------------------

my $OPTIONS = {
	offset  => "%U",
	size    => "%U",
	tab     => "    ",
	output  => "rocketfuel",
	fueled  => {}
};

while (@ARGV) {
	my $op = shift;
	if    ($op =~ /^-?-h(elp)?$/) { &uhelp;                     }
	elsif ($op eq "-offset"     ) { $OPTIONS->{offset} = shift; }
	elsif ($op eq "-size"       ) { $OPTIONS->{size}   = shift; }
	else                          { $OPTIONS->{output} = $op;   }
}

mkdir $OPTIONS->{output} unless -d $OPTIONS->{output};

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

my $space = &sc_get_space;
my $type  = $space->sc_get_type || "space";

&fuelsupply($OPTIONS,&sc_get_space,$type);