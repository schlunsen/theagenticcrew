= Git Como Infraestructura de Agentes

#figure(
  image("../../assets/illustrations/ch06-git-branches.jpg", width: 80%),
)

Ya conoces Git. Llevas años haciendo commits, ramas y merges. Pero en la ingeniería agéntica, Git no es solo control de versiones — es la columna vertebral de todo tu flujo de trabajo. Es tu botón de deshacer, tu framework de ejecución paralela, tu interfaz de revisión y tu sistema de documentación, todo a la vez.

La mayoría de los ingenieros usan quizá el 20% de lo que Git ofrece. La ingeniería agéntica exige el otro 80%.

== Commits Pequeños, Siempre

El hábito de Git más importante para la ingeniería agéntica: commits pequeños, commits frecuentes.

Cuando un agente hace cambios, quieres poder revisar cada paso lógico independientemente. Un commit que dice "refactorizada autenticación, actualizados tests, arreglada la barra de navegación y cambiado el esquema de base de datos" es imposible de revisar e imposible de revertir parcialmente. Cuatro commits separados — cada uno haciendo una cosa — te dan control quirúrgico.

Esto importa más con agentes que con desarrolladores humanos, porque los agentes se mueven rápido. Un agente puede hacer veinte cambios de archivo en treinta segundos. Si esos cambios están empaquetados en un solo commit, y algo se rompe, estás desenredando un lío. Si están en cinco commits limpios, reviertes el que rompió las cosas y conservas el resto.

Entrénate — y a tus agentes — para hacer commit en los límites naturales:
- Después de cada cambio lógico, no después de cada sesión
- Antes de cambiar a un asunto diferente
- Después de que los tests pasen, capturando un estado conocido como bueno
- Antes de intentar algo arriesgado, creando un punto de guardado

== Deja Que los Agentes Escriban Tus Mensajes de Commit

Esta es una de las victorias más fáciles en la ingeniería agéntica, y es casi vergonzosamente simple: deja que el agente escriba el mensaje de commit.

Piénsalo. El agente acaba de hacer los cambios. Sabe exactamente qué modificó, por qué lo modificó y cuál era la intención. Tiene el diff completo en el contexto. Escribirá un mensaje de commit más preciso y más descriptivo que el que tú escribirías — porque tú estarías resumiendo de memoria, y el agente está resumiendo a partir de hechos.

Un mensaje de commit humano típico a las 11 de la noche: "fix auth bug"

Un mensaje de commit típico de un agente: "fix session expiry race condition when WebSocket disconnects during OAuth token refresh — the cleanup goroutine was running before the token exchange completed, leaving orphaned sessions in the database"

El segundo es útil seis meses después cuando alguien — humano o agente — está intentando entender por qué existe ese código. El primero es ruido.

Haz de esto un hábito. Después de que el agente complete una tarea, pídele que haga commit con un mensaje descriptivo. O configura tu flujo de trabajo para que ocurra automáticamente. La calidad de tu historial de git mejorará de la noche a la mañana.

== Las Ramas Como Límites de Tareas

Cada tarea de agente tiene su propia rama. Esto es innegociable.

La rama sirve para múltiples propósitos:
- *Aislamiento.* Los cambios del agente no afectan a tu rama principal hasta que los fusionas explícitamente.
- *Alcance de revisión.* Cuando terminas, revisas un solo PR — el diff entre la rama y main. Este es un flujo de trabajo que todo ingeniero ya conoce.
- *Reversión.* Si todo está mal, borras la rama. Limpio. No se necesita cirugía.
- *Trabajo paralelo.* Múltiples agentes en múltiples ramas, trabajando simultáneamente, sin pisarse unos a otros.

Nombra tus ramas de forma descriptiva: `agent/refactor-auth-middleware`, `agent/add-user-tests`, `agent/fix-sidebar-rendering`. Cuando mires tu lista de ramas, deberías ver un manifiesto de todo en lo que tus agentes están trabajando.

== Worktrees para Agentes en Paralelo

Las ramas solas no son suficientes para verdadero trabajo en paralelo. Si dos agentes están en ramas diferentes pero comparten el mismo directorio de trabajo, pelearán por el sistema de archivos. Los worktrees de Git resuelven esto.

Un worktree es un checkout separado de tu repositorio — un directorio diferente, en una rama diferente, compartiendo el mismo historial de `.git`. Crear uno lleva segundos:

```bash
git worktree add ../my-project-feature feature-branch
```

Ahora tienes dos directorios: tu checkout principal y el worktree. Cada agente tiene su propio worktree, su propia rama, su propio sistema de archivos. Ambos pueden ejecutar tests, modificar archivos y compilar — simultáneamente, sin conflictos.

Cuando el trabajo está terminado:
- Buen resultado → fusiona la rama, elimina el worktree
- Mal resultado → elimina el worktree, borra la rama
- Necesitas iterar → mantén el worktree, continúa la conversación

Este es el sandbox más barato que puedes construir. Sin contenedores, sin VMs, sin recursos en la nube. Solo Git.

== Revisando el Trabajo del Agente a Través de Diffs

Tu interfaz principal para revisar el trabajo del agente no es leer código — es leer diffs.

Este es un cambio sutil pero importante. Cuando escribes código tú mismo, lo revisas mientras escribes. Cuando un agente escribe código, lo revisas después. Y la forma más eficiente de hacerlo es a través del diff contra tu rama base.

Desarrolla tus habilidades de lectura de diffs:
- *Empieza con los cambios de tests.* Si el agente escribió o modificó tests, léelos primero. Te dicen lo que el agente piensa que el código debería hacer. Si los tests coinciden con tu intención, la implementación probablemente está bien.
- *Busca expansión del alcance.* ¿El agente cambió archivos que no esperabas? ¿Cambios de formato no relacionados? ¿Dependencias extra? Estas son señales de alerta.
- *Revisa los límites.* Firmas de funciones, contratos de API, esquemas de base de datos — los cambios a interfaces tienen un impacto desproporcionado. Revísalos cuidadosamente.
- *Confía pero verifica.* Si el diff es grande, no leas cada línea. Revisa por muestreo las rutas críticas, asegúrate de que los tests son significativos y ejecuta la suite tú mismo.

El objetivo no es leer cada línea que el agente escribió — eso anula el propósito. El objetivo es verificar que los cambios del agente coinciden con tu intención y no introducen problemas. Los diffs hacen esto rápido.

== El Historial de Git Como Documentación

He aquí la idea que la mayoría de los ingenieros pasan por alto: los agentes leen tu historial de git. Cuando un agente está intentando entender por qué existe un código, cómo evolucionó una funcionalidad, o qué enfoque se intentó antes, mira `git log` y `git blame`.

Esto significa que tu historial de commits es documentación. No del tipo que escribes en una wiki — del tipo que está incrustada en el propio código, permanentemente, con procedencia perfecta.

Los buenos mensajes de commit se acumulan con el tiempo. Seis meses a partir de ahora, cuando un agente esté trabajando en tu código base, leerá esos mensajes para entender el contexto. La diferencia entre un historial de "fix bug" y "fix race condition in session cleanup" es la diferencia entre un agente que entiende tu código base y uno que está adivinando.

Y si tu agente tiene acceso para ejecutar `git log` y `git blame` — que debería tenerlo — esta documentación no es algo que necesites copiar y pegar en los prompts. El agente la lee directamente desde el repositorio. Tu trabajo es hacer que el historial valga la pena leerlo, no leerlo por el agente.

Esto también se aplica a las descripciones de PR, nombres de ramas y mensajes de merge commit. Cada pieza de texto que adjuntas a tu historial de Git es contexto para futuros agentes. Escribe en consecuencia.

== El Flujo de Trabajo de Git para Ingeniería Agéntica

Juntándolo todo, este es el flujo de trabajo:

+ Crea una rama para la tarea
+ Opcionalmente crea un worktree para aislamiento
+ Apunta al agente al worktree
+ Déjalo trabajar — haciendo commits en los límites naturales
+ El agente escribe mensajes de commit descriptivos
+ Revisa el diff contra main
+ Fusiona si es bueno, descarta si no

Este flujo de trabajo es rápido, seguro y escala a múltiples agentes en paralelo. Usa funcionalidades de Git que existen desde hace años — ramas, worktrees, diffs — pero las combina de una forma que está diseñada para la ingeniería agéntica.

La mejor parte: ya sabes todo esto. Llevas años usando Git. La ingeniería agéntica no requiere herramientas nuevas — requiere usar tus herramientas existentes más deliberadamente.
