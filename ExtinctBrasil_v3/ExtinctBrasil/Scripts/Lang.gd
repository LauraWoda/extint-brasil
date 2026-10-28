extends Node
## Autoload "Lang": idiomas do jogo.
##   pt_BR ... Português (Brasil)   <- padrão
##   en_US ... Inglês (Estados Unidos)
##
## - Textos da interface: Lang.t("chave") ou Lang.t("chave", [arg1, arg2]).
##   Cada chave tem [português, inglês] no dicionário S abaixo.
## - Dados (equipe, missões, espécies): o inglês fica em Data/en/*.json
##   (mesma estrutura dos arquivos em Data/). Use Lang.data_path("equipe").
## - Falas dos NPCs e nomes dos mapas em inglês: Data/en/textos.json.
## - O idioma escolhido fica salvo em user://settings.json (separado do save do jogo).
##
## Para adicionar um terceiro idioma no futuro: acrescente o código em CODES,
## uma terceira posição em cada texto de S e uma pasta Data/<código>/.

signal changed

const SETTINGS_PATH := "user://settings.json"
const CODES := ["pt_BR", "en_US"]
const NAMES := {"pt_BR": "PT-BR", "en_US": "EN-US"}
const DEFAULT_CODE := "pt_BR"
const EN_TEXTS_PATH := "res://Data/en/textos.json"

var code: String = DEFAULT_CODE
var _en_texts: Dictionary = {}

const S := {
	# ---------------------------------------------------------- tela inicial
	"menu_new": ["NOVO JOGO", "NEW GAME"],
	"menu_continue": ["CONTINUAR", "CONTINUE"],
	"menu_options": ["OPÇÕES", "OPTIONS"],
	"no_save": [
		"Nenhum jogo salvo ainda.\n\nComece um NOVO JOGO!\n\n(%s)",
		"No saved game yet.\n\nStart a NEW GAME!\n\n(%s)"],
	"close_z": ["Z para fechar", "Z to close"],
	"close_tap": ["Toque para fechar", "Tap to close"],
	"controls_touch": [
		"CONTROLES NO CELULAR\n\nDirecional na tela: andar\nA: interagir / avançar texto\nB: voltar\nECODEX e MISSÕES: botões no topo\nToque na tela: avançar diálogos\n\n(Toque para fechar)",
		"MOBILE CONTROLS\n\nOn-screen D-pad: move\nA: interact / advance text\nB: go back\nECODEX and MISSIONS: buttons at the top\nTap the screen: advance dialogues\n\n(Tap to close)"],
	"controls_kb": [
		"CONTROLES\n\nSetas ou WASD: andar\nZ, Enter ou Espaço: interagir\nX ou Esc: voltar\nC: ECODEX    M: MISSÕES\nL: idioma\nF9: reiniciar progresso (teste)\nF10: controles de toque (teste)\n\n(Z para fechar)",
		"CONTROLS\n\nArrows or WASD: move\nZ, Enter or Space: interact\nX or Esc: go back\nC: ECODEX    M: MISSIONS\nL: language\nF9: reset progress (test)\nF10: touch controls (test)\n\n(Z to close)"],
	"lang_hint": ["L: idioma", "L: language"],

	# ------------------------------------------------- escolha do caçador
	"cs_title": ["ESCOLHA SEU CAÇADOR", "CHOOSE YOUR HUNTER"],
	"cs_perk": ["VANTAGEM", "PERK"],
	"cs_who": ["Quem vai jogar?", "Who will play?"],
	"cs_back": ["< VOLTAR", "< BACK"],
	"cs_start": ["PRESSIONE START", "PRESS START"],
	"cs_reserved": ["RESERVADO", "RESERVED"],
	"cs_soon": ["Em breve!", "Coming soon!"],
	"cs_play_with": ["Jogar com %s?", "Play as %s?"],
	"cs_confirm_kb": ["Z: CONFIRMAR    X: VOLTAR", "Z: CONFIRM    X: BACK"],
	"cs_confirm_touch": ["TOQUE DE NOVO PARA CONFIRMAR", "TAP AGAIN TO CONFIRM"],
	"cs_tap_hunter": ["TOQUE NO CAÇADOR", "TAP A HUNTER"],
	"cs_slot_reserved": ["Esta vaga está reservada!", "This slot is reserved!"],

	# ---------------------------------------------------------------- mundo
	"hint_keys": [
		"Setas/WASD: andar   Z: interagir   C: ECODEX   M: MISSÕES",
		"Arrows/WASD: move   Z: interact   C: ECODEX   M: MISSIONS"],
	"narrator": ["Narração", "Narrator"],
	"get_ecomax": ["Pegue o ECOMAX com o %s", "Get the ECOMAX from %s"],
	"debug_reset": ["ECODEX e missões reiniciadas", "ECODEX and missions reset"],
	"intro_1": ["EXTINCT: BRASIL - THE TIME HUNTERS", "EXTINCT: BRASIL - THE TIME HUNTERS"],
	"intro_2": [
		"Seis jovens exploradores brasileiros construíram a TEMPORAL CAPSULE, uma tecnologia capaz de abrir portais para o passado.",
		"Six young Brazilian explorers built the TEMPORAL CAPSULE, a technology able to open portals to the past."],
	"intro_3": [
		"A missão: encontrar animais que realmente existiram, estudá-los sem machucá-los e registrar tudo na ECODEX.",
		"The mission: find animals that really existed, study them without hurting them, and record everything in the ECODEX."],
	"intro_4": [
		"Você é %s, %s. Procure o PROF. PROENÇA aqui no laboratório: ele tem um equipamento importante para você.",
		"You are %s, %s. Look for PROF. PROENÇA here in the lab: he has important equipment for you."],
	"role_default": ["líder da equipe", "team leader"],

	# ---------------------------------------------------- Prof. Proença
	"tip_c": ["aperte C", "press C"],
	"tip_ecodex_btn": ["botão ECODEX", "ECODEX button"],
	"tip_m": ["aperte M", "press M"],
	"tip_missions_btn": ["botão MISSÕES", "MISSIONS button"],
	"tip_m_key": ["tecla M", "M key"],
	"prof_hello": [
		"Ah, %s! Que bom que você chegou. Sou o Professor Proença, coordenador do projeto EXTINCT: BRASIL.",
		"Ah, %s! Glad you made it. I'm Professor Proença, coordinator of the EXTINCT: BRASIL project."],
	"prof_capsule": [
		"A TEMPORAL CAPSULE abre portais para o passado, mas ninguém viaja no tempo sem equipamento de campo.",
		"The TEMPORAL CAPSULE opens portals to the past, but nobody travels through time without field equipment."],
	"prof_ecomax": [
		"Tome: este é o ECOMAX, o meu aparelho de pesquisa mais novo!",
		"Here: this is the ECOMAX, my newest research device!"],
	"prof_received": ["%s recebeu o ECOMAX!", "%s received the ECOMAX!"],
	"prof_ecomax_info": [
		"Ele guarda a ECODEX (%s) e a lista de MISSÕES (%s), e avisa quando você cumprir uma tarefa.",
		"It holds the ECODEX (%s) and the MISSIONS list (%s), and lets you know when you complete a task."],
	"prof_attention": [
		"Agora preste atenção no que você precisa fazer:",
		"Now pay attention to what you need to do:"],
	"mission_your": ["Sua missão: %s.", "Your mission: %s."],
	"mission_back": [
		"Volte a falar comigo quando terminar. Pode conferir a lista no ECOMAX (%s).",
		"Come talk to me when you're done. You can check the list on the ECOMAX (%s)."],
	"prof_all_1": [
		"Todas as missões foram cumpridas! Não tenho mais nada a pedir, %s.",
		"All missions complete! I have nothing more to ask of you, %s."],
	"prof_all_2": [
		"Mas nunca é demais estudar mais um pouco: cada encontro com uma criatura ensina algo novo.",
		"But there's always more to learn: every creature encounter teaches something new."],
	"prof_current": ["Missão atual: %s (%d/%d).", "Current mission: %s (%d/%d)."],
	"prof_when_done": [
		"Quando terminar, volte aqui. Você também pode conferir tudo no ECOMAX (%s).",
		"When you're done, come back here. You can also check everything on the ECOMAX (%s)."],
	"prof_done_data": [
		"Missão cumprida: %s! O ECOMAX já me enviou os dados.",
		"Mission complete: %s! The ECOMAX already sent me the data."],
	"prof_bonus_caps": [
		"%s ganhou +%d CÁPSULA(S) em cada encontro!",
		"%s gained +%d CAPSULE(S) in every encounter!"],
	"prof_ready_next": ["Pronto para a próxima missão?", "Ready for the next mission?"],
	"final_1": [
		"Você cumpriu TODAS as missões e completou a ECODEX! Que expedição incrível.",
		"You completed ALL the missions and filled the ECODEX! What an incredible expedition."],
	"final_2": [
		"O projeto EXTINCT: BRASIL nunca teve exploradores melhores. Parabéns, equipe!",
		"The EXTINCT: BRASIL project has never had better explorers. Congratulations, team!"],
	"final_3": [
		"Continue explorando o Pleistoceno: sempre há algo novo para observar nos encontros.",
		"Keep exploring the Pleistocene: there is always something new to observe in the encounters."],
	"obj_talk": ["Objetivo: fale com o %s", "Objective: talk to %s"],
	"obj_all": ["Todas as missões cumpridas!", "All missions complete!"],
	"obj_mission": ["Missão: %s (%d/%d)", "Mission: %s (%d/%d)"],
	"quest_banner": ["MISSÃO CUMPRIDA! Fale com o %s", "MISSION COMPLETE! Talk to %s"],
	"portal_name": ["Portal", "Portal"],
	"portal_off": [
		"O portal está desligado. Sem o ECOMAX não dá para viajar no tempo com segurança.",
		"The portal is off. Without the ECOMAX it isn't safe to travel through time."],
	"portal_back": ["Volte ao laboratório e fale com o %s.", "Go back to the lab and talk to %s."],

	# ------------------------------------------------------------ encontro
	"track_1": ["%s segue pegadas frescas na lama.", "%s follows fresh tracks in the mud."],
	"track_2": [
		"%s ouve movimento entre a vegetação e se aproxima devagar.",
		"%s hears movement in the vegetation and slowly moves closer."],
	"track_3": [
		"Marcas em um tronco mostram por onde a criatura passou.",
		"Marks on a tree trunk show where the creature passed."],
	"track_4": [
		"%s observa a criatura de longe, sem fazer barulho.",
		"%s watches the creature from afar, without making a sound."],
	"btn_scan": ["ESCANEAR", "SCAN"],
	"btn_track": ["RASTREAR", "TRACK"],
	"btn_capsule": ["CÁPSULA", "CAPSULE"],
	"btn_leave": ["RECUAR", "RETREAT"],
	"sig_title": ["SINAL DE RASTREIO", "TRACKING SIGNAL"],
	"enc_appeared": ["Uma criatura temporal apareceu: %s!", "A temporal creature appeared: %s!"],
	"enc_new": [
		"Nova espécie descoberta! O registro #%03d foi aberto na ECODEX.",
		"New species discovered! Entry #%03d was opened in the ECODEX."],
	"enc_what": ["O que %s vai fazer?", "What will %s do?"],
	"enc_status": ["Cápsulas: %d    Tempo: %d", "Capsules: %d    Time: %d"],
	"enc_scan_done": [
		"O scanner já registrou tudo o que podia sobre esta espécie.",
		"The scanner has already recorded everything it could about this species."],
	"enc_scan_head": ["ESCANEAR: %s (%s).", "SCAN: %s (%s)."],
	"enc_scan_info": ["Habitat: %s. Alimentação: %s.", "Habitat: %s. Diet: %s."],
	"enc_scan_bonus": [
		"Os dados reforçaram o sinal de rastreio! (+%d)",
		"The data strengthened the tracking signal! (+%d)"],
	"enc_track_up": ["O sinal de rastreio aumentou! (+%d)", "The tracking signal increased! (+%d)"],
	"enc_throw": ["%s lançou a CÁPSULA TEMPORAL!", "%s threw the TEMPORAL CAPSULE!"],
	"enc_failed": [
		"O campo temporal falhou... %s resistiu à cápsula.",
		"The temporal field failed... %s resisted the capsule."],
	"enc_no_caps": [
		"Acabaram as cápsulas. A criatura se afastou em segurança.",
		"Out of capsules. The creature moved away safely."],
	"enc_leave": [
		"%s recuou em silêncio e a criatura seguiu seu caminho.",
		"%s quietly backed away and the creature went on its way."],
	"enc_weak": [
		"O sinal temporal enfraqueceu e %s se afastou.",
		"The temporal signal weakened and %s moved away."],
	"enc_glow": [
		"A cápsula brilhou e o sinal ficou estável!",
		"The capsule glowed and the signal became stable!"],
	"enc_studied": [
		"%s foi estudada e registrada na ECODEX! (%d/%d)",
		"%s was studied and recorded in the ECODEX! (%d/%d)"],
	"enc_unlocked": [
		"Novos dados liberados: Curiosidade e História.",
		"New data unlocked: Fun Fact and History."],
	"enc_returned": [
		"A criatura foi devolvida em segurança ao seu tempo.",
		"The creature was safely returned to its own time."],

	# --------------------------------------------------------------- ECODEX
	"dex_header": [
		"ECODEX    Descobertas: %d/%d    Estudadas: %d/%d",
		"ECODEX    Discovered: %d/%d    Studied: %d/%d"],
	"dex_foot_kb": ["Setas: escolher    X ou C: fechar", "Arrows: select    X or C: close"],
	"dex_foot_touch": ["Toque numa espécie para ver a ficha", "Tap a species to see its entry"],
	"btn_close": ["FECHAR", "CLOSE"],
	"dex_unknown": [
		"Espécie ainda não descoberta.\n\nExplore as regiões e procure rastros no capim alto.",
		"Species not discovered yet.\n\nExplore the regions and look for tracks in the tall grass."],
	"lbl_period": ["Período", "Period"],
	"lbl_region": ["Região", "Region"],
	"lbl_habitat": ["Habitat", "Habitat"],
	"lbl_diet": ["Alimentação", "Diet"],
	"lbl_size": ["Tamanho", "Size"],
	"lbl_status": ["Status", "Status"],
	"lbl_fun": ["Curiosidade", "Fun fact"],
	"lbl_history": ["Informação histórica", "Historical info"],
	"dex_locked": [
		"Capture esta espécie com a Temporal Capsule para estudar a Curiosidade e a Informação histórica.",
		"Capture this species with the Temporal Capsule to unlock its Fun Fact and Historical Info."],

	# ------------------------------------------------------------- missões
	"ms_title": ["ECOMAX - MISSÕES", "ECOMAX - MISSIONS"],
	"ms_hint_kb": ["X, M ou Z: fechar", "X, M or Z: close"],
	"ms_hint_touch": ["Toque na tela para fechar", "Tap the screen to close"],
	"ms_summary": [
		"Concluídas: %d / %d      Cápsulas extras: +%d",
		"Completed: %d / %d      Extra capsules: +%d"],
	"ms_complete": [
		"Cumprida! Fale com o Prof. Proença no laboratório.",
		"Complete! Talk to Prof. Proença in the lab."],
	"ms_all": ["Todas as missões foram cumpridas. Parabéns!", "All missions complete. Congratulations!"],

	# ---------------------------------------------------------------- toque
	"touch_ecodex": ["ECODEX", "ECODEX"],
	"touch_missions": ["MISSÕES", "MISSIONS"],
	"rotate": [
		"GIRE O CELULAR\n\npara jogar na horizontal",
		"ROTATE YOUR PHONE\n\nto play in landscape"],
}


func _ready() -> void:
	code = _load_code()


func is_en() -> bool:
	return code == "en_US"


## Texto da interface no idioma atual. Com argumentos: Lang.t("chave", [a, b]).
func t(key: String, args: Array = []) -> String:
	var entry = S.get(key)
	if entry == null:
		push_warning("Texto sem tradução: " + key)
		return key
	var text: String = str(entry[1]) if is_en() else str(entry[0])
	if args.is_empty():
		return text
	return text % args


## Caminho de um arquivo de dados no idioma atual (ex.: "equipe", "missoes", "species").
func data_path(data_name: String) -> String:
	if is_en():
		var p := "res://Data/en/%s.json" % data_name
		if FileAccess.file_exists(p) or ResourceLoader.exists(p):
			return p
	return "res://Data/%s.json" % data_name


## Nome do mapa no idioma atual.
func map_name(map_id: String, fallback: String) -> String:
	if not is_en():
		return fallback
	var maps = _texts().get("mapas", {})
	var info = maps.get(map_id, {})
	return str(info.get("name", fallback))


## Dados de um NPC (falas e nome) no idioma atual.
func npc_data(map_id: String, d: Dictionary) -> Dictionary:
	if not is_en():
		return d
	var maps = _texts().get("mapas", {})
	var info = maps.get(map_id, {})
	var over = info.get("npcs", {}).get(str(d.get("id", "")), {})
	if not (over is Dictionary) or (over as Dictionary).is_empty():
		return d
	var out: Dictionary = d.duplicate()
	for k in over:
		out[k] = over[k]
	return out


func _texts() -> Dictionary:
	if _en_texts.is_empty():
		var data = _read_json_direct(EN_TEXTS_PATH)
		if data is Dictionary:
			_en_texts = data
	return _en_texts


func _read_json_direct(path: String) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	return data


func set_language(new_code: String) -> void:
	if not CODES.has(new_code) or new_code == code:
		return
	code = new_code
	_save()
	changed.emit()


## Alterna entre os idiomas (tecla L).
func toggle() -> void:
	set_language("en_US" if code == "pt_BR" else "pt_BR")


func _load_code() -> String:
	if FileAccess.file_exists(SETTINGS_PATH):
		var f := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		if f != null:
			var d = JSON.parse_string(f.get_as_text())
			f.close()
			if d is Dictionary and CODES.has(str(d.get("language", ""))):
				return str(d["language"])
	# primeira vez: usa o idioma do aparelho/navegador
	if OS.get_locale().to_lower().begins_with("en"):
		return "en_US"
	return DEFAULT_CODE


func _save() -> void:
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({"language": code}))
	f.close()
