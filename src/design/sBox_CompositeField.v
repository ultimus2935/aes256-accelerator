`timescale 1ns / 1ps

module sBox(
    input wire [7:0] data_in,
    output wire [7:0] data_out
    );

    function [7:0] cfmap_satoh(input [7:0] in);
        begin
            cfmap_satoh = {
                in[7] ^ in[5],
                in[7] ^ in[6] ^ in[4] ^ in[3] ^ in[2] ^ in[1],
                in[7] ^ in[5] ^ in[3] ^ in[2],                 
                in[7] ^ in[5] ^ in[3] ^ in[2] ^ in[1],
                in[7] ^ in[6] ^ in[2] ^ in[1],
                in[7] ^ in[4] ^ in[3] ^ in[2] ^ in[1],
                in[6] ^ in[4] ^ in[1],
                in[6] ^ in[1] ^ in[0]
            };
        end
    endfunction         

    function [1:0] gf22_add(input [1:0] in1, input [1:0] in2); gf22_add = in1 ^ in2; endfunction

    function [1:0] gf22_sq(input [1:0] in); gf22_sq = {in[1], in[1] ^ in[0]}; endfunction

    function [1:0] gf22_mult_phi(input [1:0] in); gf22_mult_phi = {in[1] ^ in[0], in[1]}; endfunction

    function [1:0] gf22_mult(input [1:0] in1, input [1:0] in2);
        gf22_mult = {
            (in1[1] & in2[1]) ^ (in1[1] & in2[0]) ^ (in1[0] & in2[1]),
            (in1[1] & in2[1]) ^ (in1[0] & in2[0])
        };
    endfunction

    function [1:0] gf22_inv(input [1:0] in); gf22_inv = {in[1], in[1] ^ in[0]}; endfunction

    function [3:0] gf24_add(input [3:0] in1, input [3:0] in2); gf24_add = in1 ^ in2; endfunction

    function [3:0] gf24_sq(input [3:0] in);
        gf24_sq = {
            gf22_sq(in[3:2]),
            gf22_add(gf22_mult_phi(gf22_sq(in[3:2])), gf22_sq(in[1:0]))
        };
    endfunction

    function [3:0] gf24_mult_lambda(input [3:0] in);
        gf24_mult_lambda = {
            gf22_mult(2'b11, gf22_add(in[3:2], in[1:0])),
            in[3:2]
        };
    endfunction

    function [3:0] gf24_mult(input [3:0] in1, input [3:0] in2);
        reg [1:0] p0, p1, p2;
        begin
            p0 = gf22_mult(in1[1:0], in2[1:0]);
            p1 = gf22_mult(gf22_add(in1[3:2], in1[1:0]), gf22_add(in2[3:2], in2[1:0]));
            p2 = gf22_mult(in1[3:2], in2[3:2]);

            gf24_mult = {
                gf22_add(p1, p0),
                gf22_add(p0, gf22_mult_phi(p2))
            };
        end
    endfunction
        
    function [1:0] gf24_denom(input [3:0] in);
        gf24_denom = gf22_add(gf22_add(gf22_mult_phi(gf22_sq(in[3:2])), gf22_mult(in[3:2], in[1:0])), gf22_sq(in[1:0]));
    endfunction

    function [3:0] gf24_inv(input [3:0] in);
        reg [1:0] denom_inv;
        begin
            denom_inv = gf22_inv(gf24_denom(in));
            gf24_inv = {
                gf22_mult(denom_inv, in[3:2]),
                gf22_mult(denom_inv, gf22_add(in[3:2], in[1:0]))
            };
        end
    endfunction

    function [3:0] gf28_denom(input [7:0] in);
        gf28_denom = gf24_add(gf24_add(gf24_mult_lambda(gf24_sq(in[7:4])), gf24_mult(in[7:4], in[3:0])), gf24_sq(in[3:0]));
    endfunction

    function [7:0] gf28_inv(input [7:0] in);
        reg [3:0] denom_inv;
        begin
            denom_inv = gf24_inv(gf28_denom(in));
            gf28_inv = {
                gf24_mult(denom_inv, in[7:4]),
                gf24_mult(denom_inv, gf24_add(in[7:4], in[3:0]))
            };
        end
    endfunction

    function [7:0] cfdemap_satoh(input [7:0] in);
        begin
            cfdemap_satoh = {
                in[7] ^ in[6] ^ in[5] ^ in[1],
                in[6] ^ in[2],
                in[6] ^ in[5] ^ in[1],
                in[6] ^ in[5] ^ in[4] ^ in[2] ^ in[1],
                in[5] ^ in[4] ^ in[3] ^ in[2] ^ in[1],
                in[7] ^ in[4] ^ in[3] ^ in[2] ^ in[1],
                in[5] ^ in[4],
                in[6] ^ in[5] ^ in[4] ^ in[2] ^ in[0]
            };
        end
    endfunction

    function [7:0] affine_transform(input [7:0] in);
        begin
            affine_transform = {
                in[7] ^ in[6] ^ in[5] ^ in[4] ^ in[3], 
                in[6] ^ in[5] ^ in[4] ^ in[3] ^ in[2] ^ 1'b1, 
                in[5] ^ in[4] ^ in[3] ^ in[2] ^ in[1] ^ 1'b1, 
                in[4] ^ in[3] ^ in[2] ^ in[1] ^ in[0], 
                in[3] ^ in[2] ^ in[1] ^ in[0] ^ in[7],
                in[2] ^ in[1] ^ in[0] ^ in[7] ^ in[6],
                in[1] ^ in[0] ^ in[7] ^ in[6] ^ in[5] ^ 1'b1,
                in[0] ^ in[7] ^ in[6] ^ in[5] ^ in[4] ^ 1'b1
            };
        end
    endfunction

    assign data_out = affine_transform(cfdemap_satoh(gf28_inv(cfmap_satoh(data_in))));
endmodule