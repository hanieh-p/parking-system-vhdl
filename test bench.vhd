  library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_smart_parking is
end tb_smart_parking;

architecture sim of tb_smart_parking is

    component smart_parking_top
        Port (
            clk             : in  std_logic;
            reset           : in  std_logic;
            sensor_entry    : in  std_logic;
            sensor_exit     : in  std_logic;
            sensor_gate     : in  std_logic;
            gate_open_out   : out std_logic;
            gate_closed_out : out std_logic;
            deny_led_out    : out std_logic;
            full_led_out    : out std_logic;
            count_display   : out std_logic_vector(3 downto 0);
            seg_units_out   : out std_logic_vector(6 downto 0);
            seg_tens_out    : out std_logic_vector(6 downto 0)
        );
    end component;

    signal clk    : std_logic := '0';
    signal reset  : std_logic := '1';
    signal s_in   : std_logic := '0';
    signal s_out  : std_logic := '0';
    signal s_gate : std_logic := '0';
    signal go     : std_logic;
    signal gc     : std_logic;
    signal dl     : std_logic;
    signal fl     : std_logic;
    signal cnt    : std_logic_vector(3 downto 0);
    signal seg_u  : std_logic_vector(6 downto 0);
    signal seg_t  : std_logic_vector(6 downto 0);

    constant CLK_PERIOD : time := 20 ns;
    constant PULSE_W    : time := 40 ns;
    constant SETTLE     : time := 500 ns;

    -- one entry pulse on sensor_entry
    procedure do_entry(signal s : out std_logic) is
    begin
        s <= '1'; wait for PULSE_W;
        s <= '0'; wait for SETTLE;
    end procedure;

    -- one exit pulse on sensor_exit
    procedure do_exit(signal s : out std_logic) is
    begin
        s <= '1'; wait for PULSE_W;
        s <= '0'; wait for SETTLE;
    end procedure;

    procedure do_gate_pass(signal s : out std_logic; width : time) is
    begin
        s <= '1'; wait for width;
        s <= '0'; wait for 1000 ns;
    end procedure;

begin

    UUT : smart_parking_top
        port map (
            clk             => clk,
            reset           => reset,
            sensor_entry    => s_in,
            sensor_exit     => s_out,
            sensor_gate     => s_gate,
            gate_open_out   => go,
            gate_closed_out => gc,
            deny_led_out    => dl,
            full_led_out    => fl,
            count_display   => cnt,
            seg_units_out   => seg_u,
            seg_tens_out    => seg_t
        );

    clk <= not clk after CLK_PERIOD / 2;

    process
    begin
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 50 ns;

        do_entry(s_in);                     -- count= 1
        do_entry(s_in);                     -- count= 2
        do_entry(s_in);                     -- count= 3
        do_exit(s_out);                     -- count= 2
        do_entry(s_in);                     -- count= 3
        do_entry(s_in);                     -- count= 4
        do_exit(s_out);                     -- count= 3
        do_exit(s_out);                     -- count= 2

        wait for 200 ns;
        do_gate_pass(s_gate, 12000 ns);     

        do_entry(s_in);                     -- count= 3
        do_entry(s_in);                     -- count= 4
        do_exit(s_out);                     -- count= 3
        do_entry(s_in);                     -- count= 4
        do_entry(s_in);                     -- count= 5
        do_entry(s_in);                     -- count= 6
        do_exit(s_out);                     -- count= 5
        do_entry(s_in);                     -- count= 6
        do_entry(s_in);                     -- count= 7
        do_entry(s_in);                     -- count= 8
        do_entry(s_in);                     -- count= 9
        do_entry(s_in);                     -- count= 10 (full)
        do_entry(s_in);                     -- still 10

        wait for 200 ns;
        do_gate_pass(s_gate, 12000 ns);     -- should be denied, gate stays closed

        do_exit(s_out);                     -- count= 9
        do_exit(s_out);
			 -- count= 8
        do_entry(s_in);                     -- count= 9
        do_exit(s_out);                     -- count= 8
        do_exit(s_out);                     -- count= 7
        do_exit(s_out);                     -- count= 6

        wait for 200 ns;
        do_gate_pass(s_gate, 12000 ns);

        wait for 500 ns;
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 200 ns;
		
        do_entry(s_in);
        do_entry(s_in);
        do_exit(s_out);
        do_entry(s_in);
        do_entry(s_in);
        do_entry(s_in);
        do_exit(s_out);
        do_exit(s_out);
        do_entry(s_in);

        wait for 2000 ns;
        wait;
    end process;

end sim;