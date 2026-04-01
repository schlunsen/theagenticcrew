= Equipos Agénticos

#figure(
  image("../../assets/illustrations/ch16-crew.jpg", width: 80%),
)

El software siempre ha sido un deporte de equipo. Los agentes no cambian eso. Pero cambian la forma del equipo, el ritmo del trabajo y las habilidades que importan. Si lideras un equipo — o trabajas en uno — necesitas pensar en esto ahora, no después.

== El Multiplicador 10x Es Real, Pero Se Distribuye Diferente

Has escuchado la afirmación: los agentes hacen a los ingenieros 10x más productivos. No es incorrecta. Solo es engañosa.

Los agentes hacen ciertas tareas _dramáticamente_ más rápidas. Generar boilerplate, escribir scaffolding de tests, refactorizar a lo largo de cien archivos, migrar versiones de API, cablear endpoints CRUD — esto pasa de horas a minutos. La ganancia de velocidad es real y es masiva.

Pero otras tareas apenas cambian. El diseño de sistemas sigue requiriendo pensar. Depurar una condición de carrera sutil sigue requiriendo paciencia, intuición y comprensión profunda del runtime. Las conversaciones con stakeholders siguen llevando el tiempo que llevan. El agente no puede sentarse en tu revisión de arquitectura y hacer las preguntas correctas.

El multiplicador 10x no es un multiplicador plano a lo largo de tu día. Es un gráfico de picos. Algunas tareas van 50x más rápido. Algunas van 1x. Unas pocas podrían incluso ralentizarse si peleas con el agente en lugar de hacerlo tú mismo.

Los equipos que entienden esto despliegan agentes estratégicamente. No le pasan cada tarea a un agente esperando magia. Identifican las zonas de alto apalancamiento — las tareas donde los agentes genuinamente comprimen los plazos — y enfocan el esfuerzo de los agentes ahí. El resto sigue siendo humano.

== La Revisión de Código Cambia

Esto es lo que pasa cuando los agentes entran en el flujo de trabajo de un equipo: el volumen de PRs sube. _Mucho_. Un ingeniero que solía abrir dos PRs al día ahora abre cinco. El código en esos PRs es sintácticamente correcto, bien formateado y pasa los tests. Y revisarlo es _agotador_.

El viejo modelo de revisión de código — leer cada línea, buscar errores off-by-one, verificar el manejo de casos límite — no escala cuando la mitad del código fue generado en segundos. Quemarás a tus revisores en una semana.

El cambio es de "¿es esto correcto?" a "¿es este el enfoque correcto?" El código generado por agentes suele ser _localmente_ correcto. Hace lo que se pidió. La pregunta es si lo que se pidió era lo correcto. ¿Necesita existir este nuevo servicio, o debería vivir esta lógica en el existente? ¿Es este el límite de abstracción correcto? ¿Este cambio hace el sistema más simple o más complejo?

Los revisores se convierten en arquitectos. Hacen zoom out. Comprueban intención, no implementación.

Adaptaciones prácticas que funcionan:
- PRs más pequeños y enfocados — más fáciles tanto para agentes como para revisores
- Las comprobaciones automatizadas manejan lo mecánico (linting, cobertura de tests, comprobación de tipos)
- El tiempo de revisión se protege en el calendario, no se exprime entre reuniones
- Los equipos acuerdan "patrones de confianza" — si un PR sigue un patrón conocido y pasa CI, obtiene una vía de revisión más rápida

La fatiga de revisión es el asesino silencioso de los equipos asistidos por agentes. Tómalo en serio.

== La Pregunta del Ingeniero Junior

Este es el problema más difícil de este capítulo, y no tengo una respuesta limpia.

Los ingenieros junior tradicionalmente han aprendido haciendo el trabajo que los agentes ahora hacen más rápido y mejor. Escribir ese primer endpoint CRUD. Luchar con un layout CSS complicado. Descubrir por qué el test está fallando. Estas tareas eran tediosas para los seniors pero _formativas_ para los juniors. La lucha era la educación.

Si los agentes manejan todo eso, ¿dónde ocurre el aprendizaje?

El peor resultado son juniors que se vuelven dependientes de los prompts — pueden hacer que un agente genere código, pero no pueden explicar qué hace el código ni depurarlo cuando se rompe. Se saltan la fase de comprensión completamente. Eso no es ingeniería; es un flujo de trabajo de copiar y pegar muy caro.

El mejor camino es usar agentes como _tutores_, no como reemplazos. Un junior escribiendo una migración de base de datos debería pedirle al agente que le _explique_ la migración, no que simplemente la genere. "¿Por qué usaste una transacción aquí?" "¿Qué pasa si esto falla a mitad?" "Muéstrame cómo se ve esto sin el ORM." El agente se convierte en un profesor paciente con tiempo infinito — algo que la mayoría de los seniors no pueden ofrecer.

El pair programming con agentes, _supervisado por seniors_, es el modelo más prometedor que he visto. El junior dirige al agente. El senior observa, hace preguntas e interviene cuando el junior acepta algo que no entiende. Es más lento que dejar que el agente haga todo, pero produce ingenieros que realmente saben lo que están haciendo.

Los equipos que se saltan esta inversión están tomando prestado del futuro. Los juniors sin supervisión de hoy son los seniors de mañana que no pueden depurar producción sin una muleta de IA.

== Distribución del Conocimiento

Aquí hay un patrón que aparece en cada equipo que adopta agentes de forma desigual: un ingeniero se vuelve fluido con los agentes, empieza a entregar a 3x la velocidad de los demás, y en pocos meses ha tocado cada parte del código base. Se convierten en el punto único de fallo.

El factor bus cae a uno. No porque nadie lo planificara, sino porque la velocidad y la concentración de conocimiento están correlacionadas. El ingeniero que más entrega aprende más. Los demás se quedan atrás, no solo en producción sino en _comprensión_ del sistema que colectivamente poseen.

Este es un problema de gestión, no de tecnología. La solución es estructural:

- *Archivos `CLAUDE.md` compartidos.* Cada proyecto tiene uno. Todos contribuyen a él. Codifica el conocimiento colectivo del equipo, no el de una persona.
- *Flujos de trabajo y convenciones compartidos.* El equipo acuerda cómo usan agentes — qué herramientas, qué patrones, qué barandillas. Sin configuraciones de lobo solitario.
- *Rotación.* Los ingenieros fluidos con agentes rotan a diferentes partes del código base. El conocimiento se propaga a través del trabajo, no de la documentación.
- *Compartir sesiones de agente.* Algunos equipos han empezado a compartir sesiones de agente interesantes — los prompts, las salidas, las decisiones. Es una forma de transferencia de conocimiento que no existía antes.

El objetivo no es ralentizar a tu ingeniero más rápido. Es asegurarte de que el conocimiento del equipo se mantiene al ritmo de la producción del equipo.

== Las Convenciones Compartidas Importan Más

Cubrimos las convenciones en un capítulo anterior. En el contexto de equipo, las implicaciones son mayores.

Cuando un ingeniero solo usa agentes, sus convenciones afectan a una persona. Cuando un equipo usa agentes, las convenciones afectan _cada sesión de agente en todo el equipo_. Un proyecto bien estructurado con nombres claros, patrones consistentes y un `CLAUDE.md` mantenido significa que los agentes de cada ingeniero empiezan desde una base sólida.

Un proyecto desordenado significa que cada agente reinventa la rueda. Diferentes ingenieros obtienen salidas diferentes. El código base se desvía. Las revisiones se vuelven más difíciles porque ahora estás revisando no solo el código sino el _estilo_ del código, que varía según qué agente de qué ingeniero lo escribió.

Los estándares de código en un equipo agéntico no se tratan de estética. Se tratan de _efectividad del agente_. El equipo que acuerda la estructura del proyecto, convenciones de nombres, patrones de testing y formato de documentación obtiene mejor salida de cada sesión de agente. Es un multiplicador de fuerza sobre un multiplicador de fuerza.

Invierte el tiempo. Escribe los estándares. Imponlos en CI. Se devuelve con cada PR.

== El Nuevo Standup

¿Cómo se ve la coordinación diaria cuando cada ingeniero está ejecutando múltiples sesiones de agentes en paralelo?

El viejo standup: "Ayer trabajé en la refactorización de autenticación. Hoy seguiré. Sin bloqueos."

El nuevo standup: "Tengo tres agentes ejecutándose. La refactorización de autenticación se entregó y está en revisión. La migración de API está al 80% — el agente se quedó atascado en el parseo de XML legacy, así que estoy tomando el control manualmente. Acabo de lanzar una tercera sesión para generar tests de integración para el módulo de facturación."

La granularidad cambia. El trabajo se mueve más rápido, así que la coordinación necesita mantenerse al día. Un ingeniero podría _empezar y terminar_ una tarea entre standups. La sincronización diaria pasa de ser actualizaciones de progreso a alineación de intención — asegurarse de que tres ingenieros no están todos enviando agentes al mismo problema desde diferentes ángulos.

Algunos equipos se están moviendo a standups asíncronos con check-ins más frecuentes. Otros usan dashboards compartidos que rastrean sesiones de agentes activas. La respuesta correcta depende del equipo, pero el viejo ritmo de "una actualización por persona por día" a menudo no es suficiente.

== Cumplimiento y la Pista de Auditoría

Si un agente escribe código que causa un incidente en producción, ¿quién es responsable? ¿El ingeniero que hizo el prompt? ¿El revisor que aprobó el PR? ¿El líder del equipo que decidió adoptar flujos de trabajo agénticos? Esta no es una pregunta filosófica que debatas con unas cervezas. Es una pregunta legal y de cumplimiento, y las industrias reguladas necesitan respuestas claras _antes_ de que ocurra el incidente, no durante el postmortem.

La buena noticia es que la respuesta no es realmente tan complicada. El tooling y los procesos ya existen. Solo necesitas ser explícito sobre ellos.

*Git es tu pista de auditoría.* Cada commit generado por agente debería ser atribuible. El mensaje de commit debería indicar que fue asistido por agente — un tag `Co-Authored-By`, un prefijo, cualquier convención que adopte tu equipo. El PR debería mostrar quién lo revisó. La aprobación del merge es la firma. Así es como ya trabajan la mayoría de los equipos; la clave es hacerlo _consistente_. Atribución ad-hoc — a veces etiquetando, a veces no — es peor que no tener sistema, porque crea la impresión de un proceso sin la fiabilidad de uno.

*El revisor es responsable.* La respuesta práctica para la mayoría de las organizaciones es directa: el ingeniero que revisa y aprueba el PR asume la responsabilidad, igual que lo haría con cualquier código de cualquier fuente. El código generado por agentes no tiene un estándar de responsabilidad diferente. Si apruebas un PR, estás diciendo "he revisado esto y creo que es correcto." La herramienta que generó el código es irrelevante para esa declaración. Esto también significa que las revisiones de código generado por agentes necesitan ser revisiones _reales_, no sellos de goma. Si el volumen de PRs generados por agentes está haciendo imposible una revisión exhaustiva, eso es un problema de flujo de trabajo que resolver, no un estándar que bajar.

*Para industrias reguladas.* Documenta tu flujo de trabajo agéntico como parte de tu documentación del SDLC. Qué modelos se usan, qué versión, qué barandillas están en su lugar, qué proceso de revisión sigue el código generado por agentes antes de llegar a producción. Los auditores quieren ver un _proceso_, no perfección. Un proceso documentado que incluye "generación de código asistida por IA con revisión humana obligatoria y verificación CI" es auditable. Un proceso no documentado donde los ingenieros usan las herramientas que quieran sin enfoque consistente no lo es. Si estás en fintech, salud o cualquier cosa con supervisión regulatoria, documenta esto antes de que alguien lo pida.

*Guarda logs de sesiones.* Retén logs de sesiones de agente, especialmente para código que toca sistemas sensibles — facturación, autenticación, manejo de datos, cualquier cosa con implicaciones regulatorias. No porque los leas rutinariamente, sino porque podrías necesitarlos durante una revisión de incidente. "¿Qué vio el agente cuando generó este código? ¿Qué prompt produjo esta salida? ¿Con qué contexto trabajaba?" Son preguntas que quieres poder responder seis meses después. La mayoría de las herramientas agénticas pueden exportar o registrar sesiones. Configura la retención antes de necesitarla. El coste de almacenamiento es trivial comparado con el coste de no tener los logs cuando cumplimiento venga a llamar.

== La Contratación Cambia

Si los agentes manejan las partes mecánicas de la codificación, ¿qué necesitas realmente de un ingeniero?

La velocidad bruta de codificación importa menos. El ingeniero que podía escribir un binary search perfecto en una pizarra en tres minutos tiene una habilidad que los agentes han convertido en commodity. Eso no es inútil — entender algoritmos sigue importando — pero ya no es el diferenciador.

Lo que importa más:

- *Diseño de sistemas.* La capacidad de descomponer un problema en componentes, definir interfaces y razonar sobre compromisos. Los agentes pueden implementar un diseño. No pueden decirte qué diseño es correcto para tus restricciones.
- *Criterio.* Saber cuándo usar el agente y cuándo pensar. Saber cuándo la salida del agente está equivocada aunque parezca correcta. Saber qué esquinas recortar y cuáles proteger.
- *Comunicación.* La capacidad de articular intención con claridad — a agentes, a compañeros de equipo, a stakeholders. Los pensadores vagos obtienen salida vaga del agente. Los pensadores precisos obtienen resultados precisos.
- *Descomposición de problemas.* Dividir una tarea grande en piezas del tamaño de un agente es una habilidad. Está relacionada con el diseño de sistemas pero es más táctica. El ingeniero que puede convertir un Jira epic en diez prompts de agente bien acotados superará al que pega el epic entero en una ventana de chat.

La entrevista que pregunta "implementa este algoritmo en una pizarra" está evaluando una habilidad que importa menos cada año. La entrevista que pregunta "aquí tienes un sistema con estas restricciones — explícame cómo lo construirías, qué compromisos harías, y cómo verificarías que funciona" está evaluando las habilidades que importan _más_ cada año.

Contrata por criterio. Siempre puedes darles un agente para el resto.
