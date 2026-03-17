= Contexto

El mes pasado, llegó un bug de un cliente: los pagos estaban fallando silenciosamente para usuarios con caracteres no ASCII en su dirección de facturación. Uno complicado — del tipo que vive en la costura entre la validación de tu frontend y la codificación de caracteres de tu pasarela de pagos.

Un ingeniero de mi equipo cogió el ticket primero. Abrió su agente y escribió: "Hay un bug con los pagos para usuarios internacionales. ¿Puedes investigarlo?" El agente leyó alegremente el módulo de pagos, hizo algunas suposiciones plausibles sobre el manejo de Unicode y produjo un parche que normalizaba toda la entrada a ASCII. Habría eliminado cada acento, cada diéresis, cada carácter fuera del alfabeto inglés de la dirección de facturación de cada usuario. Una corrección técnicamente peor que el bug.

Una hora después, una segunda ingeniera tomó el mismo ticket después de que el primer intento fue rechazado en la revisión. Ella pegó el log de error del cliente, la traza de Sentry que fallaba, el código de respuesta específico de la pasarela de pagos, la sección relevante de la documentación de codificación de caracteres de la pasarela, y los tres archivos involucrados en el pipeline de facturación. Su agente diagnosticó el problema en menos de dos minutos: una cadena UTF-8 se estaba pasando a través de una función que asumía codificación Latin-1 antes de llegar a la API de la pasarela. La corrección fueron cuatro líneas. Se desplegó esa tarde.

El modelo era el mismo. El agente era el mismo. El bug era el mismo. Lo que difería era lo que cada ingeniero puso delante del agente antes de pedirle que trabajara. Uno le dio una descripción vaga y lo dejó adivinar. La otra le dio todo lo que necesitaba para _ver_ el problema.

Esa diferencia — lo que el agente puede ver — es de lo que trata este capítulo.

La habilidad más importante en la ingeniería agéntica no es el prompting. Es la gestión del contexto.

Un agente de IA es tan bueno como lo que puede ver. Dale una instrucción vaga y una pizarra en blanco, y alucinará con confianza. Dale los archivos correctos, las restricciones correctas, la vista correcta del sistema — y hará cosas que parecen magia. La diferencia no es el modelo. Eres tú.

La ingeniería tradicional también tenía una versión de esto. Un ingeniero senior no solo escribía mejor código — mantenía más del sistema en su cabeza. Sabía qué archivos importaban, dónde vivían los dragones, qué abstracciones eran estructurales y cuáles eran decorativas. Ese modelo mental era el contexto, y vivía enteramente en el cerebro del ingeniero.

Ahora tienes que _externalizarlo_. Tus agentes no pueden leer tu mente. Leen archivos, variables de entorno, logs de errores y lo que pongas delante de ellos. El oficio de la ingeniería agéntica es aprender qué sacar a la superficie, cuándo y cómo.

== La Ventana de Contexto Es Tu Banco de Trabajo

Piensa en la ventana de contexto como un banco de trabajo físico. Tiene espacio limitado. No puedes volcar todo tu código base encima y esperar buenos resultados. En su lugar, colocas las piezas que importan para _esta_ tarea: los archivos de código relevantes, el test que falla, el esquema, quizá un fragmento de documentación.

Un buen ingeniero agéntico cura el contexto como un buen cirujano dispone los instrumentos. Nada innecesario. Todo al alcance.

Esto significa desarrollar instintos para preguntas como:
- ¿Qué necesita ver el agente para entender esta tarea?
- ¿Qué lo confundirá si lo incluyo?
- ¿El contexto que estoy proporcionando es _actual_, o le estoy dando información obsoleta?

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

Los mejores ingenieros agénticos desarrollan hábitos alrededor del contexto:

*Empieza con el error.* No describas el bug — muestra al agente la traza de la pila, la salida del test que falla, la línea del log. El contexto en crudo supera al contexto parafraseado siempre.

*Muestra, no cuentes.* En lugar de explicar tu esquema de base de datos en prosa, dale al agente los archivos de migración o los modelos del ORM. En lugar de describir el contrato de la API, dale la especificación OpenAPI o una respuesta de curl.

*Poda agresivamente.* Si estás depurando un problema de renderizado, el agente no necesita ver tu middleware de autenticación. Cada archivo irrelevante en el contexto es ruido que degrada la señal.

*Usa el sistema de archivos como contexto.* Un proyecto bien organizado _es_ contexto. Nombres de archivo significativos, estructura de directorios clara, un buen README — estos ya no son solo para humanos. Tus agentes también los leen.

*Da rutas de archivos, no búsquedas del tesoro.* Cuando sabes qué archivos son relevantes, dilo explícitamente. "El bug está en `src/payments/gateway.ts`, específicamente en la función `encodeAddress` en la línea 142" es infinitamente mejor que "hay un bug en algún lugar del código de pagos." Cada minuto que el agente pasa buscando el archivo correcto es un minuto que no está dedicando al problema real — y está quemando tokens todo el rato.

*Usa git blame para explicar el _por qué_.* El código le dice al agente _qué_ existe. El historial de Git le dice _por qué_. Cuando le pides a un agente que modifique un fragmento de código con un diseño no obvio, apúntalo al mensaje de commit relevante o al pull request. "Esta función parece rara pero se escribió así por el issue #1247 — mira el mensaje de commit en `abc123`" le da al agente la justificación que necesita para hacer cambios sin romper la intención original.

*Copia y pega en lugar de parafrasear.* Vale la pena repetir esto porque es el error más común que veo. Los ingenieros describen un error con sus propias palabras en lugar de pegar el error real. "El build está fallando con algún error de TypeScript sobre tipos" versus pegar la salida exacta del compilador con ruta de archivo, número de línea y código de error. Lo primero le da al agente una dirección vaga. Lo segundo le da un objetivo específico. Siempre pega la salida en crudo. Deja que el agente haga la interpretación.

*Organiza tu contexto por capas.* Para tareas complejas, no vuelques todo de golpe. Empieza con la visión general — qué hace el sistema, qué intentas cambiar, por qué. Luego proporciona los archivos específicos. Luego proporciona el error o el fallo del test. Esto refleja cómo informarías a un colega humano, y funciona por la misma razón: construye un modelo mental antes de entrar en los detalles.

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
