----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/20/2024 06:37:29 PM
-- Design Name: 
-- Module Name: project_reti_logiche - project_reti_logiche_arch
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project_reti_logiche is
    port (
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start : in std_logic;
        i_add   : in std_logic_vector(15 downto 0);
        i_k     : in std_logic_vector(9 downto 0);
        
        o_done  : out std_logic;
        
        o_mem_addr  : out std_logic_vector(15 downto 0);
        i_mem_data  : in  std_logic_vector(7 downto 0);
        o_mem_data  : out  std_logic_vector(7 downto 0);
        o_mem_we    : out std_logic;
        o_mem_en    : out std_logic
    );
end project_reti_logiche;

architecture project_reti_logiche_arch of project_reti_logiche is
component datapath is
  Port (
        i_clk   : in std_logic;
        i_d_rst   : in std_logic;
        i_add   : in std_logic_vector(15 downto 0);
        i_k     : in std_logic_vector(9 downto 0);
        
        w_is_zero   : out std_logic;
        w_load      : in std_logic;
        
        c_31_sel    : in std_logic;
        c_load      : in std_logic;
        
        data_sel  : in std_logic;
        
        k_load      : in std_logic;
        k_set       : in std_logic;
        pre_done    : out std_logic;
        
        add_load    : in std_logic;
        add_set     : in std_logic;
        
        o_mem_addr  : out std_logic_vector(15 downto 0);
        i_mem_data  : in  std_logic_vector(7 downto 0);
        o_mem_data  : out  std_logic_vector(7 downto 0)
        );
end component;

-- Segnali di load
signal w_load   : std_logic;
signal c_load   : std_logic;
signal k_load   : std_logic;
signal add_load : std_logic;

-- Segnali di comparazione
signal w_is_zero : std_logic;

-- Segnali dei selettori
signal c_31_sel : std_logic;
signal data_sel : std_logic;
signal k_set    : std_logic;
signal add_set  : std_logic;

-- Segnale di fine interno
signal pre_done : std_logic;

-- Segnale di RST interno
signal i_d_rst  : std_logic;

-- Lista degli stati
type S is (S0, S1A, S1, S2, S3, S4, S5, S6, S7, S8, S9);
signal cur_state, next_state : S;

begin
    DATAPATH0: datapath port map(
        i_clk => i_clk,
        i_d_rst => i_d_rst,
        i_add => i_add,
        i_k => i_k,
        w_is_zero => w_is_zero,
        w_load => w_load,
        c_31_sel => c_31_sel,
        c_load => c_load,
        data_sel => data_sel,
        k_load => k_load,
        k_set => k_set,
        pre_done => pre_done,
        add_load => add_load,
        add_set => add_set,
        o_mem_addr => o_mem_addr,
        i_mem_data => i_mem_data,
        o_mem_data => o_mem_data
    );
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
    
    process(cur_state, i_start, pre_done, w_is_zero)
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 =>
                if i_start = '1' then
                    next_state <= S1A;
                end if;
            when S1A => -- Aspetta 1 clk per load dei registri
                next_state <= S1;
            when S1 =>
                if (pre_done = '0') then
                    next_state <= S2;
                else
                    next_state <= S9;
                end if;
            when S2 => -- Aspetta 1 clk per load da MEM
                next_state <= S3;
            when S3 =>
                if (w_is_zero = '1') then
                    next_state <= S4;
                else
                    next_state <= S5;
                end if;
            when S4 =>
                next_state <= S6;
            when S5 =>
                next_state <= S6;
            when S6 =>
                next_state <= S7;
            when S7 =>
                if (pre_done = '0') then
                    next_state <= S8;
                else
                    next_state <= S9;
                end if;
            when S8 =>
                next_state <= S1;
            when S9 =>
                if (i_start = '0') then
                    next_state <= S0;
                else
                    next_state <= cur_state;
                end if;
         end case;
     end process;
     
     process(cur_state)
     begin
        i_d_rst <= '0';
        w_load <= '0';
        c_31_sel <= '0';
        c_load <= '0';
        data_sel <= '0';
        k_load <= '0';
        o_done <= '0';
        add_load <= '0';
        o_mem_en <= '0';
        o_mem_we <= '0';
        k_set <= '0';
        add_set <= '0';
        
        case cur_state is
            when S0 =>
                i_d_rst <= '1';
                w_load <= '0';
                c_31_sel <= '0';
                c_load <= '0';
                data_sel <= '0';
                k_load <= '0';
                o_done <= '0';
                add_load <= '0';
                o_mem_en <= '0';
                o_mem_we <= '0';
                k_set <= '0';
                add_set <= '0';
            when S1A =>
                i_d_rst <= '0';
                w_load <= '0';
                c_31_sel <= '0';
                c_load <= '0';
                data_sel <= '0';
                k_load <= '1';
                o_done <= '0';
                add_load <= '1';
                o_mem_en <= '0';
                o_mem_we <= '0';
                k_set <= '1';
                add_set <= '1';
            when S1 =>
                i_d_rst <= '0';
                w_load <= '0';
                c_31_sel <= '0';
                c_load <= '0';
                data_sel <= '0';
                k_load <= '0';
                o_done <= '0';
                add_load <= '0';
                o_mem_en <= '1';
                o_mem_we <= '0';
                k_set <= '0';
                add_set <= '0';
            when S2 =>
                i_d_rst <= '0';
                w_load <= '0';
                c_31_sel <= '0';
                c_load <= '0';
                data_sel <= '0';
                k_load <= '0';
                o_done <= '0';
                add_load <= '0';
                o_mem_en <= '1';
                o_mem_we <= '0';
                k_set <= '0';
                add_set <= '0';
            when S3 =>
                i_d_rst <= '0';
                w_load <= '0';
                c_31_sel <= '0';
                c_load <= '0';
                data_sel <= '0';
                k_load <= '0';
                o_done <= '0';
                add_load <= '0';
                o_mem_en <= '1';
                o_mem_we <= '0';
                k_set <= '0';
                add_set <= '0';
            when S4 =>
                i_d_rst <= '0';
                w_load <= '0';
                c_31_sel <= '0';
                c_load <= '1';
                data_sel <= '0';
                k_load <= '0';
                o_done <= '0';
                add_load <= '0';
                o_mem_en <= '1';
                o_mem_we <= '1';
                k_set <= '0';
                add_set <= '0';
            when S5 =>
                i_d_rst <= '0';
                w_load <= '1';
                c_31_sel <= '1';
                c_load <= '1';
                data_sel <= '0';
                k_load <= '0';
                o_done <= '0';
                add_load <= '0';
                o_mem_en <= '1';
                o_mem_we <= '0';
                k_set <= '0';
                add_set <= '0';
            when S6 =>
                i_d_rst <= '0';
                w_load <= '0';
                c_31_sel <= '0';
                c_load <= '0';
                data_sel <= '0'; 
                k_load <= '0';
                o_done <= '0';
                add_load <= '1';
                o_mem_en <= '0';
                o_mem_we <= '0';
                k_set <= '0';
                add_set <= '0';
            when S7 =>
                i_d_rst <= '0';
                w_load <= '0';
                c_31_sel <= '0';
                c_load <= '0';
                data_sel <= '1';
                k_load <= '1';
                o_done <= '0';
                add_load <= '0';
                o_mem_en <= '1';
                o_mem_we <= '1';
                k_set <= '0';
                add_set <= '0';
            when S8 =>
                i_d_rst <= '0';
                w_load <= '0';
                c_31_sel <= '0';
                c_load <= '0';
                data_sel <= '0';
                k_load <= '0';
                o_done <= '0';
                add_load <= '1';
                o_mem_en <= '0';
                o_mem_we <= '0';
                k_set <= '0';
                add_set <= '0';
            when S9 =>
                i_d_rst <= '0';
                w_load <= '0';
                c_31_sel <= '0';
                c_load <= '0';
                data_sel <= '0';
                k_load <= '0';
                o_done <= '1';
                add_load <= '0';
                o_mem_en <= '0';
                o_mem_we <= '0';
                k_set <= '0';
                add_set <= '0';
        end case;
     end process;

end project_reti_logiche_arch;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/22/2024 02:57:23 PM
-- Design Name: 
-- Module Name: datapath - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity datapath is
  Port (
        -- Ingressi esterni
        i_clk   : in std_logic;
        i_d_rst   : in std_logic;
        i_add   : in std_logic_vector(15 downto 0);
        i_k     : in std_logic_vector(9 downto 0);
        
        -- Modulo W
        w_is_zero   : out std_logic;
        w_load      : in std_logic;
        
        -- Modulo C
        c_31_sel    : in std_logic;
        c_load      : in std_logic;
        
        -- Selettore W o C
        data_sel  : in std_logic;
        
        -- Modulo K
        k_load      : in std_logic;
        k_set       : in std_logic;
        pre_done    : out std_logic;
        
        -- Modulo ADD
        add_load    : in std_logic;
        add_set     : in std_logic;
        
        -- Memoria esterna
        o_mem_addr  : out std_logic_vector(15 downto 0);
        i_mem_data  : in  std_logic_vector(7 downto 0);
        o_mem_data  : out  std_logic_vector(7 downto 0)
        );
end datapath;

architecture Behavioral of datapath is
    -- Segnali dei registri
    signal o_reg_w  : std_logic_vector(7 downto 0);
    signal o_reg_c  : std_logic_vector(7 downto 0);
    signal o_reg_k  : std_logic_vector(9 downto 0);
    signal o_reg_add  : std_logic_vector(15 downto 0);
    
    -- Segnali dei sommatori
    signal add_sum  : std_logic_vector(15 downto 0);
    signal c_sub  : std_logic_vector(7 downto 0);
    signal k_sub  : std_logic_vector(9 downto 0);
    
    -- Segnali dei multiplexer
    signal mux_c_31_sel  : std_logic_vector(7 downto 0);
    signal mux_c_0_sel   : std_logic_vector(7 downto 0);
    signal mux_k_set     : std_logic_vector(9 downto 0);
    signal mux_add_set   : std_logic_vector(15 downto 0);
    
    -- Segnale di comparazione
    signal c_is_zero    : std_logic;
    
begin

    -- Definizione di REG_W
    process(i_clk, i_d_rst)
    begin
        if (i_d_rst = '1') then
            o_reg_w <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(w_load = '1') then
                o_reg_w <= i_mem_data;
               end if;
        end if;
    end process;
    
    -- Definizione di REG_C
    process(i_clk, i_d_rst)
    begin
        if (i_d_rst = '1') then
            o_reg_c <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(c_load = '1') then
                o_reg_c <= mux_c_31_sel;
               end if;
        end if;
    end process;
    
    
    -- Definizione di REG_K
    process(i_clk, i_d_rst)
    begin
        if (i_d_rst = '1') then
            o_reg_k <= "0000000000";
        elsif i_clk'event and i_clk = '1' then
            if(k_load = '1') then
                o_reg_k <= mux_k_set;
               end if;
        end if;
    end process;
    
    
    -- Definizione di REG_add
    process(i_clk, i_d_rst)
    begin
        if (i_d_rst = '1') then
            o_reg_add <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(add_load = '1') then
                o_reg_add <= mux_add_set;
               end if;
        end if;
    end process;
    
    -- Definizione sommatore add_sum
    add_sum <= o_reg_add + "0000000000000001"; -- Add 1, ogni banco è da 8 bit
    
    -- Definizione sommatore k_sub
    k_sub <= o_reg_k - "0000000001";
    
    -- Definizione sommatore c_sum
    c_sub <= o_reg_c - "00000001";
    
                        
    -- Definizione mux_data_sel
    with data_sel select
        o_mem_data <= o_reg_w when '0', 
                        o_reg_c when '1',
                        "XXXXXXXX" when others;
    
    -- Definizione mux_c_31_sel
    with c_31_sel select
        mux_c_31_sel <= mux_c_0_sel when '0', 
                        "00011111" when '1', -- (31)
                        "XXXXXXXX" when others;
                        
     -- Definizione mux_c_0_sel
     with c_is_zero select
        mux_c_0_sel <= c_sub when '0', 
                        "00000000" when '1',
                        "XXXXXXXX" when others;
                        
    -- Definizione mux_k_set
    with k_set select
        mux_k_set <= i_k when '1', 
                        k_sub when '0',
                        "XXXXXXXXXX" when others;
                        
    -- Definizione mux_add_set
    with add_set select
        mux_add_set <= i_add when '1', 
                        add_sum when '0',
                        "XXXXXXXXXXXXXXXX" when others;
                        
    -- Definizione comparatore w_is_zero
    w_is_zero <= '1' when (i_mem_data = "00000000") else '0';
    
    -- Definizione comparatore c_is_zero
    c_is_zero <= '1' when (o_reg_c = "00000000") else '0';
    
    -- Definizione comparatore pre_done
    pre_done <= '1' when (o_reg_k = "0000000000") else '0';
    
    -- Definizione uscite
    o_mem_addr <= o_reg_add;
    
end Behavioral;
