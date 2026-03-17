= Introducción

El año pasado vi a una desarrolladora junior de mi equipo — dos años de experiencia, todavía nerviosa en las revisiones de código — entregar un endpoint de API completo en cuarenta y cinco minutos. Modelo de datos, validación, manejo de errores, tests, documentación. El código era limpio. Los tests eran exhaustivos. El PR pasó la revisión al primer intento.

A mí me habría llevado una hora hacer el mismo trabajo. Y llevo veinte años en esto.

Ella no tecleó la mayor parte. Describió lo que necesitaba, apuntó un agente al código base y lo guió hasta la línea de meta. Su habilidad no estaba en escribir el código — estaba en saber qué pedir, reconocer cuándo el resultado era bueno y detectar el único caso límite que el agente pasó por alto. Estaba haciendo _ingeniería_. Solo que no de la forma en que yo aprendí a hacerla.

Esa noche volví a casa y me senté con una pregunta incómoda: si la brecha entre veinte años de experiencia y dos años de experiencia acaba de estrecharse considerablemente, ¿qué aporto yo exactamente?

La respuesta, al final me di cuenta, es todo lo que no es teclear. Pero llegar a esa respuesta me llevó meses, muchos errores y este libro.

== El Suelo Se Mueve

Durante veinte años, ser ingeniero de software significaba una cosa: abres un editor, escribes código, lo despliegas. Las herramientas cambiaban — de Vim a VS Code, de SVN a Git, de bare metal a Kubernetes — pero el bucle fundamental seguía siendo el mismo. Tú, un teclado y un problema.

Ese bucle se está rompiendo. Y se está rompiendo rápido.

Los agentes de IA no se limitan a autocompletar tu código. Leen todo tu código base, razonan sobre la arquitectura, hacen cambios en docenas de archivos, ejecutan tus tests e iteran sobre los fallos — todo sin que toques el teclado. No están reemplazando el editor. Están reemplazando el _flujo de trabajo_. El ingeniero que solía pasar el 80% de su tiempo tecleando ahora pasa el 80% de su tiempo pensando, revisando y dirigiendo.

Algunos ingenieros están prosperando con este cambio. Entregan más, con mayor calidad, y te dirán que disfrutan de su trabajo más que en años. Otros están frustrados, escépticos o silenciosamente aterrados de que el oficio que pasaron una década dominando se esté evaporando bajo sus pies.

Ambas reacciones son racionales. La verdad está en algún lugar del incómodo punto medio.

== Por Qué Este Libro

Porque nadie nos dio un manual.

Las herramientas aparecieron rápido — Copilot, luego Claude, luego agentes que pueden ejecutar tareas de extremo a extremo de forma autónoma — y todos estamos descubriéndolo sobre la marcha. Busqué el libro que me dijera cómo trabajar realmente con estas cosas. No el discurso de marketing. No el artículo académico. No el hilo de Twitter de alguien que lo probó durante veinte minutos. Quería la guía honesta de ingeniería — escrita por alguien que despliega código en producción y ha visto a los agentes hacer cosas brillantes y cosas catastróficamente estúpidas a partes iguales.

Ese libro no existía. Así que lo escribí.

Lo escribí porque yo también estaba perdido. Era el ingeniero senior que no podía entender por qué el agente seguía reescribiendo toda mi biblioteca de componentes cuando le pedía que arreglara el color de un botón. Era el tipo que quemó 500.000 tokens en una tarea que debería haber llevado diez minutos, porque no sabía cómo poner límites. Cometí todos los errores de este libro antes de aprender a evitarlos.

Esta es la guía que me habría gustado que alguien me diera.

== Para Quién Es

Eres ingeniero de software. Has entregado cosas reales. Sabes lo que se siente un incidente en producción a las 2 de la madrugada. No le tienes miedo al terminal.

Pero últimamente algo se siente diferente. Quizá has probado herramientas de codificación con IA y las has encontrado impresionantes pero caóticas — como hacer pair programming con alguien que es increíblemente rápido pero no tiene concepto de alcance. Quizá has visto a un desarrollador con dos años de experiencia entregar una funcionalidad completa en una tarde usando asistencia de agentes, y te hizo sentir algo que no esperabas. Quizá estás entusiasmado pero no sabes por dónde empezar. Quizá eres escéptico y quieres que alguien te convenza con sustancia, no con bombo publicitario.

Este libro es para ti. Asume que sabes programar. Asume que llevas tiempo en esto. Te encuentra donde estás.

== Cómo Leer Este Libro

Esto no es un manual de referencia. Es un viaje, y está estructurado como tal.

Empezamos entendiendo qué está cambiando realmente y por qué — el cambio en cómo se construye el software, no solo las herramientas sino el _pensamiento_. Luego entramos en qué son realmente los agentes, despojados del lenguaje de marketing, para que tengas un modelo mental que se sostenga cuando las herramientas cambien el próximo trimestre.

A partir de ahí, nos ensuciamos las manos. Aprenderás cómo funcionan los agentes en el terminal, cómo establecer barandillas para que no destrocen tu código base, cómo cambian los flujos de trabajo de Git cuando los agentes hacen commits, y por qué el sandboxing no es opcional. Profundizaremos en los tests como el bucle de retroalimentación que hace que los agentes sean _fiables_ en lugar de solo rápidos, y las convenciones como el arma secreta que la mayoría de la gente pasa por alto.

Luego iremos más profundo — modelos locales versus comerciales, ingeniería de prompts como disciplina real, y orquestación multi-agente. Veremos historias de guerra: fallos reales, lecciones reales, tejido cicatricial real. Hablaremos de cuándo _no_ usar agentes, porque saber cuándo soltar la herramienta es tan importante como saber cómo usarla. Y cerraremos con cómo los equipos adoptan esto sin implosionar.

Al final, no solo sabrás cómo usar agentes de IA. Sabrás cómo _pensar_ sobre ellos — que es la habilidad que sobrevive cuando la generación actual de herramientas quede obsoleta.

== Lo Que Este Libro No Es

Déjame ahorrarte algo de tiempo.

Esto no es un recetario de prompts. No encontrarás "50 prompts de ChatGPT para desarrolladores" aquí. Los prompts importan, y los cubrimos, pero copiar y pegar prompts sin entender el sistema debajo es una receta para una frustración costosa.

Esto no es un manifiesto del hype de la IA. No estoy aquí para decirte que los agentes reemplazarán a todos los programadores para el próximo martes. No lo harán. La brecha entre la demo y la producción es tan ancha como siempre, y alguien tiene que vigilar esa brecha.

Tampoco es una narrativa catastrofista. El encuadre de "la IA viene por tu trabajo" es perezoso y en su mayoría equivocado. Lo que viene es un cambio fundamental en _cómo_ funciona el trabajo, y esa es una conversación completamente diferente.

Este es un libro de ingeniería. Para ingenieros. Escrito por alguien que pasa sus días escribiendo código con agentes y tiene el historial de git para demostrarlo. Vamos a ser prácticos, honestos y específicos. Si eso suena como lo tuyo, pasa la página.
