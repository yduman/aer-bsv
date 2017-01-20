package HelloFSM;

	import StmtFSM :: *;

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

endpackage