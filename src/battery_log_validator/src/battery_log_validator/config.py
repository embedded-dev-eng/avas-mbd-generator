"""Chargement des seuils de securite depuis un fichier YAML externe.

Externaliser la configuration (plutot que des constantes codees en dur dans
le script) permet de faire evoluer les exigences de securite sans toucher
au code d'analyse, et de tracer chaque seuil jusqu'a sa source normative.
"""

from dataclasses import dataclass
from pathlib import Path
import yaml


@dataclass(frozen=True)
class Thresholds:
    temp_max_celsius: float
    temp_reference: str
    voltage_min_volts: float
    voltage_max_volts: float
    voltage_reference: str


def load_thresholds(config_path: Path) -> Thresholds:
    """Lit un fichier YAML de seuils et retourne un objet Thresholds valide.

    Leve FileNotFoundError si le fichier n'existe pas, et KeyError avec un
    message clair si une cle attendue est absente (plutot qu'un crash
    silencieux plus loin dans le programme).
    """
    if not config_path.exists():
        raise FileNotFoundError(
            f"Fichier de configuration introuvable : {config_path}"
        )

    with open(config_path, "r", encoding="utf-8") as f:
        raw = yaml.safe_load(f)

    try:
        return Thresholds(
            temp_max_celsius=float(raw["temperature"]["max_celsius"]),
            temp_reference=raw["temperature"].get("reference", ""),
            voltage_min_volts=float(raw["voltage"]["min_volts"]),
            voltage_max_volts=float(raw["voltage"]["max_volts"]),
            voltage_reference=raw["voltage"].get("reference", ""),
        )
    except KeyError as e:
        raise KeyError(
            f"Cle de configuration manquante dans {config_path} : {e}"
        ) from e
