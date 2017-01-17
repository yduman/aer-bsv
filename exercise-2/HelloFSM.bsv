package HelloFSM;

	import StmtFSM :: *;
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

endpackage