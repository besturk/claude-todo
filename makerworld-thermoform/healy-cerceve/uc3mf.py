"""Healy çerçeve yöntemi: PETG kalıp seti + PLA levha seti (Bambu P2S 3MF)."""
import sys, os, json, trimesh
D = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, D)
import bambu3mf_parcali as BP
from bambu3mf_parcali import Parca, nesne_kur
sys.path.insert(0, BP._skill_yolu())
import bambu3mf as B3
from thermoform import raf_yerlestir, _kutu
L = lambda n: trimesh.load(f"{D}/healy-c-{n}.stl")
proje = json.load(open(os.path.join(BP._skill_yolu(), "..", "references", "p2s_project_settings.config"), encoding="utf-8"))
KATI = {"bottom_shell_layers": "3", "top_shell_layers": "3", "sparse_infill_density": "100%"}

def tabla(ad, nesneler):
    for n, (cx, cy) in zip(nesneler, raf_yerlestir([_kutu(n.mesh) for n in nesneler])):
        n.konum = (cx, cy)
    return B3.Tabla(ad=ad, nesneler=nesneler)

# PETG: erkek kalıp (direkler %100) + oluklu çerçeve (%100)
erkek = nesne_kur("erkek-kalip", [Parca("erkek-kalip", L("erkek")),
                                  Parca("direk-guclendirici", L("direk_destek"), "modifier_part",
                                        {"sparse_infill_density": "100%"})],
                  ekstruder=2, ayarlar={"wall_loops": "3", "sparse_infill_density": "20%"})
cerceve = nesne_kur("cerceve", [Parca("cerceve", L("cerceve_baski"))],
                    ekstruder=2, ayarlar={"wall_loops": "3", "sparse_infill_density": "100%"})
BP.yaz(f"{D}/TF-Healy-cerceve-kalip-PETG.3mf", [tabla("Healy kalip seti (PETG)", [erkek, cerceve])], proje,
       baslik="Healy cerceve yontemi - kalip seti PETG", aciklama="Erkek kalip + kilavuz direkler + oluklu cerceve")

# PLA: 2 levha (çok parçalı) + 2 yan kıskaç + askılı somun
def levha(ad):
    return nesne_kur(ad, [Parca(ad, L("levha_duz")),
                          Parca(ad + "-kaburga", L("kaburga"), ayarlar=KATI),
                          Parca(ad + "-vida", L("vida"), ayarlar=KATI),
                          Parca(ad + "-bant", L("bant"), "modifier_part",
                                {"sparse_infill_density": "100%", "sparse_infill_pattern": "concentric"})],
                     ekstruder=1, ayarlar={"top_shell_layers": "0", "bottom_shell_layers": "0",
                                           "sparse_infill_pattern": "honeycomb", "sparse_infill_density": "25%"})
kis = lambda ad: nesne_kur(ad, [Parca(ad, L("kiskac"))], 1, {"sparse_infill_density": "100%"})
somun = nesne_kur("askili-somun", [Parca("askili-somun", L("somun"))], 1,
                  {"wall_loops": "4", "sparse_infill_density": "40%", "brim_type": "outer_only", "brim_width": "5"})
BP.yaz(f"{D}/TF-Healy-cerceve-levha-PLA.3mf",
       [tabla("Healy levha seti (PLA)", [levha("levha-1"), levha("levha-2"), kis("yan-kiskac-1"), kis("yan-kiskac-2"), somun])],
       proje, baslik="Healy cerceve yontemi - levha seti PLA",
       aciklama="1 mm levha %25 honeycomb, kaburga ve vida dolu, kenar bandi es merkezli %100")
print("ok")
