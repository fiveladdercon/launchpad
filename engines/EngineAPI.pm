# This file was automatically generated by SWIG (http://www.swig.org).
# Version 3.0.12
#
# Do not make changes to this file unless you know what you are doing--modify
# the SWIG interface file instead.

package EngineAPI;
use base qw(Exporter);
package EngineAPIc;
package EngineAPIc;
boot_EngineAPI();
package EngineAPI;
@EXPORT = qw();

# ---------- BASE METHODS -------------

package EngineAPI;

sub TIEHASH {
    my ($classname,$obj) = @_;
    return bless $obj, $classname;
}

sub CLEAR { }

sub FIRSTKEY { }

sub NEXTKEY { }

sub FETCH {
    my ($self,$field) = @_;
    my $member_func = "swig_${field}_get";
    $self->$member_func();
}

sub STORE {
    my ($self,$field,$newval) = @_;
    my $member_func = "swig_${field}_set";
    $self->$member_func($newval);
}

sub this {
    my $ptr = shift;
    return tied(%$ptr);
}


# ------- FUNCTION WRAPPERS --------

package EngineAPI;

*sc_get_space = *EngineAPIc::sc_get_space;
*sc_get_address = *EngineAPIc::sc_get_address;
*sc_get_identifier = *EngineAPIc::sc_get_identifier;
*sc_get_dimensions = *EngineAPIc::sc_get_dimensions;
*sc_get_offset = *EngineAPIc::sc_get_offset;
*sc_get_size = *EngineAPIc::sc_get_size;
*sc_get_span = *EngineAPIc::sc_get_span;
*sc_get_glob = *EngineAPIc::sc_get_glob;
*sc_get_value = *EngineAPIc::sc_get_value;
*sc_get_name = *EngineAPIc::sc_get_name;
*sc_get_type = *EngineAPIc::sc_get_type;
*sc_get_description = *EngineAPIc::sc_get_description;
*sc_get_children = *EngineAPIc::sc_get_children;
*sc_get_property = *EngineAPIc::sc_get_property;
*sc_get_dimension_label = *EngineAPIc::sc_get_dimension_label;
*sc_get_dimension_from = *EngineAPIc::sc_get_dimension_from;
*sc_get_dimension_to = *EngineAPIc::sc_get_dimension_to;
*sc_get_dimension_size = *EngineAPIc::sc_get_dimension_size;
*sc_get_dimension_count = *EngineAPIc::sc_get_dimension_count;
*sc_get_dimension_span = *EngineAPIc::sc_get_dimension_span;
*sc_get_dimension = *EngineAPIc::sc_get_dimension;
*sc_get_filename = *EngineAPIc::sc_get_filename;
*sc_get_lineno = *EngineAPIc::sc_get_lineno;
*sc_set_offset = *EngineAPIc::sc_set_offset;
*sc_set_size = *EngineAPIc::sc_set_size;
*sc_set_name = *EngineAPIc::sc_set_name;
*sc_set_type = *EngineAPIc::sc_set_type;
*sc_set_glob = *EngineAPIc::sc_set_glob;
*sc_set_value = *EngineAPIc::sc_set_value;
*sc_set_description = *EngineAPIc::sc_set_description;
*sc_set_children = *EngineAPIc::sc_set_children;
*sc_set_property = *EngineAPIc::sc_set_property;
*sc_set_dimension_label = *EngineAPIc::sc_set_dimension_label;
*sc_set_dimension_from = *EngineAPIc::sc_set_dimension_from;
*sc_set_dimension_to = *EngineAPIc::sc_set_dimension_to;
*sc_set_dimension_size = *EngineAPIc::sc_set_dimension_size;
*sc_is_space = *EngineAPIc::sc_is_space;
*sc_is_region = *EngineAPIc::sc_is_region;
*sc_is_field = *EngineAPIc::sc_is_field;
*sc_is_named = *EngineAPIc::sc_is_named;
*sc_is_typed = *EngineAPIc::sc_is_typed;
*sc_is_first_child = *EngineAPIc::sc_is_first_child;
*sc_is_last_child = *EngineAPIc::sc_is_last_child;
*sc_has_properties = *EngineAPIc::sc_has_properties;
*sc_has_property = *EngineAPIc::sc_has_property;
*sc_has_dimensions = *EngineAPIc::sc_has_dimensions;
*sc_has_children = *EngineAPIc::sc_has_children;
*sc_get_parent = *EngineAPIc::sc_get_parent;
*sc_get_next_child = *EngineAPIc::sc_get_next_child;
*sc_get_next_property = *EngineAPIc::sc_get_next_property;
*sc_get_next_dimension = *EngineAPIc::sc_get_next_dimension;
*sc__add_region = *EngineAPIc::sc__add_region;
*sc__add_field = *EngineAPIc::sc__add_field;
*sc_unset = *EngineAPIc::sc_unset;
*sc_unset_property = *EngineAPIc::sc_unset_property;
*sc_unset_children = *EngineAPIc::sc_unset_children;
*sc_bits = *EngineAPIc::sc_bits;
*sc_dimensions = *EngineAPIc::sc_dimensions;
*sc_import = *EngineAPIc::sc_import;
*sc_detach = *EngineAPIc::sc_detach;
*sc_reattach = *EngineAPIc::sc_reattach;
*sc_unroll = *EngineAPIc::sc_unroll;
*sc_reroll = *EngineAPIc::sc_reroll;
*sc__fuel_supply = *EngineAPIc::sc__fuel_supply;
*sc__fuel = *EngineAPIc::sc__fuel;
*sc__note = *EngineAPIc::sc__note;
*sc__warn = *EngineAPIc::sc__warn;
*sc__error = *EngineAPIc::sc__error;
*sc__fatal = *EngineAPIc::sc__fatal;

############# Class : EngineAPI::SC_SPACE ##############

package EngineAPI::SC_SPACE;
use vars qw(@ISA %OWNER %ITERATORS %BLESSEDMEMBERS);
@ISA = qw( EngineAPI );
%OWNER = ();
%ITERATORS = ();
sub new {
    my $pkg = shift;
    my $self = EngineAPIc::new_SC_SPACE(@_);
    bless $self, $pkg if defined($self);
}

sub DESTROY {
    return unless $_[0]->isa('HASH');
    my $self = tied(%{$_[0]});
    return unless defined $self;
    delete $ITERATORS{$self};
    if (exists $OWNER{$self}) {
        EngineAPIc::delete_SC_SPACE($self);
        delete $OWNER{$self};
    }
}

sub DISOWN {
    my $self = shift;
    my $ptr = tied(%$self);
    delete $OWNER{$ptr};
}

sub ACQUIRE {
    my $self = shift;
    my $ptr = tied(%$self);
    $OWNER{$ptr} = 1;
}


############# Class : EngineAPI::SC_REGION ##############

package EngineAPI::SC_REGION;
use vars qw(@ISA %OWNER %ITERATORS %BLESSEDMEMBERS);
@ISA = qw( EngineAPI );
%OWNER = ();
%ITERATORS = ();
sub new {
    my $pkg = shift;
    my $self = EngineAPIc::new_SC_REGION(@_);
    bless $self, $pkg if defined($self);
}

sub DESTROY {
    return unless $_[0]->isa('HASH');
    my $self = tied(%{$_[0]});
    return unless defined $self;
    delete $ITERATORS{$self};
    if (exists $OWNER{$self}) {
        EngineAPIc::delete_SC_REGION($self);
        delete $OWNER{$self};
    }
}

sub DISOWN {
    my $self = shift;
    my $ptr = tied(%$self);
    delete $OWNER{$ptr};
}

sub ACQUIRE {
    my $self = shift;
    my $ptr = tied(%$self);
    $OWNER{$ptr} = 1;
}


############# Class : EngineAPI::SC_FIELD ##############

package EngineAPI::SC_FIELD;
use vars qw(@ISA %OWNER %ITERATORS %BLESSEDMEMBERS);
@ISA = qw( EngineAPI );
%OWNER = ();
%ITERATORS = ();
sub new {
    my $pkg = shift;
    my $self = EngineAPIc::new_SC_FIELD(@_);
    bless $self, $pkg if defined($self);
}

sub DESTROY {
    return unless $_[0]->isa('HASH');
    my $self = tied(%{$_[0]});
    return unless defined $self;
    delete $ITERATORS{$self};
    if (exists $OWNER{$self}) {
        EngineAPIc::delete_SC_FIELD($self);
        delete $OWNER{$self};
    }
}

sub DISOWN {
    my $self = shift;
    my $ptr = tied(%$self);
    delete $OWNER{$ptr};
}

sub ACQUIRE {
    my $self = shift;
    my $ptr = tied(%$self);
    $OWNER{$ptr} = 1;
}


############# Class : EngineAPI::SC_NODE ##############

package EngineAPI::SC_NODE;
use vars qw(@ISA %OWNER %ITERATORS %BLESSEDMEMBERS);
@ISA = qw( EngineAPI );
%OWNER = ();
%ITERATORS = ();
sub new {
    my $pkg = shift;
    my $self = EngineAPIc::new_SC_NODE(@_);
    bless $self, $pkg if defined($self);
}

sub DESTROY {
    return unless $_[0]->isa('HASH');
    my $self = tied(%{$_[0]});
    return unless defined $self;
    delete $ITERATORS{$self};
    if (exists $OWNER{$self}) {
        EngineAPIc::delete_SC_NODE($self);
        delete $OWNER{$self};
    }
}

sub DISOWN {
    my $self = shift;
    my $ptr = tied(%$self);
    delete $OWNER{$ptr};
}

sub ACQUIRE {
    my $self = shift;
    my $ptr = tied(%$self);
    $OWNER{$ptr} = 1;
}


# ------- CONSTANT STUBS -------

package EngineAPI;

sub SC_MAX_STRING_LENGTH () { $EngineAPIc::SC_MAX_STRING_LENGTH }
sub SC_FUEL_RECURSIVE () { $EngineAPIc::SC_FUEL_RECURSIVE }
sub SC_FUEL_EMBEDDED () { $EngineAPIc::SC_FUEL_EMBEDDED }

# ------- VARIABLE STUBS --------

package EngineAPI;



package EngineAPI;
@EXPORT = qw(sc_get_space sc_fuel_supply sc_fuel sc_bits sc_note sc_warn sc_error sc_fatal);

# C wrappers

sub sc_add_region {
	my $region  = shift;
	my %options = (-glob => "*", -description => "", -lineno => 0, @_);
	my $node    = $region->sc__add_region($options{-offset},$options{-size},$options{-glob},$options{-name},$options{-type},$options{-description},$options{-filename},$options{-lineno});
	$node->sc_set_children($options{-children}) if $node and $options{-children};
	return $node;
}

sub sc_add_field {
	my $region  = shift;
	my %options = (-description => "", -lineno => 0, @_);
	my $node    = $region->sc__add_field($options{-offset},$options{-size},$options{-value},$options{-name},$options{-type},$options{-description},$options{-filename},$options{-lineno});
	return $node;
}

sub sc_fuel_supply {
	&sc__fuel_supply(join(":",@_));
}

sub sc_fuel {
	my $region  = ref $_[0] ? shift : undef;
	my $supply  = shift;  
	my %options = @_;
	my $flags   = 0;
	   $flags  |= SC_FUEL_RECURSIVE if $options{-recursive};
	   $flags  |= SC_FUEL_EMBEDDED  if $options{-embedded};
	return &sc__fuel($region,$supply,$flags);
}

sub sc_note {
	my $level  = shift;
	my $format = shift;
	my @args   = @_;
	&sc__note($level,sprintf($format,@args));
}

sub sc_warn {
	my $format = shift;
	my @args   = @_;
	&sc__warn(sprintf($format,@args));
}

sub sc_error {
	my $format = shift;
	my @args   = @_;
	&sc__error(sprintf($format,@args));
}

sub sc_fatal {
	my $format = shift;
	my @args   = @_;
	&sc__fatal(sprintf($format,@args));
}

# Pure Perl

sub sc_get_identifiers {
	my $region = shift;
	my $index  = shift; $index = {} unless defined $index;
	while (my $child = $region->sc_get_next_child) {
		$index->{$child->sc_get_identifier} = $child if $child->sc_is_named;
		&sc_get_identifiers($child,$index) if $child->sc_is_region;
	}
	return %{$index};
}

1;
