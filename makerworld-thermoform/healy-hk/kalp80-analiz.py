import sys,re,numpy as np,trimesh,xml.etree.ElementTree as ET
W=sys.argv[1]; ns={'c':'http://schemas.microsoft.com/3dmanufacturing/core/2015/02'}
def load(path):
    r=ET.parse(path).getroot(); out={}
    for o in r.find('c:resources',ns).findall('c:object',ns):
        m=o.find('c:mesh',ns)
        if m is None: continue
        v=np.array([[float(x.get(k)) for k in 'xyz'] for x in m.find('c:vertices',ns)])
        f=np.array([[int(x.get(k)) for k in ('v1','v2','v3')] for x in m.find('c:triangles',ns)])
        out[o.get('id')]=trimesh.Trimesh(v,f,process=True)
    return out
A=load(W+'/p/3D/Objects/object_1.model'); names={'1':'levha','2':'bant','3':'kulakcik','4':'kaburga'}
off={'1':(0,0,0.5),'2':(0,0,0.5),'3':(0,43.9757,0.5),'4':(0,0,2.745)}
for k,m in A.items():
    m.apply_translation(off[k]); A[k]=m
    print(names[k], 'wt',m.is_watertight,'bounds',np.round(m.bounds,2).tolist(),'ext',np.round(m.extents,2))
    m.export(f'{W}/{names[k]}.stl')
for k,n in (('9','kiskac'),):
    pass
B=load(W+'/p/3D/Objects/object_9.model'); C=load(W+'/p/3D/Objects/object_11.model')
for d,n in ((B,'yan-kiskac'),(C,'kilit-pimi')):
    for k,m in d.items(): print(n,np.round(m.extents,2),'wt',m.is_watertight); m.export(f'{W}/{n}.stl')
