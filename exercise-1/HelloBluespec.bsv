package HelloBluespec;
  module mkHelloBluespec(Empty);

	Reg#(UInt#(25)) counter <- mkReg(0);

	rule displayHello (counter == 0);
		$display("(%0d) Hello World", $time);
	endrule

	rule increment;
		counter <= counter + 1;
	endrule

  endmodule
endpackage

