################################################################################
#
#
# This file has one utility package and three Classes for verilog generation:
#
#
# u       : A collection of small utilities like faning out, muxing or 
#           concatinating Signals.
#
# Signal  : A Signal is a verilog variable inside a Module.  Signals can be
#           resized and configured as wires or regs, inputs or outputs,
#           clocks or resets; and they are referenced like strings in logical
#           expressions.
# 
# Block   : A Block is a related set of assign statements and always blocks.
#
# Module  : A Module is a named collection of Signals and Blocks
#
#
# These Classes serve as the underlying verilog mechanic of using Buses to 
# access Fields, since the task must be accomplished with Signals and Blocks
# in a Module.
#
# The convention used throughout is that if a name is capitalized it refers
# to an object class or instance or a method that returns an instance.  The
# distinction is important when assembling names for Signals since there
# is really no better way to distinguish the difference:
#
#    1 | my $decode = sprintf("address_%X",$address);
#    2 | my $Decode = new Signal($decode);
#    3 | $Block->assign($Decode,"$Address == %X",$address);
#
#    1 | $decode is a string and $address is a number.
#    2 | The $decode string is turned into a $Decode object, which is an 
#      | overloaded string, i.e. a string with methods.
#    3 | The $Block object's assign method is used to assign the $Decode
#      | the value of the comparison of the $Address Signal to the $address
#      | number.  Yes - it's like this all over the place - which is why
#      | the convention is important!
#
# Lastly, since the objects all play together, some methods are intended
# for public use and some are not.  Since perl doesn't have the mechanics
# to enforce protection, the function descriptions classify the function
# as public, backstage or private:
#
#   public    : intended to be used by someone deriving Buses and Fields
#   backstage : intended for use between objects, so technically "public"
#               but not intended to be used by someone deriving Buses
#               and Fields.
#   private   : intended for use by the object itself.
#
################################################################################
#-------------------------------------------------------------------------------
package u;
#-------------------------------------------------------------------------------
#
# A package of utilities
#

#
# $logic = u::concat(@signals);
# 
# A public utility that verilog concatinates a list of strings.
# If the list has only one element it that element is returned.
# 
#    u::concat("a","b","c") => "{a,b,c}"
#    u::concat("a")         => "a"
#
sub concat {
	my @signals = @_;
	return (@signals == 1) ? $signals[0] : "{".join(",",@signals)."}";
}

#
# $logic = u::fanout($signal,$size);
#
# A public utility that verilog replicates a string.
# If the size is 1, the string is not replicated.
#
#    u::fanout("sig",3)   => "{3{sig}}"
#    u::fanoud("sig",1)   => "sig"
#
sub fanout {
	my $signal = shift;
	my $size   = shift;
	return ($size == 1) ? $signal : sprintf("{%d{%s}}",$size,$signal);
}

#
# $logic = u::mux($select,$asserted,$deasserted);
#
# A public method that implements a bitwise '?' operation.
#
#    u::mux("sel","a","b")  =>  "(sel & a) | (~sel & b)"
#
sub mux {
	my $select     = shift;
	my $asserted   = shift;
	my $deasserted = shift;
	return "($select & $asserted) | (~$select & $deasserted)";
}

#
# $logic = u::reduce($op,$signal,$size);
#
# A public method that implements a reduce operation if needed.
#
#    u::reduce("|","abc",3) => "(|abc)"
#    u::reduce("|","abc",1) => "abc"
#
sub reduce {
	my $op     = shift;
	my $signal = shift;
	my $size   = shift;
	return ($size == 1) ? $signal : "($op$signal)";
}

#
# $width = u::maxlength(@strings);
#
# A backstage utility that returns the maximum length of a list of strings.
#
sub maxlength {
	my $width = 0; foreach my $string (@_) { my $l = length $string; $width = $l if $l > $width; }
	return $width;
}

#
# $indented = u::indented($tab,$string);
#
# A backstage utility that returns a string with the $tab inserted after each 
# newline in the $string.
#
sub indented {
	my $tab   = shift;
	my $logic = shift;
	$logic =~ s/\n/"\n$tab"/ge;
	return $logic;
}

#
# $power = u::clog2($number);
#
# A backstage utlity that returns the $power of the first 2^$power that is 
# larger than the given $number.  i.e. ceiling(log2(x))
#
sub clog2 {
	my $number = shift;
	my $power  = 0;
	while ((1<<$power)<$number) {$power++;}
	return $power;
}

#
# $format = u::sized($power);
#
# A backstage utility that returns a zero padded %X format given a power. 
# e.g. u::sized(5) -> %02X because 5 bits needs 2 hex characters.
#
sub sized {
  my $power = shift;
  return sprintf("%%0%dX",($power>>2)+(($power%4)?1:0));
}





#-------------------------------------------------------------------------------
package Object;
#-------------------------------------------------------------------------------
#
# A base class to help with debugging
#
use EngineAPI;

sub error {
	shift; &sc_error(@_);
}

sub debug {
	my $this = shift;
	printf("-----------------------------------\n");
	foreach my $key (sort keys %{$this}) {
		printf("%-8s = %s\n",$key,$this->{$key});
	}
}





#-------------------------------------------------------------------------------
package Signal;
#-------------------------------------------------------------------------------
#
# A Signal is a verilog variable inside a Module.
#
# The class is overloaded so that it behaves like a string in string contexts.
#
use base ('Object');

use overload '""'  => sub { $_[0]->{name}; },
             'cmp' => sub { (ref($_[0]) ? $_[0]->{name} : $_[0]) cmp (ref($_[1]) ? $_[1]->{name} : $_[1]); };

#------------
# Public API
#------------

#
# $Signal = $Signal->size($Sized[,$lsb])
# $Signal = $Signal->size($size[,$lsb])
# $size   = $Signal->size
#
# A public chainable method that resizes the Signal when passed a $size
# or a shortcut method for getting the size.  Also sets the $lsb if passed.
#
sub size {
	my $this = shift;
	my $size = shift; 
	if ($size) {
		$this->{size} = ref $size ? $size->size : $size;
		my $lsb = shift; $this->{lsb} = $lsb if defined $lsb;
		$this->{msb} = $this->{lsb}+$size-1 if ($size > 1);
		return $this;
	} else {
		return $this->{size};
	}
}

#
# $Signal = $Signal->input
#
# A public chainable method that turns the Signal into an input.
#
sub input {
	my $this = shift; $this->{port} = 'input'; return $this;
}

#
# $Signal = $Signal->output
#
# A public chainable method that turns the Signal into an output.
#
sub output {
	my $this = shift; $this->{port} = 'output'; return $this;
}

#
# $Signal = $Signal->wire
#
# A public chainable method that turns the Signal into a wire.
#
sub wire {
	my $this = shift; $this->{type} = 'wire'; return $this;
}

#
# $Signal = $Signal->reg
#
# A public chainable method that turns the Signal into a reg.
#
#
# $Signal = $Signal->reg($Clock)
# $Signal = $Signal->reg($Clock,$Reset)
# $Signal = $Signal->reg($Clock,$Reset,$default)
#
# A public chainable method that turns the Signal into a reg that is clocked by 
# the supplied $Clock Signal and reset by the supplied $Reset Signal, if 
# supplied.  If the register is reset register will reset to the $default, 
# if supplied, or {size}'d0 otherwise.
#
sub reg {
	my $this    = shift; 
	my $Clock   = shift;
	my $Reset   = shift;
	my $default = shift;

 	$this->error("Signal $Clock is not a clock.") unless $Clock->{class} eq 'clock';
	$this->{type}  = 'reg';
	$this->{Clock} = $Clock;
	if ($Reset) {
		$this->error("Signal $Reset is not a reset.") unless $Reset->{class} eq 'reset';
		$this->{Reset}   = $Reset;
		$this->{default} = $default || sprintf("%d'd0",$this->{size});
	}
	return $this;
}

#
# $Signal = $Signal->clock
#
# A public chainable method that turns the Signal into a clock, which is
# an input wire used to posedge trigger always blocks
#
sub clock {
	my $this = shift; 
	$this->{class} = 'clock'; 
	$this->{edge}  = 'posedge';
	return $this->input->wire;
}

#
# $Signal = $Signal->reset
#
# A public chainable method that turns the Signal into a reset, which is
# an input wire used to negedge trigger always blocks and set registers
# to a default state when asserted.
#
sub reset {
	my $this = shift; 
	$this->{class} = 'reset'; 
	$this->{edge}  = 'negedge'; 
	return $this->input->wire;
}

#------------------
# Module Interface
#------------------

#
# $Signal = new Signal($name);
# $Signal = new Signal($name,$size);
# $Signal = new Signal($name,$size,$lsb);
#
# A backstage method that returns a new instance of a Signal object
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $name     = shift;
	my $size     = shift; $size = 1 unless defined $size;
	my $lsb      = shift; $lsb  = 0 unless defined $lsb;
	my $this     = { 
		name    => $name,
		size    => $size,
		lsb     => $lsb,
		type    => undef,
		port    => undef,
		verilog => undef
	};
	$this->{msb} = $lsb+$size-1 if ($size > 1);
	return bless $this, $class;
}

#
# $verilog = $Signal->declaration
#
# A backstage method that returns a verilog declaration that depends on the
# Signal type and port.
#
#   "input  wire            name,\n"
#   "input  wire [msb:lsb]  name,\n"
#   "output wire            name,\n"
#   "output wire [msb:lsb]  name,\n"
#   "output reg             name,\n"
#   "output reg  [msb:lsb]  name,\n"
#   "wire            name;\n"
#   "wire [msb:lsb]  name;\n"
#   "reg             name;\n"
#   "reg  [msb:lsb]  name;\n"
#
#
sub declaration {
	my $this = shift;

	return $this->{verilog} if $this->{verilog};
	
	$this->{verilog}  = "";
	$this->{verilog} .= sprintf("  %-7s",$this->{port}) if $this->{port};
	$this->{verilog} .= sprintf("%-4s ",$this->{type});
	$this->{verilog} .= sprintf("%-10s",$this->{msb} ? sprintf("[%d:%d]",$this->{msb},$this->{lsb}) : "");
	$this->{verilog} .= $this->{name};
	$this->{verilog} .= $this->{port} ? "," : ";";
	$this->{verilog} .= "\n";

	return $this->{verilog};
}

#------------------
# Block Interface
#------------------

#
# $trigger = $Reg->trigger
#
# A backstage method that returns the condition that triggers the always
# block of a register:
#
# always @($trigger) ...
#
sub trigger {
	my $this     = shift; $this->error("Signal $Signal is not a reg.") unless $this->{type} eq 'reg';
	my $Clock    = $this->{Clock};
	my $Reset    = $this->{Reset};
	my $trigger  = "$Clock->{edge} $Clock->{name}";
	   $trigger .= " or $Reset->{edge} $Reset->{name}" if $Reset;
	return $trigger;
}

#
# $asserted = $Reset->asserted;
#
# A backstage method that returns the logic required to assert the reset 
# condition in an always block:
#
# always @(trigger) begin
#   if ($asserted) begin
#     ...
#
sub asserted {
	my $this = shift; $this->error("Signal $Signal is not a reset.") unless $this->{class} eq 'reset';
	return sprintf("%s%s",$this->{edge} eq 'negedge' ? '~' : '',$this->{name});
}





#-------------------------------------------------------------------------------
package Block;
#-------------------------------------------------------------------------------
#
# A Block is a group of related assign & always statements within a Module.
#
use base ('Object');

#------------
# Public API
#------------

#
# $Block = $Block->assign($Wire,$logic,...);
#
# A public chainable method that adds an assign statement to the Block 
# implementation:
#
# assign wire = logic;
#
# If the $Wire is actually a $Reg the $logic is set with an always block 
# instead.
#
sub assign {
	my $this   = shift;
	my $Wire   = shift;
	my $format = shift;
	my $logic  = sprintf($format,@_);
	return $this->always($Wire,$logic) if $Wire->{Clock};
	$this->{assigns}->{$Wire->{name}} = $logic;
	return $this;

}

#
# $Block = $Block->always($Reg,$logic,...);
#
# A public chainable method that adds an always statement to the Block
# implemenation:
#
# always @(posedge clock or negedge reset) begin
#   if (~reset) begin
#     reg <= 1'd0;
#   end else begin
#     reg <= logic;
#   end
# end
#
# -OR-
#
# always @(posedge clock) begin
#   reg <= logic;
# end
#
# The Clock, Reset, and default values are dictated by the supplied $Reg.
#
# If the $Reg is actually a $Wire the $logic is set with an assign statement
# instead.
#
sub always {
	my $this    = shift;
	my $Reg     = shift;
	my $format  = shift;
	my $logic   = sprintf($format,@_);
	return $this->assign($Reg,$logic) unless $Reg->{Clock};
	my $trigger = $Reg->trigger;
	my $Reset   = $Reg->{Reset};
	if ($Reset) {
		$this->{reset}->{$trigger} = $Reset->asserted;
		$this->{always}->{$trigger}->{$Reg} = {
			default => $Reg->{default},
			clocked => $logic
		};
	} else {
		$this->{always}->{$trigger}->{$Reg} = { 
			clocked => $logic
		};
	}
	return $this;
}

#
# $Block = new Block($Module);
#
# A backstage method that returns a new instance of a Block.
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $this     = {
		Module   => shift,
		comment  => shift,
		verilog  => undef
	};
	return bless $this, $class;
}

#----------------
# Module proxies
#----------------

#
# $boolean = $Block->has_signal($name);
#
# A backstage method that returns true if the given Signal $name exists
# in the Module, false otherwise.
#
sub has_signal {
	my $this = shift; return $this->{Module}->has_signal(shift);
}

#
# $Signal = $Block->get_signal($name);
#
# A backstage method the retrieves the Signal with the given $name.
#
sub get_signal {
	my $this = shift; return $this->{Module}->get_signal(shift);
}

#
# $Signal = $Block->add_signal($name);
# $Signal = $Block->add_signal($name,$size);
# $Signal = $Block->add_signal($name,$size,$lsb);
#
# A backstage method that adds a new Signal to the Module.
#
sub add_signal {
	my $this = shift; return $this->{Module}->add_signal(@_);
}

#------------------
# Module Interface
#------------------

#
# $verilog = $Block->declaration
#
# A backstage method that returns the Block declaration as a verilog string.
#
sub declaration {
	my $this = shift;
	my $width;
	my $tab;

	return $this->{verilog} if $this->{verilog};

	$this->{verilog}  = "";
	$this->{verilog} .= $this->{comment} . "\n" if $this->{comment};

	# implement combinatorial logic
	if (exists $this->{assigns}) {
		my @Wires = sort keys %{$this->{assigns}};
		$width = &u::maxlength(@Wires);
		$tab   = " " x ($width + 8);
		foreach my $Wire (@Wires) {
			$this->{verilog} .= sprintf("assign %-${width}s = %s;\n",$Wire,u::indented($tab,$this->{assigns}->{$Wire}));
		}
		$this->{verilog} .= "\n";
	}

	# implement sequential logic
	if (exists $this->{always}) {
		foreach my $trigger (sort keys %{$this->{always}}) {
			my $reset = $this->{reset}->{$trigger};
			my @Regs  = sort keys %{$this->{always}->{$trigger}};
			   $width = &u::maxlength(@Regs);
			if ($reset) {
				$tab      = " " x ($width + 6);
				$this->{verilog} .= "always @($trigger) begin\n";
				$this->{verilog} .= "  if ($reset) begin\n";
				foreach my $Reg (@Regs) {
					$this->{verilog} .= sprintf("    %-${width}s <= %s;\n",$Reg,u::indented($tab,$this->{always}->{$trigger}->{$Reg}->{default}));
				}
				$this->{verilog} .= "  end else begin\n";
				foreach my $Reg (@Regs) {
					$this->{verilog} .= sprintf("    %-${width}s <= %s;\n",$Reg,u::indented($tab,$this->{always}->{$trigger}->{$Reg}->{clocked}));
				}
				$this->{verilog} .= "  end\nend\n\n";
			} else {
				$tab      = " " x ($width + 4);
				$this->{verilog} .= "always @($trigger) begin\n";
				foreach my $Reg (@Regs) {
					$this->{verilog} .= sprintf("  %-${width}s <= %s;\n",$Reg,u::indented($tab,$this->{always}->{$trigger}->{$Reg}->{clocked}));
				}
				$this->{verilog} .= "end\n\n";
			}
		}
	}

	return $this->{verilog};
}





#-------------------------------------------------------------------------------
package Module;
#-------------------------------------------------------------------------------
#
# A Module is a named collection of Signals and Blocks
#
use EngineAPI;
use base ('Object');

#---------------------
# Backstage Interface
#---------------------

#
# $boolean = $Module->has_signal($name);
#
# A backstage method that returns true if the given Signal $name exists, 
# false otherwise.
#
sub has_signal {
	my $this = shift;
	my $name = shift;
	return exists $this->{Signals}->{$name};
}

#
# $Signal = $Module->get_signal($name);
#
# A backstage method the retrieves the Signal with the given $name.
#
sub get_signal {
	my $this = shift;
	my $name = shift;
	return $this->{Signals}->{$name};
}

#
# $Signal = $Module->add_signal($name);
# $Signal = $Module->add_signal($name,$size);
# $Signal = $Module->add_signal($name,$size,$lsb);
#
# A backstage method that adds a new Signal to the Module.
#
sub add_signal {
	my $this   = shift;
	my $Signal = new Signal(@_);
	$this->{Signals}->{$Signal->{name}} = $Signal;
	return $Signal;
}

#
# $Block = $Module->add_block;
#
# A backstage method that returns a new Block to the $Module user.
#
sub add_block {
	my $this  = shift;
	my $Block = shift || new Block($this);
	push @{$this->{Blocks}}, $Block;
	return $Block;
}

#------------------
# Engine Interface
#------------------

#
# $Module = new Module("name");
#
# A backstage method that returns a new instance of a Module.
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $this     = {
		name     => shift,
		Signals  => {}, 
		Blocks   => [],
		Inputs   => [],
		Outputs  => [],
		Wires    => [],
		Regs     => [],
		verilog  => undef,
	};
	return bless $this, $class;
}

#
# $verilog = $Module->declaration;
#
# A backstage method that returns the $Module implementation as a verilog string.
#
sub declaration {
	my $this    = shift;
	my $name    = $this->{name};

	return $this->{verilog} if $this->{verilog};
    
    foreach my $name (sort keys %{$this->{Signals}}) {
    	my $Signal = $this->get_signal($name);
    	if    ($Signal->{port} eq 'input' ) { push @{$this->{Inputs}},  $Signal;  }
    	elsif ($Signal->{port} eq 'output') { push @{$this->{Outputs}}, $Signal;  }
    	elsif ($Signal->{type} eq 'wire'  ) { push @{$this->{Wires}},   $Signal;  }
    	elsif ($Signal->{type} eq 'reg'   ) { push @{$this->{Regs}},    $Signal;  }
    	else  {$Signal->debug(); &sc_fatal("Unknown Signal type $Signal");        }
    }

    $this->{verilog} = "module $name (\n";
    foreach my $Input (@{$this->{Inputs}}) { 
    	$this->{verilog} .= $Input->declaration; 
    }
    $this->{verilog} .= "\n";
    foreach my $Output (@{$this->{Outputs}}) {	
    	$this->{verilog} .= $Output->declaration; 
    }
    $this->{verilog} =~ s/,$//;
    $this->{verilog} .= ");\n\n";
	foreach my $Wire (@{$this->{Wires}}) { 
		$this->{verilog} .= $Wire->declaration; 
	}
    $this->{verilog} .= "\n";
	foreach my $Reg (@{$this->{Regs}}) { 
		$this->{verilog} .= $Reg->declaration; 
	}
    $this->{verilog} .= "\n";
	foreach my $Block (@{$this->{Blocks}}) {
		$this->{verilog} .= $Block->declaration;
	}
    $this->{verilog} .= "\nendmodule\n";

    return $this->{verilog};
}





1;