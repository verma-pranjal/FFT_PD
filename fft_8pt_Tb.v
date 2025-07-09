`timescale 1ns / 1ps

module FFT_8pt_TB;

    // Clock and reset
    reg clk, rst;

    // Inputs
    reg [11:0] real_in, imag_in;
    reg [2:0] addr_real, addr_imag;
    reg wr_real, wr_imag;

    // Outputs
    wire [23:0] fft_real, fft_imag;

    // Integer for loop (declared outside as required by Verilog-2005)
    integer i;

    // Instantiate DUT
    FFT_8pt uut (
        .clk(clk),
        .reset(rst),
        .real_in(real_in),
        .imag_in(imag_in),
        .addr_real(addr_real),
        .addr_imag(addr_imag),
        .wr_en_real(wr_real),
        .wr_en_imag(wr_imag),
        .fft_real_out(fft_real),
        .fft_imag_out(fft_imag)
    );

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset pulse
    initial begin
        rst = 1;
        #20 rst = 0;
        #10 rst = 1;
        #10 rst = 0;
    end

    // Stimulus
    initial begin
        // Initialize
        real_in = 0; imag_in = 0;
        addr_real = 0; addr_imag = 0;
        wr_real = 0; wr_imag = 0;
        
        #50;

        // Write inputs
        wr_real = 1;
        wr_imag = 1;

        for (i = 0; i < 8; i = i + 1) begin
            addr_real = i[2:0];
            addr_imag = i[2:0];
            real_in = $random & 12'hFFF;
            imag_in = $random & 12'hFFF;
            #10;
        end

        wr_real = 0;
        wr_imag = 0;

        // Wait and finish
        #500;
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("fft_waves.vcd");
        $dumpvars(0, FFT_8pt_TB);
    end

endmodule
