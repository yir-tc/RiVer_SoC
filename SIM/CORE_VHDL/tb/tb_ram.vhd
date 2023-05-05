library ieee; 
use ieee.std_logic_1164.all;

entity tb_ram is 
end entity tb_ram; 

architecture behavior of tb_ram is

component ram_axi_lite
    port (
        -- Global interface
        clk, reset_n : in std_logic;

        -- Read adress channel
        ARADDR : in std_logic_vector(31 downto 0);
        ARPROT : in std_logic_vector(2 downto 0); -- not implemented
        ARVALID : in std_logic;
        ARREADY : out std_logic;
        
        -- Read data channel 
        RDATA : out std_logic_vector(31 downto 0);
        RRESP : out std_logic_vector(1 downto 0);
        RVALID : out std_logic;
        RREADY : in std_logic
    );
end component ram_axi_lite;

signal clk, reset_n : std_logic := '0'; 

-- Read adress channel
signal ARADDR : std_logic_vector(31 downto 0);
signal ARPROT : std_logic_vector(2 downto 0); -- not implemented
signal ARVALID : std_logic;
signal ARREADY : std_logic;

-- Read data channel 
signal RDATA : std_logic_vector(31 downto 0);
signal RRESP : std_logic_vector(1 downto 0);
signal RVALID : std_logic;
signal RREADY : std_logic;

begin 
    ram: ram_axi_lite port map (
        clk, reset_n,
        ARADDR, ARPROT, ARVALID, ARREADY,
        RDATA, RRESP, RVALID, RREADY
    );

    clk <= not clk after 5 ns;
    reset_n <= '0', '1' after 6 ns; 

    tb: process is
    begin
        wait for 20 ns;

        ARADDR <= x"deadbeef";
        ARVALID <= '1';

        wait for 90 ns;
        assert ARREADY = '1' report "RAM didn't set ARREADY" severity failure;
        
        RREADY <= '1';

        wait for 10 ns;
        assert RVALID = '1' report "RAM didn't set RVALID" severity failure;
        assert RRESP = "00" report "RAM returned an error" severity failure;
        assert RDATA = x"41414141" report "RAM didn't send valid data" severity failure;

        wait for 20 ns;
        assert (RVALID = '0' and ARREADY = '0') report "RAM didn't reset RVALID/ARREADY" severity failure;

        assert false report "End of test" severity failure;
    end process;
end architecture;
