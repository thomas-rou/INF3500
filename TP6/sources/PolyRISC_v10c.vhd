-------------------------------------------------------------------------------
--
-- PolyRISC_v10c.vhd
--
-- v. 0.2 2014-11-11 avec Hamza Bendaoudi: r��criture des types des instructions en constantes pour accomoder la synth�se
-- v. 0.3 2015-03-12 rendre le code conforme au diagramme, corrections et simplifications
-- v. 0.4 2015-11-15 ajout de abs, min et max
-- v. 1.0 2020-11-13 d�composition du code, d�finitions dans un package
-- v. 1.0a 2021-04-01 ajustements mineurs pour le laboratoire #5
-- v. 1.0b 2021-11-28 inclut les instruction GPIO_out := RB
-- v. 1.0c 2021-11-28 inclut RB := GPIO_in, solution du labo #5
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PolyRISC_utilitaires_pkg.all;

-- d�finition de la m�moire des instructions
use work.PolyRISC_le_programme_pkg.all;

entity PolyRISC is
    port(
        reset, CLK : in std_logic;
        GPIO_in : in signed(Wd - 1 downto 0);
        GPIO_in_valide : in std_logic;
        GPIO_out : out signed(Wd - 1 downto 0);
        GPIO_out_valide : out std_logic
    );
end PolyRISC;

architecture arch of PolyRISC is

-------------------------------------------------------------------------------
-- signaux du bloc des registres
--
signal lesRegistres : lesRegistres_type;
signal donneeBR, A, B : signed(Wd - 1 downto 0);
signal choixA, choixB, choixCharge : natural range 0 to Nreg - 1;
signal chargeBR : std_logic;
signal choixDonnee_BR : natural range 0 to 2;

-------------------------------------------------------------------------------
-- signaux de l'UAL
--
signal op_UAL : natural range 0 to 10;
signal valeur : signed(Wd - 1 downto 0);
signal choixB_UAL : natural range 0 to 1;
signal F : signed(Wd - 1 downto 0);
signal Z, N : std_logic;

-------------------------------------------------------------------------------
-- signaux de l'unit� de branchement
--
signal brancher : std_logic;
signal condition : natural range 0 to 7;

-------------------------------------------------------------------------------
-- signaux de la m�moire des donn�es
--
signal charge_MD : std_logic;
signal memoireDonnees : memoireDonnees_type;

-------------------------------------------------------------------------------
-- signaux de la m�moire des instructions
--
signal CP : natural range 0 to (2 ** Mi - 1); -- le compteur de programme
signal instruction : instruction_type;

-------------------------------------------------------------------------------
-- corps de l'architecture
begin

    -------------------------------------------------------------------------------
    -- bloc des registres
    process(all)
    begin
        if rising_edge(CLK) then
            if reset = '1' then
                lesRegistres <= (others => (others => '0'));
            else
                if chargeBR = '1' then
                    lesRegistres(choixCharge) <= donneeBR;
                end if;
            end if;
        end if;
    end process;
    A <= lesRegistres(choixA);
    B <= lesRegistres(choixB);

    -------------------------------------------------------------------------------
    -- UAL
    process(all)
    variable B_UAL, F_UAL : signed(Wd - 1 downto 0);
    begin

        -- multiplexeur pour l'entr�e B
        if choixB_UAL = 0 then
            B_UAL := B;
        else
            B_UAL := valeur;
        end if;

        -- mod�lisation des op�rations de l'UAL
        case op_UAL is
            when passeA => F_UAL := A;
            when passeB => F_UAL := B_UAL;
            when AplusB => F_UAL := A + B_UAL;
            when AmoinsB => F_UAL := A - B_UAL;
            when AetB => F_UAL := A and B_UAL;
            when AouB => F_UAL := A or B_UAL;
            when nonA => F_UAL := not(A);
            when AouxB => F_UAL := A xor B_UAL;
            when absA => F_UAL := abs(A);
            when minAB => F_UAL := minimum(A, B_UAL);
            when maxAB => F_UAL := maximum(A, B_UAL);
            when others => F_UAL := (others => '0');
        end case;

        -- drapeaux pour l'unit� de branchement
        if F_UAL = 0 then
            Z <= '1';
        else
            Z <= '0';
        end if;
        N <= F_UAL(F_UAL'left);

        -- sortie de l'UAL
        F <= F_UAL;

    end process;

    -------------------------------------------------------------------------------
    -- unit� de branchement
    process(all)
    begin
        case condition is
            when egal => brancher <= Z;
            when diff => brancher <= not(Z);
            when ppq => brancher <= N;
            when pgq => brancher <= not(N) and not(Z);
            when ppe => brancher <= N or Z;
            when pge => brancher <= not(N) or Z;
            when toujours => brancher <= '1';
            when jamais => brancher <= '0';
        end case;
    end process;

    -------------------------------------------------------------------------------
    -- m�moire des donn�es
    process(all)
    begin
        if rising_edge(CLK) then
            if charge_MD = '1' then
                memoireDonnees(to_integer(unsigned(F(Md - 1 downto 0)))) <= B;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------------------
    -- multiplexeur pour choisir l'entr�e du bloc des registres
    process(all)
    begin
        case choixDonnee_BR is
            when 0 =>
            donneeBR <= F;
            when 1 =>
            donneeBR <= memoireDonnees(to_integer(unsigned(F(Md - 1 downto 0))));
            -- when 2 =>
            when others =>
            donneeBR <= GPIO_in;
        end case;
    end process;

    -------------------------------------------------------------------------------
    -- compteur de programme
    process(all)
    begin
        if rising_edge(CLK) then
            if reset = '1' then
                CP <= 0;
            else
                if brancher = '1' then
                    CP <= CP + instruction.valeur;
                elsif instruction.categorie = memoire and instruction.details = lireGPIO_in then
                    if GPIO_in_valide = '1' then
                        CP <= CP + 1;
                    -- else : ne pas incr�menter le PC, la processeur g�le jusqu'� ce que GPIO_in_valide soit � '1'
                    end if;
                else
                    CP <= CP + 1;
                end if;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------------------
    -- registre du port de sortie GPIO_out
    -- le signal de validit� est activ� uniquement pendant l'ex�cution de l'instruction
    process(all)
    begin
        if rising_edge(CLK) then
            if reset = '1' then
                GPIO_out <= (others => '0');
                GPIO_out_valide <= '0';
            else
                if instruction.categorie = memoire and instruction.details = ecrireGPIO_out then
                    GPIO_out <= B;
                    GPIO_out_valide <= '1';
                else
                    GPIO_out_valide <= '0';
                end if;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------------------
    -- m�moire des instructions
    -- La m�moire des instructions est une ROM, elle est constante.
    -- Elle est d�clar�e et d�finie dans un package s�par� de ce fichier.
    instruction <= memoireInstructions(CP);

    -------------------------------------------------------------------------------
    -- d�codage des instructions pour les signaux de contr�le du chemin des donn�es
    process(all)
    begin

        -------------------------------------------------------------------------------
        -- signaux de contr�le du bloc des registres

        -- chargeBR
        if instruction.categorie = reg or
            instruction.categorie = reg_valeur or
            (instruction.categorie = memoire and instruction.details = lirememoire) or
            (instruction.categorie = memoire and instruction.details = lireGPIO_in and GPIO_in_valide = '1') then
            chargeBR <= '1';
        else
            chargeBR <= '0';
        end if;

        -- choixCharge
        choixCharge <= instruction.reg1;

        -- choixA et choixB
        if (instruction.categorie = reg) then
            choixA <= instruction.reg2;
            choixB <= instruction.valeur mod Nreg; -- on garde seulement les log2(Nreg) bits les moins significatifs
        elsif (instruction.categorie = reg_valeur) then
            choixA <= instruction.reg2;
            choixB <= instruction.reg1;
        elsif (instruction.categorie = branchement) then
            choixA <= instruction.reg2;
            choixB <= instruction.reg1;
        elsif (instruction.categorie = memoire) then
            if (instruction.details = lirememoire) then
                choixA <= instruction.reg2;
                choixB <= instruction.reg1; -- valeur bidon, le port B n'est pas lu
            elsif (instruction.categorie = ecrirememoire) then
                choixA <= instruction.reg2;
                choixB <= instruction.reg1; -- valeur bidon, le port B n'est pas lu
            elsif instruction.categorie = ecrireGPIO_out then
                choixA <= instruction.reg2; -- valeur bidon, le port A n'est pas lu
                choixB <= instruction.reg1;
            else
                choixA <= instruction.reg2;
                choixB <= instruction.reg1;
            end if;
        else -- en principe on n'arrive jamais ici
            choixA <= 0; -- valeur bidon
            choixB <= 0; -- valeur bidon
        end if;

        -------------------------------------------------------------------------------
        -- signaux de contr�le de l'UAL

        -- valeur
        valeur <= to_signed(instruction.valeur, Wd);

        -- choixB_UAL
        if (instruction.categorie = reg or instruction.categorie = branchement) then
            choixB_UAL <= 0;
        else
            choixB_UAL <= 1;
        end if;

        -- op_UAL
        if (instruction.categorie = reg or instruction.categorie = reg_valeur) then
            op_UAL <= instruction.details;
        elsif (instruction.categorie = branchement) then
            -- pour faire la comparaison entre les op�randes
            op_UAL <= AmoinsB;
        else
            -- lire et �crire la m�moire, calcul de l'adresse effective
            op_UAL <= AplusB;
        end if;

        -------------------------------------------------------------------------------
        -- signal de contr�le de l'unit� de branchement
        if (instruction.categorie = branchement) then
            condition <= instruction.details;
        else
            condition <= jamais;
        end if;

        -------------------------------------------------------------------------------
        -- signal de contr�le de la m�moire des donn�es
        if (instruction.categorie = memoire and instruction.details = ecrireMemoire) then
            charge_MD <= '1';
        else
            charge_MD <= '0';
        end if;

        -------------------------------------------------------------------------------
        -- signal de contr�le du multiplexeur de l'entr�e du bloc des registres
        if instruction.categorie = reg or instruction.categorie = reg_valeur then
            choixDonnee_BR <= 0;
        elsif instruction.categorie = memoire and instruction.details = lireMemoire then
            choixDonnee_BR <= 1;
        elsif instruction.categorie = memoire and instruction.details = lireGPIO_in then
            choixDonnee_BR <= 2;
        else
            choixDonnee_BR <= 0;
        end if;

    end process;

end arch;
