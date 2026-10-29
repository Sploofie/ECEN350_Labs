`timescale 1ns/1ps

module tb_RegisterFile;

    wire [63:0] BusA;
    wire [63:0] BusB;
    reg  [63:0] BusW;
    reg  [4:0]  RA;
    reg  [4:0]  RB;
    reg  [4:0]  RW;
    reg         RegWr;
    reg         Clk;

    integer i;
    integer errors;

    reg [63:0] rand_value;
    reg [63:0] old_value;
    reg [63:0] new_value;

    RegisterFile dut (
        .BusA(BusA),
        .BusB(BusB),
        .BusW(BusW),
        .RA(RA),
        .RB(RB),
        .RW(RW),
        .RegWr(RegWr),
        .Clk(Clk)
    );

    // Clock generation
    initial begin
        Clk = 0;
        forever #5 Clk = ~Clk;
    end

    // Make a 64-bit random value using two 32-bit random values
    function [63:0] random64;
        begin
            random64 = {$random, $random};
        end
    endfunction

    initial begin
        $dumpfile("RegisterFile_tb.vcd");
        $dumpvars(0, tb_RegisterFile);

        errors = 0;

        RegWr = 0;
        BusW  = 64'd0;
        RA    = 5'd0;
        RB    = 5'd0;
        RW    = 5'd0;

        #10;

        // Test registers 0 through 30
        for (i = 0; i < 31; i = i + 1) begin

            // -----------------------------
            // Test write enable ON
            // -----------------------------
            rand_value = random64();

            RW    = i[4:0];
            BusW  = rand_value;
            RegWr = 1'b1;

            @(posedge Clk);
            #1;
            RegWr = 1'b0;

            // Read back written value
            RA = i[4:0];
            RB = i[4:0];

            // Wait more than #3 output delay
            #5;

            $display("RegWr=1 Write R%0d = %h | BusA=%h BusB=%h",
                     i, rand_value, BusA, BusB);

            if (BusA !== rand_value) begin
                $display("ERROR: BusA wrong for R%0d. Expected %h, got %h",
                         i, rand_value, BusA);
                errors = errors + 1;
            end

            if (BusB !== rand_value) begin
                $display("ERROR: BusB wrong for R%0d. Expected %h, got %h",
                         i, rand_value, BusB);
                errors = errors + 1;
            end

            old_value = rand_value;

            // -----------------------------
            // Test write enable OFF
            // -----------------------------
            new_value = random64();

            RW    = i[4:0];
            BusW  = new_value;
            RegWr = 1'b0;

            @(posedge Clk);
            #1;

            // Read back register; it should still contain old_value
            RA = i[4:0];
            RB = i[4:0];

            #5;

            $display("RegWr=0 Attempt Write R%0d = %h | BusA=%h BusB=%h Expected=%h",
                     i, new_value, BusA, BusB, old_value);

            if (BusA !== old_value) begin
                $display("ERROR: BusA changed when RegWr=0 for R%0d. Expected %h, got %h",
                         i, old_value, BusA);
                errors = errors + 1;
            end

            if (BusB !== old_value) begin
                $display("ERROR: BusB changed when RegWr=0 for R%0d. Expected %h, got %h",
                         i, old_value, BusB);
                errors = errors + 1;
            end
        end

        // -----------------------------
        // Test register 31 / XZR
        // -----------------------------
        RW    = 5'd31;
        BusW  = random64();
        RegWr = 1'b1;

        @(posedge Clk);
        #1;
        RegWr = 1'b0;

        RA = 5'd31;
        RB = 5'd31;

        #5;

        $display("Attempt Write R31 = %h | BusA=%h BusB=%h Expected=0",
                 BusW, BusA, BusB);

        if (BusA !== 64'd0) begin
            $display("ERROR: BusA for R31 should be 0, got %h", BusA);
            errors = errors + 1;
        end

        if (BusB !== 64'd0) begin
            $display("ERROR: BusB for R31 should be 0, got %h", BusB);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED with %0d errors", errors);

        $finish;
    end

endmodule
