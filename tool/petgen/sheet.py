"""Render a pet model sheet SVG. Usage: sheet.py <animal> <out.svg>"""
import base64
import importlib
import os
import sys

from rig import to_svg

animal, out = sys.argv[1], sys.argv[2]
pet = importlib.import_module(animal)
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')
ref = os.path.join(ROOT, 'assets', 'images', animal, 'sunny.png')
INK, MUTE, BG, CARD = '#3A2A20', '#8A7868', '#F7F2E9', '#BFDDF2'
FONT = 'font-family="Helvetica, Arial, sans-serif"'


def text(x, y, s, size=18, fill=INK, weight=400, anchor='start'):
    return (f'<text x="{x}" y="{y}" font-size="{size}" fill="{fill}" '
            f'font-weight="{weight}" text-anchor="{anchor}" {FONT}>{s}</text>')


s = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1600 1080" '
     f'width="1600" height="1080"><rect width="1600" height="1080" fill="{BG}"/>']
s.append(text(60, 70, f'{pet.NAME} — model sheet', 34, weight=700))
s.append(text(60, 100, pet.PERSONALITY, 17, MUTE))

s.append('<g transform="translate(60 130)">')
s.append(f'<rect width="512" height="512" rx="16" fill="{CARD}"/>')
for y, lab in pet.GUIDES:
    s.append(f'<line x1="0" x2="512" y1="{y}" y2="{y}" stroke="#FFFFFF" '
             'stroke-dasharray="6 6"/>')
    s.append(text(8, y - 6, lab, 13, MUTE))
s.append(to_svg(pet.build()))
s.append('</g>')
s.append(text(60, 672, 'Build', 20, weight=700))
s.append(text(60, 698, '512 × 512 artboard, one group per moving part.', 15, MUTE))
s.append(text(60, 720, 'Shading: 3-stop gradients. One shared 4 px outline per silhouette.',
              15, MUTE))

b64 = base64.b64encode(open(ref, 'rb').read()).decode()
s.append('<rect x="620" y="130" width="300" height="300" rx="16" fill="#6B7280"/>')
s.append(f'<image x="630" y="150" width="280" height="249" '
         f'href="data:image/png;base64,{b64}"/>')
s.append(text(620, 456, 'Source art (being replaced)', 15, MUTE))

s.append(text(620, 510, 'Rig parts (each animates on its own)', 20, weight=700))
for i, p in enumerate(pet.PARTS):
    s.append(text(620, 540 + i * 23, '· ' + p, 15, INK))

s.append(text(980, 150, 'Palette', 20, weight=700))
for i, (k, v) in enumerate(pet.PAL.items()):
    x, y = 980 + (i % 4) * 150, 172 + (i // 4) * 92
    s.append(f'<rect x="{x}" y="{y}" width="130" height="50" rx="10" '
             f'fill="{v}" stroke="#D9CFC0"/>')
    s.append(text(x, y + 68, k.replace('_', ' ').capitalize(), 14, INK, 700))
    s.append(text(x, y + 84, v, 12, MUTE))

s.append(text(60, 772, 'Expressions', 20, weight=700))
for i, (name, states, kw) in enumerate(pet.EXPRESSIONS):
    x = 60 + i * 250
    s.append(f'<rect x="{x}" y="790" width="230" height="250" rx="16" fill="{CARD}"/>')
    s.append(f'<g transform="translate({x - 13} 778) scale(0.5)">'
             + to_svg(pet.build(head_only=True, **kw)) + '</g>')
    s.append(text(x + 115, 992, name, 17, INK, 700, 'middle'))
    s.append(text(x + 115, 1014, states, 13, MUTE, 400, 'middle'))
s.append('</svg>')
open(out, 'w').write('\n'.join(s))
