
------------------------------------------------------------------------

# INF3500 - labo 5 - automne 2023
# Équipe **nom-d-équipe-ici**

Membre #1 : **Michaud, Maël, 2209239**

Membre #2 : **Rouleau, Thomas, 2221053**

------------------------------------------------------------------------

## Partie 1

### Diagramme de blocs du système

Voici notre diagramme :

<img src="figures/diagramme.png" alt="notre diagramme" width="600">

### Description des modules

Voici, en un paragraphe pour chacun, le rôle et le fonctionnement de chacun des modules :
- generateur_horloge_precis;
Le générateur d’horloge précis vérifie d’abord si le rapport des fréquences entre la fréquence d’entré et de sortie est trop élevé en le comparant à la valeur la plus grande qu’un natural peut prendre en vhdl. Ensuite, on vérifie que la fréquence de sortie soit inférieure ou égale à la moitié de la fréquence d’entrée. Si ces deux conditions sont remplies, on rentre dans la logique du code : à chaque front montant du signal d’horloge entrant, on incrémente un compteur d’un jusqu’à ce qu’il atteigne la valeur maximum représentant le rapport des fréquences. Lorsque le compteur à la même valeur que le rapport des fréquences, le signal d’horloge de sortie est inversé. Ainsi, on recrée un signal d’horloge à partir du signal d’horloge en entré qui a une période équivalente à deux fois le rapport des fréquences.
- monopulseur;
Le module monopulseur permet de gérer l’appui d’un bouton en filtrant les faux appuis via un compteur décrémentant jusqu’à 0 à partir de la durée d’un rebond qu’on définit. De cette manière, on évite qu’un seul appui soit considéré comme plusieurs. Deux impulsions sont définies comme sorties : la première vaux ‘1’ lorsque le bouton est appuyé, l’autre vaux ‘1’ lorsque le bouton est relâché.
- uart_rx_char;
Ce module permet de recevoir un caractère par UART. Il attend un bit de départ, s’assure que ce bit soit volontaire, reçoit les 8 bits correspondants au caractère en s’assurant de mettre du temps entre chaque bit afin de ne pas créer d’erreur, puis attend le bit de fin en s’assurant de lui laisser le temps d’arriver. Le caractère est ensuite une sortie du module.
- uart_tx_char;
Ce module permet de transmettre un caractère par UART. Il attend un bit de départ puis transforme le caractère fournit en entrée en std_logic_vector. Les bits du std_logic_vector sont ensuite envoyés un par un par UART jusqu’à recevoir le bit d’arrêt.
- uart_tx_message;
Ce module permet de transmettre un message par interface UART/RS-232. Il utilise le module uart_tx_char pour transmettre caractère par caractère le message en s’assurant de laisser du temps aux différents caractères d’être envoyés. La séquence d’action commence lorsque le signal d’entrée go est mis à ‘1’.
- interface_utilisateur;
Ce module implémente le module uart_tx_message et le module uart_rx_char. Il utilise le module de transmission de message afin fournir à la carte FPGA le message envoyé par l’utilisateur et le module de réception de caractère pour montrer à l’utilisateur ce que la FPGA attends de lui via des constants strings implémentés dans la carte. Le résultat des entrées de l’utilisateur se retrouve sur l’écran de quatre sept segments de la carte FPGA .

### Analyse de quelques lignes de code

Voici notre analyse des lignes de code VHDL suivantes.

```
signal c1, c2 : character;
signal r1, r2 : std_logic_vector(7 downto 0);
...
r1 <= std_logic_vector(to_unsigned(character'pos(c1), 8));
c2 <= character'val(to_integer(unsigned(r2)));
```

La définition de la fonction `character_to_hex()` se trouve  ....


## Partie 2

Voici les modifications que nous avons apportées aux fichiers.

- top_labo_5.vhd
    - Retrait des signaux B, B0 et B_affichage. La raison étant que l'entité racine_carree ne prend qu'un seul input de 16 bits et non 2 inputs de 8 bits comme l'entité pgcf3.
    - Changement de la taille des signaux A, A0 et A_affichage de 8 bits à 16 bits. La raison étant que l'entité racine_carree prend un input de 16 bits et que l'on peut placer les 2 sorties de l'entité interface_utilisateur sur le même signal A0 de 16 bits poyr l'entité racine_carree.
    - Les 2 sorties A0 et B0 ont été remplacées par A0(15 downto 8) et A0(7 downto 0) afin de pouvoir les placer sur les 2 ouputs sur le même signal de 16 bits de l'entité racine_carree.
    - L'utilisation de l'entité racine_carree a été ajoutée avec son assignations de signaux.
    - L'utilisation de B_afichage a été retirée et remplacée par l'utilisation du signal de 16 bits A_affichage.

- interface_utilisateur.vhd
    - Modification du message de la constante m1 et retrait de la constante m2. La raison étant que l'entité racine_carree ne prend qu'un seul input de 16 bits et non 2 inputs de 8 bits comme l'entité pgcf3.
    - Retrait de l'état s_n2_m associé à l'affichage de l'attente du deuxième input comme un seul input de 16 bits est désiré par l'entité racine_carree.
    - Liaison de l'état s_n1_L à l'état s_n2_H

- racine_carree.vhd et division_par_reciproque.vhd on été ajoutés afin de pouvoir utiliser l'entité racine_carree dans le fichier top_labo_5.vhd. Ceux-ci ont également été ajoutés dans la liste des fichiers sources VHDL. pgfc3.vhd a été commenté dans la liste des fichiers sources VHDL car il n'est plus utilisé.


## Partie 3 : Bonus

*Faire un choix et garder seulement une option.*
- Nous sommes vraiment en avance dans nos études, dans ce cours et tous les autres, et nous adorons les défis dans ce cours, donc nous avons complété une ou plusieurs parties du bonus.

### Partie 3a

Notre approche consiste à placer l'assignation des caractères d'entrées de chaque état dans une condition ((caractere >= '0' and caractere <= '9') or (caractere >= 'A' and caractere <= 'F')). l'assignation de la sortie au caractère peut donc seulement se faire si la condition est rempli. Si un caractère reçu ne rempli pas la condition, alors l'état change pour l'état s_erreur qui a été ajouté. Celui-ci affiche le message d'erreur et retrourne à l'état s_bienvenue pour attendre une nouvelle entrée.

### Partie 3b

Notre approche consiste à ajoute 2 entrées au module d'interface afin de lui transmettre le résultats de l'opération ainsi que l'indication que l'opération est terminée. Lorsque l'opération est terminée, l'interface affiche le résultat. Le message est passé comme string et sous forme hexadecimal à l'aide de to_hstring(). Nous avons également séparé le message de calcul du message d'affichage des résultats dans 2 états différents afin d'améliorer l'affichage.
