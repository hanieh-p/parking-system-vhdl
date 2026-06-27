  library ieee;
use ieee.std_logic_1164.all;

entity smart_parking_top is
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
        seg_units_out   : out std_logic_vector(6 downto 0);  -- units digit
        seg_tens_out    : out std_logic_vector(6 downto 0)   -- tens digit (for showing "10")
    );
end smart_parking_top;

architecture Structural of smart_parking_top is
    component sensor_module is
        Port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            SENSOR     : in  std_logic;
            car_detect : out std_logic
        );
    end component;

    component counter_module is
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
    end component;

    component gate_control is
        Port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            car_at_gate : in  std_logic;
            full        : in  std_logic;
            gate_open   : out std_logic;
            gate_closed : out std_logic;
            deny_led    : out std_logic
        );
    end component;

    component seven_segment is
        Port (
            bin_in    : in  std_logic_vector(3 downto 0);
            seg_units : out std_logic_vector(6 downto 0);
            seg_tens  : out std_logic_vector(6 downto 0)
        );
    end component;

    signal det_entry     : std_logic;
    signal det_exit      : std_logic;
    signal parking_full  : std_logic;
    signal parking_empty : std_logic;
    signal count_sig     : std_logic_vector(3 downto 0);

begin

    U1 : sensor_module
        port map (
            clk        => clk,
            reset      => reset,
            SENSOR     => sensor_entry,
            car_detect => det_entry
        );

    U2 : sensor_module
        port map (
            clk        => clk,
            reset      => reset,
            SENSOR     => sensor_exit,
            car_detect => det_exit
        );

    U3 : counter_module
        generic map ( max_capacity => 10 )
        port map (
            clk       => clk,
            reset     => reset,
            car_enter => det_entry,
            car_exit  => det_exit,
            count_out => count_sig,
            full      => parking_full,
            empty     => parking_empty
        );

    U4 : gate_control
        port map (
            clk         => clk,
            reset       => reset,
            car_at_gate => sensor_gate,
            full        => parking_full,
            gate_open   => gate_open_out,
            gate_closed => gate_closed_out,
            deny_led    => deny_led_out
        );

    U5 : seven_segment
        port map (
            bin_in    => count_sig,
            seg_units => seg_units_out,
            seg_tens  => seg_tens_out
        );

    count_display <= count_sig;
    full_led_out  <= parking_full;

end Structural;