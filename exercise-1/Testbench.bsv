package Testbench;
	import HelloBluespec :: *;

	module mkHelloTestbench(Empty);
		HelloBluespec uut <- mkHelloBluespec();
		Reg#(UInt#(32)) counter <- mkReg(0);

		rule endSimulation (counter == 200000000);
			$finish();
		endrule

		rule increment;
			counter <= counter + 1;
		endrule

	endmodule
endpackage