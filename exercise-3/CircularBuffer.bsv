package CircularBuffer;

import Vector :: *;
import FIFO :: *;
import BlueCheck :: *;

interface MyFIFO;
	// Put Element on FIFO
	method Action put(Int#(16) e);

	// Get Element from FIFO
	method ActionValue#(Int#(16)) get();
endinterface

// Circular Buffer module
module mkCircBuffer(MyFIFO);
	Reg#(UInt#(4)) writePointer <- mkReg(0);
	Reg#(UInt#(4)) readPointer <- mkReg(0);
	Vector#(16, Reg#(Int#(16))) buffer;

	// Fill the buffer
	for (Integer i = 0; i < 16; i = i + 1) begin
		buffer[i] <- mkRegU();
	end

	// Put element
	method Action put(Int#(16) e) if ((writePointer + 1) != readPointer);
		writePointer <= writePointer + 1;
		buffer[writePointer] <= e;
	endmethod

	// Get element
	method ActionValue#(Int#(16)) get() if (readPointer != writePointer);
		readPointer <= readPointer + 1;
		return buffer[readPointer];
	endmethod
endmodule

// Test to check if our implementation is equal to the reference implementation
module [BlueCheck] checkBuffer ();
	FIFO#(Int#(16)) goldenFIFO <- mkSizedFIFO(16); // reference
	MyFIFO myFIFO <- mkCircBuffer();

	// pop function for reference impl.
	function ActionValue#(Int#(16)) popItem(FIFO#(Int#(16)) fifo);
		actionvalue
			fifo.deq();
			return fifo.first();
		endactionvalue
	endfunction

	// check
	equiv("put", goldenFIFO.enq, myFIFO.put);
	equiv("get", popItem(goldenFIFO), myFIFO.get);
endmodule

// execute test with BlueCheck
module [Module] mkBufferChecker ();
  blueCheck(checkBuffer);
endmodule

endpackage