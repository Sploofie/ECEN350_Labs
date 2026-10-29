`define InType  2'b00
`define DType   2'b01
`define CBType  2'b10
`define BIType  2'b11

module SignExtender(
    output reg [63:0] SignExOut,
    input      [25:0] Instruction,
    input       [1:0] SignOp
);

    always @(*) begin
        case (SignOp)
            `InType:
                // I-type: 12-bit immediate, Instruction[21:10]
                SignExOut = {{52{Instruction[21]}},
                             Instruction[21:10]};

            `DType:
                // D-type: 9-bit immediate, Instruction[20:12]
                SignExOut = {{55{Instruction[20]}},
                             Instruction[20:12]};

            `CBType:
                // CB-type: 19-bit immediate, shifted left by 2
                SignExOut = {{43{Instruction[23]}},
                             Instruction[23:5],
                             2'b00};

            `BIType:
                // B-type: 26-bit immediate, shifted left by 2
                SignExOut = {{36{Instruction[25]}},
                             Instruction[25:0],
                             2'b00};

            default:
                SignExOut = 64'b0;
        endcase
    end

endmodule
