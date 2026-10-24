extends Node2D
## Script de cada NIVEL (Nivel1 y Nivel2 usan el mismo script).
##
## - Pone la mira como cursor del mouse (Kenney Cursor Pixel Pack).
## - Maneja la transición entre niveles con un fundido a negro: un CanvasLayer
##   (que se dibuja adelante de todo) con un ColorRect negro que ocupa toda la
##   pantalla y un AnimationPlayer con dos animaciones:
##     "inicio": de negro a transparente (arranca sola al empezar el nivel).
##     "final":  de transparente a negro (antes de cargar el nivel siguiente).
## - Se pasa de nivel con la tecla Escape (como en clase) o al eliminar a
##   todos los enemigos.

## Escena que se carga al terminar este nivel.
@export_file("*.tscn") var siguiente_nivel: String = ""
@export var nombre_nivel: String = "Nivel 1"

const TEXTURA_MIRA_RUTA: String = "res://assets/Tiles/tile_0057.png"
const ESCALA_MIRA: int = 2

var cambiando_nivel: bool = false

@onready var jugador: CharacterBody2D = $Jugador
@onready var animation_player: AnimationPlayer = $Transicion/AnimationPlayer
@onready var label_energia: Label = $HUD/LabelEnergia
@onready var label_nivel: Label = $HUD/LabelNivel


func _ready() -> void:
	poner_mira()
	label_nivel.text = nombre_nivel
	label_energia.text = "Energía: " + str(jugador.energia)
	jugador.energia_cambiada.connect(_on_jugador_energia_cambiada)
	jugador.murio.connect(reiniciar_nivel)


## Cambia el cursor del mouse por una mira (código del ejemplo de la
## documentación: Input.set_custom_mouse_cursor). Primero hay que cargar el
## recurso con load() para tener la textura.
func poner_mira() -> void:
	var textura_mira: Texture2D = load(TEXTURA_MIRA_RUTA)
	# El tile de Kenney es de 16x16; lo agrandamos x2 para que se vea mejor.
	var imagen: Image = textura_mira.get_image()
	imagen.resize(imagen.get_width() * ESCALA_MIRA, imagen.get_height() * ESCALA_MIRA, Image.INTERPOLATE_NEAREST)
	var mira: ImageTexture = ImageTexture.create_from_image(imagen)
	# El último parámetro (hotspot) es el centro de la cruz.
	Input.set_custom_mouse_cursor(mira, Input.CURSOR_ARROW, Vector2(imagen.get_width(), imagen.get_height()) / 2.0)


func _process(_delta: float) -> void:
	if cambiando_nivel:
		return
	# Escape = "terminé el nivel" (en clase se hizo así para probar rápido).
	if Input.is_action_just_pressed("ui_cancel"):
		pasar_de_nivel()
	# Si no quedan enemigos, también se pasa de nivel.
	elif get_tree().get_nodes_in_group("enemigos").is_empty():
		pasar_de_nivel()


func pasar_de_nivel() -> void:
	if cambiando_nivel or siguiente_nivel == "":
		return
	cambiando_nivel = true
	animation_player.play("final") # Fundido a negro.
	await animation_player.animation_finished
	# Cargamos el siguiente nivel; ahí arranca solo el "inicio" (fundido a
	# transparente) y se puede volver a jugar.
	get_tree().change_scene_to_file(siguiente_nivel)


func reiniciar_nivel() -> void:
	if cambiando_nivel:
		return
	cambiando_nivel = true
	animation_player.play("final")
	await animation_player.animation_finished
	get_tree().reload_current_scene()


func _on_jugador_energia_cambiada(nueva_energia: int) -> void:
	label_energia.text = "Energía: " + str(nueva_energia)
