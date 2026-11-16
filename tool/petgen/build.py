"""Generate the Lottie files. Usage: build.py <out_dir> [animal ...]"""
import importlib
import json
import os
import sys

import anim
import lottie

out_dir = sys.argv[1]
for animal in sys.argv[2:] or ['cat']:
    pet = importlib.import_module(animal)
    states = importlib.import_module(animal + '_states').STATES
    tracks, markers, frames = anim.timeline(states)
    rig = anim.full_rig(pet)
    missing = sorted({ch.split('.')[0] for ch in tracks} - anim.names(rig))
    assert not missing, f'{animal}: states animate parts the rig lacks: {missing}'
    doc = lottie.export(rig, tracks, frames, markers)
    os.makedirs(os.path.join(out_dir, animal), exist_ok=True)
    path = os.path.join(out_dir, animal, f'{animal}.json')
    with open(path, 'w') as f:
        json.dump(doc, f, separators=(',', ':'))
    print(f'{path}: {os.path.getsize(path) / 1024:.0f} KB, {frames} frames, '
          f'{len(markers)} markers')
