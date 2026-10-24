extends Enemigo
## ZOMBIE INTELIGENTE (rojo).
##
## En vez de ir en línea recta "sin pensarlo", traza una RUTA para alcanzar al
## jugador evitando los obstáculos (pathfinding). Para eso necesita:
##   - Un NavigationAgent2D como hijo (este nodo).
##   - Un NavigationRegion2D en el nivel, que marca la zona por donde se puede
##     mover (la parte "navegable", que se ve pintada en el editor).
##
## El código base está sacado de la documentación oficial de Godot
## ("Using NavigationAgents" -> script de ejemplo para CharacterBody2D),
## adaptado para que herede de Enemigo.

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	super() # Ejecuta también el _ready() de Enemigo.
	ataque = 120 # El zombie inteligente pega mucho más fuerte.

	# Igual que en la documentación: esperamos a que el mapa de navegación se
	# sincronice en el primer frame de física antes de pedir una ruta.
	actor_setup.call_deferred()


func actor_setup() -> void:
	await get_tree().physics_frame
	if jugador != null:
		set_movement_target(jugador.global_position)


func set_movement_target(movement_target: Vector2) -> void:
	navigation_agent.target_position = movement_target


## Override del método mover() de Enemigo.
func mover(_delta: float) -> void:
	# Si solo lo hiciéramos en el _ready(), trazaría la ruta UNA sola vez hacia
	# donde estaba el jugador al principio y se quedaría trabado ahí.
	# Por eso se recalcula el destino todo el tiempo (como en clase: "es un
	# exagero, lo ideal sería una vez por segundo, pero para hacerlo rápido").
	set_movement_target(jugador.global_position)

	# Si el mapa todavía no está listo, no hacemos nada.
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	# Hay que multiplicar por la velocidad (heredada de Enemigo); si no, se
	# mueve súper lento.
	velocity = global_position.direction_to(next_path_position) * velocidad
	move_and_slide()


## Señal body_entered del AreaAtaque.
func _on_area_ataque_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		daniar() # Método heredado de Enemigo.
