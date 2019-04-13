################################################################################
#
#
# THE FOLLOWING CLASS DEFINES VIRTUAL METHODS THAT NEED TO BE IMPLEMENTED
#
#
################################################################################
#-------------------------------------------------------------------------------
package Bus;
#-------------------------------------------------------------------------------
#
# A Bus is a group of Signals with a Decoder Block that decodes addresses and
# fans-out write data to Fields and a Return Block that fans-in read data
# and errors.
#
use EngineAPI;
use Verilog::Module;
use base ('Object');

#---------------------
# Virtual Bus Signals
#---------------------
#
# In order to access Fields, a Bus derivative needs to provide an implementation
# of the following Virutal Signals.
#
# Each Virtual Signal is requested on an as needed basis, which means it should
# be added to the Module via the $Bus->Signal API and configured with the 
# callback.  The callback should also install any dependent logic it needs,
# which futher triggers callbacks.
#
# For example, a RW Field needs the Bus->Write Signal, which needs one or more
# Bus->Decode Signals, each of which needs the Bus->Address.  Hence the Field 
# implementation triggers a chain of callbacks that result in the Module
# being constructed "on-the-fly".
#

#
# $Clock = $Bus->Clock;
#
# A virtual method that creates and returns the Bus Clock Signal to clock 
# Signals on the Bus Clock clock domain.
#
sub Clock {
	&sc_error("Bus->Clock not implemented.");
}

#
# $Reset = $Bus->Reset;
#
# A virtual method that creates and returns the Bus Reset Signal to reset 
# Signals on the Bus Clock clock domain.
#
sub Reset {
	&sc_error("Bus->Reset not implemented.");
}

#
# $Address = $Bus->Address;
#
# A virtual method that creates and returns the Address Bus.
#
#  ADDRPOWER  is the optimal size of the address bus.
#  ADDRPORT   is the optimal size unless overriden by a Bus parameter.
#
# See the new constructor for more details on the bus parameters.
#
sub Address {
	&sc_error("Bus->Address not implemented.");
}

#
# $Decode = $Bus->Decode($address);
#
# A virtual method that creates a Signal that asserts that the Address matches
# the supplied $address.
#
# The $address supplied has units of (1<<UNITPOWER) but is aligned to 
# (1<<DATAPOWER), which means that $address[DATAPOWER-1:0] are 0, while
# $address[ADDRPOWER:DATAPOWER] carry the value to decode.
#
# See the new constructor for more details on the bus parameters.
#
sub Decode  {
	&sc_error("Bus->Decode not implemented.");
}

#
# $Write = $Bus->Write;
#
# A virtual method that creates a Signal that asserts that the Bus is writing
# data.
#
sub Write {
	&sc_error("Bus->Write not implemented.");
}

#
# $Wdata = $Bus->Wdata;
#
# A virtual method that creates a Signal of size DATABITS that is the data
# written on a write.
#
sub Wdata {
	&sc_error("Bus->Wdata not implemented.");
}

#
# $Rdata = $Bus->Rdata;
#
# A virtual method that creates a Signal of size DATABITS that gets assigned
# the data read on a read.
#
sub Rdata {
	&sc_error("Bus->Rdata not implemented.");
}

#
# $Error = $Bus->Error;
#
# A virtual method that creates a Signal that outputs a bus error of undef
# if not supported.
#
sub Error {
	return undef;
}

#------------------------
# Bus Implementation API
#------------------------
#
# The following methods are the public interface for implementing the
# Virtual Signals.
#

#
# $address_decode = $Bus->decode($name,$address);
#
# A public method that nicely adds the $address to a base decode signal $name.
#
sub decode {
	my $Bus     = shift;
	my $base    = shift;
	my $address = shift;
	return sprintf("%s_".&u::sized($Bus->{ADDRPOWER})."h",$base,$address);
}

#
# $Decoder = $Bus->Decoder;
#
# A public shortcut for dereferencing the Decoder Block.
#
sub Decoder {
	return shift->{Decoder};
}

#
# $Return = $Bus->Return;
#
# A public shortcut for dereferencing the Return Block.
#
sub Return {
	return shift->{Return};
}

#
# $Signal = $Bus->Signal($name,$callback);
#
# A public method that returns the $Signal with the given $name.
# If the $Signal does not already exist, the method will create the 
# $Signal and pass it to the $callback, which is then used to configure
# the $Signal (e.g. as an input wire etc), and add any dependent logic
# to the Decoder, Return path, or other Module Blocks.
#
sub Signal {
	my $Bus  = shift;
	my $name = shift;
	my $add  = shift; $add = sub {} unless defined $add;
	&$add($Bus->add_signal($name)) unless $Bus->has_signal($name);
	return $Bus->get_signal($name);
}

#------------------
# Module Interface
#------------------

#
# A backstage method that implements the Decoder Block in the Module.
# This is called *before* any fields or regions are implemented because 
# those depend on the Decoder for address decoding.
#
sub add_Decoder {
	my $Bus     = shift;
	my $Module  = shift;
	my $Decoder = $Bus->{Decoder} = $Module->add_block();

	$Decoder->{comment} = "\n//\n// Address Decoding\n//\n";

	# Cross reference our objects while we've got both in hand.

	$Module->{Bus} = $Bus;      # Give the Module a reference to the Bus
	$Bus->{Module} = $Module;   # Give the Bus a reference to the Module
}

#
# $Bus->add_Return;
#
# A backstage method that implements the Return Block in the Module.
# This is called *after* all fields or regions have been implemented
# since the outputs must be collected before they they can be assembled
# as Bus outputs.
#
sub add_Return {
	my $Bus    = shift;
	my $Module = shift;
	my $Return = $Bus->{Return} = $Module->add_block();

	$Return->{comment} = "\n//\n// Return Path\n//\n";

	# Return Data
	my @Rdata = @{$Bus->{Values}};
	$Return->assign($Bus->Rdata,join("\n| ",@Rdata)) if @Rdata;

	# Bus Errors
	my @Errors = @{$Bus->{Errors}};
	$Return->assign($Bus->Error,join("\n| ",@Errors)) if @Errors and $Bus->Error;
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
	my $Bus = shift; return $Bus->{Module}->has_signal(shift);
}

#
# $Signal = $Bus->get_signal($name);
#
# A backstage method the retrieves the Signal with the given $name.
#
sub get_signal {
	my $Bus = shift; return $Bus->{Module}->get_signal(shift);
}

#
# $Signal = $Bus->add_signal($name);
# $Signal = $Bus->add_signal($name,$size);
# $Signal = $Bus->add_signal($name,$size,$lsb);
#
# A backstage method that adds a new Signal to the Module.
#
sub add_signal {
	my $Bus = shift; return $Bus->{Module}->add_signal(@_);
}

#-----------------
# Field Interface
#-----------------

#
# $Bus->map($Field);
#
# A backstage method that maps fields to one or more bus accesses.
# This does the heavy lifting of splitting a field into multiple accesses
# up front, so that the rest of the field methods are lighter.
#
sub map {
	my $Bus    = shift;
	my $Field  = shift;
	my $size   = $Field->{size};
	my $mask   = $Bus->{DATABITS}-1;
	my $shift  = $Bus->{DATAPOWER}+$Bus->{UNITPOWER};
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
		$bit = $Bus->access($access,$address,$lsb,$mask,$bit);
		$lsb = 0;
		$address++;
	}
	$Bus->access($access,$address,$lsb,$last->{bit},$bit);

	$Field->{access} = $access;
}

#
# $Bus->return($Value);
#
# A backstage method that collects $Values for the Return path.
#
sub return {
	my $Bus   = shift;
	my $Value = shift;
	push @{$Bus->{Values}}, $Value;
}

#
# $Bus->error($Signal);
#
# A backstage method that collects error $Signals for the Return path.
#
sub error {
	my $Bus   = shift;
	my $Error = shift;
	push @{$Bus->{Errors}}, $Error;
}

#
# $Bus->access($access,$address,$lsb,$msb,$index)
#
# A private method that "walks" through the field in DATABITS sized chunks
# recording the formating information for decode fanout, write data slicing 
# and read data packing.
#
sub access {
	my $Bus       = shift;
	my $access    = shift;
	my $address   = shift; # DATABITS per address
	my $wd_lsb    = shift;
	my $wd_msb    = shift;
	my $rv_lsb    = shift;
	my $size      = $wd_msb-$wd_lsb+1;
	my $rv_msb    = $rv_lsb+$size-1;
	my $bus_msb   = $Bus->{DATABITS}-1;
	my $single    = ($size == 1);

	#
	# The format for faning out the decode
    #
	my $decode = $single ? "%s" : sprintf("{%d{%%s}}",$size);

	#
	# The format for slicing the write data
	#
    my $write = $single ? "%s[$wd_lsb]" : "%s[$wd_msb:$wd_lsb]";
	
	#
	# The format for returning the read data
	#
	my @read = ();
	push @read, sprintf("%d'd0",$bus_msb-$wd_msb) if $wd_msb != $bus_msb;
	push @read, $single ? "%s[$rv_lsb]" : "%s[$rv_msb:$rv_lsb]";
	push @read, sprintf("%d'd0",$wd_lsb         ) if $wd_lsb != 0;
	my $read = u::concat(@read);

	push @{$access}, {
		address => $address<<$Bus->{DATAPOWER}, # UNITBITS per address
		decode  => $decode,
		write   => $write,
		read    => $read,
	};

	return $rv_lsb+$size;
}

#------------------
# Engine Interface
#------------------

#
# $Bus = new Bus(%parameters)
#
# A public method that returns a new instance of a Bus.
#
# Bus Parameters
# --------------
#
# A Bus has the following primary input parameters:
#
#     UNITPOWER : 2^UNITPOWER bits per address
#     DATAPOWER : 2^DATAPOWER units per access
#
# And the following derived parameters :
#
#     ADDRPOWER = f(space size)             : The number of bits of address
#     DATABITS  = (1<<UNITPOWER<<DATAPOWER) : The number of bits per access
#
# The derived parameters stem from the prevailing Bus architures:
#
# (1) An address space assigns one address to each group of UNITBITS bits, 
#     where UNITBITS is two to the power of UNITPOWER.
#
#     UNITPOWER   = ?
#     UNITBITS    = 1<<UNITPOWER            The number of bits per address.
#
# (2) A bus uses a single address to access DATABITS at a time, where
#     DATABITS is a two to the power of DATAPOWER multiple of UNITBITS.
#
#     DATAPOWER = ?
#     DATAUNITS = 1<<DATAPOWER          The number of units per access.
#     DATABITS  = DATAUNITS<<UNITPOWER  The number of bits  per access.
#
# For example, a UNITPOWER = 3 space with an DATAPOWER = 2 access system is a:
#
#     UNITBITS = 1<<3    =  8 bits = 1 Byte
#     DATABITS = 1<<2<<3 = 32 bits = 1 Word
#
#     Byte space with a Word access system.
#
sub new {
	my $invocant  = shift;
	my $class     = ref($invocant) || $invocant;
	my $UNITPOWER = 3;
	my $DATAPOWER = 2;
	my $ADDRPOWER = &u::clog2(&sc_get_space()->sc_get_size);
	my $ADDRPORT;

	while (@_) {
		my $op = shift;
		if    ($op eq "--unitpower") { $UNITPOWER = shift; }
		elsif ($op eq "--datapower") { $DATAPOWER = shift; }
		elsif ($op eq "--addrpower") { $ADDRPORT  = shift; }
	}

	$ADDRPOWER -= $UNITPOWER;

	my $Bus = {
		# Bus Parameters
		UNITPOWER => $UNITPOWER,
		DATAPOWER => $DATAPOWER,
		DATABITS  => 1<<$DATAPOWER<<$UNITPOWER,
		ADDRPOWER => $ADDRPOWER,
		ADDRPORT  => $ADDRPORT || $ADDRPOWER,
		# Blocks
		Decoder  => undef, # Defined by $Bus->decoder
		Return   => undef, # Defined by $Bus->return
		# Return Path
		Values   => [],
		Errors   => [],
	};

	return bless $Bus, $class;
}





################################################################################
#
#
# THE FOLLOWING IS AN IMPLEMENTATION OF THE BUS ABSTRACTION
#
#
################################################################################
#-------------------------------------------------------------------------------
package APB;
#-------------------------------------------------------------------------------
use base('Bus');

sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $Bus      = new Bus(@_);

	while (@_) {
		my $op = shift;
		if ($op eq "--pslverr") { $Bus->{pslverr} = 1; }
	}

	return bless $Bus, $class;
}

#-------------------------------
# Virtual Signal Implementation
#-------------------------------

sub Clock {
	my $Bus = shift;
	return $Bus->Signal("pclk", sub {
		# Mark Pclk as a clock, a posedge triggered input wire
		shift->clock;
	});
}

sub Reset {
	my $Bus = shift;
	return $Bus->Signal("presetn", sub {
		# Mark Presetn as a reset, a negedge triggered input wire
		shift->reset;
	});
}

sub Address {
	my $Bus = shift;
	return $Bus->Signal("paddr", sub {
		# Add the Paddr[ADDRPORT:0] input wire
		shift->size($Bus->{ADDRPORT})->input->wire;
	});
}

sub Decode {
	my $Bus     = shift;
	my $address = shift;
	return $Bus->Signal($Bus->decode("paddr_reg",$address),sub {
		# Decode from a locally registered paddr.
		# Note that paddr[DATAPOWER-1:0] is not compared.
		# Also note how by referencing $Bus->Pactive_reg, it triggers
		# a chain of callbacks that ultimately add the psel & penable
		# inputs.
		my $Decode = shift->wire;
		$Bus->Decoder->assign($Decode,"%s && (%s == %d'h%X)",
			$Bus->Pactive_reg,$Bus->Paddr_reg,$Bus->{ADDRPOWER}-$Bus->{DATAPOWER}+1,$address>>$Bus->{DATAPOWER});
	});
}

sub Write {
	my $Bus = shift;
	return $Bus->Signal("pwrite_reg", sub {
		# Write from a locally registered pwrite
		my $Pwrite_reg = shift->reg($Bus->Clock,$Bus->Reset);
		my $Pwrite     = $Bus->Signal("pwrite")->input->wire;
		$Bus->Decoder->always($Pwrite_reg," ".$Pwrite);
	});
}

sub Wdata {
	my $Bus = shift;
	return $Bus->Signal("pwdata_reg", sub {
		# Write data from a locally registered pwdata
		my $Pwdata_reg = shift->size($Bus->{DATABITS})->reg($Bus->Clock,$Bus->Reset);
		my $Pwdata     = $Bus->Signal("pwdata")->size($Bus->{DATABITS})->input->wire;
		$Bus->Decoder->always($Pwdata_reg," ".$Pwdata);
	});
}

sub Rdata {
	my $Bus = shift;
	return $Bus->Signal("prdata",sub {
		# Register the prdata
		shift->size($Bus->{DATABITS})->output->reg($Bus->Clock,$Bus->Reset);
		# Add and drive the pready signal
		my $Pready = $Bus->Signal("pready")->output->reg($Bus->Clock,$Bus->Reset);
		$Bus->Return->always($Pready,$Bus->Pactive_reg);
	});
}

sub Error {
	my $Bus = shift;
	return undef unless $Bus->{pslverr};
	return $Bus->Signal("pslverr", sub {
		my $Pslverr = shift->output->reg($Bus->Clock,$Bus->Reset);
	});
}

#------------------------------------
# APB Specific Signal Implementation
#------------------------------------

sub Psel {
	my $Bus = shift;
	return $Bus->Signal("psel", sub {
		# Add the psel input wire
		shift->input->wire; 
	});
}

sub Penable {
	my $Bus = shift;
	return $Bus->Signal("penable", sub { 
		# Add the penable input wire
		shift->input->wire; 
	});
}

sub Pactive_reg {
	my $Bus = shift;
	return $Bus->Signal("pactive_reg", sub {
		# Locally register the transaction start
		my $Pactive = shift; $Pactive->reg($Bus->Clock,$Bus->Reset);
		$Bus->Decoder->always($Pactive," %s && !%s",$Bus->Psel,$Bus->Penable);
	});
}

sub Paddr_reg {
	my $Bus = shift;
	return $Bus->Signal("paddr_reg", sub {
		# Locally register and hold the address on the transaction start
		# Note that paddr[DATAPOWER-1:0] is not captured since it is unused
		# in the Decode.
		my $Paddr_reg = shift; 
		$Paddr_reg->size($Bus->{ADDRPOWER}-$Bus->{DATAPOWER},$Bus->{DATAPOWER});
		$Paddr_reg->reg($Bus->Clock,$Bus->Reset);
		$Bus->Decoder->always($Paddr_reg,"(%s && !%s) ? %s[%d:%d] : %s",
			$Bus->Psel,$Bus->Penable,$Bus->Address,$Bus->{ADDRPOWER},$Bus->{DATAPOWER},$Paddr_reg);
	});
}





1;