import sys,trimesh,numpy as np
V=sys.argv[1]; L=lambda n: trimesh.load(f'{V}/{n}.stl')
P={n:L(n) for n in ('levha','disi','erkek','kiskac','somun','ic','kabuk')}
for n,m in P.items(): print(f'{n:7s} su gecirmez={m.is_watertight} olcu={np.round(m.extents,2)}')
def kes(a,b):
    try: r=trimesh.boolean.intersection([a,b]); return round(r.volume,3) if not r.is_empty else 0
    except Exception as e: return 'hata '+str(e)
def M(z_mirror_to): # shell z -> female z : z_f = PF+t - z
    T=np.eye(4); T[2,2]=-1; T[2,3]=z_mirror_to; return T
D=10; t=0.6; PF=2+D+t+0.1; HD=PF+t+0.1; TE=2.2; C=0.1
# 1 cihaz
c=L('../v4/cihaz'); c.apply_translation([0,0,-c.bounds[0][2]])
from shapely.geometry import Polygon
vp=Polygon([(-18.5,-50),(18.5,-50),(18.5,-30),(0,-19),(-18.5,-30)]).buffer(-1.5).buffer(1.5)
vc=trimesh.creation.extrude_polygon(vp,30); vc.apply_translation([0,0,-5])
c=trimesh.boolean.difference([c,vc]); print('   çentikli cihaz hacmi',round(c.volume,1))
d=trimesh.boolean.difference([c,P['ic']]); print('1) Healy yarısı (9.25) iç hacmin dışında kalan:', round(d.volume,3),'mm3 /',round(c.volume,1))
# 2 düz levha dişi kalıbın cebinde
lv=P['levha'].copy(); lv.apply_transform(M(PF+t)); print('2) düz levha cepte, dişi ile çakışma:', kes(lv,P['disi']))
# levhayı 0.15 kaydırınca çakışma (kilit testi)
for dx,dy in((0.3,0),(0,0.3)):
    l2=lv.copy(); l2.apply_translation([dx,dy,0]); print(f'   levha {dx},{dy} mm kayarsa çakışma:', kes(l2,P['disi']))
# 3 şekillenmiş kabuk dişide
kb=P['kabuk'].copy(); kb.apply_transform(M(PF+t)); print('3) kabuk dişide, çakışma:', kes(kb,P['disi']))
# 4 erkek kalıp tam inmiş: erkek z -> shell z = z - TE - C ; shell->female
er=P['erkek'].copy(); T=np.eye(4); T[2,3]=-(TE+C); er.apply_transform(T); er.apply_transform(M(PF+t))
print('4) erkek inmiş: erkek-kabuk', kes(er,kb), ' erkek-dişi', kes(er,P['disi']))
print('   erkek alt yüzü z=',round(er.bounds[1][2],3),' dişi üstü',round(P['disi'].bounds[1][2],3))
# 5 kapalı: iki kabuk çakışmaz, iki yarım vida
k2=P['kabuk'].copy(); R=np.diag([-1,1,-1,1]); k2.apply_transform(R)
print('5) iki kabuk çakışma:', kes(P['kabuk'],k2))
# kıskaç: yan çerçevede

A=31.4+0.1+1.2
for sx in (1,-1):
    k=P['kiskac'].copy(); 
    # klips: x->-x (dünya), y->z, z->y
    T=np.array([[-1,0,0,A],[0,0,1,-3],[0,1,0,0],[0,0,0,1]],float)
    if sx<0: T=np.diag([-1,1,1,1])@T
    k.apply_transform(T)
    print('6) kıskaç',sx,'kabuk1',kes(k,P['kabuk']),'kabuk2',kes(k,k2), 'x aralığı',np.round(k.bounds[:,0],2),'z',np.round(k.bounds[:,2],2))
