library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
        RREADY : in std_logic;

        -- Write address channel
        AWADDR : in std_logic_vector(31 downto 0);
        AWPROT : in std_logic_vector(2 downto 0); -- not implemented
        AWVALID : in std_logic;
        AWREADY : out std_logic;

        -- Write data channel
        WDATA : in std_logic_vector(31 downto 0);
        WSTRB : in std_logic_vector(3 downto 0); -- A3.4.3
        WVALID : in std_logic;
        WREADY : out std_logic;

        -- Write response channel
        BRESP :  out std_logic_vector(1 downto 0);
        BVALID : out std_logic;
        BREADY : in std_logic
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

-- Write address channel
signal AWADDR : std_logic_vector(31 downto 0);
signal AWPROT : std_logic_vector(2 downto 0); -- not implemented
signal AWVALID : std_logic;
signal AWREADY : std_logic;

-- Write data channel
signal WDATA : std_logic_vector(31 downto 0);
signal WSTRB : std_logic_vector(3 downto 0); -- A3.4.3
signal WVALID : std_logic;
signal WREADY : std_logic;

-- Write response channel
signal BRESP : std_logic_vector(1 downto 0);
signal BVALID : std_logic;
signal BREADY : std_logic;

signal test_addr : std_logic_vector(31 downto 0);
signal test_data : std_logic_vector(31 downto 0);
signal test_strobe : std_logic_vector(3 downto 0);

begin 
    ram: ram_axi_lite port map (
        clk, reset_n,
        ARADDR, ARPROT, ARVALID, ARREADY,
        RDATA, RRESP, RVALID, RREADY,
        AWADDR, AWPROT, AWVALID, AWREADY,
        WDATA, WSTRB, WVALID, WREADY,
        BRESP, BVALID, BREADY
    );

    clk <= not clk after 5 ns;
    reset_n <= '0', '1' after 6 ns; 

    tb: process is
    procedure ram_axi_read_word(
        signal address : in std_logic_vector(31 downto 0);
        signal data    : out std_logic_vector(31 downto 0)) is
    begin
        -- Send address
        ARADDR <= address;
        ARVALID <= '1';

        -- RAM should wait 1 cycle (idle -> ack) then 8 cycles (ack -> ack) before setting ARREADY
        wait for 90 ns;
        assert ARREADY = '1' report "RAM didn't set ARREADY" severity failure;

        -- We're ready to get data
        ARVALID <= '0';
        RREADY <= '1';
        
        wait for 10 ns;
        assert RVALID = '1' report "RAM didn't set RVALID" severity failure;
        assert RRESP = "00" report "RAM returned an error" severity failure;
        
        data <= RDATA;
        RREADY <= '0';

        wait for 0 ns; -- because VHDL is retarded
    end procedure;

    procedure ram_axi_write_word(
        signal address : in std_logic_vector(31 downto 0);
        signal data    : in std_logic_vector(31 downto 0);
        signal strobe  : in std_logic_vector(3 downto 0)) is
    begin
        -- Send address
        AWADDR <= address;
        AWVALID <= '1';

        -- RAM should wait 1 cycle (idle -> ack) then 8 cycles (ack -> ack) before setting AWREADY
        wait for 90 ns;
        assert AWREADY = '1' report "RAM didn't set AWREADY" severity failure;

        -- We're ready to send data
        AWVALID <= '0';
        WDATA <= data;
        WSTRB <= strobe;
        WVALID <= '1';
        
        wait for 10 ns;
        assert WREADY = '1' report "RAM didn't set WREADY" severity failure;

        WVALID <= '0';
        BREADY <= '1';
        
        wait for 10 ns;
        assert BVALID = '1' report "RAM didn't set BVALID" severity failure;
        assert BRESP = "00" report "RAM returned an error" severity failure;

        BREADY <= '0';

        wait for 0 ns; -- because VHDL is retarded
    end procedure;

    begin
        test_addr <= x"0000bee0";
        test_data <= x"cafebabe";
        test_strobe <= "1111";
        wait for 20 ns;
        ram_axi_write_word(test_addr, test_data, test_strobe);

        test_data <= x"00000000";
        wait for 10 ns; -- idle state
        ram_axi_read_word(test_addr, test_data);
        assert test_data = x"cafebabe" report "RAM returned invalid data" severity failure;

        test_data <= x"0000beef";
        test_strobe <= "0011";
        wait for 20 ns;
        ram_axi_write_word(test_addr, test_data, test_strobe);

        test_data <= x"00000000";
        wait for 10 ns;
        ram_axi_read_word(test_addr, test_data);
        assert test_data = x"cafebeef" report "RAM returned invalid data" severity failure;

        wait for 10 ns;
        assert false report "End of test" severity failure;
    end process;
end architecture;
