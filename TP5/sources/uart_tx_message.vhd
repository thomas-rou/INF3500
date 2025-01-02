---------------------------------------------------------------------------------------------------
--
-- uart_tx_message.vhd
--
-- Pierre Langlois
-- v. 1.0 2022-03-16 pour le labo #2 de INF3500, hiver 2022
--
-- Transmission d'un message par interface UART/RS-232 (port s�rie COM sur un ordinateur)
--
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utilitaires_inf3500_pkg.all;
use work.all;

entity uart_tx_message is
    generic (
        f_clk      : positive := 100e6;     -- fr�quence de l'horloge de r�f�rence, en Hz
        taux_tx    : positive := 9600;      -- taux de transmission en baud (symboles par seconde), ici des bits par seconde; voir https://fr.wikipedia.org/wiki/Baud_(mesure)
        ncar       : positive := 100        -- le nombre de caract�res dans le message
    );
    port (
        reset      : in std_logic;
        clk        : in std_logic;          -- horloge de r�f�rence
        message    : in string(1 to ncar);  -- le message � transmettre
        go         : in std_logic;          -- il faut d�buter la transmission
        pret       : out std_logic;         -- 1 quand le syst�me est pr�t � transmettre un nouveau message, 0 pendant la transmission
        uart_tx    : out std_logic          -- signal de transmission s�rie RS-232
    );
end uart_tx_message;

architecture arch of uart_tx_message is

    type etat_type is (attend_go, attend_tx_caractere_pret, tx_caractere);
    signal etat : etat_type := attend_go;

    signal le_message         : string(1 to message'length);  -- un registre pour entreposer le message � transmettre    ** TODO : s'en d�barrasser ?
    signal go_caractere       : std_logic;                    -- signal de contr�le pour indiquer qu'il faut transmettre un caract�re
    signal le_caractere       : character;                    -- le caract�re � transmettre
    signal NC                 : std_logic;                    -- fil non connect�, flottant
    signal tx_caractere_pret  : std_logic;                    -- le transmetteur de caract�res est pr�t
    signal indice : natural range 1 to message'length;        -- l'indice du caract�re � transmettre dans le message

begin

    -- module responsable de transmettre un seul caract�re
    uarttx : entity uart_tx_char
    generic map (f_clk, taux_tx)
    port map (
        reset        => reset,
        clk_ref      => clk,
        le_caractere => le_caractere,
        load         => go_caractere,
        ready        => tx_caractere_pret,
        uart_tx      => uart_tx
    );

    -- s�quence des �tats
    process (all)
	begin
		if reset = '1' then
            etat <= attend_go;
        elsif rising_edge(clk) then
            case etat is
            when attend_go =>
                if go = '1' then
                    etat       <= attend_tx_caractere_pret;
                    le_message <= message;
                    indice     <= 1;
                end if;
            when attend_tx_caractere_pret =>
                if tx_caractere_pret = '1' then
                    etat <= tx_caractere;
                end if;
            when tx_caractere =>
                if le_message(indice) = ETX or indice = ncar then
                    -- on a transmis tous les caract�res du message
                    etat <= attend_go;
                else
                    etat   <= attend_tx_caractere_pret;
                    indice <= indice + 1;
                end if;
            end case;
		end if;
	end process;

    -- signaux de sortie de la machine � �tats
    process(all)
    begin
        case etat is
            when attend_go =>
        		go_caractere <= '0';
        		le_caractere <= NUL;
                pret         <= '1';
            when attend_tx_caractere_pret =>
	    		go_caractere <= '0';
	    		le_caractere <= NUL;
                pret         <= '0';
            when tx_caractere =>
	    		go_caractere <= '1';
	    		le_caractere <= le_message(indice);
                pret         <= '0';
        end case;
    end process;

end arch;




---------------------------------------------------------------------------------------------------
--
-- banc d'essai
-- un stimulateur tr�s simple
--
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utilitaires_inf3500_pkg.all;
--use work.messages_pkg.all;
use work.all;

entity uart_tx_message_TB is
--    generic (
--        f_clk      : positive := 100e6;       -- fr�quence de l'horloge de r�f�rence, en Hz
--        taux_tx    : positive := 9600000      -- taux de transmission en baud (symboles par seconde), ici des bits par seconde; voir https://fr.wikipedia.org/wiki/Baud_(mesure)
--    );
end uart_tx_message_TB;

architecture arch_tb of uart_tx_message_TB is

constant ncar : positive := 100;
signal reset : std_logic;
signal clk : std_logic := '0';
signal message : string(1 to ncar) := resize("abcdefghijklmnopqrst", ncar, ETX);
signal go : std_logic;
signal pret : std_logic;
signal uart_tx : std_logic;

constant periode : time := 10 ns;

begin

    UUT : entity uart_tx_message(arch)
--		generic map (f_clk, taux_tx)
		port map (reset, clk, message, go, pret, uart_tx);

    clk <= not(clk) after periode / 2;
	reset <= '1' after 0 ns, '0' after periode * 17 / 4;
    go <= '1' after periode * 10, '0' after periode * 11;

end arch_tb;

