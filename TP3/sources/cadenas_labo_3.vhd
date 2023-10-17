---------------------------------------------------------------------------------------------------
-- 
-- cadenas_labo_3.vhd
--
-- v. 1.0 Pierre Langlois 2022-01-21 laboratoire #3 INF3500, fichier de démarrage
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity cadenas_labo_3 is
    generic (
        M : positive := 5; -- le nombre d'entrées dans la combinaison
        N : positive := 4 -- le nombre de boutons
        );
    port (
        reset, clk : in std_logic;
        boutons : in std_logic_vector(N - 1 downto 0);
        mode : in std_logic_vector(1 downto 0);
        ouvrir : out std_logic;
        alarme : out std_logic;
        message : out string
        );
end cadenas_labo_3;

architecture arch of cadenas_labo_3 is
    
    type etat_type is (e_00, e_01, e_02, e_03, e_04);
    signal etat : etat_type := e_00;
    
    type combinaison_type is array (0 to M - 1) of std_logic_vector(N - 1 downto 0);
    signal combinaison : combinaison_type;
    constant combinaison_base : combinaison_type := ("0001", "0010", "0100", "1000", "0001");
    
begin
    
    -- processus pour la séquence des états
    process(all) is
    begin
        if reset = '1' then
            etat <= e_00;
        elsif rising_edge(clk) then
            case etat is
                when e_00 =>
                    if boutons(0) = '1' then
                        etat <= e_01;
                    end if;
                when e_01 =>
                    if boutons(0) = '1' then
                        etat <= e_02;
                    end if;
                when e_02 =>
                    if boutons(0) = '1' then
                        etat <= e_03;
                    end if;
                when e_03 =>
                    if boutons(0) = '1' then
                        etat <= e_04;
                    end if;
                when e_04 =>
                    if boutons(0) = '1' then
                        etat <= e_00;
                    end if;
                 when others =>
                    etat <= e_00;
            end case;
        end if;
    end process;
    
    -- processus pour les sorties
    process(all)
    begin
        case etat is
            when e_00 =>
                ouvrir <= '0';
                alarme <= '1';
                message <= "e_00";
            when e_01 =>
                ouvrir <= '0';
                alarme <= '0';
                message <= "e_01";
            when e_02 =>
                ouvrir <= '0';
                alarme <= '0';
                message <= "e_02";
            when e_03 =>
                ouvrir <= '0';
                alarme <= '0';
                message <= "e_03";
            when e_04 =>
                ouvrir <= '1';
                alarme <= '0';
                message <= "e_04";
            when others =>
                ouvrir <= '0';
                alarme <= '0';
                message <= "eror";
        end case;
    end process;
    
end arch;
