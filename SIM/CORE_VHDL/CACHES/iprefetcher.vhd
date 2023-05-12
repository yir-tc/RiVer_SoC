library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iprefetcher is
    generic (
        WIDTH : integer := 4
    );
    port (
        -- general interface
        clk, reset_n : in std_logic;

        -- prefetcher/ram interface
        RAM_DATA        : in std_logic_vector(31 downto 0);
        RAM_ADR         : out std_logic_vector(31 downto 0);
        RAM_ADR_VALID   : out std_logic;
        RAM_ACK         : in std_logic;

        -- cache 2 prefetcher
        NEXT_ID_SC          : in std_logic_vector(27 downto 0);
        NEXT_ID_VALID_SC    : in std_logic;

        -- prefetcher 2 cache
        IP_VALID_SC     : out std_logic; -- the tag correspond to the line (we're not loading a new line)
        IP_CURR_ID_SC   : out std_logic_vector(27 downto 0); -- address "id": address without offset
        IP_LINE_SC      : out std_logic_vector((WIDTH*32)-1 downto 0); -- instr if addr in fifo and transfer over
        
        IP_TRANSFER_SC  : out std_logic; -- true if prefetch FSM not in IDLE mode

        P_RESET_TRANSFER : in std_logic
    );
end entity;

architecture archi of iprefetcher is
-- external cache line
signal data : std_logic_vector((32*WIDTH)-1 downto 0);

-- fsm
type state is (idle, wait_mem, update, transfer, reset);
signal EP, EF : state; 
signal dbg_st : std_logic_vector(1 downto 0);
signal dbg_next_idle : std_logic;
signal dbg_cpt : std_logic_vector(3 downto 0);

begin

IP_TRANSFER_SC <= '1' when not (EP = idle) and not(EP = transfer) else '0';
IP_LINE_SC  <= data;

fsm_transition : process(clk, reset_n, P_RESET_TRANSFER)
begin  
    if reset_n = '0' then 
        EP  <=  idle; 
    elsif rising_edge(clk) then 
        EP  <=  EF; 
    end if; 
end process; 

fsm_output : process(clk, reset_n, EP, RAM_ACK, RAM_DATA, NEXT_ID_SC, NEXT_ID_VALID_SC)
variable cpt                : integer;
begin
    dbg_cpt <= std_logic_vector( to_signed(cpt, dbg_cpt'length));
    dbg_next_idle <= '0';

    case EP is 
        when idle =>
            if NEXT_ID_VALID_SC = '1' and reset_n = '1' then 
                EF <= wait_mem;
                
                -- align address then send it to the RAM
                RAM_ADR(31 downto 4)    <=  NEXT_ID_SC;
                RAM_ADR(3 downto 0)     <=  "0000";
                RAM_ADR_VALID           <=  '1';
                
                -- invalid data still in prefetcher, and update tag
                IP_CURR_ID_SC           <=  NEXT_ID_SC;
                IP_VALID_SC             <= '0'; 

                cpt := 0;
            else
                EF <= idle;
                dbg_next_idle <= '1';
                RAM_ADR_VALID <= '0';
            end if;
        when wait_mem =>
            RAM_ADR_VALID <= '0';

            if rising_edge(clk) then
                if RAM_ACK = '1' then 
                    EF <= update;     
                    data(31 downto 0)  <= RAM_DATA;
                    cpt := cpt + 1;
                else
                    EF  <=  wait_mem; 
                end if;
            end if;

            if P_RESET_TRANSFER = '1' then
                EF <= reset;
            end if;
        when update =>    
            assert false report "update" severity note;  
            RAM_ADR_VALID <= '0';

            if RAM_ACK = '0' then 
                EF <= transfer; 
                IP_VALID_SC <=  '1';  
            elsif rising_edge(clk) then
                if cpt < WIDTH + 1 then
                    data((32*(cpt))-1 downto (32*(cpt-1))) <= RAM_DATA;
                else
                    report "prefetcher counter overflow" severity error;
                end if;
                cpt := cpt + 1;
            end if; 

            if P_RESET_TRANSFER = '1' then
                EF <= reset;
            end if;
        when transfer =>
            if rising_edge(clk) then
                EF <= idle;
            end if;
        when reset =>
            if RAM_ACK = '0' then
                EF <= idle;
                IP_VALID_SC <= '0';
            end if;
    end case; 
end process;

dbg_st <= "00" when EP = idle else
            "01" when EP = wait_mem else
            "10" when EP = update else
            "11";

end architecture;