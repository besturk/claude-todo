#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Çok parçalı nesne destekli Bambu Studio proje 3MF yazıcısı.

thermoformed skill'inin bambu3mf.yaz() yapısını aynen izler; tek farkı bir
nesnenin birden çok PARÇA taşıyabilmesidir (kalp-80-ref levha setindeki gibi):
  normal_part   -> levha, kaburga, yarım vida (her biri kendi dolgu ayarıyla)
  modifier_part -> kenar bandı (eş merkezli %100), direk güçlendirici
Parçalar aynı nesne koordinatındadır; nesne, normal parçalarının sınır
kutusu merkezine taşınır (Bambu'nun kuralı).
"""
from __future__ import annotations
import datetime as _dt
import json, os, sys, uuid, zipfile
from dataclasses import dataclass, field
import numpy as np


def _skill_yolu():
    for kok in ("/root/.claude/skills", os.path.expanduser("~/.claude/skills")):
        for d, _, f in os.walk(kok):
            if d.endswith("thermoformed/scripts") and "bambu3mf.py" in f:
                return d
    raise SystemExit("thermoformed skill'i bulunamadı")


sys.path.insert(0, _skill_yolu())
import bambu3mf as B3  # noqa: E402

BED, PLATE_STRIDE, PLATES_PER_ROW = B3.BED, B3.PLATE_STRIDE, B3.PLATES_PER_ROW
_f, _kacis = B3._f, B3._kacis


@dataclass
class Parca:
    ad: str
    mesh: object
    tur: str = "normal_part"          # normal_part | modifier_part
    ayarlar: dict = field(default_factory=dict)


@dataclass
class Nesne:
    ad: str
    parcalar: list
    ekstruder: int = 1
    ayarlar: dict = field(default_factory=dict)
    konum: tuple = (0.0, 0.0)
    mesh: object = None               # normal parçaların birleşimi (yerleşim ve görsel için)


def nesne_kur(ad, parcalar, ekstruder=1, ayarlar=None):
    """Parçaları birlikte merkezler; Nesne döndürür."""
    import trimesh
    normal = [p.mesh for p in parcalar if p.tur == "normal_part"]
    b = np.array([m.bounds for m in normal])
    lo, hi = b[:, 0].min(0), b[:, 1].max(0)
    c = (lo + hi) / 2.0
    yeni = []
    for p in parcalar:
        m = p.mesh.copy(); m.apply_translation(-c)
        yeni.append(Parca(p.ad, m, p.tur, dict(p.ayarlar)))
    birlesik = trimesh.util.concatenate([p.mesh for p in yeni if p.tur == "normal_part"])
    return Nesne(ad=ad, parcalar=yeni, ekstruder=ekstruder, ayarlar=dict(ayarlar or {}),
                 mesh=birlesik)


def _nesne_dosyasi(n, idler):
    p = ['<?xml version="1.0" encoding="UTF-8"?>',
         '<model unit="millimeter" xml:lang="en-US" '
         'xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" '
         'xmlns:BambuStudio="http://schemas.bambulab.com/package/2021" '
         'xmlns:p="http://schemas.microsoft.com/3dmanufacturing/production/2015/06" '
         'requiredextensions="p">',
         ' <metadata name="BambuStudio:3mfVersion">1</metadata>', ' <resources>']
    for parca, k in zip(n.parcalar, idler):
        V, F = parca.mesh.vertices, parca.mesh.faces
        p.append(f'  <object id="{k}" p:UUID="{uuid.uuid4()}" type="model">')
        p += ['   <mesh>', '    <vertices>']
        p += ['     <vertex x="%s" y="%s" z="%s"/>' % (_f(a), _f(b), _f(c)) for a, b, c in V]
        p += ['    </vertices>', '    <triangles>']
        p += ['     <triangle v1="%d" v2="%d" v3="%d"/>' % (a, b, c) for a, b, c in F]
        p += ['    </triangles>', '   </mesh>', '  </object>']
    p += [' </resources>', ' <build/>', '</model>']
    return "\n".join(p)


def yaz(cikti, tablalar, proje_ayarlari: dict, baslik="Thermoformed", aciklama="",
        surum="02.08.02.61"):
    bugun = _dt.date.today().isoformat()
    onbellek = {}
    sayac = 0
    parca_id, saran, dosya = {}, {}, {}
    for t in tablalar:
        for n in t.nesneler:
            ids = []
            for _ in n.parcalar:
                sayac += 1; ids.append(sayac)
            sayac += 1
            parca_id[id(n)], saran[id(n)], dosya[id(n)] = ids, sayac, ids[0]

    kay, bld, rels, montaj = [], [], [], []
    ri = 0
    for t in tablalar:
        for n in t.nesneler:
            ri += 1
            rels.append(f' <Relationship Target="/3D/Objects/object_{dosya[id(n)]}.model" '
                        f'Id="rel-{ri}" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>')
    for ti, t in enumerate(tablalar):
        ox = (ti % PLATES_PER_ROW) * PLATE_STRIDE
        oy = -(ti // PLATES_PER_ROW) * PLATE_STRIDE
        for n in t.nesneler:
            s = saran[id(n)]
            comp = "\n".join(
                f'    <component p:path="/3D/Objects/object_{dosya[id(n)]}.model" objectid="{k}" '
                f'p:UUID="{uuid.uuid4()}" transform="1 0 0 0 1 0 0 0 1 0 0 0"/>'
                for k in parca_id[id(n)])
            kay.append(f'  <object id="{s}" p:UUID="{uuid.uuid4()}" type="model">\n'
                       f'   <components>\n{comp}\n   </components>\n  </object>')
            x = BED / 2 + n.konum[0] + ox
            y = BED / 2 + n.konum[1] + oy
            z = float(n.mesh.extents[2]) / 2.0
            bld.append(f'  <item objectid="{s}" p:UUID="{uuid.uuid4()}" '
                       f'transform="1 0 0 0 1 0 0 0 1 {_f(x)} {_f(y)} {_f(z)}" printable="1"/>')
            montaj.append(f'   <assemble_item object_id="{s}" instance_id="0" '
                          f'transform="1 0 0 0 1 0 0 0 1 {_f(x)} {_f(y)} {_f(z)}" offset="0 0 0" />')

    model = "\n".join([
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<model unit="millimeter" xml:lang="en-US" '
        'xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" '
        'xmlns:BambuStudio="http://schemas.bambulab.com/package/2021" '
        'xmlns:p="http://schemas.microsoft.com/3dmanufacturing/production/2015/06" '
        'requiredextensions="p">',
        f' <metadata name="Application">BambuStudio-{surum}</metadata>',
        ' <metadata name="BambuStudio:3mfVersion">1</metadata>',
        ' <metadata name="Copyright"></metadata>',
        f' <metadata name="CreationDate">{bugun}</metadata>',
        f' <metadata name="Description">{_kacis(aciklama)}</metadata>',
        ' <metadata name="Designer"></metadata>',
        ' <metadata name="DesignerCover"></metadata>',
        ' <metadata name="DesignerUserId"></metadata>',
        ' <metadata name="License"></metadata>',
        f' <metadata name="ModificationDate">{bugun}</metadata>',
        ' <metadata name="Origin"></metadata>',
        ' <metadata name="ProfileCover"></metadata>',
        ' <metadata name="ProfileDescription"></metadata>',
        ' <metadata name="ProfileTitle"></metadata>',
        f' <metadata name="Title">{_kacis(baslik)}</metadata>',
        ' <resources>', "\n".join(kay), ' </resources>',
        f' <build p:UUID="{uuid.uuid4()}">', "\n".join(bld), ' </build>', '</model>'])

    ms = ['<?xml version="1.0" encoding="UTF-8"?>', '<config>']
    for t in tablalar:
        for n in t.nesneler:
            fc = sum(len(p.mesh.faces) for p in n.parcalar)
            ms.append(f'  <object id="{saran[id(n)]}">')
            ms.append(f'    <metadata key="name" value="{_kacis(n.ad)}"/>')
            for kk in sorted(n.ayarlar):
                ms.append(f'    <metadata key="{kk}" value="{_kacis(str(n.ayarlar[kk]))}"/>')
            ms.append(f'    <metadata key="extruder" value="{n.ekstruder}"/>')
            ms.append(f'    <metadata face_count="{fc}"/>')
            for p, k in zip(n.parcalar, parca_id[id(n)]):
                pfc = len(p.mesh.faces)
                ms.append(f'    <part id="{k}" subtype="{p.tur}" uuid="{uuid.uuid4()}">')
                ms.append(f'      <metadata key="name" value="{_kacis(p.ad)}"/>')
                ms.append('      <metadata key="matrix" value="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1"/>')
                for kk in sorted(p.ayarlar):
                    ms.append(f'      <metadata key="{kk}" value="{_kacis(str(p.ayarlar[kk]))}"/>')
                ms.append(f'      <mesh_stat face_count="{pfc}" edges_fixed="0" degenerate_facets="0" '
                          'facets_removed="0" facets_reversed="0" backwards_edges="0"/>')
                ms.append('    </part>')
            ms.append('  </object>')
    kimlik = 100
    for ti, t in enumerate(tablalar):
        ms += ['  <plate>', f'    <metadata key="plater_id" value="{ti+1}"/>',
               f'    <metadata key="plater_name" value="{_kacis(t.ad)}"/>',
               '    <metadata key="locked" value="false"/>',
               '    <metadata key="filament_map_mode" value="Auto For Flush"/>',
               f'    <metadata key="thumbnail_file" value="Metadata/plate_{ti+1}.png"/>',
               f'    <metadata key="thumbnail_no_light_file" value="Metadata/plate_no_light_{ti+1}.png"/>',
               f'    <metadata key="top_file" value="Metadata/top_{ti+1}.png"/>',
               f'    <metadata key="pick_file" value="Metadata/pick_{ti+1}.png"/>']
        for n in t.nesneler:
            kimlik += 11
            ms += ['    <model_instance>', f'      <metadata key="object_id" value="{saran[id(n)]}"/>',
                   '      <metadata key="instance_id" value="0"/>',
                   f'      <metadata key="identify_id" value="{kimlik}"/>', '    </model_instance>']
        ms.append('  </plate>')
    ms += ['  <assemble>'] + montaj + ['  </assemble>', '</config>']

    kesim = ['<?xml version="1.0" encoding="utf-8"?>', '<objects>']
    for t in tablalar:
        for n in t.nesneler:
            kesim += [f' <object id="{saran[id(n)]}">',
                      '  <cut_id id="0" check_sum="1" connectors_cnt="0"/>', ' </object>']
    kesim.append('</objects>')
    fil_dizi = {f"plate_{i+1}": {"nozzle_sequence": [], "optimal_assignment": [], "sequence": []}
                for i in range(len(tablalar))}
    slice_info = ('<?xml version="1.0" encoding="UTF-8"?>\n<config>\n  <header>\n'
                  '    <header_item key="X-BBL-Client-Type" value="slicer"/>\n'
                  f'    <header_item key="X-BBL-Client-Version" value="{surum}"/>\n'
                  '  </header>\n</config>\n')
    ct = ('<?xml version="1.0" encoding="UTF-8"?>\n'
          '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">\n'
          ' <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>\n'
          ' <Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>\n'
          ' <Default Extension="png" ContentType="image/png"/>\n'
          ' <Default Extension="gcode" ContentType="text/x.gcode"/>\n</Types>\n')
    kok_rels = ('<?xml version="1.0" encoding="UTF-8"?>\n'
                '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n'
                ' <Relationship Target="/3D/3dmodel.model" Id="rel-1" '
                'Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>\n'
                ' <Relationship Target="/Metadata/plate_1.png" Id="rel-2" '
                'Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/thumbnail"/>\n'
                ' <Relationship Target="/Metadata/plate_1.png" Id="rel-4" '
                'Type="http://schemas.bambulab.com/package/2021/cover-thumbnail-middle"/>\n'
                ' <Relationship Target="/Metadata/plate_1_small.png" Id="rel-5" '
                'Type="http://schemas.bambulab.com/package/2021/cover-thumbnail-small"/>\n'
                '</Relationships>\n')
    obj_rels = ('<?xml version="1.0" encoding="UTF-8"?>\n'
                '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n'
                + "\n".join(rels) + '\n</Relationships>\n')

    os.makedirs(os.path.dirname(os.path.abspath(cikti)) or ".", exist_ok=True)
    with zipfile.ZipFile(cikti, "w", zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        z.writestr("[Content_Types].xml", ct)
        z.writestr("_rels/.rels", kok_rels)
        z.writestr("3D/3dmodel.model", model)
        z.writestr("3D/_rels/3dmodel.model.rels", obj_rels)
        for t in tablalar:
            for n in t.nesneler:
                z.writestr(f"3D/Objects/object_{dosya[id(n)]}.model", _nesne_dosyasi(n, parca_id[id(n)]))
        z.writestr("Metadata/project_settings.config",
                   json.dumps(proje_ayarlari, ensure_ascii=False, indent=4, sort_keys=True))
        z.writestr("Metadata/model_settings.config", "\n".join(ms))
        z.writestr("Metadata/slice_info.config", slice_info)
        z.writestr("Metadata/cut_information.xml", "\n".join(kesim))
        z.writestr("Metadata/filament_sequence.json", json.dumps(fil_dizi, separators=(",", ":")))
        for ti, t in enumerate(tablalar, 1):
            z.writestr(f"Metadata/plate_{ti}.png", B3._tabla_png(t, 512, (43, 43, 43, 255), B3.DOLGU, onbellek))
            z.writestr(f"Metadata/plate_no_light_{ti}.png", B3._tabla_png(t, 512, (0, 0, 0, 0), B3.DOLGU, onbellek))
            z.writestr(f"Metadata/top_{ti}.png", B3._tabla_png(t, 256, (0, 0, 0, 0), B3.DOLGU, onbellek))
            z.writestr(f"Metadata/pick_{ti}.png", B3._tabla_png(t, 256, (0, 0, 0, 0), B3.DOLGU, onbellek))
        z.writestr("Metadata/plate_1_small.png", B3._tabla_png(tablalar[0], 128, (43, 43, 43, 255), B3.DOLGU, onbellek))
    return cikti
