import sys,trimesh,numpy as np
from shapely.geometry import box,Polygon
S=sys.argv[1]; L=lambda n: trimesh.load(f'{S}/{n}.stl'); P={n:L(n) for n in ('disi','erkek','erkek_yerinde','levha','kabuk','kabuk_yerinde','ic','kiskac','somun','tam_vida')}
for n,m in P.items(): print(f'{n:14s} su geçirmez={m.is_watertight} ölçü={np.round(m.extents,2)}')
def kes(a,b):
    r=trimesh.boolean.intersection([a,b]); return 0 if r.is_empty else round(r.volume,3)
D=11.5; H=5+D+0.8+1.0; Z0=H-0.2
notch=Polygon([(-18.5,-60),(18.5,-60),(18.5,-30),(0,-19),(-18.5,-30)]).buffer(-1.5).buffer(1.5)
def cihaz(re,h=9.25,n=30):
    parts=[]
    for i in range(n):
        z0=h*i/n; z1=h*(i+1)/n; d=0 if z1<h-re else re-np.sqrt(max(0,re*re-(z1-(h-re))**2))
        g=box(-28,-29,28,29).buffer(-6).buffer(6).buffer(-d).difference(notch); m=trimesh.creation.extrude_polygon(g,z1-z0); m.apply_translation([0,0,z0]); parts.append(m)
    c=trimesh.boolean.union(parts); c.apply_transform(np.diag([1,1,-1,1])); return c
for re in (2.5,3.5): print(f'1) cihaz (kenar r{re}, V çentikli) dışarıda', round(trimesh.boolean.difference([cihaz(re),P['ic']]).volume,3))
lv=P['levha'].copy(); lv.apply_transform(np.diag([1,1,-1,1])); lv.apply_translation([0,0,Z0])
print('2) düz levha (vida dahil) - dişi', kes(lv,P['disi']))
for d in ((0.3,0,0),(0,0.3,0),(0,-0.3,0)):
    l2=lv.copy(); l2.apply_translation(d); print('   levha kayarsa',d[:2],kes(l2,P['disi']))
kb=P['kabuk'].copy(); kb.apply_translation([0,0,Z0]); ey=P['erkek_yerinde']
print('3) kabuk-dişi',kes(kb,P['disi']),' kabuk-erkek',kes(kb,ey),' erkek-dişi',kes(ey,P['disi']))
# vida yatağı boşlukları
for y in np.arange(33.8,44.0,1.0):
    hv=kb.ray.intersects_location([[0.4,y,60]],[[0,0,-1]])[0]; hd=P['disi'].ray.intersects_location([[0.4,y,60]],[[0,0,-1]])[0]; he=ey.ray.intersects_location([[0.4,y,-60]],[[0,0,1]])[0]
    if len(hv): print(f'   y={y:.1f}: vida alt {hv[:,2].min():.2f} yatak {max(z for z in hd[:,2] if z<hv[:,2].min()+0.01):.2f} | vida üst {hv[:,2].max():.2f} erkek alt {he[:,2].min():.2f}')
print('   dişi y sonu',round(P['disi'].bounds[1][1],2),' vida ucu',round(P['levha'].bounds[1][1],2))
# 4) kapalı: iki kabuk + çentik açık mı
k=P['kabuk']; k2=k.copy(); k2.apply_transform(trimesh.transformations.rotation_matrix(np.pi,[0,1,0]))
print('4) iki kabuk çakışma',kes(k,k2))
vc=trimesh.creation.extrude_polygon(notch.buffer(0.5),40); vc.apply_translation([0,0,-20])
print('   cihaz çentiği (+0,5) içinde kabuk malzemesi', kes(k,vc)+kes(k2,vc),'mm3')
# 5) somun tam vidada (aynı fazda)
tv=P['tam_vida']; s=P['somun'].copy(); s.apply_transform(trimesh.transformations.rotation_matrix(-np.pi/2,[1,0,0])); s.apply_translation([0,tv.bounds[0][1]+1.0,0])
print('5) somun-tam vida çakışma (aynı faz)', kes(s,tv))
# 6) kıskaçlar
xe=62.4/2+4.125
for sx in (1,-1):
    q=P['kiskac'].copy(); T=np.array([[-1,0,0,xe+1.6],[0,0,1,-2.5],[0,1,0,0],[0,0,0,1]],float)
    if sx<0: T=np.diag([-1,1,1,1])@T
    q.apply_transform(T); print('6) kıskaç',sx,'kabuk1',kes(q,k),'kabuk2',kes(q,k2))

r=trimesh.boolean.intersection([k,k2]); print('   iki kabuk çakışma yeri z', np.round(r.bounds[:,2],3), 'xy', np.round(r.bounds[:,:2],1).tolist())
