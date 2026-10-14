import sys,re,numpy as np,trimesh,xml.etree.ElementTree as ET
W=sys.argv[1]; C='{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}'; Pn='{http://schemas.microsoft.com/3dmanufacturing/production/2015/06}'
d=W+'/honeycombAMS'
top=ET.parse(d+'/3D/3dmodel.model').getroot()
ms=open(d+'/Metadata/model_settings.config').read()
pname=dict(re.findall(r'<part id="(\d+)" subtype="\w+"[^>]*>\s*<metadata key="name" value="([^"]+)"',ms))
cache={}
def mesh(path,oid):
    if path not in cache:
        r=ET.parse(d+path).getroot(); cache[path]={}
        for o in r.iter(C+'object'):
            v=np.array([[float(x.get(k)) for k in 'xyz'] for x in o.iter(C+'vertex')]); f=np.array([[int(x.get(k)) for k in ('v1','v2','v3')] for x in o.iter(C+'triangle')])
            cache[path][o.get('id')]=trimesh.Trimesh(v,f,process=True)
    return cache[path][oid].copy()
def T(s):
    a=[float(x) for x in s.split()]; M=np.eye(4); M[:3,:3]=np.array(a[:9]).reshape(3,3).T; M[:3,3]=a[9:]; return M
items={i.get('objectid'):T(i.get('transform')) for i in top.iter(C+'item')}
for o in top.find(C+'resources').iter(C+'object'):
    comps=o.find(C+'components')
    if comps is None: continue
    for c in comps:
        m=mesh(c.get(Pn+'path'),c.get('objectid')); m.apply_transform(T(c.get('transform'))); m.apply_transform(items[o.get('id')])
        nm=pname.get(c.get('objectid'),'?').replace('thermoformed hello kitty - ','').replace('.STL','').replace(' ','_')
        m.export(f'{W}/p_{nm}.stl'); print(f'{nm:38s} wt={m.is_watertight} ext={np.round(m.extents,2)} zmin={m.bounds[0][2]:.2f}')
