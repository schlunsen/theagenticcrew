= Cuando los Agentes Se Equivocan

#figure(
  image("../../assets/illustrations/ch14-storm.jpg", width: 80%),
)

Todo ingeniero que trabaja con agentes el tiempo suficiente tiene una colección de estas historias. Los momentos en que te echas hacia atrás en la silla, miras la pantalla y murmuras algo impublicable. Son humillantes. Son educativas. Y son _inevitables_.

Este capítulo es una colección de historias de guerra — cosas que realmente salen mal cuando entregas trabajo real a un agente. No hipotéticas. No demos fabricadas. El tipo de fallos que te cuestan una tarde, un despliegue o tu fe en la automatización. Cada una se conecta con principios de capítulos anteriores, porque los principios son baratos hasta que los aprendes por las malas.

Lee estas antes de cometer los mismos errores. O léelas después, y siéntete menos solo.

== El Refactorizador Entusiasta

La tarea era simple: arreglar un problema de z-index en un menú desplegable. El desplegable se renderizaba detrás de un overlay modal. Una corrección de CSS de una línea — quizá dos si eres cuidadoso.

El agente vio el componente del desplegable, decidió que su CSS era "inconsistente con las prácticas modernas," y lo refactorizó. Luego notó que el modal usaba un patrón de estilo diferente, así que lo refactorizó también. Luego los componentes de botón. Luego los componentes de tarjeta. Antes de que levantaras la vista de tu café, treinta y dos archivos habían cambiado. El diff era de 1.400 líneas. El agente había esencialmente reescrito el sistema de estilos de la biblioteca de componentes, migrando de un enfoque a otro con admirable consistencia y cero autorización.

¿El bug original de z-index? Seguía ahí. Enterrado en algún lugar de la avalancha de cambios, el agente había reproducido el mismo problema de capas con nuevos nombres de clase.

El PR era irrevisable. No puedes revisar significativamente 1.400 líneas de cambios de CSS en treinta y dos archivos. Lo que _puedes_ hacer es borrar la rama y empezar de nuevo. Que es lo que pasó.

*Lo que haces diferente ahora:* Acota las tareas estrictamente. "Arregla el z-index del desplegable en `NavMenu.tsx`, no toques nada más." Usa una rama dedicada para que el daño esté contenido. Y _siempre_ revisa el diff antes de dejar que el agente pase a otra cosa. En el momento en que veas el conteo de archivos subir más allá de lo que tiene sentido para la tarea, detén al agente. El capítulo de barandillas existe por una razón.

== La Biblioteca Alucinada

El agente necesitaba parsear algunos rangos de fechas complejos de la entrada del usuario. Importó `@temporal/daterange-parser`, escribió código elegante usando su método `.parseRange()` con opciones para parseo consciente del idioma y coincidencia difusa. El código era limpio. Los tipos eran correctos. El manejo de errores era cuidadoso. Incluso escribió tests — que, naturalmente, también importaban el paquete alucinado.

Todo se veía perfecto en el diff. Las firmas de funciones tenían sentido. La API estaba bien diseñada. Era una biblioteca _tan_ plausible que casi no la cuestionaste.

Luego `npm install` falló. El paquete no existía. Nunca había existido. El agente había inventado una biblioteca, le había dado un nombre creíble y una API coherente, y había escrito código de producción contra una ficción.

La parte insidiosa: si solo hubieras hecho revisión de código — leyendo la lógica, comprobando los tipos, evaluando el enfoque — lo habrías aprobado. El código era _bueno_. Simplemente no conectaba con la realidad.

*Lo que haces diferente ahora:* El agente ejecuta los tests. Siempre. Si tu configuración no lo permite, los ejecutas tú mismo antes de revisar el código. Sin excepciones. Un `npm install` que falla es una señal fuerte y obvia. Una API alucinada que nunca se ejecutó es una bomba silenciosa. Los tests detectan lo que la revisión humana no detecta — no porque tu revisión sea mala, sino porque las ficciones plausibles están _diseñadas_ para pasar la revisión. Eso es lo que _es_ la alucinación.

== El Bucle Infinito

Le pediste al agente que arreglara un test de integración que fallaba. Leyó el error, hizo un cambio, ejecutó el test. Nuevo error. Leyó _ese_ error, hizo otro cambio, ejecutó el test. Error diferente. Luego una variación del primer error. Luego algo nuevo. Luego el primer error de nuevo.

Estabas en otro terminal, trabajando en otra cosa. Cuarenta minutos después comprobaste. El agente había hecho diecinueve intentos. Había quemado 200.000 tokens. El código ahora estaba peor que al principio — un registro geológico de correcciones fallidas apiladas unas sobre otras. El agente seguía adelante, alegremente confiado en que el intento veinte sería el bueno.

No lo fue.

El problema fundamental era que el agente no entendía _por qué_ el test fallaba. Estaba haciendo coincidencia de patrones sobre mensajes de error y haciendo ediciones locales, pero el problema real era un malentendido arquitectónico — un estado de base de datos compartido entre casos de test que requería un enfoque de setup completamente diferente. Ninguna cantidad de ajustes al código bajo test arreglaría un problema en el harness de tests.

*Lo que haces diferente ahora:* Establece límites de iteración. Tres intentos en el mismo problema es un máximo razonable. Si el agente no lo ha resuelto en tres pasadas, no lo resolverá en treinta. Cuando veas el bucle — error, corrección, error diferente, corrección, error original — _rómpelo manualmente_. Detén al agente, lee los errores tú mismo, y dale un enfoque completamente diferente o toma el control. El tiempo del agente es barato. Tu tarde desperdiciada no. Más importante, empieza un contexto fresco. La comprensión del agente ahora está contaminada con diecinueve teorías equivocadas. Un inicio limpio con tu diagnóstico del problema _real_ llegará más lejos, más rápido.

== La Respuesta Equivocada Con Confianza

Un job en background ocasionalmente procesaba el mismo ítem dos veces. Condición de carrera clásica. Apuntaste al agente al problema.

El agente analizó el código, identificó la ventana de carrera y añadió un delay de 500ms entre la comprobación y la actualización. "Esto asegura que la transacción anterior tenga tiempo de hacer commit antes de la siguiente comprobación," explicó, con la serena confianza de alguien que nunca ha operado un sistema bajo carga.

Los tests pasaron. El delay era más largo que el tiempo de transacción del test, así que la ventana de carrera se cerró — en el entorno de tests, con un worker concurrente, en una máquina tranquila.

Se fue a producción. Bajo carga, con doce workers y latencia de base de datos variable, 500ms a veces no era suficiente. Y ahora tenías un _nuevo_ problema: el delay había reducido el rendimiento lo suficiente como para que la cola de jobs se acumulara durante las horas pico, creando timeouts en cascada que tumbaron un servicio no relacionado.

El sleep no arregló la condición de carrera. La ocultó a baja concurrencia y empeoró el sistema a alta concurrencia. Una corrección apropiada — un advisory lock o una clave de idempotencia — habría sido correcta a cualquier escala. El agente eligió la corrección que hacía el test verde, no la corrección que era _correcta_.

*Lo que haces diferente ahora:* Tratas los tests que pasan como necesarios pero no suficientes. Cuando un agente arregla un problema de concurrencia, te preguntas _a ti mismo_ si la corrección es correcta bajo carga, bajo fallo, bajo condiciones que la suite de tests no cubre. Los agentes optimizan para la señal de retroalimentación que les das, y si esa señal es "los tests pasan," encontrarán el camino más corto a verde — incluso si ese camino es un `time.Sleep`. Tu criterio de ingeniería sobre _por qué_ algo funciona importa más que _si_ los tests pasan. Esta es la parte del trabajo que aún no se ha automatizado. Apóyate en ella.

== La Amnesia de Contexto

Dos horas dentro de una sesión, tenías una funcionalidad evolucionando bien. Le habías dicho al agente al principio: "No uses ningún ORM — estamos escribiendo SQL directo en este proyecto. Es una decisión deliberada." El agente acusó recibo y escribió consultas limpias, hechas a mano, para las primeras varias tareas.

Luego le pediste que añadiera un nuevo endpoint. Noventa minutos de contexto se habían acumulado. El agente construyó el endpoint — usando Prisma. Archivo de esquema completo, migración, cliente generado. Código hermoso. Contradiciendo completamente la restricción que habías establecido al inicio de la sesión y los patrones en cada otro archivo que había escrito ese día.

Cuando lo señalaste, el agente se disculpó, reescribió todo en SQL directo y actuó como si nada hubiera pasado. No había _decidido_ ignorar tu restricción. Simplemente la había perdido. La ventana de contexto se había llenado con suficiente trabajo intermedio que la instrucción temprana se había desvanecido en irrelevancia.

*Lo que haces diferente ahora:* Las sesiones largas se degradan. Esta es una propiedad fundamental de cómo funcionan las ventanas de contexto, no un bug que se parcheará el próximo trimestre. Mantén las tareas cortas y enfocadas. Haz commit del código que funciona en los límites naturales para que el progreso se capture en git, no solo en la conversación. Empieza sesiones nuevas para tareas nuevas. Y para restricciones de proyecto como "no ORM" o "no nuevas dependencias," ponlas en un archivo `CLAUDE.md` o equivalente que el agente lea al arrancar. No confíes en que el agente _recuerde_ lo que dijiste hace dos horas. No lo hará. Escríbelo.

== La Avalancha de Dependencias

Pediste un selector de fechas. Una entrada simple donde los usuarios pueden seleccionar una fecha. El agente evaluó las opciones y decidió ser exhaustivo.

Instaló `moment.js` para el manejo de fechas. Luego `@popperjs/core` para posicionar el desplegable. Luego una biblioteca completa de componentes UI porque "proporciona primitivas accesibles de selector de fechas." Luego un preprocesador CSS porque el sistema de temas de la biblioteca de componentes lo requería. Luego dos paquetes utilitarios que el selector de fechas de la biblioteca de componentes necesitaba como peer dependencies.

Seis nuevas dependencias. Tu tamaño de bundle pasó de 180KB a 540KB. Tu tiempo de build se duplicó. Tenías un selector de fechas, eso sí. Muy bonito.

El `<input type="date">` nativo de HTML habría sido suficiente. O una sola biblioteca ligera de selector en 8KB. En su lugar habías heredado un ecosistema entero porque el agente optimizó para completitud en lugar de minimalismo.

La peor parte no fue el tamaño del bundle — fue la superficie de mantenimiento. Seis paquetes nuevos significan seis cosas nuevas que pueden tener vulnerabilidades de seguridad, seis cosas nuevas que pueden romperse en una actualización, seis changelogs nuevos que leer cuando Dependabot empiece a abrir PRs. No solo añadiste un selector de fechas. Adoptaste seis proyectos open source.

*Lo que haces diferente ahora:* Restringe lo que los agentes pueden instalar. "No nuevas dependencias sin preguntarme primero" es una instrucción legítima y a menudo _sabia_. Cuando permitas nuevos paquetes, dile al agente tus restricciones: presupuesto de bundle, no paquetes con menos de N descargas semanales, no paquetes que traigan mega-dependencias transitivas. Los agentes no tienen opiniones sobre el tamaño del bundle o la carga de mantenimiento. Ellos no mantienen el proyecto el año que viene. _Tú_ sí. Así que tú pones los límites.

== El Hilo Común

Cada una de estas historias tiene la misma causa raíz: el agente estaba haciendo _exactamente para lo que fue diseñado_, y el humano no estaba proporcionando suficiente estructura.

El refactorizador entusiasta estaba siendo servicial. La biblioteca alucinada estaba siendo creativa. El bucle infinito estaba siendo persistente. La respuesta equivocada con confianza estaba siendo guiada por tests. La amnesia de contexto era una limitación, no una elección. La avalancha de dependencias estaba siendo exhaustiva.

Ninguna de estas son bugs del agente. Son bugs de _flujo de trabajo_. La solución nunca es "usa un agente más inteligente." La solución es siempre la misma: alcance más estricto, mejores bucles de retroalimentación, más estructura, sesiones más cortas, y un humano que se mantiene involucrado.

Y cada vez más, la solución incluye _equipar al agente con mejores herramientas_. La Biblioteca Alucinada se habría detectado si el agente pudiera ejecutar `npm install` y la suite de tests. El Bucle Infinito se habría acotado con límites de iteración en el tooling. Las historias de guerra son a menudo historias sobre agentes que carecían de las herramientas o barandillas correctas, no agentes que carecían de inteligencia.

Los agentes se equivocan. Los humanos también. La diferencia es que los humanos se equivocan lo suficientemente despacio como para notarlo. Los agentes se equivocan a la velocidad del autocompletado, y para cuando levantas la vista de tu café, treinta y dos archivos han cambiado.

Mantente en el bucle. Revisa los diffs. Confía pero verifica. Y cuando las cosas salgan mal — porque lo harán — recuerda que el botón de borrar-rama-y-empezar-de-nuevo es la herramienta más infravalorada de tu flujo de trabajo.

== El Manual de Diagnóstico

Las historias de guerra son entretenidas. Pero no puedes pegar anécdotas en tu monitor. Lo que necesitas es un enfoque sistemático — una checklist para cuando el agente produce algo incorrecto, para que puedas diagnosticar el fallo rápido y arreglar lo correcto en lugar de ir a ciegas.

Cuando un agente te da mala salida, recorre estas preguntas en orden. La mayoría de los fallos caen en una de seis categorías, y saber en cuál estás determina qué hacer a continuación.

*1. ¿Es un problema de alcance?*

¿Pediste demasiado en un prompt? El Refactorizador Entusiasta ocurrió porque "arregla el z-index" era demasiado vago — no decía "no toques nada más." Si el agente cambió archivos que no esperabas, o hizo trabajo que no pediste, el alcance era demasiado suelto. Ajusta el prompt. Sé explícito sobre qué _no_ hacer. Las restricciones son más útiles que las instrucciones cuando lidias con un agente entusiasta.

*2. ¿Es un problema de contexto?*

¿El agente tenía lo que necesitaba para resolver el problema real? Recuerda la historia del bug de facturación del Capítulo 2 — un ingeniero dio contexto vago y obtuvo una respuesta vaga, el otro dio archivos específicos y trazas de error y obtuvo una corrección funcional. Si el agente resolvió el problema _equivocado_, probablemente no podía ver el correcto. Aliméntalo con los archivos relevantes, la salida de errores, las restricciones que no puede inferir. Los agentes no adivinan bien. Trabajan con lo que les das.

*3. ¿Es un problema de señal de retroalimentación?*

¿Tus tests realmente verifican lo correcto? La Respuesta Equivocada Con Confianza ocurrió porque los tests pasaron — pero no testeaban bajo condiciones realistas. El sleep de 500ms como "corrección" era verde en CI e incorrecto en producción. Si la solución del agente te parece dudosa pero los tests pasan, _tus tests son el problema_. El agente optimizó para la señal que le diste. Dale una señal mejor.

*4. ¿Es un problema de capacidad?*

Algunas tareas están genuinamente más allá de lo que el modelo puede hacer. Razonamiento multi-archivo a través de un sistema extenso con dependencias implícitas. Problemas sutiles de concurrencia que requieren entender el comportamiento en runtime, no solo la estructura del código. Lógica sensible a la seguridad donde "plausible" no es suficiente. Si el agente sigue intentando diferentes enfoques y fallando, puede que no sea capaz de esta tarea particular. Eso no es un problema de prompt — es una limitación. Reconócelo y toma el control. Tu tiempo se emplea mejor haciendo el trabajo que ingeniando el prompt perfecto para una tarea que el agente no puede manejar.

*5. ¿Es un problema de ventana de contexto?*

Las sesiones largas se degradan. Punto. La historia de Amnesia de Contexto lo demostró — restricciones establecidas al principio de una sesión simplemente se pierden a medida que el contexto se llena con trabajo intermedio. Si el agente contradice algo que hizo correctamente antes en la misma sesión, o ignora una restricción que estableciste hace una hora, la ventana de contexto es el culpable. Empieza una sesión nueva. Reestablece las restricciones relevantes. Dale solo el contexto que necesita para la tarea actual, no el registro arqueológico de todo lo que habéis discutido hoy.

*6. ¿Es un bucle?*

Tres intentos en el mismo error es el límite. Si el agente no lo ha resuelto en tres pasadas, no lo resolverá en treinta. La historia del Bucle Infinito quemó 200.000 tokens en diecinueve intentos sin progreso. Cuando veas el patrón — error, corrección, error diferente, corrección, error original — rompe el bucle inmediatamente. Detén al agente. Lee los errores tú mismo. O dale al agente un enfoque completamente diferente con un diagnóstico fresco, o toma el control por completo. El contexto del agente ahora está contaminado con teorías fallidas, y más intentos solo añadirán más contaminación.

Imprime esta checklist. Pégala en tu monitor. Las primeras veces la recorrerás conscientemente. Después de un mes, se convierte en instinto. Después de tres meses, detectarás el problema antes de que el agente termine su primer intento.
