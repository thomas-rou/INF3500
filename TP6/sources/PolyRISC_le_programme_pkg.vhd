---------------------------------------------------------------------------------------------------
--
-- PolyRISC_le_programme_pkg.vhd
--
-- contenu de la mémoire des instructions
--
---------------------------------------------------------------------------------------------------
use work.PolyRISC_utilitaires_pkg.all;

package PolyRISC_le_programme_pkg is

    -----------------------------------------------------------------------------------------------
    -- partie 0 : programme de démonstration, suite de Fibonacci
--    constant memoireInstructions : memoireInstructions_type := (
--    (memoire, lireGPIO_in, 0, 0, 0),               -- 0 : R0 := lire GPIO_in
--    (reg_valeur, passeB, 1, 0, 2),                 -- 1 : R1 := #2
--    (reg_valeur, passeB, 3, 0, 0),                 -- 2 : R3 := #0
--    (memoire, ecrireGPIO_out, 3, 0, 0),            -- 3 : GPIO_out := R3
--    (reg_valeur, passeB, 4, 0, 1),                 -- 4 : R4 := #1
--    (memoire, ecrireGPIO_out, 4, 0, 0),            -- 5 : GPIO_out := R4
--    (reg, AplusB, 5, 3, 4),                        -- 6 : R5 := R3 + R4
--    (reg, passeA, 3, 4, 0),                        -- 7 : R3 := R4
--    (reg, passeA, 4, 5, 0),                        -- 8 : R4 := R5
--    (memoire, ecrireGPIO_out, 4, 0, 0),            -- 9 : GPIO_out := R4
--    (reg_valeur, AplusB, 1, 1, 1),                 -- 10 : R1 := R1 + #1
--    (branchement, ppe, 0, 1, -5),                  -- 11 : si R1 <= R0 goto CP + -5
--    STOP,
--    NOP);

    -----------------------------------------------------------------------------------------------
    -- parties 1 et 2 : votre code à développer
    -- placez le code de la partie 0 en commentaires
    -- utilisez le code de la partie 0 pour vous inspirer

    constant memoireInstructions : memoireInstructions_type := (
    (memoire, lireGPIO_in, 0, 0, 0),               -- 0 : R0 := lire GPIO_in		nombre

    -- votre code ici
	(reg_valeur, passeB, 1, 0, 32767),              -- 1 : R1 := #32767				haut
	(reg_valeur, passeB, 3, 0, 0),                 	-- 2 : R3 := #0					bas
	(reg_valeur, passeB, 4, 0, 16),                 -- 3 : R4 := #16				compteur
	(reg_valeur, passeB, 5, 0, 0),					-- 4 : R5 := #0					pour comparaison compteur
	(branchement, ppe, 5, 4, 10),					-- 5 : si R4 <= R5 goto CP + 10	tant que compteur > 0
	(reg, AplusB, 2, 1, 3),							-- 6 : R2 := R1 + R3			haut + bas
	(reg, Adiv2, 6, 2, 0),							-- 7 : R6 := R2 / 2				pivot <- (haut + bas) / 2
	(reg, AmulB, 7, 6, 6),							-- 8 : R7 := R6 * R6			carree <- pivot * pivot
	(branchement, ppe, 0, 7, 3),					-- 9 : si R7 <= R0 goto CP + 3	si carree > nombre
	(reg, passeA, 1, 6, 0),							-- 10 : R1 := R6				haut <- pivot
	(branchement, toujours, 0, 0, 2),				-- 11 : goto CP + 2				fin de la condition
	(reg, passeA, 3, 6, 0),							-- 12 : R3 := R6 				bas <- pivot
	(reg_valeur, AmoinsB, 4, 4, 1),					-- 13 : R4 := R4 - 1			compteur <- compteur - 1
	(branchement, toujours, 0, 0, -9),				-- 14 : goto CP - 9				retour au début de la boucle
	(memoire, ecrireGPIO_out, 6, 0, 0),				-- 15 : GPIO_out := R6			sortie <- pivot		
    STOP,
    NOP);

end package;
