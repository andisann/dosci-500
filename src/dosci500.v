module DOSCI500(
    input AXIS_ARESETN,
    input AXIS_ACLK, // 50 MHz
    output signed [7:0] M_AXIS_TDATA,
    output reg M_AXIS_TVALID,
    input M_AXIS_TREADY
);

localparam signed [7:0] c = 8'sd118;
wire signed [7:0] x_aux; // S(n+1)
reg signed [7:0] y_aux;     // S(n-1)
reg signed [7:0] s; // S(n)
wire signed [15:0] sc; // s*c
wire signed [7:0] sc_trunc; // s*c truncated to 8 bits

reg [12:0] cnt_reg; // 13 bits to count up to 6250
wire [12:0] cnt_nxt;
wire enable;

reg state, state_nxt;
localparam idle = 1'b0, sample = 1'b1;

// Gen Enable and Counter -- 50 MHz / 8 kHz = 6250
assign enable = (cnt_reg == 13'd6249) ? 1'b1 : 1'b0;
assign cnt_nxt = enable ? 13'd0 : cnt_reg + 1'b1;

always @(posedge AXIS_ACLK or negedge AXIS_ARESETN) begin
    if (!AXIS_ARESETN) begin
        cnt_reg <= 13'd0;
    end else begin
        cnt_reg <= cnt_nxt;
    end
end // always

// AXIS Interface and Sampling
always @(*) begin
    state_nxt = state;
    M_AXIS_TVALID = 1'b0;
    case (state)
        idle: begin
            if (enable) begin
                state_nxt = sample;
            end
        end
        sample: begin
            M_AXIS_TVALID = 1'b1;
            if (M_AXIS_TREADY) begin
                state_nxt = idle;
            end
        end
        default: begin
            state_nxt = idle;
        end
    endcase
end

always @(posedge AXIS_ACLK or negedge AXIS_ARESETN) begin
    if (!AXIS_ARESETN) begin
        state <= idle;
    end else begin
        state <= state_nxt;
    end
end

// Biquad Oscillator
assign sc = s * c; // Multiply s by c
// Take a signed slice to preserve signedness when truncating
assign sc_trunc = $signed(sc[13:6]); // Truncate to 8 bits
//assign sc_trunc = sc >>> 6; // Truncate to 8 bits (arithmetic right shift)
assign x_aux = sc_trunc - y_aux;

always @(posedge AXIS_ACLK or negedge AXIS_ARESETN) begin
    if (!AXIS_ARESETN) begin
        // Reset values
        s     <= 8'sd0;
        y_aux <= -8'sd44; // VHDL's to_signed(-44, 8)
    end else begin
        if (enable == 1'b1) begin
            y_aux <= s;
            s     <= x_aux;
        end
    end
end

// Output assignment
assign M_AXIS_TDATA = s;

endmodule // DOSCI500

