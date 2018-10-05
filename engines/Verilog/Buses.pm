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
# Bus parameters
# --------------
#
# An address space assigns one address to each group of UNITBITS bits, 
# where UNITBITS is two to the power of UNITPOWER.
#
# UNITBITS    = 1<<UNITPOWER            The number of bits per address.
# UNITPOWER   = ?
#
# A bus uses a single address to access DATABITS at a time, where
# DATABITS is a two to the power of DATAPOWER multiple of UNITBITS.
#
# DATABITS  = DATAUNITS<<UNITPOWER  The number of bits  per access.
# DATAUNITS = 1<<DATAPOWER          The number of units per access.
# DATAPOWER = ?
#
# Example:
#
# A UNITPOWER = 3 space with an DATAPOWER = 2 access system is a:
#
# UNITBITS = 1<<3    =  8 bits = 1 Byte
# DATABITS = 1<<2<<3 = 32 bits = 1 Word
#
# Byte space with a Word access system.
#
#

#
# A public method that returns a new instance of a Bus.
#
sub new {
	my $invocant  = shift;
	my $class     = ref($invocant) || $invocant;
	my %options   = @_;
	my $UNITPOWER = $options{UNITPOWER}   || 3;
	my $DATAPOWER = $options{ACCESSPOWER} || 2;
	my $ADDRPOWER = &u::clog2(&sc_get_space()->sc_get_size>>$UNITPOWER);

	my $this = {
		# Bus parameters
		UNITPOWER => $UNITPOWER,
		UNITBITS  => 1<<$UNITPOWER,
		DATAPOWER => $DATAPOWER,
		DATAUNITS => 1<<$DATAPOWER,
		DATABITS  => 1<<$DATAPOWER<<$UNITPOWER,
		ADDRPOWER => $ADDRPOWER,
		ADDRPORT  => $options{optimize} ? $ADDRPOWER : ($options{addrport} || 32),
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
		# Return Path
		data     => [],
	};

	my $size = &sc_get_space()->sc_get_size;
	printf "size = %d bits = %d units (%d) <= 2^%d\n", $size, ($size>>$UNITPOWER), $UNITPOWER, $ADDRPOWER;
	  

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

	$Decoder->{comment} = "/* Address Decoding */\n";
	$Return->{comment}  = "/* Return Path */";

	# Cross reference our objects

	$Module->{Bus}  = $this;     # Give the Module a reference to the Bus
	$this->{Module} = $Module;   # Give the Bus a reference to the Module

	# Convert signal names into Signal Objects

	# Clock & Reset
	$this->{Clock}   = $this->add_signal($this->{clock})->clock; delete $this->{clock};
	$this->{Reset}   = $this->add_signal($this->{reset})->reset; delete $this->{reset};

	# Decoder Signals
	$this->{Address} = $Decoder->add_signal($this->{address},$this->{ADDRPORT})->input->wire; delete $this->{address};
	$this->{Select}  = $Decoder->add_signal($this->{select})->input->wire;                    delete $this->{select};
	$this->{Enable}  = $Decoder->add_signal($this->{enable})->input->wire;                    delete $this->{enable};
	$this->{Write}   = $Decoder->add_signal($this->{write})->input->wire;                     delete $this->{write};
	$this->{Wdata}   = $Decoder->add_signal($this->{wdata},$this->{DATABITS})->input->wire;   delete $this->{wdata};

	# Return Path Signals
	if ($this->{registered}) {
		my $Rdata      = $Return->add_signal($this->{rdata},$this->{DATABITS})->output->reg($this->{Clock},$this->{Reset});
		$this->{Rdata} = $Return->add_signal($this->{rdata}."_q",$this->{DATABITS})->wire;

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

	$this->implement;

}

#
# $Bus->return;
#
# A backstage method that implements the Return Block in the Module.
#
sub return {
	my $this = shift; $this->{Module}->add_block($this->{Return});
}

sub cycle {
	my $Bus       = shift;
	my $access    = shift;
	my $addr      = shift;
	my $wd_lsb    = shift;
	my $wd_msb    = shift;
	my $rv_lsb    = shift;
	my $size      = $wd_msb-$wd_lsb+1;
	my $rv_msb    = $rv_lsb+$size-1;
	my $bus_msb   = $Bus->{DATABITS}-1;
	my $single    = ($size == 1);

	#
	# The format for naming the decode Signal that includes address[ADDRPOWER:0]
	#
	my $decode = sprintf("%%s_".&u::hexfmt($Bus->{ADDRPOWER})."h",$addr<<$Bus->{DATAPOWER});
	#
	# The address value for comparision to address[ADDRPOWER:DATAPOWER]
	#
	my $address = sprintf("%d'h%X",$Bus->{ADDRPOWER}-$Bus->{DATAPOWER},$addr);
	#
	# The format for faning out the decode Signal and write enable Signal
    #
	my $fanout = $single ? "%s" : sprintf("{%d{%%s}}",$size);
	#
	# The format for slicing the write data
	#
    my $wdata = $single ? "%s[$wd_lsb]" : "%s[$wd_msb:$wd_lsb]";
	#
	# The format for packing the read data
	#
	my @rdata = ();
	push @rdata, sprintf("%d'd0",$bus_msb-$wd_msb) if $wd_msb != $bus_msb;
	push @rdata, $single ? "%s[$rv_lsb]" : "%s[$rv_msb:$rv_lsb]";
	push @rdata, sprintf("%d'd0",$wd_lsb         ) if $wd_lsb != 0;
	my $rdata = u::concat(@rdata);

	push @{$access}, {
		decode  => $decode,
		address => $address,
		fanout  => $fanout,
		wdata   => $wdata,
		rdata   => $rdata,
	};

	return $rv_lsb+$size;
}

#
# $Bus->access($Field);
#
# A backstage method that maps fields to bus addresses
#
sub access {
	my $this   = shift;
	my $Field  = shift;
	my $size   = $Field->{size};
	my $mask   = $this->{DATABITS}-1;
	my $shift  = $this->{DATAPOWER}+$this->{UNITPOWER};
	my $first  = {};
	my $last   = {};
	my $access = [];
	my $address;

	$address = $Field->{address};
	$first->{address} = ($address >> $shift);
	$first->{bit}     = ($address &  $mask );
	$address = $Field->{address} + $Field->{size} - 1;
	$last->{address}  = ($address >> $shift);
	$last->{bit}      = ($address &  $mask );

	$address = $first->{address};
	my $lsb  = $first->{bit};
	my $bit  = 0;

	while ($address < $last->{address}) {
		$bit = &cycle($this,$access,$address,$lsb,$mask,$bit);
		$lsb = 0;
		$address++;
	}
	&cycle($this,$access,$address,$lsb,$last->{bit},$bit);

	# printf("%s %d@%d : \n",$Field->{name},$Field->{size},$Field->{address});
	# foreach my $x (@${access}) {
	# 	printf("\t%-5s %-20s %-20s %-20s\n", 
	# 		$x->{address}, 
	# 		sprintf($x->{fanout},sprintf($x->{decode},"decode")), 
	# 		sprintf($x->{wdata},"wdata"), 
	# 		sprintf($x->{rdata},"value")
	# 	);
	# }
	# printf("\n");

	$Field->{access} = $access;
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
	my $this   = shift;
	my $access = shift;
	my $decode = sprintf($access->{decode},"paddr_reg");
	if (not $this->has_signal($decode)) {
		my $Decode = $this->add_signal($decode)->wire;
		$this->{Decoder}->assign($Decode,"pactive_reg && (paddr_reg == %s)",$access->{address});
	}
	return $this->get_signal($decode);
};

sub get_select {
	my $this = shift;
};

sub get_write_select {
	my $this = shift;
};

sub get_write_enable {
	my $this  = shift;
	my $Field = shift;
	my $write = $Field->{name}."_write";
	if (not $this->has_signal($write)) {
		my $Write = $this->add_signal($write,$Field->{size})->wire;
		my @decodes = ();
		foreach my $access (@{$Field->{access}}) {
			unshift @decodes, sprintf($access->{fanout},$this->get_decode($access));
		}
		$Field->assign($Write,"%s & %s",u::fanout("pwrite_reg",$Field->{size}),u::concat(@decodes));
	}
	return $this->get_signal($write);
};

sub get_write_data {
	my $this  = shift;
	my $Field = shift;
	my $wdata = $Field->{name}."_wdata";
	if (not $this->has_signal($wdata)) {
		my $Wdata = $this->add_signal($wdata,$Field->{size})->wire;
		my @slices = ();
		foreach my $access (@{$Field->{access}}) {
			unshift @slices, sprintf($access->{wdata},"pwdata_reg");
		}
		$Field->assign($Wdata,u::concat(@slices));
	}
	return $this->get_signal($wdata);
};

sub get_read_select {
	my $this = shift;
};

sub get_read_enable {
	my $this  = shift;
	my $Field = shift;
	my $read  = $Field->{name}."_read";
	if (not $this->has_signal($read)) {
		my $Read = $this->add_signal($read,$Field->{size})->wire;
		my @decodes = ();
		foreach my $access (@{$Field->{access}}) {
			unshift @decodes, sprintf($access->{fanout},$this->get_decode($access));
		}
		$Field->assign($Read,"%s & %s",u::fanout("~pwrite_reg",$Field->{size}),u::concat(@decodes));
	}
	return $this->get_signal($read);
};

#-----------------------------
# Field/Return Path Interface
#-----------------------------

sub add_read_data {
	my $this   = shift;
	my $Field  = shift;
	my $Value  = shift;
	my $rdata  = $Field->{name}."_rdata";
	my $rvalue = $Field->{name}."_rvalue";
	if (not $this->has_signal($rdata)) {
		# Qualify the Value with the Read Enable
		my $Read   = $this->get_read_enable($Field);
		my $Rvalue = $this->add_signal($rvalue,$Field->{size})->wire;
		$Field->assign($Rvalue,"$Read & $Value");
		# Organize the Value into data chunks
		my $Rdata  = $this->add_signal($rdata,$this->{DATABITS})->wire;
		my @shifts = ();
		foreach my $access (@{$Field->{access}}) {
			unshift @shifts, sprintf($access->{rdata},$Rvalue);
		}
		$Field->assign($Rdata,join("\n| ", @shifts));
	}
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

sub implement {
	my $this    = shift;
	my $Clock   = $this->{Clock};
	my $Reset   = $this->{Reset};
	my $Decoder = $this->{Decoder};

	my $Paddr_reg   = $Decoder->add_signal("paddr_reg",$this->{ADDRPOWER}-$this->{DATAPOWER}+1,$this->{DATAPOWER})->reg($Clock,$Reset);
	my $Pactive_reg = $Decoder->add_signal("pactive_reg")->reg($Clock,$Reset);
	my $Pwrite_reg  = $Decoder->add_signal("pwrite_reg")->reg($Clock,$Reset);
	my $Pwdata_reg  = $Decoder->add_signal("pwdata_reg",$this->{DATABITS})->reg($Clock,$Reset);

	$Decoder->always($Paddr_reg  ,"(psel && !penable) ? paddr[%d:%d] : paddr_reg",$this->{ADDRPOWER},$this->{DATAPOWER});
	$Decoder->always($Pactive_reg," psel && !penable");
	$Decoder->always($Pwrite_reg ," pwrite");
	$Decoder->always($Pwdata_reg ," pwdata");

}


1;