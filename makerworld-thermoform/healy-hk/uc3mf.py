"""Healy — Hello Kitty yöntemi: PETG kalıp seti + PLA levha seti (Bambu P2S 3MF)."""
import sys, os, json, trimesh
D = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(D, "..", "healy-cerceve"))
import bambu3mf_parcali as BP
from bambu3mf_parcali import Parca, nesne_kur
sys.path.insert(0, BP._skill_yolu())
import bambu3mf as B3
from thermoform import raf_yerlestir, _kutu
L = lambda n: trimesh.load(f"{D}/healy-hk-{n}.stl")
proje = json.load(open(os.path.join(BP._skill_yolu(), "..", "references", "p2s_project_settings.config"), encoding="utf-8"))
def tabla(ad, ns):
    for n, (cx, cy) in zip(ns, raf_yerlestir([_kutu(n.mesh) for n in ns])): n.konum = (cx, cy)
    return B3.Tabla(ad=ad, nesneler=ns)
# Hello Kitty kalıp ayarları: 0,28 mm katman, %10 dolgu, 4 alt / 5 üst kabuk
KAL = {"layer_height": "0.28", "sparse_infill_density": "10%", "skin_infill_density": "10%",
       "skeleton_infill_density": "10%", "bottom_shell_layers": "4", "top_shell_layers": "5"}
BP.yaz(f"{D}/TF-Healy-HK-kalip-PETG.3mf",
       [tabla("Healy kalip (PETG)", [nesne_kur("disi-kalip", [Parca("disi-kalip", L("disi"))], 2, KAL),
                                     nesne_kur("erkek-kalip", [Parca("erkek-kalip", L("erkek"))], 2, KAL)])],
       proje, baslik="Healy - Hello Kitty yontemi - kalip PETG", aciklama="Disi + erkek kalip, aradaki bosluk 0,8 mm")
# Levha: Hello Kitty ile aynı — %25 honeycomb, alt/üst kabuk 0, 2 duvar, 0,2 mm
LEV = {"top_shell_layers": "0", "bottom_shell_layers": "0", "sparse_infill_pattern": "honeycomb",
       "sparse_infill_density": "25%", "skin_infill_density": "25%", "skeleton_infill_density": "25%", "wall_loops": "2"}
BP.yaz(f"{D}/TF-Healy-HK-levha-PLA.3mf",
       [tabla("Healy levha (PLA)", [nesne_kur("levha-1", [Parca("levha-1", L("levha"))], 1, LEV),
                                    nesne_kur("levha-2", [Parca("levha-2", L("levha"))], 1, LEV)])],
       proje, baslik="Healy - Hello Kitty yontemi - levha PLA", aciklama="0,8 mm levha + 1,65 x 4 mm kaburga, %25 honeycomb")
print("ok")
