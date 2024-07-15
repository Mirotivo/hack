module SRAM_Controller (
    input wire clk,
    input wire rst,
    input wire we, // Write Enable
    input wire [17:0] address, // 18-bit Address bus
    inout wire [15:0] DATA, // 16-bit DATA bus
    output wire CSX, // Chip Enable (active low)
    output wire OEX, // Output Enable (active low)
    output wire WEX // Write Enable (active low)
);

    // Internal registers
    reg [15:0] DATA_reg;
    reg DATA_dir; // Direction of DATA bus: 0 for read, 1 for write

    // Tri-state buffer control
    assign DATA = (DATA_dir) ? DATA_reg : 16'bz;

    // Control signals
    assign CSX = 0; // Always enabled (active low)
    assign OEX = ~we; // Output Enable when reading (active low)
    assign WEX = we; // Write Enable (active low)

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            DATA_reg <= 16'b0;
            DATA_dir <= 0;
        end else begin
            if (we) begin
                // Write operation
                DATA_reg <= DATA;
                DATA_dir <= 1; // Set DATA bus direction to write
            end else begin
                // Read operation
                DATA_dir <= 0; // Set DATA bus direction to read
            end
        end
    end

endmodule
