module sreset(
    input clk,
    input rst_n,
    output AXIS_ARESETN
);

reg rst_mid, rst_end;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rst_mid <= 1'b0;
        rst_end <= 1'b0;
    end else begin
        rst_end <= rst_mid;
        rst_mid <= 1'b1; 
    end
end

assign AXIS_ARESETN = rst_end;

endmodule // sreset
