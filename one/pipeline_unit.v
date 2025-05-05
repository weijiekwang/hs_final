module pipeline_unit (
    input  wire         clk,
    input  wire         reset,
    input  wire [31:0]  inputs,
    input  wire         in_valid,
    input  wire         flush,
    output wire [31:0]  outputs, 
    output wire         out_valid
);
    // Define pipeline stages
    reg [31:0] stage1_data;
    reg        stage1_valid;
    reg [31:0] stage2_data;
    reg        stage2_valid;
    reg [31:0] stage3_data;
    reg        stage3_valid;
    
    // Output assignments
    assign outputs = stage3_data;
    assign out_valid = stage3_valid && !flush;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Securely clear all pipeline stages on reset
            stage1_data <= 32'b0;
            stage1_valid <= 1'b0;
            stage2_data <= 32'b0;
            stage2_valid <= 1'b0;
            stage3_data <= 32'b0;
            stage3_valid <= 1'b0;
        end
        else begin
            // Stage 3 (output stage)
            if (flush) begin
                // Secure flush: clear stage data
                stage3_data <= 32'b0;
                stage3_valid <= 1'b0;
            end
            else begin
                stage3_data <= stage2_data;
                stage3_valid <= stage2_valid;
            end
            
            // Stage 2 (middle stage)
            if (flush) begin
                // Secure flush: clear stage data
                stage2_data <= 32'b0;
                stage2_valid <= 1'b0;
            end
            else begin
                stage2_data <= stage1_data;
                stage2_valid <= stage1_valid;
            end
            
            // Stage 1 (input stage)
            if (flush) begin
                // Secure flush: clear stage data
                stage1_data <= 32'b0;
                stage1_valid <= 1'b0;
            end
            else begin
                stage1_data <= in_valid ? inputs : 32'b0;
                stage1_valid <= in_valid;
            end
        end
    end
endmodule