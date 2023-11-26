---------------------------------------------------------------------------------------------------
--
-- interface_utilisateur.vhd
--
-- v. 1.0 Pierre Langlois 2022-03-16 pour le labo #5, INF3500
--
-- TODO : comme les états sont très semblables, on pourrait les paramétrer selon quelques catégories, et utiliser une machine
-- générale pour les parcourir. La machine lirait les paramètres et les appliquerait.
-- 		message ou non, le message ou un pointeur
-- 		entrée ou non
-- 		pause ou non
-- 		prochain état
-- 		etc.
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.utilitaires_inf3500_pkg.all;
use work.all;

entity interface_utilisateur is
    generic (
        f_clk      : positive := 100e6;     -- fréquence de l'horloge de référence, en Hz
        taux_tx    : positive := 9600       -- taux de transmission en baud (symboles par seconde), ici des bits par seconde
    );
    port (
        reset, clk : in  std_logic;
        RsRx       : in  std_logic;         	-- interface USB-RS-232 réception 
		res		   : in unsigned(15 downto 0);	-- input d'un résultat extérieur
		res_pret   : in std_logic;				-- input indiquant si le résultat est prêt à être lus
        RsTx       : out std_logic;         	-- interface USB-RS-232 transmission
        A, B       : out unsigned(7 downto 0);
        input_ok   : out std_logic          	-- on a reçu toutes les entrées des utilisateurs
    );
end;

architecture arch of interface_utilisateur is

    -- ** Tous les messages doivent avoir la même taille **
    -- CR, "carriage return," est un retour de charriot au début de la ligne
    -- LF, "line feed,"       est un changement de ligne
    constant m0 : string := CR & LF & "Bonjour, bienvenue au programme du calcul du PGFC entre deux nombres.v1751" 						& CR & LF;
    constant m1 : string := CR & LF & "Entrez le nombre à quatres chiffres hexadécimaux {0 - 9, A - F}.          " 						& CR & LF;	-- changement du message pour un seul input au lieu de deux
    constant m3 : string := CR & LF & "Calculs en cours.                                                         " 						& CR & LF;  
    constant m4 : string := CR & LF & "Résultat : " & to_hstring(res) &  "                                                           " 	& CR & LF;	-- message incluant l'entrée des résultats
    constant m9 : string := CR & LF & "Erreur, nombre invalide, chiffres hexadécimaux seulement {0 - 9, A - F}.  " 						& CR & LF;	-- message d'erreur de mauvaise entrée

    signal message : string(1 to m0'length);
    signal caractere : character;

    type etat_type is (s_bienvenue, s_n1_m, s_n1_H, s_n1_L, s_n2_H, s_n2_L, s_calcul, s_resultat, s_erreur);
    signal etat : etat_type := s_bienvenue;

    signal go_tx   : std_logic;
    signal tx_pret : std_logic;
    signal car_recu : std_logic;

    signal clk_1_MHz : std_logic;

begin

    transmetteur : entity uart_tx_message(arch)
		generic map (f_clk, taux_tx, m0'length)
		port map (reset, clk, message, go_tx, tx_pret, RsTx);

    recepteur : entity uart_rx_char(arch)
		generic map (f_clk, taux_tx)
		port map (reset, clk, RsRx, caractere, car_recu);

    -- une horloge pour ralentir l'interface et laisser le temps aux communications de se faire
    gen_horloge_1_MHz  : entity generateur_horloge_precis(arch) generic map (f_clk, 1e6)  port map (clk, clk_1_MHz);

    process(all)
    variable c : character;
    constant delai : natural := 4; -- délai entre deux transmissions, en 1 / secondes (10 == 0.1 s, 5 == 0.2 s, etc.)
    variable compteur_delai : natural range 0 to f_clk / delai - 1; -- pour insérer une pause dans les transmissions
    begin
        if reset = '1' then
            etat <= s_bienvenue;
            go_tx <= '0';
            compteur_delai := f_clk / delai - 1;
        elsif rising_edge(clk) then
            case etat is
            when s_bienvenue =>
                -- message de bienvenue
                go_tx <= '0';
                -- prendre une pause entre deux messages, pour laisser au transmetteur le temps de faire son travail
                if compteur_delai = 0 then
                    if tx_pret = '1' then
                        message <= m0;
                        go_tx <= '1';
                        etat <= s_n1_m;
                        compteur_delai := f_clk / delai - 1;
                    end if;
                else
                    compteur_delai := compteur_delai - 1;
                end if;
            when s_n1_m =>
                -- message pour nombre
                go_tx <= '0';
                -- prendre une pause entre deux messages, pour laisser au transmetteur le temps de faire son travail
                if compteur_delai = 0 then
                    if tx_pret = '1' then
                        message <= m1;
                        go_tx <= '1';
                        etat <= s_n1_H;
                    end if;
                else
                    compteur_delai := compteur_delai - 1;
                end if;
            when s_n1_H =>
                -- recevoir le chiffre le plus significatif du nombre
                go_tx <= '0';
                if car_recu = '1' then
					if ((caractere >= '0' and caractere <= '9') or (caractere >= 'A' and caractere <= 'F')) then
                    	A(7 downto 4) <= character_to_hex(caractere);
                    	etat <= s_n1_L;
					else
						etat <= s_erreur;
					end if;
                end if;
            when s_n1_L =>
                -- recevoir le deuxième chiffre le plus significatif du premier nombre
                go_tx <= '0';
                if car_recu = '1' then
					if ((caractere >= '0' and caractere <= '9') or (caractere >= 'A' and caractere <= 'F')) then
                    	A(3 downto 0) <= character_to_hex(caractere);
                    	etat <= s_n2_H;
					else
						etat <= s_erreur;
					end if;
                end if;
            when s_n2_H =>
                -- recevoir le troisième chiffre le plus significatif du nombre
                go_tx <= '0';
                if car_recu = '1' then
					if ((caractere >= '0' and caractere <= '9') or (caractere >= 'A' and caractere <= 'F')) then
                    	B(7 downto 4) <= character_to_hex(caractere);
                    	etat <= s_n2_L;
					else
						etat <= s_erreur;
					end if;
                end if;
            when s_n2_L =>
                -- recevoir le chiffre moins significatif du nombre
                go_tx <= '0';
                if car_recu = '1' then
					if ((caractere >= '0' and caractere <= '9') or (caractere >= 'A' and caractere <= 'F')) then
                    	B(3 downto 0) <= character_to_hex(caractere);
                    	etat <= s_calcul;
					else
						etat <= s_erreur;
					end if;
                end if;
			when s_calcul =>
                if tx_pret = '1' then
					message <= m3; -- passe le message m3 comme message
                 	go_tx <= '1';
                   	etat <= s_resultat;
                   	compteur_delai := f_clk / delai - 1;
                end if;
            when s_resultat =>
				go_tx <= '0';
				-- prendre une pause entre deux messages, pour laisser au transmetteur le temps de faire son travail
				if compteur_delai = 0 then
                -- message pour les résultats
                	if tx_pret = '1' and res_pret = '1' then
						message <= m4; -- passe le message m4 contenant le résultat comme message
                 		go_tx <= '1';
                   		etat <= s_bienvenue;
                   		compteur_delai := f_clk / delai - 1;
                	end if;
				else
                    compteur_delai := compteur_delai - 1;
                end if;
			when s_erreur =>
				-- message d'erreur
				go_tx <= '0';
				if tx_pret = '1' then
					message <= m9;
					go_tx <= '1';
					etat <= s_bienvenue;
					compteur_delai := f_clk / delai - 1;
				end if;
            when others =>
                go_tx <= '0';
                etat <= s_bienvenue;
                compteur_delai := f_clk / delai - 1;
            end case;
        end if;
    end process;

    input_ok <= '1' when etat = s_resultat else '0';

end;
