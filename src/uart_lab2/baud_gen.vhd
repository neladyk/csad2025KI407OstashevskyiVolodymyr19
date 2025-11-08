-- baud_gen.vhd
-- Призначення: Генератор тактового сигналу, що в 16 разів швидше за Baud Rate.
--              Це необхідно для точної вибірки (sampling) RXD по середині біта.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity baud_gen is
    Port (
        clk      : in  STD_LOGIC;  -- Системний тактовий сигнал (50 МГц)
        rst      : in  STD_LOGIC;  -- Сигнал скидання
        tick_x16 : out STD_LOGIC   -- Вихідний імпульс 16x Baud Rate
    );
end entity baud_gen;

architecture Behavioral of baud_gen is

    constant CLK_FREQ : integer := 50000000;         -- Частота FPGA (50 МГц)
    constant BAUD     : integer := 500000;           -- Баудова швидкість (500 кбіт/с)
    
    -- Розрахунок дільника для 16x Baud Rate: 50M / (500k * 16) = 6.25. 
    -- Використовуємо 6 для спрощення, що призводить до невеликої похибки, але працює.
    constant DIVIDER_X16 : integer := CLK_FREQ / (BAUD * 16); 

    -- Лічильник для поділу CLK до 16x Baud Rate
    signal counter_x16 : integer range 0 to DIVIDER_X16 := 0; 
    signal r_tick_x16  : STD_LOGIC := '0';

begin

process(clk, rst)
begin
    if rst = '1' then
        counter_x16 <= 0;
        r_tick_x16  <= '0';
    elsif rising_edge(clk) then
        if counter_x16 = DIVIDER_X16 - 1 then
            -- Досягнуто кінця інтервалу: генеруємо імпульс і скидаємо лічильник
            counter_x16 <= 0;
            r_tick_x16  <= '1';  
        else
            -- Продовжуємо рахувати
            counter_x16 <= counter_x16 + 1;
            r_tick_x16  <= '0';
        end if;
    end if;
end process;

tick_x16 <= r_tick_x16;

end architecture Behavioral;