-------------------------------------------------------------------------------
--
-- demo_combinatoire.vhd
--
-- Processeur qui effectue des calculs sur un nombre donnée en entrée.
-- Toutes les fonctions sont purement combinatoires.
--
-- v. 1.1 2022-01-04 Pierre Langlois
-- ** CETTE VERSION COMPORTE DES ERREURS DE SYNTAXE ET DES ERREURS FONCTIONNELLES **
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity demo_combinatoire is       
generic (
    W : integer := 4 -- nombre de bits pour représenter le nombre
);

port (
    A : in unsigned(W - 1 downto 0);
    pair: out std_logic;        -- indique si le nombre est pair
    divpar4 : out std_logic;    -- indique si le nombre est divisible par 4
    divpar5 : out std_logic;    -- indique si le nombre est divisible par 5
    divpar8 : out std_logic     -- indique si le nombre est divisible par 8
); --";" retiré d'arpès la définition de divpar8 car il s'agit du dernier identificateur
end demo_combinatoire;


architecture arch1 of demo_combinatoire is
begin                          
    
    pair <= not(A(0)); --Ajout d'une parenthèse manquante, parité doit être évalué avec le bit le moins significatif (A(1) -> A(0))
    
    divpar4 <= (not(A(3)) and not(A(2)) and not (A(1)) and not(A(0))) -- m0
    or (not(A(3)) and (A(2)) and not(A(1)) and not(A(0))) -- m4
    or ((A(3)) and not(A(2)) and not(A(1)) and not(A(0))) -- m8 (Ajout d'une parenthèse manquante)
    or ((A(3)) and (A(2)) and not(A(1)) and not(A(0))) ; -- m12	(12 = 1100 et non 0011 qui = 3)
    
    with to_integer(A) select
    divpar5 <=
        '1' when 0,
        '1' when 5,	-- 6 n'est pas divisible par 5, 5 l'est
        '1' when 10,
        '1' when 15, --Ajout d'une virgule manquante
        '0' when others;
        
    divpar8 <= '1' when A = "1000" or A = 0000 else '0'; -- 1 n'est pas divisible par 8, 0 l'est
    
end arch1; --Correction du label de fin de l'architecture pour arch1(était arch avant)
