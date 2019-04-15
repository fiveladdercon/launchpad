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
package Field;
#-------------------------------------------------------------------------------
#
# A Field is a Node Block in a Slave Module that implements the function of the 
# field type.
#
use base ('Node');

#------------------------------
# Virtual Field Implementation
#------------------------------
#
#  $Field->implementation;
#
#  A virtual method the uses the Field Implementation APIs below to implement 
#  the functionality needed by the field type.  All derivative Field Types must 
#  override this method with thier own functionality.
#
sub implementation {
	my $Field = shift;
	&sc_error("%s->implementation not implemented",uc $Field->{type});
}

#--------------------------
# Field Implementation API
#--------------------------
#
# The following methods are the public interface for implementing the
# virtual implementation method in derived classes.
#
# In addition to te following APIs, Fields inherit the following 
# Property API from the Node Class
#

#--------------
# Property API
#--------------

#
# $boolean = $Field->has_propery($key)
#
# A public method for determining if the Field Node has the property.
# Note that the $key specified does not include the verilog: prefix.
# Returns truthy if the Field Node has the property.
#

#
# $value = $Field->get_propery($key)
#
# A public method for retrieving the given property from the Field Node.
# Note that the $key specified does not include the verilog: prefix.
# Returns the value of the property.
#

#------------
# Signal API
#------------

#
# $Signal = $Field->Signal($suffix);
# $Signal = $Field->Signal($suffix,$callback);
#
# A public method that returns a Signal based on a $suffixed Field name.
# If the $Signal does not exist, then it is created with the Field size and 
# passed to the $callback so that it can be configured when added.
#
sub Signal {
	my $Field    = shift;
	my $name     = join("_",$Field->name,shift);
	my $callback = shift;
	return $Field->Module->Signal($name, sub {
		$Signal = shift->size($Field->size);
		&$callback($Signal) if $callback;
	});
}

#---------
# Bus API
#---------

#
# $Bus = $Field->Bus;
#
# A public method that is just a shortcut to retrieving a handle to the Bus.
#
sub Bus {
	return shift->{Bus};
}

#
# $Select = $Field->Select;
#
# A public method that returns the $Select Signal.
#  
# The $Select Signal is a concatination of address decodes used to access the
# Field and may be more than one bit if the Field spans multiple Bus addresses.
#
sub Select {
	my $Field = shift;
	my $Bus   = $Field->Bus;
	return $Field->Signal("select",sub {
		my $Select  = shift;
		my @access  = $Field->access;
		my @decodes = ();
		$Select->size(scalar @access)->wire;
		foreach my $access (@access) {
			unshift @decodes, $Bus->Decode($access->{address});
		}
		$Field->assign($Select,u::concat(@decodes));
	});
}

#
# $WSelect = $Field->WSelect;
#
# A public method that returns the $WSelect Signal. 
#  
# The $WSelect is the $Select Signal qualified by the Bus Write Signal.
#
sub Wselect {
	my $Field = shift;
	my $Bus   = $Field->Bus;
	return $Field->Signal("wselect", sub {
		my $WSelect = shift;
		my $Select  = $Field->Select;
		$WSelect->size($Select->size)->wire;
		$Field->assign($WSelect,"%s & %s",u::fanout($Bus->Write,$Select->size),$Select);
	});
}

#
# $RSelect = $Field->RSelect;
#
# A public method that returns the $RSelect Signal.
#  
# The $RSelect is the $Select Signal qualified by the Bus Read Signal.
#
sub Rselect {
	my $Field = shift;
	my $Bus   = $Field->Bus;
	return $Field->Signal("rselect", sub {
		my $RSelect = shift;
		my $Select  = $Field->Select;
		$RSelect->size($Select->size)->wire;
		$Field->assign($RSelect,"%s & %s",u::fanout("~".$Bus->Write,$Select->size),$Select);
	});
}

#
# $Write = $Field->Write;
#
# A public method that returns the $Write Signal.
#  
# The $Write is a Field sized Signal that is a fanout of the the Bus Write 
# qualified by fanout(s) of the Bus Decode Signal(s).  The intent is to use the
# $Write for bitwise muxing ofthe Write Data with the Field Value:
#  
#    (Write & Wdata) | (~Write & Value)
#
sub Write {
	my $Field = shift;
	my $Bus   = $Field->Bus;
	return $Field->Signal("write", sub {
		my $Write = shift; $Write->wire;
		my @decodes = ();
		foreach my $access ($Field->access) {
			unshift @decodes, sprintf($access->{decode},$Bus->Decode($access->{address}));
		}
		$Field->assign($Write,"%s & %s",u::fanout($Bus->Write,$Field->size),u::concat(@decodes));
	});
}

#
# $Wdata = $Field->Wdata;
#
# A public method that returns the $Wdata Signal.
#  
# The $Wdata is a Field sized Signal that is a fanout of the Bus Wdata, sliced
# and/or concatinated to line up with the Field Value.
#
sub Wdata {
	my $Field = shift;
	my $Bus   = $Field->Bus;
	return $Field->Signal("wdata",sub {
		my $Wdata  = shift; $Wdata->wire;
		my @slices = ();
		foreach my $access ($Field->access) {
			unshift @slices, sprintf($access->{write},$Bus->Wdata);
		}
		$Field->assign($Wdata,u::concat(@slices));
	});
}

#
# $Read = $Field->Read;
#
# A public method that returns the $Read Signal.
#  
# The $Read Signal is an inverted $Write Signal.  It is intended for qualifying
# the Field Value before packing into the return path.
#
sub Read {
	my $Field = shift;
	my $Bus   = $Field->Bus;
	return $Field->Signal("read", sub {
		my $Read    = shift; $Read->wire;
		my @decodes = ();
		foreach my $access ($Field->access) {
			unshift @decodes, sprintf($access->{decode},$Bus->Decode($access->{address}));
		}
		$Field->assign($Read,"%s & %s",u::fanout("~".$Bus->Write,$Field->size),u::concat(@decodes));
	});
}

#
# $Field->rdata($Value);
# 
# A public method to add the $Value to the return path.
#  
# The $Value is qualified and shifted to align with the Bus address(es) then
# passed to the Bus.
#
sub rdata {
	my $Field = shift;
	my $Value = shift;
	my $Bus   = $Field->Bus;
	$Field->Signal("rvalue", sub {
		# Qualify the Value with the Read Enable
		my $Rvalue = shift; $Rvalue->wire;
		my $Read   = $Field->Read;
		$Field->assign($Rvalue,"$Read & $Value");
		# Organize the Qualified Value into data chunks
		my $Rdata  = $Field->Signal("rdata")->size($Bus->{DATABITS})->wire;
		my @shifts = ();
		foreach my $access ($Field->access) {
			unshift @shifts, sprintf($access->{read},$Rvalue);
		}
		$Field->assign($Rdata, join("\n| ", @shifts));
		$Bus->Return($Bus->Rdata, $Rdata);
	});
}

#
# $Field->ready($Ready);
#
# A public method to add the $Ready to the return path.
# The $Ready is reduce ORed if it is more than one bit.
#
sub ready {
	my $Field = shift;
	my $Ready = shift;
	my $Bus   = $Field->Bus;
	$Bus->Return($Bus->Ready, u::reduce("|",$Ready,$Ready->size));
}

#
# $Field->error($Error);
#
# A public method to add the $Error to the return path.
# The $Error is reduce ORed if it is more than one bit.
#
sub error {
	my $Field = shift;
	my $Error = shift;
	my $Bus   = $Field->Bus;
	$Bus->Return($Bus->Error, u::reduce("|",$Error,$Error->size));
}

#
# $Field->interrupt($Interrupt);
#
# A public method to add the $Interrupt to the return path.
# The $Interrupt is reduce ORed if it is more than one bit.
#
sub ready {
	my $Field     = shift;
	my $Interrupt = shift;
	my $Bus       = $Field->Bus;
	$Bus->Return($Bus->Interrupt, u::reduce("|",$Interrupt,$Interrupt->size));
}


#-----------
# Field API
#-----------

#
# $name = $Field->name;
#
# A public method to get the Field name.
#
sub name {
	return shift->{name};
}

#
# $size = $Field->size;
#
# A public method to get the Field size.
#
sub size {
	return shift->{size};
}

#
# $default = $Field->default;
#
# A public method to get the Field default value.
#
sub default {
	my $Field = shift;
	if (not defined $Field->{value}) {
		my $value = $Field->{Node}->sc_get_value;
		my $fpart = 0;
		my $shift = 0;
		my $hex   = 0;
		my $ipart = 0;

		$fpart = $1 if $value =~ s/[.](\d+)$//;
		$shift = 0  if $value =~ s/b$//;
		$shift = 3  if $value =~ s/B$//;
		$shift = 4  if $value =~ s/H$//;
		$shift = 5  if $value =~ s/W$//;
		$shift = 6  if $value =~ s/D$//;
		$shift = 13 if $value =~ s/K$//;
		$shift = 23 if $value =~ s/M$//;
		$shift = 33 if $value =~ s/G$//;
		$shift = 43 if $value =~ s/T$//;
		$hex   = 1  if $value =~ s/h$//;
		$ipart = $hex ? hex($value) : $value;
		$Field->{value} = sprintf("%d'h%x",$Field->{size},($ipart<<$shift)+$fpart);
	}
	return $Field->{value};
}

#
# $Clock = $Field->Clock;
#
# A public method to get a Clock for the Field domain.
# The clock property of the Field Node sets the name of the Clock, if present.
# This allows sharing a clock between Fields.  If the clock property is not
# present, the Clock is the Field name suffixed with 'clk'.
#
# The returned Clock is preconfigured to be a posedge triggered clock Signal.
# 
sub Clock {
	my $Field = shift;
	my $name  = $Field->get_property("clock") || $Field->name."_clk";
	return $Field->Module->Signal($name, sub { 
		shift->clock; 
	});
}

#
# $Reset = $Field->Reset;
#
# A public method to get a Reset for the Field domain.
# The reset property of the Field Node sets the name of the Reset, if present.
# This allows sharing a reset between Fields.  If the reset property is not
# present, the Reset is the Field name suffixed with 'rstn'.
#
# The returned Reset is preconfigured to be a negedge triggered reset Signal.
# 
sub Reset {
	my $Field = shift;
	my $name = $Field->get_property("reset") || $Field->name."_rstn";
	return $Field->Module->Signal($name, sub { 
		shift->reset; 
	});
}

#
# $Port = $Field->Port;
#
# A public method to get the Field Port Signal.
# The Port is the actual port on the verilog Module and thus is the Signal
# that has the Node identifier as it's name.  It is the final interface to
# the hardware.
#
# The returned Port is sized but NOT configured as an input or output, reg or wire.
#
sub Port {
	my $Field = shift;
	return $Field->Module->Signal($Field->name, sub { 
		shift->size($Field->size); 
	});
}

#
# $Value = $Field->Value;
#
# A public method to get the Field Value Signal.
# The Value is the actual value read by the Bus, which in many cases different
# than the actual value on the module port.  (i.e. different clock domains, etc.) 
# It is the Field name suffixed by 'value'
#
# The returned Value is sized but NOT configured as an input or output, reg or wire.
#
sub Value {
	my $Field = shift;
	return $Field->Signal("value");
}

#-----------
# Logic API
#-----------

#
# $Signal = $Field->Reg($name,$Clock);
# $Signal = $Field->Reg($name,$Clock,$Reset);
# $Signal = $Field->Reg($name,$Clock,$Reset,$default);
#
# A public method that returns a reg Signal of the given $name, adding it
# first if it doesn't already exist.
#
sub Reg {
	my $Field   = shift;
	my $name    = shift;
	my $Clock   = shift;
	my $Reset   = shift;
	my $default = shift; $default = $Field->default unless $default;
	return $Field->Module->Signal($name, sub {
		shift->reg($Clock, $Reset, $default);
	});
	#return $Field->get_signal($name) || $Field->add_signal($name,$Field->size)->reg($Clock,$Reset,$default);
}

#
# $Signal = $Field->Retime($Signal,$Clock);
# $Signal = $Field->Retime($Signal,$Clock,$Reset);
# $Signal = $Field->Retime($Signal,$Clock,$Reset,$default);
#
# A public method returns a double-synchronized $Signal.
#
sub Retime {
	my $Field   = shift;
	my $Source  = shift;
	my $Meta    = $Field->Reg($Source."_meta",@_);
	my $Sync    = $Field->Reg($Source."_sync",@_);
	$Field->always($Meta,$Source);
	$Field->always($Sync,$Meta);
	return $Sync;
}

#
# $Signal = $Field->Delay($Signal,$Clock);
# $Signal = $Field->Delay($Signal,$Clock,$Reset);
# $Signal = $Field->Delay($Signal,$Clock,$Reset,$default);
#
# A public method returns a delayed $Signal.
#
sub Delay {
	my $Field  = shift;
	my $Source = shift;
	my $Delay  = $Field->Reg($Source."_delay",@_);
	$Field->always($Delay,$Source);
	return $Delay;
}

#
# $logic = $Field->edge_detect($Signal,$Clock)
# $logic = $Field->edge_detect($Signal,$Clock,$Reset)
# $logic = $Field->edge_detect($Signal,$Clock,$Reset,$default)
#
# A public method that returns the logic to edge detect a $Signal.
#
sub edge_detect {
	my $Field  = shift;
	my $Signal = shift;
	my $Delay  = $Field->Delay($Signal,@_);
	return "$Delay ^ $Signal";
}

#
# $logic = $Field->posedge_detect($Signal,$Clock)
# $logic = $Field->posedge_detect($Signal,$Clock,$Reset)
# $logic = $Field->posedge_detect($Signal,$Clock,$Reset,$default)
#
# A public method that returns the logic to posedge detect a $Signal.
#
sub posedge_detect {
	my $Field  = shift;
	my $Signal = shift;
	my $Delay  = $Field->Delay($Signal,@_);
	return "~$Delay & $Signal";
}

#
# $logic = $Field->negedge_detect($Signal,$Clock)
# $logic = $Field->negedge_detect($Signal,$Clock,$Reset)
# $logic = $Field->negedge_detect($Signal,$Clock,$Reset,$default)
#
# A public method that returns the logic to negedge detect a $Signal.
#
sub negedge_detect {
	my $Field  = shift;
	my $Signal = shift;
	my $Delay  = $Field->Delay($Signal,@_);
	return "$Delay & ~$Signal";
}

#------------------
# Module Interface
#------------------

#
# $Field = new Field($Module,$Node);
#
# A backstage method that returns a new instance of a Field.
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $Module   = shift;
	my $Node     = shift;
	my $Bus      = $Module->{Bus};
	my $Field    = new Node($Module, $Node);

	my $name     = $Node->sc_get_identifier;
	my $address  = $Node->sc_get_address;
	my $size     = $Node->sc_get_size;
	my $type     = $Node->sc_get_type;
	my $filename = $Node->sc_get_filename;  $filename =~ s/.*\///;
	my $lineno   = $Node->sc_get_lineno;

	$Field->{comment} = "\n//\n// ${size}-bit ${type} field '${name}' declared on line ${lineno} in ${filename}\n//\n";
	$Field->{name}    = lc $name;
	$Field->{address} = $address;
	$Field->{size}    = $size;
	$Field->{type}    = $type;

	$Field->{Bus}     = $Bus;

	$Module->Block($Field);
	$Bus->map($Field);

	return bless $Field, $class;
}

#-----------------
# Private methods
#-----------------

#
# @access = $Field->access
#
# Returns the access vectors produced by splitting the Field into one or more
# Bus accesses.
#
sub access {
	return @{shift->{access}};
}





################################################################################
#
#
# THE FOLLOWING ARE IMPLEMENTATIONS OF THE FIELD ABSTRACTION
#
#
################################################################################
#-------------------------------------------------------------------------------
package RW;
#-------------------------------------------------------------------------------
use base ('Field');

#
# RW
# RW -verilog:retime
# RW -verilog:clock
# RW -verilog:clock CLOCK
# RW -verilog:clock       -verilog:reset
# RW -verilog:clock CLOCK -verilog:reset
# RW -verilog:clock CLOCK -verilog:reset RESET
#

sub implementation {
	my $Field   = shift;
	my $Bus     = $Field->Bus;
	my $Write   = $Field->Write;
	my $Wdata   = $Field->Wdata;
	my $Port    = $Field->Port;
	my $Value   = $Field->Value;
	my $default = $Field->default;
	my $Reset;

	# Configure the Port to be and output wire.
	$Port->output->wire;

	# Configure the Value to be a bus clocked register.
	$Value->reg($Bus->Clock,$Bus->Reset,$default);

	# Add the field Value to the Return path so it can be read.
	$Field->rdata($Value);

	# Define how the field Value is updates on Bus writes.
	$Field->always($Value,u::mux($Write,$Wdata,$Value));

	# Optionally retime the field Value on the with the field clock.
	if ($Field->has_property("retime") || $Field->has_property("clock")) {
		$Reset = $Field->Reset if $Field->has_property("reset");
		$Value = $Field->Retime($Value,$Field->Clock,$Reset,$default);
	}

	# Drive the Port with the (optionally retimed) Value.
	$Field->assign($Port,$Value);
}





#-------------------------------------------------------------------------------
package RO;
#-------------------------------------------------------------------------------
use base ('Field');

#
# RO
# RO -verilog:constant
# RO -verilog:retime
# RO -verilog:clock
# RO -verilog:clock CLOCK
# RO -verilog:clock       -verilog:reset
# RO -verilog:clock CLOCK -verilog:reset
# RO -verilog:clock CLOCK -verilog:reset RESET
#

sub implementation {
	my $Field   = shift;
	my $Bus     = $Field->Bus;
	my $Clock   = $Bus->Clock;
	my $Port    = $Field->Port;
	my $Value   = $Field->Value;
	my $default = $Field->default;
	my $Reset;

	if ($Field->has_property("constant")) {

		# Configure the Port to be an (internal) wire
		$Port->wire;

		# Assign the Port the constant value
		$Field->assign($Port, $default);

		# Configure the Value to be a wire
		$Value->wire;

		# Assign the Value from the Port
		$Field->assign($Value, $Port);

		# Add the Value to the Return path for reading
		$Field->rdata($Value);

	} else {

		# Configure the Port to be an input wire.
		$Port->input->wire;

		# Optionally retime the Port with the Bus Clock
		if ($Field->has_property("retime")) {
			$Reset = $Bus->Reset if $Field->has_property("reset");
			$Port  = $Field->Retime($Port,$Bus->Clock,$Reset,$default);
		}

		# Configure the Value to be a wire
		$Value->wire;

		# Assign the Value from the Port
		$Field->assign($Value, $Port);

		# Add the Value to the Return path for reading
		$Field->rdata($Value);

	}

	# Set an Error on a write, if supported by the Bus
	$Field->error($Field->Wselect) if $Bus->Error;
}





#-------------------------------------------------------------------------------
package RWSC;
#-------------------------------------------------------------------------------
use base ('Field');





#-------------------------------------------------------------------------------
package RW1C;
#-------------------------------------------------------------------------------
use base ('Field');





1;