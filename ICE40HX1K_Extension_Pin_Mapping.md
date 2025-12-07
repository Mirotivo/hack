# ICE40HX1K-VQ100(VQFP100) to Extension Connector Pin Mapping

## BH34R Connector Pin Mapping

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
set_io my_output 1	# PIO3_1A - Extension Pin 5 (BH34R)
set_io my_output 2	# PIO3_1B - Extension Pin 7 (BH34R)
set_io my_output 3	# PIO3_2A - Extension Pin 9 (BH34R)
set_io my_output 4	# PIO3_2B - Extension Pin 11 (BH34R)
set_io my_output 7	# PIO3_3A - Extension Pin 13 (BH34R)

# Using leds
set_io LED[0] 40	# LED1 - Extension Pin 10 (BH34R)
set_io LED[1] 51	# LED2 - Extension Pin 12 (BH34R)

# Using Uart
set_io UART_RX 36	# PIO2_8/RxD - Extension Pin 16 (BH34R) - UEXT Pin 3 (BH10S)
set_io UART_TX 37	# PIO2_9/TxD - Extension Pin 14 (BH34R) - UEXT Pin 4 (BH10S)
```