# Booth-Multiplication
Booth multiplication is a binary algorithm that efficiently multiplies signed numbers using two's complement. It reduces operations by encoding sequences in the multiplier, improving speed and performance in digital systems.
// --------------------------
module shiftreg(
    output reg [15:0] out,     // Parallel output
    input      [15:0] in,      // Parallel input
    input             sin,     // Serial input (for shifting)
    input             clk,
    input             load,    // Load enable
    input             shift    // Shift enable
);
    always @(posedge clk) begin
        if (load)
            out <= in;                     // Load input
        else if (shift)
            out <= {out[14:0], sin};       // Shift left with serial in
    end
endmodule

// --------------------------
// D Flip-Flop module (QM1)
// --------------------------
module dff(
    input d,
    output reg q,
    input clk,
    input clr
);
    always @(posedge clk) begin
        if (clr)
            q <= 0;
        else
            q <= d;
    end
endmodule

// --------------------------
// PIPO (Parallel In Parallel Out) register
// --------------------------
module PIPO(
    input [15:0] in,
    output reg [15:0] out,
    input clk,
    input load
);
    always @(posedge clk) begin
        if (load)
            out <= in;
    end
endmodule

// --------------------------
// ALU (Add/Subtract)
// --------------------------
module ALU(
    output reg [15:0] out,
    input [15:0] a,
    input [15:0] b,
    input addsub  // 1 for add, 0 for subtract
);
    always @(*) begin
        if (addsub)
            out = a + b;
        else
            out = a - b;
    end
endmodule

// --------------------------
// Counter (5-bit)
// --------------------------
module counter(
    output reg [4:0] count,
    input decr,
    input load,
    input clk
);
    always @(posedge clk) begin
        if (load)
            count <= 5'd16; // or any initial value you want
        else if (decr)
            count <= count - 1;
    end
endmodule

// --------------------------
// Top-Level Module
// --------------------------
module boothmultiplication(
    input lda, ldb, ldq, ldm, clra, clrq, clrff, sfta, sftq, addsub, clk,
    input [15:0] data_in,
    output qm1,
    output eqz,
    output [15:0] a, m, q, z,
    output [4:0] count
);

   wire decr, ldcnt;

  // eqz = (count == 0)
    assign eqz = ~|count;

  // Instantiate shift register A
    shiftreg AR(a, z, a[15], clk, clra, sfta);

   // Instantiate shift register Q
    shiftreg QR(q, data_in, a[0], clk, ldq, sftq);

   // D flip-flop for QM1
    dff QM1(q[0], qm1, clk, clrff);

   // Parallel register for M
    PIPO MR(data_in, m, clk, ldm);
  // ALU for add/sub operation
    ALU AS(z, a, m, addsub);

  // Counter for iteration control
    counter CN(count, decr, ldcnt, clk);

endmodule
