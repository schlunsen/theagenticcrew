= Orquestación Multi-Agente

#figure(
  image("../../assets/illustrations/ch12-orchestration.jpg", width: 80%),
)

Un agente es poderoso. Múltiples agentes trabajando juntos es algo completamente diferente.

Piénsalo así. Un solo carpintero puede construir un cobertizo. Pero ¿una casa? Necesitas un electricista, un fontanero, un techador — especialistas trabajando en paralelo, cada uno enfocado en lo que mejor sabe hacer, coordinándose lo justo para no estorbarse. La casa se levanta más rápido y el trabajo es mejor que el de una sola persona intentando hacerlo todo.

La ingeniería agéntica funciona de la misma forma. Un solo agente en una tarea compleja la recorrerá secuencialmente — planificar, implementar, testear, depurar, iterar. Funciona, pero es lento. Tres agentes, cada uno manejando una pieza bien acotada del problema, pueden terminar en un tercio del tiempo. A veces menos, porque los agentes enfocados cometen menos errores que un agente malabarizando demasiadas preocupaciones.

Pero hay una trampa. Los agentes en paralelo requieren _coordinación_. Y la coordinación tiene un coste. Este capítulo trata sobre cuándo pagar ese coste, y cómo pagarlo bien.

== Estrategias de Descomposición

La parte más difícil del trabajo multi-agente no es ejecutar múltiples agentes. Es decidir cómo dividir el trabajo.

La regla de oro: las tareas deben tener _mínimo acoplamiento_. Si el trabajo del agente A depende de la salida del agente B, no pueden ejecutarse en paralelo — son secuenciales, y deberías tratarlos como tal. El arte está en encontrar las costuras en tu trabajo donde puedes cortar limpiamente.

Hay tres patrones de descomposición fiables.

*Por capa.* Un agente maneja la API del backend, otro construye el componente de frontend, un tercero escribe los tests. Esto funciona bien porque las capas tienen límites naturales — una interfaz definida entre ellas. Mientras acuerdes el contrato de API por adelantado, cada agente puede trabajar independientemente.

*Por funcionalidad.* Si estás construyendo tres funcionalidades independientes, dale cada una a un agente separado. Esta es la descomposición más simple. Las funcionalidades tocan archivos diferentes, directorios diferentes, preocupaciones diferentes. Los conflictos de merge son raros.

*Por preocupación.* Un agente refactoriza, otro escribe tests para el código refactorizado, un tercero actualiza la documentación. Este es un patrón secuencial — más pipeline que paralelo — pero permite que cada agente se enfoque en un solo tipo de pensamiento. El agente de refactorización no tiene que cambiar de contexto al modo de escritura de tests. Solo refactoriza y traspasa.

La descomposición que elijas depende de la forma del trabajo. Pero el principio es constante: _encuentra las costuras, corta a lo largo de ellas, minimiza la superficie donde los agentes necesitan ponerse de acuerdo_.

== Rama-por-Agente

Cada agente tiene su propia rama. Cubrimos esto en el capítulo de Git. En el trabajo multi-agente, se vuelve absolutamente esencial.

Pero las ramas solas no son suficientes. Dos agentes en ramas diferentes compartiendo el mismo directorio de trabajo pelearán por el sistema de archivos — sobrescribirán los archivos del otro, corromperán los builds del otro, romperán las ejecuciones de tests del otro. Necesitas _worktrees_.

Cada agente tiene su propio worktree de git: un directorio separado, en su propia rama, con su propia copia del código base. Los agentes comparten historial pero nada más. Pueden compilar, ejecutar tests, instalar dependencias y hacer un desastre — todo sin afectarse mutuamente.

La configuración es rápida:

```bash
git worktree add ../project-api agent/api-endpoint
git worktree add ../project-frontend agent/frontend-component
git worktree add ../project-tests agent/integration-tests
```

Tres directorios. Tres ramas. Tres agentes. Aislamiento completo. Este es el modelo de sandbox de los capítulos anteriores hecho concreto para el trabajo multi-agente. Cuando un agente termina, revisas su rama, fusionas si es buena, y eliminas el worktree. Si el trabajo es malo, tiras todo. Coste cero.

== El Patrón de Traspaso

No todo el trabajo multi-agente es paralelo. A veces los agentes trabajan _secuencialmente_, cada uno construyendo sobre el anterior. El agente A planifica. El agente B implementa. El agente C revisa.

Este es el patrón de traspaso, y es poderoso — pero solo si el traspaso en sí es limpio.

El problema con los agentes secuenciales es la pérdida de contexto. El agente A tiene una comprensión rica del problema para cuando termina de planificar. El agente B empieza en frío. Si solo le dices al agente B "implementa el plan," va a perder matices. Hará suposiciones diferentes. Resolverá un problema ligeramente diferente del que el agente A planificó.

La solución es _traspaso estructurado_. El agente A no solo planifica — produce un artefacto que captura su razonamiento. Esto puede tomar varias formas:

- *Un documento resumen.* Un archivo markdown dejado en el repositorio: `PLAN.md`. Describe qué necesita pasar, qué compromisos se consideraron, qué se rechazó y por qué. El agente B lee esto antes de escribir una línea de código.
- *Un conjunto de archivos.* El agente A crea archivos stub — funciones vacías con docstrings, definiciones de interfaces, firmas de tipos. El agente B los rellena. Los stubs _son_ el traspaso.
- *Un prompt estructurado.* La salida del agente A se convierte en la entrada del agente B, formateada como una descripción detallada de tarea con criterios de aceptación. Lo pegas directamente en el contexto del agente B.

La clave es que el traspaso debe ser _explícito y completo_. Sin suposiciones implícitas. Sin "el siguiente agente lo descubrirá." Cada decisión, cada restricción, cada caso límite — escrito.

Esto requiere disciplina. Pero es la misma disciplina que aplicarías al escribir un ticket para un colega humano en un continente diferente y una zona horaria diferente. Si no confiarías en un traspaso verbal, no confíes en uno implícito entre agentes.

== El Problema del Merge

Aquí es donde el trabajo multi-agente se pone genuinamente difícil.

Tres agentes trabajaron en paralelo. Cada uno produjo una rama limpia y testeada. Ahora necesitas fusionarlas todas en main. A veces esto es indoloro — tres ramas tocando archivos completamente diferentes se fusionan sin un solo conflicto. Hermoso.

A veces no. El agente A cambió el esquema de base de datos. El agente B añadió una migración que asume el esquema antiguo. El agente C actualizó el handler de API que tanto A como B también tocaron. Ahora tienes un conflicto triple y ningún agente tiene la imagen completa.

Hay tres estrategias para lidiar con esto.

*Prevención.* Los mejores conflictos de merge son los que nunca suceden. Cuando descompongas el trabajo, piensa en la propiedad de archivos. Asigna diferentes directorios, diferentes módulos, diferentes archivos a diferentes agentes. Si los agentes nunca tocan el mismo archivo, nunca pueden entrar en conflicto. Esta es la estrategia más barata y deberías usarla siempre que sea posible.

*El agente de merge.* Cuando los conflictos surgen, levanta un nuevo agente cuyo único trabajo es fusionar. Dale las ramas, los conflictos y el contexto del trabajo de cada agente. Un buen agente de merge puede resolver la mayoría de los conflictos automáticamente — lee ambos lados, entiende la intención y produce un resultado coherente. Es como un ingeniero senior que se sienta con dos PRs y descubre cómo encajan juntos.

*Revisión humana.* A veces el conflicto es semántico, no sintáctico. El código se fusiona limpiamente pero la _lógica_ se contradice. Dos agentes tomaron decisiones de diseño incompatibles. Ningún merge automatizado detectará esto. Aquí es donde te ganas tu sueldo como ingeniero. Revisa las ramas antes de fusionar. Lee los diffs uno al lado del otro. Asegúrate de que las piezas realmente encajan.

En la práctica, usarás las tres. Previene lo que puedas. Automatiza el resto. Revisa todo.

== Overhead de Orquestación

Más agentes no siempre es mejor.

Cada agente adicional añade coste de coordinación. Tienes que descomponer el trabajo. Configurar worktrees. Definir interfaces. Manejar merges. Revisar múltiples ramas en lugar de una. Para una tarea que le lleva a un solo agente treinta minutos, levantar tres agentes podría llevar cuarenta y cinco — veinte minutos de trabajo de agentes en paralelo más veinticinco minutos de tu tiempo orquestando.

El punto de equilibrio es más alto de lo que crees. En mi experiencia, la orquestación multi-agente empieza a rendir cuando la tarea total le llevaría a un solo agente _al menos dos horas_. Por debajo de eso, el overhead se come las ganancias.

También hay otros costes. El contexto se fragmenta. Cada agente ve solo su pieza. Ningún agente entiende todo el sistema como lo haría uno solo trabajando. Esto puede llevar a inconsistencias — diferentes convenciones de nomenclatura, diferentes patrones de manejo de errores, diferentes suposiciones sobre estado compartido.

La habilidad no es ejecutar tantos agentes como sea posible. La habilidad es saber _cuándo_ paralelizar y cuándo un solo agente enfocado es la herramienta adecuada. Una tripulación de cinco no siempre es más rápida que un marinero experimentado que conoce el barco.

== Un Ejemplo Práctico

Hagámoslo concreto. Estás construyendo una aplicación web y necesitas añadir una nueva funcionalidad: notificaciones de usuario. Los usuarios deberían ver un icono de campana con un contador, hacer clic para ver una lista y marcar notificaciones como leídas. Necesitas una API, un componente de frontend y tests.

Este es un caso de libro para tres agentes en paralelo.

*Paso 1: Define la interfaz.* Antes de levantar ningún agente, pasas cinco minutos escribiendo el contrato de API. `GET /api/notifications` devuelve una lista. `PATCH /api/notifications/:id` marca una como leída. El objeto de notificación tiene `id`, `message`, `read`, `created_at`. Escribe esto en un documento compartido o un archivo stub. Este es el contrato contra el que trabajan los tres agentes.

*Paso 2: Crea los worktrees.*

```bash
git worktree add ../app-api agent/notifications-api
git worktree add ../app-frontend agent/notifications-frontend
git worktree add ../app-tests agent/notifications-tests
```

*Paso 3: Lanza los agentes.* Cada agente recibe una tarea clara y acotada:

- Agente 1: "Implementa los endpoints de API de notificaciones en `../app-api`. Sigue el contrato en `API_CONTRACT.md`. Incluye modelo, ruta y controlador. Escribe tests unitarios para el controlador."
- Agente 2: "Construye el componente UI de notificaciones en `../app-frontend`. Llama a `GET /api/notifications` y `PATCH /api/notifications/:id`. Muestra un icono de campana con contador de no leídas. Al hacer clic abre una lista desplegable."
- Agente 3: "Escribe tests de integración en `../app-tests`. Cubre el flujo completo: crear una notificación, obtener la lista, marcar como leída, verificar que el contador se actualiza."

*Paso 4: Déjalos trabajar.* Los tres agentes se ejecutan simultáneamente. Cada uno hace commits en su propia rama. Monitorizas el progreso pero no intervienes a menos que algo salga mal.

*Paso 5: Revisa y fusiona.* Cuando los tres terminan, revisas cada rama. La rama de API se fusiona primero — es la base. Luego la rama de frontend. Luego los tests. Ejecutas la suite completa de tests después de cada merge para detectar problemas de integración temprano.

Tiempo total: quizá cuarenta minutos. El agente de API tardó treinta, el agente de frontend tardó veinticinco, y el agente de tests tardó treinta y cinco. Pero se ejecutaron en paralelo, así que el tiempo de reloj fue treinta y cinco minutos más diez minutos de tu trabajo de orquestación.

¿Un solo agente haciendo todo secuencialmente? Probablemente noventa minutos.

Las matemáticas funcionan cuando la tarea es lo suficientemente grande. Y a medida que mejoras en la descomposición, desarrollarás intuición para qué tareas vale la pena dividir y cuáles no. Como la mayoría de las cosas en ingeniería, es una cuestión de criterio. Pero ahora tienes las herramientas para tomarlo.

Una cosa más que vale la pena señalar: no siempre tienes que orquestar manualmente. Como discutimos en el capítulo de prompting, puedes _decirle_ al agente que paralelice. "Estos tres módulos son independientes — lanza sub-agentes y trabaja en ellos simultáneamente." El agente se encarga de los worktrees, el branching y la coordinación. Tu trabajo es la parte que el agente no puede hacer: saber qué piezas es seguro ejecutar en paralelo. Ese criterio arquitectónico es el prompt de mayor apalancamiento que puedes escribir.
