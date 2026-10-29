module RegisterFile(
    output wire [63:0] BusA,
    output wire [63:0] BusB,
    input  wire [63:0] BusW,
    input  wire [4:0]  RA,
    input  wire [4:0]  RB,
    input  wire [4:0]  RW,
    input  wire        RegWr,
    input  wire        Clk
);

    // ARMv8 has 32 registers, each 64 bits.
    // Register 31 is XZR, so only registers 0-30 need storage.
    reg [63:0] registers [0:30];

    reg [63:0] BusA_temp;
    reg [63:0] BusB_temp;

    // Combinational read logic
    always @(*) begin
        if (RA == 5'd31)
            BusA_temp = 64'd0;
        else
            BusA_temp = registers[RA];

        if (RB == 5'd31)
            BusB_temp = 64'd0;
        else
            BusB_temp = registers[RB];
    end

    // Required output delay of 3 ticks
    assign #3 BusA = BusA_temp;
    assign #3 BusB = BusB_temp;

    // Sequential write logic
    always @(posedge Clk) begin
        if (RegWr && (RW != 5'd31)) begin
            registers[RW] <= BusW;
        end
    end

endmodule
