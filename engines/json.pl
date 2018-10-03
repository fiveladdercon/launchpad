#-------------------------------------------------------------------------------
# Packages
#-------------------------------------------------------------------------------

use EngineAPI;
use EngineUtils;
use strict;

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

sub JSONString {
	return sprintf("\"%s\"",shift);
}

sub JSONList {
	return sprintf("[%s]",join ",",@_);
}

sub JSONObject {
	my $options = shift;
	my $level   = shift;
	my @object  = @_;
	# Format keys as JSON Strings & gather max length
	my $max = 0;
	my $len;
	foreach my $keyvalue (@object) {
		$keyvalue->[0] = JSONString($keyvalue->[0]);
		$len = length $keyvalue->[0]; $max = $len if $len > $max;
	}
	# Format key : value pairs
	my $format = $options->{space} ? "%-${max}s : %s" : "%s:%s";
	my @json   = ();
	foreach my $keyvalue (@object) {
		push @json, sprintf($format,@{$keyvalue});
	}
	# Format the object
	my $tab = " " x $options->{space};
	my $nl  = $options->{space} ? "\n".($tab x $level) : "";
	return "{${nl}${tab}".(join ",${nl}${tab}", @json)."${nl}}";
}

sub JSONProperties {
	my $options = shift;
	my $level   = shift;
	my $node    = shift;
	my @kv      = ();
	while (my $key = $node->sc_get_next_property) {
		my $value = $node->sc_get_property($key);
		push @kv, [$key, $value ? JSONString($value) : "true"];
	}
	return JSONObject($options,$level,@kv);
}

sub JSONField {
	my $options = shift;
	my $level   = shift;
	my $field   = shift;
	my @Object  = ();

	push @Object, ["name"        , JSONString($field->sc_get_name("%v"))   ];
	push @Object, ["offset"      , $field->sc_get_offset                   ];
	push @Object, ["size"        , $field->sc_get_size                     ];
	push @Object, ["value"       , JSONString($field->sc_get_value)        ];
	push @Object, ["type"        , JSONString($field->sc_get_type)         ];
	push @Object, ["description" , JSONString($field->sc_get_description)  ];
	push @Object, ["properties"  , JSONProperties($options,$level+1,$field)] if $field->sc_has_properties;

	return JSONObject($options,$level,@Object);
}

sub JSONRegion {
	my $options = shift;
	my $level   = shift;
	my $region  = shift;
	my @Object  = ();
	my @List    = ();

	push @Object, ["name"        , JSONString($region->sc_get_name("%"))    ] if $region->sc_is_named;
	push @Object, ["offset"      , $region->sc_get_offset                   ];
	push @Object, ["size"        , $region->sc_get_size                     ];
	push @Object, ["glob"        , JSONString($region->sc_get_glob("%v"))   ];
	push @Object, ["type"        , JSONString($region->sc_get_type)         ] if $region->sc_is_typed;
	push @Object, ["description" , JSONString($region->sc_get_description)  ];
	push @Object, ["properties"  , JSONProperties($options,$level+1,$region)] if $region->sc_has_properties;

	while (my $child = $region->sc_get_next_child) {
		push @List, $child->sc_is_field ? JSONField($options,$level+1,$child) : JSONRegion($options,$level+1,$child);
	}
	push @Object, ["children" , JSONList(@List)];

	return &JSONObject($options,$level,@Object);
}

sub JSONSpace {
	my $options = shift;
	my $region  = shift;
	print &JSONRegion($options,0,$region)."\n";
}

#-------------------------------------------------------------------------------
# Command Line
#-------------------------------------------------------------------------------

my $OUTPUT;
my $OPTIONS = {
	'space' => 0,
};

while (@ARGV) {
	my $op = shift;
	if    ($op =~ /^-?-h(elp)?$/)  { &uhelp;                    }
	elsif ($op =~ /^-?-s(pace)?$/) { $OPTIONS->{space} = shift; }
	else                           { $OUTPUT = $op;             }
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

&uopen($OUTPUT);
&JSONSpace($OPTIONS,&sc_get_space);
&uclose($OUTPUT);
