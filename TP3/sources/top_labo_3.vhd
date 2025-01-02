---------------------------------------------------------------------------------------------------
-- 
-- top_labo_3.vhd
--
-- v. 1.0 Pierre Langlois 2022-01-09 probl�me du cadenas
--
-- Digilent Basys 3 Artix-7 FPGA Trainer Board 
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;  
use work.utilitaires_inf3500_pkg.all;
use work.all;

entity top_labo_3 is
    port(
        clk : in std_logic;                        -- l'horloge de la carte � 100 MHz
        sw : in std_logic_vector(15 downto 0);     -- les 16 commutateurs
        led : out std_logic_vector(15 downto 0);   -- les 16 LED
        seg : out std_logic_vector(7 downto 0);    -- les cathodes partag�es des quatre symboles � 7 segments + point
        an : out std_logic_vector(3 downto 0);     -- les anodes des quatre symboles � 7 segments + point
        btnC : in std_logic;                       -- bouton du centre
        btnU : in std_logic;                       -- bouton du haut
        btnL : in std_logic;                       -- bouton de gauche
        btnR : in std_logic;                       -- bouton de droite
        btnD : in std_logic                        -- bouton du bas
    );
end;

architecture arch of top_labo_3 is

    signal clk_50_Hz : std_logic;
    
    signal message : string(1 to 4);
    signal symboles : quatre_symboles;
    
    signal btnC_stable, btnU_stable, btnL_stable, btnR_stable, btnD_stable : std_logic;
    signal NC1, NC2, NC3, NC4, NC5 : std_logic;    -- pour fils Non Connect�s

begin

    -- g�n�ration de l'horloge du circuit � partir de l'horloge � 100 MHz de la carte
    gen_horloge : entity generateur_horloge_precis(arch) generic map (100e6, 50) port map (clk, clk_50_Hz);
        
    -- stabilisation et synchronisation des boutons avec l'horloge du circuit
    lebtnC : entity monopulseur(arch) generic map ('1', '1', 1, 1) port map (clk_50_Hz, btnC, btnC_stable, NC1);
    lebtnU : entity monopulseur(arch) generic map ('1', '1', 1, 1) port map (clk_50_Hz, btnU, btnU_stable, NC2);
    lebtnL : entity monopulseur(arch) generic map ('1', '1', 1, 1) port map (clk_50_Hz, btnL, btnL_stable, NC3);
    lebtnR : entity monopulseur(arch) generic map ('1', '1', 1, 1) port map (clk_50_Hz, btnR, btnR_stable, NC4);
    lebtnD : entity monopulseur(arch) generic map ('1', '1', 1, 1) port map (clk_50_Hz, btnD, btnD_stable, NC5);

    -- allumage de LED par les cinq boutons, pour se rassurer
    led(15 downto 11) <= (btnC, btnD, btnL, btnU, btnR);

    -- allumage de LED par les cinq boutons stabilis�s - impulsion d'activation - pour se rassurer
    led(10 downto 6) <= (btnC_stable, btnD_stable, btnL_stable, btnU_stable, btnR_stable);

    -- instantiation du module principal
    entite_principale : entity cadenas_labo_3(arch)
        generic map (
            M => 5,
            N => 4
        )
        port map (
            clk => clk_50_Hz,
            reset => btnC_stable,
            boutons(3 downto 0) => (btnD_stable, btnL_stable, btnU_stable, btnR_stable),
            mode => (sw(1), sw(0)),
            ouvrir => led(0),
            alarme => led(1),
            message => message
        );
        
    -- connexion des caract�res du message � l'affichage quadruple � 7 segments
    symboles(3) <= character_to_7seg(message(1));
    symboles(2) <= character_to_7seg(message(2));
    symboles(1) <= character_to_7seg(message(3));
    symboles(0) <= character_to_7seg(message(4));

    -- circuit pour s�rialiser l'acc�s � l'affichage
    -- l'affichage contient quatre symboles chacun compos� de sept segments et d'un point
    process(all)
    variable clkCount : unsigned(19 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            clkCount := clkCount + 1;           
        end if;
        case clkCount(clkCount'left downto clkCount'left - 1) is     -- L'horloge de 100 MHz est ramen�e � environ 100 Hz en la divisant par 2^19
            when   "00" => an <= "1110"; seg <= symboles(0);         -- Effectivement on prend les deux bits les plus significatifs d'un compteur de 20 bits.
            when   "01" => an <= "1101"; seg <= symboles(1);
            when   "10" => an <= "1011"; seg <= symboles(2);
            when others => an <= "0111"; seg <= symboles(3);
        end case;
    end process;
        
end arch;
