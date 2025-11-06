-- uart_top.vhd
-- Топ-модуль UART (інстанси TX, RX та Baud Generator)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_top is
    Port (
        clk      : in  STD_LOGIC;                      -- системний такт
        rst      : in  STD_LOGIC;                      -- reset
        tx_start : in  STD_LOGIC;                      -- старт передачі
        tx_data  : in  STD_LOGIC_VECTOR(7 downto 0);   -- передані дані
        txd      : out STD_LOGIC;                      -- UART TX
        rxd      : in  STD_LOGIC;                      -- UART RX
        rx_data  : out STD_LOGIC_VECTOR(7 downto 0);   -- прийняті дані
        rx_ready : out STD_LOGIC;                      -- готовність RX
        tx_busy  : out STD_LOGIC                       -- TX зайнятий
    );
end uart_top;

architecture Behavioral of uart_top is

    signal tick : STD_LOGIC; -- BAUD імпульс

begin

    BG: entity work.baud_gen port map(clk, rst, tick);
    TX: entity work.uart_tx port map(clk, rst, tick, tx_start, tx_data, txd, tx_busy);
    RX: entity work.uart_rx port map(clk, rst, tick, rxd, rx_data, rx_ready);

end Behavioral;
