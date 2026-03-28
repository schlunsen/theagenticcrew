#import "_os-helpers.typ": *
= Tu Primer Proyecto con IA

Hasta ahora has configurado tus herramientas y enviado tu primer pull request. Ahora vas a hacer algo genuinamente impresionante: tomar un proyecto real de código abierto, describir lo que quieres en español natural y dejar que un agente IA lo transforme, generando ilustraciones personalizadas, audio de narración y fondos animados con modelos de IA de Hugging Face.

No se requiere experiencia previa en programación. El agente escribe el código. Tú describes la visión.

#if sys.inputs.at("illustrations", default: "true") == "true" [#include "_illus-ai-studio.typ"]

== Lo que Vas a Construir

*Web Presenter* es un framework de presentaciones de código abierto: HTML, CSS y JavaScript puros, sin paso de compilación. Admite narración diapositiva por diapositiva (archivos WAV), fondos animados con Three.js y transiciones CSS suaves. Puedes ejecutarlo en cualquier navegador con un solo comando.

Al final de este capítulo, habrás:

+ Hecho un fork y clonado el proyecto
+ Elegido un tema para tu propia presentación
+ Pedido a un agente IA que genere ilustraciones personalizadas para cada diapositiva
+ Pedido a un agente IA que genere narración hablada para cada diapositiva
+ Personalizado el fondo animado para que coincida con tu tema
+ Visto el resultado final en tu navegador

Cada pieza de contenido generado por IA: las imágenes, el audio y los colores de la animación, provendrá de la API de inferencia gratuita de Hugging Face. Hugging Face aloja cientos de modelos de IA abiertos que cualquiera puede usar sin necesidad de tarjeta de crédito. Te comunicarás con ella a través de tu agente de programación IA.

== Lo que Necesitarás

De los capítulos anteriores:
- Git instalado y configurado
- CLI de GitHub autenticado
- Claude Code o Gemini CLI listo en tu terminal

Nuevo para este capítulo:
- Una cuenta de Hugging Face (gratuita)
- Un token de API de Hugging Face
- Python 3 (para ejecutar un servidor local y llamar a la API de Hugging Face)
- La biblioteca Python `huggingface_hub` (un solo comando `pip install`, que se cubre a continuación)

=== Obtén una Cuenta y Token de Hugging Face

Si no tienes una, regístrate en #link("https://huggingface.co/join")[huggingface.co/join]. Es gratuita: no se requiere tarjeta de crédito.

Una vez que hayas iniciado sesión:

+ Haz clic en tu foto de perfil (arriba a la derecha) → *Settings*
+ Haz clic en *Access Tokens* en la barra lateral izquierda
+ Haz clic en *New token*
+ Ponle un nombre como `agentic-crew` y selecciona acceso de *Read*
+ Haz clic en *Generate a token* y cópialo

Guarda este token a mano: lo pegarás en tu terminal en el siguiente paso.

=== Comprueba Python

Ejecuta:

```
python3 --version
```

#if is-windows [
Deberías ver Python 3.8 o superior. Prueba `python --version` si `python3` no funciona. Si Python no está instalado:

```
winget install Python.Python.3
```
]

#if is-mac [
Deberías ver Python 3.8 o superior. Si Python no está instalado:

```
brew install python
```
]

#if is-linux [
Deberías ver Python 3.8 o superior. Si Python no está instalado:

```
sudo apt install python3 python3-pip
```
]

Cierra y vuelve a abrir tu terminal tras la instalación, luego ejecuta `python3 --version` de nuevo para confirmar.

=== Instala la Biblioteca de Hugging Face

Los scripts que escribirá el agente usarán la biblioteca oficial de Python de Hugging Face. Instálala ahora:

```
pip install huggingface_hub
```

En algunos sistemas puede que necesites `pip3` en lugar de `pip`. Solo tienes que hacer esto una vez.

== Configura tu Token de Hugging Face

Tu agente IA usará este token para llamar a la API de Hugging Face. Configúralo como variable de entorno para que el agente pueda acceder a él sin codificarlo en ningún archivo.

#if is-mac or is-linux [
```
export HF_TOKEN="tu-token-aquí"
```
]

#if is-windows [
```
$env:HF_TOKEN = "tu-token-aquí"
```
]

Reemplaza `tu-token-aquí` con el token que copiaste. Ahora verifica que se configuró:

#if is-mac or is-linux [
```
echo $HF_TOKEN
```
]

#if is-windows [
```
echo $env:HF_TOKEN
```
]

#if is-mac or is-linux [
Deberías ver tu token impreso. Si no aparece nada, vuelve a ejecutar el comando `export`: la variable no se guardó.
]

#if is-windows [
Deberías ver tu token impreso. Si no aparece nada, vuelve a ejecutar el comando `$env:`: la variable no se guardó.
]

#quote(block: true)[
  *Mantén los tokens fuera de los archivos.* Nunca pegues tu token de API directamente en el código ni lo incluyas en un commit de Git. Las variables de entorno lo mantienen solo en memoria: sin riesgo de enviarlo accidentalmente a un repositorio público.
]

#if is-mac [
Esta configuración dura tu sesión de terminal actual. Para hacerla permanente, añade la línea `export` a tu archivo de configuración del shell (`~/.zshrc`).
]

#if is-linux [
Esta configuración dura tu sesión de terminal actual. Para hacerla permanente, añade la línea `export` a tu archivo de configuración del shell (`~/.bashrc`).
]

#if is-windows [
Esta configuración dura tu sesión de terminal actual. Para hacerla permanente, añádela en Propiedades del sistema → Variables de entorno.
]

== Fork y Clone del Proyecto

Este único comando crea tu propia copia del proyecto en GitHub y la descarga a tu máquina:

```
gh repo fork schlunsen/web-presenter --clone --remote
```

Entra en el directorio del proyecto:

```
cd web-presenter
```

Verifica tus conexiones con GitHub:

```
git remote -v
```

Deberías ver dos entradas:
- `origin` — tu fork (donde envías tus cambios)
- `upstream` — el proyecto original (de donde puedes obtener actualizaciones)

Cada remoto aparece listado dos veces: una para fetch y otra para push. Cuatro líneas en total es correcto. Si solo ves `origin`, algo salió mal: abre tu asistente IA y describe lo que ves; te ayudará.

== Explora el Proyecto

Pide al agente que te explique con qué estás trabajando. Abre tu asistente IA desde dentro del directorio del proyecto.

Si instalaste Claude Code, ejecuta:
```
claude
```

Si instalaste Gemini CLI, ejecuta:
```
gemini
```

Cualquiera funciona para todo en este capítulo. Una vez abierto, pregunta:

- _"Lee index.html, presentation-script.js y presentation-styles.css. Explica cómo funciona este framework de presentaciones: cómo se estructuran las diapositivas, cómo se carga la narración de audio y cómo funciona el fondo animado."_

El agente leerá los archivos y te dará un resumen en lenguaje sencillo. Entenderás el proyecto en dos minutos en lugar de treinta. Solo está leyendo en este punto: nada se está cambiando todavía.

Una vez que tengas una idea general, pregunta sobre los assets existentes:

- _"Lista todos los archivos en presentation-audio/ y presentation-images/. ¿Qué hay ahí ya?"_

Verás los clips de narración e imágenes existentes: marcadores de posición que estás a punto de reemplazar con los tuyos.

== Elige tu Tema

Elige algo que conozcas o que te importe. La presentación tiene diez diapositivas, así que quieres un tema con suficiente contenido para diez puntos cortos. Algunas ideas:

- Una tecnología que usas en el trabajo
- Un hobby o habilidad que quieres explicar a un amigo
- Un proyecto que estás construyendo
- Un argumento que quieres defender sobre algo

Para el resto de este capítulo, usaremos el marcador de posición *[TU TEMA]*: reemplázalo con lo que hayas elegido.

Anota diez puntos cortos: los temas de tus diapositivas. Una oración cada uno. Los pegarás en los prompts del agente que siguen.

#quote(block: true)[
  *Haz que tus puntos sean visuales.* Cada uno se convertirá en una imagen generada por IA, así que lo específico y concreto funciona mejor que lo abstracto. "Un almacén lleno de filas de servidores" generará una mejor ilustración que "infraestructura tecnológica". "Un niño leyendo bajo un árbol al atardecer" es mejor que "educación".
]

== Genera las Ilustraciones

En este paso pedirás al agente que escriba un script de Python. No lo escribirás tú: el agente lo hará. Tu trabajo es proporcionar tus diez puntos y luego pedir al agente que ejecute el script. Todo lo demás es automático.

Abre tu asistente IA (si no está ya abierto) y dale este prompt. *No lo copies palabra por palabra*: reemplaza `[TU TEMA]` con tu tema real y `[pega tus puntos]` con tus diez oraciones:

- _"Escribe un script de Python usando la biblioteca huggingface_hub. Usa InferenceClient con el token de la variable de entorno HF_TOKEN. Llama a client.text_to_image() con el modelo black-forest-labs/FLUX.1-schnell para generar una imagen por diapositiva y guarda cada resultado en presentation-images/ como slide-01.jpg, slide-02.jpg, etc. Aquí están los diez temas de las diapositivas: [pega tus puntos]. Haz que los prompts sean vívidos y consistentes en estilo."_

El agente escribirá el script. Revísalo: no necesitas entender cada línea, pero comprueba que lea el token del entorno (`os.environ` o similar) en lugar de tenerlo codificado en el código.

Cuando estés conforme, pide al agente que lo ejecute:

- _"Ejecuta el script."_

La generación tarda aproximadamente 10-20 segundos por imagen. El agente informará del progreso a medida que se complete cada una. Cuando termine, la carpeta `presentation-images/` contendrá diez nuevos archivos.

#quote(block: true)[
  *¿Y si una imagen no queda bien?* Pide al agente que regenere solo esa: _"La ilustración de la diapositiva 3 no queda bien: debería mostrar [descripción]. Regénera solo esa con un prompt mejor."_ La generación de imágenes es iterativa. Un segundo o tercer intento suele acercarse más a lo que tenías en mente.
]

== Genera la Narración

A continuación: audio hablado para cada diapositiva. Hugging Face aloja modelos de texto a voz que convierten texto en un archivo de audio. El audio sonará claro e inteligible: no del todo humano, pero suficientemente natural para una presentación.

Dale al agente este prompt, reemplazando los marcadores con tu texto de narración real:

- _"Escribe un script de Python usando la biblioteca huggingface_hub. Usa InferenceClient con el token de la variable de entorno HF_TOKEN. Llama a client.text_to_speech() con el modelo facebook/mms-tts-eng para generar narración para cada diapositiva. Guarda cada resultado en presentation-audio/ como slide-01.wav hasta slide-10.wav. Aquí están los textos de narración para cada diapositiva: [pega tus descripciones de una oración]."_

El agente escribirá el script. Ejecútalo del mismo modo:

- _"Ejecuta el script de narración."_

La generación de audio es más rápida que la de imágenes: espera unos pocos segundos por clip. Cuando termine, `presentation-audio/` tendrá diez archivos `.wav` listos para reproducir.

#quote(block: true)[
  *¿Quieres una voz más natural?* Pide al agente que pruebe `suno/bark-small` en su lugar: misma biblioteca, modelo diferente, más lento pero más expresivo. Solo pregunta: _"Reescribe el script de narración para usar el modelo suno/bark-small y ejecútalo de nuevo."_
]

== Actualiza la Presentación

`index.html` es el archivo principal del que lee tu presentación: contiene todo el contenido de las diapositivas, las rutas de imágenes y los nombres de archivos de audio. Ahora el agente lo actualizará con tu nuevo contenido.

- _"Actualiza index.html para reemplazar las diapositivas existentes con mis diez diapositivas sobre [TU TEMA]. Cada diapositiva debe usar la ilustración .jpg correspondiente de presentation-images/ y la narración .wav correspondiente de presentation-audio/. Usa los diseños de diapositivas existentes: diseño de título para la diapositiva 1, dos columnas o centrado para el resto. Mantén la estructura HTML exactamente como está; solo actualiza el contenido y las referencias a los assets."_

El agente hará las ediciones. Cuando termine, pídele que compruebe su propio trabajo:

- _"Lee index.html de nuevo y confirma que las diez diapositivas están presentes, cada una con la imagen y el archivo de audio correctos."_

Esta autocomprobación detecta referencias que faltan antes de que abras el navegador.

== Personaliza el Fondo Animado

El fondo Three.js dibuja una red de nodos y líneas de conexión. Por defecto usa azules y grises fríos. Pide al agente que lo adapte al ambiente de tu tema:

- _"Actualiza presentation-bg.js para cambiar los colores de la animación de la red a [describe tu paleta: por ejemplo, 'ámbar cálido y marrón oscuro', 'verde profundo y blanco suave' o 'azul eléctrico sobre negro']. También actualiza las variables de color CSS en presentation-styles.css para que coincidan."_

El agente editará ambos archivos. Si el resultado no se siente bien, describe lo que quieres con más precisión:

- _"El fondo es demasiado brillante. Haz los nodos más pequeños y reduce la opacidad de las líneas al 30%."_

Itera tantas veces como necesites. Cada cambio tarda unos segundos.

== Vista Previa en tu Navegador

Antes de abrir el navegador, confirma tres cosas:

+ La carpeta `presentation-images/` contiene 10 archivos `.jpg` (slide-01.jpg hasta slide-10.jpg)
+ La carpeta `presentation-audio/` contiene 10 archivos `.wav` (slide-01.wav hasta slide-10.wav)
+ La terminal que usaste para ejecutar los scripts de generación sigue activa en el directorio `web-presenter`

Si falta algún archivo, pregunta al agente: _"Comprueba las carpetas presentation-images/ y presentation-audio/. ¿Qué archivos hay y cuáles faltan?"_

Web Presenter necesita un servidor HTTP local: usa `fetch()` para cargar archivos de audio, lo que los navegadores bloquean para rutas `file://` simples. Pide al agente que inicie uno:

- _"Inicia un servidor HTTP local en este directorio en el puerto 8000."_

Ejecutará:

```
python3 -m http.server 8000
```

Deberías ver una salida como:

```
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
```

Eso significa que el servidor está listo. *Deja esta ventana de terminal abierta*: cerrarla detiene el servidor. Ahora abre tu navegador y ve a:

```
http://localhost:8000
```

Deberías ver tu presentación. Presiona la barra espaciadora o la flecha derecha para avanzar a la siguiente diapositiva. Cada diapositiva mostrará su ilustración, reproducirá la narración y avanzará automáticamente cuando el audio termine. También puedes presionar la flecha derecha para saltar manualmente.

Presiona `M` para activar/desactivar la música de fondo, `A` para activar/desactivar la narración y `Esc` para detener la reproducción.

Cuando hayas terminado, vuelve a la terminal y presiona *Ctrl+C* para detener el servidor.

== Commit y Push

Una vez que estés satisfecho con tu presentación, guarda tu trabajo en GitHub:

- _"Crea una rama llamada presentation/[TU TEMA], añade todos los archivos modificados, haz commit con un mensaje que describa lo que construí y envíalo a mi fork."_

El agente se encargará de cada paso de Git. Cuando termine, verifica en GitHub:

+ Ve a `https://github.com/TU_USUARIO/web-presenter`
+ Abre el selector de ramas y busca tu rama (`presentation/[TU TEMA]`)
+ Haz clic en ella: deberías ver tus nuevas imágenes, archivos de audio e `index.html` actualizado

Tu presentación ya está guardada en GitHub y es compartible con cualquiera a través de esa URL.

== Lo que Acaba de Pasar

Generaste diez ilustraciones de IA, las narraste, personalizaste gráficos 3D animados y actualizaste un proyecto web, todo describiendo lo que querías en español natural. El agente se encargó de la mecánica. Así es como se ve la programación agéntica.

#table(
  columns: (1fr, 1fr),
  [*Tú aportaste*], [*El agente aportó*],
  [Un tema que te importa], [Llamadas a la API de Hugging Face],
  [Diez oraciones de contenido], [Un script de Python funcional],
  [Una descripción de paleta de colores], [JavaScript y CSS actualizados],
  [El criterio sobre qué queda bien], [La mecánica para hacerlo realidad],
)

La habilidad no es programar. Es saber qué pedir, cómo comprobar el resultado y cómo iterar cuando no es del todo correcto. Eso es lo que desarrollarán los próximos capítulos.

== Solución de Problemas

*La generación de imágenes devuelve un error sobre el modelo demasiado ocupado:*
La API de inferencia gratuita tiene límites de velocidad. Espera 30 segundos e inténtalo de nuevo, o pide al agente que añada un retraso: _"Añade una pausa de 10 segundos entre cada llamada de generación de imágenes."_

*Los archivos de audio están en silencio o no se reproducen:*
El modelo TTS devuelve archivos WAV, no MP3. Si index.html referencia extensiones `.mp3`, pide al agente: _"Comprueba si los atributos src de audio en index.html usan extensiones .wav. Actualiza los que no coincidan con los archivos en presentation-audio/."_ También confirma el tamaño de los archivos: cualquier archivo `.wav` de menos de 5 KB probablemente es una respuesta de error que necesita regenerarse.

*Las diapositivas muestran iconos de imagen rota:*
La ruta de la imagen en el HTML no coincide con el nombre de archivo real. Pregunta: _"Comprueba todos los atributos src de imágenes en index.html contra los archivos reales en presentation-images/. Corrige cualquier discrepancia."_

#if is-windows [
*El comando del servidor falla:*
Prueba `python -m http.server 8000` en lugar de `python3`. O pide al agente: _"Inicia un servidor local usando npx serve."_
]

*Mi HF_TOKEN no lo encuentra el script:*
#if is-mac or is-linux [
La variable se configuró en una sesión de terminal diferente. Configúrala de nuevo en la sesión actual (`export HF_TOKEN="..."`), y luego vuelve a ejecutar el script.
]
#if is-windows [
La variable se configuró en una sesión de terminal diferente. Configúrala de nuevo en la sesión actual (`$env:HF_TOKEN = "..."`), y luego vuelve a ejecutar el script.
]

*No carga nada o la página está en blanco:*
Asegúrate de que el servidor se está ejecutando en el directorio `web-presenter`, no en una carpeta superior. Abre las herramientas de desarrollo de tu navegador (F12) y revisa la pestaña Consola: los archivos que faltan aparecen listados ahí. Dile al agente lo que ves y lo arreglará.

*La animación Three.js ha dejado de funcionar después de editar:*
Pregunta al agente: _"La animación del fondo ha dejado de funcionar. Lee presentation-bg.js y comprueba si hay errores de sintaxis o llamadas a funciones que faltan."_

*La rama incorrecta aparece en GitHub después del push:*
Asegúrate de que el nombre de la rama no tenga espacios: usa guiones. Pregunta al agente: _"¿Qué rama enviamos? Muéstrame la salida de git branch -a."_

Si encuentras un error que no aparece aquí, descríbeselo a tu agente IA: ha visto la mayoría de los errores antes y generalmente sabrá qué hacer.

== Referencia Rápida

#table(
  columns: (1fr, 2fr),
  [*Tarea*], [*Prompt o comando*],
  [Verificar que el token HF está configurado], [#if is-mac or is-linux [`echo $HF_TOKEN`] #if is-windows [`echo $env:HF_TOKEN`]],
  [Explorar el proyecto], [_"Lee index.html y explica cómo funcionan las diapositivas"_],
  [Instalar la biblioteca HF], [`pip install huggingface_hub`],
  [Generar imágenes], [_"Usa InferenceClient.text_to_image() con FLUX.1-schnell..."_],
  [Generar narración], [_"Usa InferenceClient.text_to_speech() con facebook/mms-tts-eng..."_],
  [Actualizar contenido de diapositivas], [_"Actualiza index.html con mis diez diapositivas..."_],
  [Cambiar fondo], [_"Actualiza los colores de la animación a..."_],
  [Comprobar archivos generados], [_"Lista los archivos en presentation-images/ y presentation-audio/"_],
  [Iniciar servidor local], [`python3 -m http.server 8000`],
  [Ver presentación], [`http://localhost:8000`],
  [Detener el servidor], [`Ctrl+C` en la terminal del servidor],
)
