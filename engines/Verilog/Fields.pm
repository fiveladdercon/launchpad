#-------------------------------------------------------------------------------
package Field;
#-------------------------------------------------------------------------------
#
# A Field is a Block in a Slave Module that implements the function specified
# in the field type.  This is a base class from which all implemented types
# are derived.
#
use EngineAPI;
use base ('Block');

#
# $Field = new Field($Module,$field);
#
# A backstage method that returns a new instance of a Block.
#
sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;
	my $Module   = shift;
	my $Field    = shift;
	my $Bus      = $Module->{Bus};
	my $this     = Block::new($class,$Module);

	my $address  = $Field->sc_get_address;
	my $name     = $Field->sc_get_identifier;
	my $type     = $Field->sc_get_type;
	my $size     = $Field->sc_get_size;
	my $filename = $Field->sc_get_filename;  $filename =~ s/.*\///;
	my $lineno   = $Field->sc_get_lineno;

	$this->{port}   = "f_".lc $name;
	$this->{value}  = $this->{port}."_value";
	$this->{size}   = $size;
	$this->{lsbit}  = $address;
	$this->{lsfra}  = $this->{lsbit} % $Bus->{datasize};
	$this->{lsint}  = ($this->{lsbit} - $this->{lsfra}) / $Bus->{datasize};
	$this->{msbit}  = $this->{lsbit}+$this->{size}-1;
	$this->{msfra}  = $this->{msbit} % $Bus->{datasize};
	$this->{msint}  = ($this->{msbit} - $this->{msfra}) / $Bus->{datasize};

	$this->{Bus}    = $Bus;
	$this->{Field}  = $Field;

	$this->{comment} = "\n//\n// ${size}-bit ${type} field '$name' declared on line ${lineno} in ${filename}\n//\n";

	$Module->add_block($this);

	return $this;
}

#
#  $Field->implementation;
#
#  A virtual method the uses the Bus, Field, Property & Logic APIs below to 
#  implement the functionality needed by the field type.  All derivative Field 
#  Types must override this method with thier own functionality.
#
sub implementation {
	my $this = shift;
	&sc_error("Type %s has no implementation",$this->{Field}->sc_get_type);
}

#--------------
# Property API
#--------------

sub has_property {
	my $this = shift;
	my $key  = shift;
	return $this->{Field}->sc_has_property("verilog:$key");
}

sub get_property {
	my $this = shift; 
	my $key  = shift;
	return $this->{Field}->sc_get_property("verilog:$key");
}

#---------
# Bus API
#---------

sub get_bus_clock {
	my $this = shift;
	return $this->{Bus}->{Clock};
}

sub get_bus_reset {
	my $this = shift;
	return $this->{Bus}->{Reset};
}

sub get_bus_write_enable {
	my $this = shift;
	return $this->{Bus}->get_write_enable($this);
}

sub get_bus_write_data {
	my $this = shift;
	return $this->{Bus}->get_write_data($this);
}

sub set_bus_read_data {
	my $this  = shift;
	my $Rdata = shift;
	$this->{Bus}->add_read_data($Rdata,$this);
}

sub set_bus_error {
	my $this  = shift;
	my $Error = shift;
	$this->{Bus}->add_error($Error,$this);
}

#-----------
# Field API
#-----------

sub get_field_clock {
	my $this = shift;
	my $name = $this->get_property("clock") || $this->{port}."_clk";
	return $this->get_signal($name) || $this->add_signal($name)->clock;
}

sub get_field_reset {
	my $this = shift;
	my $name = $this->get_property("reset") || $this->{port}."_rst_n";
	return $this->get_signal($name) || $this->add_signal($name)->reset;
}

sub get_field_port {
	my $this = shift;
	return $this->get_signal($this->{port}) || $this->add_signal($this->{port},$this->{size});
}

sub get_field_value {
	my $this = shift;
	return $this->get_signal($this->{value}) || $this->add_signal($this->{value},$this->{size});
}

sub get_field_default {
	my $this = shift;
	&sc_warn("get_default does not return valid verilog.");
	return $this->{Field}->sc_get_value;
}

sub get_field_size {
	my $this = shift;
	return $this->{size};
}

#-----------
# Logic API
#-----------

#
# $Signal = $Field->reg($name,$Clock);
# $Signal = $Field->reg($name,$Clock,$Reset);
# $Signal = $Field->reg($name,$Clock,$Reset,$default);
#
# A public method that returns a reg Signal of the given $name, adding it
# first if it doesn't already exist.
#
sub reg {
	my $this    = shift;
	my $name    = shift;
	my $Clock   = shift;
	my $Reset   = shift;
	my $default = shift; $default = $this->get_field_default unless $default;
	return $this->get_signal($name) || $this->add_signal($name,$this->{size})->reg($Clock,$Reset,$default);
}

#
# $Signal = $Field->retime($Signal,$Clock);
# $Signal = $Field->retime($Signal,$Clock,$Reset);
# $Signal = $Field->retime($Signal,$Clock,$Reset,$default);
#
# A public method returns a double-synchronized $Signal.
#
sub retime {
	my $this    = shift;
	my $Source  = shift;
	my $Meta    = $this->reg($Source."_meta",@_);
	my $Sync    = $this->reg($Source."_sync",@_);
	$this->always($Meta,$Source);
	$this->always($Sync,$Meta);
	return $Sync;
}

#
# $Signal = $Field->delay($Signal,$Clock);
# $Signal = $Field->delay($Signal,$Clock,$Reset);
# $Signal = $Field->delay($Signal,$Clock,$Reset,$default);
#
# A public method returns a delayed $Signal.
#
sub delay {
	my $this   = shift;
	my $Source = shift;
	my $Delay  = $this->reg($Source."_delay",@_);
	$this->always($Delay,$Source);
	return $Delay;
}

#
# $logic = $Signal->edge_detect($Signal,$Clock)
# $logic = $Signal->edge_detect($Signal,$Clock,$Reset)
# $logic = $Signal->edge_detect($Signal,$Clock,$Reset,$default)
#
# A public method that returns the logic to edge detect a $Signal.
#
sub edge_detect {
	my $this   = shift;
	my $Signal = shift;
	my $Delay  = $this->delay($Signal,@_);
	return "$Delay ^ $Signal";
}

#
# $logic = $Signal->posedge_detect($Signal,$Clock)
# $logic = $Signal->posedge_detect($Signal,$Clock,$Reset)
# $logic = $Signal->posedge_detect($Signal,$Clock,$Reset,$default)
#
# A public method that returns the logic to posedge detect a $Signal.
#
sub posedge_detect {
	my $this   = shift;
	my $Signal = shift;
	my $Delay  = $this->delay($Signal,@_);
	return "~$Delay & $Signal";
}

#
# $logic = $Signal->negedge_detect($Signal,$Clock)
# $logic = $Signal->negedge_detect($Signal,$Clock,$Reset)
# $logic = $Signal->negedge_detect($Signal,$Clock,$Reset,$default)
#
# A public method that returns the logic to negedge detect a $Signal.
#
sub negedge_detect {
	my $this   = shift;
	my $Signal = shift;
	my $Delay  = $this->delay($Signal,@_);
	return "$Delay & ~$Signal";
}


#-------------------------------------------------------------------------------
package RW;
#-------------------------------------------------------------------------------
use base ('Field');

sub implementation {
	my $this    = shift;
	my $Clock   = $this->get_bus_clock;
	my $Reset   = $this->get_bus_reset;
	my $Write   = $this->get_bus_write_enable;
	my $Wdata   = $this->get_bus_write_data;
	my $Port    = $this->get_field_port;
	my $Value   = $this->get_field_value;
	my $default = $this->get_field_default;

	# Configure the Port to be and output wire.
	$Port->output->wire;

	# Configure the Value to be a bus clocked register.
	$Value->reg($Clock,$Reset,$default);

	# Add the field Value to the Return path so it can be read.
	$this->set_bus_read_data($Value);

	# Define how the field Value is updates on Bus writes.
	$this->always($Value,"($Write & $Wdata) | (~$Write & $Value)");

	# Optionally retime the field Value on the with the field clock.
	if ($this->has_property("retime")) {
		$Value = $this->retime($Value,$this->get_field_clock);
	}

	# Drive the Port with the (optionally retimed) Value.
	$this->assign($Port,$Value);
}

#-------------------------------------------------------------------------------
package RO;
#-------------------------------------------------------------------------------
use base ('Field');

sub implementation {
	my $this    = shift;
	my $Clock   = $this->get_bus_clock;
	my $Reset   = $this->get_bus_reset;
	my $Port    = $this->get_field_port;
	my $Value   = $this->get_field_value;
	my $default = $this->get_field_default;

	if ($this->has_property("constant")) {

		# Configure the Port to be an (internal) wire
		$Port->wire;

		# Assign the Port the constant value
		$this->assign($Port, $default);

		# Configure the Value to be a wire
		$Value->wire;

		# Assign the Value from the Port
		$this->assign($Value, $Port);

		# Add the Value to the Return path for reading
		$this->set_bus_read_data($Value);

	} else {

		# Configure the Port to be an input wire.
		$Port->input->wire;

		# Optionally retime the Port with the bus clock
		if ($this->has_property("retime")) {
			$Port = $this->retime($Port,$this->get_bus_clock,$this->get_bus_reset,$default);
		}

		# Configure the Value to be a wire
		$Value->wire;

		# Assign the Value from the Port
		$this->assign($Value, $Port);

		# Add the Value to the Return path for reading
		$this->set_bus_read_data($Value);

	}
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