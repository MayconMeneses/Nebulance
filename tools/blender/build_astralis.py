"""Astralis: nave de exploracao em forma de arraia (casco branco-perolado, azul-marinho e ciano, cockpit panoramico, tres propulsores).
Sem armas. Uso: blender --background --python tools/blender/build_astralis.py -- <saida.blend> <saida.glb>
Convencao: ~6 m de comprimento, olha para +X; origem no centro."""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
import bpy
import hero_lib as H

blend_out, glb_out = H.script_args()
H.reset_scene()

pearl = H.material("astralis_pearl", "#EEF2F7", roughness=0.35)
navy = H.material("astralis_navy", "#1C416B", roughness=0.5)
cyan = H.material("astralis_cyan", "#23CFF5", emission=3.0)
glass = H.material("astralis_glass", "#8FE3F5", emission=0.5, roughness=0.1)
dark = H.material("astralis_dark", "#1A1F2B")

parts = []

# Casco central em arraia
parts.append(H.sphere("hull", (0, 0, 0), (2.4, 1.0, 0.55), pearl, segments=18, rings=10))
parts.append(H.sphere("belly", (0, 0, -0.18), (2.2, 0.9, 0.35), navy, segments=18, rings=10))
parts.append(H.cone("nose", (2.5, 0, 0.0), 0.34, 1.0, pearl, rot=(0, math.radians(90), 0), verts=10, scale=(1, 1.4, 0.8)))
# Asas curvas (arraia): duas lascas inclinadas para tras
for side, sign in (("l", 1), ("r", -1)):
    parts.append(H.cube("wing_" + side, (-0.3, sign * 2.1, 0.0), (2.4, 2.6, 0.12), pearl, rot=(math.radians(-sign * 8), 0, math.radians(-sign * 24))))
    parts.append(H.cube("wing_trim_" + side, (-0.3, sign * 2.1, -0.07), (2.4, 2.6, 0.06), navy, rot=(math.radians(-sign * 8), 0, math.radians(-sign * 24))))
    parts.append(H.cube("wing_light_" + side, (0.6, sign * 2.9, 0.1), (0.9, 0.08, 0.04), cyan, rot=(0, 0, math.radians(-sign * 24))))
# Cockpit panoramico
parts.append(H.sphere("cockpit", (1.3, 0, 0.42), (0.9, 0.55, 0.34), glass, segments=16, rings=8))
parts.append(H.cube("cockpit_frame", (1.3, 0, 0.25), (1.2, 0.8, 0.06), navy))
# Tres propulsores (cauda) com disco ciano
for i, y in enumerate((-0.7, 0.0, 0.7), start=1):
    parts.append(H.cylinder("thruster_%d" % i, (-2.5, y, 0.0), 0.28, 0.9, dark, rot=(0, math.radians(90), 0), verts=14))
    parts.append(H.cylinder("thruster_glow_%d" % i, (-2.98, y, 0.0), 0.22, 0.06, cyan, rot=(0, math.radians(90), 0), verts=14))
# Faixa de luz central
parts.append(H.cube("spine_light", (0.2, 0, 0.5), (2.2, 0.06, 0.04), cyan))

bpy.ops.object.select_all(action="DESELECT")
root = bpy.data.objects.new("AstralisRoot", None)
bpy.context.scene.collection.objects.link(root)
for p in parts:
    p.parent = root
bpy.ops.wm.save_as_mainfile(filepath=blend_out)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.export_scene.gltf(filepath=glb_out, export_format="GLB", export_apply=True, export_animations=False,
                          export_yup=True, export_materials="EXPORT")
print("ASTRALIS_OK", len(parts), "partes", glb_out)
