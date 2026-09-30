module tb_aes256_core;
    reg clk, rst;
    reg [255:0] base_key;
    reg [127:0] data_in;
    wire [127:0] data_out;

    aes256_core uut (
        .clk (clk),
        .rst (rst),
        .base_key (base_key),
        .data_in (data_in),
        .data_out (data_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    initial begin
        rst = 1;
        // base_key = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f; // FIPS 197 Key
        base_key = 256'h603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4; // NIST SP 800-38A Key
        #20 rst = 0;

        #520; // Wait 52 cycles for key expansion to complete

        // data_in = 128'h00112233445566778899aabbccddeeff; // FIPS 197 Test Vector
        data_in = 128'h6bc1bee22e409f96e93d7e117393172a; // NIST SP 800-38A Test Vector
        #10 data_in = 128'hae2d8a571e03ac9c9eb76fac45af8e51; // NIST SP 800-38A Test Vector
        #10 data_in = 128'h30c81c46a35ce411e5fbc1191a0a52ef; // NIST SP 800-38A Test Vector
        #10 data_in = 128'hf69f2445df4f9b17ad2b417be66c3710; // NIST SP 800-38A Test Vector

        #150; // Wait 15 cycles for pipeline to complete

        #10 $finish;
    end
endmodule 