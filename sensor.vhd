 library ieee;
use ieee.std_logic_1164.all;

entity sensor_module is
    Port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        SENSOR     : in  std_logic;
        car_detect : out std_logic
    );
end sensor_module;

architecture Behavioral of sensor_module is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            car_detect <= '0';
        elsif rising_edge(clk) then
            car_detect <= SENSOR;
        end if;
    end process;
end Behavioral;