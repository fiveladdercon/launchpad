#-------------------------------------------------------------------------------
# Packages
#-------------------------------------------------------------------------------
use Verilog::Module;

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
# A Bus has a Decoder Block that decodes addresses and fans-out write data & 
# controls to Field & Region Blocks, and a Return Block that fans-in read 
# data & controls from the Field & Region Blocks.
#
use base ('Object');

#---------------------
# Virtual Bus Signals
#---------------------
#
# In order to access Fields or Regions, a Bus derivative needs to provide 
# an implementation of the following Virutal Signals.
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
	my $Bus = shift;
	#
    # return $Bus->Signal("bus_clock", sub {
    #   my $Signal = shift;
    #	$Signal->clock;
    # });
    #
    # See the APB Class below for a working example.
    #
	$Bus->error("%s->Clock not implemented.", ref $Bus);
}

#
# $Reset = $Bus->Reset;
#
# A virtual method that creates and returns the Bus Reset Signal to reset 
# Signals on the Bus Clock clock domain.
#
sub Reset {
	my $Bus = shift;
	#
    # return $Bus->Signal("bus_reset", sub {
    #   my $Signal = shift;
    #	$Signal->reset;
    # });
    #
    # See the APB Class below for a working example.
    #
	$Bus->error("%s->Reset not implemented.", ref $Bus);
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
	my $Bus = shift;
	#
    # return $Bus->Signal("bus_address", sub {
    #   my $Signal = shift;
    #	$Signal->size($Bus->{ADDRPORT})->input->wire;
    # });
    #
    # See the APB Class below for a working example.
    #
	$Bus->error("%s->Address not implemented.", ref $Bus);
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
	my $Bus     = shift;
	my $address = shift;
	#
    # return $Bus->Decoder->Decode($Bus->Address, $address, sub {
    #   my $Signal = shift;
    #	$Signal->wire;
    #   
    #   # The return value will ready after it's decoded
    #   $Bus->Return($Bus->Ready, $Signal);
    # });
    #
    # See the APB Class below for a working example.
    #
	$Bus->error("%s->Decode not implemented.", ref $Bus);
}

#
# $Write = $Bus->Write;
#
# A virtual method that creates a Signal that asserts that the Bus is writing
# data.
#
sub Write {
	my $Bus = shift;
	#
    # return $Bus->Signal("bus_write", sub {
    #   my $Signal = shift;
    #	$Signal->input->wire;
    # });
    #
    # See the APB Class below for a working example.
    #
	$Bus->error("%s->Write not implemented.", ref $Bus);
}

#
# $Wdata = $Bus->Wdata;
#
# A virtual method that creates a Signal of size DATABITS that is the data
# written on a write.
#
sub Wdata {
	my $Bus = shift;
	#
    # return $Bus->Signal("bus_wdata", sub {
    #   my $Signal = shift;
    #	$Signal->size($Bus->{DATABITS})->input->wire;
    # });
    #
    # See the APB Class below for a working example.
    #
	$Bus->error("%s->Wdata not implemented.", ref $Bus);
}

#
# $Rdata = $Bus->Rdata;
#
# A virtual method that creates a Signal of size DATABITS that gets assigned
# the data read on a read.
#
sub Rdata {
	my $Bus = shift;
	#
    # return $Bus->Signal("bus_rdata", sub {
    #   my $Signal = shift;
    #	$Signal->size($Bus->{DATABITS})->output->reg($Bus->Clock, $Bus->Reset);
    # });
    #
    # See the APB Class below for a working example.
    #
	$Bus->error("%s->Wdata not implemented.", ref $Bus);
}

#
# $Ready = $Bus->Ready;
#
# A virtual method that creates a Signal that outputs when the Rdata is valid
# or undef if not supported.
#
sub Ready {
	my $Bus = shift;
	#
    # return $Bus->Signal("bus_ready", sub {
    #   my $Signal = shift;
    #	$Signal->output->reg($Bus->Clock, $Bus->Reset);
    # });
    #
    # See the APB Class below for a working example.
    #
	return undef;
}

#
# $Error = $Bus->Error;
#
# A virtual method that creates a Signal that outputs a bus error of undef
# if not supported.
#
sub Error {
	my $Bus = shift;
	#
    # return $Bus->Signal("bus_error", sub {
    #   my $Signal = shift;
    #	$Signal->output->reg($Bus->Clock, $Bus->Reset);
    # });
    #
    # See the APB Class below for a working example.
    #
	return undef;
}

#
# $Interrupt = $Bus->Interrupt;
#
# A virtual method that creates a Signal that outputs an Interrupt or undef 
# if not supported.
#
sub Interrupt {
	my $Bus = shift;
	#
    # return $Bus->Signal("bus_intr", sub {
    #   my $Signal = shift;
    #	$Signal->output->reg($Bus->Clock, $Bus->Reset);
    # });
    #
	return undef;
}

#------------------------
# Virtual Regions
#------------------------

#
# $Bus->Region($Node);
#
# A virtual method that implements bus sub-region fan-out and fan-in.
#
# The method should instantiate a Region($Bus, $Node) block and use 
# it to implemented the required functionality using the Virtual Bus
# signals.
#
sub Region {
	my $Bus    = shift;
	my $Node   = shift;
	#
	# my $Region = new Region($Bus, $Node);
	#
	# my $Address = $Region->Address()
	# my $Address = $Region->Decode()
	#
    # See the APB Class below for a working example.
    #
	$Bus->error("%s->Region not implemented.", ref $Bus);
}

#------------------------
# Bus Implementation API
#------------------------
#
# The following methods are the public interface for implementing the
# Virtual Signals.
#

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
	return shift->Module->Signal(@_);
}

#
# $Decoder = $Bus->Decoder;
#
# A public shortcut for dereferencing the Decoder Block.
#
# $Bus->Decoder($Module)
#
# A backstage method that adds the Decoder Block to the Module.
# This is called *before* any fields or regions are implemented because
# those depend on the Decoder Block for address decoding.
#
sub Decoder {
	my $Bus    = shift;
	my $Module = shift;
	if ($Module) {
		$Bus->{Module}  = $Module;
		$Bus->{Decoder} = new Decoder($Bus);
 	}
	return $Bus->{Decoder};
}

#
# $Bus->Return($Signal, $logic, ...);
#
# A public method that adds the $logic for the $Signal to the Return Block
# if the $Signal is defined.
#
# $Bus->Return;
#
# A backstage method for adding the Return Block to the Module.
# This is called *after* all fields or regions have been implemented 
# since the return logic must be collected before they they can be 
# assembled as Bus outputs.
#
sub Return {
	my $Bus    = shift;
	my $Signal = shift;
	my $logic  = shift;
	if (not defined $logic) {
		# Implement the return path
		$Return = $Bus->Module->Block("\n//\n// Return Path\n//\n");
		foreach $name (keys %{$Bus->{returns}}) {
			$Signal = $Bus->Signal($name);
			$logic  = join("\n| ", @{$Bus->{returns}->{$name}});
			if ($Bus->{REGISTERED}) {
				$Return->always($Signal, $logic);
			} else {
				$Return->assign($Signal, $logic);
			}
		}
		$Bus->{Return} = $Return;
	} elsif ($Signal) {
		# Collect the logic for the $Signal since we need fan-in multiple sources
		my $logic = sprintf($logic, @_);
		my $name  = $Signal->{name};
		$Bus->{returns}->{$name} = [] unless exists $Bus->{returns}->{$name};
		push @{$Bus->{returns}->{$name}}, $logic;
	}
}

#
# $Module = $Bus->Module;
#
# A public shortcut for accessing the Module that contains the Bus.
#
sub Module {
	return shift->{Module};
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
		$bit = $Bus->access($access,$address,$size,$lsb,$mask,$bit);
		$lsb = 0;
		$address++;
	}
	$Bus->access($access,$address,$size,$lsb,$last->{bit},$bit);

	$Field->{access} = $access;
}

#
# $Bus->access($access,$address,$size,$lsb,$msb,$index)
#
# A private method that "walks" through the field in DATABITS sized chunks
# recording the formating information for decode fanout, write data slicing 
# and read data packing.
#
sub access {
	my $Bus        = shift;
	my $access     = shift;
	my $address    = shift; # DATABITS per address
	my $size       = shift;
	my $wdata_lsb  = shift;
	my $wdata_msb  = shift;
	my $rvalue_lsb = shift;
	my $slice      = $wdata_msb-$wdata_lsb+1;
	my $rvalue_msb = $rvalue_lsb+$slice-1;
	my $Bus_msb    = $Bus->{DATABITS}-1;
	my $single     = ($slice == 1);

	#
	# The format for faning out the decode
    #
	my $decode = $single ? "%s" : sprintf("{%d{%%s}}",$slice);

	#
	# The format for slicing the write data
	#
    my $write = $single ? "%s[$wdata_lsb]" : "%s[$wdata_msb:$wdata_lsb]";
	
	#
	# The format for returning the read data
	#
	my @read = ();
	push @read, sprintf("%d'd0",$Bus_msb-$wdata_msb) if $wdata_msb != $Bus_msb;
	push @read, ($size == 1) ? "%s" : $single ? "%s[$rvalue_lsb]" : "%s[$rvalue_msb:$rvalue_lsb]";
	push @read, sprintf("%d'd0",$wdata_lsb         ) if $wdata_lsb != 0;
	my $read = u::concat(@read);

	push @{$access}, {
		address => $address<<$Bus->{DATAPOWER}, # UNITBITS per address
		decode  => $decode,
		write   => $write,
		read    => $read,
	};

	return $rvalue_lsb+$slice;
}

#------------------
# Engine Interface
#------------------

#
# $Bus = new Bus($Space, @options)
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
	my $invocant   = shift;
	my $class      = ref($invocant) || $invocant;
	my $Space      = shift;
	my $UNITPOWER  = 3;
	my $DATAPOWER  = 2;
	my $ADDRPOWER  = &u::clog2($Space->sc_get_size - 1);
	my $ADDRPORT;

	while (@_) {
		my $op = shift;
		if    ($op eq "--unitpower" ) { $UNITPOWER  = shift; }
		elsif ($op eq "--datapower" ) { $DATAPOWER  = shift; }
		elsif ($op eq "--addrpower" ) { $ADDRPORT   = shift; }
	}

	$ADDRPOWER -= $UNITPOWER;

	my $Bus = {
		# Bus Parameters
		UNITPOWER  => $UNITPOWER,
		DATAPOWER  => $DATAPOWER,
		DATABITS   => 1<<$DATAPOWER<<$UNITPOWER,
		ADDRPOWER  => $ADDRPOWER,
		ADDRPORT   => $ADDRPORT || $ADDRPOWER,
		# Storage
		Module     => undef, # Set in $Bus->Decoder()
		Decoder    => undef, # Set in $Bus->Decoder()
		Return     => undef, # Set in $Bus->Return()
		returns    => {}
	};

	return bless $Bus, $class;
}





#-------------------------------------------------------------------------------
package Decoder;
#-------------------------------------------------------------------------------
#
# A Decoder is a specialized Bus Block that has a single Decode method
# for returning Decode Signals with names that include the decoded address.
#
use base ('Block');

#------------------------
# Bus Implementation API
#------------------------

#
# $Decode = $Decoder->Decode($name, $address);
# $Decode = $Decoder->Decode($name, $address, $callback);
#
# A public method that returns an address qualified Decode Signal.
#
sub Decode {
	my $Decoder  = shift;
	my $name     = shift;
	my $address  = shift;
	my $callback = shift;
	my $APB      = $Decoder->{Bus};
	my $decode   = sprintf("%s_".&u::sized($APB->{ADDRPOWER})."h", $name, $address);
	return $APB->Module->Signal($decode, $callback);
}

#---------------
# Bus Interface
#---------------

#
# $Decoder = new Decoder($APB)
#
# A backstage method that returns a new Decoder Block.
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $APB      = shift;
	my $Decoder  = $APB->Module->Block("\n//\n// Address Decoding\n//\n");

	$Decoder->{Bus} = $APB;

	return bless $Decoder, $class;
}





#-------------------------------------------------------------------------------
package Node;
#-------------------------------------------------------------------------------
#
# A Node is a Block that wraps the spacecraft node to strip the verilog:
# prefix from properties.
#
use base ('Block');

sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $Module   = shift;
	my $node     = shift;
	my $Node     = new Block($Module);

	$Node->{Node} = $node;
	return bless $Node, $class;
}

#--------------
# Property API
#--------------

#
# $boolean = $Node->has_propery($key)
#
# A public method for determining if the Node has the property.
# Note that the $key specified does not include the verilog: prefix.
# Returns truthy if the Node has the property.
#
sub has_property {
	my $Node = shift;
	my $key  = shift;
	return $Node->{Node}->sc_has_property("verilog:$key");
}

#
# $value = $Node->get_propery($key)
#
# A public method for retrieving the given property from the Node.
# Note that the $key specified does not include the verilog: prefix.
# Returns the value of the property.
#
sub get_property {
	my $Node = shift; 
	my $key  = shift;
	return $Node->{Node}->sc_get_property("verilog:$key");
}





#-------------------------------------------------------------------------------
package Region;
#-------------------------------------------------------------------------------
use base ('Node');

#-------------------------------
# Bus Region Implementation API
#-------------------------------

#------------
# Signal API
#------------

sub Signal {
	my $Region = shift;
	my $name   = shift;
	my $signal = $Region->{glob}; $signal =~ s/[*]/$name/;
	return $Region->Module->Signal($signal, @_);
}

sub Module {
	return shift->{Module};
}

#--------------
# Logic API
#--------------

sub aligned {
	my $Region  = shift;
	my $address = $Region->{Node}->sc_get_address;
	my $size    = $Region->{Node}->sc_get_size;
	return 0 unless $size == 1<<$Region->{ADDRPOWER};
	return 0 if     $address & ($size-1);
	return 1;
}

sub address {
	my $Region  = shift;
	my $Address = shift;
	return $Address->{name};
}

sub decode {
	my $Region  = shift;
	my $Address = shift;
	return $Address->{name};
}

#---------------
# Bus Interface
#---------------

#
# $Region = new Region($Bus, $Node)
#
# A backstage method that returns a new Region Block for the Bus.
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $Bus      = shift;
	my $Node     = shift;
	my $Module   = $Bus->Module;
	my $Region   = new Node($Module, $Node);

	bless $Region, $class;

	# Add the Bus
	$Region->{Bus} = $Bus;

	# Import the Bus Parameters
	$Region->{ADDRPOWER} = u::clog2($Node->sc_get_size - 1);
	$Region->{ADDRPORT}  = ($Bus->{ADDRPORT} == $Bus->{ADDRPOWER}) ? $Bus->{ADDRPOWER} : $Region->{ADDRPOWER};
	$Region->{DATABITS}  = $Bus->{DATABITS};

	$Region->debug;

	# Determing port naming
	if ($Region->has_property("ports")) {
		$glob = $Node->get_property("ports")."_*";
	} else {
		$glob = lc $Node->sc_import($Node->sc_get_glob);
	}
	if (($glob eq "*") && $Node->sc_is_named) {
		$glob = lc $Node->sc_import($Node->sc_get_name."_*");
	}
	$Bus->error('The anonymous non-globbing region at line %d of %s requires a -verilog:ports option to name the ports.', 
		$Node->sc_get_lineno, $Node->sc_get_filename) if $glob eq "*";
	$Region->{glob} = $glob;

	$Region->{comment} = sprintf("\n//\n// %s%s region%s declared on line %s in %s\n//\n",
		$Node->sc_get_size('%U'),
		$Node->sc_is_typed ? " " .$Node->sc_get_type     : '',
		$Node->sc_is_named ? " '".$Node->sc_get_name."'" : '',
		$Node->sc_get_filename,
		$Node->sc_get_lineno);

	# Determine address/size alignment for decoding
	$size = $Node->sc_get_size;

	printf("%-10s %d\n", $glob, $Region->aligned);

	# Add the Region to the Module
	$Module->Block($Region);

	return $Region;
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
	my $APB      = new Bus(@_);

	while (@_) {
		my $op = shift;
		if ($op eq "--pslverr") { $APB->{pslverr} = 1; }
	}

	return bless $APB, $class;
}

#-----------------------------------
# ABP Virtual Signal Implementation
#-----------------------------------

sub Clock {
	return shift->Pclk;
}

sub Reset {
	return shift->Presetn;
}

sub Address {
	return shift->Paddr;
}

sub Decode {
	my $APB     = shift;
	my $address = shift;
	return $APB->Decoder->Decode($APB->Paddr_reg, $address, sub {
		# Decode from a locally registered paddr.
		# Note that paddr[DATAPOWER-1:0] is not compared.
		my $Decode = shift; $Decode->wire;
		$APB->Decoder->assign($Decode, "%s && (%s == %d'h%X)",
			$APB->Pactive_reg, $APB->Paddr_reg, $APB->{ADDRPORT}-$APB->{DATAPOWER}, $address>>$APB->{DATAPOWER});
		# Return the Decode as Pready
		$APB->Return($APB->Pready, $Decode);
	});
}

sub Write {
	my $APB = shift;
	return $APB->Signal("pwrite_reg", sub {
		# Write from a locally registered pwrite
		my $Pwrite_reg = shift; $Pwrite_reg->reg($APB->Pclk, $APB->Presetn);
		$APB->Decoder->always($Pwrite_reg," ".$APB->Pwrite);
	});
}

sub Wdata {
	my $APB = shift;
	return $APB->Signal("pwdata_reg", sub {
		# Write data from a locally registered pwdata
		my $Pwdata_reg = shift; $Pwdata_reg->size($APB->{DATABITS})->reg($APB->Pclk, $APB->Presetn);
		$APB->Decoder->always($Pwdata_reg," ".$APB->Pwdata);
	});
}

sub Rdata {
	return shift->Prdata;
}

sub Error {
	return shift->Pslverr;
}

#------------------------------------
# APB Virtual Region Implementation
#------------------------------------

sub Region {
	my $APB  = shift;
	my $Node = shift;

	my $Region = new Region($APB, $Node);

	# Define the region interface signals

	my $Paddr   = $Region->Signal("paddr")->size($Region->{ADDRPORT})->output->wire;
	my $Psel    = $Region->Signal("psel")->output->wire;
	my $Penable = $Region->Signal("penable")->output->wire;
	my $Pwrite  = $Region->Signal("pwrite")->output->wire;
	my $Pwdata  = $Region->Signal("pwdata")->size($Region->{DATABITS})->output->wire;
	my $Pready  = $Region->Signal("pready")->input->wire;
	my $Prdata  = $Region->Signal("prdata")->size($Region->{DATABITS})->input->wire;
	my $Pslverr = $Region->Signal("pslverr")->input->wire if $APB->Error;

	# Define internal logic signals

	my $Decode    = $Region->Signal("decode")->wire;
	my $Pready_q  = $Region->Signal("pready_q")->wire;
	my $Prdata_q  = $Region->Signal("prdata_q")->size($Region->{DATABITS})->wire;
	my $Pslverr_q = $Region->Signal("pslverr_q")->wire if $APB->Error;

	# Implement the fan-out

	$Region->assign($Decode , $Region->decode($APB->Paddr));
	$Region->assign($Paddr  , $Region->address($APB->Paddr));
	$Region->assign($Psel   , "%s & $Decode", $APB->Psel);
	$Region->assign($Penable, "%s & $Decode", $APB->Penable);
	$Region->assign($Pwrite , $APB->Pwrite);
	$Region->assign($Pwdata , $APB->Pwdata);

	# Implement the fan-in

	$Region->assign($Pready_q , "$Pready & $Decode");
	$Region->assign($Prdata_q , "$Prdata & {%d{$Decode}}", $Region->{DATABITS});
	$Region->assign($Pslverr_q, "$Pslverr & $Decode") if $APB->Error;
	
	$APB->Return($APB->Prdata , $Prdata_q);
	$APB->Return($APB->Pready , $Pready_q);
	$APB->Return($APB->Pslverr, $Pslverr_q);

}

#---------------
# APB Interface
#---------------

sub Pclk {
	my $APB = shift;
	return $APB->Signal("pclk", sub {
		my $Pclk = shift; $Pclk->clock;
	});
}

sub Presetn {
	my $APB = shift;
	return $APB->Signal("presetn", sub {
		my $Presetn = shift; $Presetn->reset;
	});
}

sub Paddr {
	my $APB = shift;
	return $APB->Signal("paddr", sub {
		my $Paddr = shift; $Paddr->size($APB->{ADDRPORT})->input->wire;
	});
}

sub Psel {
	my $APB = shift;
	return $APB->Signal("psel", sub {
		my $Psel = shift; $Psel->input->wire; 
	});
}

sub Penable {
	my $APB = shift;
	return $APB->Signal("penable", sub { 
		my $Penable = shift; $Penable->input->wire; 
	});
}

sub Pwrite {
	my $APB = shift;
	return $APB->Signal("pwrite", sub {
		my $Pwrite = shift; $Pwrite->input->wire;
	});
}

sub Pwdata {
	my $APB = shift;
	return $APB->Signal("pwdata", sub {
		my $Pwdata = shift; $Pwdata->size($APB->{DATABITS})->input->wire;
	});
}

sub Prdata {
	my $APB = shift;
	return $APB->Signal("prdata", sub {
		my $Prdata = shift; $APB->Output($Prdata->size($APB->{DATABITS}));
	});
}

sub Pready {
	my $APB = shift;
	return $APB->Signal("pready", sub {
		my $Pready = shift; $APB->Output($Pready);
	});
}

sub Pslverr {
	my $APB = shift;
	return undef unless $APB->{pslverr};
	return $APB->Signal("pslverr", sub {
		my $Pslverr = shift; $APB->Output($Pslverr);
	});
}

sub Output {
	my $APB    = shift;
	my $Signal = shift;
	$Signal->output->reg($APB->Pclk, $APB->Presetn);
}

#---------------------------------
# APB Specific Signals for Fields
#---------------------------------

sub Pactive_reg {
	my $APB = shift;
	return $APB->Signal("pactive_reg", sub {
		# Locally register the transaction start
		my $Pactive = shift; $Pactive->reg($APB->Clock,$APB->Reset);
		$APB->Decoder->always($Pactive," %s && !%s", $APB->Psel, $APB->Penable);
	});
}

sub Paddr_reg {
	my $APB = shift;
	return $APB->Signal("paddr_reg", sub {
		# Locally register and hold the address on the transaction start
		# Note that paddr[DATAPOWER-1:0] is not captured since it is unused
		# in the Decode.
		my $Paddr_reg = shift; 
		$Paddr_reg->size($APB->{ADDRPORT}-$APB->{DATAPOWER}, $APB->{DATAPOWER});
		$Paddr_reg->reg($APB->Clock,$APB->Reset);
		$APB->Decoder->always($Paddr_reg,"(%s && !%s) ? %s[%d:%d] : %s",
			$APB->Psel, $APB->Penable, $APB->Address, $APB->{ADDRPORT}-1, $APB->{DATAPOWER}, $Paddr_reg);
	});
}




1;