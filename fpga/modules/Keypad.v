/**
 * The module Keypad is a 4x4 keypad scanner
 * Scans columns and reads rows to detect key presses
 * Outputs key index (0-15) and validity signal
 */
`default_nettype none
module Keypad (
    // Clock
    input wire CLK,

    // Keypad Interface
    output reg [3:0] COL,
    input wire [3:0] ROW,

    // Key Output
    output reg [3:0] KEY_INDEX,
    output reg KEY_VALID
);

    // --------------------------
    // Internal signals
    // --------------------------
    reg [3:0] scan_state;
    reg [3:0] scan_timer;
    reg key_reported;
    reg [1:0] col_idx;

    integer i;

    // --------------------------
    // Sequential logic
    // --------------------------
    
    initial begin
        COL = 4'b0000;
        KEY_INDEX = 4'd0;
        KEY_VALID = 1'b0;
        scan_state = 4'b0000;
        scan_timer = 4'b0000;
        key_reported = 0;
        col_idx = 2'd0;
    end
    
    always @(posedge CLK) begin
        KEY_VALID <= 0;

        case (scan_state)

            4'b0000: begin
                COL <= 4'b0000;
                if (scan_timer == 4'b1111) begin
                    scan_state <= 4'b0001;
                    scan_timer <= 0;
                end else begin
                    scan_timer <= scan_timer + 1;
                end
            end

            4'b0001, 4'b0010, 4'b0100, 4'b1000: begin
                COL <= scan_state;

                if (scan_timer == 4'b1111) begin
                    scan_timer <= 0;

                    if (|ROW && !key_reported) begin
                        // Column index from scan_state
                        if (scan_state == 4'b0001) col_idx <= 2'd0;
                        else if (scan_state == 4'b0010) col_idx <= 2'd1;
                        else if (scan_state == 4'b0100) col_idx <= 2'd2;
                        else col_idx <= 2'd3;

                        // Row index from row bits
                        for (i = 0; i < 4; i = i + 1) begin
                            if (ROW[i]) begin
                                KEY_INDEX <= (i * 4) + col_idx;
                                KEY_VALID <= 1;
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

        if (ROW == 4'b0000)
            key_reported <= 0;
    end

endmodule
