module buffer_slots (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] inputs,
    input  wire        stall,
    output reg  [31:0] outputs,
    output wire        to_stall_mgmt
);
    // Regular slot and overflow slot
    reg [31:0] main_slot;
    reg [31:0] overflow_slot;
    reg        overflow_valid;
    
    // Signal to indicate if overflow is active
    assign to_stall_mgmt = overflow_valid;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Securely clear all storage on reset
            main_slot <= 32'b0;
            overflow_slot <= 32'b0;
            overflow_valid <= 1'b0;
            outputs <= 32'b0;
        end
        else begin
            if (stall) begin
                // If stalled, store incoming data in overflow slot
                overflow_slot <= inputs;
                overflow_valid <= 1'b1;
                // Main slot and output remain unchanged
            end
            else begin
                // Not stalled
                if (overflow_valid) begin
                    // First use data from overflow slot
                    main_slot <= overflow_slot;
                    outputs <= overflow_slot;
                    
                    // Clear overflow slot securely
                    overflow_slot <= 32'b0;
                    overflow_valid <= 1'b0;
                end
                else begin
                    // Normal operation
                    main_slot <= inputs;
                    outputs <= inputs;
                end
            end
        end
    end
endmodule