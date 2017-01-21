package NestedInterface;
	
	import FIFO :: *;
	import Vector :: *;

	interface CalcUnit;
		method Action put(Int#(32) v);
		method ActionValue#(Int#(32)) result;
	endinterface

	interface CalcUnitChangeable;
		interface CalcUnit calc;
		method Action setParameter(Int#(32) param);
	endinterface

	module mkChangeableUnit#(function Int#(32) f(Int#(32) a, Int#(32) b)) (CalcUnitChangeable);
		Reg#(Int#(32)) p <- mkReg(0);
		Reg#(Int#(32)) a <- mkReg(0);
		FIFO#(Int#(32)) r <- mkFIFO();

		rule doCalc;
			r.enq(f(a, p));
		endrule

		method Action setParameter(Int#(32) param);
			p <= param;
		endmethod

		interface CalcUnit calc;
			method Action put(Int#(32) v);
				a <= v;
			endmethod

			method ActionValue#(Int#(32)) result;
				r.deq();
				return r.first();
			endmethod
		endinterface
	endmodule

	module mkCalcUnit#(function Int#(32) f(Int#(32) a)) (CalcUnit);
		Reg#(Int#(32)) a <- mkReg(0);
		FIFO#(Int#(32)) r <- mkFIFO();

		rule calc;
			r.enq(f(a));
		endrule

		method Action put(Int#(32) v);
			a <= v;
		endmethod
		
		method ActionValue#(Int#(32)) result;
			r.deq();
			return r.first();
		endmethod
	endmodule

	module mkSomeCalculation(CalcUnit);
		Reg#(Int#(32)) a <- mkReg(42);
		Reg#(Int#(32)) b <- mkReg(2);
		Reg#(Int#(32)) c <- mkReg(4);

		function addFunc(x, y) = x + y;
		function subFunc(x, y) = x - y;
		function timesFunc(x, y) = x * y;

		CalcUnitChangeable addA <- mkChangeableUnit(addFunc);
		CalcUnitChangeable timesB <- mkChangeableUnit(timesFunc);
		CalcUnitChangeable subC <- mkChangeableUnit(subFunc);

		Vector#(3, CalcUnit) calcUnits;
		calcUnits[0] = addA.calc;
		calcUnits[1] = timesB.calc;
		calcUnits[2] = subC.calc;

		Reg#(Bool) initialized <- mkReg(False);

		rule initialize (!initialized);
			initialized <= True;
			addA.setParameter(a);
			timesB.setParameter(b);
			subC.setParameter(c);
		endrule

		FIFO#(Int#(32)) inFIFO <- mkFIFO();
		FIFO#(Int#(32)) outFIFO <- mkFIFO();

		for (Integer i = 1; i < 3; i = i + 1) begin
			rule calc;
				let t <- calcUnits[i - 1].result();
				calcUnits[i].put(t);
			endrule
		end

		rule setupCalc;
			calcUnits[0].put(inFIFO.first());
			inFIFO.deq();
		endrule

		rule outputResult;
			let result <- calcUnits[2].result();
			outFIFO.enq(result);
		endrule

		method Action put(Int#(32) v);
			inFIFO.enq(v);
		endmethod

		method ActionValue#(Int#(32)) result;
			outFIFO.deq();
			return outFIFO.first();
		endmethod
	endmodule

	module testCalculations(Empty);
		CalcUnit uut <- mkSomeCalculation();
		Reg#(Int#(32)) counter <- mkReg(0);

		rule printResult;
			$display("(%0d) Result: %d", $time, uut.result());
		endrule

		rule putData;
			$display("(%0d) Put: %d", $time, counter);
		endrule

		rule countUp;
			counter <= counter + 1;
		endrule

		rule endIt (counter == 40);
			$finish();
		endrule
	endmodule

endpackage