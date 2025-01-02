-------------------------------------------------------------------------------
--
-- Division par r�ciproque
-- 2010/01/25 v. 1.0 : Tarek Ould Bachir, creation
-- 2010/05/13 v. 1.1 : Tarek Ould Bachir, modification de certains commentaires
-- 2011/01/13 v. 2.0 : Pierre Langlois, �limination de l'horloge, simplification g�n�rale, ajout de commentaires
-- 2022/02/22 v. 2.1 : Pierre Langlois, quelques mises � jour, r�duction de la taille de la ROM, etc.
-- 2022/02/25 v. 2.2 : Pierre Langlois, num�rateur et d�nominateur de tailles diff�rentes
--
-------------------------------------------------------------------------------
--
-- Fonctionnement du module
--
-- Les entr�es a et b sont des nombres entiers exprim�s respectivement sur W_num et W_denum bits.
--
-- La division quotient = num / denom est effectu�e par la multiplication quotient = num * (1 / denom), o� 
--   o� les valeurs approximatives des r�ciproques (1 / denom) sont pr�calcul�es et entrepos�es dans une m�moire ROM.
-- Les r�ciproques sont exprim�es avec W_frac bits.
-- La taille de la ROM est donc de 2 ** W_denom mots de W_frac bits chacun.
--
-- Les cas particuliers de denom = 0 (erreur de division par 0) et de denom = 1 (quotient = num) sont trait�s s�par�ment.
--
-- Le quotient est exprim� sur W_num bits pour la partie enti�re et W_frac bits pour la partie fractionnaire.
-- Par exemple, pour W_num = 3 et W_frac = 2, le quotient serait exprim� sur 5 bits interpr�t�s comme suit :
--  00001 -> 000.01 = 0.25
--  01010 -> 010.10 = 2.50
--  11111 -> 111.11 = 7.75  
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity division_par_reciproque is
    generic (
        W_num               : integer := 16;                                -- nombre de bits pour le num�rateur
        W_denom             : integer := 8;                                 -- nombre de bits pour le d�nominateur
        W_frac              : integer := 14                                 -- nombre de bits pour exprimer les r�ciproques
    );
    port (
        num                 : in  unsigned(W_num - 1 downto 0);             -- num�rateur
        denom               : in  unsigned(W_denom - 1 downto 0);           -- d�nominateur
        quotient            : out unsigned(W_num + W_frac - 1 downto 0);    -- approximation du quotient de num / denom
        erreur_div_par_0    : out std_logic                                 -- '1' si b = 0
    );
end division_par_reciproque;

architecture arch of division_par_reciproque is

type ROM_reciproque_type is array(0 to 2 ** W_denom - 1) of unsigned(W_frac - 1 downto 0);

-- calcul des valeurs de la r�ciproque 1 / denom
function init_mem return ROM_reciproque_type is
variable reciproque : ROM_reciproque_type;
begin
    reciproque(0) := to_unsigned(0, reciproque(0)'length); -- valeur bidon, on va g�n�rer une erreur de toute fa�on si on divise par 0
    reciproque(1) := to_unsigned(0, reciproque(0)'length); -- valeur bidon, on va retourner num si on divise par 1
    for i in 2 to 2 ** W_denom - 1 loop
        reciproque(i) := to_unsigned(integer(round(real(2 ** W_frac) / real(i))), reciproque(0)'length);
    end loop;
    return reciproque;
end init_mem;

-- la m�moire ROM est initialis�e lors de l'instanciation du module par appel de la fonction
constant ROM_reciproque : ROM_reciproque_type := init_mem;

begin

    -- cas de la division par 0
    erreur_div_par_0 <= '1' when denom = 0 else '0';

    process(all)
    begin
        if denom = 1 then
            -- Si denom == 1, alors on retourne num directement, exprim� sur W_num + W_frac bits en le d�calant W_frac positions vers la gauche.
            quotient <= resize(num * 2 ** W_frac, quotient'length);
        else
            -- Sinon, on retourne le produit
            quotient <= num * ROM_reciproque(to_integer(denom));
        end if;
    end process;
    
end arch;