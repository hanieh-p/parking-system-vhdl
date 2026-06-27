 library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_module is
    Generic ( max_capacity : integer := 10 );
    Port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        car_enter : in  std_logic;
        car_exit  : in  std_logic;
        count_out : out std_logic_vector(3 downto 0);
        full      : out std_logic;
        empty     : out std_logic
    );
end counter_module;

architecture Behavioral of counter_module is
    signal count      : integer range 0 to 15 := 0;
    signal prev_enter : std_logic := '0';
    signal prev_exit  : std_logic := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' then
            count      <= 0;
            prev_enter <= '0';
            prev_exit  <= '0';
        elsif rising_edge(clk) then
            if car_enter = '1' and prev_enter = '0' then
                if count < max_capacity then
                    count <= count + 1;
                end if;
            end if;
            if car_exit = '1' and prev_exit = '0' then
                if count > 0 then
                    count <= count - 1;
                end if;
            end if;
            prev_enter <= car_enter;
            prev_exit  <= car_exit;
        end if;
    end process;

    count_out <= std_logic_vector(to_unsigned(count, 4));
    full      <= '1' when count >= max_capacity else '0';
    empty     <= '1' when count = 0 else '0';
end Behavioral;