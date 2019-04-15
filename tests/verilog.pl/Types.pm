#-------------------------------------------------------------------------------
package TEST;
#-------------------------------------------------------------------------------
use base ('Field');

sub implementation {
	my $Field = shift;
	$Field->assign($Field->Value->wire, $Field->default);
	$Field->assign($Field->Port->output->wire, $Field->Value);
}

1;