#import "_os-helpers.typ": *
= Tu Primer Pull Request

Este capítulo es un ejercicio práctico. Al final, habrás hecho un fork de un repositorio real, creado una rama, escrito una reseña de un capítulo del libro y enviado un pull request: la forma estándar en que los colaboradores de código abierto proponen cambios.

Esto no es una simulación. Tu pull request aparecerá en GitHub para que personas reales lo lean.

#if sys.inputs.at("illustrations", default: "true") == "true" [#include "_illus-pr-flow.typ"]

== Lo que Necesitarás

Todo lo del Capítulo 1:
- Una terminal (abierta y lista)
- Git instalado y configurado
- CLI de GitHub autenticado
- Una cuenta de GitHub

== Lo que Está a Punto de Ocurrir

Antes del primer comando, aquí tienes el camino completo que vas a recorrer: siete pasos, uno tras otro:

+ *Fork* — Crea tu propia copia del repositorio del libro en GitHub
+ *Clone* — Descarga esa copia en tu máquina
+ *Branch* — Crea una versión aislada y segura donde puedas hacer cambios
+ *Write* — Añade tu reseña como un nuevo archivo
+ *Commit* — Guarda tus cambios con un mensaje (el equivalente de Git a guardar)
+ *Push* — Envía tus cambios de vuelta a tu copia en GitHub
+ *Pull Request* — Pide al autor que integre tus cambios en el original

Este es el flujo de trabajo del código abierto. Cada contribución a cada proyecto importante del mundo sigue estos mismos siete pasos. Los habrás completado todos al final de este capítulo.

Aquí están los términos clave que verás: léelos una vez ahora y tendrán sentido a medida que avances:

#table(
  columns: (auto, 1fr),
  [*Término*], [*Qué significa*],
  [*Repositorio*], [Una carpeta de proyecto que Git está rastreando. A menudo llamado "repo".],
  [*Fork*], [Tu copia personal del repositorio de otra persona, almacenada en GitHub.],
  [*Clone*], [Descargar un repositorio de GitHub a tu máquina.],
  [*Branch*], [Una versión paralela del proyecto donde trabajas sin tocar la copia principal.],
  [*Commit*], [Un snapshot guardado de tus cambios, con un mensaje que describe lo que hiciste.],
  [*Push*], [Enviar tus commits desde tu máquina a GitHub.],
  [*Pull Request*], [Una solicitud formal de integrar tu rama en el proyecto original.],
)

No necesitas memorizar estos términos. Se volverán naturales a medida que los uses.

== Fork y Clone del Libro

Trabajaremos con _La Tripulación Agéntica_: el libro que estás leyendo ahora mismo. El código fuente vive en GitHub como repositorio público.

Ejecuta este único comando:

```
gh repo fork schlunsen/theagenticcrew --clone --remote
```

Esto hace tres cosas en un solo paso:
+ Crea tu propia copia (un "fork") en GitHub
+ La descarga en tu máquina (un "clone")
+ Establece la conexión entre tu copia y el original

Entra en el directorio del proyecto:

```
cd theagenticcrew
```

Verifica tu configuración:

```
git remote -v
```

Deberías ver dos remotos:
- `origin` — tu fork (donde envías tus cambios)
- `upstream` — el repositorio original (de donde puedes obtener actualizaciones)

== Explora el Proyecto

Antes de cambiar nada, mira a tu alrededor. El libro está escrito en Typst, un lenguaje de composición tipográfica moderno. Los archivos fuente son texto plano: puedes leerlos en cualquier editor.

Observa la estructura del proyecto:

```
ls
ls chapters/
```

Los capítulos están en el directorio `chapters/`, numerados y con nombres descriptivos. El que nos interesa es `01-introduction.typ`.

== Lee el Capítulo 1

Ábrelo en un editor de texto:

#if is-windows [
```
notepad chapters\01-introduction.typ
```
]

#if is-mac [
```
open -e chapters/01-introduction.typ
```
]

#if is-linux [
```
xdg-open chapters/01-introduction.typ
```
]

O con VS Code en cualquier plataforma, si lo tienes instalado:

```
code chapters/01-introduction.typ
```

Verás marcado Typst: los encabezados comienzan con `=`, el énfasis usa `_guiones bajos_` y el resto es prosa. Se lee como un documento normal.

*Tómate tu tiempo.* Lee el capítulo completo. La introducción cubre:
- El viaje del autor descubriendo los flujos de trabajo agénticos
- Por qué el terreno está cambiando para los ingenieros de software
- Para quién es el libro y cómo leerlo
- Qué es el libro y qué no es

Forma tus propias opiniones mientras lees. Ese es el objetivo de este ejercicio.

== Crea una Rama

En Git, no editas la copia principal directamente. Creas una *rama*: una versión paralela donde puedes hacer cambios sin afectar el trabajo de nadie más.

```
git checkout -b review/chapter-1-TU-NOMBRE-DE-USUARIO-GITHUB
```

Reemplaza `TU-NOMBRE-DE-USUARIO-GITHUB` con tu nombre de usuario real. Por ejemplo:

```
git checkout -b review/chapter-1-juanperez
```

#quote(block: true)[
  *Versiones más recientes de Git (2.23+)* ofrecen `git switch -c` como una alternativa más explícita a `git checkout -b`. Ambos hacen lo mismo. Usamos `checkout` aquí porque es lo que más se ve en tutoriales y documentación.
]

#quote(block: true)[
  *¿Por qué ramas?* Imagina diez personas editando el mismo documento de Google a la vez: caos. Las ramas permiten que cada persona trabaje de forma independiente y luego integre sus cambios uno a uno. Así operan todos los proyectos de software serios.
]

== Escribe tu Reseña

Crea una carpeta `reviews` y tu archivo de reseña.

#if is-windows [
```
mkdir reviews
notepad reviews\resena-capitulo-1-TU-NOMBRE-DE-USUARIO-GITHUB.md
```
]

#if is-mac or is-linux [
```
mkdir -p reviews
nano reviews/resena-capitulo-1-TU-NOMBRE-DE-USUARIO-GITHUB.md
```

Esto abre un sencillo editor de texto en la terminal. Escribe (o pega) tu reseña directamente. Cuando termines, presiona `Ctrl+X` para salir, luego `Y` para confirmar el guardado y `Enter` para mantener el nombre del archivo.

En macOS o Linux también puedes usar cualquier editor que prefieras: `code`, `vim` o lo que te resulte más natural.
]

Aquí tienes una plantilla para empezar. Escríbela o cópiala de esta página y luego completa tus pensamientos reales bajo cada encabezado:

```markdown
# Reseña — Capítulo 1: Introducción

**Reseñador/a:** @TU-NOMBRE-DE-USUARIO-GITHUB
**Fecha:** AAAA-MM-DD

## Primeras Impresiones
¿Qué te llamó la atención cuando leíste este capítulo por primera vez?

## Lo que Funcionó Bien
¿Qué partes te resonaron? ¿Qué fue claro y atractivo?

## Lo que Podría Mejorar
Sé honesto/a pero constructivo/a. ¿Secciones confusas?
¿Contexto que faltaba? ¿Algo que no encajara?

## Quién Se Beneficiaría de Este Capítulo
Basándote en lo que leíste, ¿quién es el lector ideal?

## Puntuación
Tu puntuación general sobre 5, con un resumen de una línea.
```

No lo pienses demasiado. Un párrafo genuino para cada sección vale más que un ensayo pulido.

== El Enfoque Basado en Prompts

El enfoque manual comando a comando que aparece arriba es el flujo de trabajo completo. Una vez instalado Claude Code o Gemini CLI, puedes describir toda la tarea en español natural y dejar que el agente se encargue de la mayor parte.

#if sys.inputs.at("illustrations", default: "true") == "true" [#include "_illus-two-paths.typ"]

Abre tu asistente IA desde dentro del directorio del proyecto clonado:

```
claude
```

O:

```
gemini
```

=== Deja que el agente lea el capítulo

En lugar de abrir el archivo tú mismo, pide al agente que lo lea y te dé un resumen:

- _"Lee chapters/01-introduction.typ y resume lo que cubre."_
- _"¿Cuál es el argumento principal de chapters/01-introduction.typ? ¿Para quién cree el autor que es este libro?"_

Esto es útil cuando quieres una orientación rápida antes de leer el capítulo completo tú mismo.

=== Redacta tu reseña juntos

Una vez que hayas leído el capítulo (tú mismo o con ayuda del agente), úsalo como compañero de reflexión:

- _"Lee chapters/01-introduction.typ y dame tu opinión honesta: ¿qué funciona bien y qué le falta a una introducción de libro?"_
- _"Creo que la introducción dedica demasiado tiempo a la historia personal del autor. ¿Estás de acuerdo? ¿Qué cortarías?"_
- _"Ayúdame a rellenar esta plantilla de reseña para el capítulo 1."_ (pega la plantilla en el prompt)

El agente te dará un borrador al que reaccionar. Acuerda, discrepa, edita: la reseña debe acabar con tu voz, no con la del agente.

=== Deja que el agente haga el trabajo de Git

Aquí es donde el enfoque basado en prompts realmente brilla. Después de escribir tu reseña, puedes delegar los pasos de Git al agente:

- _"Crea una rama llamada review/chapter-1-TU-NOMBRE-DE-USUARIO-GITHUB, añade mi archivo de reseña, haz commit con un mensaje sensato, envíalo a mi fork y abre un pull request."_

El agente ejecutará cada comando, te mostrará lo que está haciendo y señalará cualquier problema. Tú te mantienes al tanto sin tener que recordar la sintaxis exacta.

O ve aún más lejos: describe toda la tarea desde el principio antes de empezar:

- _"Quiero enviar una reseña de chapters/01-introduction.typ como pull request a este repositorio. Guíame paso a paso, o hazlo tú si digo adelante."_

El agente esbozará el plan, esperará tu aprobación y lo ejecutará.

=== Cuándo usar comandos vs. prompts

#table(
  columns: (1fr, 1fr),
  [*Usa comandos cuando...*], [*Usa prompts cuando...*],
  [Sabes exactamente qué hacer], [No estás seguro de cuál es el siguiente paso],
  [La velocidad importa], [Quieres entender qué está pasando],
  [Estás escribiendo scripts o automatizando], [Estás explorando o experimentando],
  [El comando es corto y memorable], [La tarea implica múltiples pasos],
)

#quote(block: true)[
  *Una nota sobre la honestidad.* Ya sea que escribas tu reseña manualmente o la redactes con ayuda de un asistente IA, las opiniones deben ser tuyas. Usa el agente para afinar tu pensamiento y manejar los pasos mecánicos, no para sustituir tu criterio. Las mejores reseñas tienen una voz humana. Un agente puede ayudarte a encontrar las palabras para lo que ya sientes, pero no puede sentirlo por ti.
]

== Stage y Commit

Una vez que tu reseña esté escrita y guardada, dile a Git que la rastree:

```
git add reviews/
```

Comprueba qué está en stage:

```
git status
```

Deberías ver tu archivo de reseña listado bajo "Changes to be committed".

Ahora haz commit: esto crea un snapshot con tus cambios y un mensaje que explica lo que hiciste:

```
git commit -m "Añadir reseña del Capítulo 1 por TU-NOMBRE-DE-USUARIO-GITHUB"
```

== Push a tu Fork

Envía tu rama a GitHub:

```
git push origin review/chapter-1-TU-NOMBRE-DE-USUARIO-GITHUB
```

Tus cambios ahora existen tanto en tu máquina como en GitHub.

== Crea el Pull Request

Este es el momento. Un pull request dice: "Hice algunos cambios en mi fork — ¿te gustaría integrarlos en el proyecto original?"

```
gh pr create --title "Reseña Capítulo 1: TU-NOMBRE-DE-USUARIO-GITHUB" --body "Reseña honesta del Capítulo 1 (Introducción) de La Tripulación Agéntica. Incluye primeras impresiones, puntos fuertes, áreas de mejora y ajuste al público objetivo."
```

El CLI mostrará una URL. Ábrela en tu navegador: ese es tu pull request, en vivo en GitHub.

También puedes verlo en cualquier momento:

```
gh pr view --web
```

== Qué Ocurre Después

Una vez que envíes tu PR:

+ *El autor lo lee* — el feedback honesto sobre un libro en progreso es genuinamente valioso
+ *Puede que comenten* — haciendo preguntas de seguimiento o agradeciéndote una observación específica
+ *Se integra* — tu reseña se convierte en parte permanente del historial del proyecto

Ese es el flujo de trabajo del código abierto: fork, rama, cambio, push, PR. Cada contribución a cada proyecto importante del mundo sigue este patrón. Tú acabas de hacerlo de verdad.

== Solución de Problemas

*`git push` pide contraseña:*
Ejecuta `gh auth setup-git` para configurar Git para usar las credenciales de tu CLI de GitHub. Funciona igual en todas las plataformas.

#if is-windows [
*`mkdir reviews` falla porque la carpeta ya existe:*
No hay problema: omite el paso `mkdir` y abre el archivo directamente con `notepad reviews\resena-capitulo-1-TU-NOMBRE-DE-USUARIO-GITHUB.md`. Windows creará el archivo si no existe.

*`mkdir reviews` da error en PowerShell antiguo:*
Usa `New-Item -ItemType Directory -Force -Path reviews` en su lugar.
]

#if is-linux [
*`nano` no está instalado en tu distro:*
Usa `vi reviews/...` (disponible en todas partes) o instala nano: `sudo apt install nano`.
]

#if is-mac [
*`open -e` no abre un editor de texto:*
TextEdit es el predeterminado. Para texto plano, prueba `open -a TextEdit chapters/01-introduction.typ` o simplemente usa `code` si tienes VS Code.
]

*Cometiste un error tipográfico en el nombre de tu rama:*
Crea una nueva rama desde main: `git checkout main && git checkout -b review/chapter-1-nombre-corregido`, luego copia tu archivo de reseña.

*El PR apunta a la rama incorrecta:*
Puedes especificar la base: `gh pr create --base main --title "..."`.

== Referencia Rápida

#table(
  columns: (1fr, 2fr),
  [*Tarea*], [*Comando*],
  [Ver tus ramas], [`git branch`],
  [Ver qué cambió], [`git status`],
  [Ver el diff], [`git diff`],
  [Obtener lo último del upstream], [`git fetch upstream && git merge upstream/main`],
  [Ver tu PR], [`gh pr view --web`],
)
