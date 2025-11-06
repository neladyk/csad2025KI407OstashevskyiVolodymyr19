-- uart_tx.vhd
-- Призначення: Передавач UART, синхронізований на 16x Tick для коректного співвідношення з RX.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        tick_x16 : in  STD_LOGIC;  -- 16x такт від Baud Generator
        tx_start : in  STD_LOGIC;
        tx_data  : in  STD_LOGIC_VECTOR(7 downto 0);
        txd      : out STD_LOGIC;
        tx_busy  : out STD_LOGIC
    );
end entity uart_tx;

architecture Behavioral of uart_tx is

    type state_t is (IDLE, START, DATA, STOP);
    signal state : state_t := IDLE;
    
    signal bit_cnt     : unsigned(2 downto 0) := (others => '0');
    signal tick_count  : integer range 0 to 15 := 0; -- Лічильник 16x тактів
    signal tx_buffer   : STD_LOGIC_VECTOR(7 downto 0);
    signal tx_reg      : STD_LOGIC := '1';

begin

txd <= tx_reg;

process(clk, rst)
begin
    if rst = '1' then
        state <= IDLE;
        bit_cnt <= (others => '0');
        tick_count <= 0;
        tx_reg <= '1';
        tx_busy <= '0';

    elsif rising_edge(clk) then
        tx_busy <= '1'; -- За замовчуванням зайнятий під час передачі
        
        if tick_x16 = '1' then
            -- Логіка FSM виконується лише, коли лічильник 16x досягає 15 (кожні 1x інтервал)
            
            if tick_count = 15 then 
                tick_count <= 0; -- Скидаємо 16x лічильник
                
                -- *** ФАКТИЧНИЙ ПЕРЕХІД СТАНІВ (1x Baud) ***
                case state is
                    when IDLE =>
                        tx_busy <= '0';
                        if tx_start = '1' then
                            tx_buffer <= tx_data;
                            state <= START;
                        end if;

                    when START =>
                        tx_reg <= '0'; 
                        state <= DATA;

                    when DATA =>
                        tx_reg <= tx_buffer(to_integer(bit_cnt));
                        if bit_cnt = 7 then
                            state <= STOP;
                        else
                            bit_cnt <= bit_cnt + 1;
                        end if;

                    when STOP =>
                        tx_reg <= '1';
                        state <= IDLE;
                        tx_busy <= '0'; -- Звільняємо шину після Стоп-біта
                end case;
                -- *******************************************
                
            else
                tick_count <= tick_count + 1; -- Рахуємо 16x такт
            end if;
        end if;
    end if;
end process;

end architecture Behavioral;