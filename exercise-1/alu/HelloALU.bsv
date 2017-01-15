package HelloALU;
	
	typedef enum{Mul, Div, Add, Sub, And, Or} AluOps deriving (Eq, Bits);

	interface HelloALU;
		method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
		method ActionValue#(Int#(32)) getResult();
	endinterface

	module mkHelloALU(HelloALU);
		Reg#(Int#(32)) operandA <- mkReg(0);
		Reg#(Int#(32)) operandB <- mkReg(0);
		Reg#(AluOps) operation <- mkReg(Mul);
		Reg#(Int#(32)) result <- mkReg(0);
		Reg#(Bool) has_result <- mkReg(False);
		Reg#(Bool) new_values <- mkReg(False);

		rule calculate (new_values);
			Int#(32) tmp = 0;
			case(operation)
				Mul: tmp = operandA * operandB;
				Div: tmp = operandA / operandB;
				Add: tmp = operandA + operandB;
				Sub: tmp = operandA - operandB;
				And: tmp = operandA & operandB;
				Or: tmp = operandA | operandB;
			endcase
			result <= tmp;
			new_values <= False;
			has_result <= True; 
		endrule

		method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b) if (!new_values);
			operandA <= a;
			operandB <= b;
			operation <= op;
			new_values <= True;
			has_result <= False;
		endmethod

		method ActionValue#(Int#(32)) getResult() if (has_result);
			has_result <= False;
			return result;
		endmethod
	endmodule
endpackage