module flush_mgmt (
    input  wire clk,
    input  wire reset,
    input  wire flush_mgmt_input,
    output reg  flush_mgmt_output
);
    // For staged pipelined flush, add delay
    reg flush_delay;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            flush_mgmt_output <= 1'b0;
            flush_delay <= 1'b0;
        end
        else begin
            // Pipelined flush with one cycle delay
            flush_delay <= flush_mgmt_input;
            flush_mgmt_output <= flush_delay;
            
            // Ensure flush is properly asserted even during reset recovery
            if (reset) begin
                flush_mgmt_output <= 1'b1;
            end
        end
    end
endmodule