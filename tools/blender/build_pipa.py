"""Pipa, a aviadora destemida (galinha branca e dourada, crista vermelha, oculos de aviadora, lenco laranja, colete tecnologico).
Uso: blender --background --python tools/blender/build_pipa.py -- <saida.blend> <saida.glb>
Paleta do PDF: #F2EDE2 penas; #EDB85E dourado; #DE5145 crista; #EC7832 lenco; #245578 colete."""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
import biped_anims as A
import hero_lib as H

blend_out, glb_out = H.script_args()
H.reset_scene()

white = H.material("pipa_white", "#F2EDE2")
gold = H.material("pipa_gold", "#EDB85E")
red = H.material("pipa_red", "#DE5145")
scarf = H.material("pipa_scarf", "#EC7832")
vest = H.material("pipa_vest", "#245578")
cyan = H.material("pipa_cyan", "#23CFF5", emission=2.0)
beak = H.material("pipa_beak", "#F0A030")
dark = H.material("pipa_dark", "#1A1F2B")
glass = H.material("pipa_glass", "#9FD8E8", emission=0.4, roughness=0.15)
leather = H.material("pipa_leather", "#7A4A2A")

arm = H.make_armature("PipaRig", [
    ("root", None, (0, 0, 0), (0, 0, 0.1)),
    ("hips", "root", (0, 0, 0.4), (0, 0, 0.52)),
    ("spine", "hips", (0, 0, 0.52), (0, 0, 0.8)),
    ("head", "spine", (0, 0, 0.8), (0, 0, 1.12)),
    ("ear_l", "head", (-0.02, 0.1, 1.0), (-0.02, 0.1, 1.1)),
    ("ear_r", "head", (-0.02, -0.1, 1.0), (-0.02, -0.1, 1.1)),
    ("tail", "hips", (-0.2, 0, 0.55), (-0.45, 0, 0.75)),
    ("arm_l", "spine", (0, 0.26, 0.72), (0, 0.26, 0.4)),
    ("arm_r", "spine", (0, -0.26, 0.72), (0, -0.26, 0.4)),
    ("leg_l", "hips", (0, 0.09, 0.4), (0, 0.09, 0.04)),
    ("leg_r", "hips", (0, -0.09, 0.4), (0, -0.09, 0.04)),
])
parts = []


def add(obj, bone):
    parts.append((obj, bone))


# Corpo compacto, colete e lenco
add(H.sphere("body", (0, 0, 0.62), (0.3, 0.3, 0.3), white), "spine")
add(H.cube("vest", (0.02, 0, 0.6), (0.62, 0.64, 0.26), vest), "spine")
add(H.cube("vest_light", (0.33, 0, 0.62), (0.03, 0.14, 0.14), cyan), "spine")
add(H.cube("belt", (0, 0, 0.5), (0.36, 0.52, 0.05), leather), "hips")
add(H.cube("belt_buckle", (0.18, 0, 0.5), (0.03, 0.08, 0.06), gold), "hips")
add(H.sphere("scarf_ring", (0.0, 0, 0.84), (0.19, 0.19, 0.09), scarf), "spine")
add(H.cone("scarf_tail", (-0.2, 0, 0.78), 0.07, 0.3, scarf, rot=(0, math.radians(110), 0), verts=6), "spine")

# Cabeca: bico, crista, olhos e oculos de aviadora
add(H.sphere("head_mesh", (0.0, 0, 1.0), (0.22, 0.21, 0.2), white), "head")
add(H.cone("beak", (0.27, 0, 0.98), 0.06, 0.16, beak, rot=(0, math.radians(90), 0), verts=6), "head")
add(H.cone("crest_a", (0.0, 0, 1.22), 0.06, 0.14, red, verts=6), "head")
add(H.cone("crest_b", (0.08, 0, 1.2), 0.05, 0.11, red, verts=6), "head")
add(H.cone("crest_c", (-0.08, 0, 1.2), 0.05, 0.11, red, verts=6), "head")
add(H.sphere("eye_l", (0.19, 0.09, 1.04), (0.05, 0.05, 0.055), dark), "head")
add(H.sphere("eye_r", (0.19, -0.09, 1.04), (0.05, 0.05, 0.055), dark), "head")
add(H.cylinder("goggle_l", (0.2, 0.09, 1.04), 0.075, 0.04, glass, rot=(0, math.radians(90), 0)), "head")
add(H.cylinder("goggle_r", (0.2, -0.09, 1.04), 0.075, 0.04, glass, rot=(0, math.radians(90), 0)), "head")
add(H.cube("goggle_band", (0.0, 0, 1.06), (0.4, 0.42, 0.04), leather), "head")
add(H.sphere("wattle", (0.2, 0, 0.9), (0.03, 0.03, 0.05), red), "head")
add(H.cone("cheek_l", (0.0, 0.1, 1.05), 0.03, 0.05, gold, verts=4), "ear_l")
add(H.cone("cheek_r", (0.0, -0.1, 1.05), 0.03, 0.05, gold, verts=4), "ear_r")

# Asas (bracos): penas brancas com borda dourada
for side, y, bone in (("l", 0.26, "arm_l"), ("r", -0.26, "arm_r")):
    add(H.sphere("wing_" + side, (0, y, 0.56), (0.1, 0.06, 0.2), white), bone)
    add(H.cone("wing_tip_" + side, (0, y, 0.38), 0.07, 0.16, gold, rot=(math.pi, 0, 0), verts=5), bone)
for side, y, bone in (("l", 0.09, "leg_l"), ("r", -0.09, "leg_r")):
    add(H.cylinder("legmesh_" + side, (0, y, 0.22), 0.03, 0.36, scarf), bone)
    add(H.cube("foot_" + side, (0.07, y, 0.03), (0.2, 0.12, 0.05), scarf), bone)

# Cauda de penas
add(H.cone("tail_a", (-0.3, 0, 0.66), 0.08, 0.3, gold, rot=(0, math.radians(-60), 0), verts=5), "tail")
add(H.cone("tail_b", (-0.28, 0.07, 0.62), 0.06, 0.26, white, rot=(0, math.radians(-60), math.radians(20)), verts=5), "tail")
add(H.cone("tail_c", (-0.28, -0.07, 0.62), 0.06, 0.26, white, rot=(0, math.radians(-60), math.radians(-20)), verts=5), "tail")

for obj, bone in parts:
    H.skin(obj, bone, arm)


def glide(arm_obj, frame):
    """special = planeio: asas abertas na horizontal, corpo levemente inclinado."""
    A.key(arm_obj, frame, {"arm_l": dict(tilt=85), "arm_r": dict(tilt=-85), "spine": dict(swing=-8),
                           "leg_l": dict(swing=-20), "leg_r": dict(swing=-20), "tail": dict(swing=-15)})


A.build_actions(arm, special=glide)
H.export_glb(arm, blend_out, glb_out)
print("PIPA_OK", len(parts), "partes", glb_out)
