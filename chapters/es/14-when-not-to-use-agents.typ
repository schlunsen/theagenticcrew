= Cuándo No Usar Agentes

Este libro trata sobre usar agentes bien. Este capítulo trata sobre saber cuándo no usarlos en absoluto.

Si has leído hasta aquí, probablemente estás convencido de la ingeniería agéntica. Bien. Pero la forma más rápida de perder credibilidad — y tiempo — es recurrir a un agente cuando el trabajo requiere un humano. Los mejores ingenieros agénticos no son los que más usan agentes. Son los que saben _exactamente_ cuándo guardar el agente y hacer el trabajo ellos mismos.

== El Impuesto del Overhead

Cada interacción con un agente tiene un coste. Escribes el prompt. Esperas la salida. Revisas lo que produjo. Arreglas los errores. Lo vuelves a ejecutar si no acertó. Eso es overhead, y es real.

Para tareas complejas que te llevarían una hora, dedicar dos minutos al prompt y la revisión es una ganga. Pero para tareas que puedes hacer en treinta segundos, el overhead hace a los agentes _más lentos_, no más rápidos.

Renombrar una variable. Arreglar un typo. Ajustar un valor de configuración. Añadir una línea de log. Estas son tareas de memoria muscular. Tus dedos conocen las pulsaciones. Para cuando has tecleado un prompt describiendo lo que quieres, podrías haberlo hecho ya.

Esto no es un fallo de los agentes. Es aritmética. Las tareas pequeñas tienen retornos pequeños, y el coste fijo de la interacción con el agente se come el margen. No dejes que la novedad de los agentes te engañe para usarlos en todo. Parte del trabajo simplemente es más rápido a mano.

== Decisiones de Arquitectura Novedosas

Cuando estás diseñando un sistema desde cero — eligiendo entre un monolito y microservicios, decidiendo tu modelo de datos, eligiendo tus patrones de comunicación — el _pensar es el trabajo_. El valor no está en el diagrama o el documento. El valor está en el modelo mental que construyes mientras luchas con los compromisos.

Un agente puede ayudarte a explorar opciones. Puede listar los pros y contras del event sourcing versus CRUD. Puede esbozar cómo se vería una arquitectura particular. Eso es útil como entrada.

Pero delegar la arquitectura misma a un agente significa que no entiendes tu propio sistema. Te costará depurarlo, extenderlo o explicárselo a tu equipo. El trabajo del ingeniero senior es tomar las decisiones difíciles — sopesar los compromisos que no tienen respuestas limpias, decidir qué complejidad vale la pena cargar y cuál no. Ese criterio viene de hacer el trabajo, no de leer el resumen de un agente.

Usa agentes como sparring partner para la arquitectura. No como el arquitecto.

== Código Crítico para la Seguridad

Flujos de autenticación. Cifrado. Control de acceso. Validación de entrada. Manejo de tokens. Estas son áreas donde "parece correcto" no es suficiente.

Los bugs de seguridad son diferentes de los bugs normales. Una función de ordenamiento rota produce salida incorrecta que alguien nota. Una comprobación de autenticación rota no produce _síntomas visibles_ hasta que un atacante la encuentra. El código parece bien. Los tests pasan. Y seis meses después estás escribiendo un informe de incidente.

Los agentes producen código plausible. Esa es su fortaleza y, en contextos de seguridad, su peligro. Un fallo sutil en un flujo de validación JWT, una comprobación faltante en una URL de redirección, un canal lateral de timing en una comparación de contraseñas — estos son el tipo de errores que sobreviven la revisión de código porque _se ven bien_.

Escribe el código crítico para la seguridad tú mismo. Revísalo cuidadosamente. Consigue un segundo par de ojos humanos. Si usas un agente para redactar código de seguridad, trata ese borrador con más sospecha de la que darías al primer intento de un desarrollador junior, no menos.

== Cuando Necesitas Aprender

Estás aprendiendo un nuevo lenguaje. Un nuevo framework. Un nuevo paradigma. La tentación es obvia: deja que el agente escriba el código mientras tú te enfocas en el panorama general.

Resístelo.

Si dejas que el agente escriba todo el Rust mientras estás aprendiendo Rust, no has aprendido Rust. Has construido algo que no puedes mantener, depurar ni extender sin el agente. Has creado una dependencia, no una habilidad.

Hay una diferencia crucial entre usar un agente para _explicar_ algo y usarlo para _hacer_ algo. Preguntar "¿por qué ocurre este error del borrow checker?" construye comprensión. Preguntar "arregla este error del borrow checker" no.

Cuando el objetivo es aprender, ve despacio. Escribe el código tú mismo. Comete los errores tú mismo. Usa agentes como tutores, no como escritores fantasma. La comprensión que construyes luchando con las partes difíciles es todo el punto.

== Decisiones con Carga Emocional

No toda decisión de ingeniería es técnica. Algunas de las más difíciles son humanas.

Deprecar una API de la que depende un socio. Decirle a un stakeholder que su petición de funcionalidad no entrará. Rechazar un deadline que sabes que es irreal. Decidir discontinuar un producto que todavía tiene usuarios.

Estas decisiones requieren empatía. Requieren leer la sala, entender la política, sopesar el coste humano junto al coste técnico. Requieren _responsabilidad_ — alguien que sea dueño de la decisión y sus consecuencias.

Un agente puede redactar el email. Puede ayudarte a pensar en los puntos clave. Pero la decisión en sí, y la conversación que la entrega, debe venir de un humano. Las personas merecen escuchar noticias difíciles de una persona, no de alguien que copió y pegó la salida de un agente.

== Cuando el Código Base Es Demasiado Desordenado

Los agentes amplifican lo que ya está ahí. En un código base limpio y bien estructurado con convenciones fuertes, los agentes producen código limpio y bien estructurado. Detectan los patrones y los siguen.

¿En un desastre? Producen más desastre.

Si tu código base tiene nombres inconsistentes, dependencias enredadas, sin límites claros de módulos, y tres formas diferentes de hacer lo mismo — un agente detectará _todos_ esos patrones. Podría combinar las peores partes de cada uno. No sabe qué patrones son intencionales y cuáles son deuda técnica. Solo ve lo que hay y produce más de lo mismo.

A veces lo correcto es limpiar antes de traer agentes. Refactorizar el módulo. Establecer la convención. Borrar el código muerto. Hacer del código base un lugar donde un agente pueda hacer buen trabajo. Este es trabajo poco glamuroso, manual. Pero es la base que hace posible todo lo demás.

Piénsalo como un taller. No le das herramientas eléctricas a alguien en un taller desordenado y desorganizado. Primero limpias, _luego_ traes las herramientas.

== Trabajando con Código Legacy

Esa metáfora del taller es bonita. Pero no todos tienen el lujo de limpiar primero. Algunos de nosotros mantenemos monolitos Java de 500.000 líneas que empezaron en 2014 y han pasado por tres migraciones de framework, dos adquisiciones, y un breve periodo en el que alguien pensó que la configuración XML era buena idea. El consejo de "refactorizar antes de traer agentes" es sólido en teoría y risible en la práctica cuando estás mirando un código base que llevaría años refactorizar.

Entonces, ¿cómo _usas_ agentes en código legacy? Con cuidado. Y con una estrategia específica.

*Empieza con los tests.* Antes de apuntar un agente a código legacy, escribe tests de caracterización — tests que capturan lo que el código _hace actualmente_, no lo que _debería_ hacer. Estos no son aspiracionales. Son descriptivos. Dicen "cuando llamas a esta función con estas entradas, esto es lo que sale, y ese es el contrato actual lo haya pretendido alguien o no."

Los tests de caracterización le dan al agente una red de seguridad. Sin ellos, el agente cambiará comportamiento que no entiende, y no lo sabrás hasta que producción te lo diga. Con ellos, cualquier cambio de comportamiento aparece como un fallo de test _antes_ de que el código salga de tu máquina. Esto es innegociable. Código legacy sin tests es código legacy que no puedes dejar que los agentes toquen de forma segura.

*Acota despiadadamente.* En un código base legacy, el agente no puede entender todo el sistema. No intentes que lo haga. Apúntalo a un archivo, una función, un bug. Dale el contexto inmediato — la firma de la función, los llamadores, el comportamiento esperado — y nada más. El código legacy está lleno de suposiciones implícitas, efectos secundarios no documentados y peculiaridades estructurales. Cuanto menos vea el agente, menos puede malinterpretar. Un alcance estrecho con contexto claro supera a un alcance amplio con complejidad arqueológica.

*Usa agentes para las partes tediosas.* Los códigos base legacy están llenos de trabajo mecánico: actualizar llamadas a API deprecadas en cientos de archivos, migrar de una versión de dependencia a otra, añadir anotaciones de tipos a código sin tipar, estandarizar patrones de manejo de errores, reemplazar un framework de logging por otro. Estas son tareas _perfectas_ para agentes — repetitivas, bien definidas, fácilmente verificadas por comprobaciones automatizadas. Deja que los agentes hagan el trabajo tedioso. Guarda tu energía para las partes que requieren entender _por qué_ el código es como es. Ese es el trabajo que solo un humano que ha vivido con el sistema puede hacer.

*Documenta sobre la marcha.* Cada vez que un agente trabaja exitosamente en un archivo legacy, añade un breve comentario explicando qué hace el código, o actualiza el `CLAUDE.md` del proyecto con contexto sobre ese módulo. Con el tiempo, algo interesante pasa: las partes del código base legacy que los agentes han tocado se vuelven mejor documentadas que las partes que no. No porque te propusieras documentar el sistema, sino porque usar agentes te _forzó_ a articular qué hace cada pieza para poder hacer prompts efectivos. Los agentes están lentamente haciendo el código base más legible — no refactorizándolo, sino haciéndote explicarlo.

== El Argumento del Oficio

Hay una razón más para a veces guardar el agente, y no se trata de eficiencia o riesgo. Se trata del oficio.

Escribir código a mano construye algo que los agentes no pueden darte. Memoria muscular. Reconocimiento de patrones que vive en tus dedos, no solo en tu cabeza. La comprensión profunda e intuitiva que viene de haber escrito el mismo tipo de función docenas de veces. La satisfacción silenciosa de resolver un problema difícil a través de tu propio razonamiento.

Estas cosas importan. No porque sean románticas, sino porque te hacen mejor ingeniero. El desarrollador que ha escrito un parser a mano entiende el parsing de forma diferente que uno que solo ha hecho prompts a un agente para que escriba uno. El desarrollador que ha depurado un problema de concurrencia a las 2am _siente_ el peligro del estado mutable compartido de una forma que leer sobre ello nunca proporciona.

Los agentes son herramientas. Potentes. Pero si los dejas hacer todo el trabajo, tus propias habilidades se atrofian. Y cuando te encuentres con un problema que el agente no puede resolver — y lo harás — necesitas que esas habilidades sigan afiladas.

Mantente en forma. Escribe código a mano regularmente. No porque sea más rápido, sino porque te mantiene peligroso.

== El Criterio Que Importa

La habilidad central de la ingeniería agéntica no es el prompting. No es la configuración de herramientas. No es saber qué modelo usar para qué tarea.

Es _criterio_.

Saber cuándo un agente te ahorrará una hora y cuándo desperdiciará una. Saber cuándo confiar en la salida y cuándo reescribirla desde cero. Saber cuándo delegar y cuándo meterte de lleno tú mismo.

Los mejores ingenieros agénticos usan agentes agresivamente — pero selectivamente. Recurren a agentes cuando el apalancamiento es real: refactorizaciones a gran escala, generación de boilerplate, exploración de código, escritura de tests, documentación. Y guardan el agente cuando el trabajo requiere pensamiento humano, responsabilidad humana u oficio humano.

Ese criterio es lo que separa a los ingenieros agénticos de los meros operadores de prompts. Cualquiera puede teclear un prompt. Saber _cuándo no hacerlo_ es la habilidad más difícil.
