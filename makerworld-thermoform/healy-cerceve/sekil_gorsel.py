import sys,trimesh,numpy as np,json,matplotlib
matplotlib.use('Agg'); import matplotlib.pyplot as plt
from matplotlib.patches import Polygon as MP
from shapely.geometry import box,Polygon,Point
from shapely import affinity
R,K=sys.argv[1:3]; O=json.load(open(R+'/olc.json'))
notch=Polygon([(-18.5,-50),(18.5,-50),(18.5,-30),(0,-19),(-18.5,-30)]).buffer(-1.5).buffer(1.5)
def prof(m,z0,ax,lim):
    xs=np.linspace(-lim,lim,500); zs=[]
    for x in xs:
        o=[0,0,80]; o[ax]=x; h=m.ray.intersects_location([o],[[0,0,-1]])[0]; zs.append(max(h[:,2].max()-z0,0) if len(h) else 0)
    return xs,np.array(zs)
def cih_prof(re,lim,yarim=28):
    xs=np.linspace(-lim,lim,500); zs=[]
    for x in xs:
        d=yarim-abs(x)
        zs.append(0 if d<0 else (9.25 if d>=re else 9.25-re+np.sqrt(max(0,re*re-(re-d)**2))))
    return xs,np.array(zs)
# 1) profiller
fig,axs=plt.subplots(1,3,figsize=(18,4.6))
er=trimesh.load(K+'/erkek_net.stl'); er.apply_translation([-67.7603455,-60.0725861,0]); er=er.slice_plane([48,0,0],[-1,0,0]).slice_plane([-48,0,0],[1,0,0])
items=[('A','MEVCUT (basılan şekil)','#4a6fa5'),('B3','YUVARLAK OMUZ (r5, 4° eğim; kılıf her yönde ~1 mm büyür)','#c0702a')]
for ax,(k,t,col) in zip(axs[:2],items):
    m=trimesh.load(f'{R}/{k}_ic.stl'); xs,zs=prof(m,0,0,36)
    ax.fill_between(xs,0,zs,color=col,alpha=.35,label='erkek kalıp (kabuğun iç yüzü)'); ax.plot(xs,zs,color=col,lw=2)
    cx,cz=cih_prof(3.5,36); ax.plot(cx,cz,'g--',lw=2,label='Healy yarısı (kenar r≈3,5 varsayım)')
    d=O[k] if k in O else None
    fit={'A':'cihaz sığıyor (0 mm³ dışarıda)','B3':'cihaz sığıyor (3,8 mm³ — sınırda)'}[k]
    st={'A':(O['A']['esneme'],O['A']['profil0']),'B3':(None,None)}[k]
    ax.set_title(t+'\n'+fit,fontsize=10); ax.set_aspect('equal'); ax.set_ylim(-1,19); ax.grid(alpha=.3); ax.legend(fontsize=8,loc='upper right')
xs,zs=prof(er,3.0,0,50); axs[2].fill_between(xs,0,zs,color='#888',alpha=.4); axs[2].plot(xs,zs,color='#555',lw=2,label='kalp kalıbı')
axs[2].set_title('REFERANS: çalışan kalp kalıbı\nduvar ~3 mm, gerisi geniş yumuşak kubbe',fontsize=10); axs[2].set_aspect('equal'); axs[2].set_ylim(-1,19); axs[2].grid(alpha=.3); axs[2].legend(fontsize=8)
fig.suptitle('Kalıp kesitleri (ortadan, enine) — yeşil kesikli çizgi cihazın yarısı',fontsize=12); fig.tight_layout(); fig.savefig(R+'/s1_profil.png',dpi=80); plt.close(fig)
# 2) levha bölgeleri: hangi kısım yüz olur, hangisi duvar olur
IC=box(-29,-30,29,30).buffer(-7).buffer(7).difference(notch.buffer(-1))
VK=notch.buffer(-1).buffer(3)
P=IC.buffer(9).difference(VK)
yuz=IC.buffer(-2.35).difference(VK)        # kalıbın düz tepesine gelen kısım (az esner)
acik=IC.buffer(3.4)                          # çerçeve açıklığı
duvar=acik.difference(yuz).intersection(P)   # duvar + omuz olacak halka (çok esner)
bant=P.difference(IC.buffer(2.5))            # mevcut dolu bant
def fillg(ax,g,**kw):
    for q in (g.geoms if hasattr(g,'geoms') else [g]):
        if q.geom_type!='Polygon' or q.area<0.01: continue
        ax.add_patch(MP(np.array(q.exterior.coords),closed=True,**kw))
        for i in q.interiors: ax.add_patch(MP(np.array(i.coords),closed=True,fc='white',ec='none'))
def hexes(ax,region,a=4.0,col='#333',stretch=None):
    sat=a*np.sqrt(3)/2
    for j in range(-14,15):
        for i in range(-12,13):
            c=np.array([i*a+(0 if j%2==0 else a/2), j*sat])
            if not region.contains(Point(c)): continue
            th=np.radians(np.arange(30,390,60)); pts=np.c_[np.cos(th),np.sin(th)]*(a/2*0.82)
            if stretch is not None:
                f=stretch(c); pts=pts@f.T
            ax.add_patch(MP(pts+c,closed=True,fc='none',ec=col,lw=.7))
fig,axs=plt.subplots(1,3,figsize=(18,6.6))
for ax,(t,mode) in zip(axs,(('MEVCUT LEVHA: petek her yerde','mevcut'),('ALTERNATİF: petek sadece ön yüzde,\nduvara gelen kısım dolu','oneri'),('Levhanın hangi kısmı nereye gidiyor','harita'))):
    fillg(ax,P,fc='#f4e7d6',ec='#c08a4a',lw=1.5)
    if mode=='harita':
        fillg(ax,duvar,fc='#e74c3c',alpha=.55,ec='none'); fillg(ax,yuz,fc='#3498db',alpha=.45,ec='none'); fillg(ax,bant.difference(acik),fc='#95a5a6',alpha=.6,ec='none')
        ax.text(0,5,'ÖN YÜZ\n(az esner)',ha='center',fontsize=11,color='#1b4f72',weight='bold'); ax.text(0,33.2,'DUVAR + OMUZ (çok esner)',ha='center',fontsize=9,color='#922b21',weight='bold')
        ax.text(0,40.5,'çerçeve altında, düz kalır',ha='center',fontsize=8,color='#444')
    elif mode=='mevcut':
        fillg(ax,bant,fc='#d9c2a3',ec='none'); hexes(ax,IC.buffer(2.5).difference(VK).buffer(-0.8))
    else:
        fillg(ax,P.difference(yuz),fc='#d9c2a3',ec='none'); hexes(ax,yuz.buffer(-0.8))
    ax.set_xlim(-42,42); ax.set_ylim(-42,44); ax.set_aspect('equal'); ax.axis('off'); ax.set_title(t,fontsize=11)
fig.tight_layout(rect=[0,0,1,0.93]); fig.savefig(R+'/s2_levha.png',dpi=80); plt.close(fig)
# 3) şekillenince (temsili, üstten bakış)
def stretch_ring(c):
    # duvar halkasında petekler dışa doğru uzar (temsili)
    d=IC.exterior.distance(Point(c)); inside=IC.contains(Point(c))
    if inside and IC.buffer(-2.35).contains(Point(c)): return np.eye(2)
    v=np.array(c)/max(np.linalg.norm(c),1e-6); n=np.outer(v,v); return np.eye(2)+1.8*n
fig,axs=plt.subplots(1,2,figsize=(13,6.6))
for ax,(t,mode) in zip(axs,(('MEVCUT: şekillenmiş kabuk (temsili)\nkenara gelen petekler uzayıp yamuluyor','mevcut'),('ALTERNATİF: şekillenmiş kabuk (temsili)\nön yüzdeki petekler düzgün, yan duvar düz dolu','oneri'))):
    fillg(ax,IC.buffer(1),fc='#e9d3b5',ec='#a0703a',lw=1.5); fillg(ax,IC.buffer(-2.35).difference(VK),fc='#f6ecdf',ec='none')
    if mode=='mevcut': hexes(ax,IC.buffer(0.5).difference(VK).buffer(-0.5),stretch=stretch_ring)
    else: hexes(ax,IC.buffer(-2.35).difference(VK).buffer(-0.8))
    ax.set_xlim(-34,34); ax.set_ylim(-34,34); ax.set_aspect('equal'); ax.axis('off'); ax.set_title(t,fontsize=11)
fig.tight_layout(); fig.savefig(R+'/s3_sonuc.png',dpi=80); plt.close(fig)
