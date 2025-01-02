
------------------------------------------------------------------------

# INF3500 - labo 1
# Équipe **nom-d-equipe-ici**

------------------------------------------------------------------------

## Parties 1c et 1d : correction des erreurs de syntaxe et de fonctionnalité

*Indiquez vos correction directement dans votre fichier .vhd*

## Partie 2 : Ajout de fonctionnalités

*Remettez votre fichier demo_combinatoire_ameliore.vhd et le fichier de programmation .bit.*

Le fichier de programmation se trouve dans le dossier synthese-implementation/top_labo_1.bit et le fichier source est dans source/demo_combinatoire_ameliore

**Faire un choix et garder seulement une option.**

Nous utilisons la carte Basys 3.

## Partie 3: Bonus

Nous sommes vraiment en avance dans nos études, dans ce cours et tous les autres, et nous adorons les défis dans ce cours, donc nous avons complété le bonus.

Voici nos réponses :

Question : Proposez **deux** manières de décrire le module en VHDL afin qu'il accommode un grand nombre d'entrées. Expliquez complètement vos deux suggestions à l'aide d'exemples.

- Proposition 1 : On pourrait continuer de la même manière avec une description par flots de données en faisant une table de vérité indiquant la sortie voulus pour toutes les entrées possibles. ex :

```vhdl
    divpar5 <=
        '1' when 0,
        '1' when 5,
        '1' when 10,
        '1' when 15,
        '1' when 20,
        '1' when 25,
        '1' when 30,
        '1' when 35,
        '0' when others;
```

- Proposition 2 : Faire une description comportementale du processus désirées à l'aide de processus, de boucle et de d'outils mathématique tel que modulo. ex :

```vhdl
    process (A)
    begin
    if(A mod 4 = 0) then
        divpar4 <= '1';
    else
        divpar4 <= '0';
    end if;
    end process;
```

Nos fichiers sont :

- demo_combinatoire_bonus_3b.vhd et top_labo_1_bonus_partie_3b
- demo_combinatoire_bonus_3c.vhd

Nous avons observé que ...

## Observations et discussion générale

Dans ce laboratoire, nous avons remarqué que : ...

Nous avons appris que ....

Nous avons trouvé plus difficile de ...

Selon nous ...

Nous recommandons que ...