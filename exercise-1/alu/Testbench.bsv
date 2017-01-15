package Testbench;
	import HelloALU :: *;

	module mkAluTestbench(Empty);
		HelloALU uut <- mkHelloALU();
		Reg#(UInt#(8)) state <- mkReg(0);

		rule testMul (state == 0);
			$display("Testing multiplication of 4 and 5...");
			uut.setupCalculation(Mul, 4, 5);
			state <= state + 1;
		endrule

		rule testDiv (state == 2);
			$display("Testing division of 4 and 2...");
			uut.setupCalculation(Div, 4, 2);
			state <= state + 1;
		endrule

		rule testAdd (state == 4);
			$display("Testing addition of 5 and 5...");
			uut.setupCalculation(Add, 5, 5);
			state <= state + 1;
		endrule

		rule testSub (state == 6);
			$display("Testing subtraction of 10 and 4...");
			uut.setupCalculation(Sub, 10, 4);
			state <= state + 1;
		endrule

		rule testAnd (state == 8);
			$display("Testing logical AND between 4 and 4...");
			uut.setupCalculation(And, 4, 4);
			state <= state + 1;
		endrule

		rule testOr (state == 10);
			$display("Testing logical OR between 8 and 8...");
			uut.setupCalculation(Or, 8, 8);
			state <= state + 1;
		endrule

		rule displayResults;
			$display("Result: %d", uut.getResult());
			state <= state + 1;
		endrule

		rule endSimulation (state == 12);
			$finish();
		endrule

	endmodule
endpackage