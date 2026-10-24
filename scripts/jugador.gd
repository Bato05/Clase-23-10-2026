extends CharacterBody2D
## JUGADOR.
##
## - Se mueve en las 8 direcciones con Input.get_vector().
## - No rota todo el personaje: rota solamente el ARMA (un Node2D) para que
##   apunte al mouse con look_at(get_global_mouse_position()).
##   Ojo: el ColorRect hereda de Control y NO tiene look_at(); por eso el arma
##   es un Node2D y el rectángulo (FormaArma) va adentro.
## - Dispara balas que salen del Marker2D "PuntaArma".

signal energia_cambiada(nueva_energia: int)
signal murio

const VELOCIDAD: float = 300.0
const ENERGIA_MAXIMA: int = 300

var escena_bala: PackedScene = preload("res://scenes/bala.tscn")
var energia: int = ENERGIA_MAXIMA

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var arma: Node2D = $Arma
@onready var punta_arma: Marker2D = $Arma/PuntaArma


func _physics_process(_delta: float) -> void:
	# Movimiento en 8 direcciones: get_vector toma las 4 teclas a la vez y
	# cambiamos la velocity completa (x e y), no solamente la x.
	var direccion: Vector2 = Input.get_vector("mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo")
	velocity = direccion * VELOCIDAD
	move_and_slide()

	# El arma apunta todo el tiempo hacia donde está el mouse.
	# (0 grados en 2D es hacia la derecha = Vector2.RIGHT.)
	arma.look_at(get_global_mouse_position())

	if Input.is_action_just_pressed("disparar"):
		disparar()


func disparar() -> void:
	# 1) Creamos la bala en memoria partiendo de la escena cargada.
	var nueva_bala: Node2D = escena_bala.instantiate()

	# 2) La agregamos al JUEGO (la escena actual) y NO al jugador con add_child():
	#    si fuera hija del jugador, al mover el jugador se moverían las balas.
	#    (En clase: get_node("/root/Juego").add_child(nueva_bala).)
	get_tree().current_scene.add_child(nueva_bala)

	# 3) IMPORTANTE: primero se agrega a la escena y RECIÉN AHÍ se le cambia la
	#    posición; si se hace antes, la posición queda en cualquier lado.
	#    Usamos global_position para que no dependa de los nodos padres.
	nueva_bala.global_position = punta_arma.global_position

	# 4) Le pasamos la rotación del arma; si no, la bala sale siempre con
	#    rotación 0 y se va siempre hacia la derecha.
	nueva_bala.global_rotation = arma.global_rotation


## Se conecta con la señal "jugador_daniado" de cada Enemigo.
func recibir_danio(cantidad: int) -> void:
	energia = max(energia - cantidad, 0)
	energia_cambiada.emit(energia)

	# Flash rojo del jugador al recibir daño.
	sprite_2d.modulate = Color(1, 0.2, 0.2)
	var tween := create_tween()
	tween.tween_property(sprite_2d, "modulate", Color(0.55, 0.8, 1.0), 0.3)

	if energia <= 0:
		murio.emit()
