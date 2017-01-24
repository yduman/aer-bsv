package TestImageFilter;

import ImageFilter :: *;
import ClientServer :: *;
import GetPut :: *;
import Vector :: *;

module mkTestbench(Empty);
	// Get uut and create data structure for test data
	Server#(RGB, GrayScale) uut <- mkGray;
	Vector#(4, Tuple2#(RGB, GrayScale)) testData;

	// test data
	testData[0] = tuple2(RGB { r: 0, g: 0, b: 0 }, 0);
	testData[1] = tuple2(RGB { r: 255, g: 255, b: 255 }, 254);
	testData[2] = tuple2(RGB { r: 42, g: 10, b: 50 }, 23);
	testData[3] = tuple2(RGB { r: 128, g: 5, b: 240 }, 68);

	Reg#(Bool) send <- mkReg(True);
	Reg#(int) pointer <- mkReg(0);

	// send a request
	rule send (send && pointer < 4);
		uut.request.put(tpl_1(testData[pointer]));
		send <= False;
	endrule

	// check response
	rule get (!send && pointer < 4);
		let result <- uut.response.get();
		if (result != tpl_2(testData[pointer]))
			$display("Error. Wrong Calculation at testData[%d]", pointer);

		pointer <= pointer + 1;
		send <= True;
	endrule

	// finish 
	rule endTest (pointer == 4);
		$finish();
	endrule
endmodule


endpackage;