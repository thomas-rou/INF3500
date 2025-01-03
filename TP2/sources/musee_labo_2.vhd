-------------------------------------------------------------------------------
--
-- musee_labo_2.vhd
--
-- v. 2.1 2022-01-08 Pierre Langlois, version � compl�ter pour le labo 2
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utilitaires_inf3500_pkg.all;

entity musee_labo_2 is
    generic (
        N : positive := 16 -- nombre de salles
    );
    port (
    detecteurs_mouvement : in std_logic_vector(N - 1 downto 0) ;
    alarme_intrus : out std_logic;
    alarme_jasette : out std_logic;
    alarme_greve : out std_logic;
    alarme_generale : out std_logic;
    alarme_reserve : out std_logic;
    zone_reserve : out unsigned(1 downto 0)
    );
end;

architecture arch of musee_labo_2 is

begin
    
    assert N mod 4 = 0 report "Cette architecture ne fonctionne que pour N muliple de 4." severity error;

    -- code � modifier pour la partie 1
	process(detecteurs_mouvement)
	variable compte_detecteur_actif : natural := 0;
	begin
		compte_detecteur_actif 	:= 0;
		alarme_intrus 			<= '0';
		alarme_jasette 			<= '0';
		alarme_greve 			<= '0';
		alarme_generale 		<= '0';
		for k in N - 1 downto 0 loop
			if detecteurs_mouvement(k) = '1' then
				compte_detecteur_actif := compte_detecteur_actif + 1;
			end if;
		end loop;
		if 	compte_detecteur_actif = 0 then
			alarme_greve <= '1'; -- aucun d�tecteur de mouvement n'est actif
		elsif compte_detecteur_actif <= 2 then
			alarme_jasette <= '1'; -- un ou deux d�tecteur de mouvement sont actifs
		elsif compte_detecteur_actif <= (N-1) and compte_detecteur_actif /= 3 then
			alarme_intrus <= '1'; -- au moins 4 d�tecteur de mvmt actif
		elsif compte_detecteur_actif = N then
			alarme_generale <= '1'; -- tous les d�tecteurs sont activ�s
		end if;
	end process;
    
    -- code � modifier pour le bonus de la partie 4a.	
	process(detecteurs_mouvement)
	type vecteur_compteurs_zones is array (natural range <>) of natural;
    variable compte_zones_actives : vecteur_compteurs_zones(0 to 3) := (0, 0, 0, 0);
	variable zone_prioritaire : natural := 0;
	begin
		alarme_reserve <= '0';
    	zone_reserve <= to_unsigned(0, zone_reserve'length); -- la valeur par d�faut de zone_reserve = 0
		compte_zones_actives  := (0, 0, 0, 0);
		zone_prioritaire := 0;
		for zone in 0 to 3 loop
        	for j in zone * (N/4) to ((zone + 1) * (N/4) - 1) loop
            	if detecteurs_mouvement(j) = '1' then
                    compte_zones_actives(zone) := compte_zones_actives(zone) + 1;
                end if;      
        	end loop;
    	end loop;
		
		for i in 0 to 3 loop
			if compte_zones_actives(i) >= 2 then
				alarme_reserve <= '1';			
				if compte_zones_actives(i) > compte_zones_actives(zone_prioritaire) then
        			zone_prioritaire := i;
    			elsif compte_zones_actives(i) = compte_zones_actives(zone_prioritaire) and i <= zone_prioritaire then
        			zone_prioritaire := i;
				end if;
			end if;
		end loop;
		if alarme_reserve = '1' then
			zone_reserve <= to_unsigned(zone_prioritaire, zone_reserve'length);
		else
			zone_reserve <= to_unsigned(0, zone_reserve'length);
		end if;
	end process;

end;