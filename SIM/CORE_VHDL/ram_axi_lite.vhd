library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_axi_lite is
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
end entity ram_axi_lite;

architecture behavior of ram_axi_lite is

-- Import C functions
function read_mem(adr : unsigned) return integer is 
begin 
    assert false severity failure;
end read_mem; 
attribute foreign of read_mem : function is "VHPIDIRECT read_mem";    

-- A3.4.4
constant RESP_OKAY : std_logic_vector(1 downto 0) := "00";
constant RESP_EXOKAY : std_logic_vector(1 downto 0) := "01";
constant RESP_SLVERR : std_logic_vector(1 downto 0) := "10";
constant RESP_DECERR : std_logic_vector(1 downto 0) := "11";

-- RAM FSM
type state is (idle, ack, transfer);
signal EP, EF : state; 

-- Debug signals
signal dbg_st : std_logic_vector(1 downto 0);
signal dbg_cycles : std_logic_vector(3 downto 0);

begin
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

    fsm_output: process (clk, EP, ARADDR, ARPROT, ARVALID, RREADY)
    variable cycles : integer := 0; -- used to simulate RAM latency cycles
    variable address : unsigned(31 downto 0);

    begin 
        case EP is
            when idle =>
                -- drive low every channel control signals
                ARREADY <= '0';
                RVALID <= '0';

                if ARVALID = '1' then 
                    EF <= ack;
                    cycles := 0;
                end if;
            when ack =>
                if rising_edge(clk) then
                    cycles := cycles + 1;
                    if cycles = 8 then
                        -- acknowledge master request, keep address in memory
                        address := unsigned(ARADDR);
                        ARREADY <= '1';
                        EF <= transfer;
                    end if;
                end if;
            when transfer =>
                -- drive adress channel signals low
                ARREADY <= '0';

                -- drive data channel signals high
                RDATA <= std_logic_vector(to_signed(read_mem(address), 32));
                RRESP <= RESP_OKAY;
                RVALID <= '1';

                if RREADY = '1' then
                    EF <= idle;
                end if;
        end case;
        dbg_cycles <= std_logic_vector(to_unsigned(cycles, 4));
    end process;

    dbg_st <= "00" when EP = idle else
                "01" when EP = ack else
                "10" when EP = transfer else
                "11";    
end architecture behavior;
