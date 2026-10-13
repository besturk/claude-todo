import sys,trimesh,numpy as np,matplotlib
matplotlib.use('Agg'); import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
from shapely.geometry import Polygon, box
from shapely.ops import unary_union
R=sys.argv[1]
M={y:{n:trimesh.load(f'{R}/{y}/{n}.stl') for n in ('levha','erkek','cerceve','kabuk')} for y in ('taban','ust')}
BAS={'taban':'MEVCUT (basılan)','ust':'ÖNERİ'}
# cihaz: 56x58 r6, V çentiği, 18.5 mm, ortası z=0
cp=box(-28,-29,28,29).buffer(-6).buffer(6)
notch=Polygon([(-18.5,-50),(18.5,-50),(18.5,-30),(0,-19),(-18.5,-30)]).buffer(-1.5).buffer(1.5)
cih=trimesh.creation.extrude_polygon(cp.difference(notch),18.5); cih.apply_translation([0,0,-9.25])
def draw(ax,ms,el,az,zoom=1.0,center=None):
    bs=[]
    for m,col,a in ms:
        t=m.vertices[m.faces]; n=m.face_normals; l=np.array([0.3,-0.6,0.7]); l/=np.linalg.norm(l)
        sh=0.35+0.65*np.clip(n@l,0,1); c=np.array(matplotlib.colors.to_rgb(col))
        ax.add_collection3d(Poly3DCollection(t,facecolors=np.column_stack([np.outer(sh,c),np.full(len(sh),a)]),edgecolor='none')); bs.append(m.bounds)
    b=np.array(bs); lo=b[:,0].min(0); hi=b[:,1].max(0); c=(lo+hi)/2 if center is None else np.array(center); r=(hi-lo).max()/2/zoom
    ax.set_xlim(c[0]-r,c[0]+r); ax.set_ylim(c[1]-r,c[1]+r); ax.set_zlim(c[2]-r,c[2]+r); ax.view_init(el,az); ax.set_axis_off()
def sec2d(m,z):
    s=m.section(plane_origin=[0,0,z],plane_normal=[0,0,1]); p,_=s.to_2D(to_2D=np.eye(4)); return unary_union(p.polygons_full)
def ciz(ax,g,col,lbl,lw=1.6,fill=None):
    for q in (g.geoms if hasattr(g,'geoms') else [g]):
        if fill: ax.fill(*q.exterior.xy,color=fill,alpha=.35,lw=0)
        for r in [q.exterior]+list(q.interiors):
            x,y=r.xy; ax.plot(x,y,color=col,lw=lw,label=lbl); lbl=None
# 1) üstten V bölgesi
fig,axs=plt.subplots(1,2,figsize=(15,6.3))
for ax,y in zip(axs,('taban','ust')):
    ciz(ax,sec2d(M[y]['erkek'],5),'#1f77b4','erkek kalıp (cihaz şekli)',fill='#1f77b4')
    ciz(ax,sec2d(M[y]['levha'],0.5),'#e08a30','levha kesimi',lw=2.2)
    ciz(ax,sec2d(M[y]['cerceve'],1.5 if y=='taban' else 11.5),'#9b59e6','çerçeve (alt yüzü)' if y=='taban' else 'çerçeve + V dudağı (z=11,5)')
    ax.set_xlim(-30,30); ax.set_ylim(-44,-8); ax.set_aspect('equal'); ax.grid(alpha=.3); ax.legend(fontsize=8,loc='upper right'); ax.set_title(BAS[y]+' — V bölgesi üstten',fontsize=12)
fig.tight_layout(); fig.savefig(R+'/k1_ustten.png',dpi=80); plt.close(fig)
# 2) kesit: sol eğik V duvarına dik düzlem (USB'nin olduğu yüz)
ang=np.arctan2(11,18.5); nrm=np.array([np.cos(ang),-np.sin(ang)*-1,0]); 
d=np.array([-np.sin(ang)*-1,np.cos(ang),0])
# düzlem: V sol kenarının ortasından geçen, kenara dik
mid=np.array([-9.25,-24.5,0]); edge=np.array([18.5,11,0])/np.linalg.norm([18.5,11]); pn=edge  # normal = kenar yönü -> düzlem kenara dik
fig,axs=plt.subplots(1,2,figsize=(15,4.8))
for ax,y in zip(axs,('taban','ust')):
    for n,col,lb,a in (('erkek','#8a95a8','erkek kalıp',.9),('kabuk','#f08a20','levha (şekillenmiş)',1),('cerceve','#9b59e6','çerçeve',.6)):
        s=M[y][n].section(plane_origin=mid,plane_normal=pn)
        if s is None: continue
        perp=np.cross([0,0,1],pn)
        for e in s.discrete:
            u=(e-mid)@perp; ax.fill(u,e[:,2],color=col,alpha=a,lw=0,label=lb); lb=None
    ax.set_xlim(-22,14); ax.set_ylim(-4,14); ax.set_aspect('equal'); ax.grid(alpha=.3); ax.legend(fontsize=8,loc='upper left')
    ax.set_title(BAS[y]+' — V\'nin sol yüzüne dik kesit (USB burada)\nsağ: cihazın içi · sol: çentik',fontsize=11)
fig.tight_layout(); fig.savefig(R+'/k2_kesit.png',dpi=80); plt.close(fig)
# 3) kapalı kılıf + cihaz: aynı dik kesit
fig,axs=plt.subplots(1,2,figsize=(15,5.2))
for ax,y in zip(axs,('taban','ust')):
    kb=M[y]['kabuk']; k2=kb.copy(); k2.apply_transform(np.diag([-1,1,-1,1]))
    perp=np.cross([0,0,1],pn)
    for m,col,lb,al in ((cih,'#27ae60','Healy',.55),(kb,'#f08a20','kabuklar',1),(k2,'#f08a20',None,1)):
        s2=m.section(plane_origin=mid,plane_normal=pn)
        if s2 is None: continue
        for e in s2.discrete:
            u=(e-mid)@perp; ax.fill(u,e[:,2],color=col,alpha=al,lw=0,label=lb); lb=None
    ax.add_patch(plt.Rectangle((-0.6,-2.5),0.5,5,color='black')); ax.text(-1,3.2,'USB / soket\nburada',fontsize=8,ha='right')
    ax.set_xlim(-16,14); ax.set_ylim(-13,13); ax.set_aspect('equal'); ax.grid(alpha=.3); ax.legend(fontsize=8,loc='upper left')
    ax.set_title(BAS[y]+' — kapalı kılıf, V yüzüne dik kesit\n'+('girişlerin önü kabukla kapalı' if y=='taban' else 'girişlerin önü açık'),fontsize=11)
fig.tight_layout(); fig.savefig(R+'/k3_kapali.png',dpi=80); plt.close(fig)
# 4) çerçeve V bölgesi 3D (kullanım konumu) + erkek
fig=plt.figure(figsize=(15,6))
for i,y in enumerate(('taban','ust')):
    ax=fig.add_subplot(1,2,i+1,projection='3d'); draw(ax,[(M[y]['erkek'],'#8a95a8',1),(M[y]['kabuk'],'#f08a20',1),(M[y]['cerceve'],'#9b59e6',.75)],el=35,az=-70,zoom=1.7,center=[0,-25,5])
    ax.set_title(BAS[y]+' — çerçeve indirilmiş, V bölgesi',fontsize=11)
fig.tight_layout(); fig.savefig(R+'/k4_cerceve.png',dpi=80); plt.close(fig)
