---------------------------------------------------------------------------------------------------
--
-- racine_carree_tb.vhd
--
-- v. 1.0 Pierre Langlois 2022-02-25 laboratoire #4 INF3500, fichier de d�marrage
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use ieee.math_real.all;

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

    signal A : unsigned(N - 1 downto 0);        -- le nombre dont on cherche la racine carr�e
    signal go : std_logic;                      -- commande pour d�buter les calculs
    signal X : unsigned(M - 1 downto 0);        -- la racine carr�e de A, telle que X * X = A
    signal fini : std_logic;                    -- '1' quand les calculs sont termin�s ==> la valeur de X est stable et correcte

    -- Ajout du signal pour la vrai racine carr�e
	signal vrai_racine_carree : real := 0.0;
	-- Ajout de signaux pour l'erreur maximale et moyenne
    signal erreur : real := 0.0;
	signal erreur_max : real := 0.0;
	signal erreur_tot : real := 0.0;
    signal erreur_moy : real := 0.0;
    signal compteur : real := 0.0;

begin

    UUT : entity racine_carree(newton)
        generic map (16, 8, 10)
        port map (reset, clk, A, go, X, fini);

    clk <= not clk after periode / 2;
    reset <= '1' after 0 ns, '0' after 5 * periode / 4;

	PROC_SEQUENCE : process
	begin
		wait for 5 * periode / 4;

		-- G�n�ration de toutes les possibilit�s de A
		for i in 0 to 2**A'length - 1 loop
			A <= to_unsigned(i, A'length);
			go <= '1';
			wait for 10 ns;
			go <= '0';
			wait for 110 ns;

			-- Calcul de la vrai racine carr�e (On utise math_real.sqrt qui est non synth�tisable, alors seulement pour TB)
			vrai_racine_carree <= (sqrt(real(to_integer(A))));
			wait for 5 ns;

			-- Calcul de l'erreur
			erreur <= abs(real(to_integer(X)) - vrai_racine_carree);

			-- M�j de l'erreur max
			if erreur > erreur_max then
				erreur_max <= erreur;
			end if;

			-- M�j de l'erreur total
			erreur_tot <= erreur_tot + erreur;
			wait for 5 ns;

			-- incr�mentation du compteur de nombre test�s pour le calcul de l'erreur moyenne
			compteur <= compteur + 1.0;

			if fini = '1' then
				assert (erreur <= 1.0) report
				"La racine carr�e de : " & integer'image(to_integer(A)) &
				" r�sulte en : " & integer'image(to_integer(X)) &
				" l'erreur plus grande que 1 est de : " & real'image(real(erreur)) &
				" la vrai racine car�e est : " & real'image(real(vrai_racine_carree))
				severity warning;
			end if;

		end loop;
	-- calcul de l'erreur moy
	erreur_moy <= erreur_tot / compteur;
	wait for 5 ns;
	-- Affichage des r�sultats
	report "Erreur maximale : " & real'image(real(erreur_max));
    report "Erreur moyenne : " & real'image(real(erreur_moy));

	assert false report "Test: OK" severity failure;

	end process;

end arch;

