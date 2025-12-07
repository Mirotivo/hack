/**
 * The module Hack is a logic gate test
 * Tests AND and OR gates with BUTton inputs
 * LED0 shows AND of BUTtons, LED1 shows OR of BUTtons
 * It connects the external pins of our FPGA (Hack.pcf)
 * to test basic logic gate functionality
 */
`default_nettype none

`include "../../modules/Nand.v"
`include "../../modules/Not.v"
`include "../../modules/And.v"
`include "../../modules/Or.v"

module Hack (
    // GPIO (Buttons and LEDs)
    input wire [1:0] BUT,
    output wire [1:0] LED
);

    // Internal signals - Button processing
    wire inv_0;
    wire inv_1;

    // Module instantiations
    
    // GPIO - Button inversion (BUTtons are active low)
    Not not1(.IN(BUT[0]), .OUT(inv_0));
    Not not2(.IN(BUT[1]), .OUT(inv_1));

    // Logic gates
    And and1(.A(inv_0), .B(inv_1), .OUT(LED[0]));
    Or or1(.A(inv_0), .B(inv_1), .OUT(LED[1]));

endmodule
