`timescale 1ns / 1ps

module top (
    input  wire       sys_clk,
    input  wire       sys_rst_n,
	
	input  wire [1:0] btn, 

    output wire       vga_hsync,  
    output wire       vga_vsync, 
    output wire [2:0] vga_rgb
);

	// VGA clock devider
    logic pixel_clk;
    always_ff @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            pixel_clk <= 1'b0;
        end else begin
            pixel_clk <= ~pixel_clk;
        end
    end

    VGA vga_controller (
        .clk 	(pixel_clk),
        .rst_n	(sys_rst_n),
        
        .hsync (vga_hsync),
        .vsync (vga_vsync),
        .RGB   (vga_rgb)
    );
	
	wire [1:0] cntrl_btn;
	debouncer debouncer_1 (
		.clk		 (sys_clk),
		.rst_n  	 (sys_rst_n),
		
		.btn_in 	 (btn[0]),
		.btn_pressed (cntrl_btn[0])
	);
	
	debouncer debouncer_2 (
		.clk		 (sys_clk),
		.rst_n  	 (sys_rst_n),
		
		.btn_in 	 (btn[1]),
		.btn_pressed (cntrl_btn[1])
	);
endmodule