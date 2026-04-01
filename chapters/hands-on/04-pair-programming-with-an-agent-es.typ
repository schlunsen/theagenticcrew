#import "_os-helpers.typ": *
= Programación en Pareja con un Agente

En los últimos tres capítulos configuraste tus herramientas, enviaste un pull request y generaste contenido con IA. Ahora vas a construir algo desde cero: una aplicación web completa, describiendo lo que quieres a un agente de programación IA.

No escribirás el código tú mismo. Describirás lo que quieres, revisarás lo que el agente construye e iterarás hasta que esté bien. Esto es programación en pareja con una IA: tú aportas la visión, el agente aporta la implementación.

== Lo que Vas a Construir

Una *Lista de Viajes Pendientes* — una aplicación web personal donde puedes añadir destinos que quieres visitar, explorarlos como tarjetas visuales, editar los detalles, marcar lugares como visitados y eliminar entradas sobre las que hayas cambiado de opinión. Los datos se guardan en el almacenamiento local de tu navegador, así que nada se envía a un servidor y nada desaparece cuando cierras la pestaña.

Al final de este capítulo, habrás:

+ Creado un proyecto desde cero usando solo prompts en lenguaje natural
+ Construido una aplicación funcional con operaciones de Crear, Leer, Actualizar y Eliminar
+ Usado localStorage para persistencia — sin base de datos, sin servidor
+ Dado estilo para que sea algo que realmente quieras ver
+ Enviado todo a GitHub

Cada línea de HTML, CSS y JavaScript será escrita por el agente. Tu trabajo es describir, revisar y refinar.

== Lo que Necesitarás

De los capítulos anteriores:
- Un terminal (abierto y listo)
- Git instalado y configurado
- CLI de GitHub autenticado
- Claude Code o Gemini CLI listo en tu terminal

No se necesitan herramientas nuevas para este capítulo. Todo se ejecuta en un navegador — sin paso de compilación, sin dependencias.

== Crea el Proyecto

Empieza creando una carpeta de proyecto vacía e inicializando Git:

```
mkdir travel-bucket-list && cd travel-bucket-list
git init
```

Ahora abre tu asistente IA desde dentro del directorio del proyecto:

```
claude
```

O:

```
gemini
```

Estás listo para empezar a construir.

== Describe la Aplicación

Dale al agente una imagen clara de lo que quieres. No te preocupes por los detalles técnicos — descríbelo como si le estuvieras explicando a un amigo cómo debería verse y funcionar la aplicación.

Prueba esto como tu prompt inicial:

- _"Constrúyeme una aplicación de Lista de Viajes Pendientes en un solo archivo index.html con CSS y JavaScript integrados. Debe permitirme añadir destinos que quiero visitar, mostrarlos como tarjetas visuales en una cuadrícula, editar cualquier destino, marcarlo como visitado y eliminarlo. Almacena todo en localStorage para que los datos persistan entre actualizaciones de página. Hazlo bonito — quiero disfrutar usándolo de verdad."_

El agente generará un archivo `index.html`. Este único archivo contiene todo — la estructura (HTML), el estilo (CSS) y el comportamiento (JavaScript). Sin frameworks, sin herramientas de compilación, sin complejidad.

#quote(block: true)[
  *¿Por qué un solo archivo?* Para una pequeña aplicación personal, un archivo es lo más simple que funciona. Puedes abrirlo en cualquier navegador, enviárselo a un amigo por correo o alojarlo en cualquier lugar. El agente podría separarlo en archivos diferentes más adelante si el proyecto crece — pero ahora mismo, la simplicidad gana.
]

== Revisa lo que el Agente Construyó

Antes de abrir el navegador, pide al agente que te explique lo que creó:

- _"Explícame el código paso a paso. ¿Cómo se almacenan los destinos? ¿Cómo funciona añadir uno nuevo? ¿Cómo sabe el botón de eliminar qué tarjeta quitar?"_

No necesitas entender cada línea, pero deberías entender la estructura general:

- *HTML* define el formulario y el contenedor de tarjetas
- *CSS* lo hace atractivo — el diseño de cuadrícula, el estilo de las tarjetas, los colores
- *JavaScript* gestiona la lógica — guardar en localStorage, renderizar tarjetas, manejar clics de botones

Este es el hábito más importante en el desarrollo asistido por agentes: *siempre revisa antes de ejecutar*. El agente es rápido, pero no es infalible. Una explicación rápida detecta malentendidos a tiempo.

== Ábrelo en tu Navegador

#if is-mac [
```
open index.html
```
]

#if is-linux [
```
xdg-open index.html
```
]

#if is-windows [
```
start index.html
```
]

Deberías ver tu aplicación — un formulario en la parte superior y un área de tarjetas vacía debajo. Prueba añadiendo tu primer destino:

+ Escribe el nombre de un destino (por ejemplo, "Kioto, Japón")
+ Añade una razón corta ("Cerezos en flor en primavera")
+ Elige una prioridad
+ Haz clic en *Añadir*

Debería aparecer una tarjeta. Añade dos o tres más. Actualiza la página — deberían seguir ahí, porque están guardadas en localStorage.

== El Ciclo CRUD

Tu aplicación ahora soporta las cuatro operaciones. Aquí está lo que significa cada una en la práctica:

#table(
  columns: (auto, 1fr, 1fr),
  [*Operación*], [*Qué significa*], [*En tu aplicación*],
  [*Create*], [Añadir una nueva entrada], [Rellena el formulario y haz clic en Añadir],
  [*Read*], [Ver las entradas existentes], [La cuadrícula de tarjetas muestra todos los destinos],
  [*Update*], [Editar una entrada existente], [Haz clic en Editar en una tarjeta, cambia los detalles, guarda],
  [*Delete*], [Eliminar una entrada], [Haz clic en Eliminar en una tarjeta — desaparece],
)

Estas cuatro operaciones son la base de casi todas las aplicaciones que has usado — correo electrónico, redes sociales, aplicaciones de notas, tiendas online. El modelo de datos cambia, pero el patrón siempre es el mismo: crear, leer, actualizar, eliminar.

== Itera y Mejora

La primera versión es un punto de partida. Ahora hazla tuya. Aquí es donde la programación en pareja brilla — describes lo que quieres cambiar, el agente lo hace realidad, revisas, repites.

Aquí hay prompts para probar. Elige los que te atraigan:

=== Hazla más visual

- _"Añade un campo de URL de imagen a cada destino. Cuando una tarjeta tiene imagen, muéstrala como fondo de la tarjeta. Cuando no la tiene, usa un degradado bonito basado en el nivel de prioridad."_

- _"Añade una insignia con código de color a cada tarjeta — verde para 'obligatorio', ámbar para 'me encantaría' y gris para 'algún día'."_

=== Añade filtrado y búsqueda

- _"Añade una barra de búsqueda que filtre las tarjetas mientras escribo — buscando en el nombre del destino o la razón."_

- _"Añade botones de filtro en la parte superior: Todos, Obligatorio, Me Encantaría, Algún Día, Visitado. Al hacer clic en uno, muestra solo las tarjetas que coincidan."_

=== Haz que marcar como visitado sea satisfactorio

- _"Cuando marco un destino como visitado, anima la tarjeta — quizás una pequeña explosión de confeti o un sello superpuesto que diga 'ESTUVE AHÍ'. Que se sienta como un logro."_

=== Añade una barra de estadísticas

- _"Añade una barra de resumen en la parte superior mostrando: total de destinos, cuántos visitados, cuántos pendientes. Que se actualice en tiempo real cuando añada, elimine o marque destinos."_

=== Mejora el formulario

- _"Añade un selector desplegable de país (o autocompletado) al formulario, y agrupa las tarjetas por país en la cuadrícula."_

- _"Haz que el formulario sea plegable para poder ocultarlo cuando solo estoy navegando."_

#quote(block: true)[
  *Sal del guión.* Estos prompts son sugerencias, no tareas obligatorias. Si quieres un modo oscuro, una vista de mapa o un botón de "destino aleatorio" — pídelo. El agente averiguará cómo construirlo. El objetivo es practicar el ida y vuelta: describir, revisar, refinar.
]

== Cuando Algo Sale Mal

Pasará. El agente puede generar código con un error, o construir algo que no coincide exactamente con lo que describiste. Eso es normal — y es una habilidad para practicar, no un fracaso.

*Si un botón no funciona:*
- _"El botón de Eliminar no está quitando la tarjeta. Comprueba el event listener — ¿está adjuntado correctamente? Arréglalo y explica qué estaba mal."_

*Si el diseño se ve roto:*
- _"Las tarjetas se superponen en móvil. Haz que la cuadrícula sea responsiva — una columna en pantallas pequeñas, dos columnas en medianas, tres en grandes."_

*Si los datos desaparecen:*
- _"Mis destinos desaparecen cuando actualizo la página. Comprueba si la función de guardar en localStorage se está llamando después de cada cambio."_

*Si el agente cambió algo que no pediste:*
- _"Cambiaste el diseño de las tarjetas pero solo te pedí que añadieras el campo de imagen. Revierte los cambios de diseño y solo añade la función de imagen."_

El patrón siempre es el mismo: describe el problema, pide al agente que lo diagnostique, revisa la corrección. Esto es depuración por conversación — y es exactamente cómo trabajan los desarrolladores profesionales con agentes IA.

== Entiende lo que se Construyó

Antes de hacer commit, tómate un momento para entender los conceptos clave que usó el agente. Pregunta:

- _"Explica cómo funciona localStorage en esta aplicación. ¿Dónde se guardan los datos y qué pasa si borro los datos del navegador?"_

- _"¿Qué es el DOM? ¿Cómo actualiza el JavaScript lo que veo en pantalla cuando añado una nueva tarjeta?"_

- _"Explícame paso a paso qué pasa desde el momento en que hago clic en el botón Añadir hasta que aparece la nueva tarjeta."_

No necesitas memorizar las respuestas. Pero entender el flujo — entrada del formulario → función JavaScript → localStorage → actualización del DOM — te da vocabulario para la próxima vez que construyas algo.

#table(
  columns: (1fr, 1fr),
  [*Concepto*], [*Qué significa*],
  [*HTML*], [La estructura — qué elementos existen en la página],
  [*CSS*], [El estilo — cómo se ven esos elementos],
  [*JavaScript*], [El comportamiento — qué pasa cuando interactúas],
  [*localStorage*], [Almacenamiento del navegador que persiste entre visitas],
  [*DOM*], [La representación en vivo de la página que JavaScript puede modificar],
  [*Event listener*], [Código que se ejecuta cuando algo ocurre (clic, envío, tecla)],
  [*CRUD*], [Create, Read, Update, Delete — las cuatro operaciones básicas de datos],
)

== Commit y Push

Una vez que estés satisfecho con tu aplicación, guárdala en GitHub. Pide al agente:

- _"Inicializa un repositorio Git si no existe, crea una rama llamada feature/travel-bucket-list, añade todos los archivos, haz commit con un mensaje describiendo lo que construimos y envíalo a un nuevo repositorio de GitHub llamado travel-bucket-list."_

O hazlo paso a paso:

```
git add index.html
git commit -m "Build travel bucket list app with CRUD and localStorage"
```

Crea un repositorio en GitHub y envíalo:

```
gh repo create travel-bucket-list --public --source=. --remote=origin --push
```

Verifica que está ahí:

```
gh repo view --web
```

Tu aplicación ya está en GitHub. Cualquiera con el enlace puede clonarla y abrir `index.html` en su navegador.

== Lo que Acaba de Pasar

Construiste una aplicación web completa sin escribir una sola línea de código tú mismo. Describiste lo que querías, revisaste lo que el agente produjo e iteraste hasta que estuvo bien.

#table(
  columns: (1fr, 1fr),
  [*Tú aportaste*], [*El agente aportó*],
  [Una idea clara — "lista de viajes pendientes"], [El HTML, CSS y JavaScript],
  [Opiniones sobre cómo debería verse], [Diseños de tarjetas, cuadrículas y esquemas de color],
  [Reportes de errores cuando algo falló], [Diagnóstico y correcciones],
  [La decisión de publicarlo], [Comandos Git y configuración de GitHub],
)

Este es el ciclo central del desarrollo asistido por agentes:

+ *Describe* lo que quieres
+ *Revisa* lo que el agente construye
+ *Itera* hasta que esté bien
+ *Entiende* lo suficiente para mantener el control

No necesitas saber cómo escribir JavaScript para construir una aplicación JavaScript. Necesitas saber qué quieres, cómo comprobar si lo obtuviste y cómo pedir cambios. Esa es una habilidad diferente — y es la que este libro te está enseñando.

== Solución de Problemas

*La página está en blanco cuando abro index.html:*
Abre las herramientas de desarrollo de tu navegador (F12 o clic derecho → Inspeccionar) y revisa la pestaña Consola. Los errores en rojo te dicen qué salió mal. Copia el mensaje de error y pégalo al agente: _"Estoy recibiendo este error en la consola: [pega el error]. Arréglalo."_

*Las tarjetas aparecen pero desaparecen al actualizar:*
La función de guardar en localStorage no se está ejecutando. Pregunta: _"Comprueba que cada función que modifica el array de destinos también llame a la función de guardado después."_

*El formulario se envía pero no aparece nada:*
La función de renderizado de tarjetas puede tener un error. Pregunta: _"Añade un console.log al inicio de la función de renderizado para ver si se está ejecutando. Luego revisa la consola del navegador."_

#if is-windows [
*index.html se abre en el Bloc de notas en lugar del navegador:*
Haz clic derecho en el archivo → *Abrir con* → elige tu navegador. O escribe la ruta completa en la barra de direcciones de tu navegador.
]

*El estilo se ve diferente en distintos navegadores:*
Pide al agente: _"Añade un CSS reset al inicio de los estilos para normalizar las diferencias entre navegadores."_

*Quiero empezar de nuevo:*
Está bien — y es fácil. Pide: _"Borra index.html y empecemos de cero. Esta vez quiero [nueva descripción]."_ Una de las ventajas del desarrollo asistido por agentes es que empezar de nuevo cuesta minutos, no horas.

*localStorage está lleno o se comporta de forma extraña:*
Abre las herramientas de desarrollo → pestaña Application → Local Storage. Puedes ver y eliminar entradas manualmente. O pide al agente: _"Añade un botón 'Borrar todos los datos' que limpie localStorage y reinicie la aplicación."_

== Referencia Rápida

#table(
  columns: (1fr, 2fr),
  [*Tarea*], [*Prompt o comando*],
  [Iniciar el proyecto], [`mkdir travel-bucket-list && cd travel-bucket-list && git init`],
  [Construir la aplicación], [_"Constrúyeme una aplicación de Lista de Viajes Pendientes en un solo index.html..."_],
  [Abrir en el navegador], [#if is-mac [`open index.html`] #if is-linux [`xdg-open index.html`] #if is-windows [`start index.html`]],
  [Revisar el código], [_"Explícame cómo funciona la aplicación"_],
  [Añadir una funcionalidad], [_"Añade [descripción de la funcionalidad] a la aplicación"_],
  [Corregir un error], [_"[describe el problema] — diagnostica y arréglalo"_],
  [Entender un concepto], [_"Explica cómo funciona [concepto] en esta aplicación"_],
  [Enviar a GitHub], [`gh repo create travel-bucket-list --public --source=. --remote=origin --push`],
  [Ver en GitHub], [`gh repo view --web`],
)
