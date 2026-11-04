"""Biblioteca de modelagem procedural estilizada (roda DENTRO do Blender, --background).
Convencoes: 1 unidade = 1 m; pes em z=0; personagem olha para +X; Z para cima.
Ossos que apontam para cima: eixo local X = global X, Y = Z global, Z = -Y global.
Por isso 'swing' (balanco frente/tras) gira em torno do eixo local Z.
Para membros que apontam para BAIXO, swing positivo = para frente (+X); para ossos que apontam para CIMA, positivo = para tras."""
import math
import sys

import bpy
from mathutils import Euler, Vector


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def hex_color(value):
    value = value.lstrip("#")
    r, g, b = (int(value[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
    lin = lambda c: ((c + 0.055) / 1.055) ** 2.4 if c > 0.04045 else c / 12.92
    return (lin(r), lin(g), lin(b), 1.0)


_MATS = {}


def material(name, hex_value, emission=0.0, roughness=0.65, metallic=0.0):
    if name in _MATS:
        return _MATS[name]
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = hex_color(hex_value)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    if emission > 0.0:
        bsdf.inputs["Emission Color"].default_value = hex_color(hex_value)
        bsdf.inputs["Emission Strength"].default_value = emission
    _MATS[name] = mat
    return mat


def _apply_modifiers(obj):
    """Assenta bevel/subdivisao na malha: o export NAO aplica modificadores (export_apply=False), entao sem isto as quinas saem duras."""
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    for mod in list(obj.modifiers):
        if mod.type != "ARMATURE":
            bpy.ops.object.modifier_apply(modifier=mod.name)


def _finish(obj, name, mat, smooth=True):
    _apply_modifiers(obj)
    obj.name = name
    obj.data.name = name
    obj.data.materials.append(mat)
    if smooth:
        for poly in obj.data.polygons:
            poly.use_smooth = True
    return obj


def sphere(name, loc, scale, mat, segments=16, rings=10):
    """Esfera com detalhe proporcional ao tamanho (peca pequena = poucos triangulos): o orcamento dos herois e de 4000 triangulos."""
    if max(scale) < 0.1:
        segments, rings = 10, 6
    elif max(scale) < 0.2:
        segments, rings = 12, 8
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, radius=1.0, location=loc)
    obj = bpy.context.active_object
    obj.scale = scale
    return _finish(obj, name, mat)


def cube(name, loc, scale, mat, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=loc, rotation=rot)
    obj = bpy.context.active_object
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bevel = obj.modifiers.new("bevel", "BEVEL")
    bevel.width = min(scale) * 0.32
    bevel.segments = 2 if max(scale) >= 0.3 else 1
    return _finish(obj, name, mat)


def limb(name, top, bottom, radius, mat):
    """Membro macio (elipsoide) entre dois pontos na vertical: bem mais organico que um cilindro."""
    center = ((top[0] + bottom[0]) / 2.0, (top[1] + bottom[1]) / 2.0, (top[2] + bottom[2]) / 2.0)
    half = abs(top[2] - bottom[2]) / 2.0 + radius * 0.45
    return sphere(name, center, (radius, radius, half), mat, segments=12, rings=8)


def cylinder(name, loc, radius, depth, mat, rot=(0, 0, 0), verts=12, scale=(1, 1, 1)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius, depth=depth, location=loc, rotation=rot)
    obj = bpy.context.active_object
    obj.scale = scale
    return _finish(obj, name, mat)


def cone(name, loc, radius, depth, mat, rot=(0, 0, 0), verts=10, scale=(1, 1, 1)):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=radius, radius2=0.0, depth=depth, location=loc, rotation=rot)
    obj = bpy.context.active_object
    obj.scale = scale
    return _finish(obj, name, mat)


def make_armature(name, bones):
    """bones: lista de (nome, pai|None, cabeca, cauda)."""
    bpy.ops.object.armature_add(enter_editmode=True, location=(0, 0, 0))
    arm_obj = bpy.context.active_object
    arm_obj.name = name
    arm = arm_obj.data
    arm.name = name
    for b in list(arm.edit_bones):
        arm.edit_bones.remove(b)
    for bone_name, parent, head, tail in bones:
        eb = arm.edit_bones.new(bone_name)
        eb.head = Vector(head)
        eb.tail = Vector(tail)
        eb.roll = 0.0
        if parent:
            eb.parent = arm.edit_bones[parent]
    bpy.ops.object.mode_set(mode="OBJECT")
    return arm_obj


def skin(obj, bone_name, arm_obj):
    """Skinning rigido: todos os vertices da peca no osso (peso 1.0)."""
    group = obj.vertex_groups.new(name=bone_name)
    group.add([v.index for v in obj.data.vertices], 1.0, "REPLACE")
    mod = obj.modifiers.new("Armature", "ARMATURE")
    mod.object = arm_obj
    obj.parent = arm_obj


def pose(arm_obj, frame, bone_name, swing=0.0, tilt=0.0, twist=0.0, up=0.0, fwd=0.0):
    """Define e keyeia a pose de um osso. Angulos em graus; up/fwd em metros (espaco GLOBAL do repouso)."""
    pb = arm_obj.pose.bones[bone_name]
    pb.rotation_mode = "XYZ"
    pb.rotation_euler = Euler((math.radians(tilt), math.radians(twist), math.radians(swing)), "XYZ")
    pb.location = Vector((fwd, up, 0.0))
    pb.keyframe_insert("rotation_euler", frame=frame)
    pb.keyframe_insert("location", frame=frame)


def new_action(arm_obj, name, length):
    if arm_obj.animation_data is None:
        arm_obj.animation_data_create()
    action = bpy.data.actions.new(name)
    action.use_fake_user = True
    arm_obj.animation_data.action = action
    for pb in arm_obj.pose.bones:
        pb.rotation_mode = "XYZ"
        pb.rotation_euler = (0, 0, 0)
        pb.location = (0, 0, 0)
    bpy.context.scene.frame_start = 1
    bpy.context.scene.frame_end = length
    return action


def export_glb(arm_obj, blend_path, glb_path):
    bpy.ops.wm.save_as_mainfile(filepath=blend_path)
    arm_obj.animation_data.action = None
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=glb_path, export_format="GLB", export_apply=False,
                              export_animations=True, export_animation_mode="ACTIONS",
                              export_skins=True, export_yup=True, export_materials="EXPORT",
                              export_force_sampling=True)


def script_args():
    return sys.argv[sys.argv.index("--") + 1:]
