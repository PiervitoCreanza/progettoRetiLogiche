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
