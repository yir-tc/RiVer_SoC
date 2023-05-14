library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity icache is 
    generic (
        WAYS : integer := 256;
        WIDTH : integer := 4
    );
    port(
        -- global interface
        clk, reset_n    :   in  std_logic;

        -- core interface
        ADR_SI          :   in  std_logic_vector(31 downto 0);
        ADR_VALID_SI    :   in  std_logic;
        IC_INST_SI      :   out std_logic_vector(31 downto 0);
        IC_STALL_SI     :   out std_logic;

        -- ram inteface
        RAM_DATA        :   in  std_logic_vector(31 downto 0);
        RAM_ADR         :   out std_logic_vector(31 downto 0);
        RAM_ADR_VALID   :   out std_logic;
        RAM_ACK         :   in  std_logic
    );
end icache;

architecture archi of icache is 

component iprefetcher is 
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

        IP_TRANSFER_SC  : out std_logic; -- true if addr in fifo and transfer not over
        
        P_RESET_TRANSFER : in std_logic
    );
end component;

-- log2(WIDTH) bits to adress the word in the cache line)
-- and +2 bits to adress the byte into the word
-- (could move this in util.vhdl)
constant N_BITS_OFFSET : integer := integer(ceil(log2(real(WIDTH)))) + 2;
constant N_BITS_WAYS : integer := integer(ceil(log2(real(WAYS))));
constant N_BITS_TAG : integer := 32 - N_BITS_WAYS - N_BITS_OFFSET;

-- prefetch signals
signal prefetch_reset : std_logic;
signal prefetch_next_id : std_logic_vector(27 downto 0);
signal prefetch_next_id_valid : std_logic;

signal prefetch_ram_data : std_logic_vector(31 downto 0);
signal prefetch_ram_adr : std_logic_vector(31 downto 0);
signal prefetch_ram_adr_valid : std_logic;
signal prefetch_ram_ack : std_logic;

signal prefetch_valid : std_logic;
signal prefetch_id    : std_logic_vector(27 downto 0);
signal prefetch_line : std_logic_vector((WIDTH*32)-1 downto 0);
signal prefetch_stall : std_logic;

signal current_block_id : std_logic_vector(27 downto 0);
signal next_block_id : std_logic_vector(27 downto 0);

-- address parameters 
signal adr_tag      :   std_logic_vector((N_BITS_TAG - 1) downto 0);
signal adr_index    :   std_logic_vector((N_BITS_WAYS - 1) downto 0);
signal adr_offset   :   std_logic_vector((N_BITS_OFFSET - 1) downto 0);

-- cache datatypes (tag array, ways, validity bit array)
type tags_t is array (0 to (WAYS - 1)) of std_logic_vector((N_BITS_TAG - 1) downto 0);
signal tags : tags_t;
signal valid : std_logic_vector((WAYS - 1) downto 0);

type data_t is array (0 to (WIDTH - 1)) of std_logic_vector(31 downto 0);
type ways_t is array (0 to (WAYS - 1)) of data_t;
signal cache_ways : ways_t;

signal hit : std_logic := '0';

-- fsm
type state is (idle, wait_mem, update);
signal EP, EF : state; 

-- debug
signal dbg_cpt : std_logic_vector(3 downto 0);
signal dbg_st : std_logic_vector(1 downto 0);
signal dbg_valid_count : std_logic_vector(7 downto 0);
signal valid_count : integer := 0;
signal dbg_prefetch_start : std_logic;

begin 

adr_tag     <=  ADR_SI(31 downto (N_BITS_OFFSET + N_BITS_WAYS)); 
adr_index   <=  ADR_SI((N_BITS_WAYS + N_BITS_OFFSET- 1) downto N_BITS_OFFSET);
adr_offset  <=  ADR_SI((N_BITS_OFFSET - 1) downto 0);

current_block_id <= ADR_SI(31 downto 4);
next_block_id <= std_logic_vector(unsigned(current_block_id) + integer(WIDTH/4));

-- miss detection 
hit <=  '1' when adr_tag = tags(to_integer(unsigned(adr_index))) and valid(to_integer(unsigned(adr_index))) = '1' else 
        '0';

IC_INST_SI  <=  cache_ways(to_integer(unsigned(adr_index)))(to_integer(unsigned(adr_offset((N_BITS_OFFSET - 1) downto 2)))) when hit = '1' else 
                x"00000000";

IC_STALL_SI <=  not(hit);

-- prefetcher
prefetcher: iprefetcher 
    generic map (
        WIDTH
    )
    port map (
        clk, reset_n,
        prefetch_ram_data, prefetch_ram_adr, prefetch_ram_adr_valid, prefetch_ram_ack,
        prefetch_next_id, prefetch_next_id_valid,
        prefetch_valid, prefetch_id, prefetch_line, 
        prefetch_stall, prefetch_reset
    );

-- succession des etats 
fsm_transition : process(clk, reset_n)
begin  
    if reset_n = '0' then 
        EP  <=  idle; 
    elsif rising_edge(clk) then 
        EP  <=  EF; 
    end if; 
end process; 

fsm_output : process(clk, EP, hit, 
    RAM_ACK, ADR_SI, ADR_VALID_SI, RAM_DATA,
    prefetch_ram_adr, prefetch_ram_adr_valid)

variable current_adr_tag    :   std_logic_vector((N_BITS_TAG - 1) downto 0);
variable current_adr_index  :   std_logic_vector((N_BITS_WAYS - 1) downto 0);
variable current_adr_offset :   std_logic_vector((N_BITS_OFFSET - 1) downto 0);

variable cpt : integer;

begin 
    prefetch_reset <= '0';

    case EP is 
        when idle =>
            -- prefetch/ram interface
            prefetch_ram_data <= RAM_DATA;
            RAM_ADR <= prefetch_ram_adr;
            RAM_ADR_VALID <= prefetch_ram_adr_valid;
            prefetch_ram_ack <= RAM_ACK;

            -- is the data in the cache ?
            if ADR_VALID_SI = '1' and reset_n = '1' and hit = '0' then 
                -- no, is the data in the prefetcher ?
                if prefetch_id = current_block_id then
                    -- yes, did the prefetcher finished the transfer ?
                    if prefetch_stall = '0' and prefetch_valid = '1' then
                        -- yes ! fetch one cache line from it
                        --cache_ways(to_integer(unsigned(adr_index)))(0) <= prefetch_line(31 downto 0);
                        --cache_ways(to_integer(unsigned(adr_index)))(1) <= prefetch_line(63 downto 32);
                        --cache_ways(to_integer(unsigned(adr_index)))(2) <= prefetch_line(95 downto 64);
                        --cache_ways(to_integer(unsigned(adr_index)))(3) <= prefetch_line(127 downto 96);
                        for i in 0 to WIDTH - 1 loop
                            cache_ways(to_integer(unsigned(adr_index)))(i) <= prefetch_line((32 * (i + 1)) - 1 downto (32 * i));
                        end loop;
                        
                        tags(to_integer(unsigned(adr_index)))          <= adr_tag; 
                        valid(to_integer(unsigned(adr_index)))         <= '1';  
        
                        -- prefetch next line
                        prefetch_next_id <= next_block_id;
                        prefetch_next_id_valid <= '1';

                        dbg_prefetch_start <= '0';

                        RAM_ADR_VALID <= '0';
                        EF <= idle;
                    else
                        -- no, lets loop until it does (maybe add another state for this ?)
                        dbg_prefetch_start <= '1';

                        EF <= idle;
                    end if;
                else
                    -- is the prefetcher stalling anyway ?
                    if prefetch_stall = '1' then
                        -- reset the prefetcher and invalid adress so it doesn't
                        -- start a transfer while we're also doing one
                        prefetch_reset <= '1';
                        prefetch_next_id_valid <= '0';

                        -- the reset will put the prefetcher in a state
                        -- where he can only go out if RAM acknowledged the
                        -- ongoing request
                        EF <= idle;
                    else
                        -- still no, hard miss
                        EF <= wait_mem;
                        
                        -- align address then send it to the RAM
                        RAM_ADR(31 downto 4)    <=  ADR_SI(31 downto 4);
                        RAM_ADR(3 downto 0)     <=  "0000";
                        RAM_ADR_VALID           <=  '1';
                        
                        valid_count <= valid_count + 1;
                        dbg_valid_count <= std_logic_vector(to_signed(valid_count, 8));
                        dbg_prefetch_start <= '0';

                        -- save adress parameters for later use
                        current_adr_tag         :=  ADR_SI(31 downto (N_BITS_WAYS + N_BITS_OFFSET));
                        current_adr_index       :=  ADR_SI((N_BITS_WAYS + N_BITS_OFFSET - 1) downto N_BITS_OFFSET);
                        
                        cpt := 0;
                    end if;
                end if;
            else
                -- yes, hit!
                if ADR_VALID_SI = '1' and reset_n = '1' then
                    if next_block_id /= prefetch_id and prefetch_stall = '0' then
                        -- prefetch the next block if not doing it already
                        prefetch_next_id <= next_block_id;
                        prefetch_next_id_valid <= '1';
                    end if;
                    dbg_prefetch_start <= '1';
                end if;
                
                EF <= idle;
            end if;
        when wait_mem =>
            RAM_ADR_VALID <= '0';
            prefetch_next_id_valid <= '0';

            if RAM_ACK = '1' then 
                EF <= update; 

                cache_ways(to_integer(unsigned(current_adr_index)))(0)  <= RAM_DATA;
                tags(to_integer(unsigned(current_adr_index)))           <= current_adr_tag; 
                valid(to_integer(unsigned(current_adr_index)))          <= '0';  

                dbg_prefetch_start <= '0';
            else
                EF  <=  wait_mem; 
            end if;
        when update =>  
            RAM_ADR_VALID <= '0';
            prefetch_next_id_valid <= '0';

            if RAM_ACK = '0' then 
                EF <= idle; 
                valid(to_integer(unsigned(current_adr_index))) <=  '1';  

                -- prefetch the next block
                prefetch_next_id <= next_block_id;
                prefetch_next_id_valid <= '1';            
            elsif rising_edge(clk) then -- temp solution because we send 1 word/cycle
                                        -- basically, we need to find a proper way to still increment cpt event if RAM_DATA didn't change
                                        -- (we can have to consecutive same words)
                EF <= update;
                if cpt < WIDTH then
                    cache_ways(to_integer(unsigned(current_adr_index)))(cpt) <= RAM_DATA;
                else
                    report "counter overflow" severity error;
                end if;

                cpt := cpt + 1;
            end if;  
    end case; 
    dbg_cpt <= std_logic_vector(to_signed(cpt, 4));
end process; 

dbg_st <= "00" when EP = idle else
          "01" when EP = wait_mem else
          "10" when EP = update else
          "11";
end archi;