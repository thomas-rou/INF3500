---------------------------------------------------------------------------------------------------
--
-- uart_rx_char.vhd
--
-- Pierre Langlois
-- v. 1.0 2022-03-16 pour le labo #5 de INF3500, hiver 2022, inspir� entre autres des travaux de Russel, https://www.nandland.com
--
-- R�ception d'un caract�re
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

entity uart_rx_char is
    generic (
        f_clk_ref : positive := 100e6;   -- fr�quence de l'horloge de r�f�rence, en Hz
        baud_rate : positive := 9600     -- taux de r�ception de symboles par seconde, ici des bits; voir https://fr.wikipedia.org/wiki/Baud_(mesure)
    );
    port(
        reset        : in  std_logic;
        clk_ref      : in  std_logic;    -- horloge de r�f�rence
        uart_rx      : in  std_logic;    -- signal de r�ception s�rielle RS-232
        le_caractere : out character;    -- le caract�re re�u
        valide       : out std_logic     -- on a re�u un nouveau caract�re (passe de 0 � 1)
    );
end uart_rx_char;

architecture arch of uart_rx_char is

constant clk_ratio   : natural := f_clk_ref / baud_rate;

constant start_bit   : std_logic := '0'; -- TODO : � param�trer avec un generic
constant stop_bit    : std_logic := '1'; -- TODO : � param�trer avec un generic
constant n_data_bits : positive  :=  8;  -- TODO : � param�trer avec un generic, mais alors on devrait changer la sortie "le_caractere"

signal uart_rx_meta, uart_rx_stable : std_logic;                     -- pour le double tampon du signal asynchrone en entr�e
signal registre      : std_logic_vector(n_data_bits - 1 downto 0);   -- les bits de donn�es

type etat_type is (attente, rx_start_bit, rx_data_bits, rx_stop_bit, fini);
signal etat : etat_type := attente;

begin

    -- double tampon sur le signal RS-232 pour �viter la m�tastabilit� et synchroniser le signal avec l'horloge de r�f�rence
    process(all)
    begin
        if rising_edge(clk_ref) then
            uart_rx_meta   <= uart_rx;          -- registre potentiellement m�tastable
            uart_rx_stable <= uart_rx_meta;     -- registre probablement stabilis�
        end if;
    end process;

    process(all)
    variable compteur_bits : natural range 0 to registre'length;
    variable compteur_clk  : natural range 0 to clk_ratio - 1;
    begin
        if reset = '1' then
            etat <= attente;
        elsif rising_edge(clk_ref) then
            case etat is
                when attente =>
                    -- attendre le bit de d�part
                    if uart_rx_stable = start_bit then
                        etat <= rx_start_bit;
                        compteur_clk := clk_ratio / 2; -- une demi-p�riode
                    end if;
                when rx_start_bit =>
                    -- attendre une demi-p�riode pour v�rifier si le bit de d�part est toujours l�
                    if compteur_clk = 0 then
                        if uart_rx_stable = start_bit then
                            etat <= rx_data_bits;
                            compteur_clk := clk_ratio - 1; -- pr�pare le compteur de coups d'horloges pour le prochain bit � recevoir
                            compteur_bits := registre'length - 1;
                        else
                            -- fausse alarme, on n'a pas re�u le bit de d�part
                            etat <= attente;
                        end if;
                    else
                        compteur_clk := compteur_clk - 1;
                    end if;
                when rx_data_bits =>
                    -- attendre une p�riode pour se placer au centre du bit
                    if compteur_clk = 0 then
                        compteur_clk := clk_ratio - 1; -- pr�pare le compteur de coups d'horloges pour le prochain bit � recevoir
                        -- emmagasiner un bits de plus dans le registre � d�calage
                        registre <= uart_rx_stable & registre(registre'left downto 1);
                        if compteur_bits = 0 then
                            -- on a re�u tous les bits
                            etat <= rx_stop_bit;
                        else
                            compteur_bits := compteur_bits - 1;
                        end if;
                    else
                        compteur_clk := compteur_clk - 1;
                    end if;
                when rx_stop_bit =>
                    -- attendre une p�riode, que le bit d'arr�t soit pass�
                    -- on n'a pas besoin de le lire ** TODO : confirmer que c'est bien le bit d'arr�t ('1') sinon activer un signal d'erreur
                    if compteur_clk = 0 then
                        etat <= fini;
                    else
                        compteur_clk := compteur_clk - 1;
                    end if;
                when fini =>
                    -- cet �tat ne dure qu'un seul cycle de l'horloge de r�f�rence (en principe, c'est court)
                    -- son seul but est que l'impulsion sur 'valide' se fasse apr�s la dur�e du bit d'arr�t
                    -- il faut �tre certain qu'on a bien re�u le bit d'arr�t (un '1') et non un '0',
                    -- sinon on repartirait tout de suite parce que le '0' serait interpr�t� comme un bit de d�part
                    etat <= attente;
            end case;
        end if;
    end process;

    valide <= '1' when etat = fini else '0';
    le_caractere <= character'val(to_integer(unsigned(registre)));

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

entity uart_rx_char_TB is
end uart_rx_char_TB;

architecture arch_tb of uart_rx_char_TB is

signal reset        : std_logic := '1';
signal clk          : std_logic := '0';
signal valide       : std_logic;
signal le_caractere : character;
signal uart_rx_data : std_logic;

constant periode    : time := 10 ns;

begin

	clk <= not(clk) after periode / 2;
	reset <= '1' after 0 ns, '0' after periode * 9 / 4;

    UUT : entity uart_rx_char(arch)
		generic map (100e6, 10e6)
		port map (reset, clk, uart_rx_data, le_caractere, valide);

    uart_rx_data <=
    '1' after 0 ns, -- stop bit
    '0' after 100 ns, -- start bit
    '1' after 200 ns, -- bit 0
    '0' after 300 ns, -- bit 1
    '0' after 400 ns, -- bit 2
    '1' after 500 ns, -- bit 3
    '1' after 600 ns, -- bit 4
    '1' after 700 ns, -- bit 5
    '0' after 800 ns, -- bit 6
    '0' after 900 ns, -- bit 7
    '1' after 1000 ns; -- stop bit

end arch_tb;
