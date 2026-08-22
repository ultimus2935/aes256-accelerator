module mixColumns(
    input wire [127:0] data_in,
    output wire [127:0] data_out
);
    function [7:0] gf28_mult2(input [7:0] in); 
        gf28_mult2 = in[7] ? ((in << 1) ^ 8'h1B) : (in << 1);
    endfunction

    function [7:0] 
        gf28_mult3(input [7:0] in); gf28_mult3 = gf28_mult2(in) ^ in; 
    endfunction

    function [31:0] column_mixer(input [31:0] column);
        reg [7:0] r0, r1, r2, r3;
        begin
            r0 = column[31:24];
            r1 = column[23:16];
            r2 = column[15:8];
            r3 = column[7:0];

            column_mixer = {
                gf28_mult2(r0) ^ gf28_mult3(r1) ^ r2 ^ r3,
                r0 ^ gf28_mult2(r1) ^ gf28_mult3(r2) ^ r3,
                r0 ^ r1 ^ gf28_mult2(r2) ^ gf28_mult3(r3),
                gf28_mult3(r0) ^ r1 ^ r2 ^ gf28_mult2(r3)
            };
        end
    endfunction

    assign data_out = {
            column_mixer(data_in[127:96]),
            column_mixer(data_in[95:64]),
            column_mixer(data_in[63:32]),
            column_mixer(data_in[31:0])
        };
endmodule