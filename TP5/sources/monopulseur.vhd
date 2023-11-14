---------------------------------------------------------------------------------------------------
--
-- monopulseur.vhd
--
-- v. 1.0, 2022/01/19, Pierre Langlois
-- Inspir� de beaucoup trop de sources pour toutes les citer, mais incluant https://vhdlguru.blogspot.com/2017/09/pushbutton-debounce-circuit-in-vhdl.html.
-- Pour un traitement int�ressant de la question, incluant un grand nombre de r�f�rences, on peut consulter la suite de Maxfield dans l'EE Journal, janvier 2020 :
-- https://www.eejournal.com/article/ultimate-guide-to-switch-debounce-part-1/
--
-- Gestion des rebonds des commutateurs activ�s par un humain et g�n�ration de mono-impulsion.
--
-- Le module a deux entr�es :
-- * une horloge qui doit n�cessairement avoir une fr�quence plus �lev�e que les mouvements humains,
--   donc de l'ordre de 100 Hz ou plus,
-- * une entr�e asynchrone activ�e par un �tre humain qui p�se sur un bouton.
--
-- Le module a deux sorties :
-- * impulsion_debut : une impulsion qui d�bute � la transition d'horloge qui suit le moment o� le bouton est pes�,
-- * impulsion_fin : une impulsion qui d�bute � la transition d'horloge qui suit le moment o� le bouton est rel�ch�.
--
-- Tout est configurable par des generics :
-- * la polarit� du bouton quand il est pes�
-- * la dur�e de la p�riode de rebond, en coups d'horloge
-- * la dur�e des impulsions, en coups d'horloge
--
-- Une fr�quence d'horloge �lev�e permet une meilleure r�activit�, mais rend difficile la synchronisation de plus d'un bouton simultan�ment.
-- La dur�e du rebond est normalement moins de 5 ms (voir la r�f�rence de Maxfield, cit�e plus haut).
-- Pour une horloge de 100 Hz (p�riode 10 ms), un cycle cyle d'horloge suffit pour duree_rebond.
--
--
-- TODO : g�n�raliser pour un vecteur de boutons.
-- TODO : ajouter la possibilit� de g�n�rer un train d'impulsions si le bouton est pes� (une impulsion) puis gard� pes�
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity monopulseur is
    generic (
        polarite_bouton_active : std_logic := '1';                          -- valeur logique quand le bouton est activ�
        polarite_sortie_active : std_logic := '1';                          -- valeur logique de sortie active
        duree_rebond : positive := 10;                                      -- dur�e du rebond du bouton, en cycles d'horloge
        duree_impulsion : positive := 1                                     -- dur�e de l'impulsion de sortie, en cycles d'horloge
--        N_boutons : positive := 1;                                        -- TODO
--        delai_repetition;                                                 -- d�lai d'attente avant de g�n�rer un train d'impulsions parce que le bouton est gard� pes�, en cycles d'horloge
    );
    port (
        clk : in std_logic;                                                 -- l'horloge de r�f�rence
        bouton : in std_logic;                                              -- le bouton asynchrone duquel on veut g�n�rer une impulsion
        impulsion_debut : out std_logic;                                    -- impulsion g�n�r�e quand le bouton est activ�
        impulsion_fin : out std_logic                                       -- impulsion g�n�r�e quand le bouton est rel�ch�
--        boutons : in std_logic_vector(N_boutons - 1 downto 0);            -- TODO
--        impulsion_debut : out std_logic_vector(N_boutons - 1 downto 0);   -- TODO
--        impulsion_fin : out std_logic_vector(N_boutons - 1 downto 0)      -- TODO
    );
end monopulseur;

architecture arch of monopulseur is

    type etat_type is (attend_action, action_recue, stabilisation_action, attend_relache, relache_recue, stabilisation_relache);
    signal etat : etat_type := attend_action;
    signal bouton_1, bouton_2 : std_logic;

begin

    -- double tampon pour r�duire les probabilit�s de m�tastabilit� avec l'entr�e asynchrone
    process(all)
    begin
        if rising_edge(clk) then
            bouton_1 <= bouton;
            bouton_2 <= bouton_1;
        end if;
    end process;

    with etat select
    impulsion_debut <=
        polarite_sortie_active when action_recue,
        not(polarite_sortie_active) when others;

    with etat select
    impulsion_fin <=
        polarite_sortie_active when relache_recue,
        not(polarite_sortie_active) when others;

    -- s�quence des �tats
    process(all)
    variable compteur : natural range 0 to duree_rebond;
    begin
        if rising_edge(clk) then
            case etat is
                when attend_action =>
                    if bouton_2 = polarite_bouton_active then
                        etat <= action_recue;
                    end if;
                when action_recue =>
                    compteur := duree_rebond;
                    etat <= stabilisation_action;
                when stabilisation_action =>
                    compteur := compteur - 1;
                    if compteur = 0 then
                        etat <= attend_relache;
                    end if;
                when attend_relache =>
                    if bouton_2 = not(polarite_bouton_active) then
                        etat <= relache_recue;
                    end if;
                when relache_recue =>
                    compteur := duree_rebond;
                    etat <= stabilisation_relache;
                when stabilisation_relache =>
                    compteur := compteur - 1;
                    if compteur = 0 then
                        etat <= attend_action;
                    end if;
            end case;
        end if;
    end process;

end arch;


---------------------------------------------------------------------------------------------------
--
-- banc d'essai
--
-- v. 1.0, 2022-01-22, bien imparfaite et tr�s incompl�te
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity monopulseur_tb is
    generic (
        polarite_sortie_active : std_logic := '1';
        duree_rebond : positive := 10;
        duree_impulsion : positive := 1
    );
end monopulseur_tb;

architecture arch of monopulseur_tb is

    signal clk : STD_LOGIC := '0';
    signal bouton : std_logic;
    signal impulsion_debut : std_logic;
    signal impulsion_fin : std_logic;

    constant periode : time := 10 ms; -- horloge de 100 Hz

begin

	UUT : entity monopulseur(arch)
        generic map (
            polarite_bouton_active => '1',
            polarite_sortie_active => '1',
            duree_rebond => 10,
            duree_impulsion => 1
        )
        port map (clk, bouton, impulsion_debut, impulsion_fin);

	clk <= not clk after periode / 2;

    bouton <=
        '0' after 0 ns, '1' after 11.7 ms, '0' after 24.7 ms, '1' after 34.7 ms, '0' after 44.7 ms, '1' after 57.7 ms,
        '0' after 102 ms, '1' after 115 ms, '0' after 125 ms, '1' after 135 ms, '0' after 145 ms;

end arch;
