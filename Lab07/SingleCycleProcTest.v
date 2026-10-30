      // ***********************************************************
      // Program 2: MOVZ test (starts at NEW = 0x34, LDUR at 0x54)
      // ***********************************************************
      #1
        Reset = 1; startPC = 64'h34;
      @(posedge CLK);
      @(negedge CLK);
      @(posedge CLK);
      Reset = 0;

      while (currentPC < 64'h54)
        begin
           @(posedge CLK);
           @(negedge CLK);
           $display("CurrentPC:%h",currentPC);
        end
      passTest(MemtoRegOut, 64'h123456789ABCDEF0, "Results of Program 2 (MOVZ)", passed);

      // Done
      allPassed(passed, 2);   // two tests now
      $finish;
