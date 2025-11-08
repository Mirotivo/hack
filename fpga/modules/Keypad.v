`default_nettype none

module Keypad (
    input  wire clk,
    output reg [3:0] col,           // drive keypad columns (active-low)
    input  wire [3:0] row,          // read keypad rows (active-low)
    output reg [3:0] key_index,     // key index: 0 to 15
    output reg key_valid            // high for 1 cycle when key is detected
);

    reg [3:0] scan_state = 4'b0000;      // active column: one-hot
    reg [3:0] scan_timer = 4'b0000;      // delay per column
    reg       key_reported = 0;
    reg [1:0] col_idx = 2'd0;            // moved outside procedural block

    integer i;

    initial begin
        col       = 4'b0000;
        key_index = 4'd0;
        key_valid = 1'b0;
    end

    always @(posedge clk) begin
        key_valid <= 0;

        case (scan_state)

            4'b0000: begin
                col <= 4'b0000;
                if (scan_timer == 4'b1111) begin
                    scan_state <= 4'b0001;
                    scan_timer <= 0;
                end else begin
                    scan_timer <= scan_timer + 1;
                end
            end

            4'b0001, 4'b0010, 4'b0100, 4'b1000: begin
                col <= scan_state;

                if (scan_timer == 4'b1111) begin
                    scan_timer <= 0;

                    if (|row && !key_reported) begin
                        // column index from scan_state
                        if (scan_state == 4'b0001) col_idx <= 2'd0;
                        else if (scan_state == 4'b0010) col_idx <= 2'd1;
                        else if (scan_state == 4'b0100) col_idx <= 2'd2;
                        else col_idx <= 2'd3;

                        // row index from row bits
                        for (i = 0; i < 4; i = i + 1) begin
                            if (row[i]) begin
                                key_index <= (i * 4) + col_idx;
                                key_valid <= 1;
                                key_reported <= 1;
                            end
                        end

                        scan_state <= 4'b0000;
                    end else begin
                        scan_state <= scan_state << 1;
                    end

                end else begin
                    scan_timer <= scan_timer + 1;
                end
            end

        endcase

        if (row == 4'b0000)
            key_reported <= 0;
    end

endmodule
