-------------------------------------------------------------------------------
--
-- demo_combinatoire_bonus_3c.vhd
--
-- Processeur qui effectue des calculs sur un nombre donnée en entrée.
-- Toutes les fonctions sont purement combinatoires.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity demo_combinatoire_bonus_3c is       
generic (
    W : integer := 6 -- nombre de bits pour représenter le nombre
);

port (
    A : in unsigned(W - 1 downto 0);
    pair: out std_logic;        -- indique si le nombre est pair
    divpar4 : out std_logic;    -- indique si le nombre est divisible par 4
    divpar5 : out std_logic;    -- indique si le nombre est divisible par 5
    divpar8 : out std_logic     -- indique si le nombre est divisible par 8
);
end demo_combinatoire_bonus_3c;


architecture arch1 of demo_combinatoire_bonus_3c is
begin                          
    -- div par 2
    pair <= not(A(0));
   	--div par 4
	process (A)
	begin
	if(A mod 4 = 0) then   
		divpar4 <= '1';
	else
		divpar4 <= '0';
	end if;
	end process;
    -- div par 5
    process (A)
	begin
	if(A mod 5 = 0) then   
		divpar5 <= '1';
	else
		divpar5 <= '0';
	end if;
	end process;
    -- div par 8
	process (A)
	begin
	if(A mod 8 = 0) then   
		divpar8 <= '1';
	else
		divpar8 <= '0';
	end if;
	end process;
        
end arch1;