"""Healy — Hello Kitty yöntemi, tam set: PETG kalıp + PLA levha/kıskaç/somun (Bambu P2S 3MF)."""
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
# Kalıplar — Hello Kitty ayarı: 0,28 mm katman, %10 dolgu, 4 alt / 5 üst kabuk
KAL = {"layer_height": "0.28", "sparse_infill_density": "10%", "skin_infill_density": "10%",
       "skeleton_infill_density": "10%", "bottom_shell_layers": "4", "top_shell_layers": "5"}
BP.yaz(f"{D}/TF-Healy-HK-kalip-PETG.3mf",
       [tabla("Healy kalip (PETG)", [nesne_kur("disi-kalip", [Parca("disi-kalip", L("disi"))], 2, KAL),
                                     nesne_kur("erkek-kalip", [Parca("erkek-kalip", L("erkek"))], 2, KAL)])],
       proje, baslik="Healy - Hello Kitty yontemi - kalip PETG", aciklama="Disi + erkek kalip, 0,8 mm bosluk, V + vida yatagi")
# Levha — Hello Kitty ayarı: %25 honeycomb, alt/üst kabuk 0, 2 duvar; yarım vida dolu
LEV = {"top_shell_layers": "0", "bottom_shell_layers": "0", "sparse_infill_pattern": "honeycomb",
       "sparse_infill_density": "25%", "skin_infill_density": "25%", "skeleton_infill_density": "25%", "wall_loops": "2"}
KATI = {"bottom_shell_layers": "3", "top_shell_layers": "3", "sparse_infill_density": "100%"}
levha = lambda ad: nesne_kur(ad, [Parca(ad, L("levha_govde")), Parca(ad + "-vida", L("vida"), ayarlar=KATI)], 1, LEV)
kis = lambda ad: nesne_kur(ad, [Parca(ad, L("kiskac"))], 1, {"sparse_infill_density": "100%"})
somun = nesne_kur("askili-somun", [Parca("askili-somun", L("somun"))], 1,
                  {"wall_loops": "4", "sparse_infill_density": "40%", "brim_type": "outer_only", "brim_width": "5"})
BP.yaz(f"{D}/TF-Healy-HK-levha-PLA.3mf",
       [tabla("Healy levha (PLA)", [levha("levha-1"), levha("levha-2"), kis("kiskac-1"), kis("kiskac-2"), somun])],
       proje, baslik="Healy - Hello Kitty yontemi - levha PLA", aciklama="0,8 mm levha + kaburga, V onceden kesik, yarim vida dolu; 2 kiskac; askili somun")
print("ok")
