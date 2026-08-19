`timescale 1ns / 1ps

module tb_sBox_CompositeField();
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

        rst = 0; enable = 1;
        #10;

        // Apply first input
        data_in = 8'hAA; 
        #20; // Wait for the next clock edge
        
        // Apply second input
        data_in = 8'hBA; 
        #20; 
        
        // Apply third input
        data_in = 8'hCE; 
        #20; 
    
        // Apply fourth input
        data_in = 8'h56; 
        #20; 
    
        // Apply fifth input
        data_in = 8'h9D; 
        #20;

        #50 $finish;
    end
endmodule