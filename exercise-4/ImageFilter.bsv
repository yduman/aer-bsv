package ImageFilter;

import GetPut :: *;
import ClientServer :: *;
import FIFO :: *;

typedef Bit#(8) Color;
typedef Bit#(8) GrayScale;

typedef struct {
	Color r;
	Color g;
	Color b;
} RGB deriving (Bits, Eq, FShow);

module mkGray(Server#(RGB, GrayScale));
	// FIFO for request and response
	FIFO#(RGB) fifo_in <- mkFIFO;
	FIFO#(GrayScale) fifo_out <- mkFIFO;

	// Grayscale calculation
	function GrayScale calcGray(RGB rgb);
		UInt#(16) result = 0;
		
		// Q8.8 representation
		UInt#(16) r = extend(unpack(rgb.r)) << 8;
		UInt#(16) g = extend(unpack(rgb.g)) << 8;
		UInt#(16) b = extend(unpack(rgb.b)) << 8;

		// Float to Q
		// Multiply the floating point number by pow(2, 8)
		// Round to nearest integer
		// floor(factor * (1 << 8))
		UInt#(16) factorR = 76;
		UInt#(16) factorG = 150;
		UInt#(16) factorB = 29;

		// Mult factors with colors and normalize to UInt(16) again
		UInt#(24) mult_result = extend(r) * extend(factorR);
		r = truncate(mult_result >> 8);

		mult_result = extend(g) * extend(factorG);
		g = truncate(mult_result >> 8);

		mult_result = extend(b) * extend(factorB);
		b = truncate(mult_result >> 8);

		// sum up and return 
		result = r + g + b;
		return pack(result)[15:8];
	endfunction

	rule calc;
		let color = fifo_in.first(); fifo_in.deq();
		let gray = calcGray(color);
		fifo_out.enq(gray);
	endrule

	interface Put request = toPut(fifo_in);
	interface Get response = toGet(fifo_out);
endmodule

endpackage