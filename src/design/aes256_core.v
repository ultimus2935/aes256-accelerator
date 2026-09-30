module aes256_core (
    input wire clk, rst,
    input wire [255:0] base_key,
    input wire [127:0] data_in,
    output wire [127:0] data_out
);
    wire [1919:0] round_key_out;
    wire key_ready;

    key_expansion u_key_expansion(
        .clk(clk),
        .rst(rst),
        .base_key(base_key),
        .round_key_out(round_key_out),
        .key_ready(key_ready)
    );

    reg  [127:0] pipe_reg_0;
    wire [127:0] pipe [0:13];

    assign pipe[0] = pipe_reg_0;

    always @(posedge clk or posedge rst) begin
        if (rst) pipe_reg_0 <= 128'b0;
        else if (key_ready) pipe_reg_0 <= data_in ^ round_key_out[127:0];
    end

    genvar i;
    generate
        for (i = 1; i < 14; i = i + 1) begin : gen_std_rounds
            standard_round u_standard_round(
                .clk(clk),
                .rst(rst),
                .data_in(pipe[i-1]),
                .round_key(round_key_out[i*128 +: 128]),
                .data_out(pipe[i])
            );
        end
    endgenerate

    final_round u_final_round(
        .clk(clk),
        .rst(rst),
        .data_in(pipe[13]),
        .round_key(round_key_out[14*128 +: 128]),
        .data_out(data_out)
    );
endmodule
