`timescale 1ns / 1ps

module sBox(
    input wire [7:0] data_in,
    output wire [7:0] data_out
    );

    reg [7:0] sbox_lut [0:255];
    wire [7:0] async_data;

    initial $readmemh("sbox_lut.mem", sbox_lut);

    assign data_out = sbox_lut[data_in];
endmodule