= El Prompting Como Ingeniería

No hay una sintaxis secreta. Ninguna fórmula mágica que haga que un agente produzca código perfecto. El prompting es _comunicación_ — y ya sabes cómo comunicar.

Si alguna vez has escrito un buen informe de bug, sabes cómo hacer prompts. Si alguna vez has escrito un documento de diseño que un compañero podía implementar sin hacerte veinte preguntas, sabes cómo hacer prompts. Si alguna vez has creado un ticket de Jira que no volvió como algo completamente diferente de lo que querías — sabes cómo hacer prompts.

Las habilidades se transfieren directamente. Claridad, especificidad, contexto, restricciones. Las mismas cosas que hacen eficiente la colaboración humana hacen eficiente la colaboración con agentes. La diferencia es que los agentes no harán preguntas aclaratorias cuando tu prompt es vago. Simplemente adivinarán. Y adivinarán con confianza.

Aquí es donde muchos ingenieros experimentados luchan en silencio. Has pasado años construyendo la habilidad de _hacer_ — escribir código, depurar, construir sistemas. Ahora la habilidad que importa es _articular_ — explicar lo que quieres con suficiente precisión para que alguien más pueda hacerlo. Es un músculo diferente. Y puede sentirse, en los primeros días, como una degradación. No lo es. Pero la incomodidad es real, y pretender que no es así no ayuda.

== La Anatomía de un Buen Prompt de Tarea

Un buen prompt tiene tres partes: _qué_ quieres que se haga, _por qué_ importa, y _cómo_ se ve el éxito. La mayoría de la gente solo proporciona lo primero, y hasta eso suele ser vago.

Considera la diferencia:

*Mal:* "Arregla el bug de autenticación."

Esto no le dice casi nada al agente. ¿Qué bug de autenticación? ¿Dónde se manifiesta? ¿Cuál es el comportamiento esperado? El agente irá a buscar por tu código base, formará una teoría sobre lo que podrías querer decir, y aplicará una corrección que podría estar completamente equivocada. Has convertido una corrección de cinco minutos en una revisión de veinte minutos de algo que no pediste.

*Bien:* "El endpoint de login devuelve 401 para tokens válidos cuando la caché de sesiones está fría. El bug probablemente está en `middleware/auth.go` en la función `validateSession`. El test en `auth_test.go:TestColdCacheLogin` lo reproduce. Arregla el bug y asegúrate de que todos los tests existentes de autenticación sigan pasando."

Esto es un animal completamente diferente. El agente conoce el síntoma, la ubicación sospechada, y cómo verificar la corrección. Puede ir directamente al código relevante, entender el problema y validar su solución — todo sin adivinar.

*Con herramientas:* "El endpoint de login devuelve 401 para tokens válidos cuando la caché de sesiones está fría. El test que falla es `TestColdCacheLogin`. Investiga, arréglalo y asegúrate de que todos los tests de autenticación pasen."

Fíjate en lo que falta: sin ruta de archivo, sin nombre de función. El agente tiene `grep`, `find` y el ejecutor de tests. Puede _descubrir_ dónde vive `TestColdCacheLogin` y trazar el camino del código por sí mismo. Lo que le diste es el _qué_ y el _por qué_ — el conocimiento de dominio que las herramientas no pueden proporcionar. El detalle de la caché fría, el síntoma, el nombre del test como hilo del que tirar. El agente hace el trabajo mecánico de localizar el código.

Los tres niveles son útiles. A veces _sí_ conoces el archivo y la función exactos, y darlos ahorra al agente treinta segundos de búsqueda. Pero el tercer nivel representa el modelo mental maduro: proporciona solo lo que el agente no puede encontrar por sí mismo. La descripción del problema, el contexto de dominio, la intención. Deja que las herramientas se encarguen del descubrimiento.

El patrón es simple. _Qué_ está roto o se necesita. _Dónde_ mirar (si ya lo sabes — no vayas a buscar solo para completar esto). _Cómo_ verificar. Cada minuto que pasas haciendo tu prompt preciso te ahorra cinco minutos revisando la salida equivocada.

== Especificación de Restricciones

Decirle a un agente qué hacer es solo la mitad del trabajo. Decirle qué _no_ hacer es igualmente importante.

Los agentes son entusiastas. Optimizan para resolver el problema que describiste, y felizmente refactorizarán todo tu módulo, añadirán tres dependencias nuevas y cambiarán la API pública para hacerlo. Eso no es malicia — es un optimizador haciendo lo que hacen los optimizadores. Tu trabajo es establecer los límites.

Las restricciones útiles se ven así:

- "No modifiques la superficie de la API pública."
- "Mantén la estructura de tests existente — añade casos de test nuevos, no reorganices."
- "No añadas nuevas dependencias."
- "Mantente dentro de los patrones de manejo de errores existentes en este código base."
- "No cambies ningún archivo fuera del directorio `services/`."

Piensa en las restricciones como las barandillas de un puente. El agente puede conducir a cualquier lugar dentro de los carriles, pero no puede pasar por encima del borde. Sin barandillas, obtienes soluciones creativas que técnicamente funcionan pero crean pesadillas de mantenimiento. Con ellas, obtienes soluciones que encajan en tu código base como si siempre hubieran estado ahí.

Cuanta más experiencia acumulas en ingeniería agéntica, más tus prompts se definen por sus restricciones que por sus instrucciones. Aprendes qué libertades llevan a buenos resultados y cuáles llevan al caos.

== Descomposición de Tareas

Un error común: pedirle a un agente que construya algo grande en un solo prompt. "Construye un panel de usuario con métricas en tiempo real, acceso basado en roles y exportación a CSV." Eso no es un prompt — es un proyecto. Y los proyectos necesitan descomponerse en tareas.

La descomposición de tareas es la práctica de dividir peticiones grandes en pasos pequeños y _verificables_. Cada paso tiene una entrada clara, una salida clara y una forma clara de comprobar si funcionó.

En lugar de "construye un panel de usuario," escribes:

+ Crea el modelo de datos para las métricas del panel en `models/dashboard.go` con el esquema definido en el documento de diseño. Escribe tests unitarios para la validación del modelo.
+ Construye el endpoint de API `GET /api/dashboard` que devuelve métricas para el usuario autenticado. Escribe tests de integración.
+ Añade filtrado basado en roles para que los usuarios admin vean todas las métricas y los usuarios normales solo vean las suyas. Actualiza los tests existentes para cubrir ambos roles.
+ Construye el componente React que muestra los datos del panel. Usa el componente `DataTable` existente para la cuadrícula de métricas.

Cada paso es un prompt autocontenido. Cada uno tiene un resultado verificable. Cada uno se construye sobre la salida verificada del paso anterior. Si el paso dos sale mal, lo detectas antes de haber desperdiciado tiempo en el paso tres.

Esto no es solo buen prompting — es buena ingeniería. Estás aplicando las mismas habilidades de descomposición que usarías al planificar un sprint o desglosar un pull request. La unidad de trabajo es lo suficientemente pequeña para revisar, lo suficientemente pequeña para testear, y lo suficientemente pequeña para tirar si está mal.

== Prompting para Paralelismo

Hay algo que la mayoría de la gente no ve: puedes decirle al agente que paralelice.

Las herramientas agénticas modernas — Claude Code, Cursor, Cline — pueden lanzar sub-agentes. Cada sub-agente tiene su propio contexto, su propio espacio de trabajo, su propio hilo de ejecución. Se ejecutan simultáneamente. El agente padre coordina, espera resultados y ensambla la salida. Esto no es una funcionalidad oculta que necesitas desbloquear. Está ahí. Pero casi nadie hace prompts para ello.

Considera la diferencia. Tienes una funcionalidad que toca tres módulos independientes — la API, el worker y el servicio de notificaciones. El enfoque secuencial:

_"Implementa el handler de webhook en el módulo API. Luego actualiza el worker para procesar eventos webhook. Luego añade notificaciones para webhooks fallidos."_

El agente hace cada paso uno a la vez. Veinte minutos, quizá treinta. Bien.

Ahora el enfoque paralelo:

_"Esta funcionalidad toca tres módulos independientes. Lanza sub-agentes para trabajar en ellos en paralelo: uno para el handler de webhook en el módulo API, uno para el worker que procesa eventos webhook, y uno para el servicio de notificaciones que alerta sobre fallos. Cada módulo tiene su propio directorio y sus propios tests. Fusiona los resultados cuando los tres terminen."_

El mismo trabajo. Un tercio del tiempo de reloj. La palabra clave en ese prompt es _independientes_ — le estás diciendo al agente que estas piezas no dependen unas de otras, así que es seguro paralelizar. Le estás dando permiso para ser rápido.

Esto funciona porque _tú_ tienes la visión general de la arquitectura. Sabes qué módulos están acoplados y cuáles no. Sabes qué piezas se pueden construir simultáneamente y cuáles necesitan ser secuenciales. El agente no siempre sabe esto — por defecto hace las cosas de una en una, porque lo secuencial es seguro. Tu trabajo es ver el paralelismo y hacerlo explícito.

Algunos patrones de prompting que fomentan el paralelismo:

- *"Estas tareas son independientes — ejecútalas en paralelo."* Directo y efectivo. El agente sabe que tiene permiso.
- *"Lanza un sub-agente para cada una de estas."* Instrucción explícita para usar la capacidad de ejecución paralela.
- *"Trabaja en la API y el frontend simultáneamente — comparten la interfaz definida en `types.ts` pero no dependen de las implementaciones del otro."* Contexto sobre _por qué_ el paralelismo es seguro.
- *"Empieza los tres y repórtame cuando estén listos."* Lo enmarca como una tarea de coordinación, que es exactamente lo que es.

El cambio de modelo mental es sutil pero importante. No solo le estás diciendo al agente _qué_ construir — le estás diciendo _cómo organizar el trabajo_. Estás siendo un tech lead, no solo un escritor de tickets. Estás diciendo "he mirado este problema, veo tres flujos independientes, y quiero que atiendas los tres simultáneamente."

Este es el apalancamiento de ingeniería que los desarrolladores experimentados aportan al trabajo agéntico. Un ingeniero junior puede no saber qué piezas es seguro paralelizar. Tú sí. Y cuando codificas ese conocimiento en el prompt, el agente se vuelve dramáticamente más rápido — no porque sea más inteligente, sino porque le diste un mejor plan.

== El Prompt Como Especificación

Los mejores prompts que he visto se leen como documentos de diseño en miniatura. Describen el resultado deseado, no los pasos de implementación. Listan las restricciones. Definen criterios de aceptación. Proporcionan justo el contexto suficiente para que el agente tome buenas decisiones sin ahogarlo en información irrelevante.

Así se ve un prompt-como-especificación:

_"Añade limitación de tasa al endpoint `/api/search`. Usa el middleware `RateLimiter` existente en `middleware/ratelimit.go`. Establece el límite a 100 peticiones por minuto por usuario autenticado, y 20 por minuto para peticiones no autenticadas. Devuelve un status 429 con un header `Retry-After` cuando se exceda el límite. Añade tests para ambas rutas, autenticada y no autenticada, incluyendo el caso límite donde un usuario alcanza exactamente el límite. No modifiques el middleware de limitación de tasa en sí — solo configúralo y aplícalo."_

Eso es una especificación. Un agente puede implementar esto sin ambigüedad. Un revisor humano puede comprobar el resultado contra los requisitos. El resultado deseado es claro, las restricciones son explícitas y los criterios de verificación están definidos.

Escribir prompts de esta forma requiere práctica. También requiere disciplina — la disciplina de pensar en lo que realmente quieres antes de empezar a teclear. Pero esa disciplina paga dividendos. Un prompt bien especificado produce un resultado que puedes fusionar. Un prompt vago produce un resultado que tienes que reescribir.

== Iteración Sobre Perfección

Tu primer prompt no será perfecto. Eso está bien. El prompting es un proceso iterativo, y la habilidad no está en escribir el prompt perfecto — está en _leer la salida_, entender dónde se rompió la comunicación y refinar.

Cuando un agente produce algo equivocado, resiste la tentación de culpar a la herramienta. En su lugar, pregúntate: ¿qué no logré comunicar? ¿Dejé fuera una restricción? ¿El contexto era insuficiente? ¿Asumí conocimiento que el agente no tenía?

Esto es depuración — pero en lugar de depurar código, estás depurando tu propia comunicación. El mensaje de error es la salida del agente. La traza de pila es tu prompt. En algún lugar ahí está la falta de comunicación, y encontrarla hace que tu próximo prompt sea mejor.

Los ingenieros agénticos experimentados desarrollan un instinto de retroalimentación. Ven la salida del agente e inmediatamente saben qué parte de su prompt causó la desviación. "Ah, dije 'maneja los errores' pero no especifiqué _qué_ errores ni _cómo_ manejarlos. Claro que metió un catch-all genérico."

Cada iteración ajusta el bucle. El primer prompt te lleva al 70%. Una corrección de seguimiento te lleva al 90%. Un refinamiento final te lleva al hecho. Con el tiempo, tus primeros prompts mejoran y necesitas menos iteraciones. Pero nunca necesitas cero.

== Desarrollo Dirigido por Voz

La mayoría de nosotros hacemos prompts tecleando. Eso tiene sentido — somos ingenieros, vivimos en texto. Pero hay otro canal de entrada que es más rápido, más natural y sorprendentemente infrautilizado: tu voz.

La conversión de voz a texto moderna ha alcanzado el punto en el que puedes hablar un prompt en tu terminal y tenerlo transcrito con precisión casi perfecta. Herramientas como Whisper, la Dictación de macOS y SuperWhisper te permiten hablar con tu agente en lugar de teclear. El resultado es el mismo — entra texto, sale código. Pero la experiencia es fundamentalmente diferente.

He aquí por qué: teclear y hablar son modos diferentes de pensar. Cuando tecleas, editas sobre la marcha. Borras una palabra, reformulas, retrocedes, reestructuras. El texto que produces está _pulido_ — tuviste tiempo de suavizar las asperezas antes de que dejara tus dedos. Hablar no te da ese lujo. Cuando hablas, te comprometes. Las palabras salen de tu boca y se han ido. No hay tecla de retroceso.

Esto suena como una desventaja. En realidad es un campo de entrenamiento.

Cuando hablas un prompt, te ves forzado a organizar tus pensamientos _antes_ de abrir la boca. No puedes apoyarte en la muleta de editar a mitad de frase. Tienes que saber lo que quieres, estructurarlo mentalmente y entregarlo con claridad — en tiempo real. Las primeras veces que lo intentes, divagarás. Dirás "eh" y "mm" y darás vueltas y te contradirás. El agente recibirá una transcripción desordenada, y la salida reflejará ese desorden.

Pero algo pasa si sigues haciéndolo. Mejoras. No solo en el prompting — en _hablar con claridad sobre problemas técnicos_. Desarrollas la capacidad de describir un bug, una funcionalidad o una tarea de refactorización en un solo flujo coherente. Aprendes a cargar el contexto al frente, a establecer restricciones temprano y a terminar con una petición clara. Dejas de divagar porque divagar produce malos resultados.

Esta habilidad se transfiere a todas partes. Reuniones de standup. Discusiones de arquitectura. Pair programming. Llamadas de incidentes. Cada situación donde necesitas articular una idea técnica con claridad, bajo presión de tiempo, sin la red de seguridad de un editor de texto. El desarrollo dirigido por voz no es solo una forma más rápida de hacer prompts — es práctica para cada conversación técnica que tendrás.

También hay una ventaja práctica de velocidad. La mayoría de la gente habla a 130 palabras por minuto. La mayoría teclea a 40 a 80. Para el tipo de prompts de alto nivel, orientados a intención, que producen la mejor salida del agente — "aquí está el problema, aquí está el contexto, aquí está lo que quiero, aquí está lo que no quiero" — hablar es simplemente más rápido. Pasas menos tiempo en la entrada y más tiempo revisando la salida.

Pruébalo durante una semana. Elige una herramienta de voz a texto, conéctala a tu flujo de trabajo y habla tus prompts en lugar de teclearlos. El primer día se sentirá torpe. Para el tercer día, notarás que tus prompts hablados se vuelven más ajustados. Al final de la semana, notarás que tu _comunicación hablada en general_ se vuelve más ajustada.

También vale la pena señalar que los modelos de voz a texto pueden ejecutarse enteramente en tu máquina. La familia de modelos Parakeet de NVIDIA — modelos ASR compactos y de alta precisión — se ejecutan localmente sin ninguna dependencia cloud. Herramientas como SuperWhisper y whisper.cpp hacen lo mismo usando los pesos de Whisper de OpenAI. Un MacBook moderno puede ejecutar estos modelos en tiempo casi real con transcripción precisa y baja latencia. No necesitas un servicio cloud para convertir voz en texto — el tooling local ya está ahí.

A los agentes no les importa si tu prompt fue tecleado o hablado. Pero _tú_ serás un pensador más claro por haberlo hablado.

== Contexto Visual: Cuando las Palabras No Son Suficientes

No todo es fácil de describir en texto. Un layout roto, un glitch de renderizado extraño, un diálogo de error con una traza de pila — a veces la forma más rápida de comunicar lo que estás viendo es _mostrarlo_.

Los LLMs modernos son multimodales. Pueden leer capturas de pantalla, diagramas, fotos de pizarras y mensajes de error capturados de tu pantalla. Esto no es una funcionalidad novedosa — es una de las herramientas más infrautilizadas en el flujo de trabajo de ingeniería agéntica.

Aquí hay un flujo de trabajo que uso a diario: veo un bug en mi teléfono — un layout roto, un modal descentrado, un formulario que se come la entrada. Hago una captura en iOS, y gracias al Portapapeles Universal, la pego directamente en mi sesión de terminal en mi Mac. El agente ve lo que yo veo. No hay necesidad de describir "el botón se superpone al header en el viewport móvil" — la captura _es_ la descripción.

Esto importa porque los bugs visuales son notoriamente difíciles de describir en texto. Terminas escribiendo tres párrafos sobre padding y z-index cuando una sola captura de pantalla comunica el problema instantáneamente. El agente puede ver el estado roto, razonar sobre qué está mal y proponer una corrección — a menudo más rápido de lo que podrías terminar de escribir la descripción.

Pero va más allá de los informes de bugs. Algunos flujos de trabajo comunes con contexto visual:

- *Capturas de errores.* Una consola de navegador llena de rojo, una traza de pila del terminal, un panel de despliegue mostrando health checks fallidos. Haz una captura, pégala, pide al agente que diagnostique. Esto es especialmente útil cuando los mensajes de error son largos o contienen formato que es doloroso de copiar como texto.
- *Referencias de diseño.* Un mockup de Figma, un boceto, la UI de un competidor que quieres aproximar. Pega la imagen y di "haz que nuestra página de configuración se vea como esto." El agente puede extraer estructura de layout, elecciones de color y jerarquía de componentes de una referencia visual.
- *Depuración de estado visual.* "¿Por qué esta página se ve mal?" es un prompt terrible. Una captura de pantalla de la página _más_ "¿por qué esta página se ve mal?" es uno genial. El agente puede comparar lo que ve contra el layout esperado e identificar problemas de CSS, datos faltantes o bugs de renderizado.
- *Fotos de pizarra.* Después de una discusión de arquitectura, saca una foto de la pizarra y pégala. El agente puede leer las cajas, flechas y etiquetas, y ayudarte a traducir ese boceto en estructura de código, definiciones de API o documentación.

El pipeline del portapapeles de iOS a Mac merece mención especial porque elimina toda fricción de este flujo de trabajo. No necesitas guardar la captura, hacer AirDrop, encontrarla en Finder y arrastrarla a una herramienta. Ves el problema, lo capturas, lo pegas. Tres segundos desde "eso está roto" hasta "el agente lo está mirando." Esa velocidad importa porque te mantiene en el flujo. Cualquier paso extra — incluso treinta segundos de gestión de archivos — crea suficiente fricción para que vuelvas a escribir una descripción de texto, que es más lenta y menos precisa.

La idea clave es que _el contexto no es solo texto_. Cuando hablamos de que el contexto es el ingrediente más importante en el trabajo agéntico, estábamos hablando de todas las formas de contexto — archivos de código, documentación, salida de tests _y_ estado visual. Una captura de pantalla vale mil tokens, y los agentes que pueden ver son dramáticamente más útiles que los agentes que solo pueden leer.

Si no estás usando contexto visual en tu flujo de trabajo agéntico ya, empieza. Haz capturas de tus bugs. Pega tus mensajes de error. Comparte tus referencias de diseño. Los agentes pueden ver ahora. Déjalos.

== Anti-Patrones

Algunos hábitos de prompting consistentemente producen malos resultados. Aprende a reconocerlos.

*Ser demasiado vago.* "Haz este código mejor." ¿Mejor cómo? ¿Más rápido? ¿Más legible? ¿Más mantenible? El agente elegirá _algo_ para mejorar, y probablemente no será lo que tenías en mente. Si no puedes articular qué significa "mejor," no estás listo para hacer el prompt.

*Ser demasiado prescriptivo.* El fallo opuesto. "En la línea 47, cambia el nombre de la variable de `x` a `count`, luego añade un if en la línea 48 que compruebe si count es mayor que cero, luego..." Estás escribiendo el código en español y pidiéndole al agente que traduzca. Eso es más lento que escribir el código tú mismo. Describe el _resultado_, no las pulsaciones de teclas.

*Volcado de contexto.* Pegar todo tu código base, todos tus documentos de diseño y una transcripción de tus últimas tres reuniones de equipo en el prompt. Más contexto no siempre es mejor. El contexto irrelevante es ruido, y el ruido ahoga la señal. Dale al agente lo que necesita — rutas de archivos, nombres de funciones, el comportamiento específico que quieres — y confía en que explore desde ahí.

*Prompts fregadero.* "Arregla el bug de autenticación, también refactoriza la capa de base de datos, y ya que estás actualiza el README y añade tipos TypeScript al cliente de API." Estas son cuatro tareas separadas metidas en un prompt. El agente intentará todas, no hará ninguna bien, y producirá un diff tan grande que revisarlo toma más tiempo que hacer el trabajo tú mismo. Un prompt, una tarea.

*Asumir contexto compartido.* "Hazlo igual que hicimos con el módulo de pagos." El agente no recuerda tu última sesión. No sabe lo que "nosotros" decidimos en el standup. Cada prompt empieza desde cero. Proporciona el contexto explícitamente, cada vez.

*Hacer el trabajo del agente por él.* Pasas cinco minutos buscando en el código base para encontrar el archivo exacto, número de línea y nombre de función, y luego lo pegas todo en tu prompt. Ese es trabajo que las herramientas del agente pueden hacer en segundos. Proporciona el _problema_ — el síntoma, el contexto, el nombre del test que falla. Deja que el agente investigue. Para eso son sus herramientas. Tu tiempo se emplea mejor en las partes que el agente _no puede_ hacer: entender el dominio, definir las restricciones, saber por qué este comportamiento es incorrecto en primer lugar.

== El Prompting Es una Habilidad

El prompting no es un truco de salón. No se trata de descubrir la frase mágica que desbloquea mejor salida. Es una habilidad de comunicación — y como todas las habilidades de comunicación, mejora con práctica, retroalimentación y atención deliberada.

Los ingenieros que sacan más provecho de las herramientas agénticas son los que tratan el prompting con el mismo rigor que aplican a escribir código. Piensan antes de teclear. Especifican antes de implementar. Verifican antes de seguir adelante.

Eso no es una habilidad nueva. Eso es simplemente ingeniería.
