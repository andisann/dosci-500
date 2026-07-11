module TX115(
    input        AXIS_ARESETN, // Active-low reset
    input        AXIS_ACLK,    // 50 MHz Clock
    input signed [7:0] S_AXIS_TDATA, 
    input        S_AXIS_TVALID,
    output       S_AXIS_TREADY,
    output       TX_232        // 115200 bps serial line
);

    // Baud Rate Enable (Adapted for 50 MHz: 50MHz / 115200 = 434 total states, error of 0.0064%)
    localparam [8:0] MAX_COUNT = 9'd433;
    reg [8:0] cnt;
    wire [8:0] cnt_sig;
    wire en;

    // Load and Shift Registers (10 bits to hold: 1 stop bit + 8 data bits + 1 start bit)
    reg [9:0] dato_r;
    wire [9:0] n_dato_r;
    reg [9:0] q_r;
    wire [9:0] q_sig;

    // 1. Baud Rate Timing Logic
    assign en = (cnt >= MAX_COUNT) ? 1'b1 : 1'b0;
    assign cnt_sig = en ? 9'd0 : (cnt + 1'b1);

    always @(posedge AXIS_ACLK or negedge AXIS_ARESETN) begin
        if (!AXIS_ARESETN) begin
            cnt <= 9'd0;
        end else begin
            cnt <= cnt_sig;
        end
    end

    // 2. Load Register Logic (dato_r)
    // Combines the 1-bit stop bit ('1'), 8-bit data, and 1-bit start bit ('0')
    assign n_dato_r = (S_AXIS_TVALID && dato_r[0]) ? {1'b1, S_AXIS_TDATA, 1'b0} :
                      ((q_r == 10'd1) && en)       ? 10'd1 :
                                                     dato_r;

    always @(posedge AXIS_ACLK or negedge AXIS_ARESETN) begin
        if (!AXIS_ARESETN) begin
            dato_r <= 10'd1;
        end else begin
            dato_r <= n_dato_r;
        end
    end

    // 3. Transmission Shift Register Logic (q_r)
    assign q_sig = (q_r == 10'd1) ? dato_r : {1'b0, q_r[9:1]};

    always @(posedge AXIS_ACLK or negedge AXIS_ARESETN) begin
        if (!AXIS_ARESETN) begin
            q_r <= 10'd1;
        end else begin
            if (en) begin
                q_r <= q_sig;
            end
        end
    end

    // 4. Output Assignments
    assign S_AXIS_TREADY = dato_r[0];
    assign TX_232        = q_r[0];

endmodule //tx115
