import sys,trimesh,numpy as np,json
from shapely.geometry import box,Polygon
from shapely.ops import unary_union
R,K=sys.argv[1:3]
def esneme(plug,z0,opening):
    # plug: tepe yüzeyi (alt yüz hariç) alanı + açıklıkla taban arasındaki düz halka
    f=plug.triangles_center[:,2]>z0+0.01
    top=plug.area_faces[f].sum()
    s=plug.section(plane_origin=[0,0,z0+0.05],plane_normal=[0,0,1]); p,_=s.to_2D(to_2D=np.eye(4)); base=unary_union(p.polygons_full)
    return (top+opening.area-base.area)/opening.area
def profil(plug,z0,op_half,ax):
    xs=np.linspace(-op_half,op_half,600); zs=[]
    for x in xs:
        o=[0,0,60]; o[ax]=x; h=plug.ray.intersects_location([o],[[0,0,-1]])[0]
        zs.append(max(h[:,2].max(),z0) if len(h) else z0)
    zs=np.array(zs)-z0; L=np.sum(np.hypot(np.diff(xs),np.diff(zs))); return L/(2*op_half), xs, zs
out={}
# kalp referansı
er=trimesh.load(K+'/erkek_net.stl'); er.apply_translation([-67.7603455,-60.0725861,0])
dome=er.slice_plane([0,0,3.0],[0,0,1]); dome=dome.slice_plane([0,0,0],[1,0,0]) if False else dome
# direkleri çıkar: |x|<50
dome=dome.slice_plane([50,0,0],[-1,0,0]).slice_plane([-50,0,0],[1,0,0])
s=er.section(plane_origin=[0,0,3.3],plane_normal=[0,0,1]); p,_=s.to_2D(to_2D=np.eye(4)); db=max(unary_union(p.polygons_full).geoms if hasattr(unary_union(p.polygons_full),'geoms') else [unary_union(p.polygons_full)],key=lambda g:g.area)
op=db.buffer(3.4)
out['kalp']={'esneme':esneme(dome,3.0,op),'yukseklik':float(er.bounds[1][2]-3)}
for a,ax in ((0,0),(1,1)):
    r,xs,zs=profil(dome,3.0,(op.bounds[2]-op.bounds[0])/2 if ax==0 else (op.bounds[3]-op.bounds[1])/2,ax); out['kalp'][f'profil{ax}']=r
# cihaz yarısı: 56x58 r6, kenar yuvarlaması re, çentik
notch=Polygon([(-18.5,-50),(18.5,-50),(18.5,-30),(0,-19),(-18.5,-30)]).buffer(-1.5).buffer(1.5)
def cihaz(re,h=9.25,n=30):
    parts=[]
    for i in range(n):
        z0=h*i/n; z1=h*(i+1)/n; d=0 if z1<h-re else re-np.sqrt(max(0,re*re-(z1-(h-re))**2))
        g=box(-28,-29,28,29).buffer(-6).buffer(6).buffer(-d).difference(notch)
        m=trimesh.creation.extrude_polygon(g,z1-z0); m.apply_translation([0,0,z0]); parts.append(m)
    return trimesh.boolean.union(parts)
C={re:cihaz(re) for re in (0,3.5)}
IC=box(-29,-30,29,30).buffer(-7).buffer(7).difference(notch.buffer(-1))
for k in 'ABCD':
    ic=trimesh.load(f'{R}/{k}_ic.stl'); op=IC.buffer(3.4)
    d={'esneme':esneme(ic,0,op),'yukseklik':float(ic.bounds[1][2])}
    for ax in (0,1):
        r,_,_=profil(ic,0,(op.bounds[2]-op.bounds[0])/2 if ax==0 else (op.bounds[3]-op.bounds[1])/2,ax); d[f'profil{ax}']=r
    for re,c in C.items(): d[f'disari_re{re}']=float(trimesh.boolean.difference([c,ic]).volume)
    out[k]=d
print(json.dumps(out,indent=1)); json.dump(out,open(R+'/olc.json','w'))
