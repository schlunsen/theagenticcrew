= Contexto

El mes pasado, llegó un bug de un cliente: los pagos estaban fallando silenciosamente para usuarios con caracteres no ASCII en su dirección de facturación. Uno complicado — del tipo que vive en la costura entre la validación de tu frontend y la codificación de caracteres de tu pasarela de pagos.

Un ingeniero de mi equipo cogió el ticket primero. Abrió su agente y escribió: "Hay un bug con los pagos para usuarios internacionales. ¿Puedes investigarlo?" El agente leyó alegremente el módulo de pagos, hizo algunas suposiciones plausibles sobre el manejo de Unicode y produjo un parche que normalizaba toda la entrada a ASCII. Habría eliminado cada acento, cada diéresis, cada carácter fuera del alfabeto inglés de la dirección de facturación de cada usuario. Una corrección técnicamente peor que el bug.

Una hora después, una segunda ingeniera tomó el mismo ticket después de que el primer intento fue rechazado en la revisión. Ella pegó el log de error del cliente, la traza de Sentry que fallaba, el código de respuesta específico de la pasarela de pagos, la sección relevante de la documentación de codificación de caracteres de la pasarela, y los tres archivos involucrados en el pipeline de facturación. Su agente diagnosticó el problema en menos de dos minutos: una cadena UTF-8 se estaba pasando a través de una función que asumía codificación Latin-1 antes de llegar a la API de la pasarela. La corrección fueron cuatro líneas. Se desplegó esa tarde.

El modelo era el mismo. El agente era el mismo. El bug era el mismo. Lo que difería era lo que cada ingeniero puso delante del agente antes de pedirle que trabajara. Uno le dio una descripción vaga y lo dejó adivinar. La otra le dio todo lo que necesitaba para _ver_ el problema.

Pero aquí está la cuestión: la segunda ingeniera no solo dio mejor contexto. Le dio al agente los _materiales en bruto_ que necesitaba — la traza de error, los docs, los archivos relevantes. Eso es un paso significativo hacia arriba. ¿La versión aún mejor? Darle al agente _herramientas_ para encontrar esos materiales por sí mismo. Si esa traza de Sentry fuera accesible a través de una integración MCP, si el agente pudiera leer los docs de la pasarela desde una fuente configurada, si pudiera ejecutar `git log` sobre el pipeline de facturación — ella no habría necesitado ensamblar el contexto manualmente. El agente lo habría reunido, y ella podría haberse enfocado en lo que solo ella podía aportar: el criterio de que esto era un problema de codificación de caracteres, no de validación.

Esa diferencia — lo que el agente puede ver y a lo que puede _llegar_ — es de lo que trata este capítulo.

La habilidad más importante en la ingeniería agéntica no es el prompting. Es la gestión del contexto.

Un agente de IA es tan bueno como lo que puede ver. Dale una instrucción vaga y una pizarra en blanco, y alucinará con confianza. Dale los archivos correctos, las restricciones correctas, la vista correcta del sistema — y hará cosas que parecen magia. La diferencia no es el modelo. Eres tú.

La ingeniería tradicional también tenía una versión de esto. Un ingeniero senior no solo escribía mejor código — mantenía más del sistema en su cabeza. Sabía qué archivos importaban, dónde vivían los dragones, qué abstracciones eran estructurales y cuáles eran decorativas. Ese modelo mental era el contexto, y vivía enteramente en el cerebro del ingeniero.

Ahora tienes que _externalizarlo_. Tus agentes no pueden leer tu mente. Leen archivos, variables de entorno, logs de errores y lo que pongas delante de ellos — y cada vez más, pueden _encontrar_ esas cosas si les das las herramientas adecuadas. El oficio de la ingeniería agéntica es aprender qué sacar a la superficie, cuándo y cómo — y, más importante, construir la infraestructura que permite a los agentes encontrar las cosas por sí mismos.

== La Ventana de Contexto Es Tu Banco de Trabajo

Piensa en la ventana de contexto como un banco de trabajo físico. Tiene espacio limitado. No puedes volcar todo tu código base encima y esperar buenos resultados. En su lugar, colocas las piezas que importan para _esta_ tarea: los archivos de código relevantes, el test que falla, el esquema, quizá un fragmento de documentación.

Pero aquí está la evolución en el pensamiento: no eres el asistente del cirujano, entregando instrumentos nerviosamente uno a la vez. Eres la persona que _diseñó el quirófano_. Un buen ingeniero agéntico cura el contexto, sí — pero la habilidad real es construir un taller bien organizado donde el agente pueda encontrar lo que necesita. Estructura de archivos clara, herramientas accesibles, cajones bien etiquetados. Cuando el taller está bien montado, el agente saca el instrumento correcto de la pared por sí mismo. Tú intervenes solo cuando necesita algo que no está en ningún estante — tu criterio, tu intención, tu conocimiento de por qué las cosas son como son.

#image("../../assets/illustrations/ch02-context-workbench.jpg", width: 80%)

Esto significa desarrollar instintos para preguntas como:
- ¿Qué necesita ver el agente para entender esta tarea?
- ¿Qué lo confundirá si lo incluyo?
- ¿El contexto que estoy proporcionando es _actual_, o le estoy dando información obsoleta?

== Infraestructura de Contexto vs. Inyección de Contexto

Antes de entrar en los detalles, vale la pena nombrar las dos capas de contexto que importan en el trabajo agéntico — porque la mayoría de los ingenieros solo piensan en una de ellas.

*Capa 1: Infraestructura de Contexto.* Esta es la inversión duradera. Es todo lo que configuras _una vez_ que se paga en cada sesión: acceso al sistema de archivos, ejecución de comandos, integraciones MCP con tu rastreador de errores y herramientas de gestión de proyectos, estructura de repositorio bien organizada, archivos `CLAUDE.md` que describen tu arquitectura y convenciones. Cuando inviertes en infraestructura de contexto, estás construyendo un taller donde el agente puede encontrar sus propias herramientas. Esto es _ingeniería_ — se acumula.

*Capa 2: Inyección de Contexto.* Este es el trabajo manual por sesión: pegar logs de error, escribir restricciones, explicar conocimiento de dominio, describir intención. Sigue siendo esencial — hay cosas que ninguna herramienta puede descubrir, como por qué se tomó una decisión de diseño particular, o que el equipo de marketing necesita esta funcionalidad para el jueves. Pero debería ser el _recurso de último momento_, no el predeterminado. Cada vez que te encuentras pegando repetidamente el mismo tipo de información, esa es una señal de promoverla de Capa 2 a Capa 1 configurando una herramienta o integración.

Los mejores ingenieros agénticos dedican la mayor parte de su esfuerzo a la Capa 1 y necesitan la Capa 2 solo para cosas que son genuinamente efímeras o tácitas. Los demás pasan todo su tiempo en la Capa 2 y se preguntan por qué cada sesión se siente como empezar desde cero.

=== Niveles de Entrega de Contexto

Hay una forma útil de pensar sobre cómo llega el contexto a tu agente, de menos efectivo a más:

*Nivel 0: Describe el problema con tus propias palabras.* "El build está roto, algo sobre tipos." Esta es la forma más ruidosa de contexto. Estás comprimiendo un error detallado a través del tubo estrecho de tu paráfrasis, y el agente tiene que descomprimirlo — mal — al otro lado. Es como describir una pintura a alguien por teléfono y pedirle que la reproduzca.

*Nivel 1: Pega datos en bruto.* Copia la traza de pila, la salida del test que falla, el archivo de log, el código fuente relevante. Aquí es donde aterrizan la mayoría de los ingenieros competentes hoy, y es un paso significativo hacia arriba. El agente ve exactamente lo que tú viste. Sin compresión ruidosa. La limitación es que es manual, es efímero y no escala — en la próxima sesión, tendrás que pegarlo todo de nuevo.

*Nivel 2: Dale al agente herramientas para encontrar los datos por sí mismo — y proporciona solo lo que las herramientas no pueden descubrir.* El agente ejecuta el test que falla, lee la traza de error, hace grep del código relevante, comprueba `git blame` para el historial. Tú proporcionas la _intención_ ("necesitamos arreglar esto sin cambiar el formato almacenado porque tres servicios downstream dependen de él") y las _restricciones_ ("la pasarela de pagos tiene una peculiaridad que no está documentada en ningún sitio"). Aquí es donde deberías apuntar. Es duradero, escala y te permite concentrarte en la parte del trabajo que es realmente difícil: el criterio.

La mayoría de los equipos están en algún lugar entre el Nivel 0 y el Nivel 1. El objetivo de este capítulo es llevarte al Nivel 2 — o al menos mostrarte el camino.

== El Impuesto de la Ventana de Contexto

Cada token que pones en una ventana de contexto te cuesta dos veces: una en dinero, otra en atención.

La parte del dinero es sencilla. Las llamadas a la API se cobran por conteo de tokens. Vuelca todo tu código base en el contexto y estarás quemando dólares en cada interacción. Pero el coste más insidioso es la degradación de la atención. Los modelos de lenguaje no tratan todos los tokens por igual — hay un fenómeno bien documentado en el que la información en medio de un contexto largo recibe menos peso que la información al principio o al final. Cuanto más metes, más probable es que el modelo pase por alto lo que realmente importa.

Aprendí esto por las malas. Al principio, pensaba que más contexto siempre era mejor. Trabajando en una migración de base de datos complicada, alimenté al agente con cada archivo de migración que habíamos escrito — tres años de cambios de esquema, cientos de archivos. Mi razonamiento era sólido: el agente necesitaba entender el historial completo para escribir la siguiente migración correctamente. El resultado fue una migración que duplicó una columna que ya existía, porque la migración anterior relevante estaba enterrada en medio de un contexto enorme y el modelo efectivamente la perdió de vista.

En el siguiente intento, le di solo el esquema actual, las tres migraciones más recientes y un párrafo resumiendo el historial relevante. El agente lo clavó.

Este es el impuesto de la ventana de contexto en acción. Hay un punto óptimo entre demasiado poco y demasiado, y encontrarlo es una habilidad que se desarrolla con la práctica.

Demasiado poco contexto produce alucinaciones. El agente no tiene suficiente información, así que llena los vacíos con invenciones que suenan plausibles. Le pides que arregle una función sin mostrarle el archivo, e inventa una API que no existe. Le pides que escriba un test sin mostrarle tu framework de testing, y elige Jest cuando usas Vitest.

Demasiado contexto produce confusión y desperdicio. El agente tiene la respuesta enterrada en algún lugar de la pila, pero no puede encontrarla — o peor, encuentra información contradictoria en diferentes archivos y elige la equivocada. También estás pagando por cada token de ruido que incluiste.

El punto óptimo es contexto _curado_. No todo lo que el agente podría posiblemente necesitar, sino todo lo que realmente necesita para esta tarea específica, presentado con claridad. Piénsalo menos como llenar un archivador y más como informar a un colega antes de una reunión. No le darías todos los documentos que la empresa ha producido. Le darías las tres cosas que necesita leer y un resumen de un minuto del trasfondo.

Una heurística práctica: si estás a punto de pegar algo en el contexto, pregúntate — ¿tomará el agente una decisión diferente (mejor) por haber visto esto? Si la respuesta es no, déjalo fuera.

== Local, en Sandbox, Remoto: Moviendo Tus Agentes

El contexto no es solo texto en un prompt. Es sobre _dónde_ opera tu agente y a qué tiene acceso.

=== La Máquina Local

La configuración más simple: el agente se ejecuta en tu máquina, lee tus archivos, ejecuta tus comandos. Aquí es donde la mayoría empieza — herramientas como Claude Code operando directamente en el directorio de tu proyecto.

La ventaja es la inmediatez. El agente ve lo que tú ves. Puede leer tu código, ejecutar tus tests, consultar tu historial de git. El riesgo también es obvio: es tu máquina, tus credenciales, tu configuración de producción ahí mismo en `~/.env`.

=== Entornos en Sandbox

Un enfoque más disciplinado es dar al agente un sandbox — un contenedor, una VM, un worktree. Obtiene una copia del código pero no tus claves. Puede romper cosas sin romper _tus_ cosas.

Esto importa más de lo que la mayoría cree. Cuando dejas que un agente itere libremente — ejecutando código, instalando paquetes, modificando archivos — quieres que lo haga en un espacio donde un error sea barato. Un agente en sandbox es un agente sin miedo, y un agente sin miedo es uno productivo.

Los worktrees son una herramienta infravalorada aquí. Los worktrees de Git te permiten crear una copia aislada de tu repositorio en segundos. El agente trabaja en su propia rama, su propio directorio. Si el resultado es bueno, lo fusionas. Si no, eliminas el worktree y sigues adelante. Sin desorden.

=== Exploración Remota

Aquí es donde las cosas se ponen interesantes. Un ingeniero agéntico hábil no solo apunta agentes a archivos locales — enseña a los agentes a _explorar_ sistemas remotos.

SSH a un servidor de staging para examinar logs. Consultar una base de datos para entender la forma de los datos reales. Hacer curl a un endpoint de API para ver qué devuelve realmente, no lo que dice la documentación. Descargar logs de contenedores de un servicio en ejecución.

El agente se convierte en tu explorador. Lo apuntas a un sistema y dices: "ve a mirar y cuéntame lo que encuentres." Pero tienes que configurar esto. El agente necesita credenciales (con alcance limitado y temporales), acceso a la red y límites claros sobre lo que puede tocar.

Esta es una decisión de criterio — cuánto acceso dar, a qué sistemas, con qué barandillas. Demasiado poco y el agente es inútil. Demasiado y estás a un mal prompt de un incidente en producción. El ingeniero agéntico aprende a calibrar esto con el tiempo.

== Alimentando el Contexto Deliberadamente

Hay dos niveles para proporcionar contexto, y los mejores ingenieros agénticos invierten mucho en el primero para que rara vez necesiten el segundo.

=== Nivel 1: Infraestructura de Contexto

Lo de mayor apalancamiento que puedes hacer es darle a tu agente _herramientas_ para reunir contexto por sí mismo. Esta es una inversión duradera — la configuras una vez y cada sesión futura se beneficia.

*Da a los agentes acceso a tus herramientas.* El acceso al sistema de archivos y la ejecución de comandos son la base. Un agente que puede ejecutar `git log`, `git blame`, `grep` y tu suite de tests puede responder la mayoría de sus propias preguntas. Pero no te detengas ahí. Los servidores MCP pueden conectar agentes a sistemas externos — tu rastreador de errores (Sentry, Datadog), tu herramienta de gestión de proyectos (Linear, Jira), tu base de datos, tu pipeline de CI. Cada integración es una cosa menos que necesitas copiar y pegar manualmente, para siempre.

*Haz que la estructura de tu proyecto sea navegable.* Un proyecto bien organizado _es_ infraestructura de contexto. Nombres de archivo significativos, estructura de directorios clara, un buen README — estos ya no son solo para humanos. Tus agentes también los leen. Cuando el sistema de archivos es legible, un agente equipado con herramientas puede encontrar el archivo correcto sin que lo señales.

*Mantén archivos CLAUDE.md (o su equivalente).* Un archivo de contexto a nivel de proyecto que describe la arquitectura, las convenciones y las prioridades actuales es una de las formas más baratas y poderosas de infraestructura de contexto. Vive en el sistema de archivos, persiste entre sesiones y se lee automáticamente. Piénsalo como un documento de briefing que cada nueva sesión de agente recoge por sí sola.

*Limita el alcance de tus herramientas, no las elimines.* El instinto de restringir el acceso del agente es comprensible, pero restringir demasiado es tan costoso como permitir demasiado. En lugar de impedir el acceso a archivos, limita el alcance a los directorios relevantes. En lugar de bloquear la ejecución de comandos, incluye en la lista de permitidos los comandos que importan. Un agente con alcance bien definido es tanto seguro como capaz.

=== Nivel 2: Inyección Directa de Contexto

Las herramientas no pueden proporcionar todo. Tu modelo mental de por qué algo fue diseñado de cierta manera, restricciones que nunca se escribieron, conocimiento tribal sobre cómo funciona el equipo, experiencia de dominio sobre el negocio — esto es lo que _tú_ aportas. Aquí es donde copiar y pegar e instrucciones directas siguen importando.

*Empieza con el error — o deja que el agente lo encuentre.* Si tu agente tiene acceso a tu sistema de seguimiento de errores a través de MCP, deja que descargue él mismo la traza de Sentry o la alerta de Datadog. Si no, pega la traza de la pila, la salida del test que falla, la línea del log. El contexto en crudo supera al contexto parafraseado siempre — pero la mejor versión es que el agente acceda a la fuente en bruto directamente.

*Da intención, no solo detalles de implementación.* Un agente equipado con herramientas es sorprendentemente bueno para encontrar los archivos correctos. Lo que _no puede_ encontrar es tu intención. "Necesitamos arreglar el bug de codificación en el pipeline de facturación, y la corrección no debe cambiar el formato almacenado porque tres servicios downstream dependen de él" es el tipo de contexto que ninguna herramienta puede descubrir. Enfoca tu entrada manual en el _por qué_ y las _restricciones_, no en el _dónde_.

*Datos en bruto sobre paráfrasis — e idealmente, deja que el agente acceda a la fuente.* Este es el error más común que veo: ingenieros describiendo un error con sus propias palabras en lugar de proporcionar el error real. "El build está fallando con algún error de TypeScript sobre tipos" versus la salida exacta del compilador con ruta de archivo, número de línea y código de error. Lo primero le da al agente una dirección vaga. Lo segundo le da un objetivo específico. Pero la mejor versión es un agente que puede ejecutar el build por sí mismo y ver el error de primera mano.

*Usa git blame para explicar el _por qué_ — o deja que el agente lo ejecute.* El código le dice al agente _qué_ existe. El historial de Git le dice _por qué_. Cuando le pides a un agente que modifique código con un diseño no obvio, el mensaje de commit o pull request relevante le da la justificación que necesita. Si tu agente puede ejecutar `git blame` y `git log` por sí mismo, puede encontrar este historial. Lo que todavía necesita de ti es la _interpretación_: "Esta función parece rara pero se escribió así por una peculiaridad de la pasarela de pagos que no está documentada en ningún sitio — mira `abc123`."

*Poda agresivamente — limitando el alcance de las herramientas.* Si estás depurando un problema de renderizado, el agente no necesita ver tu middleware de autenticación. Con contexto manual, esto significa ser selectivo sobre lo que pegas. Con agentes equipados con herramientas, significa limitar el acceso a archivos o trabajar en un worktree enfocado. Cada archivo irrelevante en el contexto es ruido que degrada la señal, ya sea que llegó por pegar o por herramienta.

*Organiza tu contexto por capas.* Para tareas complejas, no vuelques todo de golpe. Empieza con la visión general — qué hace el sistema, qué intentas cambiar, por qué. Luego proporciona los archivos específicos. Luego proporciona el error o el fallo del test. Esto refleja cómo informarías a un colega humano, y funciona por la misma razón: construye un modelo mental antes de entrar en los detalles.

*Equipa, no alimentes con cuchara.* Cuando te pilles a punto de pegar un archivo en la ventana de contexto, pregúntate: ¿podría el agente haber encontrado esto por sí mismo si tuviera las herramientas adecuadas? Si la respuesta es sí, invierte el tiempo en configurar ese acceso en su lugar. Pegar es una solución puntual. Las herramientas son una mejora permanente. El objetivo es un agente que te necesite por tu criterio, no por tu portapapeles.

== Contexto Entre Sesiones

He aquí un problema del que nadie te advierte: las ventanas de contexto son efímeras. Cuando una sesión termina, todo lo que el agente aprendió — cada archivo que leyó, cada decisión que tomó, cada callejón sin salida que exploró — se desvanece. La siguiente sesión empieza desde cero.

Para tareas cortas, esto no importa. Pegas el error, el agente lo arregla, listo. Pero el trabajo de ingeniería real abarca días, a veces semanas. Una funcionalidad que toca doce archivos en tres servicios. Una refactorización que necesita hacerse por etapas. Una sesión de depuración donde las primeras dos horas acotan el problema y los últimos treinta minutos lo arreglan — excepto que tuviste que cerrar tu portátil entre medias.

Si no planificas los límites de sesión, desperdiciarás cantidades enormes de tiempo restableciendo contexto que el agente ya tenía. He visto a ingenieros pasar los primeros quince minutos de cada sesión re-explicando lo que le dijeron al agente ayer. Eso no es ingeniería. Es hacer de canguro.

La solución es hacer el contexto _duradero_ — almacenarlo en algún lugar donde la siguiente sesión pueda retomarlo.

*Deja que el código base sea la capa de continuidad.* La forma más fiable de contexto entre sesiones es el propio código. Si el agente progresó ayer, ese progreso debería estar commiteado. Los buenos mensajes de commit se convierten en el rastro de migas de pan: "Refactorizado pasarela de pagos para separar paso de codificación — siguiente paso es añadir tests para entrada no ASCII." La siguiente sesión empieza leyendo el log de git reciente, y el agente tiene una imagen clara de dónde están las cosas.

*Usa archivos CLAUDE.md (o su equivalente).* Muchas herramientas de agentes soportan un archivo de contexto a nivel de proyecto — un archivo markdown en la raíz de tu repositorio que describe la arquitectura del proyecto, las convenciones y el estado actual. Este archivo persiste entre sesiones porque vive en el sistema de archivos. Actualízalo a medida que el proyecto evoluciona. Incluye cosas como: cuáles son los componentes principales, qué patrones seguir, qué está roto actualmente, en qué está trabajando el equipo. Es un documento de briefing que cada nueva sesión lee automáticamente.

*Escribe resúmenes de sesión.* Cuando terminas una sesión compleja, dedica sesenta segundos a que el agente resuma lo que logró, lo que queda por hacer y lo que aprendió sobre el código base. Guarda ese resumen en algún lugar — un comentario en el ticket, una nota en el proyecto, incluso un archivo de texto en el repositorio. La siguiente sesión empieza leyendo ese resumen, y has preservado horas de comprensión acumulada en unos pocos párrafos.

*Haz commit temprano y a menudo.* Esto se cubre en el capítulo de Git, pero vale la pena repetirlo aquí porque es fundamentalmente una estrategia de gestión de contexto. Cada commit es un punto de control que las sesiones futuras pueden referenciar. Una sesión que termina con cambios sin commitear es una sesión cuyo contexto está atrapado en una ventana de terminal que puede que no exista mañana.

Los ingenieros que manejan bien el trabajo agéntico de larga duración son los que tratan los límites de sesión como una preocupación de primera clase. No simplemente cierran el portátil — cierran el ciclo.

== El Contexto Como Arquitectura

He aquí la idea más profunda: a medida que mejoras en la ingeniería agéntica, empiezas a diseñar tus sistemas _para_ el contexto. Escribes mensajes de commit más claros porque los agentes los leen. Mantienes las funciones pequeñas porque los agentes trabajan mejor con archivos enfocados. Mantienes la documentación actualizada porque los agentes la tratan como la fuente de verdad.

Este no es un ajuste menor. Cambia cómo piensas sobre la estructura del código a todos los niveles.

*Las funciones pequeñas son amigables con el contexto.* Una función de 400 líneas requiere que el agente mantenga todo en la memoria de trabajo para hacer un cambio de forma segura. Una función de 30 líneas que hace una sola cosa es algo que el agente puede entender completamente, modificar con confianza y verificar rápidamente. El viejo consejo — "una función debería hacer una sola cosa" — siempre fue buena ingeniería. Ahora también es buena gestión de contexto. Cada vez que extraes una función con un buen nombre de una más grande, estás creando una unidad de significado con la que un agente puede trabajar independientemente.

*Los nombres de archivo son navegación.* Cuando un agente necesita encontrar el código que maneja la autenticación de usuarios, empieza mirando los nombres de archivo. `auth.ts` es una señal. `utils.ts` es un agujero negro. `handleStuff.js` es un callejón sin salida. La disciplina de nombrar archivos claramente — `user-authentication.ts`, `payment-gateway.ts`, `rate-limiter.middleware.ts` — ya no es solo una cortesía para futuros desarrolladores. Es un índice que los agentes usan para orientarse en tu código base sin leer cada archivo.

*La estructura de directorios es documentación de arquitectura.* Un directorio plano con sesenta archivos no le dice nada al agente sobre cómo está organizado el sistema. Una jerarquía clara — `src/api/`, `src/services/`, `src/models/`, `src/middleware/` — se lo dice todo. El agente puede inferir la arquitectura solo de la estructura de carpetas, sin leer una sola línea de documentación. He visto agentes navegar un monorepo bien estructurado de 10.000 archivos más efectivamente que un proyecto mal estructurado de 200, puramente porque la disposición de directorios hacía el sistema legible.

*Monorepos vs. multirepos: un compromiso de contexto.* En un monorepo, el agente puede ver todo — la API, el frontend, las bibliotecas compartidas, la configuración de infraestructura. Esto es potente para tareas que cruzan límites. Pero también significa que el agente podría ver _demasiado_, incorporando código irrelevante de servicios no relacionados. En una configuración multirepo, cada repositorio tiene un alcance natural — el agente ve solo el servicio en el que está trabajando. Pero las tareas entre servicios se vuelven más difíciles porque el agente no puede referenciar fácilmente el otro lado de un contrato de API. Ningún enfoque es universalmente mejor. El punto es que tu estrategia de repositorios es una decisión de contexto, lo pienses así o no.

*Los tipos son contexto.* Un código base fuertemente tipado le da al agente algo que uno dinámicamente tipado no: una descripción legible por máquina del contrato de cada función. El agente puede mirar una firma de función y saber exactamente qué entra y qué sale, sin leer la implementación. TypeScript, Rust, Go — estos lenguajes llevan contexto estructural en sus sistemas de tipos. Python y JavaScript dejan al agente adivinando a menos que hayas escrito docstrings exhaustivos o type hints. Esto no es un argumento a favor de un lenguaje sobre otro. Es una observación de que los sistemas de tipos hacen doble función en la era agéntica: detectan bugs _y_ comunican intención.

*La documentación es la fuente de verdad (sea precisa o no).* Los agentes tratan tu README, tus docs de API, tus comentarios inline como autoritativos. Si tu documentación dice que la API devuelve un campo `user_id` pero la respuesta real devuelve `userId`, el agente escribirá código contra la documentación y producirá un bug. La documentación obsoleta siempre fue una molestia. Con los agentes, es una fuente activa de defectos. El listón de precisión de la documentación sube — no porque los agentes necesiten mejor documentación que los humanos, sino porque los agentes seguirán documentación mala más fielmente de lo que lo haría un humano.

La forma en que estructuras tu código, tus repositorios, tu infraestructura — todo se convierte en parte del contexto que proporcionas a tu tripulación. Los ingenieros que entienden esto temprano construirán sistemas que no solo son mantenibles por humanos, sino _navegables_ por agentes. Y con el tiempo, esa navegabilidad se acumula — cada nueva sesión de agente se beneficia de cada decisión estructural que tomaste antes.
