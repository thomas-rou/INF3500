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
    W : integer := 5 -- nombre de bits pour représenter le nombre
);

port (
    A : in unsigned(W - 1 downto 0);
    pair: out std_logic;        -- indique si le nombre est pair
    divpar4 : out std_logic;    -- indique si le nombre est divisible par 4
    divpar5 : out std_logic;    -- indique si le nombre est divisible par 5
    divpar8 : out std_logic     -- indique si le nombre est divisible par 8
);
end demo_combinatoire;


architecture arch1 of demo_combinatoire is
begin                          
    
    pair <= not(A(0));
    
    divpar4 <= (not(A(4)) and not(A(3)) and not(A(2)) and not (A(1)) and not(A(0))) -- m0
    or (not(A(4)) and not(A(3)) and (A(2)) and not(A(1)) and not(A(0))) -- m4
    or (not(A(4)) and (A(3)) and not(A(2)) and not(A(1)) and not(A(0))) -- m8
    or (not(A(4)) and (A(3)) and (A(2)) and not(A(1)) and not(A(0))) --m12
    or ((A(4)) and not(A(3)) and not(A(2)) and not (A(1)) and not(A(0))) --m16
    or ((A(4)) and not(A(3)) and (A(2)) and not (A(1)) and not(A(0)))  --m20
    or ((A(4)) and (A(3)) and not(A(2)) and not (A(1)) and not(A(0)))  --m24
    or ((A(4)) and (A(3)) and (A(2)) and not (A(1)) and not(A(0)));	  --m28
    
    with to_integer(A) select
    divpar5 <=
        '1' when 0,
        '1' when 5,
        '1' when 10,
        '1' when 15,
        '1' when 20,
        '1' when 25,
        '1' when 30,
        '0' when others;
        
    divpar8 <= '1' when A = "01000" or A = 00000 or A = "10000" or A = "11000" else '0';
    
end arch1;
