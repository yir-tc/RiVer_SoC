library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_axi_lite is
    port (
        -- Global interface
        clk, reset_n : in std_logic;

        -- Read address channel
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
end entity ram_axi_lite;

architecture behavior of ram_axi_lite is

-- Import C functions
function read_mem(addr : integer) return integer is 
begin 
    assert false severity failure;
end read_mem; 
attribute foreign of read_mem : function is "VHPIDIRECT read_mem";    

function write_mem(addr : integer; data : integer; byte_select : integer; dtime : integer) return integer is 
begin 
    assert false severity failure;
end write_mem; 
attribute foreign of write_mem : function is "VHPIDIRECT write_mem";    

-- A3.4.4
constant RESP_OKAY : std_logic_vector(1 downto 0) := "00";
constant RESP_EXOKAY : std_logic_vector(1 downto 0) := "01";
constant RESP_SLVERR : std_logic_vector(1 downto 0) := "10";
constant RESP_DECERR : std_logic_vector(1 downto 0) := "11";

-- RAM FSM
type state is (idle, read_ack, read_transfer,
                     write_ack, write_wait_data, write_transfer, write_resp);
signal EP, EF : state; 

-- Debug signals
signal dbg_st : std_logic_vector(2 downto 0);
signal dbg_cycles : std_logic_vector(3 downto 0);

-- Time spent in simulation
signal dtime : integer := 0;

begin
    time_counter: process(clk)
    begin 
        dtime <= dtime + 5; 
    end process; 

    fsm_transition: process (clk, reset_n)
    begin 
        if reset_n = '0' then
            EP <= idle;
            -- A3.1.2
            -- RVALID <= '0'; put RVALID to x wtf ?
        elsif rising_edge(clk) then 
            EP <=  EF; 
        end if; 
    end process;

    fsm_output: process (clk, EP, ARADDR, ARPROT, ARVALID,
                                  AWADDR, AWPROT, AWVALID,
                                  WDATA,  WSTRB,  WVALID,
                                  RREADY, BREADY)
    variable cycles : integer := 0; -- used to simulate RAM latency cycles
    variable address : integer;
    variable data : integer;
    variable strobe : integer;

    variable ignore : integer;

    begin 
        case EP is
            when idle =>
                -- drive low every channel control signals
                ARREADY <= '0';
                AWREADY <= '0';

                WREADY <= '0';
                RVALID <= '0';
                BVALID <= '0';

                -- write have priority over read if AW/AR are both up
                if AWVALID = '1' then 
                    EF <= write_ack;
                    cycles := 0;
                elsif ARVALID = '1' then
                    EF <= read_ack;
                    cycles := 0;
                end if;
            when read_ack =>
                if rising_edge(clk) then
                    cycles := cycles + 1;
                    if cycles = 8 then
                        -- acknowledge master request, keep address in memory
                        address := to_integer(unsigned(ARADDR));
                        ARREADY <= '1';
                        EF <= read_transfer;
                    end if;
                end if;
            when read_transfer =>
                -- drive adress channel signals low
                ARREADY <= '0';

                -- drive data channel signals high
                RDATA <= std_logic_vector(to_signed(read_mem(address), 32));
                RRESP <= RESP_OKAY;
                RVALID <= '1';

                if RREADY = '1' then
                    EF <= idle;
                end if;
            when write_ack =>
                if rising_edge(clk) then
                    cycles := cycles + 1;
                    if cycles = 8 then
                        -- acknowledge master request, keep address in memory
                        address := to_integer(signed(AWADDR));
                        AWREADY <= '1';

                        EF <= write_wait_data;
                    end if;
                end if;
            when write_wait_data =>
                AWREADY <= '0';

                if WVALID = '1' then
                    -- acknowledge data/strobe
                    -- data := unsigned(WDATA);
                    -- strobe := unsigned(WSTRB);
                    ignore := write_mem(address, 
                        to_integer(signed(WDATA)), 
                        to_integer(unsigned(WSTRB)), dtime);
                    WREADY <= '1';

                    EF <= write_resp;
                end if;
            when write_transfer =>
            when write_resp =>
                WREADY <= '0';
                
                BRESP <= RESP_OKAY;
                BVALID <= '1';

                if BREADY = '1' then
                    EF <= idle;
                end if;
        end case;
        dbg_cycles <= std_logic_vector(to_unsigned(cycles, 4));
    end process;

    dbg_st <= "000" when EP = idle else
                "001" when EP = read_ack else
                "010" when EP = read_transfer else
                "011" when EP = write_ack else
                "100" when EP = write_wait_data else
                "101" when EP = write_transfer else
                "110" when EP = write_resp else 
                "111";    
end architecture behavior;
