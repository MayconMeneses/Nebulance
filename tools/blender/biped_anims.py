"""Conjunto padrao de animacoes dos herois (contrato de nomes): idle, run, jump, fall, land, special, hurt, celebrate.
Roda dentro do Blender. Cada heroi pode sobrescrever 'special' (dash, escalada, planeio)."""
import hero_lib as H

CLIPS = ["idle", "run", "jump", "fall", "land", "special", "hurt", "celebrate"]


def key(arm_obj, frame, poses):
    """poses: {osso: dict(swing=,tilt=,twist=,up=,fwd=)}; ossos omitidos voltam ao repouso neste quadro."""
    for pb in arm_obj.pose.bones:
        H.pose(arm_obj, frame, pb.name, **poses.get(pb.name, {}))


def build_actions(arm_obj, arms=("arm_l", "arm_r"), special=None):
    al, ar = arms

    # idle: respiracao suave (laco de 48 quadros)
    H.new_action(arm_obj, "idle-loop", 49)
    for f, bob, tail, head in ((1, 0.0, 10, 2), (25, 0.02, -10, -2), (49, 0.0, 10, 2)):
        key(arm_obj, f, {"hips": dict(up=bob), "tail": dict(swing=tail), "head": dict(swing=head),
                         al: dict(swing=3 if f != 25 else -3), ar: dict(swing=-3 if f != 25 else 3)})

    # run: ciclo de corrida (laco de 16 quadros)
    H.new_action(arm_obj, "run-loop", 17)
    for f, leg, bob, tail in ((1, 40, 0.0, 15), (5, 0, 0.05, 0), (9, -40, 0.0, -15), (13, 0, 0.05, 0), (17, 40, 0.0, 15)):
        key(arm_obj, f, {"leg_l": dict(swing=leg), "leg_r": dict(swing=-leg), al: dict(swing=-leg * 0.85),
                         ar: dict(swing=leg * 0.85), "hips": dict(up=bob), "spine": dict(swing=-10),
                         "head": dict(swing=5), "tail": dict(swing=tail)})

    # jump: subida (membros recolhidos, bracos para cima)
    H.new_action(arm_obj, "jump", 9)
    for f in (1, 5, 9):
        key(arm_obj, f, {"leg_l": dict(swing=30), "leg_r": dict(swing=-15), al: dict(swing=120), ar: dict(swing=120),
                         "spine": dict(swing=-5), "tail": dict(swing=20)})

    # fall: queda (bracos abertos para cima, pernas soltas)
    H.new_action(arm_obj, "fall", 9)
    for f in (1, 5, 9):
        key(arm_obj, f, {"leg_l": dict(swing=15), "leg_r": dict(swing=15), al: dict(swing=150), ar: dict(swing=150),
                         "tail": dict(swing=-20), "head": dict(swing=-5)})

    # land: amortecimento do pouso
    H.new_action(arm_obj, "land", 7)
    for f, down in ((1, 0.0), (3, -0.12), (7, -0.04)):
        key(arm_obj, f, {"hips": dict(up=down), "leg_l": dict(swing=35), "leg_r": dict(swing=35),
                         al: dict(swing=20), ar: dict(swing=20), "spine": dict(swing=-8)})

    # special: padrao = investida (inclinacao para frente, bracos para tras); herois sobrescrevem
    H.new_action(arm_obj, "special", 13)
    for f in (1, 7, 13):
        if special:
            special(arm_obj, f)
        else:
            key(arm_obj, f, {"spine": dict(swing=-25), "head": dict(swing=-10), al: dict(swing=-70), ar: dict(swing=-70),
                             "leg_l": dict(swing=45), "leg_r": dict(swing=-45), "tail": dict(swing=25)})

    # hurt: recuo
    H.new_action(arm_obj, "hurt", 11)
    for f, back in ((1, 10), (6, 22), (11, 12)):
        key(arm_obj, f, {"spine": dict(swing=back), "head": dict(swing=back * 0.8), al: dict(swing=60), ar: dict(swing=-40),
                         "hips": dict(up=-0.03), "tail": dict(swing=-20)})

    # celebrate: pulinhos com bracos para cima (laco de 24 quadros)
    H.new_action(arm_obj, "celebrate-loop", 25)
    for f, bob, tail in ((1, 0.0, 30), (7, 0.12, -30), (13, 0.0, 30), (19, 0.12, -30), (25, 0.0, 30)):
        key(arm_obj, f, {"hips": dict(up=bob), al: dict(swing=160), ar: dict(swing=160), "tail": dict(swing=tail),
                         "head": dict(swing=-4 if f in (7, 19) else 4)})
