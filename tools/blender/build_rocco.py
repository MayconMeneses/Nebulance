"""Rocco, o mecanico corajoso (cachorro robusto castanho, uniforme azul-marinho e laranja).
Uso: blender --background --python tools/blender/build_rocco.py -- <saida.blend> <saida.glb>
Paleta do PDF: #1C416B azul, #F08A3B laranja, #23CFF5 emissivo; castanho e creme de pelagem."""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
import biped_anims as A
import hero_lib as H

blend_out, glb_out = H.script_args()
H.reset_scene()

navy = H.material("rocco_navy", "#1C416B")
orange = H.material("rocco_orange", "#F08A3B")
fur = H.material("rocco_fur", "#8A5A36")
cream = H.material("rocco_cream", "#EBDDBE")
dark = H.material("rocco_dark", "#1A1F2B")
amber = H.material("rocco_amber", "#D98A1E", emission=0.3)
cyan = H.material("rocco_cyan", "#23CFF5", emission=2.0)
metal = H.material("rocco_metal", "#8D98A8", roughness=0.4)

arm = H.make_armature("RoccoRig", [
    ("root", None, (0, 0, 0), (0, 0, 0.1)),
    ("hips", "root", (0, 0, 0.8), (0, 0, 0.95)),
    ("spine", "hips", (0, 0, 0.95), (0, 0, 1.35)),
    ("head", "spine", (0, 0, 1.35), (0, 0, 1.75)),
    ("ear_l", "head", (0.02, 0.2, 1.62), (0.02, 0.2, 1.8)),
    ("ear_r", "head", (0.02, -0.2, 1.62), (0.02, -0.2, 1.8)),
    ("tail", "hips", (-0.2, 0, 0.95), (-0.45, 0, 1.15)),
    ("arm_l", "spine", (0, 0.32, 1.3), (0, 0.32, 0.78)),
    ("arm_r", "spine", (0, -0.32, 1.3), (0, -0.32, 0.78)),
    ("leg_l", "hips", (0, 0.15, 0.8), (0, 0.15, 0.06)),
    ("leg_r", "hips", (0, -0.15, 0.8), (0, -0.15, 0.06)),
])

parts = []


def add(obj, bone):
    parts.append((obj, bone))


# Tronco e uniforme
add(H.cube("torso", (0, 0, 1.08), (0.42, 0.62, 0.56), navy), "spine")
add(H.cube("chest_emblem", (0.215, 0, 1.12), (0.03, 0.2, 0.2), cyan), "spine")
add(H.cube("belt", (0, 0, 0.88), (0.44, 0.64, 0.1), orange), "hips")
add(H.cube("pouch_l", (0.2, 0.2, 0.86), (0.12, 0.14, 0.14), orange), "hips")
add(H.cube("pouch_r", (0.2, -0.2, 0.86), (0.12, 0.14, 0.14), orange), "hips")
add(H.cube("shoulder_pad_l", (0, 0.33, 1.32), (0.24, 0.2, 0.18), orange), "spine")
add(H.cube("shoulder_pad_r", (0, -0.33, 1.32), (0.24, 0.2, 0.18), orange), "spine")
add(H.cube("backpack", (-0.3, 0, 1.12), (0.22, 0.4, 0.46), orange), "spine")
add(H.sphere("backpack_light", (-0.42, 0, 1.2), (0.05, 0.1, 0.1), cyan), "spine")
add(H.cube("chest_fur", (0.17, 0, 1.3), (0.08, 0.26, 0.18), cream), "spine")

# Cabeca de cachorro
add(H.sphere("head_mesh", (0.02, 0, 1.55), (0.3, 0.29, 0.28), fur), "head")
add(H.sphere("muzzle", (0.27, 0, 1.49), (0.2, 0.15, 0.12), cream), "head")
add(H.sphere("nose", (0.45, 0, 1.52), (0.06, 0.07, 0.05), dark), "head")
add(H.sphere("eye_l", (0.24, 0.12, 1.6), (0.055, 0.055, 0.065), amber), "head")
add(H.sphere("eye_r", (0.24, -0.12, 1.6), (0.055, 0.055, 0.065), amber), "head")
add(H.sphere("pupil_l", (0.285, 0.12, 1.6), (0.025, 0.03, 0.04), dark), "head")
add(H.sphere("pupil_r", (0.285, -0.12, 1.6), (0.025, 0.03, 0.04), dark), "head")
# Palpebras (a engine as mostra no piscar e ao tomar dano; ocultas no resto do tempo)
add(H.sphere("lid_l", (0.245, 0.12, 1.6), (0.075, 0.072, 0.082), fur), "head")
add(H.sphere("lid_r", (0.245, -0.12, 1.6), (0.075, 0.072, 0.082), fur), "head")
add(H.cube("brow_l", (0.23, 0.12, 1.67), (0.04, 0.1, 0.03), fur, rot=(0, 0, math.radians(-10))), "head")
add(H.cube("brow_r", (0.23, -0.12, 1.67), (0.04, 0.1, 0.03), fur, rot=(0, 0, math.radians(10))), "head")
# Orelhas: a esquerda em pe, a direita parcialmente caida (expressiva)
add(H.cone("ear_l_mesh", (0.02, 0.21, 1.74), 0.1, 0.26, fur, rot=(0, 0, 0), verts=8), "ear_l")
add(H.cone("ear_r_mesh", (0.02, -0.27, 1.68), 0.1, 0.26, fur, rot=(math.radians(70), 0, 0), verts=8), "ear_r")
add(H.cube("goggles_band", (0.0, 0, 1.68), (0.32, 0.6, 0.05), dark), "head")

# Bracos, luvas e pernas
for side, y, bone in (("l", 0.32, "arm_l"), ("r", -0.32, "arm_r")):
    add(H.limb("armmesh_" + side, (0, y, 1.3), (0, y, 0.8), 0.105, navy), bone)
    add(H.sphere("glove_" + side, (0, y, 0.78), (0.12, 0.12, 0.12), dark), bone)
    add(H.cube("glove_stripe_" + side, (0, y, 0.84), (0.2, 0.2, 0.04), orange), bone)
for side, y, bone in (("l", 0.15, "leg_l"), ("r", -0.15, "leg_r")):
    add(H.limb("legmesh_" + side, (0, y, 0.8), (0, y, 0.2), 0.135, navy), bone)
    add(H.sphere("knee_pad_" + side, (0.1, y, 0.52), (0.07, 0.09, 0.09), orange), bone)
    add(H.cube("boot_" + side, (0.07, y, 0.1), (0.38, 0.22, 0.2), dark), bone)
    add(H.cube("boot_toe_" + side, (0.2, y, 0.1), (0.1, 0.2, 0.14), metal), bone)

# Cauda
add(H.cone("tail_mesh", (-0.34, 0, 1.06), 0.09, 0.42, fur, rot=(0, math.radians(-60), 0), verts=8), "tail")

for obj, bone in parts:
    H.skin(obj, bone, arm)

A.build_actions(arm)
H.export_glb(arm, blend_out, glb_out)
print("ROCCO_OK", len(parts), "partes", glb_out)
