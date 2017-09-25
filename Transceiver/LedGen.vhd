library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LedGen is
    port 
    (
        Clk             : in  std_logic;
        ResetN          : in  std_logic;
        Brightness      : out std_logic_vector(31 downto 0)
    );
end entity;

architecture LedGen_Arch of LedGen is
constant cUpdateRate    : natural := 50*1000*10;

signal UpdateCnt        : natural;
signal Direction        : natural;
signal UpCountIdx       : natural := 1;
signal DownCountIdx     : natural;
signal BrightnessTemp   : std_logic_vector(31 downto 0) := x"0000000F";

begin
    Brightness <= BrightnessTemp;
    
    process(Clk, ResetN)
    begin
        if(ResetN = '0') then
            BrightnessTemp <= x"0000000F";
            Direction <= 0;
            UpCountIdx <= 1;
            DownCountIdx <= 0;
            UpdateCnt <= 0;
            
        elsif((Clk'event) and (Clk = '1')) then
            if(UpdateCnt < cUpdateRate-1) then
                UpdateCnt <= UpdateCnt + 1;
            else
                UpdateCnt <= 0;
                
                for i in 0 to 7 loop
                    if(i = UpCountIdx) then
                        if(unsigned(BrightnessTemp(((i*4)+3) downto (i*4))) < 15) then
                            BrightnessTemp(((i*4)+3) downto (i*4)) <= std_logic_vector(unsigned(BrightnessTemp(((i*4)+3) downto (i*4))) + 1);
                        end if;
                        
                        if(unsigned(BrightnessTemp(((i*4)+3) downto (i*4))) = 14) then
                            if(Direction = 0) then
                                if(i < 7) then
                                    UpCountIdx <= UpCountIdx + 1;
                                else
                                    Direction <= 1;
                                    UpCountIdx <= UpCountIdx - 1;
                                end if;
                                DownCountIdx <= UpCountIdx;
                            else
                                if(i > 0) then
                                    UpCountIdx <= UpCountIdx - 1;
                                else
                                    Direction <= 0;
                                    UpCountIdx <= UpCountIdx + 1;
                                end if;
                                DownCountIdx <= UpCountIdx;
                            end if;
                        end if;
                    end if;
                    if(i = DownCountIdx) then
                        if(unsigned(BrightnessTemp(((i*4)+3) downto (i*4))) > 0) then
                            BrightnessTemp(((i*4)+3) downto (i*4)) <= std_logic_vector(unsigned(BrightnessTemp(((i*4)+3) downto (i*4))) - 1);
                        end if;
                    end if;
                end loop;
            end if;
        end if;
    end process;
    
end LedGen_Arch;