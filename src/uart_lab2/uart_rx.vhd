-- uart_rx.vhd
-- UART приймач (8N1)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    Port (
        clk        : in  STD_LOGIC;                    -- системний такт
        rst        : in  STD_LOGIC;                    -- reset
        tick       : in  STD_LOGIC;                    -- такт BAUD
        rxd        : in  STD_LOGIC;                    -- UART RX вхід
        data_out   : out STD_LOGIC_VECTOR(7 downto 0); -- отримані дані
        data_ready : out STD_LOGIC                     -- імпульс готовності байта
    );
end uart_rx;

architecture Behavioral of uart_rx is

    type state_t is (IDLE, START, DATA, STOP); -- FSM
    signal state : state_t := IDLE;

    signal bit_cnt : integer range 0 to 7 := 0;      -- відлік біта
    signal buffer  : STD_LOGIC_VECTOR(7 downto 0);   -- прийняті біти

begin

process(clk, rst)
begin
    if rst = '1' then
        state <= IDLE;
        bit_cnt <= 0;
        data_ready <= '0';

    elsif rising_edge(clk) then
        data_ready <= '0';

        if tick = '1' then
            case state is

                when IDLE =>
                    if rxd = '0' then  -- старт-біт
                        state <= START;
                    end if;

                when START =>
                    state <= DATA;

                when DATA =>
                    buffer(bit_cnt) <= rxd; -- зчитування біта
                    if bit_cnt = 7 then
                        bit_cnt <= 0;
                        state <= STOP;
                    else
                        bit_cnt <= bit_cnt + 1;
                    end if;

                when STOP =>
                    data_out <= buffer;
                    data_ready <= '1'; -- байт готовий
                    state <= IDLE;

            end case;
        end if;
    end if;
end process;

end Behavioral;
