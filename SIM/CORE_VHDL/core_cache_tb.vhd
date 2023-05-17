library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;
use work.all;

entity core_cache_tb is 
end core_cache_tb;

architecture simu of core_cache_tb is 

-- functions 
function read_mem(adr : integer) return integer is 
begin 
    assert false severity failure;
end read_mem; 
attribute foreign of read_mem : function is "VHPIDIRECT read_mem";    

function write_mem(adr : integer; data : integer; byte_select : integer; dtime : integer) return integer is 
begin 
    assert false severity failure;
end write_mem; 
attribute foreign of write_mem : function is "VHPIDIRECT write_mem";    

function get_startpc(a : integer) return integer is 
begin 
    assert false severity failure; 
end get_startpc;
attribute foreign of get_startpc : function is "VHPIDIRECT get_startpc";

function get_good(a : integer) return integer is 
begin 
    assert false severity failure; 
end get_good; 
attribute foreign of get_good : function is  "VHPIDIRECT get_good";

function get_bad(a : integer) return integer is 
begin 
    assert false severity failure; 
end get_bad; 
attribute foreign of get_bad : function is  "VHPIDIRECT get_bad";

function end_simulation(result : integer; riscof_enable : integer) return integer is 
begin
    assert false severity failure; 
end end_simulation; 
attribute foreign of end_simulation : function is  "VHPIDIRECT end_simulation";

function get_riscof_en(z : integer) return integer is 
begin 
    assert false severity failure;
end get_riscof_en; 
attribute foreign of get_riscof_en : function is "VHPIDIRECT get_riscof_en";    

function get_end_riscof(z : integer) return integer is 
begin 
    assert false severity failure;
end get_end_riscof; 
attribute foreign of get_end_riscof : function is "VHPIDIRECT get_end_riscof";    

function to_string ( a: std_logic_vector) return string is
variable b : string (1 to a'length) := (others => NUL);
variable stri : integer := 1; 
begin
    for i in a'range loop
        b(stri) := std_logic'image(a((i)))(2);  
        stri := stri+1;
    end loop;
    return b;
end function;

------------------------------
-- core signals instance
------------------------------
-- global interface
signal clk : std_logic := '1';
signal reset_n : std_logic := '0';

-- Mcache interface
signal MCACHE_RESULT_SM : std_logic_vector(31 downto 0);
signal MCACHE_STALL_SM : std_logic;

signal MCACHE_ADR_VALID_SM, MCACHE_STORE_SM, MCACHE_LOAD_SM : std_logic;
signal MCACHE_DATA_SM : std_logic_vector(31 downto 0);
signal MCACHE_ADR_SM : std_logic_vector(31 downto 0);
signal byt_sel : std_logic_vector(3 downto 0);
signal MCACHE_PC : std_logic_vector(31 downto 0);

-- Icache interface
signal IC_INST_SI : std_logic_vector(31 downto 0);
signal IC_STALL_SI : std_logic; 

signal ADR_SI : std_logic_vector(31 downto 0);
signal ADR_VALID_SI : std_logic; 

-- Debug 
signal PC_INIT : std_logic_vector(31 downto 0);
signal DEBUG_PC_READ : std_logic_vector(31 downto 0);

----------------------------
-- icache signals instance
----------------------------
-- ram interface
signal I_RAM_DATA : std_logic_vector(31 downto 0);
signal I_RAM_ADR : std_logic_vector(31 downto 0);
signal I_RAM_ADR_VALID : std_logic;
signal I_RAM_ACK : std_logic;


----------------------------
-- dcache signals instance
----------------------------
signal D_RAM_ADR : std_logic_vector(31 downto 0);
signal D_RAM_ADR_VALID          :  std_logic;

signal D_RAM_ACK      :std_logic;
signal D_RAM_ACK_temp :std_logic := '0'; --Utilisé pour synchro ça bien.
signal D_RAM_DATA     :std_logic_vector(31 downto 0);

            --write

signal D_RAM_WRITE_ADR   : std_logic_vector(31 downto 0);
signal D_RAM_WRITE_DATA  : std_logic_vector(31 downto 0);
signal D_RAM_BYTE_SEL  : std_logic_vector(3  downto 0);
signal D_RAM_STORE       : std_logic;

signal D_RAM_BUFFER_CACHE_POP : std_logic := '0';

signal transf_cpt_dcache: integer;

component core
    port(
        -- global interface
        clk, reset_n : in std_logic;

        -- Mcache interface
        MCACHE_RESULT_SM : in std_logic_vector(31 downto 0);
        MCACHE_STALL_SM : in std_logic;

        MCACHE_ADR_VALID_SM, MCACHE_STORE_SM, MCACHE_LOAD_SM : out std_logic;
        MCACHE_DATA_SM : out std_logic_vector(31 downto 0);
        MCACHE_ADR_SM : out std_logic_vector(31 downto 0);
        byt_sel : out std_logic_vector(3 downto 0);
        MCACHE_PC  :   out std_logic_vector(31 downto 0);


        -- Icache interface
        IC_INST_SI : in std_logic_vector(31 downto 0);
        IC_STALL_SI : in std_logic; 

        ADR_SI : out std_logic_vector(31 downto 0);
        ADR_VALID_SI : out std_logic; 

        -- Debug 
        PC_INIT : in std_logic_vector(31 downto 0);
        DEBUG_PC_READ : out std_logic_vector(31 downto 0)
    );
end component; 

component icache
    generic(
        WAYS    : integer;
        WIDTH   : integer
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
end component;


component dcache 
    port(
        -- global interface
        clk, reset_n    :   in  std_logic;

        --core interface
        ADR_SM          :   in  std_logic_vector(31 downto 0);
        DATA_SM          :   in  std_logic_vector(31 downto 0);
        ADR_VALID_SM    :   in  std_logic;  --not sure if useful, as we have load and store. If we combine them, then useful
        LOAD_SM         :   in  std_logic;
        STORE_SM        :   in  std_logic;
        SIZE_SM         :   in  std_logic_vector(3 downto 0);
        PC_SM           :   in std_logic_vector(31 downto 0);

        DATA_SC         :   out     std_logic_vector(31 downto 0);
        STALL_SC        :   out     std_logic;


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
end component;


-- Simulation 
constant NCYCLES : integer := 100000000; 
signal CYCLES : integer := 0; 
signal good_adr, bad_adr, exception_adr : std_logic_vector(31 downto 0);
signal end_simu : std_logic := '0'; 
signal result : integer := 0;  
signal timeout : integer := 0; 
signal dtime : integer := 0; 

-- riscof
signal riscof_en : integer := 0; 
signal riscof_end_adr : std_logic_vector(31 downto 0);
signal cpt_end : integer := 0;
constant cpt_max : integer := 10;
signal riscof_end : integer := 0;

begin 

good_adr        <=  std_logic_vector(to_signed(get_good(0), 32));
bad_adr         <=  std_logic_vector(to_signed(get_bad(0), 32));
exception_adr   <=  x"00011064"; -- because of flemme, TODO in ram_sim.c
riscof_en       <=  get_riscof_en(0);
riscof_end_adr  <=  std_logic_vector(to_signed(get_end_riscof(0), 32));

core0 : core
    port map(
        -- global interface
        clk, reset_n,

        -- Mcache interface
        MCACHE_RESULT_SM,
        MCACHE_STALL_SM,

        MCACHE_ADR_VALID_SM, MCACHE_STORE_SM, MCACHE_LOAD_SM,
        MCACHE_DATA_SM,
        MCACHE_ADR_SM,
        byt_sel, 
        MCACHE_PC,
        -- Icache interface
        IC_INST_SI,
        IC_STALL_SI, 

        ADR_SI,
        ADR_VALID_SI, 

        -- Debug 
        PC_INIT,
        DEBUG_PC_READ
    );

icache_inst: icache
    generic map (
        ICACHE_WAYS, ICACHE_WIDTH
    )
    port map(
        -- global interface
        clk, reset_n,

        -- core interface
        ADR_SI,
        ADR_VALID_SI,
        IC_INST_SI,
        IC_STALL_SI,

        -- ram interface
        I_RAM_DATA,
        I_RAM_ADR,
        I_RAM_ADR_VALID,
        I_RAM_ACK
    );


dcache_inst: dcache
    port map (
        clk,reset_n,

        MCACHE_ADR_SM,
        MCACHE_DATA_SM,
        MCACHE_ADR_VALID_SM,
        MCACHE_LOAD_SM,
        MCACHE_STORE_SM,
        byt_sel,
        MCACHE_PC,        

        MCACHE_RESULT_SM,
        MCACHE_STALL_SM,


        D_RAM_ADR,
        D_RAM_ADR_VALID,
        D_RAM_ACK,
        D_RAM_DATA,

        D_RAM_WRITE_ADR,
        D_RAM_WRITE_DATA,
        D_RAM_BYTE_SEL,
        D_RAM_STORE,

        D_RAM_BUFFER_CACHE_POP

        );


clk_gen : process
variable r0 : integer;
variable un : integer := 1;
begin         
    clk <= '0'; 
    wait for 5 ns; 
    clk <= '1'; 
     CYCLES <= CYCLES + 1; 
    wait for 5 ns; 
    if CYCLES = 1 then 
        if riscof_en = 1 then 
            assert false report "RISCOF simulation begin" severity note; 
        else
            assert false report "simulation begin" severity note; 
        end if;
    end if; 
    if end_simu = '1' or cpt_end = cpt_max then 
        assert false report "end of simulation, done in " & integer'image(CYCLES) & " cycles" severity note; 
        r0 := end_simulation(result,un);
        wait; 
    end if; 
    if riscof_end = 1 then 
        cpt_end <= cpt_end + 1;
    end if; 
    if CYCLES = NCYCLES then 
        timeout <= 1; 
        assert false report "end of simulation (timeout)" severity note; 
        r0 := end_simulation(un,0);
       wait; 
    end if;
    
    -- if ADR_SI = riscof_end then   
    -- report "end riscof test" severity note; 
    --     r0 := end_simulation(0,1);
    -- end if;
end process; 


process(clk)
begin 
    dtime <= dtime + 5; 
end process; 

reset_n <= '0', '1' after 6 ns;


PC_INIT <= std_logic_vector(to_signed(get_startpc(0), 32));

simul: process (clk, ADR_SI, ADR_VALID_SI)
begin
    if riscof_end_adr = (riscof_end_adr'range => '0') then
        if ADR_VALID_SI = '1' then 
            if ADR_SI = bad_adr then 
                assert false report "Test failed" severity error; 
                result <= 1;
                end_simu <= '1';              
            elsif ADR_SI = good_adr then 
                assert false report "Test success" severity note; 
                result <= 0;
                end_simu <= '1';  
            elsif ADR_SI = exception_adr then 
                assert false report "Exception occured" severity warning; 
                result <= 2;    
                end_simu <= '1'; 
            end if;
        end if;
    else
        if ADR_VALID_SI = '1' then 
            if ADR_SI = riscof_end_adr then 
                assert false report "RISCOF test end" severity note; 
                result <= 0 ;
                riscof_end <= 1;
            end if;
        end if;
    end if;
end process;

ram : process (clk, I_RAM_ADR, I_RAM_ADR_VALID)

variable adr_int : integer; 
variable inst_int : integer; 
variable intermed : signed(I_RAM_ADR'range); 
variable transf_cpt : integer;

begin
    if I_RAM_ADR_VALID = '1' then
        I_RAM_ACK <= '1' after RAM_LATENCY;
        transf_cpt := 0;
    end if;

    if I_RAM_ACK = '1' and rising_edge(clk) then -- 1 word per cycle
        intermed    := signed(I_RAM_ADR); 
        adr_int     := to_integer(intermed) + 4 * transf_cpt;
        inst_int    := read_mem(adr_int);

        I_RAM_DATA <= std_logic_vector(to_signed(inst_int, 32));
        transf_cpt := transf_cpt + 1;

        if transf_cpt = ICACHE_WIDTH + 1 then
            I_RAM_ACK <= '0';
        end if;
    end if;
end process; 

--ram_ack_process : process(clk)
--begin
--    if rising_edge(clk) then
--        D_RAM_ACK <= D_RAM_ACK_temp;
--    end if;
--end process;

dcache_ram : process(clk, D_RAM_ADR_VALID, D_RAM_ADR, D_RAM_WRITE_ADR, D_RAM_WRITE_DATA, D_RAM_BYTE_SEL, D_RAM_STORE,D_RAM_ACK_temp)
variable read0      : integer; -- ignore 
variable adr_u      : signed(D_RAM_ADR'range);
variable adr_write  : signed(D_RAM_WRITE_ADR'range);
variable adr_int    : integer := 0;
variable adr_write_int : integer := 0;
variable data_u     : signed(D_RAM_WRITE_DATA'range);
variable data_int   : integer := 0;
variable byt_sel_u  : unsigned(D_RAM_BYTE_SEL'range);
variable byt_sel_i  : integer := 0;
variable d_transf_cpt : integer;
variable res_data   : integer;
variable store_en_cours : integer := 0;
variable store_en_cours_reset : integer := 0;


begin 
    adr_u       := signed(D_RAM_ADR);
    adr_write   := signed(D_RAM_WRITE_ADR);
--    adr_int     := to_integer(adr_u);
    adr_write_int := to_integer(adr_write);
    data_u      := signed(D_RAM_WRITE_DATA);
    data_int    := to_integer(data_u);
    byt_sel_u   := unsigned(D_RAM_BYTE_SEL);
    byt_sel_i   := to_integer(byt_sel_u);


    if D_RAM_STORE = '1' and store_en_cours = 0 then
        report "Store waiting";
        D_RAM_BUFFER_CACHE_POP <= '1' after RAM_LATENCY;
        store_en_cours := 1;
    end if;

    if D_RAM_ADR_VALID = '1' then
        D_RAM_ACK_temp <= '1' after RAM_LATENCY;
        adr_int     := to_integer(adr_u);
        d_transf_cpt := 0;
    end if;
    if rising_edge(clk) then
        if store_en_cours_reset = 1 then
            report "store_en_cours_reset";
            store_en_cours := 0;
            store_en_cours_reset := 0;
        end if;
        if D_RAM_BUFFER_CACHE_POP = '1' then
            read0 := write_mem(adr_write_int, data_int, byt_sel_i, dtime);
            D_RAM_BUFFER_CACHE_POP <= '0';
            store_en_cours_reset := 1;
            --store_en_cours := 0;
        end if;

        if D_RAM_ACK_temp = '1' then
            D_RAM_ACK <= '1';
            res_data := read_mem(adr_int);
            D_RAM_DATA <= std_logic_vector(to_signed(res_data,32));

--            report "RAM send " & INTEGER'Image(res_data) & " from " & INTEGER'Image(adr_int);
            
            d_transf_cpt := d_transf_cpt + 1;
            adr_int := adr_int + 4;


            if d_transf_cpt = DCACHE_WIDTH + 1 then
                D_RAM_ACK_temp <= '0';
            end if;
        else
            D_RAM_ACK <= '0';
        end if;
    end if;
        transf_cpt_dcache <= d_transf_cpt;

end process;

end simu;
