# Büyüteç mercek tutucu aparat — parametrik kaynak (ölçüler mm)
# Mercek halkası (kumpasla ölçüldü): iç boşluk 7,7 x 4,1 ; kalınlık 3,0
# Diğer ölçüler fotoğraftan, kumpas cetveline göre ölçeklendi.
import numpy as np, trimesh
from shapely.geometry import Polygon

HALKA_IC_EN, HALKA_IC_YUK, HALKA_KAL = 7.7, 4.1, 3.0

TABAN_EN   = 25.5   # üçgen plaka taban kenarı
PLAKA_YUK  = 13.6   # tabandan bele kadar
BEL_UZ     = 2.1    # bel (plaka ile flanş arası)
PLAKA_KAL  = 2.1
BEL_EN     = 6.5
DELIK_ARA  = 7.8    # vida merkezleri arası (fotoğraftan)
DELIK_PAY  = 0.3    # fotoğraf ölçüsü payı: delik yanlara ±0,3 mm oval
DELIK_Y    = 4.0    # tabandan delik merkezine
DELIK_CAP  = 2.2
HAVSA_CAP  = 4.2
FLANS_EN, FLANS_KAL, FLANS_DERIN = 15.7, 3.2, 8.3
DESTEK_R   = 4.0    # flanş altı kavisli destek
BOYUN_EN, BOYUN_KAL = HALKA_IC_EN, HALKA_IC_YUK   # deliği tam doldurur, halka kaymaz (pay 0)
BOYUN_UZ   = HALKA_KAL          # halka flanşla blok arasında sıkı (pay 0,00)
TIRNAK     = 0.6    # her yanda halka yan çubuğuna binme
BASLIK_UZ  = 2.6    # tırnak başı boyu (ucu pahlı, itince bacaklar içeri esner)
UC_EN      = 6.4    # tırnak ucunun eni (giriş pahı)
YARIK_EN   = 1.8    # iki bacak arası yarık (2x0,6 sıkışma + pay)
YARIK_ALT  = 10.0   # yarığın indiği yer (tabandan); esneme boyu için

def kutu(x0,x1,y0,y1,z0,z1):
    b = trimesh.creation.box(extents=[x1-x0,y1-y0,z1-z0])
    b.apply_translation([(x0+x1)/2,(y0+y1)/2,(z0+z1)/2]); return b

def model():
    yb = PLAKA_YUK + BEL_UZ       # flanş alt yüzü
    p = Polygon([(-TABAN_EN/2,0),(TABAN_EN/2,0),(BEL_EN/2,PLAKA_YUK),
                 (BEL_EN/2,yb+0.5),(-BEL_EN/2,yb+0.5),(-BEL_EN/2,PLAKA_YUK)])
    p = p.buffer(1.5, join_style=1).buffer(-1.5, join_style=1)   # iç köşeler yuvarlak
    p = p.buffer(-0.5, join_style=1).buffer(0.5, join_style=1)   # dış köşeler hafif
    plaka = trimesh.creation.extrude_polygon(p, PLAKA_KAL)
    parts = [plaka]
    yf = yb + FLANS_KAL
    parts.append(kutu(-FLANS_EN/2,FLANS_EN/2,yb,yf,0,FLANS_DERIN))
    # kavisli destek
    d = kutu(-BEL_EN/2,BEL_EN/2,yb-DESTEK_R,yb+0.01,PLAKA_KAL-0.01,PLAKA_KAL+DESTEK_R)
    c = trimesh.creation.cylinder(radius=DESTEK_R, height=BEL_EN+2, sections=96)
    c.apply_transform(trimesh.transformations.rotation_matrix(np.pi/2,[0,1,0]))
    c.apply_translation([0,yb-DESTEK_R+0.15,PLAKA_KAL+DESTEK_R-0.15])  # teğet sivri kenar olmasın
    parts.append(d.difference(c))
    parts.append(kutu(-BOYUN_EN/2,BOYUN_EN/2,yf-0.01,yf+BOYUN_UZ+0.01,0,BOYUN_KAL))
    # tırnak başı: tutma yüzü düz, ucu pahlı (yamuk)
    y0 = yf+BOYUN_UZ; w0 = BOYUN_EN/2+TIRNAK
    bas = trimesh.creation.extrude_polygon(Polygon([(-w0,y0),(w0,y0),(w0,y0+0.6),
            (UC_EN/2,y0+BASLIK_UZ),(-UC_EN/2,y0+BASLIK_UZ),(-w0,y0+0.6)]), BOYUN_KAL)
    parts.append(bas)
    m = trimesh.boolean.union(parts)
    # yarık: tırnaktan aşağı, flanş ve belden geçip plakaya iner (ucu yuvarlak)
    ytop = yf+BOYUN_UZ+BASLIK_UZ+1
    yr = Polygon([(-YARIK_EN/2,YARIK_ALT),(YARIK_EN/2,YARIK_ALT),(YARIK_EN/2,ytop),(-YARIK_EN/2,ytop)])
    from shapely.geometry import Point
    yr = yr.union(Point(0,YARIK_ALT).buffer(YARIK_EN/2, resolution=24))
    yk = trimesh.creation.extrude_polygon(yr, 20); yk.apply_translation([0,0,-5])
    m = m.difference(yk)
    # havşalı vida delikleri (havşa ön yüzde)
    for sx in (-1,1):
        x = sx*DELIK_ARA/2
        hv, kv = [], []
        for dx in (-DELIK_PAY, DELIK_PAY):
            h = trimesh.creation.cylinder(radius=DELIK_CAP/2, height=10, sections=64)
            h.apply_translation([x+dx,DELIK_Y,0]); hv.append(h.vertices)
            k = trimesh.creation.cone(radius=HAVSA_CAP/2+0.5, height=HAVSA_CAP/2+0.5, sections=90)
            k.apply_transform(trimesh.transformations.rotation_matrix(np.pi,[1,0,0]))
            k.apply_translation([x+dx,DELIK_Y,PLAKA_KAL+0.5]); kv.append(k.vertices)
        h = trimesh.Trimesh(np.vstack(hv)).convex_hull
        k = trimesh.Trimesh(np.vstack(kv)).convex_hull
        m = m.difference(h).difference(k)
    return m, yf

if __name__ == "__main__":
    m, yf = model()
    m.merge_vertices(); m.export("buyutec_aparat.stl"); m.export("buyutec_aparat.glb")
    print("hacim", round(m.volume,1), "watertight", m.is_watertight, "boyut", m.extents.round(2))
