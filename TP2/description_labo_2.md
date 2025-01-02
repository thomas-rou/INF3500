-----------------------------------------------------------------------
<table>
<tr>
<td><img src="figures\Polytechnique_signature-RGB-gauche_FR.png" alt="Logo de Polytechnique Montréal"></td>
<td><h2>INF3500 - Conception et réalisation de systèmes numériques
<br><br>Automne 2023
<br><br>Laboratoire #2
<br>Module combinatoire, banc d'essai et ressources du FPGA
</h2></td>
</tr>
</table>

------------------------------------------------------------------------

# Le problème du musée

------------------------------------------------------------------------

Ce laboratoire s'appuie sur et complémente le matériel suivant :
1. Les concepts couverts dans le laboratoire #1.
2. La matière du cours des semaines 2 (Technologies de logique programmable) et 3 (Modélisation et vérification de circuits combinatoires).

À la fin de ce laboratoire, vous devrez être capable de :

- concevoir un module combinatoire pour qu'il rencontre ses spécifications;
- concevoir un banc d'essai pour vérifier qu'un module combinatoire rencontre ses spécifications;
    - utiliser des fonctions en VHDL
    - utiliser des types abstraits
    - utiliser l'énoncé _assert_
- faire la synthèse et l'implémentation du module, et programmer un FPGA pour en vérifier le fonctionnement.

## Partie 0 : Préparatifs

- Créez un répertoire `inf3500\labo-2` dans lequel vous mettrez tous les fichiers de ce laboratoire.
- Importez tous les fichiers du laboratoire à partir de l'entrepôt Git.
- Si vous utilisez Active-HDL :
    - Créez un espace de travail (workspace) et créez un projet (design).
    - Ajoutez les fichiers dans votre projet.
    - Compilez tous les fichiers.
    - Choisissez le module `musee_labo_2_tb` comme `Top-Level`.
    - Créez un chronogramme et glissez-y l'unité sous test `UUT`.
    - Lancez la simulation et observez les messages dans la console.
- Si vous utilisez un autre environnement, suivez des étapes similaires pour lancer la simulation et observer les résultats.

## Partie 1 : Conception d'un module combinatoire

Le Musée d'histoire naturelle de New York investit dans un nouveau système de surveillance. Les objets des différentes collections sont réparties dans 16 salles d'exposition numérotées de 0 à 15 inclusivement, et les salles sont groupée en quatre zones. La zone 00 regroupe les salles 0 à 3, la zone 01 les sales 4 à 7, la zone 10 les salles 8 à 11, et la zone 11 les salles 12 à 15. Chaque salle est munie d’un détecteur de mouvement, dont le numéro est le même que la salle qu'il surveille.

Pendant la nuit, trois gardiens patrouillent le musée en tout temps. Une alarme `alarme_intrus` doit être déclenchée quand au moins quatre détecteurs de mouvement sont actifs, indiquant qu'il y a un intrus en plus des trois gardiens. Une alarme `alarme_jasette` doit être déclenchée quand un ou deux détecteur de mouvement sont actifs, indiquant que des gardiens sont dans la même salle et ne font pas leur travail. Une alarme `alarme_greve` doit être déclenchée quand aucun détecteur de mouvement n'est actif, indiquant que les trois gardiens ont quitté leur poste. Une alarme spéciale `alarme_generale` s'active lorsque les statues de cire et les animaux empaillés prennent vie et que tous les détecteurs sont activés.

Faites la conception du système de contrôle des détecteurs de mouvement. Complétez la définition du fichier [musee_labo_2.vhd](sources/musee_labo_2.vhd) et remettez-le. **N'apportez aucun changement aux noms des entités, aux noms des architectures ni à la liste des ports ni à leurs noms.**

Utilisez l'ébauche de banc d'essai fournie dans le fichier [musee_labo_2_tb.vhd](sources/musee_labo_2_tb.vhd) pour stimuler votre module.

Pour tous les points, votre architecture doit fonctionner pour tout nombre de salles `N` multiple de quatre.

## Partie 2 : Conception d'un banc d'essai

Complétez et remettez la description de banc d'essai fournie dans le fichier [musee_labo_2_tb.vhd](sources/musee_labo_2_tb.vhd) pour qu'il vérifie le comportement de votre module selon les spécifications données dans la partie 1.

Vérifiez le fonctionnement correct de votre code de la partie 1 avec votre banc d'essai. Au besoin, corrigez votre code de la partie 1.

## Partie 3 : Synthèse et implémentation sur la carte

Confirmez que vous avez bien importé et ajouté les fichiers suivants dans votre répertoire de projet `inf3500\labo-2`. Ne les modifiez pas.

- sources\top_labo_2.vhd
- sources\utilitaires_inf3500_pkg.vhd
- xdc\basys_3_top.xdc, xdc\nexys_a7_50t_top.xdc et xdc\nexys_a7_100t_top.xdc
- synthese-implementation\labo_2_synth_impl.tcl

Utilisez le fichier de commandes [labo_2_synth_impl.tcl](synthese-implementation/labo_2_synth_impl.tcl). Commentez et dé-commentez les lignes appropriées du fichiers selon la planchette que vous utilisez.

1. Lancez une fenêtre d'invite de commande (`cmd` sous Windows) et naviguez au répertoire `inf3500\labo-2\synthese-implementation`.
2. De ce répertoire, lancez Vivado en mode script avec la commande `{repertoire-d-installation-d-Vivado}\bin\vivado -mode tcl`, où `{repertoire-d-installation-d-Vivado}` est probablement `C:\Xilinx\Vivado\2021.2` si votre système d'exploitation est Windows.
3. Dans la fenêtre, à l'invite de commande `Vivado%`, entrez une à une les commandes du fichier [labo_2_synth_impl.tcl](synthese-implementation/labo_2_synth_impl.tcl).

Consultez le fichier [top_labo_2.vhd](sources/top_labo_2.vhd) pour comprendre comment sont reliés les ports du module musee_labo_2 aux différentes ressources de la carte. On utilise entre autres les affichages à sept segments.

Pour cette partie, on fixe le nombre de salles `N` à 16.

Vérifiez le fonctionnement correct de votre système sur la carte, et remettez votre fichier de configuration [top_labo_2.bit](synthese-implementation/top_labo_2.bit).

## Partie 4: Bonus - au-delà du A

**Mise en garde**. *Compléter correctement les parties 1, 2 et 3 peut donner une note de 17 / 20 (85%), ce qui peut normalement être interprété comme un A. La partie 4 demande du travail supplémentaire qui sort normalement des attentes du cours. Il n'est pas nécessaire de la compléter pour réussir le cours ni pour obtenir une bonne note. Il n'est pas recommandé de s'y attaquer si vous éprouvez des difficultés dans un autre cours. La partie 4 propose un défi supplémentaire pour les personnes qui souhaitent s'investir davantage dans le cours INF3500 en toute connaissance de cause.*

### 4a. Mode jour : afficher le numéro de la zone la plus occupée

Le système des détecteurs de mouvement est utilisé aussi pendant le jour pour aider à répartir les guides dans les différentes zones. Il y a toujours quatre zones et les salles sont réparties également entre les zones. Un guide est attitré à chaque zone. Un cinquième guide est gardé en réserve.

Dès qu'une zone a des visiteurs dans au moins deux salles, le guide en réserve doit s'y déplacer pour appuyer son collègue qui s'y trouve déjà. Dans ce cas, une alarme `alarme_reserve` doit être activée. Le numéro de la zone où le guide en réserve doit se déplacer doit être placé sur le port `zone_reserve`.

Si plus d'une zone a au moins deux salles occupées, alors le port `zone_reserve` doit indiquer la zone où il y en a le plus. Si plusieurs zones ont le même nombre de salles occupées (au moins 2), alors `zone_reserve` doit afficher en priorité la zone avec le nombre le plus bas (0, puis 1, puis 2, puis 3).

Pour tous les points, votre architecture doit fonctionner pour tout nombre de salles `N` multiple de quatre. Il y a toujours exactement quatre zones.

Modifiez vos fichiers [musee_labo_2.vhd](sources/musee_labo_2.vhd) et [musee_labo_2_tb.vhd](sources/musee_labo_2_tb.vhd). Expliquez clairement vos modifications par des commentaires et dans votre [rapport.md](rapport.md). 

### 4b. Étude de l'utilisation des ressources de votre module selon le nombre d'entrées

Faites plusieurs synthèses (et non l'implémentation au complet) de votre module musee_labo_2 uniquement (et non du module top_labo_2) pour différents nombres de salles et de zones (il y a toujours quatre salles par zone). Obtenez un rapport des ressources utilisées avec les commandes suivantes :

`synth_design -top musee_labo_2 -generic N=**un-nombre-ici** -part xc7a35tcpg236-1 -assert`  
`report_utilization -file monrapport.txt` (pour créer un nouveau fichier) ou `report_utilization -file monrapport.txt -append` (pour ajouter au fichier à chaque itération)

Changez le nombre de salles à chaque fois (paramètre N). Vous pouvez programmer une boucle (`help for`) dans Vivado afin d'automatiser le processus.

Étudiez la progression de la complexité du circuit quand le nombre de détecteurs varie. Présentez vos résultats sous forme tabulaire et graphique, faites une analyse et présentez une discussion dans votre [rapport.md](rapport.md).

## Remise

La remise se fait directement sur votre entrepôt Git. Faites un 'push' régulier de vos modifications, et faites un 'push' final avant la date limite de la remise. Respectez l'arborescence de fichiers originale. Consultez le barème de correction pour la liste des fichiers à remettre.

**Directives spéciales :**
- Ne modifiez pas les noms des fichiers, les noms des entités, les listes des `generics`, les listes des ports ou les noms des architectures.
- Remettez du code de très bonne qualité, lisible et bien aligné, bien commenté.
- Indiquez clairement la source de tout code que vous réutilisez ou duquel vous vous êtes inspiré/e.
- Modifiez et complétez le fichier [rapport.md](rapport.md), entre autres pour spécifier quelle carte vous utilisez.

## Barème de correction

Le barème de correction est progressif. Il est relativement facile d'obtenir une note de passage (> 10) au laboratoire et il faut mettre du travail pour obtenir l'équivalent d'un A (17/20). Obtenir une note plus élevée (jusqu'à 20/20) nécessite plus de travail que ce qui est normalement demandé dans le cadre du cours et plus que les 9 heures que vous devez normalement passer par semaine sur ce cours.

Critères | Points
-------- | ------
Partie 1 : votre module final dans le fichier musee_labo_2.vhd | 6
Partie 2 : votre banc d'essai complet dans le fichier musee_labo_2_tb.vhd | 7
Partie 3 : votre fichier top_labo_2.bit | 2
Qualité, lisibilité et élégance du code : alignement, choix des identificateurs, qualité et pertinence des commentaires, respect des consignes de remise incluant les noms des fichiers, orthographe, etc. | 2
Pleine réussite du labo | 17

Bonus | Points
----- | ------
Partie 4a : vos fichiers musee_labo_2.vhd et musee_labo_2_tb.vhd modifiés | 2
Partie 4b : vos données sous forme tabulaire et graphique dans votre fichier [rapport.md](rapport.md), une analyse et une discussion | 1
Maximum possible sur 20 points | 20

## Références pour creuser plus loin

Les liens suivants ont été vérifiés en septembre 2021.

- Aldec Active-HDL Manual : accessible en faisant F1 dans l'application, et accessible [à partir du site de Aldec](https://www.aldec.com/en/support/resources/documentation/manuals/).
- Tous les manuels de Xilinx :  <https://www.xilinx.com/products/design-tools/vivado/vivado-ml.html#documentation>
- Vivado Design Suite Tcl Command Reference Guide : <https://www.xilinx.com/content/dam/xilinx/support/documentation/sw_manuals/xilinx2021_1/ug835-vivado-tcl-commands.pdf>
- Vivado Design Suite User Guide - Design Flows Overview : <https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug892-vivado-design-flows-overview.pdf>
- Vivado Design Suite User Guide - Synthesis : <https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug901-vivado-synthesis.pdf>
- Vivado Design Suite User Guide - Implementation : <https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug904-vivado-implementation.pdf>
