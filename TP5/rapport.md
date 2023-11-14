
------------------------------------------------------------------------

# INF3500 - labo 5 - automne 2023
# Équipe **nom-d-équipe-ici**

Membre #1 : **nom, prénom, matricule**

Membre #2 : **nom, prénom, matricule**

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

- fichier1.vhd
    - ceci
    - cela

- fichier2.vhd
    - ceci
    - cela

- fichier3.vhd
    - ceci
    - cela


## Partie 3 : Bonus

*Faire un choix et garder seulement une option.*
- Nous n'avons pas complété le bonus. Nous nous concentrons sur notre réussite dans ce cours et dans d'autres.
- Nous sommes vraiment en avance dans nos études, dans ce cours et tous les autres, et nous adorons les défis dans ce cours, donc nous avons complété une ou plusieurs parties du bonus.

### Partie 3a

Notre approche consiste à ...

### Partie 3b

Notre approche consiste à ...
