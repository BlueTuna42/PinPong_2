`timescale 1ns / 1ps

module top (
    input  wire       sys_clk,
    input  wire       sys_rst_n,

    output wire       vga_hsync,  
    output wire       vga_vsync, 
    output wire [2:0] vga_rgb
);

    logic pixel_clk;
    always_ff @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            pixel_clk <= 1'b0;
        end else begin
            pixel_clk <= ~pixel_clk;
        end
    end

    VGA vga_controller (
        .clk   (pixel_clk),
        .rst_n (sys_rst_n),
        
        .hsync (vga_hsync),
        .vsync (vga_vsync),
        .RGB   (vga_rgb)
    );

endmodule