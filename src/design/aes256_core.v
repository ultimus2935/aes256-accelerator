module aes256_core (
    input  wire clk, rst,
    input  wire [255:0] base_key,
    input  wire [127:0] data_in,
    output wire [127:0] data_out
);
    wire [127:0] round_key_out [0:14];
    wire key_ready;

    keyExpansion u_keyExpansion(
        .clk (clk),
        .rst (rst),
        .base_key (base_key),
        .round_key_out (round_key_out),
        .key_ready (key_ready)
    );

    reg [127:0] pipe [0:13];

    always @(posedge clk or posedge rst) begin
        if (rst) pipe[0] <= 128'b0;
        else if (key_ready) pipe[0] <= data_in ^ round_key_out[0];
    end

    genvar i;
    generate
        for (i = 1; i < 14; i = i + 1) begin : gen_std_rounds
            standardRound u_stdRound(
                .clk (clk),
                .rst (rst),
                .data_in (pipe[i-1]),
                .round_key (round_key_out[i]),
                .data_out (pipe[i])
            );
        end
    endgenerate

    finalRound u_finalRound(
        .clk (clk),
        .rst (rst),
        .data_in (pipe[13]),
        .round_key (round_key_out[14]),
        .data_out (data_out)
    );
endmodule
