`timescale 1ns / 1ps

module sBox(
    input clk, rst, enable,
    input [7:0] data_in,
    output reg [7:0] data_out
    );

    reg [7:0] sbox_lut [0:255];
    wire [7:0] async_data;

    initial $readmemh("sbox_lut.mem", sbox_lut);

    assign async_data = sbox_lut[data_in];

    always @(posedge clk or posedge rst) begin
        if (rst) data_out <= 8'b0;
        else if (enable) data_out <= async_data;
    end
endmodule