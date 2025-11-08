-- uart_top.vhd
-- Призначення: З'єднання Baud Generator, TX та RX.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_top is
    Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        tx_start : in  STD_LOGIC;
        tx_data  : in  STD_LOGIC_VECTOR(7 downto 0);
        txd      : out STD_LOGIC;
        rxd      : in  STD_LOGIC;
        rx_data  : out STD_LOGIC_VECTOR(7 downto 0);
        rx_ready : out STD_LOGIC;
        tx_busy  : out STD_LOGIC
    );
end entity uart_top;

architecture Behavioral of uart_top is

    signal tick_x16 : STD_LOGIC; -- 16x BAUD імпульс

begin

    -- Інстанціювання дільника (генерує 16x tick)
    BG: entity work.baud_gen port map(
        clk      => clk, 
        rst      => rst, 
        tick_x16 => tick_x16 -- Тепер порт називається tick_x16
    ); 

    -- Інстанціювання Передавача (використовує 16x tick для внутрішнього рахунку)
    TX: entity work.uart_tx port map(
        clk      => clk, 
        rst      => rst, 
        tick_x16 => tick_x16, 
        tx_start => tx_start, 
        tx_data  => tx_data, 
        txd      => txd, 
        tx_busy  => tx_busy
    ); 

    -- Інстанціювання Приймача (використовує 16x tick для точної вибірки)
    RX: entity work.uart_rx port map(
        clk      => clk, 
        rst      => rst, 
        tick_x16 => tick_x16, 
        rxd      => rxd, 
        rx_data  => rx_data, 
        rx_ready => rx_ready
    );

end architecture Behavioral;