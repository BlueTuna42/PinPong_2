module VGA (
    input  wire         clk,
    input  wire         rst_n,
    
    output logic        hsync,
    output logic        vsync,
    output logic [2:0]  RGB
);
    // VGA 640x480 @ 60Hz pixel clock 25MHz
    localparam H_total = 800;
    localparam V_total = 525; 
    
    localparam H_res = 640;
    localparam V_res = 480;
    
    localparam H_front_porch = 16;
    localparam V_front_porch = 10;
    
    localparam H_sync_width = 96;
    localparam V_sync_width = 2;

    // === coordinate counter ===
    logic [10:0] hpos;
    logic [9:0]  vpos;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hpos <= 0;
            vpos <= 0;
        end else begin
            if (hpos == H_total - 1) begin
                hpos <= 0;
                
                if (vpos == V_total - 1)
                    vpos <= 0;
                else
                    vpos <= vpos + 1'd1;
            end else begin
                hpos <= hpos + 1'd1;
            end
        end  
    end
    
    // === FSMs ===
    typedef enum logic [1:0] {
        ST_FRAME        = 2'b00,
        ST_FRONT_PORCH  = 2'b01,
        ST_SYNC         = 2'b10,
        ST_BACK_PORCH   = 2'b11
    } vga_state_t;

    vga_state_t h_current, h_next;
    vga_state_t v_current, v_next;

    // === Horizontal FSM ===
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            h_current <= ST_FRAME;
        else        
            h_current <= h_next;
    end

    always_comb begin
        h_next = h_current;
        case (h_current)
            ST_FRAME:      
                if (hpos == H_res - 1)                                          h_next = ST_FRONT_PORCH;
            ST_FRONT_PORCH: 
                if (hpos == H_res + H_front_porch - 1)                          h_next = ST_SYNC;
            ST_SYNC:        
                if (hpos == H_res + H_front_porch + H_sync_width - 1)           h_next = ST_BACK_PORCH;
            ST_BACK_PORCH:  
                if (hpos == H_total - 1)                                        h_next = ST_FRAME;
            default:                                                            h_next = ST_FRAME;
        endcase
    end

    // === Vertical FSM ===
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            v_current <= ST_FRAME;
        else
            v_current <= v_next;
    end

    always_comb begin
        v_next = v_current; 
        if (hpos == H_total - 1) begin
            case (v_current)
                ST_FRAME:
                    if (vpos == V_res - 1)                                      v_next = ST_FRONT_PORCH;
                ST_FRONT_PORCH:
                    if (vpos == V_res + V_front_porch - 1)                      v_next = ST_SYNC;
                ST_SYNC:
                    if (vpos == V_res + V_front_porch + V_sync_width - 1)       v_next = ST_BACK_PORCH;
                ST_BACK_PORCH:
                    if (vpos == V_total - 1)                                    v_next = ST_FRAME;
                default:                                                        v_next = ST_FRAME;
            endcase
        end
    end

    // === Output logic ===
    always_comb begin
        hsync = (h_current == ST_SYNC) ? 1'b0 : 1'b1;
        vsync = (v_current == ST_SYNC) ? 1'b0 : 1'b1;

        if (h_current == ST_FRAME && v_current == ST_FRAME) begin
            RGB = 3'b111;
        end else begin
            RGB = 3'b000;
        end
    end

endmodule