#-------------------------------------------------------------------------------
# Packages
#-------------------------------------------------------------------------------

use EngineAPI;
use EngineUtils;
use strict;


#-------------------------------------------------------------------------------
package Node;
#-------------------------------------------------------------------------------
use EngineAPI;

sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $node     = shift;
	my $options  = shift;
	my $this     = {
		node    => $node,
		options => $options,
		dims    => [],
	};

	my @dims  = grep /:/, split '#', $node->sc_get_identifier("#%l:%f:%t:%z#");
	my %count = ();
	foreach my $dim (@dims) {
		my ($label,$from,$to,$size) = split /:/, $dim;

		$count{$label} = -1 unless exists $count{$label};
		$count{$label}++;
		
		push @{$this->{dims}}, {
			label => $label,
			from  => $from,
			to    => $to,
			size  => $size,
			var   => $count{$label} ? $label.$count{$label} : $label
		};
	}

	return bless $this, $class;
}

sub dims {
	my $this     = shift;
	my $callback = shift;
	my @result   = ();
	foreach my $dim (@{$this->{dims}}) {
		push @result, &$callback($dim);
	}
	return @result;
}

sub macro {
	my $this  = shift;
	my $macro = $this->{node}->sc_get_identifier;
	my @vars  = $this->dims(sub {
		my $dim = shift; return $dim->{var};
	});
	return scalar @vars ? $macro."(".join(",",@vars).")" : $macro;
}

sub access {
	my $this   = shift;
	my $access = $this->{options}->{access};
	my $node   = $this->{node};
	while ($node) {
		if ($node->sc_has_property("access")) {
			$access = $node->sc_get_property("access");
			$node   = undef;
		} else {
			$node = $node->sc_get_parent;
		}
	}
	return $access; 
}

sub size {
	my $this = shift;
	return $this->{node}->sc_get_size;
}

sub address {
	my $this    = shift;
	my $address = $this->{node}->sc_get_address;
	my @adds    = $this->dims(sub {
		my $dim   = shift;
		my $size  = $dim->{size};
		my $v     = $dim->{var};
		my $f     = $dim->{from};
		my $t     = $dim->{to};
		my $shift = ($f == 0) ? "($v)" : ($f < $t) ? "(($v)-$f)" : "($f-($v))";
		return "($size*$shift)";
	});
	return scalar @adds ? join("+",$address,@adds) : $address;
}

sub value {
	my $this = shift;
	return $this->{node}->sc_is_field ? "\"".$this->{node}->sc_get_value."\"" : "NULL";
}

sub valid {
	my $this = shift;
	my @range = $this->dims(sub {
		my $dim = shift;
		my $v   = $dim->{var};
		my $f   = $dim->{from};
		my $t   = $dim->{to};
		my $l   = ($f<$t) ? $f : $t;
		my $u   = ($f<$t) ? $t : $f;
		return "($l<=($v))&&(($v)<=$u)";
	});
	return scalar @range ? join("&&",@range) : "1";
}

sub identifier {
	my $this = shift;
	my $id   = $this->{node}->sc_get_identifier("@");
	my $P    = $this->{options}->{C} ? '#' : '';
	$this->dims(sub {
		my $dim = shift; 
		my $val = "\" ".$P.$dim->{var}." \"";
		$id =~ s/@/$val/e;
	});
	$id = "\"".$id."\""; $id =~ s/\s*""\s*//g;
	return $id;
}

sub define {
	my $this   = shift;
	my $D      = $this->{options}->{C}      ? '#'          : '`';
	my $O      = $this->{options}->{STRUCT} ? '(field_t){' : '';
	my $C      = $this->{options}->{STRUCT} ? '}'          : '';
	my @value  = (
		$this->access,
		$this->size,
		$this->address,
		$this->valid
	);

	push @value, $this->identifier unless $this->{options}->{OPTIMIZE};
	push @value, $this->value      unless $this->{options}->{OPTIMIZE};
	
	return sprintf "${D}define %-80s ${O}%s${C}\n", $this->macro, join(",", @value);
}

package main;
#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

sub defines {
	my $options = shift;
	my $region  = shift;
	while (my $node = $region->sc_get_next_child) {
		print new Node($node,$options)->define if $node->sc_is_named;
		&defines($options,$node) if $node->sc_is_region;
	}
}

#-------------------------------------------------------------------------------
# Command Line
#-------------------------------------------------------------------------------

my $OUTPUT;
my $DIALECT   = 'C';
my $FORMAT    = 'LIST';
my $MODE      = 'DEBUG';
my $ACCESS    = 1;
my $CONSTANTS = 1;
my $OPTIONS   = {
	access    => 32,
};

while (@ARGV) {
	my $op = shift;
	if    ($op =~ /^-?-h(elp)?$/     ) { &uhelp;                  }
	elsif ($op =~ /^-?-s(tructs)?$/  ) { $FORMAT    = 'STRUCT';   }
	elsif ($op =~ /^-?-v(erilog)?$/  ) { $DIALECT   = 'VERILOG';  }
	elsif ($op =~ /^-?-o(ptimize)?$/ ) { $MODE      = 'OPTIMIZE'; }
	elsif ($op =~ /^-?-c(onstants)?$/) { $CONSTANTS = 0;          }
	elsif ($op =~ /^-?-a(ccess)?$/   ) { $ACCESS    = 0;          }
	else                               { $OUTPUT    = $op;        }
}

$OPTIONS->{$FORMAT}  = 1;
$OPTIONS->{$DIALECT} = 1;
$OPTIONS->{$MODE}    = 1;
$OPTIONS->{ACCESS}   = $ACCESS;
$OPTIONS->{CONSTANTS} = $CONSTANTS;

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

my $D     = $OPTIONS->{C} ? '#' : '`';
my $U     = $OPTIONS->{C} ? ''  : '`';
my $space = &sc_get_space;
my $TYPE  = uc $space->sc_get_type;

&uopen($OUTPUT);

print <<"_" if $OPTIONS->{ACCESS};
${D}ifndef _ACCESS_DEFINES
${D}define _ACCESS_DEFINES

/*
 * The 'fields' macro is used in the prototype of access functions, typing and
 * setting the locally scoped 'field' variable:
 *
 *     void write(${U}fields, int wval);
 *     int  read(${U}fields);
 *
 * Access functions declared with the 'fields' macro can then be invoked using
 * field constants:
 *
 *     write(${U}FIELD_MACRO, 25);
 *
 */

_
print <<"_" if $OPTIONS->{ACCESS} and $OPTIONS->{LIST} and $OPTIONS->{DEBUG};
${D}define fields   int access, int size, int address, int valid, char *name, char *value
_
print <<"_" if $OPTIONS->{ACCESS} and $OPTIONS->{LIST} and $OPTIONS->{OPTIMIZE};
${D}define fields   int access, int size, int address, int valid
_
print <<"_" if $OPTIONS->{ACCESS} and $OPTIONS->{STRUCT};
typedef struct {
    int    access;
    int    size;
    int    address;
    int    valid;
_
print <<"_" if $OPTIONS->{ACCESS} and $OPTIONS->{STRUCT} and $OPTIONS->{DEBUG};
    char  *name;
    char  *value;
_
print <<"_" if $OPTIONS->{ACCESS} and $OPTIONS->{STRUCT};
} field_t;

${D}define fields  field_t field
_
print <<"_" if $OPTIONS->{ACCESS};

/*
 * The 'field' macro is used in the body of access functions as a variable:
 *
 *     void access(${U}fields) {
 *         printf("access_of  = %d\\n", ${U}access_of(${U}field)  );
 *         printf("size_of    = %d\\n", ${U}size_of(${U}field)    );
 *         printf("address_of = %d\\n", ${U}address_of(${U}field) );
 *         printf("is_valid   = %d\\n", ${U}is_valid(${U}field)   );
 *         printf("name_of    = %s\\n", ${U}name_of(${U}field)    );
 *         printf("value_of   = %s\\n", ${U}value_of(${U}field)   );
 *     } 
 *
 */

_
print <<"_" if $OPTIONS->{ACCESS} and $OPTIONS->{LIST} and $OPTIONS->{DEBUG};
${D}define field   access,size,address,valid,name,value
_
print <<"_" if $OPTIONS->{ACCESS} and $OPTIONS->{LIST} and $OPTIONS->{OPTIMIZE};
${D}define field   access,size,address,valid
_
print <<"_" if $OPTIONS->{ACCESS} and $OPTIONS->{STRUCT};
${D}define field   field
_
print <<"_" if $OPTIONS->{ACCESS} and $OPTIONS->{LIST};

/*
 * The <parameter>_of macros that follow need an indirect implementation to 
 * properly pre-process the two-stage expansion required when passing the
 * 'field' macro to these macros.
 *
 */

_
print <<"_" if $OPTIONS->{ACCESS} and $OPTIONS->{LIST} and $OPTIONS->{DEBUG};
${D}define __access_of(access,size,address,valid,name,value)  access
${D}define __size_of(access,size,address,valid,name,value)    size
${D}define __address_of(access,size,address,valid,name,value) address
${D}define __is_valid(access,size,address,valid,name,value)   valid
${D}define __name_of(access,size,address,valid,name,value)    name
${D}define __value_of(access,size,address,valid,name,value)   value
_
print <<"_" if $OPTIONS->{ACCESS} and $OPTIONS->{LIST} and $OPTIONS->{OPTIMIZE};
${D}define __access_of(access,size,address,valid)  access
${D}define __size_of(access,size,address,valid)    size
${D}define __address_of(access,size,address,valid) address
${D}define __is_valid(access,size,address,valid)   valid
${D}define __name_of(access,size,address,valid)    ""
${D}define __value_of(access,size,address,valid)   ""
_
print <<"_" if $OPTIONS->{ACCESS};

/*
 * The <parameter>_of macros below abstract accessing the parameters of
 * a field and work on field constants or the 'field' variable:
 *
 *    void access(${U}fields) {
 *       is_valid(${U}field);       // Passing the 'field' variable
 *    }
 *
 *    is_valid(${U}FIELD_CONSTANT)  // Passing a field constant
 *
 * ${U}access_of(field)  : returns the number of bits accessed per address
 * ${U}size_of(field)    : returns the number of bits accessed at the field address
 * ${U}address_of(field) : returns the bit address of the least significant bit of the field
 * ${U}is_valid(field)   : returns true if the dimension variables, if any, are in range
 * ${U}name_of(field)    : returns the field name as a string (debug)
 * ${U}value_of(field)   : returns the initial value of the field (debug)
 *
 */

_
print <<"_" if $OPTIONS->{ACCESS} and $OPTIONS->{LIST};
${D}define access_of(f)   __access_of(f)
${D}define size_of(f)     __size_of(f)
${D}define address_of(f)  __address_of(f)
${D}define is_valid(f)    __is_valid(f)
${D}define name_of(f)     __name_of(f) 
${D}define value_of(f)    __value_of(f)
_
print <<"_" if $OPTIONS->{ACCESS} and $OPTIONS->{STRUCT};
${D}define access_of(f)   f.access
${D}define size_of(f)     f.size
${D}define address_of(f)  f.address
${D}define is_valid(f)    f.valid
_
print <<"_" if $OPTIONS->{ACCESS} and $OPTIONS->{STRUCT} and $OPTIONS->{DEBUG};
${D}define name_of(f)     f.name
${D}define value_of(f)    f.value
_
print <<"_" if $OPTIONS->{ACCESS} and $OPTIONS->{STRUCT} and $OPTIONS->{OPTIMIZE};
${D}define name_of(f)     "" 
${D}define value_of(f)    ""
_
print <<"_" if $OPTIONS->{ACCESS};

${D}endif

_
print <<"_" if $OPTIONS->{CONSTANTS};
${D}ifndef _${TYPE}_DEFINES
${D}define _${TYPE}_DEFINES

_
&defines($OPTIONS,$space) if $OPTIONS->{CONSTANTS};
print <<"_" if $OPTIONS->{CONSTANTS};

${D}endif
_

&uclose($OUTPUT);
