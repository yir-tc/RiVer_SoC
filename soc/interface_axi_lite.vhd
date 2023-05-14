library ieee;
use ieee.std_logic_1164.all;

entity interface_axi_lite is 
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
        DI_READ_DATA : out std_logic_vector(31 downto 0);
        
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
        BREADY : out std_logic
    );
end entity interface_axi_lite;

architecture behavior of interface_axi_lite is

-- Interface FSM
type state is (idle, read_wait, read_transfer,
                     write_addr_wait, write_data_wait, write_resp);
signal EP, EF : state; 

-- Debug signals
signal dbg_st : std_logic_vector(2 downto 0);

begin
    -- Do the CPU need to stall ?
    IC_STALL <= '1' when not (EP = idle) else
                '0';

    -- FSM
    fsm_transition: process (clk, reset_n)
    begin 
        if reset_n = '0' then
            EP <= idle;
        elsif rising_edge(clk) then 
            EP <=  EF; 
        end if; 
    end process;

    fsm_output : process (clk, EP, II_ADDR, II_VALID,
                                   DI_ADDR, DI_WRITE_DATA, DI_STROBE, DI_VALID, DI_WRITE,
                                   ARREADY,
                                   RDATA, RRESP, RVALID,
                                   AWREADY,
                                   WREADY,
                                   BRESP, BVALID,
                                   II_ACK, DI_ACK)
    
    variable address : std_logic_vector(31 downto 0);
    variable data : std_logic_vector(31 downto 0);
    variable strobe : std_logic_vector(3 downto 0);
    variable instr : boolean; -- weither the read is instruction or data;

    begin
        -- no idea why it's not working outside of this process
        if II_ACK = '1' then
            II_DONE <= '0';
        end if;
        if DI_ACK = '1' then
            DI_DONE <= '0';
        end if;

        case EP is
            when idle =>
                -- reset AXI control signals
                ARVALID <= '0';
                RREADY  <= '0';
                AWVALID <= '0';
                WVALID  <= '0';
                BREADY  <= '0';
                
                -- priority: intruction read > data write > data read
                -- shouldn't matter (if we ask for instruction it's unlikely we would ask
                -- for data at the same time)
                if II_VALID = '1' then
                    address := II_ADDR;
                    instr   := true;

                    EF <= read_wait;
                elsif DI_VALID = '1' then
                    if DI_WRITE = '1' then
                        address := DI_ADDR;
                        data    := DI_WRITE_DATA;
                        strobe  := DI_STROBE;

                        EF <= write_addr_wait;
                    elsif DI_WRITE = '0' then
                        address := DI_ADDR;
                        instr   := false;

                        EF <= read_wait;
                    end if;
                end if;
            when read_wait =>
                ARADDR  <= address;
                ARVALID <= '1';

                if ARREADY = '1' then
                    ARVALID <= '0';
                    RREADY  <= '1';
                    EF      <= read_transfer;
                end if;
            when read_transfer =>
                if RVALID = '1' then
                    -- TODO: should trigger exception when RRESP != RESP_OKAY
                    RREADY  <= '0';

                    if instr then
                        II_DATA <= RDATA;
                        II_DONE <= '1';
                    else
                        DI_READ_DATA <= RDATA;
                        DI_DONE <= '1';
                    end if;

                    EF      <= idle;
                end if;
            when write_addr_wait =>
                AWADDR <= address;
                AWVALID <= '1';

                if AWREADY = '1' then
                    AWVALID <= '0';
                    EF <= write_data_wait;
                end if;
            when write_data_wait =>
                -- maybe do this in write_addr_wait ?
                WDATA <= data;
                WSTRB <= strobe;
                WVALID <= '1';
                
                if WREADY = '1' then
                    WVALID <= '0';
                    BREADY <= '1';
                    EF <= write_resp;
                end if;
            when write_resp =>
                if BVALID = '1' then
                    BREADY  <= '0';
                    DI_DONE <= '1';
                    -- TODO: handle the BRESP
                    EF <= idle;
                end if;
        end case;
    end process;

    dbg_st <= "000" when EP = idle else
                "001" when EP = read_wait else
                "010" when EP = read_transfer else
                "011" when EP = write_addr_wait else
                "100" when EP = write_data_wait else
                "101" when EP = write_resp else
                "111";
end architecture;