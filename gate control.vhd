   library ieee;
use ieee.std_logic_1164.all;

entity gate_control is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        car_at_gate : in  std_logic;  
        full        : in  std_logic;  
        gate_open   : out std_logic;
        gate_closed : out std_logic;
        deny_led    : out std_logic   
    );
end gate_control;

architecture Behavioral of gate_control is
    type state_type is (IDLE, CHECKING, OPEN_GATE, CLOSE_GATE, WAIT_CLEAR, DENY);
    signal state      : state_type := IDLE;
    signal timer      : integer range 0 to 500 := 0;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            state       <= IDLE;
            timer       <= 0;
            gate_open   <= '0';
            gate_closed <= '1';
            deny_led    <= '0';
        elsif rising_edge(clk) then
            gate_open   <= '0';
            gate_closed <= '0';
            deny_led    <= '0';

            case state is
                when IDLE =>
                    gate_closed <= '1';
                    if car_at_gate = '1' then
                        state <= CHECKING;
                    end if;

                when CHECKING =>
                    gate_closed <= '1';
                    if full = '1' then
                        state <= DENY;
                    else
                        state <= OPEN_GATE;
                        timer <= 0;
                    end if;

                when OPEN_GATE =>
                    gate_open <= '1';
                    if timer < 500 then
                        timer <= timer + 1;
                    else
                        state <= CLOSE_GATE;
                        timer <= 0;
                    end if;

                when CLOSE_GATE =>
                    gate_closed <= '1';
                    state <= WAIT_CLEAR;

                when WAIT_CLEAR =>
                    gate_closed <= '1';
                    if car_at_gate = '0' then
                        state <= IDLE;
                    end if;

                when DENY =>
                    deny_led <= '1';
                    gate_closed <= '1';
                    if car_at_gate = '0' then
                        state <= IDLE;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;