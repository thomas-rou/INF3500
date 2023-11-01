---------------------------------------------------------------------------------------------------
-- 
-- racine_carree_tb.vhd
--
-- v. 1.0 Pierre Langlois 2022-02-25 laboratoire #4 INF3500, fichier de démarrage
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity racine_carree_tb is
    generic (
    N : positive := 16;
    M : positive := 8
    );
end racine_carree_tb;

architecture arch of racine_carree_tb is

    signal reset : STD_LOGIC;
    signal clk : STD_LOGIC := '0';
    constant periode : time := 10 ns;
    
    signal A : unsigned(N - 1 downto 0);        -- le nombre dont on cherche la racine carrée
    signal go : std_logic;                      -- commande pour débuter les calculs
    signal X : unsigned(M - 1 downto 0);        -- la racine carrée de A, telle que X * X = A
    signal fini : std_logic;                    -- '1' quand les calculs sont terminés ==> la valeur de X est stable et correcte
    
    -- votre code ici
    
begin

    UUT : entity racine_carree(newton)
        generic map (16, 8, 10)
        port map (reset, clk, A, go, X, fini);

    clk <= not clk after periode / 2;
    reset <= '1' after 0 ns, '0' after 5 * periode / 4;
	
	PROC_SEQUENCE : process
	begin
		wait for 5 * periode / 4;
		for i in 0 to 2**A'length - 1 loop
			A <= to_unsigned(i, A'length);
			go <= '1';
			wait for 10 ns;
			go <= '0';
			wait for 110 ns;
		end loop;
	assert false report "Test: OK" severity failure;	
		
	end process;

    --A <= to_unsigned(30000, A'length) after 0 ns, to_unsigned(6755, A'length) after 136 ns;                          -- une stimulation de base
    --go <= '0' after 0 ns, '1' after 27 ns, '0' after 37 ns, '1' after 136 ns, '0' after 146 ns;     -- une stimulation de base
    
    -- votre code ici

end arch;

