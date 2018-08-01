sub usage { print <<'_';

Usage: calc.pl [EXPRESSION]

  calc.pl performs rudamentary calculations with spacecraft bits.

  If an EXPRESSION is given, it is parsed and the result is displayed,
  otherwise an EXPRESSION will be collected from STDIN.

  EXPRESSIONS are to be in reverse polish notation (RPN), as this
  eliminates the need for brackets.

  To add     : >> X Y -
  To subtract: >> X Y +
  To multiply: >> X Y *
  To divide  : >> X Y /

  where X & Y are a spacecraft bits.

  e.g. Calculate the offset of a ROM in the last 2KB of a 4GB space:

  spacecraft -u -Q calc.pl 4GB 2KB -
	34359721984b    7FFFFC000hb
	4294965248B     FFFFF800hB
	2147482624H     7FFFFC00hH
	1073741312W     3FFFFE00hW
	4194302KB       3FFFFEhKB

_
	&sc_error(@_) if @_; exit;
}

#-------------------------------------------------------------------------------
# Packages
#-------------------------------------------------------------------------------

use EngineAPI;
use strict;

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

sub calculate {
	my $exp   = shift;
	my @stack = ();

	my $count = 10;
	while ($exp && $count--) {
		if ($exp =~ s/^(([0-9]+|[0-9a-fA-F]+h)(b|[BHWD](\.[0-9]+)?|KB|MB|GB|TB)?)// )  { 
			push @stack, &sc_bits("%d",$1);
		} elsif ($exp =~ s/^\+//) {
			my $a = pop (@stack) || 0;
			my $b = pop (@stack) || 0;
			push @stack, $b+$a;
		} elsif ($exp =~ s/^-//) {
			my $a = pop (@stack) || 0;
			my $b = pop (@stack) || 0;
			push @stack, $b-$a;
		} elsif ($exp =~ s/^\*//) {
			my $a = pop (@stack) || 0;
			my $b = pop (@stack) || 0;
			push @stack, $b*$a;
		} elsif ($exp =~ s/^\///) {
			my $a = pop (@stack) || 0;
			my $b = pop (@stack) || 0;
			push @stack, sprintf("%d",$b/$a);
		} else {
			$exp =~ s/^[\s\n]+//;
		}
	}
	my $result = pop @stack;
 	printf &sc_bits("\t%b\t%hb\n\t%B\t%hB\n\t%H\t%hH\n\t%W\t%hW\n\t%U\t%hU\n","$result") if $result;
}

#-------------------------------------------------------------------------------
# Command Line
#-------------------------------------------------------------------------------

my $EXPRESSION = "";

while (@ARGV) {
	my $op = shift;
	if    ($op eq "--help") { &usage;             }
	elsif ($op eq "-h"    ) { &usage;             }
	else                    { $EXPRESSION .= $op; }
}

if ($EXPRESSION) {
	&calculate($EXPRESSION);
} else {
	print (">>");
	while ($EXPRESSION = <STDIN>) { 
		&calculate($EXPRESSION);
		print (">>");
	}
	print "\n";
}
