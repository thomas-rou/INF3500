---------------------------------------------
--
-- demo_combinatoire_tb
--
-- Banc d'essai pour le module demo_combinatoire
--
-- v. 1.0 2022-01-04 Pierre Langlois
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity demo_combinatoire_tb is
    generic (
        W_tb : positive := 4
    );
end demo_combinatoire_tb;

architecture arch of demo_combinatoire_tb is

signal A_tb : unsigned(W_tb - 1 downto 0);
signal pair_tb, divpar4_tb, divpar5_tb, divpar8_tb : std_logic;

constant periode : time := 10 ns;
    
begin
    
    -- instanciation du module à vérifier UUT (Unit Under Test)
    UUT : entity demo_combinatoire(arch1)
        generic map (W => W_tb)
        port map (
            A => A_tb,
            pair => pair_tb,
            divpar4 => divpar4_tb,
            divpar5 => divpar5_tb,
            divpar8 => divpar8_tb
        );

    -- application exhaustive des vecteurs de test
    -- ** pas de vérification ** : il faut observer les signaux d'entrée et de sortie avec une trace
    process
    begin
        for k in 0 to 2 ** A_tb'length - 1 loop
            A_tb <= to_unsigned(k, A_tb'length);
            wait for periode;  -- nécessaire pour que les signaux se propagent dans l'UUT
        end loop;
        report "simulation terminée" severity failure;
    end process;
    
end arch;