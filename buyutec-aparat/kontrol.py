import buyutec_aparat as b, trimesh, numpy as np
m,yf=b.model()
def kutu(*a): return b.kutu(*a)
# Mercek halkası: dış 14,9 en, iç 7,7 x 4,1, kalınlık 3,0 (Y yönü); boyun halkanın içinde
y0,y1=yf,yf+b.HALKA_KAL
oz0=0.0; oz1=oz0+b.HALKA_IC_YUK
dis=kutu(-14.9/2,14.9/2,y0,y1,oz0-1.5,oz1+1.5)
ic=kutu(-b.HALKA_IC_EN/2,b.HALKA_IC_EN/2,y0-1,y1+1,oz0,oz1)
halka=dis.difference(ic)
cak=m.intersection(halka).volume if m.intersection(halka).is_volume else 0.0
R=[]
def chk(ad,ok,olc): R.append((ad,ok,olc)); print(("GEÇTİ " if ok else "KALDI ")+ad+" -> "+olc)
chk("Halka takılıyken parçayla çakışma yok", cak<0.01, f"çakışma hacmi {cak:.3f} mm³")
chk("Flanş–blok arası = halka kalınlığı (sıkı, pay 0)", abs(b.BOYUN_UZ-b.HALKA_KAL)<1e-9, f"{b.BOYUN_UZ:.2f} / {b.HALKA_KAL:.2f}")
chk("Boyun halka deliğine sığıyor", b.BOYUN_EN<=b.HALKA_IC_EN and b.BOYUN_KAL<=b.HALKA_IC_YUK, f"{b.BOYUN_EN}x{b.BOYUN_KAL} ≤ {b.HALKA_IC_EN}x{b.HALKA_IC_YUK}")
chk("Uç blok halkadan geçebiliyor", b.BLOK_EN<=b.HALKA_IC_EN and b.BLOK_KAL<=b.HALKA_IC_YUK, f"{b.BLOK_EN}x{b.BLOK_KAL} ≤ {b.HALKA_IC_EN}x{b.HALKA_IC_YUK}")
chk("Blok halkayı tutuyor (boyundan kalın)", b.BLOK_KAL>b.BOYUN_KAL and b.BLOK_EN>b.BOYUN_EN, f"blok {b.BLOK_EN}x{b.BLOK_KAL} > boyun {b.BOYUN_EN}x{b.BOYUN_KAL}")
# vida delikleri ölçümü: z=0.5 kesitinde delik merkezleri
s=m.section(plane_origin=[0,0,0.5],plane_normal=[0,0,1]); p,_=s.to_2D()
ics=[q for q in p.polygons_full[0].interiors]
from shapely.geometry import Polygon
cx=sorted(Polygon(i).centroid.x for i in ics) if ics else []
chk("İki vida deliği, merkezler arası 7,8", len(cx)==2 and abs((cx[1]-cx[0])-b.DELIK_ARA)<0.05, f"{len(cx)} delik, ara {cx[1]-cx[0]:.2f} mm" if len(cx)==2 else str(cx))
chk("Kapalı yüzey (watertight)", m.is_watertight, str(m.is_watertight))
chk("En ince duvar ≥ 1,2 mm (FDM)", min(b.PLAKA_KAL,b.BOYUN_KAL)>=1.2, f"plaka {b.PLAKA_KAL}, boyun {b.BOYUN_KAL}")
mont=trimesh.util.concatenate([m,halka]); mont.export("montaj.glb")
print("TOPLAM", sum(r[1] for r in R),"/",len(R))
