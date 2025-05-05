module pipeline_wrapped (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] pipeline1_inputs,
    input  wire [31:0] pipeline2_inputs,
    input  wire [1:0]  in_valid,
    input  wire        flush_1,
    input  wire        flush_2,
    output wire [31:0] pipeline1_outputs,
    output wire [31:0] pipeline2_outputs,
    output wire [1:0]  out_valid
);

    // Internal signals for arbiter requests and grants
    wire arbiter_req_1;
    wire arbiter_req_2;
    wire arbiter_grant_1;
    wire arbiter_grant_2;

    // Signals for pipelines to communicate with shared resource
    wire [31:0] resource_input_1;
    wire [31:0] resource_input_2;
    wire [31:0] resource_output;

    // Instantiate arbiter
    arbiter arbiter_inst (
        .clk      (clk),
        .reset    (reset),
        .req_1    (arbiter_req_1),
        .req_2    (arbiter_req_2),
        .grant_1  (arbiter_grant_1),
        .grant_2  (arbiter_grant_2)
    );

    // Instantiate shared resource
    shared_resource shared_resource_inst (
        .clk             (clk),
        .reset           (reset),
        .resource_input  (arbiter_grant_1 ? resource_input_1 : resource_input_2),
        .resource_output (resource_output)
    );

    wire _in_valid_1, _out_valid_1;
    wire _in_valid_2, _out_valid_2;

    // Assign and manage valid signals
    assign _in_valid_1 = in_valid[0]; 
    assign _out_valid_1 = out_valid[0];
    assign _in_valid_2 = in_valid[1]; 
    assign _out_valid_2 = out_valid[1];

    // Instantiate pipeline 1
    pipeline_top pipeline_1 (
        .clk      (clk),
        .reset    (reset),
        .inputs   (pipeline1_inputs),
        .in_valid (_in_valid_1)
        .flush    (flush_1),
        .outputs  (pipeline1_outputs),
        .out_valid(_out_valid_1),
        .arbiter_req      (arbiter_req_1),
        .arbiter_grant    (arbiter_grant_1),
        .resource_input   (resource_input_1),
        .resource_output  (resource_output)
    );

    // Instantiate pipeline 2
    pipeline_top pipeline_2 (
        .clk      (clk),
        .reset    (reset),
        .inputs   (pipeline2_inputs),
        .in_valid (_in_valid_2)
        .flush    (flush_2),
        .outputs  (pipeline2_outputs),
        .out_valid(_out_valid_2),
        .arbiter_req      (arbiter_req_2),
        .arbiter_grant    (arbiter_grant_2),
        .resource_input   (resource_input_2),
        .resource_output  (resource_output)
    );

endmodule