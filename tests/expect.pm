package Expect;
use EngineAPI;
use base qw(Exporter);

@EXPORT = qw(pass fail expect);

sub pass {
	my $format = shift;
	&sc_note(0,"\e[32m$format\e[0m",@_);
}

sub fail {
	&sc_error(@_);
}

sub expect {
	my $act = shift;
	my $exp = shift;
	&fail("Expected %s, got %s.",$exp,$act) if ("$act" ne "$exp");
}

1;