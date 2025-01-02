---------------------------------------------------------------------------------------------------
--
-- uart_tx_char.vhd
--
-- Pierre Langlois
-- v. 1.0 2020-07-23 inspir� de plusieurs modules pr�c�dents
-- v. 1.1 2022-03-16 pour le labo #5 de INF3500, hiver 2022, inspir� entre autres des travaux de Russel � https://www.nandland.com
--
-- Transmission d'un caract�re par interface UART
-- Taux de symboles ("baud rate") ajustable
-- 8 bits, pas de parit�, 1 bit d'arr�t
--
-- voir https://fr.wikipedia.org/wiki/UART
-- voir aussi https://www.nandland.com/vhdl/modules/module-uart-serial-port-rs232.html
--
-- TODO : modifier le code pour param�trer le nombre de bits, la parit� et le nombre de bits d'arr�t
--
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx_char is
    generic (
        f_clk_ref : positive := 100e6;  -- fr�quence de l'horloge de r�f�rence, en Hz
        baud_rate : positive := 9600    -- taux de transmission de symboles par seconde, ici des bits; voir https://fr.wikipedia.org/wiki/Baud_(mesure)
    );
    port(
        reset : in std_logic;
        clk_ref : in std_logic;         -- horloge de r�f�rence
        le_caractere : in character;    -- caract�re � transmettre
        load : in std_logic;            -- il faut charger le caract�re et d�buter la transmission
        ready : out std_logic;          -- le syst�me est pr�t � transmettre un nouveau caract�re
        uart_tx : out std_logic         -- signal de transmission s�rielle RS-232
    );
end uart_tx_char;

architecture arch of uart_tx_char is

constant clk_ratio   : natural := f_clk_ref / baud_rate;

constant start_bit   : std_logic := '0'; -- TODO : � param�trer
constant stop_bit    : std_logic := '1'; -- TODO : � param�trer
constant n_data_bits : positive  := 8;   -- TODO : � param�trer, mais alors on devrait changer l'entr�e "le_caractere"

signal registre : std_logic_vector(n_data_bits downto 0); -- les bits de donn�es + le bit de d�part

type etat_type is (attente, transmission);
signal etat : etat_type := attente;

begin

    process(all)
    variable compteur_bits : natural range 0 to registre'length;
    variable compteur_clk  : natural range 0 to clk_ratio - 1;
    begin
        if reset = '1' then
            etat <= attente;
        elsif rising_edge(clk_ref) then
            case etat is
                when attente =>
                    if load = '1' then
                        compteur_bits := registre'length;
                        registre <= std_logic_vector(to_unsigned(character'pos(le_caractere), 8)) & start_bit;
                        etat <= transmission;
                        compteur_clk := clk_ratio - 1;
                    end if;
                when transmission =>
                    -- on ralentit la transmission au taux d�sir� de transmission de symboles par secondes avec le compteur_clk
                    if compteur_clk = 0 then
                        compteur_clk := clk_ratio - 1;
                        registre <= stop_bit & registre(8 downto 1);
                        if compteur_bits = 0 then
                            etat <= attente;
                        else
                            compteur_bits := compteur_bits - 1;
                        end if;
                    else
                        compteur_clk := compteur_clk - 1;
                    end if;
            end case;
        end if;
    end process;

    ready    <= '1'      when etat = attente else '0';
    uart_tx <= stop_bit when etat = attente else registre(0);

end arch;




---------------------------------------------------------------------------------------------------
--
-- banc d'essai
-- un stimulateur tr�s simple
--
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity uart_tx_char_TB is
end uart_tx_char_TB;

architecture arch_tb of uart_tx_char_TB is

constant message : string := "voici quelques caract�res ! FINI *";

signal reset : std_logic := '1';
signal clk : std_logic := '0';
signal load : std_logic := '0';
signal le_caractere : character;
signal ready, uart_tx_data : std_logic;

type etat_type is (attend_ready, attend_ack);
signal etat : etat_type := attend_ready;

constant periode : time := 10 ns;

begin

	clk <= not(clk) after periode / 2;
	reset <= '1' after 0 ns, '0' after periode * 9 / 4;

    UUT : entity uart_tx_char(arch)
		generic map (100e6, 1e6)
		port map (reset, clk, le_caractere, load, ready, uart_tx_data);
		
	-- stimulation seulement, pas de v�rification
	process (clk)
	variable compte : natural range 1 to message'length + 1 := 1;
	begin
        if reset = '1' then
            load <= '0';
            le_caractere <= NUL;
            compte := 1;
            etat <= attend_ready;
		elsif (falling_edge(clk)) then
            case etat is
                when attend_ready =>
			    if ready = '1' then
        			if compte = message'length + 1 then
                        report "simulation termin�e" severity failure;
                    end if;                
		    		le_caractere <= message(compte);
		    		load <= '1';
		    		compte := compte + 1;
                    etat <= attend_ack;
                end if;
                
                when attend_ack =>
                if ready = '0' then
		    		le_caractere <= nul;
		    		load <= '0';
                    etat <= attend_ready;
                end if;
            end case;
		end if;
	end process;
		
end arch_tb;
