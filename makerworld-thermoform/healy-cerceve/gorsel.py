import sys,trimesh,numpy as np,matplotlib
matplotlib.use('Agg'); import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
from shapely.ops import unary_union
V=sys.argv[1]; L=lambda n: trimesh.load(f'{V}/{n}.stl')
P={n:L(n) for n in ('levha','erkek','cerceve','cerceve_baski','kiskac','somun','kabuk','ic')}
RENK={'erkek':'#8a95a8','cerceve':'#9b59e6','levha':'#f0a050','kabuk':'#f0a050','kaburga':'#d62020','kiskac':'#c0392b','somun':'#e8b020','cihaz':'#27ae60'}
def draw(ax,ms,el=30,az=-60,zoom=1.0):
    bs=[]
    for m,col,a in ms:
        m2=m
        t=m2.vertices[m2.faces]; n=m2.face_normals; l=np.array([0.3,-0.5,0.8]); l/=np.linalg.norm(l)
        sh=0.35+0.65*np.clip(n@l,0,1); c=np.array(matplotlib.colors.to_rgb(col))
        ax.add_collection3d(Poly3DCollection(t,facecolors=np.column_stack([np.outer(sh,c),np.full(len(sh),a)]),edgecolor='none')); bs.append(m.bounds)
    b=np.array(bs); lo=b[:,0].min(0); hi=b[:,1].max(0); c=(lo+hi)/2; r=(hi-lo).max()/2/zoom
    ax.set_xlim(c[0]-r,c[0]+r); ax.set_ylim(c[1]-r,c[1]+r); ax.set_zlim(c[2]-r,c[2]+r); ax.view_init(el,az); ax.set_axis_off()
# 1 parçalar
fig=plt.figure(figsize=(17,4))
for i,(k,n,col) in enumerate((('Erkek kalıp (PETG)','erkek',RENK['erkek']),('Oluklu çerçeve (PETG, baskı konumu)','cerceve_baski',RENK['cerceve']),('Levha ×2 (PLA, 1 mm)','levha',RENK['levha']),('Yan kıskaç ×2','kiskac',RENK['kiskac']),('Askılı somun','somun',RENK['somun']))):
    ax=fig.add_subplot(1,5,i+1,projection='3d'); m=P[n]; draw(ax,[(m,col,1)],el=35); e=m.extents; ax.set_title(f'{k}\n{e[0]:.1f} × {e[1]:.1f} × {e[2]:.1f} mm',fontsize=10)
fig.tight_layout(); fig.savefig(V+'/g1_parcalar.png',dpi=80); plt.close(fig)
# 2 üstten + kesitler (kalp-80-ref önizlemesi gibi)
def sec2d(m,z):
    s=m.section(plane_origin=[0,0,z],plane_normal=[0,0,1]); p,_=s.to_2D(to_2D=np.eye(4)); return unary_union(p.polygons_full)
def ciz(ax,g,col,lbl,fill=False,lw=1.4):
    gs=g.geoms if hasattr(g,'geoms') else [g]
    for q in gs:
        for r in [q.exterior]+list(q.interiors):
            x,y=r.xy; ax.plot(x,y,color=col,lw=lw,label=lbl); lbl=None
fig=plt.figure(figsize=(18,6.2)); gs=fig.add_gridspec(1,3,width_ratios=[1.05,1.3,1.3])
ax=fig.add_subplot(gs[0])
ciz(ax,sec2d(P['erkek'],-1.5),'#444','erkek kalıp tabanı'); ciz(ax,sec2d(P['cerceve'],7),'#9b59e6','çerçeve'); ciz(ax,sec2d(P['levha'],0.5),'#e08a30','levha')
ciz(ax,sec2d(P['levha'],3),'#d62020','kilit kaburgası',lw=0.8); ciz(ax,sec2d(P['ic'],0.3),'#1f77b4','cihaz yuvası (şekil)')
for s in (-1,1): ax.add_patch(plt.Circle((s*float(P['erkek'].bounds[1][0]-1-9.5- (0)),0),4,color='#555'))
ax.set_aspect('equal'); ax.legend(fontsize=7,loc='lower left'); ax.set_title('Üstten'); ax.grid(alpha=.3)
def kesit(ax,normal,title):
    for n,col,lb in (('erkek',RENK['erkek'],'erkek kalıp (PETG)'),('kabuk',RENK['kabuk'],'levha (PLA)'),('cerceve',RENK['cerceve'],'çerçeve (oluklu)')):
        s=P[n].section(plane_origin=[0,0,0],plane_normal=normal)
        if s is None: continue
        for e in s.discrete:
            xy=e[:,1] if normal[0] else e[:,0]
            ax.fill(xy,e[:,2],color=col,alpha=.85 if n!='cerceve' else .7,lw=0,label=lb); lb=None
    ax.set_aspect('equal'); ax.set_title(title); ax.grid(alpha=.3); ax.set_ylabel('z (mm)'); ax.legend(fontsize=7,loc='upper right')
kesit(fig.add_subplot(gs[1]),[0,1,0],'Kesit y = 0 (direklerden, çerçeve oturmuş)')
kesit(fig.add_subplot(gs[2]),[1,0,0],'Kesit x = 0 (altta V, üstte yarım vida)')
fig.suptitle('Healy — çerçeve yöntemi (kalp-80-ref ölçüleriyle)'); fig.tight_layout(); fig.savefig(V+'/g2_ustten_kesit.png',dpi=80); plt.close(fig)
# 3 basma sırası 3D
er,ce,kb,lv=P['erkek'],P['cerceve'],P['kabuk'],P['levha']
fig=plt.figure(figsize=(17,5.5))
c_up=ce.copy(); c_up.apply_translation([0,0,D:=14]); l_up=lv.copy(); l_up.apply_translation([0,0,14])
for i,(tt,ms) in enumerate((('1) Isınmış levha çerçevenin oluğunda,\nçerçeve direklere geçiyor',[(er,RENK['erkek'],1),(l_up,RENK['levha'],1),(c_up,RENK['cerceve'],.55)]),
                             ('2) Çerçeve indi: levha şeklin üstüne gerildi,\nkenarı tabana basıldı',[(er,RENK['erkek'],1),(kb,RENK['kabuk'],1),(ce,RENK['cerceve'],.55)]),
                             ('3) Soğuyunca çıkan kabuk',[(kb,RENK['kabuk'],1)]))):
    ax=fig.add_subplot(1,3,i+1,projection='3d'); draw(ax,ms,el=28,az=-55,zoom=1.15); ax.set_title(tt,fontsize=11)
fig.tight_layout(); fig.savefig(V+'/g3_basma.png',dpi=80); plt.close(fig)
# 4 kapalı kılıf
k2=kb.copy(); k2.apply_transform(np.diag([-1,1,-1,1]))
ks=[]
for s in (1,-1):
    k=P['kiskac'].copy(); T=np.array([[-1,0,0,38+1.6],[0,0,1,-2.5],[0,1,0,0],[0,0,0,1]],float)
    if s<0: T=np.diag([-1,1,1,1])@T
    k.apply_transform(T); ks.append((k,RENK['kiskac'],1))
sm=P['somun'].copy(); sm.apply_transform(trimesh.transformations.rotation_matrix(-np.pi/2,[1,0,0])); sm.apply_translation([0,37.2+0.5,0])
fig=plt.figure(figsize=(15,5.5))
for i,(el,az) in enumerate(((22,-60),(22,120),(80,-90))):
    ax=fig.add_subplot(1,3,i+1,projection='3d'); draw(ax,[(kb,'#f3b070',1),(k2,'#e89a50',1),(sm,RENK['somun'],1)]+ks,el=el,az=az,zoom=1.1)
fig.suptitle('Kapalı kılıf: iki kabuk + 2 yan kıskaç + askılı somun'); fig.tight_layout(); fig.savefig(V+'/g4_kapali.png',dpi=80); plt.close(fig)
