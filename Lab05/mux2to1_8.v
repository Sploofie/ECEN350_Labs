module mux2to1_8 (
    input wire [7:0] a,
    input wire [7:0] b,
    input wire sel,
    output reg  [7:0] out
);

    always @(*) begin
        if (sel == 1'b0)
            out = a;
        else
            out = b;
    end

endmodu
