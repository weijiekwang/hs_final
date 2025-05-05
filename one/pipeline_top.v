module pipeline_top (
    input  wire         clk,
    input  wire         reset,
    input  wire [31:0]  inputs,
    input  wire         in_valid,
    input  wire         flush,
    output wire [31:0]  outputs,
    output wire         out_valid,
    output wire         arbiter_req,
    input  wire         arbiter_grant,
    output wire [31:0]  resource_input,
    input  wire [31:0]  resource_output
);

    wire [31:0] pipeline_unit_outputs;
    wire stall_signal;
    wire to_stall_mgmt_signal;
    wire _in_valid, _out_valid;

    // Assign and manage valid signals
    assign _in_valid = in_valid && !stall_signal;
    assign out_valid = _out_valid && !stall_signal;
    
    // Generate arbiter request when pipeline has valid data
    assign arbiter_req = _out_valid;
    
    // Connect pipeline output to resource input
    assign resource_input = pipeline_unit_outputs;

    pipeline_unit pipeline_unit_inst (
        .clk      (clk),
        .reset    (reset),
        .inputs   (inputs),
        .in_valid (_in_valid),
        .flush    (flush),
        .outputs  (pipeline_unit_outputs),
        .out_valid(_out_valid)
    );

    buffer_slots buffer_slots_inst (
        .clk           (clk),
        .reset         (reset),
        .inputs        (pipeline_unit_outputs),
        .stall         (stall_signal),
        .outputs       (outputs),
        .to_stall_mgmt (to_stall_mgmt_signal)
    );

    stall_mgmt stall_mgmt_inst (
        .clk           (clk),
        .reset         (reset),
        .stall_input   (!arbiter_grant && arbiter_req),
        .to_stall_mgmt (to_stall_mgmt_signal),
        .stall_output  (stall_signal)
    );

    flush_mgmt flush_mgmt_inst (
        .clk               (clk),
        .reset             (reset),
        .flush_mgmt_input  (flush),
        .flush_mgmt_output () // Connect as necessary to pipeline stages if needed
    );
endmodule