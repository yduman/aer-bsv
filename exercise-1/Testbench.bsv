package Testbench;
	import HelloBluespec :: *;

	module mkHelloTestbench(Empty);
		HelloBluespec uut <- mkHelloBluespec();
		Reg#(UInt#(28)) counter <- mkReg(0);
		Reg#(Bool) last_led_status <- mkReg(False);

		rule endSimulation (counter == 200000000);
			$finish();
		endrule

		rule increment;
			counter <= counter + 1;
		endrule

		rule checkLedStatusChange;
			last_led_status <= uut.getLed();
			if (last_led_status == True && uut.getLed() == False)
				$display("LED off.");
			else if (last_led_status == False && uut.getLed() == True)
				$display("LED on.");
		endrule

	endmodule
endpackage