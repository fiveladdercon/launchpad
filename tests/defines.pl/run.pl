use lib "$ENV{SC_LAUNCHPAD}/tests";
use run;

sub compile {
	my $mode = shift;
	&rm("test.exe *.log");
	&execute("gcc -I . -o test.exe test.c");
	&execute("./test.exe > $mode.act") if -e "test.exe";
	&diff("$mode.act","$mode.exp");
	&rm("test.h test.exe $mode.act");
}

sub head {
	my $act = shift;
	my $exp = shift;
	my $n   = shift; $n = 1 unless defined $n;
	&execute("head -$n $exp > $exp.head");
	&diff($act,"$exp.head");
	&rm("$act $exp.head");
}

sub tail {
	my $act = shift;
	my $exp = shift;
	my $n   = shift; $n = 1 unless defined $n;
	&execute("tail -$n $exp > $exp.tail");
	&diff($act,"$exp.tail");
	&rm("$act $exp.tail");
}

describe("defines.pl", sub {

	describe("C dialect", sub {

		describe("list format",sub {

			describe("debug mode", sub {

				it("is generated by default", sub {
					spacecraft("test.rf defines.pl c_list_debug.act");
					diff("c_list_debug.act","c_list_debug.exp");
				});

				it("compiles & executes", sub {
					spacecraft("test.rf defines.pl test.h");
					compile("c_exec_debug");
				});

			});

			describe("optimized mode", sub {

				it("is generated with the -?-o(ptimize)? switch", sub {
					foreach my $optimize ("-o","--o","-optimize","--optimize") {
						spacecraft("test.rf defines.pl $optimize c_list_opt.act");
						diff("c_list_opt.act","c_list_opt.exp");
					}
				});

				it("compiles & executes", sub {
					spacecraft("test.rf defines.pl -o test.h");
					compile("c_exec_opt");
				});

			});

		});

		describe("struct format",sub {

			describe("debug mode", sub {

				it("is generated with the -?-s(tructs)? switch", sub {
					foreach my $structs ("-s","--s","-structs","--structs") {
						spacecraft("test.rf defines.pl $structs c_struct_debug.act");
						diff("c_struct_debug.act","c_struct_debug.exp");
					}
				});

				it("compiles & executes", sub {
					spacecraft("test.rf defines.pl -s test.h");
					compile("c_exec_debug");
				});

			});

			describe("optimized mode", sub {

				it("is generated with the -?-s(tructs)? and -?-o(ptimize)? switches", sub {
					foreach my $structs ("-s","--s","-structs","--structs") {
						foreach my $optimize ("-o","--o","-optimize","--optimize") {
							spacecraft("test.rf defines.pl $optimize $structs c_struct_opt.act");
							diff("c_struct_opt.act","c_struct_opt.exp");
						}
					}
				});

				it("compiles & executes", sub {
					spacecraft("test.rf defines.pl -o -s test.h");
					compile("c_exec_opt");
				});

			});

		});

		describe("access defines", sub {

			it("is omitted with the -?-a(ccess)? switch", sub {
				foreach my $access ("-a","--a","-access","--access") {
					spacecraft("test.rf defines.pl $access c_list_debug.act");
					tail("c_list_debug.act","c_list_debug.exp",9);

					spacecraft("test.rf defines.pl $access -o c_list_opt.act");
					tail("c_list_opt.act","c_list_opt.exp",9);

					spacecraft("test.rf defines.pl $access -s c_struct_debug.act");
					tail("c_struct_debug.act","c_struct_debug.exp",9);

					spacecraft("test.rf defines.pl $access -s -o c_struct_opt.act");
					tail("c_struct_opt.act","c_struct_opt.exp",9);
				}
			});

		});

		describe("constant defines", sub {

			it("are omitted with the -?-c(onstants)? switch", sub {
				foreach my $constants ("-c","--c","-constants","--constants") {
					spacecraft("test.rf defines.pl $constants c_list_debug.act");
					head("c_list_debug.act","c_list_debug.exp",77);

					spacecraft("test.rf defines.pl $constants -o c_list_opt.act");
					head("c_list_opt.act","c_list_opt.exp",77);

					spacecraft("test.rf defines.pl $constants -s c_struct_debug.act");
					head("c_struct_debug.act","c_struct_debug.exp",72);

					spacecraft("test.rf defines.pl $constants -s -o c_struct_opt.act");
					head("c_struct_opt.act","c_struct_opt.exp",70);
				}
			});

		});

	});

	describe("Verilog dialect", sub {

	});

});


&rm("test.h");

&report("defines.pl");