module booth_multiplier #(
    parameter N = 4
)(
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 start,
    input  wire signed [N-1:0]  multiplicand,
    input  wire signed [N-1:0]  multiplier,
    output reg  signed [2*N-1:0] product,
    output reg                  done
);

    reg signed [N-1:0] M;
    reg signed [N-1:0] A;
    reg signed [N-1:0] Q;
    reg                  Q_1;
    reg [N-1:0]          count;

    always @(posedge clk or posedge rst) begin

        if (rst) begin
            M       <= 0;
            A       <= 0;
            Q       <= 0;
            Q_1     <= 0;
            count   <= 0;
            product <= 0;
            done    <= 0;
        end

        else begin
            done <= 0;

            if (start) begin
                M     <= multiplicand;
                A     <= 0;
                Q     <= multiplier;
                Q_1   <= 0;
                count <= 0;
            end

            else if (count < N) begin

                // Booth decision
                case ({Q[0], Q_1})

                    2'b01: A <= A + M;  // Add M

                    2'b10: A <= A - M;  // Subtract M

                    default: A <= A;    // No operation

                endcase

                // Arithmetic right shift
                {A, Q, Q_1} <= {A, Q, Q_1} >>> 1;

                count <= count + 1;
            end

            else begin
                product <= {A, Q};
                done    <= 1;
            end
        end
    end

endmodule
