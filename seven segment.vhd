  library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_segment is
    Port (
        bin_in    : in  std_logic_vector(3 downto 0); 
        seg_units : out std_logic_vector(6 downto 0); 
        seg_tens  : out std_logic_vector(6 downto 0)  
    );
end seven_segment;

architecture Behavioral of seven_segment is

    function decode_digit(d : integer) return std_logic_vector is
    begin
        case d is
            when 0 => return "0000001"; -- 0
            when 1 => return "1001111"; -- 1
            when 2 => return "0010010"; -- 2
            when 3 => return "0000110"; -- 3
            when 4 => return "1001100"; -- 4
            when 5 => return "0100100"; -- 5
            when 6 => return "0100000"; -- 6
            when 7 => return "0001111"; -- 7
            when 8 => return "0000000"; -- 8
            when 9 => return "0000100"; -- 9
            when others => return "1111111"; -- blank
        end case;
    end function;

    signal count_int : integer range 0 to 15;
    signal tens_digit : integer range 0 to 1;
    signal units_digit : integer range 0 to 9;

begin

    count_int  <= to_integer(unsigned(bin_in));

    -- with max_capacity = 10, count_int can only be 0..10, so tens is 0 or 1
    tens_digit  <= count_int / 10;
    units_digit <= count_int mod 10;

    seg_tens  <= "1111111" when tens_digit = 0 else decode_digit(tens_digit);
    seg_units <= decode_digit(units_digit);

end Behavioral;