-------------------------------------------------------------------------------
--
-- musee_labo_2_tb
--
-- v. 2.1 2022-01-08 Pierre Langlois version à compléter pour le labo 2
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.all;

entity musee_labo_2_tb is
    generic (
        N_tb : positive := 16
    );
end entity;

architecture arch of musee_labo_2_tb is
    
signal detecteurs_mouvement_tb : std_logic_vector(N_tb - 1 downto 0) ;
signal alarme_intrus_tb : std_logic;
signal alarme_jasette_tb : std_logic;
signal alarme_greve_tb : std_logic;
signal alarme_generale_tb : std_logic;
signal alarme_reserve_tb : std_logic;
signal zone_reserve_tb : unsigned(1 downto 0);

begin

    -- instanciation du module à vérifier UUT (Unit Under Test)
    UUT : entity musee_labo_2(arch)
        generic map (N => N_tb)
        port map (
            detecteurs_mouvement => detecteurs_mouvement_tb,
            alarme_intrus => alarme_intrus_tb,
            alarme_jasette => alarme_jasette_tb,
            alarme_greve => alarme_greve_tb,
            alarme_generale => alarme_generale_tb,
            alarme_reserve => alarme_reserve_tb,
            zone_reserve => zone_reserve_tb
            );
    
    -- application exhaustive des vecteurs de test, affichage et vérification
    process
	variable compte_tb : natural := 0;
    begin
		compte_tb := 0;
        for k in 0 to 2 ** N_tb - 1 loop

            detecteurs_mouvement_tb <= std_logic_vector(to_unsigned(k, N_tb));

            wait for 10 ns; -- nécessaire pour que les signaux se propagent dans l'UUT	
			
			compte_tb := 0;	
			
			for k in N_tb - 1 downto 0 loop
				if detecteurs_mouvement_tb(k) = '1' then
				compte_tb := compte_tb + 1;
				end if;
			end loop;
		  	
			if compte_tb = 0 then				
				assert(alarme_greve_tb = '1')		report "erreur grève" 		severity warning;
				assert(alarme_jasette_tb = '0' or alarme_intrus_tb = '0' or alarme_generale_tb = '0')	report "Plusieurs alarmes" 	severity warning;
			elsif compte_tb <= 2 then
				assert(alarme_jasette_tb = '1')		report "erreur jasette" 	severity warning;
				assert(alarme_greve_tb = '0' or alarme_intrus_tb = '0' or alarme_generale_tb = '0')		report "Plusieurs alarmes" 	severity warning;
			elsif compte_tb >= 4 and compte_tb < N_tb then
				assert(alarme_intrus_tb = '1')		report "erreur intrus" 		severity warning;
				assert(alarme_jasette_tb = '0' or alarme_greve_tb = '0' or alarme_generale_tb = '0')	report "Plusieurs alarmes" 	severity warning;
			elsif compte_tb = N_tb then
				assert(alarme_generale_tb = '1')	report "erreur générale" 	severity warning;
				assert(alarme_jasette_tb = '0' or alarme_intrus_tb = '0' or alarme_greve_tb = '0')		report "Plusieurs alarmes" 	severity warning;
            end if;
        end loop;
            
        report "simulation terminée" severity failure;
        
    end process;
    
end arch;
