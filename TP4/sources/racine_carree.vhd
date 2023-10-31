---------------------------------------------------------------------------------------------------
-- 
-- racine_carree.vhd
--
-- v. 1.0 Pierre Langlois 2022-02-25 laboratoire #4 INF3500 - code de base
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity racine_carree is
    generic (
        N : positive := 16;                     -- nombre de bits de A
        M : positive := 8;                      -- nombre de bits de X
        kmax : positive := 10                   -- nombre d'itérations à faire
    );
    port (
        reset, clk : in std_logic;
        A : in unsigned(N - 1 downto 0);        -- le nombre dont on cherche la racine carrée
        go : in std_logic;                      -- commande pour débuter les calculs
        X : out unsigned(M - 1 downto 0);       -- la racine carrée de A, telle que X * X = A
        fini : out std_logic                    -- '1' quand les calculs sont terminés ==> la valeur de X est stable et correcte
    );
end racine_carree;

architecture newton of racine_carree is
    
    constant W_frac : integer := 14;               -- pour le module de division, nombre de bits pour exprimer les réciproques
    
    type etat_type is (attente, calculs);
    signal etat : etat_type := attente;
    
--- votre code ici
	component division_par_reciproque
		generic (W_num, W_denom, W_frac : integer);
		port (
		num                 : in  unsigned(W_num - 1 downto 0);             -- numérateur
        	denom               : in  unsigned(W_denom - 1 downto 0);           -- dénominateur
        	quotient            : out unsigned(W_num + W_frac - 1 downto 0);    -- approximation du quotient de num / denom
        	erreur_div_par_0    : out std_logic                                 -- '1' si b = 0
		);
	end component division_par_reciproque;
	
	signal quotient : unsigned(N + W_frac - 1 downto 0);
	signal quotient_8bits, xk, div_2_result : unsigned(M - 1 downto 0);
	signal sum_result : unsigned(M downto 0); 
	signal A_int : unsigned(N - 1 downto 0);
	signal erreur_div_0 : std_logic;
	
begin
	diviseur1 : division_par_reciproque
			generic map (N, M, W_frac)
			port map (
			num => A, denom => xk, quotient => quotient, erreur_div_par_0 => erreur_div_0
			);
	process(all) is
		variable k : natural := 0;	
	begin			
		if reset = '1' then
    			etat <= attente;
		else
			case etat is
				when attente =>
				if go = '1' and rising_edge(clk) then
					k := 0;
					A_int <= A;
					xk <= to_unsigned(255, M);
					etat <= calculs;
				end if;
				when calculs =>
				-- xk <-- (xk + A / xk)/ 2
				quotient_8bits <= resize(quotient(23 downto 16), M);
				sum_result <= ('0' & xk) + ('0' & quotient_8bits);
				div_2_result <= resize(sum_result srl 1, M);
				if rising_edge(clk) then
					xk <= div_2_result;
					k := k + 1;
				end if;
				if k = kmax then
					etat <= attente;
				end if;
				when others =>
				etat <= attente;
			end case;
		end if;
	end process;
	
	process(all)
	begin
		X <= xk;		
		case etat is 
			when attente =>
				fini <= '1';
			when calculs =>
				fini <= '0';
			when others =>
				fini <= '0';
		end case;
	end process;    
end newton;
