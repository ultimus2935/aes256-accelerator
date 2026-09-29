module standard_round(
    input wire clk, rst, 
    input wire [127:0] round_key,
    input wire [127:0] data_in,
    output reg [127:0] data_out
);
    wire [127:0] sub_bytes_out;
    wire [127:0] shift_rows_out;
    wire [127:0] mix_columns_out;

    sub_bytes_lut sub_bytes_lut(
        .data_in(data_in),
        .data_out(sub_bytes_out)
    );

    shift_rows shift_rows(
        .data_in(sub_bytes_out),
        .data_out(shift_rows_out)
    );

    mix_columns mix_columns(
        .data_in(shift_rows_out),
        .data_out(mix_columns_out)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) data_out <= 128'b0;
        else data_out <= mix_columns_out ^ round_key;
    end
endmodule