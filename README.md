# Enemigos Inteligentes — Clase 23/10/2026

Proyecto de **Godot 4.6 stable** armado a partir de la clase virtual del 23/10/2026.
Abrilo desde el Project Manager con "Importar" y elegí `project.godot`.

**Controles:** WASD o flechas para moverte · click izquierdo o Enter para disparar · Esc para pasar de nivel.

## Qué se vio en la clase y dónde está en el proyecto

| Tema de la clase | Minuto aprox. | Dónde está |
|---|---|---|
| El arma rota hacia el mouse con `look_at(get_global_mouse_position())`. El `ColorRect` no tiene `look_at` porque hereda de **Control**, así que el arma es un **Node2D** con el rectángulo adentro | 08:00 – 16:30 | `scenes/jugador.tscn`, `scripts/jugador.gd` |
| Cursor de mira con `Input.set_custom_mouse_cursor` y el **Kenney Cursor Pixel Pack** ("la crucecita chica") | 16:50 – 22:10 | `scripts/juego.gd` → `poner_mira()` |
| Instanciar balas: `Marker2D` en la punta del arma; **primero** se hace `add_child` y **después** se cambia la posición; la bala se agrega al **Juego**, no al jugador; se le pasa la rotación del arma | 22:15 – 36:30 | `jugador.gd` → `disparar()` |
| La bala avanza con `Vector2.RIGHT.rotated(rotation) * VELOCIDAD * delta`; la raíz es un `Area2D` | 31:30 – 35:50 | `scenes/bala.tscn`, `scripts/bala.gd` |
| **Herencia (tema nuevo):** clase base con `class_name Enemigo` que extiende `CharacterBody2D`, con `@export` de velocidad, vida y ataque | 57:40 – 67:30 | `scripts/enemigo.gd` |
| **Zombie tonto:** sobrescribe (override) `mover()` y va en línea recta con `direction_to`; se traba contra la pared | 67:50 – 82:40 | `scripts/zombie_tonto.gd` |
| **Zombie inteligente:** `NavigationAgent2D` + `NavigationRegion2D` (con agent radius 30) y el código de ejemplo de la documentación; recalcula el destino todo el tiempo | 82:40 – 99:00 | `scripts/zombie_inteligente.gd`, `NavigationRegion2D` en cada nivel |
| `daniar()` definida solo en `Enemigo` y llamada desde los hijos; ataque 10 (tonto) y 120 (inteligente) asignado en el `_ready()` | 99:30 – 116:10 | `enemigo.gd`, señal `body_entered` del `AreaAtaque` |
| Capas de colisión: 1 jugador · 2 pared · 3 enemigos · 4 área de daño (+5 bala). `motion_mode` en **Floating** | 110:30 – 115:20 | Inspector de cada escena / `project.godot` |
| Convenciones: nodos en PascalCase, variables en snake_case, constantes en MAYÚSCULAS, carpetas `scenes/` y `scripts/` | 117:50 – 119:50 | todo el proyecto |
| Transición entre niveles: `CanvasLayer` + `ColorRect` negro + `AnimationPlayer` con las animaciones "inicio" y "final"; Esc hace el fundido y carga el nivel 2 | 120:00 – 125:00 | nodo `Transicion` en cada nivel, `juego.gd` |
| Sugerencia del final: una señal que recibe el jugador, hace un flash y muestra la vida en pantalla | 125:43 | señal `jugador_daniado`, `jugador.gd` → `recibir_danio()`, HUD |

## Notas

- El **NavigationRegion2D** ya viene horneado. Si movés o agregás paredes, metelas dentro del nodo `Paredes` (grupo `navegacion`), seleccioná el `NavigationRegion2D` y tocá **Bake NavigationPolygon**.
- `enemigo.tscn` es la escena base: no se instancia en el nivel, solo sirve para heredar de ella (como explicó el profe).
- También pasás de nivel si eliminás a todos los zombies. Si la energía llega a 0, el nivel se reinicia con el fundido.
- Assets: Kenney Cursor Pixel Pack (CC0) en `assets/Tiles` y `assets/Tilemap`.
