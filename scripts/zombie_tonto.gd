extends Enemigo
## ZOMBIE TONTO (verde).
##
## Calcula la dirección desde donde está él hacia donde está el jugador y camina
## en esa dirección, sin importarle si hay una pared en el medio: si choca con
## la pared se queda trabado ahí (por eso es "tonto").
##
## Fijate que acá NO están declaradas "velocidad", "vida", "ataque" ni "jugador":
## todo eso viene heredado de Enemigo.


func _ready() -> void:
	super() # Ejecuta también el _ready() de Enemigo (la clase padre).
	ataque = 10 # El zombie tonto no hace tanto daño.


## Override del método mover() de Enemigo.
func mover(_delta: float) -> void:
	# Vector de dirección: desde la posición del zombie HACIA la del jugador
	# (la "flechita" que dibujó el profe). Va del zombie al jugador, no al revés.
	var direccion: Vector2 = global_position.direction_to(jugador.global_position)
	# Esa dirección multiplicada por la velocidad (heredada de Enemigo).
	velocity = direccion * velocidad
	# Sin move_and_slide() no se mueve. Si hay una pared en el medio, no pasa.
	move_and_slide()


## Señal body_entered del AreaAtaque: se dispara cuando un body entra al área.
func _on_area_ataque_body_entered(body: Node2D) -> void:
	# Por las capas de colisión el área solo "ve" al jugador (capa 1), pero
	# igual verificamos el grupo por si detecta la pared u otro enemigo.
	if body.is_in_group("jugador"):
		daniar() # Método heredado de Enemigo.
