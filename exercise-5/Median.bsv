package Median;

import GetPut :: *;
import ClientServer :: *;
import FIFO :: *;
import Vector :: *;
import List :: *;
import Types :: *;
import BlueCheck :: *;

typedef Vector#(9, GrayScale) Kernel;
typedef Vector#(3, GrayScale) GrayScaleStream;
typedef Server#(Vector#(9, GrayScale), GrayScale) Median;

typedef struct {
	GrayScale max;
	GrayScale med;
	GrayScale min;
} Sorted deriving (Bits, Eq);

module mkSort(Server#(GrayScaleStream, Sorted));
	FIFO#(GrayScaleStream) inputData <- mkFIFO();
	FIFO#(Sorted) outputData <- mkFIFO();

	rule sort;
		let i = inputData.first(); inputData.deq();
		let xored = i[0] ^ i[1] ^ i[2];
		Sorted sorted;
		sorted.max = max(i[0], max(i[1], [2]));
		sorted.min = min(i[0], min(i[1], [2]));
		sorted.med = xored ^ sorted.max ^ sorted.min;
		outputData.enq(sorted);
	endrule

	interface Put request = toPut(inputData);
	interface Get response = toGet(outputData);
endmodule

module mkMedian(Median);
	FIFO#(Kernel) inputData <- mkFIFO();
	FIFO#(GrayScale) outputData <- mkFIFO();
	Vector#(7, Server#(GrayScaleStream, Sorted)) sortingNetwork <- replicateM(mkSort());

	rule firstStage;
		let t = inputData.first(); inputData.deq();
		Vector#(3, Vector#(3, GrayScale)) c = unpack(pack(t));

		for (Integer i = 0; i < 3; i = i + 1) begin
			sortingNetwork[i].request.put(c[i]);
		end
	endrule

	rule secondStage;
		Vector#(3, Vector#(3, GrayScale)) sorted;

		for (Integer i = 0; i < 3; i = i + 1) begin
			let tmp <- sortingNetwork[i].response.get();
			sorted[i] = unpack(pack(tmp));
		end

		for (Integer i = 0; i < 3; i = i + 1) begin
			GrayScaleStream iSort;
			for (Integer j = 0; j < 3; j = j + 1) begin
				iSort[j] = sorted[i][j];
			end

			sortingNetwork[3 + i].request.put(iSort);
		end
	endrule

	rule thirdStage;
		GrayScaleStream sorted;

		for (Integer i = 0; i < 3; i = i + 1) begin
			let tmp <- sortingNetwork[3 + i].response.get();
			GrayScaleStream tmpSorted = unpack(pack(tmp));
			sorted[i] = tmpSorted[2 - i];
		end
		sortingNetwork[6].request.put(sorted);
	endrule

	rule fourthStage;
		let tmp <- sortingNetwork[6].response.get();
		outputData.enq(tmp.med);
	endrule

	interface Put request = toPut(inputData);
	interface Get response = toGet(outputData);
endmodule

module [BlueCheck] mkMedianSpec();
	Median implementation <- mkMedian();
	FIFO#(Kernel) specFIFO <- mkFIFO();

	function ActionValue#(GrayScale) getMedian();
		actionvalue
			let s = specFIFO.first(); specFIFO.deq();
			List#(GrayScale) grayScaleList = toList(s);
			grayScaleList = sort(grayScaleList);

			return grayScaleList[4];
		endactionvalue
	endfunction

	equiv("put", specFIFO.enq, implementation.request.put)
	equiv("get", getMedian, implementation.response.get)
endmodule

module [Module] mkMedianChecker();
	blueCheck(mkMedianSpec);
endmodule

endpackage