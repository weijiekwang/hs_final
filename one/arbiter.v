module arbiter (
    input  wire clk,
    input  wire reset,
    input  wire req_1,
    input  wire req_2,
    output reg  grant_1,
    output reg  grant_2
);
    // State to remember whose turn it is next
    reg priority_to_1;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset to a secure state - no grants active
            grant_1 <= 1'b0;
            grant_2 <= 1'b0;
            priority_to_1 <= 1'b1; // Start with priority to pipeline 1
        end
        else begin
            // Default state - no grants
            grant_1 <= 1'b0;
            grant_2 <= 1'b0;
            
            // Round robin arbitration
            if (req_1 && req_2) begin
                // Both requesting - use priority
                if (priority_to_1) begin
                    grant_1 <= 1'b1;
                    priority_to_1 <= 1'b0; // Give priority to pipeline 2 next
                end
                else begin
                    grant_2 <= 1'b1;
                    priority_to_1 <= 1'b1; // Give priority to pipeline 1 next
                end
            end
            else begin
                // Single request or no requests
                if (req_1) begin
                    grant_1 <= 1'b1;
                    // Don't change priority on single request
                end
                else if (req_2) begin
                    grant_2 <= 1'b1;
                    // Don't change priority on single request
                end
                // If no requests, both grants remain 0
            end
        end
    end
endmodule