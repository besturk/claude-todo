import sys,trimesh,numpy as np,matplotlib
matplotlib.use('Agg'); import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
V=sys.argv[1]; L=lambda n: trimesh.load(f'{V}/{n}.stl')
P={n:L(n) for n in ('levha','disi','erkek','kiskac','somun','kabuk')}
def draw(ax,ms,lim=None,el=35,az=-60):
    allv=[]
    for m,col,a in ms:
        m2=m.simplify_quadric_decimation(face_count=40000) if len(m.faces)>40000 else m
        t=m2.vertices[m2.faces]; n=m2.face_normals; L_=np.array([0.3,-0.5,0.8]); L_/=np.linalg.norm(L_)
        sh=0.35+0.65*np.clip(n@L_,0,1); c=np.array(matplotlib.colors.to_rgb(col))
        ax.add_collection3d(Poly3DCollection(t,facecolors=np.column_stack([np.outer(sh,c),np.full(len(sh),a)]),edgecolor='none')); allv.append(m.bounds)
    b=np.array(allv); lo=b[:,0].min(0); hi=b[:,1].max(0); c=(lo+hi)/2; r=(hi-lo).max()/2
    ax.set_xlim(c[0]-r,c[0]+r); ax.set_ylim(c[1]-r,c[1]+r); ax.set_zlim(c[2]-r,c[2]+r); ax.view_init(el,az); ax.set_axis_off()
O=V+'/'
fig=plt.figure(figsize=(16,4))
for i,(k,n,col) in enumerate((('Levha (2 adet, PLA)','levha','#e8e8e8'),('Dişi kalıp (PETG)','disi','#4a90d9'),('Erkek kalıp (PETG)','erkek','#d9824a'),('U kıskaç (2 adet)','kiskac','#c0392b'),('Askılı somun','somun','#f39c12'))):
    ax=fig.add_subplot(1,5,i+1,projection='3d'); m=P[n]; draw(ax,[(m,col,1)]); e=m.extents; ax.set_title(f'{k}\n{e[0]:.1f}×{e[1]:.1f}×{e[2]:.1f} mm',fontsize=10)
fig.tight_layout(); fig.savefig(O+'g_parcalar.png',dpi=85); plt.close(fig)
# yakın: levha köşe + dişi oluk
fig=plt.figure(figsize=(12,5))
ax=fig.add_subplot(1,2,1,projection='3d'); draw(ax,[(P['levha'],'#cccccc',1)],el=50,az=-60); ax.set_title('Levha: kafes + dar çerçeve + yarım vida')
ax=fig.add_subplot(1,2,2,projection='3d'); draw(ax,[(P['disi'],'#4a90d9',1)],el=55,az=-60); ax.set_title('Dişi kalıp: levha cebi + çerçeve oluğu (V dahil)')
fig.tight_layout(); fig.savefig(O+'g_yakin.png',dpi=85); plt.close(fig)
# kesitler
D=10; t=0.6; PF=2+D+t+0.1; TE=2.2; C=0.1
def Mz(z): T=np.eye(4); T[2,2]=-1; T[2,3]=z; return T
lv=P['levha'].copy(); lv.apply_transform(Mz(PF+t))
kb=P['kabuk'].copy(); kb.apply_transform(Mz(PF+t))
er=P['erkek'].copy(); T=np.eye(4); T[2,3]=-(TE+C); er.apply_transform(T); er.apply_transform(Mz(PF+t))
er_ust=er.copy(); er_ust.apply_translation([0,0,12])
def kes(ax,m,col,lbl,x=0.0):
    s=m.section(plane_origin=[x,0,0],plane_normal=[1,0,0])
    if s is None: return
    for e in s.discrete: ax.fill(e[:,1],e[:,2],color=col,alpha=.85,lw=0,label=lbl); lbl=None
fig,axs=plt.subplots(3,1,figsize=(11,11))
for ax,(tt,ms) in zip(axs,(('1) Levha cepte: çerçeve oluğa girmiş, levha kayamaz',[(P['disi'],'#4a90d9','dişi kalıp'),(lv,'#222','levha (0,6)'),(er_ust,'#d9824a','erkek kalıp (yukarıda)')]),
                          ('2) Erkek kalıp bastırıldı: levha iki kalıp arasında şekil aldı',[(P['disi'],'#4a90d9','dişi kalıp'),(kb,'#222','şekillenmiş kabuk'),(er,'#d9824a','erkek kalıp')]),)):
    for m,c,l in ms: kes(ax,m,c,l,x=3.0)
    ax.set_aspect('equal'); ax.set_title(tt+'  (kesit, boydan)'); ax.legend(loc='upper right',fontsize=8); ax.grid(alpha=.3)
# kapalı + cihaz
k2=P['kabuk'].copy(); k2.apply_transform(np.diag([-1,1,-1,1]))
c=L('../v4/cihaz'); c.apply_translation([0,0,-c.bounds[0][2]-9.25])
from shapely.geometry import Polygon
vp=Polygon([(-18.5,-50),(18.5,-50),(18.5,-30),(0,-19),(-18.5,-30)]).buffer(-1.5).buffer(1.5)
c2=c.copy(); c2.apply_translation([0,0,9.25]); c=trimesh.util.concatenate([c,c2]); vc=trimesh.creation.extrude_polygon(vp,30); vc.apply_translation([0,0,-15]); c=trimesh.boolean.difference([c,vc])
ax=axs[2]
for m,col,l in ((P['kabuk'],'#222','kabuklar'),(k2,'#222',None),(c,'#27ae60','Healy (18,5 mm)')): kes(ax,m,col,l,x=3.0)
ax.set_aspect('equal'); ax.set_title('3) Kapalı kılıf: iki kabuk + içinde Healy (kesit, boydan; altta V açık)'); ax.legend(loc='upper right',fontsize=8); ax.grid(alpha=.3)
fig.tight_layout(); fig.savefig(O+'g_kesit.png',dpi=85); plt.close(fig)
# kapalı 3D
ks=[]
for sx in (1,-1):
    k=P['kiskac'].copy(); T=np.array([[-1,0,0,32.7],[0,0,1,-3],[0,1,0,0],[0,0,0,1]],float)
    if sx<0: T=np.diag([-1,1,1,1])@T
    k.apply_transform(T); ks.append((k,'#c0392b',1))
sm=P['somun'].copy(); sm.apply_transform(trimesh.transformations.rotation_matrix(-np.pi/2,[1,0,0])); sm.apply_translation([0,30+2.4+0.5+0.5,0])
fig=plt.figure(figsize=(12,5))
for i,(el,az) in enumerate(((25,-60),(25,120))):
    ax=fig.add_subplot(1,2,i+1,projection='3d'); draw(ax,[(P['kabuk'],'#dddddd',.9),(k2,'#bbbbbb',.9),(sm,'#f39c12',1)]+ks,el=el,az=az)
fig.suptitle('Kapalı kılıf önizlemesi (iki kabuk + 2 kıskaç + somun)'); fig.tight_layout(); fig.savefig(O+'g_kapali.png',dpi=85)
