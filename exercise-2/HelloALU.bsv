package HelloALU;
	
	typedef enum { 
		Mul, Div, Add, Sub, And, Or, Pow 
	} AluOps deriving (Eq, Bits);
	
	// 2.2.1 Tagged Unions und flexible ALU 
	typedef union tagged { 
		UInt#(32) Unsigned; 
		Int#(32) Signed; 
	} SignedOrUnsigned deriving (Eq, Bits);

	interface Power#(type t);
		method Action setOperands(t a, t b);
		method t getResult();
	endinterface

	module mkPower(Power#(t)) provisos (Bits#(t, t_sz), Ord#(t), Arith#(t), Eq#(t));
		
		Reg#(t) operandA <- mkReg(0);
		Reg#(t) operandB <- mkReg(0);
		Reg#(t) result <- mkReg(0);
		Reg#(Bool) has_result <- mkReg(False);

		rule calculate_power (operandB > 0);
			operandB <= operandB - 1;
			result <= result * operandA;
		endrule

		rule calculate_power_done (operandB == 0 && !has_result);
			has_result <= True;
		endrule

		method Action setOperands(t a, t b);
			result <= 1;
			operandA <= a;
			operandB <= b;
			has_result <= False;
		endmethod

		method t getResult() if (has_result);
			return result;
		endmethod
	endmodule

	interface HelloALU;
		method Action setupCalculation(AluOps op, SignedOrUnsigned a, SignedOrUnsigned b);
		method ActionValue#(SignedOrUnsigned) getResult();
	endinterface

	module mkHelloALU(HelloALU);
		Reg#(SignedOrUnsigned) operandA <- mkReg(tagged Signed 0);
		Reg#(SignedOrUnsigned) operandB <- mkReg(tagged Signed 0);
		Reg#(SignedOrUnsigned) result <- mkReg(tagged Signed 0);
		Reg#(AluOps) operation <- mkReg(Mul);
		Reg#(Bool) has_result <- mkReg(False);
		Reg#(Bool) new_values <- mkReg(False);
		
		Power#(UInt#(32)) powerUInt <- mkPower();
		Power#(Int#(32)) powerInt <- mkPower();

		rule calculateSigned (operandA matches tagged Signed .aa &&& operandB matches tagged Signed .bb &&& new_values);
			Int#(32) tmp = 0;
			case(operation)
				Mul: tmp = aa * bb;
				Div: tmp = aa / bb;
				Add: tmp = aa + bb;
				Sub: tmp = aa - bb;
				And: tmp = aa & bb;
				Or: tmp  = aa | bb;
				Pow: tmp = powerInt.getResult();
			endcase
			result <= tagged Signed tmp;
			new_values <= False;
			has_result <= True; 
		endrule

		rule calculateUnsigned (operandA matches tagged Unsigned .aa &&& operandB matches tagged Unsigned .bb &&& new_values);
			UInt#(32) tmp = 0;
			case(operation)
				Mul: tmp = aa * bb;
				Div: tmp = aa / bb;
				Add: tmp = aa + bb;
				Sub: tmp = aa - bb;
				And: tmp = aa & bb;
				Or: tmp  = aa | bb;
				Pow: tmp = powerUInt.getResult();
			endcase
			result <= tagged Unsigned tmp;
			new_values <= False;
			has_result <= True; 
		endrule

		method Action setupCalculation(AluOps op, SignedOrUnsigned a, SignedOrUnsigned b) if (!new_values);
			operandA <= a;
			operandB <= b;
			operation <= op;
			new_values <= True;
			has_result <= False;

			if (op == Pow)
				if (operandA matches tagged Signed .aa &&& operandB matches tagged Signed .bb)
					powerInt.setOperands(aa, bb);
				else if (operandA matches tagged Unsigned .aa &&& operandB matches tagged Unsigned .bb)
					powerUInt.setOperands(aa, bb);
				else
					$display("Both operands are mixed within type!");
		endmethod

		method ActionValue#(SignedOrUnsigned) getResult() if (has_result);
			has_result <= False;
			return result;
		endmethod
	endmodule

	module mkAluTestbench(Empty);
		HelloALU uut <- mkHelloALU();
		Reg#(UInt#(8)) state <- mkReg(0);

		rule testMul (state == 0);
			$display("Testing multiplication of 4 and 5...");
			uut.setupCalculation(Mul, tagged Unsigned 4, tagged Unsigned 5);
			state <= state + 1;
		endrule

		rule testDiv (state == 2);
			$display("Testing division of 4 and 2...");
			uut.setupCalculation(Div, tagged Unsigned 4, tagged Unsigned 2);
			state <= state + 1;
		endrule

		rule testAdd (state == 4);
			$display("Testing addition of 5 and 5...");
			uut.setupCalculation(Add, tagged Unsigned 5, tagged Unsigned 5);
			state <= state + 1;
		endrule

		rule testSub (state == 6);
			$display("Testing subtraction of 10 and 4...");
			uut.setupCalculation(Sub, tagged Unsigned 10, tagged Unsigned 4);
			state <= state + 1;
		endrule

		rule testAnd (state == 8);
			$display("Testing logical AND between 4 and 4...");
			uut.setupCalculation(And, tagged Unsigned 4, tagged Unsigned 4);
			state <= state + 1;
		endrule

		rule testOr (state == 10);
			$display("Testing logical OR between 8 and 8...");
			uut.setupCalculation(Or, tagged Unsigned 8, tagged Unsigned 8);
			state <= state + 1;
		endrule

		rule testPow (state == 12);
			$display("Testing 2 to the power of 5...");
			uut.setupCalculation(Pow, tagged Unsigned 2, tagged Unsigned 5);
			state <= state + 1;
		endrule

		rule endSimulation (state == 14);
			$finish();
		endrule

		rule displayResults;
			$display("Result: %d", uut.getResult());
			state <= state + 1;
		endrule

	endmodule
endpackage