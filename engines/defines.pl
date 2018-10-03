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

sub grid {
	my $this = shift;
	my $grid = $this->{options}->{GRID};
	my $node = $this->{node};
	while ($node) {
		if ($node->sc_has_property("grid")) {
			$grid = $node->sc_get_property("grid");
			$node = undef;
		} else {
			$node = $node->sc_get_parent;
		}
	}
	return $grid; 
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

sub constant {
	my $this   = shift;
	my $D      = $this->{options}->{C}      ? '#'         : '`';
	my $O      = $this->{options}->{STRUCT} ? '(node_t){' : '';
	my $C      = $this->{options}->{STRUCT} ? '}'         : '';
	my @value  = (
		$this->grid,
		$this->size,
		$this->address
	);
	push @value, (
		$this->identifier,
		$this->value,
		$this->valid
	) unless $this->{options}->{OPTIMIZE};
	
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
		print new Node($node,$options)->constant if $node->sc_is_named;
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
my $STORAGE   = 1;
my $CONSTANTS = 1;
my $GRID      = 32;
my $OPTIONS   = {};

while (@ARGV) {
	my $op = shift;
	if    ($op =~ /^-?-h(elp)?$/       ) { &uhelp;                  }
	elsif ($op =~ /^-?-g(rid)?$/       ) { $GRID      = shift;      }
	elsif ($op =~ /^-?-v(erilog)?$/    ) { $DIALECT   = 'VERILOG';  }
	elsif ($op =~ /^-?-o(ptimize)?$/   ) { $MODE      = 'OPTIMIZE'; }
	elsif ($op =~ /^-?-s(tructs)?$/    ) { $FORMAT    = 'STRUCT';   }
	elsif ($op =~ /^(--storage)?-off$/ ) { $STORAGE   = 0;          }
	elsif ($op =~ /^(--storage)?-only$/) { $CONSTANTS = 0;          }
	else                                 { $OUTPUT    = $op;        }
}

$OPTIONS->{$DIALECT}  = 1;
$OPTIONS->{$MODE}     = 1;
$OPTIONS->{$FORMAT}   = 1;
$OPTIONS->{STORAGE}   = $STORAGE;
$OPTIONS->{CONSTANTS} = $CONSTANTS;
$OPTIONS->{GRID}      = $GRID;

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

my $D     = $OPTIONS->{C} ? '#' : '`';
my $U     = $OPTIONS->{C} ? ''  : '`';
my $space = &sc_get_space;
my $TYPE  = uc $space->sc_get_type;

&uopen($OUTPUT);

print <<"_" if $OPTIONS->{STORAGE};
${D}ifndef _STORAGE_DEFINES
${D}define _STORAGE_DEFINES

/*
 * The 'nodes' macro is used in the prototype of access routines, typing and
 * setting the locally scoped 'node' variable:
 *
 *     void write(${U}nodes, int wval);
 *     int  read(${U}nodes);
 *
 * Access functions declared with the 'nodes' macro can then be invoked using
 * node constants:
 *
 *     write(${U}FIELD_MACRO, 25);
 *
 */

_
print <<"_" if $OPTIONS->{STORAGE} and $OPTIONS->{LIST} and $OPTIONS->{DEBUG};
${D}define nodes   int grid, int size, int address, char *name, char *value, int valid
_
print <<"_" if $OPTIONS->{STORAGE} and $OPTIONS->{LIST} and $OPTIONS->{OPTIMIZE};
${D}define nodes   int grid, int size, int address
_
print <<"_" if $OPTIONS->{STORAGE} and $OPTIONS->{STRUCT};
typedef struct {
    int    grid;
    int    size;
    int    address;
_
print <<"_" if $OPTIONS->{STORAGE} and $OPTIONS->{STRUCT} and $OPTIONS->{DEBUG};
    char  *name;
    char  *value;
    int    valid;
_
print <<"_" if $OPTIONS->{STORAGE} and $OPTIONS->{STRUCT};
} node_t;

${D}define nodes  node_t node
_
print <<"_" if $OPTIONS->{STORAGE};

/*
 * The 'node' macro is used in the body of access functions as a variable:
 *
 *     void access(${U}nodes) {
 *         printf("grid_of    = %d\\n", ${U}grid_of(${U}node)    );
 *         printf("size_of    = %d\\n", ${U}size_of(${U}node)    );
 *         printf("address_of = %d\\n", ${U}address_of(${U}node) );
 *         printf("name_of    = %s\\n", ${U}name_of(${U}node)    );
 *         printf("value_of   = %s\\n", ${U}value_of(${U}node)   );
 *         printf("is_valid   = %d\\n", ${U}is_valid(${U}node)   );
 *     } 
 *
 */

_
print <<"_" if $OPTIONS->{STORAGE} and $OPTIONS->{LIST} and $OPTIONS->{DEBUG};
${D}define node   grid,size,address,name,value,valid
_
print <<"_" if $OPTIONS->{STORAGE} and $OPTIONS->{LIST} and $OPTIONS->{OPTIMIZE};
${D}define node   grid,size,address
_
print <<"_" if $OPTIONS->{STORAGE} and $OPTIONS->{STRUCT};
${D}define node   node
_
print <<"_" if $OPTIONS->{STORAGE} and $OPTIONS->{LIST};

/*
 * The <parameter>_of macros that follow need an indirect implementation to 
 * properly pre-process the two-stage expansion required when passing the
 * 'node' macro to these macros.
 *
 */

_
print <<"_" if $OPTIONS->{STORAGE} and $OPTIONS->{LIST} and $OPTIONS->{DEBUG};
${D}define __grid_of(grid,size,address,name,value,valid)    grid
${D}define __size_of(grid,size,address,name,value,valid)    size
${D}define __address_of(grid,size,address,name,value,valid) address
${D}define __name_of(grid,size,address,name,value,valid)    name
${D}define __value_of(grid,size,address,name,value,valid)   value
${D}define __is_valid(grid,size,address,name,value,valid)   valid
_
print <<"_" if $OPTIONS->{STORAGE} and $OPTIONS->{LIST} and $OPTIONS->{OPTIMIZE};
${D}define __grid_of(grid,size,address)    grid
${D}define __size_of(grid,size,address)    size
${D}define __address_of(grid,size,address) address
${D}define __name_of(grid,size,address)    ""
${D}define __value_of(grid,size,address)   ""
${D}define __is_valid(grid,size,address)   1
_
print <<"_" if $OPTIONS->{STORAGE};

/*
 * The <parameter>_of macros below abstract accessing the parameters of
 * a node constant and work on node constants or the 'node' variable:
 *
 *    void access(${U}nodes) {
 *       is_valid(${U}node);       // Passing the 'node' variable
 *    }
 *
 *    is_valid(${U}NODE_CONSTANT)  // Passing a node constant
 *
 * ${U}grid_of(node)    : returns the access grid size, in bits.
 * ${U}size_of(node)    : returns the size of the node, in bits.
 * ${U}address_of(node) : returns the bit address of the least significant bit of the node.
 * ${U}name_of(node)    : returns the name of the node as a string, unless optimized.
 * ${U}value_of(node)   : returns the default value of the node as a string, unless optimized.
 * ${U}is_valid(node)   : returns true if the dimension indices, if any, are in range.
 *
 */

_
print <<"_" if $OPTIONS->{STORAGE} and $OPTIONS->{LIST};
${D}define grid_of(f)     __grid_of(f)
${D}define size_of(f)     __size_of(f)
${D}define address_of(f)  __address_of(f)
${D}define name_of(f)     __name_of(f) 
${D}define value_of(f)    __value_of(f)
${D}define is_valid(f)    __is_valid(f)
_
print <<"_" if $OPTIONS->{STORAGE} and $OPTIONS->{STRUCT};
${D}define grid_of(n)     n.grid
${D}define size_of(n)     n.size
${D}define address_of(n)  n.address
_
print <<"_" if $OPTIONS->{STORAGE} and $OPTIONS->{STRUCT} and $OPTIONS->{DEBUG};
${D}define name_of(n)     n.name
${D}define value_of(n)    n.value
${D}define is_valid(n)    n.valid
_
print <<"_" if $OPTIONS->{STORAGE} and $OPTIONS->{STRUCT} and $OPTIONS->{OPTIMIZE};
${D}define name_of(n)     "" 
${D}define value_of(n)    ""
${D}define is_valid(n)    1
_
print <<"_" if $OPTIONS->{STORAGE};

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
