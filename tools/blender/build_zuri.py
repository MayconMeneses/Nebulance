"""Zuri, a navegadora acrobata (gata grafite quase preta, olhos verde-turquesa, roupa violeta, hologramas ciano).
Uso: blender --background --python tools/blender/build_zuri.py -- <saida.blend> <saida.glb>
Paleta do PDF: #292B37 grafite; #56DDB5 olhos; #52368A roupa violeta; #17C9EF hologramas."""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
import biped_anims as A
import hero_lib as H

blend_out, glb_out = H.script_args()
H.reset_scene()

fur = H.material("zuri_fur", "#292B37")
fur_light = H.material("zuri_fur_light", "#3C4050")
violet = H.material("zuri_violet", "#52368A")
violet_dark = H.material("zuri_violet_dark", "#34205C")
holo = H.material("zuri_holo", "#17C9EF", emission=1.6)
eye = H.material("zuri_eye", "#56DDB5", emission=1.2)
dark = H.material("zuri_dark", "#12131A")
pink = H.material("zuri_pink", "#C98AA0")
silver = H.material("zuri_silver", "#A9B3C4", roughness=0.35)

arm = H.make_armature("ZuriRig", [
    ("root", None, (0, 0, 0), (0, 0, 0.1)),
    ("hips", "root", (0, 0, 0.66), (0, 0, 0.78)),
    ("spine", "hips", (0, 0, 0.78), (0, 0, 1.1)),
    ("head", "spine", (0, 0, 1.1), (0, 0, 1.5)),
    ("ear_l", "head", (0.0, 0.14, 1.4), (0.0, 0.14, 1.58)),
    ("ear_r", "head", (0.0, -0.14, 1.4), (0.0, -0.14, 1.58)),
    ("tail", "hips", (-0.14, 0, 0.8), (-0.55, 0, 1.0)),
    ("arm_l", "spine", (0, 0.24, 1.05), (0, 0.24, 0.62)),
    ("arm_r", "spine", (0, -0.24, 1.05), (0, -0.24, 0.62)),
    ("leg_l", "hips", (0, 0.11, 0.66), (0, 0.11, 0.05)),
    ("leg_r", "hips", (0, -0.11, 0.66), (0, -0.11, 0.05)),
])
parts = []


def add(obj, bone):
    parts.append((obj, bone))


# Tronco esguio, roupa violeta com hologramas
add(H.cube("torso", (0, 0, 0.94), (0.3, 0.38, 0.4), violet), "spine")
add(H.cube("jacket_collar", (0.0, 0, 1.13), (0.32, 0.4, 0.08), violet_dark), "spine")
add(H.cube("holo_stripe_l", (0.155, 0.1, 0.94), (0.025, 0.022, 0.3), holo), "spine")
add(H.cube("holo_stripe_r", (0.155, -0.1, 0.94), (0.025, 0.022, 0.3), holo), "spine")
add(H.cube("belt", (0, 0, 0.74), (0.32, 0.4, 0.06), violet_dark), "hips")
add(H.cube("hips_mesh", (0, 0, 0.7), (0.28, 0.34, 0.16), violet), "hips")
add(H.sphere("collar_light", (0.14, 0, 1.13), (0.04, 0.04, 0.04), holo), "spine")

# Cabeca felina refinada
add(H.sphere("head_mesh", (0.0, 0, 1.3), (0.22, 0.21, 0.2), fur), "head")
add(H.sphere("muzzle", (0.17, 0, 1.24), (0.1, 0.1, 0.07), fur_light), "head")
add(H.sphere("nose", (0.26, 0, 1.26), (0.03, 0.035, 0.025), pink), "head")
add(H.sphere("eye_l", (0.17, 0.085, 1.33), (0.05, 0.06, 0.07), eye), "head")
add(H.sphere("eye_r", (0.17, -0.085, 1.33), (0.05, 0.06, 0.07), eye), "head")
add(H.sphere("pupil_l", (0.205, 0.085, 1.33), (0.015, 0.02, 0.045), dark), "head")
add(H.sphere("pupil_r", (0.205, -0.085, 1.33), (0.015, 0.02, 0.045), dark), "head")
# Palpebras (a engine as mostra no piscar e ao tomar dano; ocultas no resto do tempo)
add(H.sphere("lid_l", (0.18, 0.085, 1.33), (0.068, 0.075, 0.085), fur), "head")
add(H.sphere("lid_r", (0.18, -0.085, 1.33), (0.068, 0.075, 0.085), fur), "head")
add(H.cone("ear_l_mesh", (0.0, 0.14, 1.5), 0.085, 0.24, fur, verts=4), "ear_l")
add(H.cone("ear_r_mesh", (0.0, -0.14, 1.5), 0.085, 0.24, fur, verts=4), "ear_r")
add(H.cone("ear_inner_l", (0.02, 0.14, 1.49), 0.045, 0.16, pink, verts=4), "ear_l")
add(H.cone("ear_inner_r", (0.02, -0.14, 1.49), 0.045, 0.16, pink, verts=4), "ear_r")

# Bracos, dispositivo de pulso e pernas esguias
for side, y, bone in (("l", 0.24, "arm_l"), ("r", -0.24, "arm_r")):
    add(H.limb("armmesh_" + side, (0, y, 1.04), (0, y, 0.64), 0.062, violet), bone)
    add(H.sphere("paw_" + side, (0, y, 0.62), (0.07, 0.07, 0.07), fur), bone)
add(H.cylinder("wrist_device", (0, 0.24, 0.7), 0.08, 0.09, silver), "arm_l")
add(H.cube("wrist_screen", (0.0, 0.24, 0.76), (0.1, 0.1, 0.02), holo), "arm_l")
for side, y, bone in (("l", 0.11, "leg_l"), ("r", -0.11, "leg_r")):
    add(H.limb("legmesh_" + side, (0, y, 0.66), (0, y, 0.16), 0.088, violet_dark), bone)
    add(H.cube("boot_" + side, (0.06, y, 0.07), (0.28, 0.16, 0.14), violet), bone)
    add(H.cube("boot_light_" + side, (0.0, y, 0.12), (0.2, 0.17, 0.03), holo), bone)

# Cauda longa e livre
add(H.cone("tail_mesh", (-0.34, 0, 0.92), 0.075, 0.58, fur, rot=(0, math.radians(-68), 0), verts=8), "tail")
add(H.sphere("tail_ring", (-0.55, 0, 1.0), (0.06, 0.06, 0.06), holo), "tail")

for obj, bone in parts:
    H.skin(obj, bone, arm)
A.build_actions(arm)
H.export_glb(arm, blend_out, glb_out)
print("ZURI_OK", len(parts), "partes", glb_out)
