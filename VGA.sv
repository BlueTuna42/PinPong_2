module VGA (
    input wire          clk,
    input wire          rst_n,
//    input wire [9:0]    x,
//    input wire [9:0]    y,
    
    output logic        hsync,
    output logic        vsync,
    output logic [2:0]  RGB
//    output logic        vga_clk
);

    logic [10:0]        hpos;
    logic [9:0]         vpos;

    typedef enum logic [2:0] {
        ST_IDLE         = 3'b000,
        ST_FRAME        = 3'b001,
        ST_HBLANK       = 3'b010,
        ST_VBLANK       = 3'b011
    } state_t;
    
    always_ff @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            hpos <= 1'd1;
            vpos <= 1'd1;
        end else begin
            if (hpos == 1040) begin
                hpos <= 1;
                
                if (vpos == 666)
                    vpos <= 1;
                else
                    vpos <= vpos + 1'd1;
            end else begin
                hpos <= hpos + 1'd1;
            end
        end  
    end
    
    state_t current_state, next_state;
    
    always_ff @(posedge clk or posedge rst_n) begin
        if (rst_n)
            current_state <= ST_IDLE;
        else
            current_state <= next_state;
    end

    always_comb begin
        hsync = 1;
        vsync = 1;
        RGB = 3'b000;
        next_state = current_state;
        
        case (current_state)
            ST_IDLE: begin
                
                hsync <= 1;
                vsync <= 1;
                                            next_state = ST_FRAME;
            end
            
            ST_FRAME: begin
                RGB = 3'b011;
                
                if      (hpos == 800)       next_state = ST_HBLANK;
                else                        next_state = ST_FRAME;
            end
            
            ST_HBLANK: begin
                if (hpos >= 856 & hpos <= 976)
                    hsync = 1'd0;
                else
                    hsync = 1'd1;
                   
                if      (vpos >= 600)       next_state = ST_VBLANK;
                else if (hpos == 1040)      next_state = ST_FRAME;
                else                        next_state = ST_HBLANK;
            end
           
            ST_VBLANK: begin
                if (vpos >= 637 & vpos <= 643)
                    vsync <= 0;
                else 
                    vsync <= 1;
                     
                if      (hpos == 800)       next_state = ST_HBLANK;
                else                        next_state = ST_VBLANK;
            end
            
            default:                        next_state = ST_IDLE;
        endcase
    end

endmodule