class_name Enemigo
extends CharacterBody2D
## Clase BASE de todos los enemigos (tema nuevo de la clase: HERENCIA).
##
## Igual que en Programación Orientada a Objetos (Animal -> Gato / Perro),
## acá ponemos todo lo que es COMÚN a los dos tipos de zombie para no repetir
## código. Gracias al "class_name Enemigo", Godot registra un tipo nuevo que
## aparece en la lista de nodos, y los scripts de los zombies pueden hacer
## "extends Enemigo" y heredar automáticamente todas estas propiedades y métodos.
##
## Esta escena/clase NO se instancia directamente en el nivel: se usa
## solamente para que otros hereden de ella (ZombieTonto y ZombieInteligente).

## Señal que avisa al jugador que recibió daño (el profe propuso al final de
## la clase: "disparar una señal que la capture el jugador, que haga un flash
## y que le baje la vida y se vea en pantalla").
signal jugador_daniado(cantidad: int)

# Con @export las propiedades aparecen en el Inspector para modificarlas a mano.
@export var velocidad: float = 100.0
@export var vida: int = 3
## El ataque está definido como entero pero SIN valor: cada hijo le asigna el
## suyo en su _ready() (ZombieTonto = 10, ZombieInteligente = 120).
@export var ataque: int

# Referencia al jugador. Va con @onready porque cuando arranca el script el
# nodo del jugador todavía no está creado: hay que esperar a que Godot lo cree.
# (En clase se usó get_node("/root/Juego/Jugador"); con el grupo "jugador"
# funciona igual en el nivel 1 y en el nivel 2.)
@onready var jugador: CharacterBody2D = get_tree().get_first_node_in_group("jugador")


func _ready() -> void:
	add_to_group("enemigos")
	if jugador != null and jugador.has_method("recibir_danio"):
		jugador_daniado.connect(jugador.recibir_danio)


# Como ahora el enemigo es un CharacterBody2D (tiene físicas), se mueve en el
# _physics_process y no en el _process.
func _physics_process(delta: float) -> void:
	if jugador == null:
		return
	mover(delta)


## Método que los hijos SOBRESCRIBEN (override). Cada zombie se mueve distinto:
## el tonto va en línea recta y el inteligente traza una ruta con navegación.
func mover(_delta: float) -> void:
	pass


## Función común a todos los enemigos. No está definida en ZombieTonto ni en
## ZombieInteligente, pero como la heredan de Enemigo la pueden llamar igual.
## (Se escribe "daniar" porque en el código no usamos la ñ.)
func daniar() -> void:
	print("Restando energia al jugador: " + str(ataque))
	jugador_daniado.emit(ataque)


## Lo llama la bala cuando le pega a un enemigo.
func recibir_disparo(cantidad: int) -> void:
	vida -= cantidad
	# Pequeño flash para que se note el impacto.
	modulate = Color(3, 3, 3)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.15)
	if vida <= 0:
		queue_free()
