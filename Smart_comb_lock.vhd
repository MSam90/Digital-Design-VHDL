----------------------------------------------------------------------------------
-- Institution: University Of Birmingham 
-- Engineer: Mohamed Abou Samak - 1973783
-- 
-- Create Date: 10.01.2019 18:22:57
-- Design Name: Design Part_1
-- Module Name: part_2 - Behavioral
-- Project Name: 
-- Target Devices: Nexys 4 DDR
-- Tool Versions: Vivado 2018.3
-- Description: A simple key combination lock based on binary input; Key sequence: 73783; 0111,0011,0111,1000,0011
-- 
-- Additional Comments:
-- 
---------------------------- Clock Generator --------------------------------------
LIBRARY IEEE;                   -- The IEEE Library.
USE IEEE.STD_LOGIC_1164.ALL;    -- To enable the use of STD_LOGIC.
USE IEEE.STD_LOGIC_UNSIGNED.ALL;-- To use the arithmetic +.

Entity clk_generator IS
        PORT(  clk: IN STD_LOGIC;                       -- Input clock
            value: IN STD_LOGIC_VECTOR(27 DOWNTO 0);    -- Maximum bits
            clk_out: OUT STD_LOGIC);                    -- Output clock
END clk_generator;

ARCHITECTURE Behav OF clk_generator IS
SIGNAL counter: STD_LOGIC_VECTOR(27 DOWNTO 0):= (OTHERS => '0');
BEGIN
PROCESS(clk)                                    -- Triggered on CLK_IN
BEGIN   
    IF RISING_EDGE(clk) THEN                    -- Triggered on the rising_edge
        IF(counter >= value) THEN               -- If value reached then
            counter <= (OTHERS => '0');         -- re-initialize to zero
        ELSE
            counter <= counter + 1;             -- increment by 1
        END IF;
    END IF;
END PROCESS;
clk_out <= '1' WHEN counter = value ELSE '0';   -- Generated clock is 1
END Behav;

--------------------------------- D type Flip Flops ------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY D_FF IS
    PORT (  CLK : IN STD_LOGIC;
            CLK_ENABLE: IN STD_LOGIC:= '0';
            D : IN STD_LOGIC:= '0';
            Q : OUT STD_LOGIC:= '0');
end D_FF;

ARCHITECTURE Behavioral of D_FF is
BEGIN
PROCESS(CLK)
BEGIN
IF RISING_EDGE(CLK) THEN
    IF(CLK_ENABLE = '1') THEN
        Q <= D;
    END IF;
END IF;
END PROCESS;
END Behavioral;

--------------------------------- Button Debounce --------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY BUTTON_DEBOUNCE IS
    PORT(   CLK_IN: IN STD_LOGIC;
            BUTTON_IN: IN STD_LOGIC;
            BUTTON_OUT: OUT STD_LOGIC);
END BUTTON_DEBOUNCE;

ARCHITECTURE Behavioral OF BUTTON_DEBOUNCE IS
    SIGNAL Qc,Qb,Qa,Qa_bar,SLOW_CLK: STD_LOGIC:= '0';
    SIGNAL value: STD_LOGIC_VECTOR(27 DOWNTO 0):= X"01E8480";
BEGIN
CLK1: ENTITY WORK.clk_generator(Behav) PORT MAP(CLK => CLK_IN,value => value ,clk_out => SLOW_CLK);

FF1: ENTITY WORK.D_FF(Behavioral) PORT MAP(CLK => CLK_IN, CLK_ENABLE=> SLOW_CLK, D => BUTTON_IN, Q => Qc);

FF2: ENTITY WORK.D_FF(Behavioral) PORT MAP(CLK => CLK_IN,CLK_ENABLE => SLOW_CLK, D => Qc, Q => Qb);

FF3: ENTITY WORK.D_FF(Behavioral) PORT MAP(CLK => CLK_IN,CLK_ENABLE => SLOW_CLK, D => Qb, Q => Qa);

Qa_bar <= NOT Qa;
BUTTON_OUT <= Qc AND Qb  AND Qa_bar;

END Behavioral;

-------------------------------- 7 Segment BCD Driver ----------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity display is
    Port (  CLK: IN STD_LOGIC;
            display_number: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            SEGS : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
end display;

architecture Behavioral of display is
BEGIN

PROCESS(CLK,display_number)
BEGIN
IF RISING_EDGE(CLK) THEN
    CASE display_number IS
        WHEN "0000" => SEGS <= "11000000";    --0
        WHEN "0001" => SEGS <= "11111001";    --1
        WHEN "0010" => SEGS <= "10100100";    --2
        WHEN "0011" => SEGS <= "10110000";    --3
        WHEN "0100" => SEGS <= "10011001";    --4
        WHEN "0101" => SEGS <= "10010010";    --5
        WHEN "0110" => SEGS <= "10000010";    --6
        WHEN "0111" => SEGS <= "11111000";    --7   
        WHEN "1000" => SEGS <= "10000000";    --8
        WHEN "1001" => SEGS <= "10010000";    --9
        WHEN "1010" => SEGS <= "10101111";    --r
        WHEN "1011" => SEGS <= "10001001";    --K
        WHEN "1100" => SEGS <= "11000110";    --C
        WHEN "1101" => SEGS <= "10100011";    --o
        WHEN "1110" => SEGS <= "10000110";    --E    
        WHEN "1111" => SEGS <= "11111111";    --F
        WHEN OTHERS => SEGS <= "11111111";    -- Nones
    END CASE;
END IF; 
END PROCESS;
end Behavioral;
----------------------------------- Main Entity ----------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY part2 IS
Port (  CLK100MHZ: IN STD_LOGIC;                        -- Base 100 MHZ Clock
        SET_IN,INIT_IN,RNDM_IN,RST_IN: IN STD_LOGIC;    -- All the input buttons
        SWITCHES: IN STD_LOGIC_VECTOR (3 DOWNTO 0);     -- Binary input switches
        DIGITS: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);       -- Used to choose the displays
        SEGMENTS : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);   -- Used to display a value on the displays   
        Z: OUT STD_LOGIC;                               -- Output when correct sequence is detected
        LEDS: OUT STD_LOGIC_VECTOR (4 DOWNTO 0));       -- Output LEDS used to show which is the current state
END ENTITY part2;

ARCHITECTURE Behavioral OF part2 IS
    SIGNAL SET,INIT,RNDM,RST, basic: STD_LOGIC:= '0';           -- Used for the button debounce
    SIGNAL state_count: STD_LOGIC_VECTOR(1 DOWNTO 0):="00";     -- Used to count the random states passed
    TYPE state_type IS ( state_i ,state_A, state_B, state_C, state_D, state_E, state_F, state_R);   -- State definitions
    SIGNAL state,current_state,next_state: state_type:= state_i;        -- State variables of the type state
    SIGNAL switch_inputs,show_this: STD_LOGIC_VECTOR(19 DOWNTO 0):= X"FFFFF";   -- Bectors to hold the values input and the ones displayed
    SIGNAL clk200hz,clk1hz,displayed_sequence: STD_LOGIC:= '0';                 -- Bits used for clock and counter purposes
    SIGNAL display_counter: STD_LOGIC_VECTOR (2 DOWNTO 0);                      -- Vector used for display refresh
    SIGNAL SEGMENTS_OUT: STD_LOGIC_VECTOR(39 DOWNTO 0);                         -- Vector used to control the segments for character display
    SIGNAL CORRECT_SEQ: STD_LOGIC_VECTOR(19 DOWNTO 0):= X"73783";               -- Holds the correct key sequence
    SIGNAL rndm_1,rndm_2: STD_LOGIC_VECTOR(2 DOWNTO 0);                         -- Random number counter values
    SIGNAL RNDM_SEQ: STD_LOGIC_VECTOR(19 DOWNTO 0):=X"FFFFF";                   -- Used to confirm the random sequence input by the user
    SIGNAL hz1value: STD_LOGIC_VECTOR(27 DOWNTO 0):= X"5F5E100";                -- Used to derive the 1Hz clock
    SIGNAL hz200value: STD_LOGIC_VECTOR(27 DOWNTO 0):= X"0061A80";              -- Used to derive the 200Hz clock
BEGIN

    db1: ENTITY WORK.BUTTON_DEBOUNCE(Behavioral) PORT MAP(                      -- Debounce for the Ready to read key input
    CLK_IN => CLK100MHZ,
    BUTTON_IN => SET_IN,
    BUTTON_OUT => SET
    );
    db2: ENTITY WORK.BUTTON_DEBOUNCE(Behavioral) PORT MAP(                      -- Debounce for the Initialize button
    CLK_IN => CLK100MHZ,
    BUTTON_IN => INIT_IN,
    BUTTON_OUT => INIT
    );
    db3: ENTITY WORK.BUTTON_DEBOUNCE(Behavioral) PORT MAP(                      -- Debounce for the reset button
    CLK_IN => CLK100MHZ,
    BUTTON_IN => RST_IN,
    BUTTON_OUT => RST
    );
    
    db4: ENTITY WORK.BUTTON_DEBOUNCE(Behavioral) PORT MAP(                      -- Debounce for the random sequence button
    CLK_IN => CLK100MHZ,
    BUTTON_IN => RNDM_IN,
    BUTTON_OUT => RNDM
    );
    
    d1: ENTITY WORK.display PORT MAP(                                           -- Used to drive the right most display
            CLK => CLK100MHZ,
            display_number => show_this(3 DOWNTO 0),
            segs => SEGMENTS_OUT(7 DOWNTO 0)
            );
    d2: ENTITY WORK.display PORT MAP(                                           -- Used to drive the second most right display
            CLK => CLK100MHZ,
            display_number => show_this(7 DOWNTO 4),
            segs => SEGMENTS_OUT(15 DOWNTO 8)

            );
    d3: ENTITY WORK.display PORT MAP(                                           -- Used to drive the third most right display
            CLK => CLK100MHZ,
            display_number => show_this(11 DOWNTO 8),
            segs => SEGMENTS_OUT(23 DOWNTO 16)

            );
    d4: ENTITY WORK.display PORT MAP(                                           -- Used to drive the fourth most right display
            CLK => CLK100MHZ,
            display_number => show_this(15 DOWNTO 12),
            segs => SEGMENTS_OUT(31 DOWNTO 24)

            );
    d5: ENTITY WORK.display PORT MAP(                                           -- Used to drive the fifth most right display
            CLK => CLK100MHZ,
            display_number => show_this(19 DOWNTO 16),
            segs => SEGMENTS_OUT(39 DOWNTO 32)
            );
            
    clk1:ENTITY WORK.clk_generator(Behav) PORT MAP(                             -- Generates the 1Hz Clock used to show the messages and the input sequence
            clk => CLK100MHZ, value => hz1value, clk_out => clk1hz);
            
    clk2:ENTITY WORK.clk_generator(Behav) PORT MAP(                             -- Generates the 200 Hz clock used to refresh the display
            clk => CLK100MHZ, value => hz200value, clk_out => clk200hz);
            

PROCESS(clk200hz)
BEGIN
    IF RISING_EDGE(clk200hz) THEN                   --A counter based on 200hz of refresh rate for the 5 displays
        IF (display_counter = "100") THEN
            display_counter <= (OTHERS => '0');
        ELSE
            display_counter <= display_counter + 1;
        END IF;
    END IF;
END PROCESS;

PROCESS(display_counter)                            -- A MUX used to change the display and the value displayed
BEGIN
    CASE display_counter IS
    
        WHEN "000" => 
            DIGITS <= "11111110";
            SEGMENTS <= SEGMENTS_OUT(7 DOWNTO 0);
           
        WHEN "001" =>
            DIGITS <= "11111101";
            SEGMENTS <= SEGMENTS_OUT(15 DOWNTO 8);
            
        WHEN "010" => 
            DIGITS <= "11111011";
            SEGMENTS <= SEGMENTS_OUT(23 DOWNTO 16);
            
        WHEN "011" => 
            DIGITS <= "11110111";
            SEGMENTS <= SEGMENTS_OUT(31 DOWNTO 24);
        
        WHEN "100" =>
            DIGITS <= "11101111";
            SEGMENTS <= SEGMENTS_OUT(39 DOWNTO 32);

        WHEN OTHERS =>
            DIGITS <= "11111111";
        
    END CASE;

END PROCESS;    

PROCESS(CLK100MHZ)                                      -- First random number generator
BEGIN
    IF RISING_EDGE(CLK100MHZ) THEN
        rndm_1 <= rndm_1 + 1;
        IF(rndm_1 = "100") THEN
            rndm_1 <= (OTHERS => '0');
        END IF;
    END IF;
END PROCESS;

PROCESS(clk200hz)                                       -- Second random number generator
BEGIN
    IF RISING_EDGE(clk200hz) THEN
        rndm_2 <= rndm_2 + 1;
        IF(rndm_1 = "100") THEN
            rndm_2 <= (OTHERS => '0');
        END IF;
    END IF;
END PROCESS;

PROCESS(rndm_1)                                         -- State assignment based on the first random number
BEGIN
    CASE rndm_1 IS
    WHEN "000" =>
        current_state <= state_A;
    WHEN "001" =>
        current_state <= state_B;
    WHEN "010" =>
        current_state <= state_C;
    WHEN "011" =>
        current_state <= state_D;
    WHEN "100" =>
        current_state <= state_E;
    WHEN OTHERS =>
        current_state <= state_C;
    END CASE;
END PROCESS;

PROCESS(rndm_2)                                         -- State assignment based on the second random number
BEGIN
    CASE rndm_2 IS
    WHEN "000" =>
        next_state <= state_A;
    WHEN "001" =>
        next_state <= state_B;
    WHEN "010" =>
        next_state <= state_C;
    WHEN "011" =>
        next_state <= state_D;
    WHEN "100" =>
        next_state <= state_E;
    WHEN OTHERS =>
        next_state <= state_B;
    END CASE;
END PROCESS;

PROCESS (CLK100MHZ,SWITCHES)
BEGIN
    IF RISING_EDGE(CLK100MHZ) THEN                              -- The state machine performed using a Multiplexer
        CASE state IS
            WHEN state_i =>
                switch_inputs <= X"FFFFF";                      -- Initializes all the inputs to "1111" since its a unused input number
                 show_this <= X"FFFFF";                         -- Initializes all the values displayed to "1111" so the displays are turned off.
                  basic <= '0';                                 -- A value used to distinguish between a basic input sequence and a random sequence
                  state_count <= "00";                          -- Used to distinguish how many random states have been entered.
                  RNDM_SEQ <= X"FFFFF";                         -- Reinitalizes the RNDM_SEQ incase of another try.
                IF(INIT = '1') THEN                             -- Checks if the initialize button has been pressed
                    basic <= NOT basic; state <= state_A;       -- If pressed the machine is set to basic sequence
                ELSIF (RNDM = '1') THEN                         -- If pressed the machine is set to random sequence
                        state_count <= state_count + 1;         -- Increments one state, so the next state will be the final entry
                        state <= current_state;                 -- Assigns to a state based on the random generated state
                ELSIF(INIT = '0' AND RNDM = '0') THEN           -- If nothing is pressed stay at the initial state
                    state <= state_i;
                END IF;
                
            WHEN state_A =>
                show_this(19 DOWNTO 16) <= X"1";                                                -- Display which key is to be entered
                IF(SET = '1' AND switch_inputs(19 DOWNTO 16) = X"F" AND SWITCHES <= X"9") THEN  -- Checks checks if the binary input has changed and ready
                    switch_inputs(19 DOWNTO 16) <= SWITCHES;                                    -- to be read, conserves the switch inputs to compare at the
                    show_this(19 DOWNTO 16) <= SWITCHES;                                        -- final state, displays the input keys.
                ELSIF (SET = '0' AND switch_inputs(19 DOWNTO 16) /= X"F" AND basic = '1') THEN  -- Checks if the button has been released and keys input
                    state <= state_B;                                                           -- Transitions to the next state
                ELSIF (SET = '0' AND switch_inputs(19 DOWNTO 16) /= X"F" AND basic = '0') THEN  -- Checks if a random sequence is in place
                        RNDM_SEQ(19 DOWNTO 16) <= X"7";                                         -- Conserves the value of the random key input
                    IF  (state_count = "01") THEN                                               -- checks how many keys have been input
                        state_count <= state_count + 1;                                         -- increments the amount of that has been input
                        state <= next_state;                                                    -- Transitions to the next random state
                    ELSIF (state_count >= "10") THEN                                            -- Checks if all keys have been entered
                        state <= state_R;                                                       -- Transitions to the final state for sequence check
                    END IF;
                ELSIF (RST = '1') THEN                                                          -- Resets to the initial state
                    state <= state_i;
                END IF;
                
            WHEN state_B =>
                show_this(15 DOWNTO 12) <= X"2";
                IF (SET = '1' AND switch_inputs(15 DOWNTO 12) = X"F" AND SWITCHES <= X"9") THEN -- All but the final states F and R has the same function.
                    switch_inputs(15 DOWNTO 12) <= SWITCHES;
                    show_this(15 DOWNTO 12) <= SWITCHES;
                ELSIF (SET ='0' AND switch_inputs(15 DOWNTO 12) /= X"F" AND basic = '1') THEN
                    state <= state_C;
                ELSIF (SET ='0' AND switch_inputs(15 DOWNTO 12) /= X"F" AND basic = '0') THEN
                        RNDM_SEQ(15 DOWNTO 12) <= X"3";
                    IF  (state_count = "01") THEN
                        state_count <= state_count + 1;
                        state <= next_state;
                    ELSIF (state_count >= "10") THEN
                        state <= state_R;
                    END IF;
                ELSIF (RST = '1') THEN
                    state <= state_i;
                END IF;
                
            WHEN state_C => 
                show_this(11 DOWNTO 8) <= X"3";
                IF (SET = '1' AND switch_inputs(11 DOWNTO 8) = X"F" AND SWITCHES <= X"9") THEN
                    switch_inputs(11 DOWNTO 8) <= SWITCHES;
                    show_this(11 DOWNTO 8) <= SWITCHES;
                ELSIF(SET = '0' AND switch_inputs(11 DOWNTO 8) /= X"F" AND basic = '1') THEN
                        state <= state_D; 
                ELSIF(SET = '0' AND switch_inputs(11 DOWNTO 8) /= X"F" AND basic = '0') THEN
                        RNDM_SEQ(11 DOWNTO 8) <= X"7";
                    IF  (state_count = "01") THEN
                        state_count <= state_count +1;
                        state <= next_state;
                    ELSIF (state_count >= "10") THEN
                        state <= state_R;
                    END IF;
                ELSIF (RST = '1') THEN
                    state <= state_i;
                END IF;
                
            WHEN state_D => 
                show_this(7 DOWNTO 4) <= X"4";
                IF (SET = '1' AND switch_inputs(7 DOWNTO 4) = X"F" AND SWITCHES <= X"9") THEN
                    switch_inputs(7 DOWNTO 4) <= SWITCHES;
                    show_this(7 DOWNTO 4) <= SWITCHES;
                ELSIF (SET = '0' AND switch_inputs(7 DOWNTO 4) /= X"F" AND basic = '1') THEN
                        state <= state_E;
                ELSIF (SET = '0' AND switch_inputs(7 DOWNTO 4) /= X"F" AND basic = '0') THEN
                        RNDM_SEQ(7 DOWNTO 4) <= X"8";
                    IF  (state_count = "01") THEN
                        state_count <= state_count +1;
                        state <= next_state;
                    ELSIF (state_count >= "10") THEN
                        state <= state_R;
                    END IF;
                ELSIF (RST = '1') THEN
                    state <= state_i;
                END IF;
                
            WHEN state_E => 
                show_this(3 DOWNTO 0) <= X"5";
                IF (SET = '1' AND switch_inputs(3 DOWNTO 0) = X"F" AND SWITCHES <= X"9") THEN
                    switch_inputs(3 DOWNTO 0) <= SWITCHES;
                    show_this(3 DOWNTO 0) <= SWITCHES;
                ELSIF(SET = '0' AND switch_inputs(3 DOWNTO 0) /= X"F" AND basic = '1') THEN
                    state <= state_F;
                ELSIF(SET = '0' AND switch_inputs(3 DOWNTO 0) /= X"F" AND basic = '0') THEN
                        RNDM_SEQ(3 DOWNTO 0) <= X"3";
                    IF  (state_count = "01") THEN
                        state_count <= state_count +1;
                        state <= next_state;
                    ELSIF (state_count >= "10") THEN
                        state <= state_R;
                    END IF;
                ELSIF (RST = '1') THEN
                    state <= state_i;
                END IF;
                
            WHEN state_F =>
                IF (switch_inputs = CORRECT_SEQ) THEN                       -- Checks if input is the correct sequence
                    IF (clk1hz = '1' AND displayed_sequence = '0') THEN     -- Used to distinguish between whether the key or the message is displayed
                        show_this <= X"FFF0B";                              -- Displays OK on the rightmost two displays
                        displayed_sequence <= '1';                          -- Used to distinguish that OK has been displayed for 1 second
                    ELSIF (clk1hz = '1' AND displayed_sequence = '1') THEN  -- checks if OK has been displayed if so
                        show_this <= switch_inputs;                         -- display the key inputs
                        displayed_sequence <= '0';                          -- used to distingush that the key inputs have been displayed
                    END IF;
                ELSIF (switch_inputs /= CORRECT_SEQ) THEN                   -- Checks if input is the incorrect sequence
                    IF (clk1hz = '1' AND displayed_sequence = '0') THEN     -- used to distingush whether the key or the message is displayed
                        show_this <= X"EAADA";                              -- Display the word Error
                        displayed_sequence <= '1';                          -- Used to distinguish wheter Error has been displayed or not
                    ELSIF (clk1hz = '1' AND displayed_sequence = '1') THEN  -- Checks if Error has been displayed
                        show_this <= switch_inputs;                         -- Displays the key sequence entered
                        displayed_sequence <= '0';                          -- User to distinguish that the wrong key sequence has been displayed
                    END IF;                                                 -- for 1 second
                END IF;
                
                IF(RST = '1') THEN                                          -- Enables the ability to reset to the inital state.
                    state <= state_i;
                END IF;
                
            WHEN state_R =>
                IF (switch_inputs = RNDM_SEQ) THEN                          -- The same functions that was applied to the basic sequence was applied
                    IF (clk1hz = '1' AND displayed_sequence = '0') THEN     -- to the random with a minor difference that only the input keys
                        show_this <= X"FFF0B";                              -- are compared.
                        displayed_sequence <= '1';
                    ELSIF (clk1hz = '1' AND displayed_sequence = '1') THEN
                        show_this <= switch_inputs;
                        displayed_sequence <= '0';
                    END IF;
                 ELSIF (switch_inputs /= RNDM_SEQ) THEN
                    IF (clk1hz = '1' AND displayed_sequence = '0') THEN
                        show_this <= X"EAADA";
                        displayed_sequence <= '1';
                    ELSIF (clk1hz = '1' AND displayed_sequence = '1') THEN
                        show_this <= switch_inputs;
                        displayed_sequence <= '0';
                    END IF;
                END IF;
                
                IF(RST = '1') THEN 
                    state <= state_i;
                END IF;
                
            WHEN OTHERS =>
                    state <= state_A;
        END CASE;
    END IF;
END PROCESS;

-- Output logic
LEDS(0) <= '1' WHEN state = state_A ELSE '0';   -- Signals that the machine is at the first state
LEDS(1) <= '1' WHEN state = state_B ELSE '0';   -- Signals that the machine is at the second state
LEDS(2) <= '1' WHEN state = state_C ELSE '0';   -- Signals that the machine is at the third state
LEDS(3) <= '1' WHEN state = state_D ELSE '0';   -- Signals that the machine is at the fourth state
LEDS(4) <= '1' WHEN state = state_E ELSE '0';   -- Signals that the machine is at the fifth state
Z <= '1' WHEN state = state_F AND (switch_inputs = CORRECT_SEQ OR switch_inputs = RNDM_SEQ) ELSE '0';  -- Outputs HIGH when the correct key sequence is input

END ARCHITECTURE Behavioral;
