#-------------------------------------------------------------------------------
package TEST;
#-------------------------------------------------------------------------------
use base ('Field');

sub implementation {
	my $Field = shift;
	$Field->assign($Field->Port->output->wire,$Field->default);
}

1;