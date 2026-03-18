= ¿Qué Es un Agente?

La palabra "agente" se usa mucho. Se aplica a todo, desde un chatbot que responde preguntas hasta un sistema que despliega código en producción de forma autónoma. Antes de seguir adelante, seamos precisos sobre lo que queremos decir — porque la distinción importa para cómo trabajas con ellos.

== El Espectro

No todas las herramientas de IA son agentes. En un extremo, el *autocompletado* sugiere los siguientes tokens mientras escribes — reactivo, una línea a la vez, sin razonamiento involucrado. Un *copiloto* ve más contexto y genera bloques más grandes, pero sigue siendo pasivo: tú preguntas, él responde. El cambio ocurre con los *agentes que usan herramientas*. Un agente no solo genera texto — _actúa_. Lee archivos, escribe archivos, ejecuta comandos, inspecciona resultados y, crucialmente, lo hace en un bucle: intenta, observa, ajusta, intenta de nuevo. En el extremo opuesto, los *agentes autónomos* toman un objetivo de alto nivel, planifican su propio enfoque y entregan un resultado con mínima interacción humana.

La mayor parte de la ingeniería agéntica práctica hoy ocurre en la zona de uso de herramientas. Le das al agente una tarea, tiene acceso a herramientas y trabaja iterativamente. Tú estás en el bucle — revisando, guiando, aprobando — pero el agente hace el trabajo pesado.

== Qué Hace Que Algo Sea "Agéntico"

Tres capacidades separan a un agente de un chatbot sofisticado:

*Planificación.* Un agente descompone un objetivo en pasos. "Añade autenticación a esta app" se convierte en una serie de acciones — leer el código base, elegir el framework, crear middleware, actualizar rutas, añadir tests, verificar. Un chatbot te da un bloque de código. Un agente te da un proceso.

*Uso de herramientas.* Un agente interactúa con el mundo — lee tus archivos, ejecuta tus tests, examina la salida de errores. Cada llamada a una herramienta proporciona nueva información que da forma a la siguiente decisión. Este bucle de retroalimentación es lo que hace poderosos a los agentes: no están generando código en el vacío, están generando código y _verificándolo_. Y aquí está lo que la gente no percibe: las herramientas que le das a un agente definen qué tipo de agente _es_. Un LLM con solo texto de entrada y texto de salida es un chatbot. Dale acceso a archivos, ejecución de comandos e integraciones con sistemas externos, y se convierte en un ingeniero. Las herramientas son el ascenso.

*Iteración.* Un agente puede intentar, fallar e intentar de nuevo. Escribe una función, ejecuta los tests, ve un fallo, lee el error, ajusta, vuelve a ejecutar. Actúa, observa, ajusta. Un chatbot te da un solo intento. Un agente te da un ciclo.

== Los Agentes No Son Magia

Es importante ser realista sobre lo que son y lo que no son los agentes.

Los agentes no son sentientes. No entienden tu código como tú lo haces. No tienen intuición, gusto ni experiencia. Lo que tienen es la capacidad de procesar grandes cantidades de texto, reconocer patrones y generar próximos pasos plausibles — muy rápido, muy incansablemente, y a una escala que agotaría a cualquier humano.

Alucinan. Cometen errores con confianza. A veces resuelven el problema equivocado de forma brillante. Pueden escribir código que pasa todos los tests pero pierde completamente el objetivo. Son becarios brillantes con energía infinita y cero criterio.

Por eso el _ingeniero_ importa. El agente proporciona velocidad y amplitud. Tú proporcionas dirección, criterio y gusto. La combinación es más poderosa que cualquiera por separado.

== Cuándo Fallan los Agentes

Fallarán. Entender _cómo_ fallan te ayuda a construir mejores flujos de trabajo.

*Expansión del alcance.* Pides una corrección de bug, el agente refactoriza tres archivos y actualiza el sistema de build. Los agentes son entusiastas, y ese entusiasmo se extiende más allá de lo que pediste. Las tareas pequeñas y enfocadas y el aislamiento de ramas son tu defensa.

*APIs alucinadas.* El agente llama a funciones o bibliotecas que no existen — o que existen en una versión diferente. Ejecutar tests detecta esto. El agente no puede alucinar su camino a través de una suite de tests.

*Exceso de confianza.* El agente dice que ha terminado, y parece que ha terminado, pero hay un bug sutil que solo aparece bajo condiciones específicas. Revisa los diffs. No confíes ciegamente en la salida del agente.

*Pérdida de contexto.* En tareas largas, el agente pierde el hilo de decisiones anteriores — se contradice, reescribe código que ya escribió, olvida restricciones. Los commits pequeños y la gestión clara del contexto son la mitigación.

Cada modo de fallo tiene una mitigación, y esas mitigaciones son los capítulos de este libro: contexto, barandillas, git, sandboxes, testing, convenciones. Los principios no son teóricos — son respuestas directas a cómo fallan los agentes en la práctica.

== El Modelo Mental Correcto

No pienses en los agentes como herramientas. No pienses en ellos como reemplazos. Piensa en ellos como colaboradores con un conjunto muy específico de fortalezas y debilidades.

Son rápidos donde tú eres lento. Son pacientes donde tú eres impaciente. Pueden mantener más texto en la memoria de trabajo que tú. Nunca se cansan, nunca se frustran, nunca tienen un mal día.

Pero no saben qué importa. No saben lo que el usuario realmente necesita. No saben qué deuda técnica es aceptable y cuál es una bomba de relojería. No saben cuándo rechazar un requisito. No saben cuándo la especificación está equivocada.

La mejor analogía que he encontrado es _Rain Man_. Tú eres Tom Cruise. El agente es Dustin Hoffman.

Raymond puede contar cartas como ningún humano vivo — ve patrones en montañas de datos, los procesa instantáneamente, nunca se cansa, nunca pierde el foco. Pero no puede navegar por el suelo de un casino. No sabe _por qué_ están contando cartas. No sabe cuándo alejarse de la mesa, cuándo el jefe de sala empieza a sospechar, o qué hacer con el dinero. Dejado a sus propios medios, contaría cartas para siempre en una habitación vacía.

Charlie es el que tiene el plan. Sabe a qué casino ir, cuándo apostar fuerte, cuándo cobrar, cuándo cambiar de estrategia completamente. No puede contar cartas él mismo — no a la velocidad de Raymond, no a la escala de Raymond. Pero no lo necesita. Su trabajo es la dirección, el criterio y saber para qué sirve toda la operación.

Eso es la ingeniería agéntica. Tu agente procesará todo tu código base, generará soluciones a una velocidad que no puedes igualar e iterará incansablemente. Pero no sabe qué problema vale la pena resolver. No sabe cuándo la solución elegante es la equivocada. No sabe cuándo parar.

Ese es tu trabajo. Y siempre lo será.
