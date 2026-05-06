#!/usr/bin/env python3
"""
generate_weather_pets.py
Generates 44 Lottie JSON animation files for weather app pets.
Outputs: assets/lottie/{pet}/default/{state}.json

Timing reference:
  sunny/cloudy/snowy/windy/cold/night/foggy  → 8 s = 240 f
  rainy/hot                                  → 4 s = 120 f
  stormy                                     → 7 s = 210 f  (flash at t=0)
  loading                                    → 2 s =  60 f
"""
import json, os

FPS = 30
W = H = 200

PETS   = ["cat", "dog", "dragon", "frog"]
STATES = ["sunny","cloudy","rainy","stormy","snowy","windy",
          "hot","cold","night","foggy","loading"]
OP = {
    "sunny":240,"cloudy":240,"rainy":120,"stormy":210,
    "snowy":240,"windy":240,"hot":120,"cold":240,
    "night":240,"foggy":240,"loading":60,
}

# ─── Lottie primitives ────────────────────────────────────────────

def sv(v):
    return {"a": 0, "k": v}

def rgb(h):
    h = h.lstrip("#")
    return [int(h[i:i+2], 16)/255 for i in (0, 2, 4)] + [1.0]

def fl(col, op=100):
    return {"ty":"fl","nm":"F","c":sv(rgb(col)),"o":sv(op),"r":1}

def stk(col, w=2):
    return {"ty":"st","nm":"S","c":sv(rgb(col)),"o":sv(100),
            "w":sv(w),"r":1,"lc":2,"lj":2}

def el(cx, cy, ew, eh):
    return {"ty":"el","nm":"E","p":sv([cx,cy]),"s":sv([ew,eh]),"d":1}

def pt(v, i=None, o=None, cl=True):
    n = len(v)
    return {"ty":"sh","nm":"P","ks":sv({
        "i": i or [[0,0]]*n,
        "o": o or [[0,0]]*n,
        "v": v, "c": cl
    }), "d":1}

def trn(px=0, py=0, ax=0, ay=0, P=None, Sc=None, R=None, o=100):
    return {
        "ty":"tr","nm":"T",
        "p": P or sv([px, py]),
        "a": sv([ax, ay]),
        "s": Sc or sv([100, 100]),
        "r": R or sv(0),
        "o": sv(o),
        "sk": sv(0), "sa": sv(0)
    }

def grp(nm, items, t=None):
    tt = t or trn()
    return {"ty":"gr","nm":nm,"it":items+[tt],
            "np":len(items)+1,"cix":2,"bm":0,"ix":1,"mn":""}

def lay(nm, shapes, P=None, R=None, Sc=None, op=240):
    return {
        "ty":4,"nm":nm,"ind":1,
        "ks":{
            "p": P or sv([0,0]),
            "s": Sc or sv([100,100]),
            "r": R or sv(0),
            "o": sv(100),
            "a": sv([0,0]),
        },
        "shapes": shapes,
        "ip":0,"op":op,"st":0,"bm":0,"sr":1
    }

def lf(nm, layers, op=240):
    return {"v":"5.7.4","fr":FPS,"ip":0,"op":op,"w":W,"h":H,
            "nm":nm,"ddd":0,"assets":[],"layers":layers}

# ─── Keyframe helpers ─────────────────────────────────────────────

def _ez():  return {"i":{"x":[0.45],"y":[1.0]},"o":{"x":[0.55],"y":[0.0]}}
def _ez2(): return {"i":{"x":[0.45,0.45],"y":[1.0,1.0]},"o":{"x":[0.55,0.55],"y":[0.0,0.0]}}

def k1(t, v, e=None):
    k = {"t":t, "s":[v] if not isinstance(v,list) else v}
    if e is not None:
        k["e"] = [e] if not isinstance(e,list) else e
        k.update(_ez())
    return k

def k2(t, v, e=None):
    k = {"t":t, "s":list(v)}
    if e is not None:
        k["e"] = list(e)
        k.update(_ez2())
    return k

def a1(kfs): return {"a":1,"k":kfs}
def a2(kfs): return {"a":1,"k":kfs}

# ─── Reusable animation patterns ──────────────────────────────────

def P_float(bx, by, amp, op):
    h = op//2
    return a2([k2(0,[bx,by],[bx,by-amp]),
               k2(h,[bx,by-amp],[bx,by]),
               k2(op,[bx,by])])

def P_sway(bx, by, amp, op):
    h = op//2
    return a2([k2(0,[bx,by],[bx+amp,by]),
               k2(h,[bx+amp,by],[bx,by]),
               k2(op,[bx,by])])

def P_flinch(bx, by, fx, fy, op):
    return a2([k2(0,[bx,by],[bx+fx,by+fy]),
               k2(8,[bx+fx,by+fy],[bx,by]),
               k2(30,[bx,by]),
               k2(op,[bx,by])])

def P_storm(bx, by, op):
    # lightning fires at t=0 → jump up, then crouch for rest of 7s cycle
    return a2([k2(0, [bx,by+6],[bx,by-12]),
               k2(6, [bx,by-12],[bx,by+6]),
               k2(20,[bx,by+6]),
               k2(op,[bx,by+6])])

def P_shiver(bx, by, amp, op):
    n = 12; step = op // n
    kfs = [k2(i*step,[bx+(amp if i%2==0 else -amp),by],
               [bx+(-amp if i%2==0 else amp),by]) for i in range(n)]
    return a2(kfs + [k2(op,[bx,by])])

def P_confused(bx, by, op):
    q = op//4
    return a2([k2(0,   [bx,by],     [bx+5,by]),
               k2(q,   [bx+5,by],   [bx-4,by+2]),
               k2(2*q, [bx-4,by+2], [bx+3,by-3]),
               k2(3*q, [bx+3,by-3], [bx,by]),
               k2(op,  [bx,by])])

def R_sway(amp, op):
    h = op//2
    return a1([k1(0,-amp,amp), k1(h,amp,-amp), k1(op,-amp)])

def R_lean(amp, op):
    h = op//2
    return a1([k1(0,amp,-amp), k1(h,-amp,amp), k1(op,amp)])

def R_confused(op):
    q = op//4
    return a1([k1(0,-5,8), k1(q,8,-6), k1(2*q,-6,7), k1(3*q,7,-5), k1(op,-5)])

def Sc_crouch(op):
    return a2([k2(0,[100,90]), k2(8,[100,100]), k2(op,[100,90])])

def Sc_breathe(op):
    h = op//2
    return a2([k2(0,[100,100],[102,102]), k2(h,[102,102],[100,100]), k2(op,[100,100])])

def Sc_puff(op):
    h = op//2
    return a2([k2(0,[106,106],[100,100]), k2(h,[100,100],[106,106]), k2(op,[106,106])])

def Sc_pulse(op):
    h = op//2
    return a2([k2(0,[90,90],[110,110]), k2(h,[110,110],[90,90]), k2(op,[90,90])])

def Sc_wilt(op):
    h = op//2
    return a2([k2(0,[100,96],[100,100]), k2(h,[100,100],[100,96]), k2(op,[100,96])])

def R_tail_wave(op):
    q = op//4
    return a1([k1(0,-20,20), k1(q,20,-20), k1(2*q,-20,20), k1(3*q,20,-20), k1(op,-20)])

def R_wag(op):
    q = max(op//8, 8)
    return a1([k1(i*q, 35 if i%2==0 else -35, -35 if i%2==0 else 35)
               for i in range(8)] + [k1(op,35)])

def R_wing(op, amp=14):
    h = op//2
    return a1([k1(0,-amp,amp), k1(h,amp,-amp), k1(op,-amp)])

def main_anim(state, op, bx=100, by=100):
    """Return (MP, MR, MSc) for the given weather state."""
    if   state=="sunny":   return P_float(bx,by,5,op),    R_sway(2,op),   sv([100,100])
    elif state=="cloudy":  return P_sway(bx,by,3,op),     R_sway(1,op),   sv([100,100])
    elif state=="rainy":   return P_flinch(bx,by,-4,-3,op),sv(0),          sv([100,100])
    elif state=="stormy":  return P_storm(bx,by,op),       R_sway(3,op),   Sc_crouch(op)
    elif state=="snowy":   return P_float(bx,by,3,op),    R_sway(1,op),   sv([100,100])
    elif state=="windy":   return P_sway(bx,by,6,op),     R_lean(8,op),   sv([100,100])
    elif state=="hot":     return P_sway(bx,by+4,2,op),   R_sway(1,op),   Sc_wilt(op)
    elif state=="cold":    return P_shiver(bx,by,2,op),   sv(0),           Sc_puff(op)
    elif state=="night":   return P_float(bx,by,2,op),    sv(0),           Sc_breathe(op)
    elif state=="foggy":   return P_confused(bx,by,op),   R_confused(op), sv([100,100])
    else:                  return sv([bx,by]),              sv(0),           Sc_pulse(op)

# ─── CAT ──────────────────────────────────────────────────────────

def cat(state, op):
    CB="#E8943A"; CL="#F5C17A"; CE="#E87090"
    EG="#4A9A2A"; PU="#1A1010"; WH="#FFFFFF"; NK="#E06080"

    MP, MR, MSc = main_anim(state, op)

    if state in ("stormy","rainy"):
        TR = sv(-35)
    elif state in ("cold","night"):
        TR = sv(-5)
    else:
        TR = R_tail_wave(op)

    ey_h = 7 if state=="sunny" else (6 if state=="night" else 12)

    ER = (a1([k1(0,-8,18), k1(op//2,18,-8), k1(op,-8)])
          if state in ("windy","stormy") else sv(0))

    extras = []
    if state == "hot":
        ts = a2([k2(0,[100,100],[110,120]),
                 k2(op//2,[110,120],[100,100]),
                 k2(op,[100,100])])
        extras = [grp("tongue",[el(0,0,14,18),fl("#E84060")],
                      t=trn(px=0,py=-7,ax=0,ay=-9,Sc=ts))]

    tail = grp("tail",
               [pt([[0,0],[20,-8],[28,-28],[14,-44]],
                   i=[[0,0],[-10,0],[-6,8],[0,10]],
                   o=[[10,0],[6,-8],[0,-10],[0,0]], cl=False),
                stk(CB, 9)],
               t=trn(px=36,py=16, R=TR))

    body  = grp("body",  [el(0,20,68,50),   fl(CB)])
    belly = grp("belly", [el(0,24,42,32),   fl(CL)])
    pl    = grp("pl",    [el(-22,38,22,14), fl(CB)])
    pr    = grp("pr",    [el( 22,38,22,14), fl(CB)])
    le    = grp("le",    [pt([[-8,0],[0,-18],[8,0]]),fl(CB)],  t=trn(px=-26,py=-54,R=ER))
    lei   = grp("lei",   [pt([[-5,0],[0,-13],[5,0]]),fl(CE)],  t=trn(px=-26,py=-54,R=ER))
    re    = grp("re",    [pt([[-8,0],[0,-18],[8,0]]),fl(CB)],  t=trn(px= 26,py=-54,R=ER))
    rei   = grp("rei",   [pt([[-5,0],[0,-13],[5,0]]),fl(CE)],  t=trn(px= 26,py=-54,R=ER))
    head  = grp("head",  [el(0,-18,76,74),  fl(CB)])
    ley   = grp("ley",   [el(-16,-22,16,ey_h),          fl(EG)])
    lpu   = grp("lpu",   [el(-16,-22, 7,min(ey_h+2,12)),fl(PU)])
    lsh   = grp("lsh",   [el(-19,-25, 4,4),              fl(WH)])
    rey   = grp("rey",   [el( 16,-22,16,ey_h),           fl(EG)])
    rpu   = grp("rpu",   [el( 16,-22, 7,min(ey_h+2,12)),fl(PU)])
    rsh   = grp("rsh",   [el( 13,-25, 4,4),              fl(WH)])
    nse   = grp("nose",  [pt([[0,-10],[-4,-4],[4,-4]]),   fl(NK)])
    wl1   = grp("wl1",   [pt([[-18,-10],[-40,-8]], cl=False), stk("#3A2010",1)])
    wl2   = grp("wl2",   [pt([[-18, -6],[-40,-9]], cl=False), stk("#3A2010",1)])
    wr1   = grp("wr1",   [pt([[ 18,-10],[ 40,-8]], cl=False), stk("#3A2010",1)])
    wr2   = grp("wr2",   [pt([[ 18, -6],[ 40,-9]], cl=False), stk("#3A2010",1)])

    shapes = [tail, body, belly, pl, pr,
              le, lei, re, rei, head,
              ley, lpu, lsh, rey, rpu, rsh,
              nse, wl1, wl2, wr1, wr2] + extras
    return lay("cat", shapes, P=MP, R=MR, Sc=MSc, op=op)

# ─── DOG ──────────────────────────────────────────────────────────

def dog(state, op):
    CB="#C8962A"; CL="#ECC87A"; EN="#2A1A0E"; WH="#FFFFFF"; EY="#8B4513"

    MP, MR, MSc = main_anim(state, op)

    if state in ("sunny","snowy","rainy"):
        WR = R_wag(op)
    elif state in ("stormy","cold"):
        WR = sv(-40)
    elif state == "night":
        WR = a1([k1(0,-15), k1(op//2,-5), k1(op,-15)])
    else:
        WR = R_wag(max(op//2, 30))

    LE_R = a1([k1(0,10,-10), k1(op//2,-10,10), k1(op,10)])
    RE_R = a1([k1(0,-10,10), k1(op//2,10,-10), k1(op,-10)])

    ey_h = 9 if state not in ("night","hot") else 5

    extras = []
    if state == "hot":
        ts = a2([k2(0,[100,100],[110,130]),
                 k2(op//2,[110,130],[100,100]),
                 k2(op,[100,100])])
        extras = [grp("tongue",[el(0,0,16,22),fl("#E84060")],
                      t=trn(px=0,py=-4,Sc=ts))]

    tail = grp("tail",
               [pt([[0,0],[18,-14],[22,-32]],
                   i=[[0,0],[-8,6],[0,8]],
                   o=[[8,-6],[0,-8],[0,0]], cl=False),
                stk(CB, 11)],
               t=trn(px=32,py=14, R=WR))

    body  = grp("body",  [el(0,22,74,54),   fl(CB)])
    belly = grp("belly", [el(0,26,46,34),   fl(CL)])
    pl    = grp("pl",    [el(-24,40,26,14), fl(CB)])
    pr    = grp("pr",    [el( 24,40,26,14), fl(CB)])
    le    = grp("le",    [el(0,0,22,32),fl(CB)],
                t=trn(px=-34,py=-28,ax=0,ay=-16,R=LE_R))
    re    = grp("re",    [el(0,0,22,32),fl(CB)],
                t=trn(px= 34,py=-28,ax=0,ay=-16,R=RE_R))
    head  = grp("head",  [el(0,-16,76,72),  fl(CB)])
    ley   = grp("ley",   [el(-16,-20,16,ey_h),         fl(WH)])
    lpu   = grp("lpu",   [el(-16,-20, 8,min(ey_h,8)),  fl(EY)])
    lsh   = grp("lsh",   [el(-18,-23, 3,3),             fl(WH)])
    rey   = grp("rey",   [el( 16,-20,16,ey_h),          fl(WH)])
    rpu   = grp("rpu",   [el( 16,-20, 8,min(ey_h,8)),  fl(EY)])
    rsh   = grp("rsh",   [el( 14,-23, 3,3),             fl(WH)])
    nse   = grp("nose",  [el(0,-4,22,14),               fl(EN)])
    nsl   = grp("nsl",   [el(-5,-4,5,5),                fl("#3A2A1E",50)])
    nsr   = grp("nsr",   [el( 5,-4,5,5),                fl("#3A2A1E",50)])

    shapes = [tail, body, belly, pl, pr,
              le, re, head,
              ley, lpu, lsh, rey, rpu, rsh,
              nse, nsl, nsr] + extras
    return lay("dog", shapes, P=MP, R=MR, Sc=MSc, op=op)

# ─── DRAGON ───────────────────────────────────────────────────────

def dragon(state, op):
    CB="#2A7A5A"; CS="#1A5A4A"; CL="#7AE8C8"
    EY="#FFD700"; PU="#1A1030"; WH="#FFFFFF"
    WG="#3A9A6A"; FI="#FF6030"

    MP, MR, MSc = main_anim(state, op)

    TR  = R_tail_wave(op) if state not in ("stormy","cold") else sv(-25)
    WL  = R_wing(op, 15)
    WR2 = a1([k1(0,15,-15), k1(op//2,-15,15), k1(op,15)])

    ey_h = 14 if state != "night" else 7

    extras = []
    if state == "hot":
        fsc = a2([k2(0,[60,60],[140,140]),
                  k2(op//3,[140,140],[80,80]),
                  k2(2*op//3,[80,80],[60,60]),
                  k2(op,[60,60])])
        extras = [grp("fire",
                      [pt([[0,-6],[-12,-22],[0,-38],[12,-22]]), fl(FI,80)],
                      t=trn(px=0,py=-36,Sc=fsc))]

    lwing = grp("lwing",
                [pt([[0,0],[-24,-22],[-38,-6],[-20,12]],
                    i=[[0,0],[0,10],[12,0],[0,-10]],
                    o=[[0,-10],[-12,0],[0,10],[10,0]]),
                 fl(WG,88), stk(CS,1)],
                t=trn(px=-14,py=-8, R=WL))
    rwing = grp("rwing",
                [pt([[0,0],[24,-22],[38,-6],[20,12]],
                    i=[[0,0],[0,10],[-12,0],[0,-10]],
                    o=[[0,-10],[12,0],[0,10],[-10,0]]),
                 fl(WG,88), stk(CS,1)],
                t=trn(px=14,py=-8, R=WR2))

    tail  = grp("tail",
                [pt([[0,0],[22,-8],[32,-28],[20,-44]],
                    i=[[0,0],[-10,0],[-8,8],[0,10]],
                    o=[[10,0],[8,-8],[0,-10],[0,0]], cl=False),
                 stk(CB,8)],
                t=trn(px=34,py=16, R=TR))

    sp1   = grp("sp1",   [pt([[0,-34],[-5,-26],[5,-26]]),   fl(CS)])
    sp2   = grp("sp2",   [pt([[0,-28],[-4,-22],[4,-22]]),   fl(CS)])
    body  = grp("body",  [el(0,22,72,56),                   fl(CB)])
    belly = grp("belly", [el(0,28,44,36),                   fl(CL)])
    pl    = grp("pl",    [el(-24,42,24,14),                 fl(CB)])
    pr    = grp("pr",    [el( 24,42,24,14),                 fl(CB)])
    horn  = grp("horn",  [pt([[0,-58],[-6,-44],[6,-44]]),   fl(CS)])
    head  = grp("head",  [el(0,-16,80,74),                  fl(CB)])
    hspot = grp("hs",    [el(0,-20,46,38),                  fl(CL)])
    ley   = grp("ley",   [el(-16,-22,18,ey_h),              fl(EY)])
    lpu   = grp("lpu",   [el(-16,-22, 8,min(ey_h,12)),      fl(PU)])
    lsh   = grp("lsh",   [el(-19,-25, 4,4),                 fl(WH)])
    rey   = grp("rey",   [el( 16,-22,18,ey_h),              fl(EY)])
    rpu   = grp("rpu",   [el( 16,-22, 8,min(ey_h,12)),      fl(PU)])
    rsh   = grp("rsh",   [el( 13,-25, 4,4),                 fl(WH)])
    nsl   = grp("nsl",   [el(-6,-6,5,4),                    fl(CS)])
    nsr   = grp("nsr",   [el( 6,-6,5,4),                    fl(CS)])

    shapes = [lwing, rwing, tail, sp1, sp2,
              body, belly, pl, pr,
              horn, head, hspot,
              ley, lpu, lsh, rey, rpu, rsh,
              nsl, nsr] + extras
    return lay("dragon", shapes, P=MP, R=MR, Sc=MSc, op=op)

# ─── FROG ─────────────────────────────────────────────────────────

def frog(state, op):
    CB="#4A9A3A"; CL="#8ACA6A"; EY_C="#F5E030"
    PU="#1A2A18"; WH="#FFFFFF"; TH="#3A7A2A"

    if state == "rainy":
        MP = P_float(100,100,5,op)
        MR = R_sway(2,op)
        MSc = sv([100,100])
    else:
        MP, MR, MSc = main_anim(state, op)

    ey_h = 18 if state != "night" else 9

    if state == "hot":
        TS = a2([k2(0,[100,100],[118,114]),
                 k2(op//4,[118,114],[100,100]),
                 k2(op//2,[100,100],[118,114]),
                 k2(3*op//4,[118,114],[100,100]),
                 k2(op,[100,100])])
    elif state in ("night","cold"):
        TS = a2([k2(0,[100,100],[104,102]),
                 k2(op//2,[104,102],[100,100]),
                 k2(op,[100,100])])
    else:
        TS = a2([k2(0,[100,100],[108,106]),
                 k2(op//2,[108,106],[100,100]),
                 k2(op,[100,100])])

    EB = a2([k2(0,   [100,100],[100,100]),
             k2(op-12,[100,100],[100,15]),
             k2(op-6, [100,15],[100,100]),
             k2(op,   [100,100])])

    def eye_g(x, y):
        iris  = grp("iris",  [el(0,0,24,ey_h),               fl(EY_C)])
        pupil = grp("pupil", [el(0,0,10,min(int(ey_h*.75),14)),fl(PU)])
        shine = grp("shine", [el(-5,-5,4,4),                  fl(WH)])
        return grp("eye", [iris,pupil,shine], t=trn(px=x,py=y,Sc=EB))

    body  = grp("body",  [el(0,30,82,58),   fl(CB)])
    belly = grp("belly", [el(0,34,56,40),   fl(CL)])
    fll   = grp("fll",   [el(-38,44,28,16), fl(CB)])
    flr   = grp("flr",   [el( 38,44,28,16), fl(CB)])
    tl1   = grp("tl1",   [el(-54,46,12,10), fl(TH)])
    tl2   = grp("tl2",   [el(-38,48,10,10), fl(TH)])
    tr1   = grp("tr1",   [el( 38,48,10,10), fl(TH)])
    tr2   = grp("tr2",   [el( 54,46,12,10), fl(TH)])
    head  = grp("head",  [el(0,-8,84,66),   fl(CB)])
    mth   = grp("mouth", [pt([[-32,-2],[0,8],[32,-2]],
                              i=[[0,0],[-14,0],[0,0]],
                              o=[[14,0],[0,0],[-14,0]], cl=False),
                          stk("#2A6A1A",3)])
    thr   = grp("throat",[el(0,0,48,24),fl(TH,80)],
                t=trn(px=0,py=12,Sc=TS))
    lbump = grp("lbump", [el(0,0,36,34),fl(CB)], t=trn(px=-26,py=-30))
    rbump = grp("rbump", [el(0,0,36,34),fl(CB)], t=trn(px= 26,py=-30))
    leye  = eye_g(-26,-30)
    reye  = eye_g( 26,-30)

    shapes = [body,belly,fll,flr,tl1,tl2,tr1,tr2,
              lbump,rbump,head,thr,mth,leye,reye]
    return lay("frog", shapes, P=MP, R=MR, Sc=MSc, op=op)

# ─── Generator ────────────────────────────────────────────────────

BUILDERS = {"cat":cat, "dog":dog, "dragon":dragon, "frog":frog}

def main():
    # Output to assets/lottie/{pet}/default/{state}.json
    script_dir = os.path.dirname(os.path.abspath(__file__))
    root = os.path.join(script_dir, "..", "assets", "lottie")
    count = 0
    for pet in PETS:
        d = os.path.join(root, pet, "default")
        os.makedirs(d, exist_ok=True)
        for state in STATES:
            op = OP[state]
            layer_data = BUILDERS[pet](state, op)
            data = lf(f"{pet}_{state}", [layer_data], op=op)
            path = os.path.join(d, f"{state}.json")
            with open(path, "w") as f:
                json.dump(data, f, separators=(",",":"))
            size = os.path.getsize(path)
            print(f"  ✓ {pet}/default/{state}.json  ({op}f, {size}B)")
            count += 1
    print(f"\n✓ {count} Lottie files generated → {root}")

if __name__ == "__main__":
    main()
