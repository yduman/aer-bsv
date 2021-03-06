package HelloFSM;

	import StmtFSM :: *;
	import HelloALU :: *;
	import Vector :: *;

	typedef struct {
			Int#(32) opA;
			Int#(32) opB;
			AluOps operator;
			Int#(32) expectedResult;
	} TestData deriving (Eq, Bits);

	typedef union tagged {
		void Invalid;
		t Valid;
	} Maybe#(type t) deriving (Eq, Bits);

	interface SimpleCounter;
		method Action incr(UInt#(32) v);
		method Action decr(UInt#(32) v);
		method UInt#(32) counterValue();
	endinterface 

	// 2.1.1 Eine erste FSM
	module mkFirstFSM(Empty);
		Stmt myStmt = {
			seq
				delay(100);
				action
					$display("(%0d) Hello World", $time);
				endaction
			endseq
		};
		mkAutoFSM(myStmt);
	endmodule

	// 2.1.2 Parallele Ausfuehrung in FSM
	module mkSecondFSM(Empty);
		Reg#(Bool) boolReg <- mkReg(False);

		Stmt myStmt = {
			par
				seq
					$display("(%0d) seq 1 started", $time);	
					delay(100);
					boolReg <= True;
					$display("(%0d) seq 1 ended", $time);
				endseq
				seq
					$display("(%0d) seq 2 started", $time);	
					repeat(10) $display("(%0d) seq 2 repeating", $time);
					await(boolReg);
					$display("(%0d) seq 2 ended", $time);
				endseq
			endpar
		};
		mkAutoFSM(myStmt);
	endmodule

	// 2.1.3 FSM Ausfuehrung steuern
	module mkThirdFSM(Empty);
		Reg#(int) counter <- mkReg(0);
		Reg#(int) i <- mkReg(0);
		PulseWire pw <- mkPulseWire();

		rule count (counter < 99); 
			counter <= counter + 1;
		endrule

		rule finished (counter == 99);
			counter <= 0;
			pw.send();
		endrule

		Stmt myStmt = {
			seq
				for (i <= 0; i < 20; i <= i + 1)
					seq
						$display("time: (%0d) iteration: %d", $time, i);
					endseq
					$finish();
			endseq
		};
		FSM myFSM <- mkFSMWithPred(myStmt, pw);

		rule startFSM (myFSM.done());
			myFSM.start();
		endrule
	endmodule

	// 2.1.4 FSM als Testbench
	module mkFourthFSM(Empty);
		HelloALU uut <- mkHelloALU();
		Vector#(5, TestData) testVector;

		testVector[0] = TestData {opA: 2, opB: 4, operator: Add, expectedResult: 6};
		testVector[1] = TestData {opA: 10, opB: 5, operator: Sub, expectedResult: 5};
		testVector[2] = TestData {opA: 2, opB: 4, operator: Mul, expectedResult: 8};
		testVector[3] = TestData {opA: 10, opB: 5, operator: Div, expectedResult: 2};
		testVector[4] = TestData {opA: 5, opB: 2, operator: Pow, expectedResult: 25};

		Reg#(int) pointer <- mkReg(0);

		Stmt check = {
			seq
				action
					let currentTest = testVector[pointer];
					uut.setupCalculation(currentTest.operator, currentTest.opA, currentTest.opB);
				endaction

				action
					let currentTest = testVector[pointer];
					let result <- uut.getResult();
					if (result == currentTest.expectedResult)
						$display("Result correct: %d", result);
					else
						$display("Result incorrect: %d != %d", result, currentTest.expectedResult);
				endaction
			endseq
		};
		FSM checker <- mkFSM(check);

		Stmt test = {
			seq
				for (pointer <= 0; pointer < 5; pointer <= pointer + 1)
					seq
						checker.start();
						checker.waitTillDone();
					endseq
			endseq
		};
		mkAutoFSM(test);
	endmodule
	
	// 2.2.2 Maybe
	module mkHelloMaybe(SimpleCounter);
		RWire#(int) incrementWire <- mkRWire();
		RWire#(int) decrementWire <- mkRWire();
		Reg#(int) result <- mkReg(0);

		rule count;
			let counter = result;
			Maybe#(int) maybeIncrement = incrementWire.wget();
			Maybe#(int) maybeDecrement = decrementWire.wget();

			int incrementValue = 0;
			int decrementValue = 0;

			if (isValid(maybeIncrement)) incrementValue = fromMaybe(?, maybeIncrement);
			if (isValid(maybeDecrement)) decrementValue = fromMaybe(?, maybeDecrement);

			result <= result + incrementValue - decrementValue;
		endrule

		method Action incr(UInt#(32) v);
			incrementWire.wset(v);
		endmethod

		method Action decr(UInt#(32) v);
			decrementWire.wset(v);
		endmethod

		method UInt#(32) counterValue();
			return result;
		endmethod

	endmodule

	module mkMaybeTest(Empty);
		SimpleCounter uut <- mkHelloMaybe();
		Stmt testbench = {
			seq
				action 
					uut.incr(5);
				endaction

				action 
					$display("%d", uut.counterValue());
					uut.incr(5);
					uut.decr(6);
				endaction

				action
					$display("%d", uut.counterValue());
					uut.decr(4);
				endaction

				action 
					$display("%d", uut.counterValue());
				endaction
			endseq
		};
		mkAutoFSM(testbench);
	endmodule

endpackage