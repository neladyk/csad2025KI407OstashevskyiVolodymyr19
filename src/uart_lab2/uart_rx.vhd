-- uart_rx.vhd
-- Призначення: Приймач UART з точністю 16x для надійної роботи.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    Port (
        clk        : in  STD_LOGIC;
        rst        : in  STD_LOGIC;
        tick_x16   : in  STD_LOGIC;  -- 16x такт від Baud Generator
        rxd        : in  STD_LOGIC;  -- UART RX вхід
        rx_data    : out STD_LOGIC_VECTOR(7 downto 0); -- Отримані дані
        rx_ready   : out STD_LOGIC   -- Імпульс готовності байта
    );
end entity uart_rx;

architecture Behavioral of uart_rx is
    type state_t is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal state : state_t := IDLE;
    
    signal r_rxd_sync : STD_LOGIC := '1'; -- Синхронізований вхід RXD
    signal bit_cnt    : unsigned(2 downto 0) := (others => '0'); -- 0 до 7
    signal tick_count : integer range 0 to 15 := 0; -- Лічильник 16x тактів
    signal rx_buffer  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); -- Буфер даних

begin

-- Синхронізація RXD на CLK (для уникнення метастабільності)
process(clk, rst)
begin
    if rising_edge(clk) then
        if rst = '1' then
            r_rxd_sync <= '1';
        else
            r_rxd_sync <= rxd;
        end if;
    end if;
end process;

-- FSM Приймача, що працює по TICK_X16
process(clk, rst)
begin
    if rst = '1' then
        state <= IDLE;
        bit_cnt <= (others => '0');
        tick_count <= 0;
        rx_ready <= '0';
        rx_data <= (others => '0');
    elsif rising_edge(clk) then
        rx_ready <= '0';
        
        if tick_x16 = '1' then
            
            case state is
                when IDLE =>
                    tick_count <= 0;
                    -- Виявлено перехід 1->0: Потенційний Старт-біт
                    if r_rxd_sync = '0' then 
                        state <= START_BIT;
                    end if;

                when START_BIT =>
                    if tick_count = 7 then -- Середина Старт-біта (8-й такт)
                        if r_rxd_sync = '0' then
                            tick_count <= 0;
                            state <= DATA_BITS;
                        else 
                            state <= IDLE; -- Помилка/Шум
                        end if;
                    else
                        tick_count <= tick_count + 1;
                    end if;

                when DATA_BITS =>
                    if tick_count = 15 then -- Кінець бітового інтервалу
                        tick_count <= 0;
                        if bit_cnt = 7 then
                            state <= STOP_BIT;
                        else
                            bit_cnt <= bit_cnt + 1;
                        end if;
                    else
                        -- Зчитування біта в середині інтервалу (8-й такт)
                        if tick_count = 7 then
                            rx_buffer(to_integer(bit_cnt)) <= r_rxd_sync;
                        end if;
                        tick_count <= tick_count + 1;
                    end if;

                when STOP_BIT =>
                    if tick_count = 15 then -- Кінець Стоп-біта
                        rx_data <= rx_buffer;
                        rx_ready <= '1';
                        state <= IDLE;
                    else
                        tick_count <= tick_count + 1;
                    end if;
            end case;
        end if;
    end if;
end process;

end architecture Behavioral;