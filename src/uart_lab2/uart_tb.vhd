-- testbench.vhd
-- Призначення: Тест-сценарій для верифікації UART.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all; 

entity uart_tb is
end entity uart_tb;

architecture tb of uart_tb is

    -- Компонент DUT (для коректної ієрархії)
    component uart_top is
        Port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            tx_start : in  std_logic;
            tx_data  : in  std_logic_vector(7 downto 0);
            txd      : out std_logic;
            rxd      : in  std_logic;
            rx_data  : out std_logic_vector(7 downto 0);
            rx_ready : out std_logic;
            tx_busy  : out std_logic
        );
    end component;

    -- Тестові сигнали
    constant C_CLK_PERIOD : time := 10 ns; 

    signal clk      : std_logic := '0';        
    signal rst      : std_logic := '1';        
    signal tx_start : std_logic := '0';        
    signal tx_data  : std_logic_vector(7 downto 0) := x"5A"; -- Тестовий байт
    signal txd      : std_logic;               
    signal rx_data  : std_logic_vector(7 downto 0); 
    signal rx_ready : std_logic;               
    signal tx_busy  : std_logic;               

begin

    -- Інстанс UART (DUT)
    DUT: entity work.uart_top
        port map (
            clk      => clk,
            rst      => rst,
            tx_start => tx_start,
            tx_data  => tx_data,
            txd      => txd,
            rxd      => txd,         -- Loopback: TX підключаємо до RX
            rx_data  => rx_data,
            rx_ready => rx_ready,
            tx_busy  => tx_busy
        );

    -- Генерація системного тактового сигналу 50 MHz
    clk <= not clk after C_CLK_PERIOD;

    -- Процес стимулювання
    stim: process
    begin
        -- 1. Фаза reset
        rst <= '1';
        wait for 200 ns; 
        rst <= '0';
        wait for 100 ns;

        -- 2. Подача тестового байта та запуск
        tx_data <= x"5A";
        wait for 50 ns;
        tx_start <= '1';
        
        -- Тримаємо tx_start високим на 5 us (більше, ніж T_bit = 2 us)
        wait for 5 us; 
        tx_start <= '0';

        -- 3. Чекаємо поки RX прийме байт
        wait until rx_ready = '1';

        -- 4. Перевірка результату (тепер має бути успішно)
        assert (rx_data = x"5A")
            report "TEST FAILED: Received data is not 0x5A"
            severity error;
        
        -- 5. Зупинка симуляції
        wait for 1 us;
        report "Simulation completed. Test passed." severity note;
        
        assert false report "Simulation stop" severity failure; 
        
    end process stim;

end architecture tb;