module key_expansion(
    input wire clk, rst,
    input wire [255:0] base_key,
    output wire [1919:0] round_key_out,
    output wire key_ready
);
    wire [31:0] key_words [0:59];
    reg  [31:0] key_words_reg [8:59];

    function [31:0] rotWord(input [31:0] in); rotWord = {in[23:0], in[31:24]}; endfunction

    reg [7:0] sbox_lut [0:255];
    initial $readmemh("sbox_lut.mem", sbox_lut);

    function [31:0] subWord(input [31:0] in); for (integer i = 0; i < 4; i = i + 1) subWord[i*8 +: 8] = sbox_lut[in[i*8 +: 8]]; endfunction

    reg [31:0] rcon_lut [0:7];
    initial $readmemh("rcon_lut.mem", rcon_lut);

    genvar j;
    generate
        for (j = 0; j < 8; j = j + 1) begin : base_key_words
            assign key_words[j] = base_key[255 - j*32 -: 32];
        end
        for (j = 8; j < 60; j = j + 1) begin : reg_key_words_map
            assign key_words[j] = key_words_reg[j];
        end
    endgenerate

    reg [6:0] i; // word index
    always @(posedge clk or posedge rst) begin
        if (rst) i <= 8;
        else if (i < 60) begin
            case (i % 8)
                0: key_words_reg[i] <= key_words[i-8] ^ subWord(rotWord(key_words[i-1])) ^ rcon_lut[i[5:3]]; // i[5:3] is binary division by 8
                4: key_words_reg[i] <= key_words[i-8] ^ subWord(key_words[i-1]);
                default: key_words_reg[i] <= key_words[i-8] ^ key_words[i-1];
            endcase
            
            i <= i + 1;
        end
    end

    assign key_ready = (i > 59);

    genvar k;
    generate
        for (k = 0; k < 15; k = k + 1) begin : gen_round_keys
            assign round_key_out[k*128 +: 128] = {key_words[k*4], key_words[k*4 + 1], key_words[k*4 + 2], key_words[k*4 + 3]};
        end
    endgenerate
endmodule