----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.01.2019 03:16:27
-- Design Name: 
-- Module Name: testbench - Behavioral
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


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY testbench is
--  Port ( );
END testbench;

ARCHITECTURE Tb of testbench is
SIGNAL CLK100MHZ: STD_LOGIC:= '0';
SIGNAL SET_IN,INIT_IN,RST_IN,RNDM_IN: STD_LOGIC:= '0';
SIGNAL SWITCHES: STD_LOGIC_VECTOR (3 DOWNTO 0):="0000";  

BEGIN
UUT: ENTITY WORK.part2(Behavioral) PORT MAP(
    CLK100MHZ => CLK100MHZ, SET_IN => SET_IN, INIT_IN => INIT_IN, RNDM_IN => RNDM_IN, RST_IN => RST_IN,SWITCHES => SWITCHES);

    CLK100MHZ <= NOT CLK100MHZ AFTER 10NS;
    
    TB:PROCESS
    BEGIN
    -- Incorrect sequence
    WAIT FOR 5 NS;
    INIT_IN <= '1';
    WAIT FOR  25 NS;
    INIT_IN <= '0';
    WAIT FOR 20 NS;
    SWITCHES <= "0001";
    WAIT FOR 10 NS;
    SET_IN <= '1';
    WAIT FOR 50 NS;
    SET_IN <= '0';
    WAIT FOR 40 NS;
    SWITCHES <= "0010";
    WAIT FOR 25 NS;
    SET_IN <= '1';
    WAIT FOR 50 NS;
    SET_IN <= '0';
    WAIT FOR 25 NS;
    SWITCHES <= "0011";
    WAIT FOR 25 NS;
    SET_IN <= '1';
    WAIT FOR 50 NS;
    SET_IN <= '0';
    WAIT FOR 25 NS;
    SWITCHES <= "0100";
    WAIT FOR 25 NS;
    SET_IN <= '1';
    WAIT FOR 50 NS;
    SET_IN <= '0';
    WAIT FOR 25 NS;
    SWITCHES <= "0101";
    WAIT FOR 25 NS;
    SET_IN <= '1';
    WAIT FOR 50 NS;
    SET_IN <= '0';
    WAIT FOR 25 NS;
    SWITCHES <= "0000";
    WAIT FOR 25 NS;
    RST_IN <= '1';
    WAIT FOR 50 NS;
    RST_IN <= '0';
    WAIT FOR 25 NS;
    -- Correct Sequence
    INIT_IN <= '1';
    WAIT FOR  25 NS;
    INIT_IN <= '0';
    WAIT FOR 20 NS;
    SWITCHES <= "0111";
    WAIT FOR 10 NS;
    SET_IN <= '1';
    WAIT FOR 50 NS;
    SET_IN <= '0';
    WAIT FOR 40 NS;
    SWITCHES <= "0011";
    WAIT FOR 25 NS;
    SET_IN <= '1';
    WAIT FOR 50 NS;
    SET_IN <= '0';
    WAIT FOR 25 NS;
    SWITCHES <= "0111";
    WAIT FOR 25 NS;
    SET_IN <= '1';
    WAIT FOR 50 NS;
    SET_IN <= '0';
    WAIT FOR 25 NS;
    SWITCHES <= "1000";
    WAIT FOR 25 NS;
    SET_IN <= '1';
    WAIT FOR 50 NS;
    SET_IN <= '0';
    WAIT FOR 25 NS;
    SWITCHES <= "0111";
    WAIT FOR 25 NS;
    SET_IN <= '1';
    WAIT FOR 50 NS;
    SET_IN <= '0';
    WAIT FOR 25 NS;
    SWITCHES <= "0000";
    WAIT FOR 25 NS;
    RST_IN <= '1';
    WAIT FOR 50 NS;
    RST_IN <= '0';
    WAIT FOR 25 NS;
    END PROCESS;

END Tb;
