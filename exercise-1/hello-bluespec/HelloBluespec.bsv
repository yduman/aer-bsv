package HelloBluespec;

  interface HelloBluespec;
    (* always_enabled, always_ready *) method Bool getLed();
  endinterface

  module mkHelloBluespec(HelloBluespec);

    Reg#(UInt#(25)) counter <- mkReg(0);
    Reg#(Bool) is_led <- mkReg(False);

    rule displayHello (counter == 0);
      $display("(%0d) Hello World", $time);
			is_led <= !is_led;
    endrule

    rule increment;
      counter <= counter + 1;
    endrule

    method Bool getLed();
      return is_led;
    endmethod

  endmodule
endpackage

