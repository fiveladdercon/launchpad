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
	my @spaces  = ();
	my $rf      = "";

	while (my $node = $region->sc_get_next_child()) {
		$rf .= &description($INDENT,$node);
		$rf .= $INDENT . $node->sc_get_offset($options->{offset});
		$rf .= $TAB    . $node->sc_get_size("%b");
		if ($node->sc_is_field) {
			$rf .= $TAB . $node->sc_get_value();
			$rf .= $TAB . $node->sc_get_name("%v");
			$rf .= $TAB . $node->sc_get_type();
		} else {
			my $glob = $node->sc_get_glob("%v");
			my $name = $node->sc_is_named() ? $node->sc_get_name("#") : "";
			my $type = $node->sc_get_type();

			$rf .= $TAB . $glob unless $glob eq "*";
			$rf .= $TAB . $name if $name;

			if ($type) {
				$rf .= $TAB . $type;
				push @spaces, [$type, $node];
			} else {
				$rf .= $TAB . "{\n\n";
				$rf .= &rocketfuel($options,$node,$level+1);
				$rf .= $INDENT . "}";
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
	my $output  = $options->{dir}."/".$type.".rf";
	my $rf      = &rocketfuel($options,$space);

	&sc_note(2,"Writting $output");
	&uopen($output);
	print $rf;
	&uclose($output);
}

#-------------------------------------------------------------------------------
# Command Line
#-------------------------------------------------------------------------------

my $OUTPUT  = "space.rf";
my $OPTIONS = {
	offset  => "%hW",
	size    => "%hb",
	tab     => "    ",
	dir     => undef,
	recurse => 0,
};

while (@ARGV) {
	my $op = shift;
	if    ($op =~ /^-?-h(elp)?$/) { &uhelp;                     }
	elsif ($op eq "-offset"     ) { $OPTIONS->{offset} = shift; }
	elsif ($op eq "-size"       ) { $OPTIONS->{size}   = shift; }
	elsif ($op eq "-R"          ) { $OPTIONS->{dir}    = shift; }
	else                          { $OUTPUT = $op;              }
}

$OPTIONS->{recurse} = defined $OPTIONS->{dir};
$OPTIONS->{dir}     = "." unless $OPTIONS->{recurse};

$OUTPUT =~ s/[.]rf$//;

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

&fuelsupply($OPTIONS,&sc_get_space,$OUTPUT);