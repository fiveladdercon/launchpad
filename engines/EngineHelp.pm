package EngineHelp;
use EngineAPI;
use base qw(Exporter);

@EXPORT = qw(help);

sub help {
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
		print "\n";
	} else {
		print shift;
	}

	&sc_error(@_) if @_;
	exit;
}

1;