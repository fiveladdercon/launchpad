package EngineUtils;
use EngineAPI;
use base qw(Exporter);

#
# All exported symbols start with 'u' to identify them as a utility.
#
@EXPORT = qw(uhelp uopen uclose);

#
#  &uhelp()                    : print <engine>.md & exit
#  &uhelp(error)               : print <engine>.md, print error & exit
#  &uhelp(format,args)         : print <engine>.md, printf format, args & exit
#  &uhelp(message)             : print message & exit
#  &uhelp(message,error)       : print message, print error & exit
#  &uhelp(message,format,args) : print message, printf format, args & exit
#
#  Prints a help message and an optional error message, then exits.
#
#  A message is required when the <engine>.md file does not exist.
#  This calling style is intended for private engines, since the usage
#  does not need to be released in .md format.
#
sub uhelp {
	my $markdown = $0; $markdown =~ s!engines!docs/_engines!; $markdown .= ".md";

	if (-e $markdown) {
		my $engine = $0; $engine =~ s/.*engines.//;
		my $print  = 0;
		print "\n$engine\n";
		open(MD,"<$markdown") or die("Can't open $markdown for reading:$!\n");
		while (<MD>) {
			$print = /=/ unless $print;	print if $print;
		}
		close(MD);
	} else {
		print shift;
	}

	&sc_error(@_) if @_;
	exit;
}

#
# &uopen($OUTPUT)
#
# Opens and selects the $OUTPUT file when defined
#
sub uopen {
	my $output = shift;
	if ($output) {
		&sc_note(2,"Writing $output");
		open(OUTPUT,">$output") or &sc_fatal("Can't open $output for writting: $!\n");
		select OUTPUT
	}
}

#
# &uclose($OUTPUT)
#
# Closes and deselects the $OUTPUT file when defined
#
sub uclose {
	my $output = shift;
	if ($output) {
		close(OUTPUT);
	}
}

1;