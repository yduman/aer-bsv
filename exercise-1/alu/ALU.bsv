package ALU;

	interface HelloALU;
		method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
		method ActionValue#(Int#(32)) getResult();
	endinterface

	module mkSimpleALU(HelloALU);

		method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
			// do stuff
		endmethod

		method ActionValue#(Int#(32)) getResult();
			// do stuff
		endmethod

	endmodule
endpackage