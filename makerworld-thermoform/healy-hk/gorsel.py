import sys,trimesh,numpy as np,matplotlib
matplotlib.use('Agg'); import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
S,H=sys.argv[1:3]; L=lambda d,n: trimesh.load(f'{d}/{n}.stl')
def draw(ax,ms,el=30,az=-60,zoom=1.0):
    bs=[]
    for m,col,a in ms:
        t=m.vertices[m.faces]; n=m.face_normals; l=np.array([0.3,-0.5,0.8]); l/=np.linalg.norm(l); sh=0.35+0.65*np.clip(n@l,0,1)
        ax.add_collection3d(Poly3DCollection(t,facecolors=np.column_stack([np.outer(sh,matplotlib.colors.to_rgb(col)),np.full(len(sh),a)]),edgecolor='none')); bs.append(m.bounds)
    b=np.array(bs); lo=b[:,0].min(0); hi=b[:,1].max(0); c=(lo+hi)/2; r=(hi-lo).max()/2/zoom
    ax.set_xlim(c[0]-r,c[0]+r); ax.set_ylim(c[1]-r,c[1]+r); ax.set_zlim(c[2]-r,c[2]+r); ax.view_init(el,az); ax.set_axis_off()
di=L(S,'disi'); er=L(S,'erkek'); ey=L(S,'erkek_yerinde'); lv=L(S,'levha'); kb=L(S,'kabuk_yerinde'); k0=L(S,'kabuk')
# 1) kesit karşılaştırması: Hello Kitty ve Healy (aynı ölçek)
B=L(H,'al_B'); T=L(H,'al_T')
fig,axs=plt.subplots(1,2,figsize=(18,5))
for ax,(t,ms) in zip(axs,(('Hello Kitty kalıbı (ölçülen)',[(B,'#8a95a8','dişi'),(T,'#d9824a','erkek')]),('Healy — aynı yöntem (yeni)',[(di,'#8a95a8','dişi'),(ey,'#d9824a','erkek'),(kb,'#222','şekillenmiş levha 0,8')]))):
    for m,c,l in ms:
        s=m.section(plane_origin=[0,0,0],plane_normal=[0,1,0])
        for e in s.discrete: ax.fill(e[:,0],e[:,2],color=c,alpha=.9,lw=0,label=l); l=None
    ax.set_xlim(-62,62); ax.set_ylim(-1,25); ax.set_aspect('equal'); ax.grid(alpha=.3); ax.legend(fontsize=9,loc='lower center'); ax.set_title(t)
fig.tight_layout(); fig.savefig(S+'/h1_kesit.png',dpi=75); plt.close(fig)
# 2) kenar yakın plan
fig,ax=plt.subplots(figsize=(10,5.5))
for m,c,l in ((di,'#8a95a8','dişi kalıp'),(ey,'#d9824a','erkek kalıp'),(kb,'#222','levha (0,8) + kaburga')):
    s=m.section(plane_origin=[0,0,0],plane_normal=[0,1,0])
    for e in s.discrete: ax.fill(e[:,0],e[:,2],color=c,alpha=.9,lw=0,label=l); l=None
ax.set_xlim(14,43); ax.set_ylim(-0.5,22); ax.set_aspect('equal'); ax.grid(alpha=.3); ax.legend(fontsize=9,loc='lower right'); ax.set_title('Healy kenar yakın plan: yastık kenarı R10, kaburga oluğa oturmuş, levha iki kalıp arasında')
fig.tight_layout(); fig.savefig(S+'/h2_kenar.png',dpi=75); plt.close(fig)
# 3) parçalar
fig=plt.figure(figsize=(15,4.6))
for i,(m,t,c) in enumerate(((di,'Dişi kalıp (PETG)','#8a95a8'),(er,'Erkek kalıp (PETG, baskı konumu)','#d9824a'),(lv,'Levha ×2 (PLA, 0,8 mm + kaburga)','#f0a050'))):
    ax=fig.add_subplot(1,3,i+1,projection='3d'); draw(ax,[(m,c,1)],el=35); e=m.extents; ax.set_title(f'{t}\n{e[0]:.1f} × {e[1]:.1f} × {e[2]:.1f} mm',fontsize=10)
fig.tight_layout(); fig.savefig(S+'/h3_parcalar.png',dpi=75); plt.close(fig)
# 4) basma sırası
lvy=lv.copy(); lvy.apply_transform(np.diag([1,1,-1,1])); lvy.apply_translation([0,0,18.3-1.0+0.8])
eu=ey.copy(); eu.apply_translation([0,0,22])
fig=plt.figure(figsize=(17,5.5))
for i,(t,ms) in enumerate((('1) Isınmış levha, kaburgası aşağıda,\ndişinin ağzındaki oluğa oturur',[(di,'#8a95a8',1),(lvy,'#f0a050',1),(eu,'#d9824a',.5)]),('2) Erkek kalıp üstten bastırılır;\ntabanı dişiye değene kadar',[(di,'#8a95a8',1),(kb,'#f0a050',1),(ey,'#d9824a',.45)]),('3) Soğuyunca çıkan kabuk',[(k0,'#f0a050',1)]))):
    ax=fig.add_subplot(1,3,i+1,projection='3d'); draw(ax,ms,el=25,az=-55,zoom=1.1); ax.set_title(t,fontsize=11)
fig.tight_layout(); fig.savefig(S+'/h4_basma.png',dpi=75); plt.close(fig)
