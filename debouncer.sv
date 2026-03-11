module debouncer #(
	parameter int CLK_FREQ = 50_000_000,
	parameter int DEBOUNCE_MS = 20
)(
	input  logic			clk,
	input  logic			rst_n,
	
	input  logic 			btn_in,
	output logic			btn_out,
	output logic			btn_pressed,
	output logic			btn_released

);

	localparam int MAX_COUNT = (CLK_FREQ / 1000) * DEBOUNCE_MS;
    localparam int COUNTER_WIDTH = $clog2(MAX_COUNT);
	
	logic [1:0] sync_reg;
    logic btn_sync;
    
    logic [COUNTER_WIDTH-1:0] counter;
    logic btn_out_d; // 1 clock delayed signal
	
	
	// === metastablity protection ===
	always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_reg <= 2'b00;
        end else begin
            sync_reg <= {sync_reg[0], btn_in};
        end
    end

    assign btn_sync = sync_reg[1];
	
	// === debounce timer ===
	always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= '0;
            btn_out <= 1'b0;
        end else begin
            if (btn_sync == btn_out) begin
                counter <= '0;
            end else begin
                if (counter == MAX_COUNT - 1) begin
                    btn_out <= btn_sync;
                    counter <= '0;
                end else begin
                    counter <= counter + 1'b1;
                end
            end
        end
    end
	
	// === Pulse generator ===
	always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_out_d <= 1'b0;
        end else begin
            btn_out_d <= btn_out;
        end
    end

    assign btn_pressed  = btn_out & ~btn_out_d;
    assign btn_released = ~btn_out & btn_out_d;
	
endmodule 