import sys,trimesh,numpy as np,matplotlib
matplotlib.use('Agg'); import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
from shapely.geometry import box,Polygon
S=sys.argv[1]; L=lambda n: trimesh.load(f'{S}/{n}.stl')
def draw(ax,ms,el=30,az=-60,zoom=1.0,center=None):
    bs=[]
    for m,col,a in ms:
        t=m.vertices[m.faces]; n=m.face_normals; l=np.array([0.3,-0.5,0.8]); l/=np.linalg.norm(l); sh=0.35+0.65*np.clip(n@l,0,1)
        ax.add_collection3d(Poly3DCollection(t,facecolors=np.column_stack([np.outer(sh,matplotlib.colors.to_rgb(col)),np.full(len(sh),a)]),edgecolor='none')); bs.append(m.bounds)
    b=np.array(bs); lo=b[:,0].min(0); hi=b[:,1].max(0); c=(lo+hi)/2 if center is None else np.array(center); r=(hi-lo).max()/2/zoom
    ax.set_xlim(c[0]-r,c[0]+r); ax.set_ylim(c[1]-r,c[1]+r); ax.set_zlim(c[2]-r,c[2]+r); ax.view_init(el,az); ax.set_axis_off()
di,er,ey,lv,k,ks,sm=L('disi'),L('erkek'),L('erkek_yerinde'),L('levha'),L('kabuk'),L('kiskac'),L('somun')
Z0=18.1; kb=k.copy(); kb.apply_translation([0,0,Z0])
k2=k.copy(); k2.apply_transform(trimesh.transformations.rotation_matrix(np.pi,[0,1,0]))
notch=Polygon([(-18.5,-60),(18.5,-60),(18.5,-30),(0,-19),(-18.5,-30)]).buffer(-1.5).buffer(1.5)
cih=trimesh.creation.extrude_polygon(box(-28,-29,28,29).buffer(-6).buffer(6).difference(notch),18.5); cih.apply_translation([0,0,-9.25])
# 1 parçalar
fig=plt.figure(figsize=(18,4.5))
for i,(m,t,c) in enumerate(((di,'Dişi kalıp (PETG)','#8a95a8'),(er,'Erkek kalıp (PETG)','#d9824a'),(lv,'Levha ×2 (PLA)','#f0a050'),(ks,'Kıskaç ×2','#c0392b'),(sm,'Askılı somun','#e8b020'))):
    ax=fig.add_subplot(1,5,i+1,projection='3d'); draw(ax,[(m,c,1)],el=35); e=m.extents; ax.set_title(f'{t}\n{e[0]:.1f} × {e[1]:.1f} × {e[2]:.1f} mm',fontsize=10)
fig.tight_layout(); fig.savefig(S+'/t1_parcalar.png',dpi=72); plt.close(fig)
# 2 kesit x=0: V (sol) ve vida (sağ), kalıplar kapalı
fig,ax=plt.subplots(figsize=(15,5))
for m,c,l in ((di,'#8a95a8','dişi kalıp'),(ey,'#d9824a','erkek kalıp'),(kb,'#222','levha (şekillenmiş) + yarım vida')):
    s=m.section(plane_origin=[0.4,0,0],plane_normal=[1,0,0])
    for e in s.discrete: ax.fill(e[:,1],e[:,2],color=c,alpha=.9,lw=0,label=l); l=None
ax.set_aspect('equal'); ax.grid(alpha=.3); ax.legend(fontsize=9,loc='lower center'); ax.set_xlim(-46,50); ax.set_ylim(-1,23)
ax.set_title('Kesit (ortadan, boyuna) — solda V: levha önceden kesik, kalıpta levha yok · sağda vida: yatağında, erkek kalıbın tabanı üstünü bastırıyor')
fig.tight_layout(); fig.savefig(S+'/t2_kesit.png',dpi=72); plt.close(fig)
# 3 basma
lvy=lv.copy(); lvy.apply_transform(np.diag([1,1,-1,1])); lvy.apply_translation([0,0,Z0]); eu=ey.copy(); eu.apply_translation([0,0,22])
fig=plt.figure(figsize=(17,5.5))
for i,(t,ms) in enumerate((('1) Isınmış levha kaburgası aşağıda dişinin ağzına;\nkaburga oluğa, vida yatağına oturur',[(di,'#8a95a8',1),(lvy,'#f0a050',1),(eu,'#d9824a',.45)]),('2) Erkek kalıp bastırılır,\ntabanı dişiye değene kadar',[(di,'#8a95a8',1),(kb,'#f0a050',1),(ey,'#d9824a',.4)]),('3) Çıkan kabuk: V önceden açık',[(k,'#f0a050',1)]))):
    ax=fig.add_subplot(1,3,i+1,projection='3d'); draw(ax,ms,el=28,az=-60,zoom=1.1); ax.set_title(t,fontsize=11)
fig.tight_layout(); fig.savefig(S+'/t3_basma.png',dpi=72); plt.close(fig)
# 4 kapalı kılıf
q=[]
for sx in (1,-1):
    m=ks.copy(); T=np.array([[-1,0,0,62.4/2+4.125+1.6],[0,0,1,-2.5],[0,1,0,0],[0,0,0,1]],float)
    if sx<0: T=np.diag([-1,1,1,1])@T
    m.apply_transform(T); q.append((m,'#c0392b',1))
s2=sm.copy(); s2.apply_transform(trimesh.transformations.rotation_matrix(-np.pi/2,[1,0,0])); s2.apply_translation([0,34.7+0.6,0])
fig=plt.figure(figsize=(17,5.8))
for i,(el,az,z,cen) in enumerate(((22,-60,1.0,None),(8,-90,1.5,[0,-20,0]),(75,-90,1.0,None))):
    ax=fig.add_subplot(1,3,i+1,projection='3d'); draw(ax,[(cih,'#27ae60',1),(k,'#f3b070',.9),(k2,'#e89a50',.9),(s2,'#e8b020',1)]+q,el=el,az=az,zoom=z,center=cen)
axs=fig.axes; axs[1].set_title('V tarafı: çentik ve girişler açık',fontsize=11)
fig.suptitle('Kapalı kılıf: iki kabuk + Healy (yeşil) + 2 kıskaç + askılı somun'); fig.tight_layout(); fig.savefig(S+'/t4_kapali.png',dpi=72); plt.close(fig)
