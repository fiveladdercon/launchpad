#-------------------------------------------------------------------------------
# Packages
#-------------------------------------------------------------------------------

use EngineAPI;
use EngineHelp;
use strict;

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

sub calculate {
	my $stack = shift;
	my $exp   = shift;

	while ($exp) {
		if ($exp =~ s/^(([0-9]+|[0-9a-fA-F]+h)(b|[BHWD](\.[0-9]+)?|KB|MB|GB|TB)?)// )  { 
			unshift @{$stack}, &sc_bits("%d",$1);
		} elsif ($exp =~ s/^\+//) {
			my $a = shift (@{$stack}) || 0;
			my $b = shift (@{$stack}) || 0;
			unshift @{$stack}, $b+$a;
		} elsif ($exp =~ s/^-//) {
			my $a = shift (@{$stack}) || 0;
			my $b = shift (@{$stack}) || 0;
			unshift @{$stack}, $b-$a;
		} elsif ($exp =~ s/^\*//) {
			my $a = shift (@{$stack}) || 0;
			my $b = shift (@{$stack}) || 0;
			unshift @{$stack}, $b*$a;
		} elsif ($exp =~ s/^\///) {
			my $a = shift (@{$stack}) || 0;
			my $b = shift (@{$stack}) || 0;
			unshift @{$stack}, sprintf("%d",$b/$a);
		} else {
			$exp =~ s/^[\s\n]+//;
		}
	}
 	printf &sc_bits("\t%b\t%hb\n\t%B\t%hB\n\t%H\t%hH\n\t%W\t%hW\n\t%U\t%hU\n","$stack->[0]") if @{$stack};
}

#-------------------------------------------------------------------------------
# Command Line
#-------------------------------------------------------------------------------

my $STACK      = [];
my $EXPRESSION = "";

while (@ARGV) {
	my $op = shift;
	if    ($op eq "--help") { &help;              }
	elsif ($op eq "-h"    ) { &help;              }
	else                    { $EXPRESSION .= $op; }
}

if ($EXPRESSION) {
	&calculate($STACK,$EXPRESSION);
} else {
	print (">>");
	while ($EXPRESSION = <STDIN>) { 
		&calculate($STACK,$EXPRESSION);
		print (">>");
	}
	print "\n";
}
