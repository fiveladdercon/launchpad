use EngineAPI;

sub named {
	my $region = shift;
	while (my $node = $region->sc_get_next_child()) {
		printf("%08x %08x %s\n",$node->sc_get_address(), $node->sc_get_size(), $node->sc_get_identifier()) if $node->sc_is_named();
		&named($node) if $node->sc_is_region();
	}
}

&named(&sc_get_space());