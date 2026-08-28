# Terminal-Wallpaper 2560x1600 im vhstack-Logo-Stil, Catppuccin-Mocha-Palette.
# Erzeugt vhstack.bg.svg; JPG daraus rendern, z. B.:
#   chromium --headless=new --screenshot=bg.png --window-size=2560,1600 file://.../bg.html
#   python3 -c "from PIL import Image; Image.open('bg.png').convert('RGB').save('vhstack.bg.jpg', quality=92)"
import os
import numpy as np, os
from scipy.spatial import Delaunay
rng = np.random.default_rng(7)
W, H = 2560, 1600; CX, CY = W/2, H/2; R = 400
light = np.array([-0.5, -0.6, 0.65]); light /= np.linalg.norm(light)

def sphere_pts(N, jitter):
    i = np.arange(N)+0.5; phi = np.arccos(1-2*i/N); th = np.pi*(1+5**0.5)*i
    p = np.stack([np.cos(th)*np.sin(phi), np.sin(th)*np.sin(phi), np.cos(phi)],1)
    p += rng.normal(0,jitter,p.shape); p /= np.linalg.norm(p,axis=1)[:,None]
    a=np.radians(20); Rx=np.array([[1,0,0],[0,np.cos(a),-np.sin(a)],[0,np.sin(a),np.cos(a)]])
    return p @ Rx.T

svg=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">',
f'''<defs>
  <radialGradient id="bg" cx="50%" cy="45%" r="75%">
    <stop offset="0" stop-color="#1e1e2e"/><stop offset="1" stop-color="#11111b"/>
  </radialGradient>
  <radialGradient id="body" cx="40%" cy="35%" r="70%">
    <stop offset="0" stop-color="#15292f"/><stop offset="0.7" stop-color="#0e1a1a"/><stop offset="1" stop-color="#0b1213"/>
  </radialGradient>
  <radialGradient id="rim" cx="50%" cy="50%" r="50%">
    <stop offset="0.88" stop-color="#3aa8b8" stop-opacity="0"/><stop offset="1" stop-color="#3aa8b8" stop-opacity="0.25"/>
  </radialGradient>
  <radialGradient id="halo" cx="50%" cy="50%" r="50%">
    <stop offset="0.6" stop-color="#2c8f9c" stop-opacity="0.10"/><stop offset="1" stop-color="#2c8f9c" stop-opacity="0"/>
  </radialGradient>
  <filter id="glow" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="2.5"/></filter>
  <filter id="softglow" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="1.2"/></filter>
</defs>
<rect width="{W}" height="{H}" fill="url(#bg)"/>''']

# --- background network (sparse, very faint)
P = np.c_[rng.uniform(-100,W+100,140), rng.uniform(-100,H+100,140)]
tri = Delaunay(P).simplices
svg.append('<g stroke="#2f7f86" stroke-width="1" fill="none" stroke-opacity="0.10">')
for t in tri:
    pts=" ".join(f"{P[k,0]:.0f},{P[k,1]:.0f}" for k in t); svg.append(f'<polygon points="{pts}"/>')
svg.append('</g><g fill="#5fd0dc" fill-opacity="0.35" filter="url(#softglow)">')
for x,y in P[rng.random(len(P))<0.45]: svg.append(f'<circle cx="{x:.0f}" cy="{y:.0f}" r="2.2"/>')
svg.append('</g>')

# --- outer wire shell (like original halo network)
Q = sphere_pts(90, 0.12)*rng.uniform(1.25,1.65,(90,1))
x,y = CX+Q[:,0]*R, CY+Q[:,1]*R
tri = Delaunay(np.c_[x,y]).simplices
svg.append('<g stroke="#3aa8b8" fill="none" stroke-width="1">')
for t in tri:
    d=(Q[t,2].mean()/1.5+1)/2
    pts=" ".join(f"{x[k]:.0f},{y[k]:.0f}" for k in t); svg.append(f'<polygon points="{pts}" stroke-opacity="{0.06+0.18*d:.2f}"/>')
svg.append('</g><g fill="#7fe0ea" filter="url(#softglow)">')
for k in range(len(Q)):
    d=(Q[k,2]/1.5+1)/2; svg.append(f'<circle cx="{x[k]:.0f}" cy="{y[k]:.0f}" r="{1.5+1.5*d:.1f}" fill-opacity="{0.15+0.4*d:.2f}"/>')
svg.append('</g>')

# --- sphere
svg.append(f'<circle cx="{CX}" cy="{CY}" r="{R*1.35}" fill="url(#halo)"/>')
svg.append(f'<circle cx="{CX}" cy="{CY}" r="{R}" fill="url(#body)"/>')
pts = sphere_pts(240, 0.06)
front = pts[pts[:,2] > -0.05]; fx,fy = CX+front[:,0]*R, CY+front[:,1]*R
tri = Delaunay(np.c_[fx,fy]).simplices
svg.append(f'<clipPath id="clip"><circle cx="{CX}" cy="{CY}" r="{R}"/></clipPath><g clip-path="url(#clip)">')
svg.append('<g stroke="#3aa8b8" stroke-width="1.2" stroke-opacity="0.35" stroke-linejoin="round">')
for t in tri:
    v=front[t]; n=v.mean(0); n/=np.linalg.norm(n); lam=max(0,n@light)
    base=np.array([10,24,28])+lam*np.array([12,36,40])
    if rng.random()<0.06: base=np.array([28,80,90])*(0.6+0.4*lam)
    col="#%02x%02x%02x"%tuple(np.clip(base,0,255).astype(int))
    p=" ".join(f"{fx[k]:.0f},{fy[k]:.0f}" for k in t); svg.append(f'<polygon points="{p}" fill="{col}" fill-opacity="0.75"/>')
svg.append('</g><g fill="#8fe6ee" filter="url(#glow)">')
for k in range(len(front)):
    d=(front[k,2]+1)/2; svg.append(f'<circle cx="{fx[k]:.0f}" cy="{fy[k]:.0f}" r="{1.5+2*d:.1f}" fill-opacity="{0.2+0.3*d:.2f}"/>')
svg.append('</g></g>')
svg.append(f'<circle cx="{CX}" cy="{CY}" r="{R}" fill="url(#rim)"/>')
# vignette for readability
svg.append(f'<rect width="{W}" height="{H}" fill="#11111b" fill-opacity="0.30"/>')
svg.append('</svg>')
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'vhstack.bg.svg')
open(OUT,'w').write("\n".join(svg)); print("written", OUT)
