----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:13:28 09/24/2014 
-- Design Name: 
-- Module Name:    Top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Top is
    Port ( 
				CLK_8MHZ 		: in 		STD_LOGIC;
				BTN_0 			: in  	STD_LOGIC;
				BTN_1 			: in  	STD_LOGIC;
				LED_0 			: out 	STD_LOGIC;
				LED_1 			: out 	STD_LOGIC;
				LED_2 			: out 	STD_LOGIC;
				LED_3 			: out 	STD_LOGIC;
			  
				DAC_BIN			: out  	STD_LOGIC;
				DAC_SCLK			: out  	STD_LOGIC;
				DAC_SDO			: in  	STD_LOGIC;
				DAC_N_LDAC		: out  	STD_LOGIC;
				DAC_D1			: in  	STD_LOGIC;
				ADC_OS			: out  	STD_LOGIC_VECTOR(2 downto 0);
				ADC_RANGE		: out  	STD_LOGIC;
				ADC_CONVST_B	: out  	STD_LOGIC;
				ADC_SCLK			: out  	STD_LOGIC;
				ADC_BUSY			: in  	STD_LOGIC;
				ADC_DOUT_A		: in  	STD_LOGIC;
				RESET				: in  	STD_LOGIC;
				SYNC_RESET		: in  	STD_LOGIC;
				BUS_CLK			: in 		STD_LOGIC;
				MISO				: inout  STD_LOGIC;
				CS					: in  	STD_LOGIC;
				CSMUX				: in  	STD_LOGIC_VECTOR(2 downto 0);
				SPARE10			: in  	STD_LOGIC;
				SPARE8			: in  	STD_LOGIC;
				SPARE9			: in  	STD_LOGIC;
				SPARE6			: in  	STD_LOGIC;
				SPARE7			: in  	STD_LOGIC;
				SPARE3			: in  	STD_LOGIC;
				SPARE2			: in  	STD_LOGIC;
				SPARE5			: in  	STD_LOGIC;
				SPARE4			: in  	STD_LOGIC;
				SPARE1			: in  	STD_LOGIC;
				SCK				: in  	STD_LOGIC;
				MOSI				: in  	STD_LOGIC;
				SYNC_CLK			: in  	STD_LOGIC;
				FAULT				: inout 	STD_LOGIC;
				ADC_DOUT_B		: in  	STD_LOGIC;
				ADC_FRSTDATA	: in  	STD_LOGIC;
				ADC_N_CS			: out  	STD_LOGIC;
				ADC_RESET		: out  	STD_LOGIC;
				ADC_CONVST_A	: out  	STD_LOGIC;
				ADC_N_STBY		: out  	STD_LOGIC;
				DAC_N_RSTIN		: out  	STD_LOGIC;
				DAC_D0			: in  	STD_LOGIC;
				DAC_N_CLR		: out  	STD_LOGIC;
				DAC_SDIN			: out  	STD_LOGIC;
				DAC_N_SYNC		: out  	STD_LOGIC
			  );
end Top;

architecture Behavioral of Top is

component clk_mult_100mhz
port
 (-- Clock in ports
  CLK_IN1           			: in     std_logic;
  -- Clock out ports
  CLK_OUT1          			: out    std_logic
 );
 end component;

component clk_binary_divider
    Generic
			(
			NB_OF_BIT 			: positive := 16										-- determine the number of bit in the counter
			);
	 Port ( 
			CLK 					: in  	STD_LOGIC;								-- Main clock of the system
			OUTPUT				: out  	STD_LOGIC								-- Counter output
			);								
end component;

component time_sync
	 Generic (
			sync_time_size 	: POSITIVE := 16
			);
    Port ( 
			  CLK 				: in  	STD_LOGIC;								-- Main clock of the system
           SYNC_CLK 			: in  	STD_LOGIC;								-- Counter increment clock tick
           SYNC_RESET 		: in  	STD_LOGIC;								-- Counter reset signal
           SYNC_TIME 		: out  	STD_LOGIC_VECTOR(sync_time_size-1 downto 0)	-- Counter output
           );								
end component;

component aio_spi_protocol
	 Generic (
				sync_time_size : POSITIVE := 16
	 );
    Port ( 
				-- System clock
				CLK 				: in  	STD_LOGIC;
				
				-- System reset signal
				RESET 			: in 		STD_LOGIC;
				
				-- SPI Interface
				MOSI 				: in 		STD_LOGIC;
				MISO 				: inout 	STD_LOGIC;
				SCK 				: in		STD_LOGIC;
				CS 				: in 		STD_LOGIC;
				
				-- Time reference
				SYNC_TIME 		: in 		STD_LOGIC_VECTOR(sync_time_size-1 downto 0);
				
				-- Time feed-back pulse (named as the fault signal in the system)
				FAULT				: inout  STD_LOGIC;

				-- User led control
				LED1				: out 	STD_LOGIC;
				LED2				: out 	STD_LOGIC;
				LED3				: out 	STD_LOGIC;

				-- BOARD IO

				-- SPI DAC
				DAC_BIN			: out  	STD_LOGIC;
				DAC_SCLK			: out  	STD_LOGIC;
				DAC_SDO			: in  	STD_LOGIC;
				DAC_N_LDAC		: out  	STD_LOGIC;
				DAC_D1			: in  	STD_LOGIC;
				DAC_N_RSTIN		: out  	STD_LOGIC;
				DAC_D0			: in  	STD_LOGIC;
				DAC_N_CLR		: out  	STD_LOGIC;
				DAC_SDIN			: out  	STD_LOGIC;
				DAC_N_SYNC		: out  	STD_LOGIC;

				-- SPI ADC
				ADC_OS			: out  	STD_LOGIC_VECTOR(2 downto 0);
				ADC_RANGE		: out  	STD_LOGIC;
				ADC_CONVST_B	: out  	STD_LOGIC;
				ADC_SCLK			: out  	STD_LOGIC;
				ADC_BUSY			: in  	STD_LOGIC;
				ADC_DOUT_A		: in  	STD_LOGIC;
				ADC_DOUT_B		: in  	STD_LOGIC;
				ADC_FRSTDATA	: in  	STD_LOGIC;
				ADC_N_CS			: out  	STD_LOGIC;
				ADC_RESET		: out  	STD_LOGIC;
				ADC_CONVST_A	: out  	STD_LOGIC;
				ADC_N_STBY		: out  	STD_LOGIC;

				-- SPARE IO
				SPARE1			: out  	STD_LOGIC;
				SPARE2			: out  	STD_LOGIC;
				SPARE3			: out  	STD_LOGIC;
				SPARE4			: out  	STD_LOGIC;
				SPARE5			: out  	STD_LOGIC;
				SPARE6			: out  	STD_LOGIC;
				SPARE7			: out  	STD_LOGIC;
				SPARE8			: out  	STD_LOGIC;
				SPARE9			: out  	STD_LOGIC;
				SPARE10			: out  	STD_LOGIC
				);
end component;

signal clk_100mhz_s 	: STD_LOGIC; -- system clock

signal sync_time_s 	: STD_LOGIC_VECTOR(31 downto 0);

begin

CLK0 :  clk_mult_100mhz
port map
 (-- Clock in ports
  CLK_IN1						=> CLK_8MHZ,
  -- Clock out ports
  CLK_OUT1						=> clk_100mhz_s
 );


U0 : clk_binary_divider
    Generic map
			(
			NB_OF_BIT 			=> 25
			)
	 Port map ( 
			CLK 					=> clk_100mhz_s,
			OUTPUT 				=> LED_0
			);				
	
U1 : time_sync
	 Generic map(
			sync_time_size 	=> 32
			)
    Port map( 
			  CLK 				=> clk_100mhz_s,						-- Main clock of the system
           SYNC_CLK 			=> SYNC_CLK,							-- Counter increment clock tick
           SYNC_RESET 		=> SYNC_RESET,							-- Counter reset signal
           SYNC_TIME 		=> sync_time_s							-- Counter output
           );								
	
U2 : aio_spi_protocol
	 Generic map(
				sync_time_size => 32
	 )
    Port map( 
				-- System clock
				CLK 				=> clk_100mhz_s,
				
				-- System reset signal
				RESET 			=> RESET,
				
				-- SPI Interface
				MOSI 				=> MOSI,
				MISO 				=> MISO,
				SCK 				=> SCK,
				CS 				=> CS,
				
				-- Time reference
				SYNC_TIME 		=> sync_time_s,
				
				-- Time feed-back pulse (named as the fault signal in the system)
				FAULT				=> FAULT,

				-- User led control
				LED1				=> LED_1,
				LED2				=> LED_2,
				LED3				=> LED_3,

				-----------------------------
				-- BOARD IO

				-- SPI DAC
				DAC_BIN			=>DAC_BIN,
				DAC_SCLK			=>DAC_SCLK,
				DAC_SDO			=>DAC_SDO,
				DAC_N_LDAC		=>DAC_N_LDAC,
				DAC_D1			=>DAC_D1,
				DAC_N_RSTIN		=>DAC_N_RSTIN,
				DAC_D0			=>DAC_D0,
				DAC_N_CLR		=>DAC_N_CLR,
				DAC_SDIN			=>DAC_SDIN,
				DAC_N_SYNC		=>DAC_N_SYNC,

				-- SPI ADC
				ADC_OS			=>ADC_OS,
				ADC_RANGE		=>ADC_RANGE,
				ADC_CONVST_B	=>ADC_CONVST_B,
				ADC_SCLK			=>ADC_SCLK,
				ADC_BUSY			=>ADC_BUSY,
				ADC_DOUT_A		=>ADC_DOUT_A,
				ADC_DOUT_B		=>ADC_DOUT_B,
				ADC_FRSTDATA	=>ADC_FRSTDATA,
				ADC_N_CS			=>ADC_N_CS,
				ADC_RESET		=>ADC_RESET,
				ADC_CONVST_A	=>ADC_CONVST_A,
				ADC_N_STBY		=>ADC_N_STBY,

				-- SPARE IO
				SPARE1			=>open,
				SPARE2			=>open,
				SPARE3			=>open,
				SPARE4			=>open,
				SPARE5			=>open,
				SPARE6			=>open,
				SPARE7			=>open,
				SPARE8			=>open,
				SPARE9			=>open,
				SPARE10			=>open
				);


end Behavioral;
