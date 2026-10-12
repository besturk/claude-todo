import sys,trimesh,numpy as np
from shapely.geometry import Polygon
V=sys.argv[1]; L=lambda n: trimesh.load(f'{V}/{n}.stl')
P={n:L(n) for n in ('levha','erkek','cerceve','cerceve_baski','kiskac','somun','kabuk','ic','bant')}
for n,m in P.items(): print(f'{n:14s} su geçirmez={m.is_watertight} ölçü={np.round(m.extents,2)}')
def kes(a,b):
    r=trimesh.boolean.intersection([a,b]); return 0 if r.is_empty else round(r.volume,3)
# 1 cihaz
c0=trimesh.load(V+'/../v4/cihaz.stl'); c0.apply_translation([0,0,-c0.bounds[0][2]])
vp=Polygon([(-18.5,-50),(18.5,-50),(18.5,-30),(0,-19),(-18.5,-30)]).buffer(-1.5).buffer(1.5)
vc=trimesh.creation.extrude_polygon(vp,40); vc.apply_translation([0,0,-5]); c0=trimesh.boolean.difference([c0,vc]); h0=c0.extents[2]
for h in (18.5,18.6):
    c=c0.copy(); c.apply_scale([1,1,(h/2)/h0]); print(f'1) cihaz {h} mm: dışarıda', round(trimesh.boolean.difference([c,P['ic']]).volume,3))
kb,er,ce=P['kabuk'],P['erkek'],P['cerceve']
print('2) kabuk-erkek', kes(kb,er), ' kabuk-çerçeve', kes(kb,ce), ' çerçeve-erkek (direkler dahil)', kes(ce,er))
for d in ((0.3,0,0),(-0.3,0,0),(0,0.3,0),(0,-0.3,0)):
    k=kb.copy(); k.apply_translation(d); print('   kabuk',d[:2],'kayarsa çerçeveye çarpma', kes(k,ce))
# çerçeve direklerde yana oynama
for d in ((0.35,0,0),(0,0.35,0)):
    c=ce.copy(); c.apply_translation(d); print('   çerçeve',d[:2],'kayarsa erkeğe çarpma', kes(c,er))
# vida: tabana ve yatağa
for y in (37.6,39.0,41.0,42.8):
    hb=er.ray.intersects_location([[0,y,-50]],[[0,0,1]])[0]; ht=ce.ray.intersects_location([[0,y,-50]],[[0,0,1]])[0]; hv=kb.ray.intersects_location([[0,y,-50]],[[0,0,1]])[0]
    print(f'   y={y}: taban üstü {round(max(z for z in hb[:,2] if z<1),2)}  vida alt {round(hv[:,2].min(),2)} üst {round(hv[:,2].max(),2)}  çerçeve yatağı {round(min(z for z in ht[:,2] if z>1),2)}')
# 3 kapalı
k2=kb.copy(); k2.apply_transform(np.diag([-1,1,-1,1])); print('3) iki kabuk çakışma', kes(kb,k2))
x0=58/2+9
for s in (1,-1):
    k=P['kiskac'].copy()
    T=np.array([[-1,0,0,x0+1.6],[0,0,1,-2.5],[0,1,0,0],[0,0,0,1]],float)
    if s<0: T=np.diag([-1,1,1,1])@T
    k.apply_transform(T); print('   kıskaç',s,'kabuk1',kes(k,kb),'kabuk2',kes(k,k2),'z',np.round(k.bounds[:,2],2))
