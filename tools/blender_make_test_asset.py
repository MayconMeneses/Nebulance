"""Roda DENTRO do Blender (--background --python). Cria um cubo com material,
salva o .blend original e exporta .glb. Uso: ver docs/ASSET_PIPELINE.md."""
import bpy
import sys

blend_out, glb_out = sys.argv[sys.argv.index("--") + 1:][:2]

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.5))
cube = bpy.context.active_object
cube.name = "test_cube"
mat = bpy.data.materials.new("test_cube_mat")
mat.diffuse_color = (0.1, 0.8, 0.9, 1.0)
cube.data.materials.append(mat)
bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)

bpy.ops.wm.save_as_mainfile(filepath=blend_out)
bpy.ops.export_scene.gltf(filepath=glb_out, export_format="GLB", export_apply=True)
print("BLENDER_PIPELINE_OK", blend_out, glb_out)
