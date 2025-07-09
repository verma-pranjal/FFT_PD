`timescale 1ns / 1ps

module FFT_8pt(
    input clk, reset,
    input [11:0] real_in, imag_in,
    input [2:0] addr_real, addr_imag,
    input wr_en_real, wr_en_imag,
    output [23:0] fft_real_out, fft_imag_out
);
    // Memory Interface
    wire [11:0] mem_real_out, mem_imag_out;
    
    // Parallel Data Buses
    wire [11:0] parallel_real[0:7], parallel_imag[0:7];
    wire [23:0] fft_result_real[0:7], fft_result_imag[0:7];

    // Memory Unit
    FFT_Memory memory_unit (
        .clk(clk),
        .real_in(real_in),
        .imag_in(imag_in),
        .addr_real(addr_real),
        .addr_imag(addr_imag),
        .wr_en_real(wr_en_real),
        .wr_en_imag(wr_en_imag),
        .real_out(mem_real_out),
        .imag_out(mem_imag_out)
    );

    // Serial-to-Parallel Converter
    S2P_Converter s2p_unit (
        .clk(clk),
        .reset(reset),
        .serial_real(mem_real_out),
        .serial_imag(mem_imag_out),
        .parallel_real_0(parallel_real[0]), .parallel_imag_0(parallel_imag[0]),
        .parallel_real_1(parallel_real[1]), .parallel_imag_1(parallel_imag[1]),
        .parallel_real_2(parallel_real[2]), .parallel_imag_2(parallel_imag[2]),
        .parallel_real_3(parallel_real[3]), .parallel_imag_3(parallel_imag[3]),
        .parallel_real_4(parallel_real[4]), .parallel_imag_4(parallel_imag[4]),
        .parallel_real_5(parallel_real[5]), .parallel_imag_5(parallel_imag[5]),
        .parallel_real_6(parallel_real[6]), .parallel_imag_6(parallel_imag[6]),
        .parallel_real_7(parallel_real[7]), .parallel_imag_7(parallel_imag[7])
    );

    // FFT Processing Core
    FFT_Engine fft_core (
        .in0_real(parallel_real[0]), .in0_imag(parallel_imag[0]),
        .in1_real(parallel_real[1]), .in1_imag(parallel_imag[1]),
        .in2_real(parallel_real[2]), .in2_imag(parallel_imag[2]),
        .in3_real(parallel_real[3]), .in3_imag(parallel_imag[3]),
        .in4_real(parallel_real[4]), .in4_imag(parallel_imag[4]),
        .in5_real(parallel_real[5]), .in5_imag(parallel_imag[5]),
        .in6_real(parallel_real[6]), .in6_imag(parallel_imag[6]),
        .in7_real(parallel_real[7]), .in7_imag(parallel_imag[7]),
        .out0_real(fft_result_real[0]), .out0_imag(fft_result_imag[0]),
        .out1_real(fft_result_real[1]), .out1_imag(fft_result_imag[1]),
        .out2_real(fft_result_real[2]), .out2_imag(fft_result_imag[2]),
        .out3_real(fft_result_real[3]), .out3_imag(fft_result_imag[3]),
        .out4_real(fft_result_real[4]), .out4_imag(fft_result_imag[4]),
        .out5_real(fft_result_real[5]), .out5_imag(fft_result_imag[5]),
        .out6_real(fft_result_real[6]), .out6_imag(fft_result_imag[6]),
        .out7_real(fft_result_real[7]), .out7_imag(fft_result_imag[7])
    );

    // Parallel-to-Serial Converter
    P2S_Converter p2s_unit (
        .clk(clk),
        .reset(reset),
        .parallel_real_0(fft_result_real[0]), .parallel_imag_0(fft_result_imag[0]),
        .parallel_real_1(fft_result_real[1]), .parallel_imag_1(fft_result_imag[1]),
        .parallel_real_2(fft_result_real[2]), .parallel_imag_2(fft_result_imag[2]),
        .parallel_real_3(fft_result_real[3]), .parallel_imag_3(fft_result_imag[3]),
        .parallel_real_4(fft_result_real[4]), .parallel_imag_4(fft_result_imag[4]),
        .parallel_real_5(fft_result_real[5]), .parallel_imag_5(fft_result_imag[5]),
        .parallel_real_6(fft_result_real[6]), .parallel_imag_6(fft_result_imag[6]),
        .parallel_real_7(fft_result_real[7]), .parallel_imag_7(fft_result_imag[7]),
        .serial_real(fft_real_out),
        .serial_imag(fft_imag_out)
    );
endmodule

module FFT_Memory(
    input clk,
    input [11:0] real_in, imag_in,
    input [2:0] addr_real, addr_imag,
    input wr_en_real, wr_en_imag,
    output [11:0] real_out, imag_out
);
    reg [11:0] real_mem [0:7];
    reg [11:0] imag_mem [0:7];
    reg [2:0] read_addr_real, read_addr_imag;

    always @(posedge clk) begin
        if(wr_en_real) real_mem[addr_real] <= real_in;
        else read_addr_real <= addr_real;
        
        if(wr_en_imag) imag_mem[addr_imag] <= imag_in;
        else read_addr_imag <= addr_imag;
    end

    assign real_out = real_mem[read_addr_real];
    assign imag_out = imag_mem[read_addr_imag];
endmodule

module S2P_Converter(
    input clk, reset,
    input [11:0] serial_real, serial_imag,
    output [11:0] parallel_real_0, parallel_imag_0,
    output [11:0] parallel_real_1, parallel_imag_1,
    output [11:0] parallel_real_2, parallel_imag_2,
    output [11:0] parallel_real_3, parallel_imag_3,
    output [11:0] parallel_real_4, parallel_imag_4,
    output [11:0] parallel_real_5, parallel_imag_5,
    output [11:0] parallel_real_6, parallel_imag_6,
    output [11:0] parallel_real_7, parallel_imag_7
);
    reg [3:0] counter;
    reg [11:0] real_shift_reg [0:7];
    reg [11:0] imag_shift_reg [0:7];
    integer i;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            counter <= 0;
            for(i=0; i<8; i=i+1) begin
                real_shift_reg[i] <= 0;
                imag_shift_reg[i] <= 0;
            end
        end else if(counter < 8) begin
            for(i=7; i>0; i=i-1) begin
                real_shift_reg[i] <= real_shift_reg[i-1];
                imag_shift_reg[i] <= imag_shift_reg[i-1];
            end
            real_shift_reg[0] <= serial_real;
            imag_shift_reg[0] <= serial_imag;
            counter <= counter + 1;
        end
    end

    assign parallel_real_0 = real_shift_reg[7];
    assign parallel_imag_0 = imag_shift_reg[7];
    assign parallel_real_1 = real_shift_reg[6];
    assign parallel_imag_1 = imag_shift_reg[6];
    assign parallel_real_2 = real_shift_reg[5];
    assign parallel_imag_2 = imag_shift_reg[5];
    assign parallel_real_3 = real_shift_reg[4];
    assign parallel_imag_3 = imag_shift_reg[4];
    assign parallel_real_4 = real_shift_reg[3];
    assign parallel_imag_4 = imag_shift_reg[3];
    assign parallel_real_5 = real_shift_reg[2];
    assign parallel_imag_5 = imag_shift_reg[2];
    assign parallel_real_6 = real_shift_reg[1];
    assign parallel_imag_6 = imag_shift_reg[1];
    assign parallel_real_7 = real_shift_reg[0];
    assign parallel_imag_7 = imag_shift_reg[0];
endmodule

module FFT_Engine(
    input [11:0] in0_real, in0_imag,
    input [11:0] in1_real, in1_imag,
    input [11:0] in2_real, in2_imag,
    input [11:0] in3_real, in3_imag,
    input [11:0] in4_real, in4_imag,
    input [11:0] in5_real, in5_imag,
    input [11:0] in6_real, in6_imag,
    input [11:0] in7_real, in7_imag,
    output [23:0] out0_real, out0_imag,
    output [23:0] out1_real, out1_imag,
    output [23:0] out2_real, out2_imag,
    output [23:0] out3_real, out3_imag,
    output [23:0] out4_real, out4_imag,
    output [23:0] out5_real, out5_imag,
    output [23:0] out6_real, out6_imag,
    output [23:0] out7_real, out7_imag
);
    // Stage 1 Signals
    wire [12:0] s1_0r, s1_0i, s1_1r, s1_1i;
    
    // Stage 1 Butterfly
    Butterfly_Stage1 bf1_0(
        .in_real_a(in0_real), .in_imag_a(in0_imag),
        .in_real_b(in4_real), .in_imag_b(in4_imag),
        .sum_real(s1_0r), .sum_imag(s1_0i),
        .diff_real(s1_1r), .diff_imag(s1_1i)
    );

    // Add other stages similarly...

    // Final Output Assignment
    assign out0_real = s1_0r << 11; // Scaling
    assign out0_imag = s1_0i << 11;
    // Connect other outputs...
endmodule

module Butterfly_Stage1(
    input [11:0] in_real_a, in_imag_a,
    input [11:0] in_real_b, in_imag_b,
    output [12:0] sum_real, sum_imag,
    output [12:0] diff_real, diff_imag
);
    assign sum_real = in_real_a + in_real_b;
    assign sum_imag = in_imag_a + in_imag_b;
    assign diff_real = in_real_a - in_real_b;
    assign diff_imag = in_imag_a - in_imag_b;
endmodule

module P2S_Converter(
    input clk, reset,
    input [23:0] parallel_real_0, parallel_imag_0,
    input [23:0] parallel_real_1, parallel_imag_1,
    input [23:0] parallel_real_2, parallel_imag_2,
    input [23:0] parallel_real_3, parallel_imag_3,
    input [23:0] parallel_real_4, parallel_imag_4,
    input [23:0] parallel_real_5, parallel_imag_5,
    input [23:0] parallel_real_6, parallel_imag_6,
    input [23:0] parallel_real_7, parallel_imag_7,
    output reg [23:0] serial_real, serial_imag
);
    reg [2:0] count;

    always @(posedge clk or posedge reset) begin
        if(reset) count <= 0;
        else count <= (count == 7) ? 0 : count + 1;
    end

    always @(*) begin
        case(count)
            0: begin serial_real = parallel_real_0; serial_imag = parallel_imag_0; end
            1: begin serial_real = parallel_real_1; serial_imag = parallel_imag_1; end
            2: begin serial_real = parallel_real_2; serial_imag = parallel_imag_2; end
            3: begin serial_real = parallel_real_3; serial_imag = parallel_imag_3; end
            4: begin serial_real = parallel_real_4; serial_imag = parallel_imag_4; end
            5: begin serial_real = parallel_real_5; serial_imag = parallel_imag_5; end
            6: begin serial_real = parallel_real_6; serial_imag = parallel_imag_6; end
            7: begin serial_real = parallel_real_7; serial_imag = parallel_imag_7; end
        endcase
    end
endmodule
