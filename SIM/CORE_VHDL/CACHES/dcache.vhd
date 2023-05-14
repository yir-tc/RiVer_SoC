library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dcache is
	port(
        -- global interface
        clk, reset_n    :   in  std_logic;

        --core interface
        ADR_SM          :   in  std_logic_vector(31 downto 0);
        DATA_SM          :   in  std_logic_vector(31 downto 0);
        ADR_VALID_SM    :   in  std_logic; 	--not sure if useful, as we have load and store. If we combine them, then useful
        LOAD_SM			:   in  std_logic;
        STORE_SM		:   in  std_logic;
        SIZE_SM         :   in  std_logic_vector(3 downto 0);

        DATA_SC			:	out 	std_logic_vector(31 downto 0);
        STALL_SC		:	out 	std_logic;


        -- buffer cache interface



        --bus wrapper interface

            --read

            RAM_ADR : out std_logic_vector(31 downto 0);
            RAM_ADR_VALID          : out  std_logic;

            RAM_ACK      : in std_logic;
            RAM_DATA     : in std_logic_vector(31 downto 0);

            --write

            RAM_WRITE_ADR       : out std_logic_vector(31 downto 0);
            RAM_WRITE_DATA      : out std_logic_vector(31 downto 0);
            RAM_WRITE_BYTE_SEL  : out std_logic_vector(3  downto 0);
            RAM_STORE           : out std_logic;

            RAM_BUFFER_CACHE_POP : in std_logic


	);
end dcache;


architecture archi of dcache is

constant LINES : integer := 128;
constant WIDTH : integer := 4;


type tag_tab is array(0 to (LINES - 1)) of std_logic_vector(20 downto 0);

type data_t is array (0 to (WIDTH - 1)) of std_logic_vector(31 downto 0);
type ways_t is array (0 to (LINES - 1)) of data_t;


signal w0_tags: tag_tab;
signal w0_data : ways_t;
signal w0_data_valid : std_logic_vector((LINES - 1) downto 0);

signal w1_tags: tag_tab;
signal w1_data : ways_t;
signal w1_data_valid : std_logic_vector((LINES - 1)  downto 0);

signal lru_tab: std_logic_vector((LINES - 1) downto 0);
signal lru_adr : std_logic_vector(6 downto 0);
signal lru_val : std_logic;
signal set_lru : std_logic;

signal adr_tag      :   std_logic_vector(20 downto 0);
signal adr_index    :   std_logic_vector(6 downto 0);
signal adr_offset   :   std_logic_vector(3 downto 0);


signal hit_w0: std_logic;
signal hit_w1: std_logic;

signal hit: std_logic;

signal w0_data_res: std_logic_vector(31 downto 0);
signal w1_data_res: std_logic_vector(31 downto 0);
signal data_res: std_logic_vector(31 downto 0);

component buffer_cache
    port (
        -- global interface
        clk, reset_n : in std_logic;

        -- fifo commands & status
        PUSH, POP : in std_logic;
        EMPTY, FULL : out std_logic;

        -- fifo input data      TODO : remove LOAD and change all indexes
        DATA_C : in std_logic_vector(31 downto 0);
        ADR_C : in std_logic_vector(31 downto 0);
        STORE_C : in std_logic;
        BYTE_SEL_C : in std_logic_vector(3 downto 0); 

        -- output
        DATA_BC : out std_logic_vector(31 downto 0);
        ADR_BC : out std_logic_vector(31 downto 0);
        STORE_BC : out std_logic; 
        BYTE_SEL_BC : out std_logic_vector(3 downto 0)
    );
end component;

signal last_write_adr : std_logic_vector(31 downto 0);
signal last_write_data: std_logic_vector(31 downto 0);

signal last_write_adr_t : std_logic_vector(31 downto 0);
signal last_write_data_t: std_logic_vector(31 downto 0);

signal buffer_PUSH, buffer_POP : std_logic;
signal buffer_EMPTY, buffer_FULL : std_logic;

        -- fifo input data
signal buffer_DATA_C : std_logic_vector(31 downto 0);
signal buffer_ADR_C : std_logic_vector(31 downto 0);
signal buffer_STORE_C : std_logic;
signal buffer_BYTE_SEL_C : std_logic_vector(3 downto 0); 

        -- fifo output data
signal buffer_DATA_BC : std_logic_vector(31 downto 0);
signal buffer_ADR_BC :  std_logic_vector(31 downto 0);
signal buffer_STORE_BC : std_logic; 
signal buffer_BYTE_SEL_BC : std_logic_vector(3 downto 0);



--state machine
type state is (idle, wait_mem,update);
signal EP, EF: state;

signal etat : Integer;


signal cpt: integer;
signal inc_cpt : std_logic;
signal reset_cpt : std_logic;


--debug signals
signal dbg_w0_tag_adr : std_logic_vector(20 downto 0);
signal dbg_w1_tag_adr : std_logic_vector(20 downto 0);

signal dbg_w0_valid_adr : std_logic;
signal dbg_w1_valid_adr : std_logic;

signal dbg_lru_adr      : std_logic;

begin

--buffer cache to ram/wrapper

buffer_cache_inst: buffer_cache port map(clk,reset_n,buffer_PUSH, buffer_POP, buffer_EMPTY, buffer_FULL, 
    buffer_DATA_C, buffer_ADR_C, buffer_STORE_C, buffer_BYTE_SEL_C, 
    buffer_DATA_BC, buffer_ADR_BC, buffer_STORE_BC, buffer_BYTE_SEL_BC);

RAM_WRITE_ADR  <= buffer_ADR_BC;
RAM_WRITE_DATA <= buffer_DATA_BC;
RAM_WRITE_BYTE_SEL <= buffer_BYTE_SEL_BC;
RAM_STORE      <= not buffer_EMPTY;

buffer_POP     <= RAM_BUFFER_CACHE_POP;


buffer_DATA_C <= DATA_SM;
buffer_ADR_C <= ADR_SM;
buffer_STORE_C <= STORE_SM;
buffer_BYTE_SEL_BC <= SIZE_SM;


process(clk,reset_n) is
begin
    -- report "process write_addr";
    if reset_n = '0' then
        last_write_data <= x"00000000";
        last_write_adr  <= x"00000000";
    elsif rising_edge(clk) then
        last_write_adr <= last_write_adr_t;
        last_write_data<= last_write_data_t;
    end if;
end process;

process(clk,reset_n) is
begin
    -- report "process cpt";
    if reset_n = '0' then
        cpt <= -1;
    elsif rising_edge(clk) then
        if reset_cpt = '1' then 
            cpt <= 0;
        elsif inc_cpt = '1' then
            -- --report "incrementing cpt, value is " & INTEGER'Image(cpt);
            cpt <= cpt + 1;
        else 
            cpt <= cpt;
        end if;
    end if;
end process;

lru_synchro : process(clk,reset_n) is
begin
    if reset_n = '0' then
        for i in (LINES - 1) downto 0 loop
            lru_tab(i) <= '0';
        end loop;
    elsif rising_edge(clk) then
        if set_lru = '1' then
            lru_tab(to_integer(unsigned(lru_adr))) <= lru_val;
        end if;
    end if;
end process;

-- read to ram

-- align address then send it to the RAM
RAM_ADR(31 downto 4)    <=  ADR_SM(31 downto 4);
RAM_ADR(3 downto 0)     <=  "0000";

    -- RAM_ADR_VALID set in the fsm

--


adr_tag     <=  ADR_SM(31 downto 11); 
adr_index   <=  ADR_SM(10 downto 4);
adr_offset  <=  ADR_SM(3 downto 0);

dbg_w0_tag_adr <= w0_tags(to_integer(unsigned(adr_index)));
dbg_w1_tag_adr <= w1_tags(to_integer(unsigned(adr_index)));

dbg_w0_valid_adr <= w0_data_valid(to_integer(unsigned(adr_index)));
dbg_w1_valid_adr <= w1_data_valid(to_integer(unsigned(adr_index)));

dbg_lru_adr      <= lru_tab(to_integer(unsigned(adr_index)));


hit_w0 <= '1' when ( (w0_tags(to_integer(unsigned(adr_index))) = adr_tag) and (w0_data_valid(to_integer(unsigned(adr_index)))) = '1') else
		  '0';

hit_w1 <= '1' when ( (w1_tags(to_integer(unsigned(adr_index))) = adr_tag) and (w1_data_valid(to_integer(unsigned(adr_index)))) = '1') else
		  '0';

hit <= hit_w0 or hit_w1;


w0_data_res  <=  w0_data(to_integer(unsigned(adr_index)))(to_integer(unsigned(adr_offset(3 downto 2))));

--w0_data0(to_integer(unsigned(adr_index)))  when adr_offset(3 downto 2) = "00" else 
--                w0_data1(to_integer(unsigned(adr_index)))  when adr_offset(3 downto 2) = "01" else
--                w0_data2(to_integer(unsigned(adr_index)))  when adr_offset(3 downto 2) = "10" else
--                w0_data3(to_integer(unsigned(adr_index)))  when adr_offset(3 downto 2) = "11" else
--                x"00000000";

w1_data_res  <=  w1_data(to_integer(unsigned(adr_index)))(to_integer(unsigned(adr_offset(3 downto 2))));


--w1_data_res  <=  w1_data0(to_integer(unsigned(adr_index)))  when adr_offset(3 downto 2) = "00" else 
                --w1_data1(to_integer(unsigned(adr_index)))  when adr_offset(3 downto 2) = "01" else
                --w1_data2(to_integer(unsigned(adr_index)))  when adr_offset(3 downto 2) = "10" else
                --w1_data3(to_integer(unsigned(adr_index)))  when adr_offset(3 downto 2) = "11" else
                --x"00000000";

data_res <= w0_data_res when hit_w0 = '1' else
			w1_data_res when hit_w1 = '1' else
			x"00000000";

DATA_SC <= data_res;

STALL_SC <= (not hit) when LOAD_SM = '1' else
			buffer_FULL when STORE_SM = '1' else 
			'0'; --value doesn't matter if the proc doesn't ask anything to the cache.

fsm_transition : process(clk, reset_n)
begin  
    -- report "process fsm_transition";
    if reset_n = '0' then 
        EP  <=  idle; 
    elsif rising_edge(clk) then 
        EP  <=  EF; 


    end if; 
end process; 

fsm_state_transition : process(clk,EP,LOAD_SM,ADR_VALID_SM,hit,cpt,inc_cpt)
begin
    -- report "process fsm_state_transition";
    case EP is 
        when idle =>
            if LOAD_SM = '1' and ADR_VALID_SM = '1'then -- read
                if (hit = '0') then
                    EF <= wait_mem;
                else
                    EF <= idle;
                end if;
            else    --Write : no state change
                EF <= idle;
            end if;

        when wait_mem =>
            if cpt = (WIDTH - 1) and inc_cpt = '1' then
                EF <= update;
            else
                EF <= wait_mem;
            end if;
        when update =>
            EF <= idle;
    end case;
end process;

fsm_output_bis : process(clk,reset_n,EP,LOAD_SM,STORE_SM,ADR_VALID_SM,ADR_SM,hit,hit_w0,DATA_SM,last_write_data,last_write_adr,RAM_DATA,RAM_ACK)
begin

    if reset_n = '0' then
        -- report "reset data_valid";
        for i in (LINES - 1) downto 0 loop
            w0_data_valid(i) <= '0';
            w1_data_valid(i) <= '0';
        end loop;

    else
        -- report "process fsm_output";
        RAM_ADR_VALID <= '0';
        buffer_PUSH <= '0';
        reset_cpt <= '0';
        inc_cpt <= '0';
        set_lru <= '0';

        case EP is
            when idle =>
                etat <= 0;
                if LOAD_SM = '1' and ADR_VALID_SM = '1' then --Read
                    if (hit = '0') then --Miss
                        reset_cpt <= '1';
                        RAM_ADR_VALID <= '1';

                    else                --Hit
                        set_lru <= '1';
                        if hit_w0 = '1' then
                            lru_val <= '1';
                        else
                            lru_val <= '0';
                        end if;
                        lru_adr <= adr_index;
                    end if;

                elsif STORE_SM = '1' and ADR_VALID_SM = '1' then
                    if (DATA_SM = last_write_data and ADR_SM = last_write_adr) then --temp : don't repeat the writes.

                    else
                        buffer_PUSH <= '1';
                        last_write_data_t <= DATA_SM;
                        last_write_adr_t <= ADR_SM;
                    end if;
                end if;
            when wait_mem =>
                etat <= 1;
                -- --report "wait mem";
                if RAM_ACK = '1' then
                    
                    -- report "wait_mem : cpt = " & INTEGER'Image(cpt);
                    --write the value sent in the correct place.
                    if lru_tab(to_integer(unsigned(adr_index))) = '0' then
                        w0_data((to_integer(unsigned(adr_index))))(cpt) <= RAM_DATA;
                    else
                        w1_data((to_integer(unsigned(adr_index))))(cpt) <= RAM_DATA;
                    end if;
                    
                    inc_cpt <= '1';
                end if;

            when update =>
                -- report "state update";  
                etat <= 2;

                --set tag, validity bit and update the LRU value. 
                if lru_tab(to_integer(unsigned(adr_index))) = '0' then
                    W0_tags(to_integer(unsigned(adr_index))) <= adr_tag;
                    w0_data_valid(to_integer(unsigned(adr_index))) <= '1';
                    lru_val <= '1';
                else
                    W1_tags(to_integer(unsigned(adr_index))) <= adr_tag;
                    w1_data_valid(to_integer(unsigned(adr_index))) <= '1';
                    lru_val <= '0';
                end if;
                set_lru <= '1';
                lru_adr <= adr_index;
        end case;
    end if;
end process;


 






end architecture;