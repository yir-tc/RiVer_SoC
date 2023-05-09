library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_interface is 
end entity tb_interface; 

architecture behavior of tb_interface is

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

component interface_axi_lite is
    port (
        -- Global interface
        clk, reset_n : in std_logic;

        -- I-Cache/Intf signals
        II_ADDR : in std_logic_vector(31 downto 0);
        II_VALID : in std_logic;
        II_DATA : out std_logic_vector(31 downto 0);
        
        II_DONE : out std_logic;
        II_ACK : in std_logic;

        -- D-Cache/Intf signals
        DI_ADDR : in std_logic_vector(31 downto 0);
        DI_WRITE_DATA : in std_logic_vector(31 downto 0);
        DI_STROBE : in std_logic_vector(3 downto 0);
        DI_VALID : in std_logic;
        DI_WRITE : in std_logic;
        DI_READ_DATA : out std_logic;
        
        DI_DONE : out std_logic;
        DI_ACK : in std_logic;
        
        -- Intf/CPU signals
        IC_STALL : out std_logic;

        -- Read address channel
        ARADDR : out std_logic_vector(31 downto 0);
        ARPROT : out std_logic_vector(2 downto 0); -- not implemented
        ARVALID : out std_logic;
        ARREADY : in std_logic;
        
        -- Read data channel 
        RDATA : in std_logic_vector(31 downto 0);
        RRESP : in std_logic_vector(1 downto 0);
        RVALID : in std_logic;
        RREADY : out std_logic;

        -- Write address channel
        AWADDR : out std_logic_vector(31 downto 0);
        AWPROT : out std_logic_vector(2 downto 0); -- not implemented
        AWVALID : out std_logic;
        AWREADY : in std_logic;

        -- Write data channel
        WDATA : out std_logic_vector(31 downto 0);
        WSTRB : out std_logic_vector(3 downto 0); -- A3.4.3
        WVALID : out std_logic;
        WREADY : in std_logic;

        -- Write response channel
        BRESP :  in std_logic_vector(1 downto 0);
        BVALID : in std_logic;
        BREADY : out std_logic);
end component interface_axi_lite;

-- Global interface
signal clk : std_logic := '0';
signal reset_n : std_logic;

-- I-Cache/Intf signals
signal II_ADDR : std_logic_vector(31 downto 0);
signal II_VALID : std_logic;
signal II_DATA : std_logic_vector(31 downto 0);

signal II_DONE : std_logic;
signal II_ACK : std_logic;

-- D-Cache/Intf signals
signal DI_ADDR : std_logic_vector(31 downto 0);
signal DI_WRITE_DATA : std_logic_vector(31 downto 0);
signal DI_STROBE : std_logic_vector(3 downto 0);
signal DI_VALID : std_logic;
signal DI_WRITE : std_logic;
signal DI_READ_DATA : std_logic;

signal DI_DONE : std_logic;
signal DI_ACK : std_logic;

-- Intf/CPU signals
signal IC_STALL : std_logic;

-- Read address channel
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
signal BRESP :  std_logic_vector(1 downto 0);
signal BVALID : std_logic;
signal BREADY : std_logic;

begin
    ram: ram_axi_lite port map (
        clk, reset_n,
        ARADDR, ARPROT, ARVALID, ARREADY,
        RDATA, RRESP, RVALID, RREADY,
        AWADDR, AWPROT, AWVALID, AWREADY,
        WDATA, WSTRB, WVALID, WREADY,
        BRESP, BVALID, BREADY
    );

    intf: interface_axi_lite port map(
        clk, reset_n,
        II_ADDR, II_VALID, II_DATA, II_DONE, II_ACK,
        DI_ADDR, DI_WRITE_DATA, DI_STROBE, DI_VALID, DI_WRITE, DI_READ_DATA, DI_DONE, DI_ACK,
        IC_STALL,
        ARADDR, ARPROT, ARVAlID, ARREADY,
        RDATA, RRESP, RVALID, RREADY,
        AWADDR, AWPROT, AWVALID, AWREADY,
        WDATA, WSTRB, WVALID, WREADY,
        BRESP, BVALID, BREADY
    );

    clk <= not clk after 5 ns;
    reset_n <= '0', '1' after 6 ns; 

    tb: process is
    begin
        II_ADDR <= x"0000bee0";
        II_VALID <= '1';

        wait on II_DONE for 150 ns;
        assert II_DATA = x"41414141" report "RAM returned invalid data" severity failure;
        II_ACK <= '1';

        wait for 15 ns;
        assert II_DONE = '0' report "Couldn't reset acknowledgment" severity failure;

        wait for 10 ns;
        assert false report "End of test" severity failure;
    end process;
end architecture;