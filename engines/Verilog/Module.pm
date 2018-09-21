package Verilog;
use EngineAPI;
use base qw(Exporter);

#-------------------------------------------------------------------------------
package u;
#-------------------------------------------------------------------------------
#
# A package of utilities
#

#
# $width = u::maxlength(@strings);
#
# Returns the maximum length of a list of strings.
#
sub maxlength {
	my $width = 0; foreach my $string (@_) { my $l = length $string; $width = $l if $l > $width; }
	return $width;
}

#
# $indented = u::indented($tab,$string);
#
# Return a string with the $tab inserted after each newline in the $string.
#
sub indented {
	my $tab   = shift;
	my $logic = shift;
	$logic =~ s/\n/"\n$tab"/ge;
	return $logic;
}

#-------------------------------------------------------------------------------
package Signal;
#-------------------------------------------------------------------------------
#
# A Signal is a verilog variable inside a Module.
#
# The class is overloaded so that it behaves like a string in string contexts.
#

use overload '""'  => sub { $_[0]->{name}; },
             'cmp' => sub { (ref($_[0]) ? $_[0]->{name} : $_[0]) cmp (ref($_[1]) ? $_[1]->{name} : $_[1]); };

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
		port    => undef
	};
	$this->{msb} = $lsb+$size-1 if ($size > 1);
	return bless $this, $class;
}

#
# $verilog = $Signal->declaration
#
# A backstage method that returns a declaration string that depends on the
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
	my $this    = shift;
	my $verilog = "";
	$verilog .= sprintf("  %-7s",$this->{port}) if $this->{port};
	$verilog .= sprintf("%-4s",$this->{type});
	$verilog .= sprintf("%-10s",$this->{msb} ? sprintf("[%d:%d]",$this->{msb},$this->{lsb}) : "");
	$verilog .= $this->{name};
	$verilog .= $this->{port} ? "," : ";";
	$verilog .= "\n";
	return $verilog;
}

#-------------------------------------------------------------------------------
package Wire;
#-------------------------------------------------------------------------------
use base ('Signal');

#
# $Wire = new Wire($name);
# $Wire = new Wire($name,$size);
# $Wire = new Wire($name,$size,$lsb);
#
# A backstage method that returns a new instance of a Wire Signal.
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $signal   = Signal::new($class,@_); $signal->{type} = 'wire';
	return $signal; 
}

#
# $Wire = $Wire->input
#
# A public chainable method that turns the wire into an *input* wire.
#
sub input {
	my $this = shift; $this->{port} = 'input'; return $this;
}

#
# $Wire = $Wire->output
#
# A public chainable method that turns the wire into an *output* wire.
#
sub output {
	my $this = shift; $this->{port} = 'output'; return $this;
}

#-------------------------------------------------------------------------------
package Clock;
#-------------------------------------------------------------------------------
use base ('Wire');

#
# $Clock = new Clock("name");
#
# A backstage method that returns a posedge triggered input Wire Signal.
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $name     = shift;
	my $wire     = Wire::new($class,$name); $wire->{edge} = 'posedge'; $wire->input;
	return $wire; 
}

#-------------------------------------------------------------------------------
package Reset;
#-------------------------------------------------------------------------------
use base ('Wire');

#
# $Reset = new Reset($name);
#
# A backstage method that returns a negedge triggered input Wire Signal.
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $name     = shift;
	my $wire     = Wire::new($class,$name); $wire->{edge} = 'negedge'; $wire->input;
	return $wire; 
}

#-------------------------------------------------------------------------------
package Reg;
#-------------------------------------------------------------------------------
use base ('Signal');

#
# $Reg = new Reg($name);
# $Reg = new Reg($name,$size);
# $Reg = new Reg($name,$size,$lsb);
#
# A backstage method that returns a new instance of a Reg Signal.
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $signal   = Signal::new($class,@_); $signal->{type} = 'reg';
	return $signal; 
}

#
# $Reg = $Reg->output
#
# A public chainable method that turns the reg into an *output* reg.
#
sub output {
	my $this = shift; $this->{port} = 'output'; return $this;
}

#
# $Reg = $Reg->clocked($Clock)
# $Reg = $Reg->clocked($Clock,$Reset)
# $Reg = $Reg->clocked($Clock,$Reset,$default)
#
# A public chainable method that clocks the register with the supplied $Clock 
# Signal.  If a $Reset Signal is supplied the register will be reset by the 
# signal, otherwise the register will not be reset.  If the register is reset 
# the register will reset to the $default, if supplied, or {size}'d0 otherwise.
#
sub clocked {
	my $this    = shift; 
	my $clock   = shift;
	my $reset   = shift;
	my $default = shift;

	$this->{Clock} = $clock;
	if ($reset) {
		$this->{Reset}   = $reset;
		$this->{default} = $default || sprintf("%d'd0",$this->{size});
	}
	return $this;
}

#-------------------------------------------------------------------------------
package Block;
#-------------------------------------------------------------------------------
#
# A Block is a group of related assign & always statements within a Module.
#

#
# $Block = new Block($Module);
#
# A backstage method that returns a new instance of a Block.
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $this     = {
		Module   => shift
	};
	return bless $this, $class;
}

#
# $Wire = $Block->wire($name);
# $Wire = $Block->wire($name,$size);
# $Wire = $Block->wire($name,$size,$lsb);
#
# A public method that returns a Module Wire for Block assign and always.
#
sub wire {
	my $this = shift; return $this->{Module}->signal(new Wire(@_));
}

#
# $Reg = $Block->reg($name);
# $Reg = $Block->reg($name,$size);
# $Reg = $Block->reg($name,$size,$lsb);
#
# A public method that returns a Module Reg for Block assign and always.
#
sub reg {
	my $this = shift; return $this->{Module}->signal(new Reg(@_));
}

#
# $Clock = $Block->reg($name);
#
# A public method that returns a Module Clock for Block assign and always.
#
sub clock {
	my $this = shift; return $this->{Module}->signal(new Clock(@_));
}

#
# $Clock = $block->reg($name);
#
# A public method that returns a Module Reset for Block assign and always.
#
sub reset {
	my $this = shift; return $this->{Module}->signal(new Reset(@_));
}

#
# $Block = $Block->assign($Wire,$format,...);
#
# A public chainable method that adds an assign statement to the Block 
# implementation:
#
# assign wire = logic;
#
sub assign {
	my $this   = shift;
	my $Wire   = shift;
	my $format = shift;
	my $logic  = sprintf($format,@_);
	$this->{assigns}->{$Wire->{name}} = $logic;
	return $this;

}

#
# $Block = $Block->always($Reg,$format,...);
#
# A public chainable method that adds an always statement to the Block
# implemenation:
#
# always @(posedge clock or negedge reset) begin
#   reg <= 1'd0;
# end else begin
#   reg <= logic;
# end
#
# The clock, reset, and default values are dictated by the supplied $Reg.
#
sub always {
	my $this   = shift;
	my $Reg    = shift;
	my $format = shift;
	my $logic  = sprintf($format,@_);
	my $Clock  = $Reg->{Clock};
	my $Reset  = $Reg->{Reset} || {edge => "0", name => "0"};
	my $ce     = $Clock->{edge};
	my $cn     = $Clock->{name};
	my $re     = $Reset->{edge};
	my $rn     = $Reset->{name};
	$this->{always}->{$ce}->{$cn}->{$re}->{$rn}->{$Reg->{name}} = {default => $Reg->{default}, logic => $logic};
}

#
# $verilog = $block->implementation
#
# A backstage method that returns the Block implementation as a verilog string.
#
sub implementation {
	my $this    = shift;
	my $verilog = "";
	my $width;
	my $tab;

	$verilog .= $this->{comment} . "\n" if $this->{comment};

	# implement combinatorial logic
	if (exists $this->{assigns}) {
		my @wires = sort keys %{$this->{assigns}};
		$width = &u::maxlength(@wires);
		$tab   = " " x ($width + 8);
		foreach my $wire (@wires) {
			$verilog .= sprintf("assign %-${width}s = %s;\n",$wire,u::indented($tab,$this->{assigns}->{$wire}));
		}
		$verilog .= "\n";
	}

	# implement sequential logic
	if (exists $this->{always}) {
		foreach my $ce (sort keys %{$this->{always}}) {
			foreach my $cn (sort keys %{$this->{always}->{$ce}}) {
				foreach my $re (sort keys %{$this->{always}->{$ce}->{$cn}}) {
					foreach my $rn (sort keys %{$this->{always}->{$ce}->{$cn}->{$re}}) {
						my @regs = sort keys %{$this->{always}->{$ce}->{$cn}->{$re}->{$rn}};
						$width = &u::maxlength(@regs);
						if ($rn eq "0") {
							$tab = " " x ($width + 4);
							$verilog .= "always @($ce $cn) begin\n";
							foreach my $reg (@regs) {
								$verilog .= sprintf("  %-${width}s <= %s;\n",$reg,u::indented($tab,$this->{always}->{$ce}->{$cn}->{$re}->{$rn}->{$reg}->{logic}));
							}
							$verilog .= "end\n\n";
						} else {
							$tab = " " x ($width + 6);
							$verilog .= "always @($ce $cn or $re $rn) begin\n";
							foreach my $reg (@regs) {
								$verilog .= sprintf("    %-${width}s <= %s;\n",$reg,u::indented($tab,$this->{always}->{$ce}->{$cn}->{$re}->{$rn}->{$reg}->{default}));
							}
							$verilog .= "  end else begin\n";
							foreach my $reg (@regs) {
								$verilog .= sprintf("    %-${width}s <= %s;\n",$reg,u::indented($tab,$this->{always}->{$ce}->{$cn}->{$re}->{$rn}->{$reg}->{logic}));
							}
							$verilog .= "  end\nend\n\n";
						}
					}
				}
			}
		}
	}

	return $verilog;
}

#-------------------------------------------------------------------------------
package Module;
#-------------------------------------------------------------------------------
#
# A Module is a named collection of Signals and Blocks
#

#
# $Module = new Module("name");
#
# A public method that returns a new instance of a Module.
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $this     = {
		name     => shift,
		signals  => {}, 
		blocks   => []
	};
	return bless $this, $class;
}

#
# $Block = $Module->block;
#
# A public method that returns a new Block to the $Module user.
#
sub block {
	my $this  = shift;
	my $block = new Block($this);
	push @{$this->{blocks}}, $block;
	return $block;
}

#
# $Signal = $Module->signal($Signal);
# $Signal = $Module->signal($name);
#
# An backstage method that creates and/or returns a $Signal from the $Module.
# If a $Signal is provided, the existing $Signal with the same name is returned
# if it exists, otherwise the $Signal is is added to the $Module and returned.
# If only a $name is provided, the $Signal must exist and is returned.
#
sub signal {
	my $this   = shift;
	my $signal = shift;
	if (not exists $this->{signals}->{$signal}) {
		&sc_fatal("$signal is not a Signal") unless ref $signal;
		$this->{signals}->{$signal} = $signal;
	}
	return $this->{signals}->{$signal};
}

#
# $verilog = $Module->implementation;
#
# A public method that returns the $Module implementation as a verilog string.
#
sub implementation {
	my $this    = shift;
	my $name    = $this->{name};
	my $verilog = "";
    my @inputs  = ();
    my @outputs = ();
    my @wires   = ();
    my @regs    = ();
    my $width;

    foreach my $name (sort keys %{$this->{signals}}) {
    	my $signal = $this->signal($name);
    	if    ($signal->{port} eq 'input' ) { push @inputs,  $signal;        }
    	elsif ($signal->{port} eq 'output') { push @outputs, $signal;        }
    	elsif ($signal->{type} eq 'wire'  ) { push @wires,   $signal;        }
    	elsif ($signal->{type} eq 'reg'   ) { push @regs,    $signal;        }
    	else  {$signal->debug(); &sc_fatal("Unknown signal type $signal\n"); }
    }

    $verilog .= "module $name (\n";
    foreach my $input (@inputs) { 
    	$verilog .= $input->declaration; 
    }
    $verilog .= "\n";
    foreach my $output (@outputs) {	
    	$verilog .= $output->declaration; 
    }
    $verilog =~ s/,$//;
    $verilog .= ");\n\n";
	foreach my $wire (@wires) { 
		$verilog .= $wire->declaration; 
	}
    $verilog .= "\n";
	foreach my $reg (@reg) { 
		$verilog .= $reg->declaration; 
	}
	foreach my $block (@{$this->{blocks}}) {
		$verilog .= $block->implementation;
	}
    $verilog .= "endmodule\n";

    return $verilog;
}

1;