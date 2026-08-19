`timescale 1ns / 1ps

module tb_sBox();
    reg clk, rst, enable;
    reg [7:0] data_in;

    wire [7:0] data_out;

    sBox uut(
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .data_in(data_in),
        .data_out(data_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        rst = 1;
        enable = 0;
        data_in = 8'h00;
        #10

        rst = 0; 
        
        data_in = 8'hAA; 
        #5; 

        enable = 1;
        #5;
        
        data_in = 8'hBA; 
        #10; 
        
        data_in = 8'hCE; 
        #10; 

        data_in = 8'h56; 
        #10; 

        data_in = 8'h9D; 
        #10;

        $finish;
    end
endmodule