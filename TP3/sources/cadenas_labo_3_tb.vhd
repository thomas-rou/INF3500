---------------------------------------------------------------------------------------------------
-- 
-- cadenas_labo_3_tb.vhd
--
-- v. 1.0 Pierre Langlois 2022-01-21 laboratoire #3 INF3500, fichier de démarrage
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity cadenas_labos_3_tb is
    generic (
        M : positive := 5; -- le nombre d'entrées dans la combinaison
        N : positive := 4 -- le nombre de boutons
    );    
end cadenas_labos_3_tb;

architecture arch of cadenas_labos_3_tb is

    signal reset : STD_LOGIC;
    signal clk : STD_LOGIC := '0';
    constant periode : time := 10 ns;
    
    signal boutons : std_logic_vector(N - 1 downto 0);
    signal mode : std_logic_vector(1 downto 0);
    signal ouvrir : STD_LOGIC;
    signal alarme : std_logic;
    signal message : string(1 to 4);
    
    type combinaison_type is array (0 to 19) of std_logic_vector(N - 1 downto 0);
    signal vecteurs : combinaison_type := (
    "0001", "0001", "0001", "0001", "0001", 
    "0000", "0000", "0000", "0000", "0001", 
    "0001", "0010", "0100", "1000", "0001",
    "0001", "0010", "0100", "1000", "0001"
    );
    
    signal vecteur_tests_un_bouton : std_logic_vector(15 downto 0) := "0011100101110011";

begin

    UUT : entity cadenas_labo_3(arch)
        generic map (M, N)
        port map (reset, clk, boutons, mode, ouvrir, alarme, message);

    clk <= not clk after periode / 2;
    reset <= '1' after 0 ns, '0' after 5 * periode / 4;
    
    process(clk)
    variable indice : natural range 0 to vecteurs'length;
    begin
        
        if reset = '1' then
            indice := 0;
        elsif falling_edge(clk) then -- on choisit la polarité d'horloge inverse de celle de l'UUT pour simplifier la lecture de la trace
            if indice < vecteur_tests_un_bouton'length then
                boutons(0) <= vecteur_tests_un_bouton(indice);
                report "bouton : " & to_string(vecteur_tests_un_bouton(indice))
                    & ", message : " & message
                    & ", alarme : " & to_string(alarme)
                    & ", ouvrir : " & to_string(ouvrir)
                    severity note;
                indice := indice + 1;
            else
                report "simulation terminée" severity failure;
            end if;
            
        end if;
    end process;

end arch;

