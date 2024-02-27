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
type S is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11);
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
                    next_state <= S1;
                end if;
            when S1 => -- Aspetta 1 clk per load dei registri
                next_state <= S2;
            when S2 =>
                if (pre_done = '0') then
                    next_state <= S3;
                else
                    next_state <= S11;
                end if;
            when S3 => -- Aspetta 1 clk per load da MEM
                next_state <= S4;
            when S4 => -- Aspetta 1 clk per load da MEM
                next_state <= S5; 
            when S5 =>
                if (w_is_zero = '1') then
                    next_state <= S6;
                else
                    next_state <= S7;
                end if;
            when S6 =>
                next_state <= S8;
            when S7 =>
                next_state <= S8;
            when S8 =>
                next_state <= S9;
            when S9 =>
                next_state <= S10;
            when S10 =>
                next_state <= S2;
            when S11 =>
                if (i_start = '0') then
                    next_state <= S0;
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
            when S1 =>
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
            when S2 =>
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
                c_load <= '0';
                data_sel <= '0';
                k_load <= '0';
                o_done <= '0';
                add_load <= '0';
                o_mem_en <= '1';
                o_mem_we <= '0';
                k_set <= '0';
                add_set <= '0';
            when S5 =>
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
            when S6 =>
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
            when S7 =>
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
                data_sel <= '1';
                k_load <= '1';
                o_done <= '0';
                add_load <= '0';
                o_mem_en <= '1';
                o_mem_we <= '1';
                k_set <= '0';
                add_set <= '0';
            when S10 =>
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
            when S11 =>
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


        
        
