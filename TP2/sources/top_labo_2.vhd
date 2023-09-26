---------------------------------------------------------------------------------------------------
-- 
-- top_labo_2.vhd
--
-- Pierre Langlois
-- v. 2.0, 2022/01/08 pour le laboratoire #2
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;  
use work.utilitaires_inf3500_pkg.all;
use work.all;

entity top_labo_2 is
    port(
        clk : in std_logic;                         -- l'horloge de la carte à 100 MHz
        sw : in std_logic_vector(15 downto 0);      -- les 16 commutateurs
        led : out std_logic_vector(15 downto 0);    -- les 16 LED
        seg : out std_logic_vector(7 downto 0);     -- les cathodes partagées des quatre symboles à 7 segments + point
        an : out std_logic_vector(3 downto 0);      -- les anodes des quatre symboles à 7 segments + point
        btnC : in std_logic;                        -- bouton du centre
        btnU : in std_logic;                        -- bouton du haut
        btnL : in std_logic;                        -- bouton de gauche
        btnR : in std_logic;                        -- bouton de droite
        btnD : in std_logic                         -- bouton du bas
    );
end;

architecture arch of top_labo_2 is

constant N_salles : positive := 16;
signal zone : unsigned(1 downto 0);

signal symboles : quatre_symboles;

begin
    
    -- instanciation de l'unité du musée
    UUT : entity musee_labo_2(arch)
        generic map (N => N_salles)
        port map (
            detecteurs_mouvement => sw(15 downto 0),
            alarme_intrus => led(0),
            alarme_jasette => led(1),
            alarme_greve => led(2),
            alarme_generale => led(3),
            alarme_reserve => led(4),
            zone_reserve => zone
            );
            
    symboles <= (hex_to_7seg(to_unsigned(0, 4)), hex_to_7seg(to_unsigned(0, 4)), hex_to_7seg(to_unsigned(0, 4)), hex_to_7seg("00" & zone));
 
   -- Circuit pour sérialiser l'accès aux quatre symboles à 7 segments.
   -- L'affichage contient quatre symboles chacun composé de sept segments et d'un point.
   -- L'horloge de 100 MHz est ramenée à environ 100 Hz en la divisant par 2^19.
    process(all)
    variable clkCount : unsigned(19 downto 0) := (others => '0');
    begin
        if (clk'event and clk = '1') then
            clkCount := clkCount + 1;           
        end if;
        case clkCount(clkCount'left downto clkCount'left - 1) is
            when "00" => an <= "1110"; seg <= symboles(0);
            when "01" => an <= "1101"; seg <= symboles(1);
            when "10" => an <= "1011"; seg <= symboles(2);
            when others => an <= "0111"; seg <= symboles(3);
        end case;
    end process;
        
end arch;