# ICE40HX1K to Extension Connector Pin Mapping

## BH34R Connector Pin Mapping (Corrected)

Based on the physical connector layout, the BH34R connector is a 17x2 pin header with the following pin mapping:

| Left (Odd) |          |      |         |     | Right (Even) |          |      |          |
|------------|----------|------|---------|-----|--------------|----------|------|----------|
| **Pin** | **Signal** | **PCF PIN** | **Pin Name** | | **Pin** | **Signal** | **PCF PIN** | **Pin Name** |
| 1 | +5V | - | Power | | 2 | GND | - | Ground |
| 3 | +3.3V | - | Power | | 4 | GND | - | Ground |
| 5 | PIO3_1A | 1 | IOL_1A | | 6 | EXTCLK | - | EXTCLK |
| 7 | PIO3_1B | 2 | IOL_1B | | 8 | GND | - | Ground |
| 9 | PIO3_2A | 3 | IOL_2A | | 10 | LED1 | 40 | IOB_41 |
| 11 | PIO3_2B | 4 | IOL_2B | | 12 | LED2 | 51 | IOR_52 |
| 13 | PIO3_3A | 7 | IOL_3A | | 14 | PIO2_9/TxD | 37 | IOB_37 |
| 15 | PIO3_3B | 8 | IOL_3B | | 16 | PIO2_8/RxD | 36 | IOB_34 |
| 17 | PIO3_5A | 9 | IOL_5A | | 18 | PIO2_7 | 34 | IOB_36_GBIN4 |
| 19 | PIO3_5B | 10 | IOL_5B | | 20 | PIO2_6 | 33 | IOB_35_GBIN5 |
| 21 | PIO3_6A | 12 | IOL_6A | | 22 | PIO2_5 | 30 | IOB_30 |
| 23 | PIO3_6B | 13 | IOL_6B_GBIN7 | | 24 | PIO2_4 | 29 | IOB_29 |
| 25 | PIO3_7B | 16 | IOL_7B | | 26 | PIO2_3 | 28 | IOB_28 |
| 27 | PIO3_8A | 18 | IOL_8A | | 28 | PIO2_2 | 27 | IOB_27 |
| 29 | PIO3_8B | 19 | IOL_8B | | 30 | PIO2_1 | 26 | IOB_26 |
| 31 | PIO3_10A | 20 | IOL_10A | | 32 | PIO3_12B | 25 | IOL_12B |
| 33 | PIO3_10B | 21 | IOL_10B | | 34 | PIO3_12A | 24 | IOL_12A |


## Usage in PCF Files

To use these pins in your constraint files:

```tcl
set_io signal_name <ICE40HX1K_Pin_Number>
```

Example:
```tcl
# Using GPIO pins from the extension connector
set_io my_output 1     # Maps to Extension pin 5 (PIO3_1A / IOL_1A)
set_io my_input  2     # Maps to Extension pin 7 (PIO3_1B / IOL_1B)

# Using UART
set_io uart_tx 37      # Maps to Extension pin 14 (PIO2_9/TxD / IOB_37)
set_io uart_rx 36      # Maps to Extension pin 16 (PIO2_8/RxD / IOB_34)

# Using LEDs
set_io led1 40         # Maps to Extension pin 10 (LED1 / IOB_41)
set_io led2 51         # Maps to Extension pin 12 (LED2 / IOR_53)

# Using External Clock
set_io ext_clock 15    # Maps to Extension pin 6 (EXTCLK / IOL_7A_GBIN6)
```

## ICE40HX1K-VQ100 Pin Reference

For reference, the ICE40HX1K-VQ100 pin numbers mentioned above correspond to physical pins on the FPGA package. Always verify pin assignments match your specific board layout.
