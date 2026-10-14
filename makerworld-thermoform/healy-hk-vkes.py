"""Healy HK: V açıklığı için levhanın önceden kesilecek bölgesini hesaplar.

Hedef: şekillenmiş kabukta cihazın V çentiğinin (1 mm paylı) üstü açık olsun.
Model: sıcak levha önce erkek kalıbın düz tepesine değer ve orada esnemez
(düz tepe levhada 1:1). Düz tepenin kenarından kaburgaya kadar olan halka,
yastık kenarını (R yayı + dik duvar + flanş) eşit esneyerek kaplar.
Çıktı: healy-hk-vkes.scad (levha koordinatında bir polygon).
"""
import numpy as np
from shapely.geometry import Polygon, LineString
cihaz_boy, yan_pay, R, D = 58, 3.2, 10, 11.5
kalinlik, oluk_ara, oluk_pay, kaburga_en = 0.8, 1.5, 0.175, 1.65
P_OFS = kalinlik + oluk_ara + oluk_pay + kaburga_en
IC_Y = cihaz_boy/2 + yan_pay                    # 32,2
y_f = -(IC_Y - R)                               # düz tepenin alt kenarı
# cihaz çentiği (V) + 1 mm pay
V = Polygon([(-18.5,-60),(18.5,-60),(18.5,-30),(0,-19),(-18.5,-30)]).buffer(-1.5).buffer(1.5).buffer(1.0)
# halkanın esneme katsayısı: kabuk yolu / levha yolu
La = R*np.pi/2 + (D - R) + (P_OFS - kaburga_en)
Lf = R + (P_OFS - kaburga_en)
s = La / Lf
def harita(y_hedef):
    if y_hedef >= y_f: return y_hedef
    u = y_f - y_hedef
    a = R*np.arcsin(min(u, R)/R) + max(0, u - R)
    return y_f - a/s
xs = np.linspace(V.bounds[0]+1e-3, V.bounds[2]-1e-3, 241)
ust = []
for x in xs:
    g = V.intersection(LineString([(x,-80),(x,40)]))
    if g.is_empty: continue
    yN = max(c[1] for c in (g.coords if hasattr(g,'coords') else [p for gg in g.geoms for p in gg.coords]))
    ust.append((x, harita(yN)))
pts = ust + [(ust[-1][0], -70), (ust[0][0], -70)]
open('healy-hk-vkes.scad','w').write('// healy-hk-vkes.py ile üretildi — elle değiştirme\n'
    f'// esneme katsayısı s = {s:.3f}\nVKES_PTS = [' + ', '.join(f'[{x:.3f}, {y:.3f}]' for x,y in pts) + '];\n')
print('s=',round(s,3),' V tepe (hedef)',round(V.bounds[3],2),' levhada tepe',round(max(p[1] for p in ust),2),' en dar yer y=',round(min(p[1] for p in ust),2))
