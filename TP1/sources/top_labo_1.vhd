---------------------------------------------------------------------------------------------------
-- 
-- top_labo_1.vhd
-- fichier d'interface avec la carte de développement

-- Pierre Langlois
-- v. 1.0, 2022/01/04 pour le laboratoire #1
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;  
use work.all;

entity top_labo_1 is
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

architecture arch of top_labo_1 is

constant W : positive := 4;
signal A : unsigned(W - 1 downto 0);
signal pair, divpar4, divpar5, divpar8 : std_logic;

begin
    
    -- instanciation de l'unité du vote à majorité qualifiée
UUT : entity demo_combinatoire(arch1)
        generic map (W)
        port map (A, pair, divpar4, divpar5, divpar8);
        
    -- connexion des interfaces de la carte aux ports d'entrée de l'unité du vote
    A <= unsigned(sw(15 downto 12));    -- l'entrée A; noter la conversion explicite de type
    led(0) <= pair;                     -- sortie pair
    led(1) <= divpar4;                  -- sortie divisible par 4
    led(2) <= divpar5;                  -- sortie divisible par 5
    led(3) <= divpar8;                  -- sortie divisible par 8
    led(15 downto 12) <= sw(15 downto 12); -- pour confirmer le fonctionnement des commutateurs
    
end arch;