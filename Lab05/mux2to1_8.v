`timescale 1ns/1ps

module tb_mux2to1_8;

    reg  [7:0] in0;
    reg  [7:0] in1;
    reg        sel;
    wire [7:0] out;

    reg  [7:0] expected;
    integer i0;
    integer i1;
    integer s;
    integer errors;

    // Instantiate the device under test
    // If your structural mux module has a different name,
    // change mux2to1_8 to that module name.
    mux2to1_8 dut (
        .in0(in0),
        .in1(in1),
        .sel(sel),
        .out(out)
    );

    initial begin
        // Create VCD waveform file
        $dumpfile("mux2to1_8.vcd");
        $dumpvars(0, tb_mux2to1_8);

        errors = 0;

        // Exhaustively test every input combination:
        // sel has 2 possibilities
        // in0 has 256 possibilities
        // in1 has 256 possibilities
        for (s = 0; s < 2; s = s + 1) begin
            for (i0 = 0; i0 < 256; i0 = i0 + 1) begin
                for (i1 = 0; i1 < 256; i1 = i1 + 1) begin

                    // Apply stimulus
                    sel = s[0];
                    in0 = i0[7:0];
                    in1 = i1[7:0];

                    // Wait 5 ticks after inputs change
                    #5;

                    // Determine expected output
                    if (sel == 1'b0)
                        expected = in0;
                    else
                        expected = in1;

                    // Print stimulus and output
                    $display("sel=%b in0=%h in1=%h | out=%h expected=%h",
                              sel, in0, in1, out, expected);

                    // Check output
                    if (out !== expected) begin
                        $display("ERROR: sel=%b in0=%h in1=%h out=%h expected=%h",
                                  sel, in0, in1, out, expected);
                        errors = errors + 1;
                    end

                end
            end
        end

        if (errors == 0) begin
            $display("TEST PASSED: all input combinations correct.");
        end else begin
            $display("TEST FAILED: %0d errors found.", errors);
        end

        $finish;
    end

endmodule
