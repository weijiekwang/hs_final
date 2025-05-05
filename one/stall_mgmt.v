module stall_mgmt (
    input  wire clk,
    input  wire reset,
    input  wire stall_input,    // Incoming stall signal (e.g., from arbiter)
    input  wire to_stall_mgmt,  // Feedback from buffer about its status
    output reg  stall_output    // Stall signal to propagate
);
    // Parameter to select stall strategy
    parameter GLOBAL_STALL = 1'b1; // Set to 0 for pipelined stall
    
    // For global stall, directly propagate stall signal
    // For pipelined stall, we'll add a cycle delay
    
    reg stall_delay; // For pipelined stall
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            stall_output <= 1'b0;
            stall_delay <= 1'b0;
        end
        else begin
            if (GLOBAL_STALL) begin
                // Global stall: direct propagation
                stall_output <= stall_input | to_stall_mgmt;
            end
            else begin
                // Pipelined stall: delayed propagation
                stall_delay <= stall_input | to_stall_mgmt;
                stall_output <= stall_delay;
            end
        end
    end
endmodule