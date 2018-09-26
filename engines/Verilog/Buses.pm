#-------------------------------------------------------------------------------
package Bus;
#-------------------------------------------------------------------------------
#
# A Bus is a group of Signals with a *Decoder Block* that decodes addresses and
# fans-out write data to Fields and a *Return Block* that fans-in read data
# and errors.
#
use EngineAPI;
use Verilog::Module;
use base ('Object');

#
# A public method that returns a new instance of a Bus.
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my %options  = @_;
	my $space    = &sc_get_space();
	my $spacesize = $space->sc_get_size;
	my $unitsize = $options{unitsize} || 8;
	my $optsize  = &u::clog2($spacesize / $unitsize);
	my $addrsize = $options{addrsize} || $options{optimize} ? $optsize : 32;
	my $datasize = $options{datasize} || 4;

	my $this = {
		# Bus parameters
		unitsize => $unitsize,           # A single address refers to $unitsize bits, typically 8 bits
		addrsize => $addrsize,           # The space is 2^addrsize, typically 32 bits
		datasize => $datasize*$unitsize, # A single access returns N units
		# Signal names
		clock    => 'up_clk',
		reset    => 'up_reset',
		address  => 'up_address',
		select   => 'up_sel',
		enable   => 'up_enable',
		write    => 'up_write',
		wdata    => 'up_wdata',
		rdata    => 'up_rdata',
		ready    => 'up_ready',
		error    => 'up_error',
		# Blocks
		Decoder  => undef, # Defined by $this->decoder
		Return   => undef, # Defined by $this->return
	};

	return bless $this, $class;
}

#
# A backstage method that implements the Decoder Block in the Module.
#
sub decoder {
	my $this   = shift;
	my $Module = shift;

	#
	# Though this is the Decoder Block declaration, the $Return path also needs 
	# to be declared so that Fields can use the decoder then add to the $Return 
	# path. The Return does not use $Module->block() becuase we don't want the 
	# $Return path added to the module until after the Field Blocks have been 
	# added.
	#

	my $Decoder = $this->{Decoder} = $Module->add_block();
	my $Return  = $this->{Return}  = new Block($Module);

	$Decoder->{comment} = "/* Address Decoding */";
	$Return->{comment}  = "/* Return Path */";

	# Cross reference our objects

	$Module->{Bus}  = $this;     # Give the Module a reference to the Bus
	$this->{Module} = $Module;   # Give the Bus a reference to the Module

	# Convert signal names into Signal Objects

	# Clock & Reset
	$this->{Clock}   = $this->add_signal($this->{clock})->clock; delete $this->{clock};
	$this->{Reset}   = $this->add_signal($this->{reset})->reset; delete $this->{reset};

	# Decoder Signals
	$this->{Address} = $Decoder->add_signal($this->{address},$this->{addrsize})->input->wire; delete $this->{address};
	$this->{Select}  = $Decoder->add_signal($this->{select})->input->wire;                    delete $this->{select};
	$this->{Enable}  = $Decoder->add_signal($this->{enable})->input->wire;                    delete $this->{enable};
	$this->{Write}   = $Decoder->add_signal($this->{write})->input->wire;                     delete $this->{write};
	$this->{Wdata}   = $Decoder->add_signal($this->{wdata},$this->{datasize})->input->wire;   delete $this->{wdata};

	# Return Path Signals
	if ($this->{registered}) {
		my $Rdata      = $Return->add_signal($this->{rdata},$this->{datasize})->output->reg($this->{Clock},$this->{Reset});
		$this->{Rdata} = $Return->add_signal($this->{rdata}."_q",$this->{datasize})->wire;

		my $Ready      = $Return->add_signal($this->{ready})->output->reg($this->{Clock},$this->{Reset});
		$this->{Ready} = $Return->add_signal($this->{ready}."_q")->wire;

		my $Error      = $Return->add_signal($this->{error})->output->reg($this->{Clock},$this->{Reset});
		$this->{Error} = $Return->add_signal($this->{error}."_q")->wire;
		
		$Return->always($Rdata,$this->{Rdata}); delete $this->{rdata};
		$Return->always($Ready,$this->{Ready}); delete $this->{ready};
		$Return->always($Error,$this->{Error}); delete $this->{error};
	} else {
		$this->{Rdata} = $Return->add_signal($this->{rdata},$this->{datasize})->output->wire; delete $this->{rdata};
		$this->{Ready} = $Return->add_signal($this->{ready})->output->wire;                   delete $this->{ready};
		$this->{Error} = $Return->add_signal($this->{error})->output->wire;                   delete $this->{error};
	}

}

#
# $Bus->return;
#
# A backstage method that implements the Return Block in the Module.
#
sub return {
	my $this = shift; $this->{Module}->add_block($this->{Return});
}

#----------------
# Module proxies
#----------------

#
# $boolean = $Bus->has_signal($name);
#
# A backstage method that returns true if the given Signal $name exists
# in the Module, false otherwise.
#
sub has_signal {
	my $this = shift; return $this->{Module}->has_signal(shift);
}

#
# $Signal = $Bus->get_signal($name);
#
# A backstage method the retrieves the Signal with the given $name.
#
sub get_signal {
	my $this = shift; return $this->{Module}->get_signal(shift);
}

#
# $Signal = $Bus->add_signal($name);
# $Signal = $Bus->add_signal($name,$size);
# $Signal = $Bus->add_signal($name,$size,$lsb);
#
# A backstage method that adds a new Signal to the Module.
#
sub add_signal {
	my $this = shift; return $this->{Module}->add_signal(@_);
}

#-------------------------
# Field/Decoder Interface
#-------------------------

sub get_decode {
	my $this = shift; return "decode";
};

sub get_select {
	my $this = shift; return "select";
};

sub get_write_select {
	my $this = shift; return "write_select";
};

sub get_write_enable {
	my $this = shift; return "write_enable";
};

sub get_write_data {
	my $this = shift; return "write_data";
};

sub get_read_select {
	my $this = shift; return "read_select";
};

sub get_read_enable {
	my $this = shift; return "read_enable";
};

#-----------------------------
# Field/Return Path Interface
#-----------------------------

sub add_read_data {
	my $this = shift;
};

sub add_error {
	my $this = shift;
}


#-------------------------------------------------------------------------------
package APB;
#-------------------------------------------------------------------------------
use base('Bus');

sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $this     = Bus::new($class,@_);

	$this->{clock}   = "pclk";
	$this->{reset}   = "presetn";
	$this->{address} = "paddr";
	$this->{select}  = "psel";
	$this->{enable}  = "penable";
	$this->{write}   = "pwrite";
	$this->{wdata}   = "pwdata";
	$this->{rdata}   = "prdata";
	$this->{ready}   = "pready";
	$this->{error}   = "pslverr";

	return $this;
}

1;