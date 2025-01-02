
------------------------------------------------------------------------

# INF3500 - labo 4 - automne 2023
# Équipe

Membre #1 : **Michaud, Maël, 2209239**

Membre #2 : **Rouleau, Thomas, 2221053**

------------------------------------------------------------------------

## Partie #3

**Faire un choix et garder seulement une option.**
Nous utilisons la carte Basys 3.

Voici un lien vers notre fichier de configuration final : [top_labo_4.bit](synthese-implementation/top_labo_4.bit)

Voici les ressources utilisées par notre système :
Quoi | Slice LUTs | Slice Registers | F7 Muxes | F8 Muxes | Bonded IOB
--- | ---------- | --------------- | -------- | -------- | ------------
module racine_carre seul | 92    | 72         | 6  | 0  | 28
tout le système | 190    | 135         | 0  | 0  | 50

## Partie 4: Bonus

*Faire un choix et garder seulement une option.*
- Nous sommes vraiment en avance dans nos études, dans ce cours et tous les autres, et nous adorons les défis dans ce cours, donc nous avons complété une ou plusieurs parties du bonus.

### Partie 4a :

Notre fichier [racine_carree.vhd](sources/racine_carree.vhd). contient des changements pour le calcul de la valeur initiale X<sub>0</sub>, aux lignes 61 et aux lignes 73 à 87.

### Partie 4b :

Notre fichier [racine_carree.vhd](sources/racine_carree.vhd) ne contiennent pas de changements pour de la division.

Nous avons utiliser un module différent décrit dans le fichier [votre-nom-de-fichier.vhd](sources/votre-nom-de-fichier.vhd). Notre approche consiste à ...
