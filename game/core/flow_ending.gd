class_name FlowEnding
extends RefCounted
## Reacao de Caeldron, sequencia final (morte de Caeldron) e creditos. Os contadores e o estado ficam no GameFlow.


## A destruicao da semente e salva NA HORA (nao so ao abrir o bau); a reacao de Caeldron toca so na primeira vez.
static func seed_destroyed(flow: GameFlow, first_time: bool) -> void:
	flow.last_save_error = flow.service.save(flow.profile)
	var reaction: CaeldronReaction = null
	if first_time:
		flow.reaction_plays += 1
		reaction = CaeldronReaction.new()
		var custom: Variant = flow.level.get("reaction_message")
		if custom is String and custom != "":
			reaction.message = custom
		flow.add_child(reaction)
	# Sexta semente: Caeldron morre. A sequencia final e uma transacao unica (nao repete ao recarregar nem ao revisitar).
	if ProgressLedger.new().claim_campaign_end(flow.profile)["first_time"]:
		flow.last_save_error = flow.service.save(flow.profile)
		flow._ending_active = true
		if reaction != null:
			reaction.finished.connect(flow._play_ending)
		else:
			flow._play_ending()


## Morte de Caeldron (pulavel) -> creditos (pulaveis). O jogo fica pausado enquanto dura; nada do save muda aqui.
static func play_ending(flow: GameFlow) -> void:
	flow.ending_plays += 1
	flow.get_tree().paused = true
	var death := CaeldronDeath.new()
	flow.add_child(death)
	death.finished.connect(func() -> void: flow._show_credits(true))


static func show_credits(flow: GameFlow, from_ending: bool) -> void:
	flow.credits_plays += 1
	var credits := CreditsScreen.new()
	flow.add_child(credits)
	credits.finished.connect(func() -> void:
		if from_ending:
			flow._ending_active = false
			flow.get_tree().paused = false)
