-----------------------------------------------------------------------
<table>
<tr>
<td><img src="figures\Polytechnique_signature-RGB-gauche_FR.png" alt="Logo de Polytechnique Montréal"></td>
<td><h2>INF3500 - Conception et réalisation de systèmes numériques
<br><br>Automne 2023
<br><br>Laboratoire #3
<br><br>Circuits séquentiels et chemins des données
</h2></td>
</tr>
</table>

----------------------------------------------------------------------------------------------

# Le cadenas à boutons

----------------------------------------------------------------------------------------------


À la fin de ce laboratoire, vous devrez être capable de :

- Concevoir un circuit séquentiel à partir d’une spécification. Donner un diagramme d’état, le code VHDL, le schéma du circuit et son implémentation résultante sur un FPGA. (B5)
    - Utiliser une horloge et un signal de réinitialisation.
    - Utiliser des registres et des compteurs.
    - Utiliser une machine à états.
- Composer un banc d’essai pour stimuler un modèle VHDL d’un circuit séquentiel. Donner le chronogramme résultant de l’exécution d’un banc d’essai. (B4,B5)
    - Générer un signal d'horloge et un signal de réinitialisation.
    - Générer des stimuli pour un circuit séquentiel.
    - Calculer les sorties correspondantes aux stimuli.
    - Réconcilier les problèmes de synchronisation.
    - Utiliser des énoncés `assert` ou des conditions pour vérifier le module.
- Implémenter un circuit séquentiel sur un FPGA et en vérifier le fonctionnement correct
    - Utiliser des interfaces comme des boutons et des affichages à LED.
    - Constater et corriger les phénomènes de rebond des boutons et commutateurs.

Ce laboratoire s'appuie sur le matériel suivant :
1. Les concepts couverts dans les laboratoires #1 et #2.
2. La matière des cours des semaines 4 (Modélisation et vérification de circuits combinatoires) et 5 (Conception de chemins des données - surtout les diapositives 0502).

## Partie 0 : une machine à états de base

### Préparatifs

- Créez un répertoire `inf3500\labo-3`.
- Importez-y tous les fichiers du laboratoire à partir de l'entrepôt Git.
- Si vous utilisez Active-HDL :
    - Créez un espace de travail (workspace) et créez un projet (design).
    - Ajoutez les fichiers dans votre projet.
    - Compilez tous les fichiers.
    
Les fichiers suivants sont  fournis pour aider à contrôler les interfaces de la carte et faire l'implémentation dans le FPGA. Ne les modifiez pas.
- [utilitaires_inf3500_pkg.vhd](sources/utilitaires_inf3500_pkg.vhd) : pour regrouper un ensemble de fonctions utiles pour les laboratoires du cours;
- [generateur_horloge_precis.vhd](sources/generateur_horloge_precis.vhd) : pour générer une horloge à une fréquence désirée à partir de l'horloge de la carte;
- [monopulseur.vhd](sources/monopulseur.vhd) : pour synchroniser les actions des humains avec l'horloge du système;
- [top_labo_3.vhd](sources/top_labo_3.vhd) : pour regrouper tous les fichiers lors de l'implémentation;
- [basys_3_top.xdc](xdc/basys_3_top.xdc), [nexys_a7_50t_top.xdc](xdc/nexys_a7_50t_top.xdc) et [nexys_a7_100t_top.xdc](xdc/nexys_a7_100t_top.xdc) : trois fichiers correspondant à trois cartes de développement différentes, pour établir des liens entre des identificateurs et des pattes du FPGA; et,
- [labo_3_synth_impl.tcl](synthese-implementation/labo_3_synth_impl.tcl) : pour regrouper les commandes à utiliser pour faire l'implémentation.

### La machine à états et son code VHDL

Une machine à états de base vous est fournie dans le fichier [cadenas_labo_3.vhd](sources/cadenas_labo_3.vhd). La machine à états de base correspond au diagramme d'états suivant.

![machine à états de base](figures/machine_etats_de_base.svg)

La machine a cinq états, E_00 à E_04 inclusivement. À chaque coup d'horloge, la machine avance d'un état si le bouton(0) a une valeur de '1'. Les sorties sont indiquées dans les états.

### Simulation    

Une ébauche de banc d'essai se trouve dans le fichier [cadenas_labo_3_tb.vhd](sources/cadenas_labo_3_tb.vhd).

Faites la simulation de la machine à états de base à l'aide de ce banc d'essai. Avec Active-HDL :
- Choisissez le module `cadenas_labo_3_tb` comme `Top-Level`.
- Initialisez la simulation.
- Créez un chronogramme et glissez-y l'unité sous test `UUT`.
- Lancez la simulation, observez le chronogramme et observez les messages dans la console.
- Constatez qu'une valeur de '1' au bouton(0) résulte en une transition vers un autre état lors de la prochaine transition positive de l'horloge.
- Constatez que les sorties `ouvrir` et `alarme` sont déterminées par l'état actuel de la machine.

Si vous utilisez un autre environnement, suivez des étapes similaires pour lancer la simulation et observer les résultats.

### Implémentation et programmation de la carte

Suivez les étapes suivantes pour faire la synthèse et l'implémentation du code sur votre carte :

1. Lancez une fenêtre d'invite de commande (`cmd` sous Windows) et naviguez au répertoire `\inf350\labo-3\synthese-implementation\`.
2. De ce répertoire, lancez Vivado en mode script avec la commande 
`{repertoire-d-installation-d-Vivado}\bin\vivado -mode tcl` où {repertoire-d-installation-d-Vivado} est probablement C:\Xilinx\Vivado\2021.1 si votre système d'exploitation est Windows.
3. Dans la fenêtre, à l'invite de commande `Vivado%`, entrez les commandes contenues dans le fichier [labo_3_synth_impl.tcl](synthese-implementation/labo_3_synth_impl.tcl). Si votre carte n'est pas une Basys 3, vous devrez commenter certaines lignes et en dé-commenter d'autres qui correspondent à votre carte.

Observez le fonctionnement correct du système sur la carte. Inspectez le contenu du fichier [top_labo_3.vhd](sources/top_labo_3.vhd) pour connaître le pairage entre les ports de l'entité `cadenas_labo_3` et les périphériques d'entrées et de sortie de la carte : 
- Le port `reset` est relié au bouton du centre;
- Le port `boutons(3 downto 0)` est relié dans l'ordre aux boutons du bas, de gauche, d'en haut et de droite.
- Les boutons sont également reliés à des LED, directement et aussi par l'entremise du module de stabilisation et de synchronisation du fichier [monopulseur.vhd](sources/monopulseur.vhd). Observez que quand vous appuyez sur un bouton et le gardez pressé, une LED reste allumée et une autre ne reçoit qu'une seule courte impulsion.
- Les ports `alarme` et `ouvrir` sont reliés aux LED(1:0).
- L'affichage quadruple à 7 segments affiche les caractères placés sur le port `message`.

## Partie 1 : Conception du cadenas

### Spécifications de base

Faites la conception d'un cadenas numérique à boutons rencontrant les spécifications suivantes :
- La combinaison est composée d'une suite de boutons appuyés les uns après les autres dans une séquence déterminée. Conseil : chaque fois que le bon bouton est appuyé dans la séquence, votre machine devrait passer à l'état suivant. Si le mauvais bouton est appuyé, votre machine devrait retourner à l'état initial.
- La combinaison de base doit être : {bouton-haut, bouton-gauche, bouton-bas, bouton-droite, bouton-haut}.
- L'affichage doit indiquer un message représentatif de l'état actif.
- Quand la combinaison est entrée correctement, le port `ouvrir` doit prendre la valeur '1', ce qui fait allumer la LED correspondante, et l'affichage doit indiquer `"ourr"`.
- Le cadenas doit se verrouiller dès que le mauvais bouton est appuyé dans une séquence.
- Pour verrouiller le cadenas après qu'il ait été débarré, on le réinitialise à l'aide du bouton du centre relié au port `reset`.
- Pour cette partie, les ports `mode` et `alarme` ne sont pas utilisés.

Modifiez le fichier [cadenas_labo_3.vhd](sources/cadenas_labo_3.vhd) en conséquence. **Ne modifiez pas le nom du fichier, le nom de l'entité, la liste et le nom des ports, la liste et le nom des `generics`, ni le nom de l'architecture.**

### Simulation, vérification et débogage

Modifiez le banc d'essai dans le fichier [cadenas_labo_3_tb.vhd](sources/cadenas_labo_3_tb.vhd) pour vérifier complètement votre cadenas. Simulez complètement votre code pour vous assurer qu'il rencontre bien toutes les spécifications.

### Synthèse et implémentation

Faites la synthèse et l'implémentation de votre module pour votre carte. Vérifiez-en le fonctionnement.

### À remettre pour la partie 1

- Un seul fichier [cadenas_labo_3.vhd](sources/cadenas_labo_3.vhd) modifié pour toute la partie 1;
- Un diagramme d'états modifié en format .png ou .svg. Vous pouvez modifier directement [le diagramme fourni avec diagrams.net](https://app.diagrams.net/) ou bien soumettre un dessin fait à la main et numérisé, au propre, ou par tout autre moyen.
- Une brève explication de vos modifications dans le fichier [rapport.md](rapport.md);
- Une brève explication des vérifications effectuées par votre banc d'essai dans le fichier [rapport.md](rapport.md);
- Votre fichier [cadenas_labo_3_tb.vhd](sources/cadenas_labo_3_tb.vhd) modifié;
- Votre fichier de configuration final : [top_labo_3.bit](synthese-implementation/top_labo_3.bit).

## Partie 2 : Conception du cadenas : spécifications avancées

Ajoutez les spécifications suivantes à votre cadenas :
- Quand le cadenas est débarré, on peut modifier la combinaison avec les étapes suivantes :
    - Appuyer simultanément sur les boutons de droite et de gauche.
    - L'affichage doit alors indiquer "cmod" pour indiquer qu'on modifie maintenant la combinaison.
    - Appuyer sur une séquence de cinq bouton (excluant le bouton du centre, relié au `reset`) afin de l'enregistrer comme nouvelle séquence, après quoi le cadenas se verrouille en retournant à son état initial.
- Appuyer sur le bouton du centre `reset` a pour effet de réinitialiser la combinaison du cadenas à la séquence de la partie 1.
- Quand le cadenas est débarré, appuyer simultanément sur les boutons du haut et du bas verrouille le cadenas sans réinitialiser la combinaison.
- Pour cette partie, les ports `mode` et `alarme` ne sont pas utilisés.


Modifiez votre banc d'essai pour vérifier les nouvelles fonctionnalités.

Faites la synthèse et l'implémentez votre cadenas modifié. Vérifiez-en le fonctionnement correct sur votre carte.

### À remettre pour la partie 2

- Un seul fichier [cadenas_labo_3.vhd](sources/cadenas_labo_3.vhd) modifié pour les parties 1 et 2 mais avec des commentaires montrant clairement à quelle partie le code correspond;
- Un seul diagramme d'états modifié pour les partie 1 et 2, en format .png ou .svg. Vous pouvez modifier directement [le diagramme fourni avec diagrams.net](https://app.diagrams.net/) ou bien soumettre un dessin fait à la main, au propre, ou par tout autre moyen.
- Une brève explication de vos modifications dans le fichier [rapport.md](rapport.md);
- Votre banc d'essai final qui vérifie toutes les spécifications des parties 1 et 2, dans un seul fichier [cadenas_labo_3_tb.vhd](sources/cadenas_labo_3_tb.vhd) modifié;
- Votre fichier de configuration final : [top_labo_3.bit](synthese-implementation/top_labo_3.bit).

## Partie 3: Bonus

**Mise en garde**. *Compléter correctement les parties 1 et 2 peut donner une note de 17 / 20 (85%), ce qui peut normalement être interprété comme un A. La partie bonus demande du travail supplémentaire qui sort normalement des attentes du cours. Il n'est pas nécessaire de la compléter pour réussir le cours ni pour obtenir une bonne note. Il n'est pas recommandé de s'y attaquer si vous éprouvez des difficultés dans un autre cours. La partie bonus propose un défi supplémentaire pour les personnes qui souhaitent s'investir davantage dans le cours INF3500 en toute connaissance de cause.*

### 3a. Mode obfusqué

Dans les spécifications des parties 1 et 2, une utilisatrice astucieuse pourrait deviner la combinaison en essayant successivement tous les boutons et en observant la séquence des états. (Si le cadenas retourne à l'état initial, c'est nécessairement parce qu'on a appuyé sur le mauvais bouton.) Pour cette partie, ajoutez un mode de fonctionnement obfusqué activé par une valeur de "01" sur le port `mode` (le fonctionnement normal des parties 1 et 2 doit se faire quand le port `mode` a les valeurs "00", "10" ou "11".) Le porte `mode` est relié à deux commutateurs de la planchette - consultez le fichier [top_labo_3.vhd](sources/top_labo_3.vhd).

Ajoutez les spécifications suivantes à votre machine :
- La machine doit emmagasiner une séquence complète de 5 boutons appuyés avant de vérifier si la combinaison correcte a été entrée. La machine ne doit pas retourner à l'état initial tant que 5 boutons n'ont pas été appuyés les uns après les autres.
- L'affichage doit indiquer "br_1", "br_2", "br_3", "br_4" et "br_5" pour indiquer à l'utilisateur l'indice du bouton dans la séquence en cours.
- Si la séquence correcte est entrée, l'affichage doit indiquer "ourr" pour (débarré/ouvrir).
- Si la séquence est incorrecte, l'affichage doit indiquer "barr" pour (barré). Le système doit alors être prêt à accepter une nouvelle combinaison.

Expliquez tous vos changements dans votre rapport.

### 3b. Alarme pour essais incorrects multiples

Si une utilisatrice entre un code incorrect à trois reprises, le port `alarme` doit être activé et l'affichage doit indiquer "alrm". La machine doit rester dans cet état jusqu'à ce que le bouton `reset` soit appuyé.

Expliquez tous vos changements dans votre rapport.

## Remise

La remise se fait directement sur votre entrepôt Git. Faites un 'push' régulier de vos modifications, et faites un 'push' final avant la date limite de la remise. Respectez l'arborescence de fichiers originale. Consultez le barème de correction pour la liste des fichiers à remettre.

**Directives spéciales :**
- Ne modifiez pas les noms des fichiers, les noms des entités, les listes des `generics`, les listes des ports ni les noms des architectures.
- Remettez du code de très bonne qualité, lisible et bien aligné, bien commenté.
- Indiquez clairement la source de tout code que vous réutilisez ou duquel vous vous êtes inspiré/e.
- Modifiez et complétez le fichier [rapport.md](rapport.md), entre autres pour spécifier quelle carte vous utilisez.


## Barème de correction

Le barème de correction est progressif. Il est relativement facile d'obtenir une note de passage (> 10) au laboratoire et il faut mettre du travail pour obtenir l'équivalent d'un A (17/20). Obtenir une note plus élevée (jusqu'à 20/20) nécessite plus de travail que ce qui est normalement demandé dans le cadre du cours et plus que les 9 heures que vous devez normalement passer par semaine sur ce cours.

Critères | Points
-------- | ------
Partie 1 : Spécifications de base | 8
Partie 2 : Spécifications avancées | 7
Qualité, lisibilité et élégance du code : alignement, choix des identificateurs, qualité et pertinence des commentaires, respect des consignes de remise incluant les noms des fichiers, orthographe, etc. | 2
**Pleine réussite du labo** | **17**
Bonus partie 3a. Mode obfusqué | 2
Bonus partie 3b. Alarme | 1
**Maximum possible sur 20 points** | **20**


## Références pour creuser plus loin

Les liens suivants ont été vérifiés en septembre 2021.

- Aldec Active-HDL Manual : accessible en faisant F1 dans l'application, et accessible [à partir du site de Aldec](https://www.aldec.com/en/support/resources/documentation/manuals/).
- Tous les manuels de Xilinx :  <https://www.xilinx.com/products/design-tools/vivado/vivado-ml.html#documentation>
- Vivado Design Suite Tcl Command Reference Guide : <https://www.xilinx.com/content/dam/xilinx/support/documentation/sw_manuals/xilinx2021_1/ug835-vivado-tcl-commands.pdf>
- Vivado Design Suite User Guide - Design Flows Overview : <https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug892-vivado-design-flows-overview.pdf>
- Vivado Design Suite User Guide - Synthesis : <https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug901-vivado-synthesis.pdf>
- Vivado Design Suite User Guide - Implementation : <https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug904-vivado-implementation.pdf>
