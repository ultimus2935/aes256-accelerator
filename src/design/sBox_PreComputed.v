`timescale 1ns / 1ps

module sBox(
    input wire [127:0] data_in,
    output wire [127:0] data_out
    );

    reg [7:0] sbox_lut [0:255];
    wire [7:0] async_data;

    initial $readmemh("sbox_lut.mem", sbox_lut);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin: gen_sbox
            assign data_out[i*8 +: 8] = sbox_lut[data_in[i*8 +: 8]];
        end
    endgenerate
endmodule