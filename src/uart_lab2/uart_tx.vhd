-- uart_tx.vhd
-- UART передавач (8N1)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    Port (
        clk      : in  STD_LOGIC;                    -- системний такт
        rst      : in  STD_LOGIC;                    -- reset
        tick     : in  STD_LOGIC;                    -- частота BAUD
        tx_start : in  STD_LOGIC;                    -- запуск передачі
        tx_data  : in  STD_LOGIC_VECTOR(7 downto 0); -- дані для передачі
        txd      : out STD_LOGIC;                    -- вихід UART TX
        tx_busy  : out STD_LOGIC                     -- 1 = йде передача
    );
end uart_tx;

architecture Behavioral of uart_tx is

    type state_t is (IDLE, START, DATA, STOP); -- стани FSM
    signal state : state_t := IDLE;

    signal bit_cnt : integer range 0 to 7 := 0;      -- індекс біта 0..7
    signal buffer  : STD_LOGIC_VECTOR(7 downto 0);   -- байт що передається
    signal tx_reg  : STD_LOGIC := '1';               -- регістр лінії TX

begin

txd <= tx_reg;

process(clk, rst)
begin
    if rst = '1' then
        state <= IDLE;
        bit_cnt <= 0;
        tx_reg <= '1';
        tx_busy <= '0';

    elsif rising_edge(clk) then
        if tick = '1' then

            case state is

                when IDLE =>
                    tx_busy <= '0';
                    if tx_start = '1' then
                        buffer <= tx_data;  -- завантаження байта
                        state <= START;
                    end if;

                when START =>
                    tx_busy <= '1';
                    tx_reg <= '0';         -- старт-біт
                    state <= DATA;

                when DATA =>
                    tx_reg <= buffer(bit_cnt); -- передача LSB
                    if bit_cnt = 7 then
                        bit_cnt <= 0;
                        state <= STOP;
                    else
                        bit_cnt <= bit_cnt + 1;
                    end if;

                when STOP =>
                    tx_reg <= '1'; -- стоп-біт
                    state <= IDLE;

            end case;

        end if;
    end if;
end process;

end Behavioral;
