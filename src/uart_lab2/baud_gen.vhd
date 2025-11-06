-- baud_gen.vhd
-- Генерує імпульс tick для UART (1 tick = 1 біт)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity baud_gen is
    Port (
        clk  : in  STD_LOGIC;   -- системний тактовий сигнал
        rst  : in  STD_LOGIC;   -- сигнал скидання ('1' = reset)
        tick : out STD_LOGIC    -- імпульс частоти BAUD
    );
end baud_gen;

architecture Behavioral of baud_gen is

    constant CLK_FREQ : integer := 50000000; -- частота FPGA
    constant BAUD     : integer := 9600;     -- швидкість UART
    constant DIVIDER  : integer := CLK_FREQ / BAUD;

    signal counter : integer range 0 to DIVIDER := 0; -- лічильник для формування tick

begin

process(clk, rst)
begin
    if rst = '1' then
        counter <= 0;
        tick <= '0';
    elsif rising_edge(clk) then
        if counter = DIVIDER then
            counter <= 0;
            tick <= '1';  -- один такт для зсуву бітів UART
        else
            counter <= counter + 1;
            tick <= '0';
        end if;
    end if;
end process;

end Behavioral;
