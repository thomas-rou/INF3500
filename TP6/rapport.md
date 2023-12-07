
------------------------------------------------------------------------

# INF3500 - labo 6
# Équipe *nom-d-equipe-ici*
# Noms et prénoms des coéquipiers: *vos-noms-et-prenoms-ici*

------------------------------------------------------------------------

## Partie 1 : Nouvelles instructions et programme en assembleur

Notes et observations ...

Parties 1B et 1C : fichiers modifiés [PolyRISC_v10c.vhd](sources/PolyRISC_v10c.vhd) et [PolyRISC_utilitaires_pkg.vhd](sources/PolyRISC_utilitaires_pkg.vhd).

(Remettre une seule version des fichiers pour les parties 1B et 1C.)

Partie 1D : fichier modifié [PolyRISC_le_programme_pkg.vhd](sources/PolyRISC_le_programme_pkg.vhd) utilisant vos nouvelles instructions.

Le cas échéant, votre banc d'essai modifié [PolyRISC_v10_tb.vhd](sources/PolyRISC_v10_tb.vhd).

## Partie 2 : Implémentation sur la planchette

**Faire un choix et garder seulement une option.**

Nous utilisons la carte Basys 3.

Nous utilisons la carte Nexys A7-50T.

Nous utilisons la carte Nexys A7-100T.

Voici un lien vers notre fichier de configuration final : [top_labo_6.bit](synthese-implementation/top_labo_6.bit)

## Partie 3 : Ressources pour implémenter le processeur PolyRISC

Voici le nombre de ressources disponibles dans notre FPGA.

Slice LUTs | Slice Registers | F7 Muxes | F8 Muxes | Bonded IOB
---------- | --------------- | -------- | -------- | ----------
nombre? | nombre? | nombre? | nombre? | nombre?

Voici le nombre de ressources utilisées par le PolyRISC selon les valeurs demandées dans les instructions du labo.

Nreg | Wd | Mi | Md | version du processeur | Slice LUTs | Slice Registers | F7 Muxes | F8 Muxes | Bonded IOB
---- | -- | -- | -- | --------------------- | ---------- | --------------- | -------- | -------- | ------------
16   | 32 | 8  | 8  | version de base       | 292    | 197        | 0  | 0  | 68
16   | 64 | 8  | 8  | version de base       | 555    | 389         | 0  | 0  | 132
32   | 32 | 8  | 8  | version de base       | 290    | 197         | 0  | 0  | 68
32   | 64 | 8  | 8  | version de base       | 555    | 389         | 0  | 0  | 132
16   | 32 | 8  | 8  | version partie 1      | 606    | 294         | 96  | 32  | 68
16   | 64 | 8  | 8  | version partie 1      | 1179    | 582         | 192  | 64  | 132
32   | 32 | 8  | 8  | version partie 1      | 606    | 294         | 96  | 32  | 68
32   | 64 | 8  | 8  | version partie 1      | 1213   | 582         | 192 | 64  | 132

Commentez complètement vos résultats ici.

- Si on s'intéresse aux f7 muxes, f8 muxes et aux Bonded IOB des deux versions, on peut voir avec le tableau que seulement
le Wd influence la différence dans ces valeurs selon la version du processeur. Cela s'explique par le fait que le Wd est la constante
qui influence la largeur du chemin des données en bit. De ce fait, comme l'information est plus large lorsque Wd =64 que lorsque Wd =32 
il est normal que ces 3 sections soient plus grandes lorsque Wd = 64.
- Pour ce qui est des Slice LUTs et des Slice Registers, ils sont influencés autant par le Nreg que le Wd bien que l'influence du Wd est
plus importante. C'est expliqué par le fait qu'un chemin des données plus grand implique des opérations logiques plus complexes et donc un nombre de Slice LUTs 
nécessaire plus élevé, mais également un nombre de Slice Registers plus grand pour stocker ces données plus complexes.



## Partie 4 : Bonus

*Faire un choix et garder seulement une option.*
- Nous n'avons pas complété le bonus. Nous nous concentrons sur notre réussite dans ce cours et dans d'autres.
- Nous sommes vraiment en avance dans nos études, dans ce cours et tous les autres, et nous adorons les défis dans ce cours, donc nous avons complété une ou plusieurs parties du bonus.
