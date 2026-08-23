module standardRound(
    input wire clk, rst, 
    input wire [127:0] data_in,
    input wire [127:0] round_key,
    output reg [127:0] data_out
);
    wire [127:0] subBytes_out;
    wire [127:0] shiftRows_out;

    subBytesLUT subBytesLUT(
        .data_in(data_in),
        .data_out(subBytes_out)
    );

    shiftRows shiftRows(
        .data_in(subBytes_out),
        .data_out(shiftRows_out)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) data_out <= 128'b0;
        else data_out <= shiftRows_out ^ round_key;
    end

endmodule