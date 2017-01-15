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
endpackage