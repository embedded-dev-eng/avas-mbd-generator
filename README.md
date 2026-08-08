# AVAS MBD Generator

Outil d'automatisation **Model-Based Design (MBD)** qui génère automatiquement un modèle
Simulink à partir d'une spécification fonctionnelle (Excel) et d'un jeu de paramètres (XML) —
sans écrire un seul bloc à la main.

Cas d'usage de démonstration : le système d'alerte sonore pour véhicule électrique
**AVAS** (Acoustic Vehicle Alerting System), imposé en Europe par le règlement **UN R138 /
UE 540/2014**. Les seuils utilisés (vitesse d'activation, plage de fréquence, niveau sonore)
sont issus de ce règlement public.

## Pourquoi ce projet

Cet outil reproduit, sur un cas d'usage 100% public, la méthode que j'ai développée et mise en
œuvre en entreprise (Expleo Group) sur deux projets consécutifs de conception basée sur les
modèles (top-level design MBD) :

- **Version 1** : lecture d'une spécification fonctionnelle et de paramètres depuis des
  fichiers **Excel**.
- **Version 2** : lecture d'une architecture au format **XML** (type NEDS) pour générer le
  modèle correspondant.

Ce dépôt combine les deux approches (Excel pour l'architecture fonctionnelle, XML pour les
paramètres) sur un cas d'usage librement réutilisable.

## Ce que fait l'outil

1. Lit `data/functions.xlsx` : la liste des fonctions (blocs), leurs entrées/sorties, et leur
   enchaînement.
2. Lit `data/parameters.xml` : les paramètres de chaque fonction (un "data dictionary" simplifié).
3. Génère `output/build_avas_model.m` : un script MATLAB qui construit automatiquement le
   modèle Simulink — sous-systèmes, ports, connexions, et variables de paramètres.
4. Génère `output/architecture_preview.svg` : un aperçu visuel de l'architecture, consultable
   sans avoir MATLAB installé.

## Architecture générée

![Architecture AVAS](output/architecture_preview.svg)

`SpeedSensorInterface → SoundGenerator → VolumeControl → SpeakerOutputDriver`

Chaque sous-système est un bloc indépendant qui, dans une version plus poussée, peut lui-même
contenir d'autres sous-systèmes représentant ses exigences de niveau inférieur — exactement le
principe de décomposition MBD utilisé pour l'outil original.

### Logique interne implémentée : SoundGenerator

Le sous-système `SoundGenerator` n'est pas qu'une coquille vide : il contient une **Lookup
Table 1-D** qui convertit `VehicleSpeed_kmh` en une fréquence audio (Hz), en s'appuyant
directement sur les seuils `F02_ActivationSpeed_kmh_min/max` et
`F02_FrequencyBand_Hz_min/max` lus depuis `parameters.xml` — aucune valeur n'est codée en dur
dans le modèle. Modifier ces seuils dans le XML et relancer `generate_model.py` met
automatiquement à jour la table de correspondance.

*Simplification assumée* : la table interpole uniquement entre les deux bornes de vitesse
(0 → 20 km/h) et de fréquence (160 → 5000 Hz) définies par le règlement ; une implémentation
de production affinerait la courbe avec des points intermédiaires et la génération réelle du
signal audio (oscillateur), hors du périmètre de cette démonstration.

## Utilisation

```bash
# 1. Installer les dépendances Python
pip install openpyxl graphviz

# 2. Générer le script MATLAB et l'aperçu
python3 scripts/generate_model.py

# 3. Dans MATLAB (avec Simulink installé)
run('output/build_avas_model.m')
```

Le fichier `AVAS_ElectricVehicle.slx` est alors créé automatiquement dans `output/`.

## Modifier l'architecture

Pour ajouter ou modifier une fonction, il suffit d'éditer `data/functions.xlsx` (une ligne =
une fonction) et `data/parameters.xml` (les paramètres associés), puis de relancer
`generate_model.py`. Aucune modification du code Python n'est nécessaire — c'est tout l'intérêt
de l'approche MBD automatisée.

## Stack technique

- Python (`openpyxl`, `xml.etree`, `graphviz`)
- MATLAB / Simulink (génération de modèle via l'API `add_block` / `add_line`)
- Méthodologie : Model-Based Design, décomposition fonctionnelle en sous-systèmes

## Auteur

[Ton nom] — Ingénieur systèmes embarqués, spécialisée en Model-Based Design.
Basé sur une expérience de deux projets MBD en entreprise (Expleo Group, 2023–2024).

## Sources réglementaires

- Règlement (UE) N°540/2014 relatif au niveau sonore des véhicules à moteur
- UN Regulation No. 138 — Acoustic Vehicle Alerting Systems (AVAS)
