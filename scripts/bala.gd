extends Area2D
## BALA.
##
## La raíz es un Area2D (como recomendó el profe) para detectar cuando le pega
## a algo: al destruir el área se destruye también el Sprite2D que tiene de hijo.
##
## Para que avance hacia donde se disparó: Vector2.RIGHT es el ángulo 0 (hacia
## la derecha) y lo ROTAMOS con la rotación que le pasó el jugador al
## instanciarla (la del arma).

const VELOCIDAD: float = 600.0
const DANIO: int = 1


func _process(delta: float) -> void:
	# No es un CharacterBody2D, así que multiplicamos por delta para que no
	# dependa de los FPS del juego.
	position += Vector2.RIGHT.rotated(rotation) * VELOCIDAD * delta


func _on_body_entered(body: Node2D) -> void:
	# Si le pega a un enemigo, le hace daño; si es una pared, solo desaparece.
	if body is Enemigo:
		body.recibir_disparo(DANIO)
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Si sale de la pantalla, la borramos para no llenar la memoria.
	queue_free()
