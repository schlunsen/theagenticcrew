= LLMs Locales vs. Comerciales

Un amigo mío — ingeniero senior en una startup Serie B — me escribió un viernes por la tarde. "Acabo de recibir nuestra primera factura real de API. Dos mil doscientos dólares. Solo de _marzo_." Había estado ejecutando Claude Code en su equipo de ocho ingenieros, cada uno iterando en funcionalidades, depurando, refactorizando. Nadie había establecido presupuestos de tokens. Nadie estaba vigilando el contador. Los agentes funcionaban de maravilla, y la factura era escalofriante.

Esa misma semana, hablé con una ingeniera en una empresa de salud en Múnich. Estaba ejecutando Llama 70B en un servidor GPU local porque su pipeline de datos de pacientes no podía tocar APIs externas. No "no debería" — _no podía_. Su equipo de cumplimiento lo había dejado claro por escrito. Obtenía resultados decentes para tareas enfocadas, pero cada vez que necesitaba razonamiento complejo multi-archivo, el modelo se desmoronaba y acababa haciendo el trabajo manualmente.

Estas dos historias son los extremos de la misma pregunta: ¿dónde se ejecuta el modelo? Suena como una decisión de infraestructura. Realmente es una decisión sobre confianza, coste, capacidad y — cada vez más — cómo arquitectas todo tu flujo de trabajo agéntico.

== LLMs Comerciales: La Frontera

Los modelos comerciales — Claude, GPT, Gemini — son donde vive la frontera. Si estás haciendo ingeniería agéntica seria, probablemente has pasado la mayor parte de tu tiempo aquí. Hay buenas razones para ello.

=== Ventanas de Contexto

El contexto lo es todo para los agentes. Un agente no solo lee tu prompt — lee archivos, salidas de herramientas, mensajes de error, resultados de tests y su propio razonamiento previo. Una sola tarea compleja puede llenar fácilmente 50.000 tokens de contexto, y una sesión de depuración multi-paso puede superar los 100.000.

Los modelos comerciales de frontera ofrecen ventanas de contexto de 128K tokens y más. Esto importa enormemente para el trabajo agéntico porque el agente necesita mantener tu código base en su cabeza. Cuando el contexto se agota, el agente empieza a olvidar archivos que leyó antes, decisiones que tomó antes, errores que vio antes. Se degrada de un ingeniero capaz a alguien con amnesia.

Los modelos locales típicamente tienen un tope de 8K-32K de contexto en la práctica, incluso si técnicamente soportan más sobre el papel. La calidad de la atención se degrada a medida que empujas hacia el límite. Un modelo comercial a 100K de contexto sigue razonando bien. Un modelo local a 32K de contexto a menudo pierde el hilo.

=== Calidad del Uso de Herramientas

Los agentes viven y mueren por el uso de herramientas. Leer archivos, escribir código, ejecutar comandos, buscar en códigos base — estos no son extras opcionales. Son el bucle principal. Y la calidad del uso de herramientas varía dramáticamente entre modelos.

Los modelos comerciales de frontera han sido específicamente entrenados y afinados para llamadas a herramientas. Formatean los argumentos correctamente, encadenan llamadas lógicamente, se recuperan con gracia cuando falla una llamada. Saben cuándo leer un archivo antes de editarlo. Saben cuándo ejecutar tests después de hacer cambios.

Los modelos más pequeños — incluyendo la mayoría de los modelos locales — son menos fiables aquí. Alucinarán rutas de archivos, olvidarán pasar argumentos requeridos, llamarán herramientas en el orden equivocado o se quedarán atascados en bucles llamando a la misma herramienta fallida una y otra vez. La diferencia no es sutil. En una tarea compleja que implica diez o quince llamadas a herramientas, un modelo de frontera podría tener éxito el 90% de las veces donde un modelo local tiene éxito el 40%.

=== Seguimiento de Instrucciones

Cuando le dices a un modelo de frontera "solo modifica archivos en el directorio `src/auth/`" o "no cambies la API pública, solo la implementación interna," generalmente escucha. Sigue los system prompts, respeta las restricciones y se mantiene dentro de los límites.

Los modelos más pequeños se desvían. Empezarán bien, luego gradualmente ignorarán tus restricciones a medida que la conversación se alarga y el contexto se llena. Este es un problema real para el trabajo agéntico, donde la precisión importa. Un agente que "mayormente" sigue instrucciones ocasionalmente reescribirá un archivo que no le pediste que tocara, o refactorizará algo que explícitamente le dijiste que dejara en paz. En un entorno sandbox esto es solo molesto. Sin sandbox es peligroso.

=== Eligiendo el Modelo Comercial Adecuado

No todos los modelos comerciales son intercambiables, incluso en la frontera. Esto es lo que he encontrado en la práctica:

*Para refactorizaciones complejas multi-archivo y trabajo arquitectónico* — usa el modelo más capaz que puedas permitirte. Aquí es donde la calidad de razonamiento más importa. La diferencia de coste entre un modelo de nivel medio y uno de primer nivel es unos pocos dólares por tarea. La diferencia de calidad es a menudo la diferencia entre un diff limpio y un desastre que tienes que rehacer manualmente.

*Para tareas enfocadas de un solo archivo* — escribir tests, implementar una función bien definida, corregir un bug claro — los modelos de nivel medio rinden casi tan bien como los de primer nivel, a una fracción del coste. La tarea tiene suficiente alcance como para que el modelo no necesite malabarear muchas preocupaciones a la vez.

*Para trabajo de alto volumen y baja complejidad* — generar boilerplate, formatear código, escribir mensajes de commit — el modelo más barato que pueda seguir instrucciones es la elección correcta. Ejecutarás estas tareas cientos de veces. Los ahorros por token se acumulan.

El error que veo más a menudo es usar un solo modelo para todo. Eso es como conducir un Fórmula 1 al supermercado. Ajusta el modelo a la tarea.

== LLMs Locales: La Imagen Completa

Ejecutar un modelo localmente — Llama, Mistral, Qwen, DeepSeek, Codestral, o cualquiera de los modelos de pesos abiertos vía Ollama, llama.cpp o vLLM — te da algo que las APIs comerciales no pueden: soberanía completa sobre los datos y coste marginal cero por token.

Tu código nunca sale de tu máquina. Puedes alimentarlo con código propietario, documentos internos, logs de producción, datos de clientes, API keys que dejaste accidentalmente en una configuración — nada de ello cruza una frontera de red. Y una vez que el modelo está descargado, cada inferencia es gratis. Ejecútalo mil veces, ejecútalo toda la noche, nadie te envía una factura.

Pero seamos honestos sobre la experiencia, porque el marketing alrededor de los modelos locales a menudo no lo es.

=== La Realidad del Hardware

La pregunta del hardware es la primera que todos hacen, y la respuesta es menos glamurosa de lo que sugieren los posts de blog de "¡ejecuta IA localmente!".

*MacBook Pro con Apple Silicon (M2/M3/M4 Pro o Max, 32-64GB RAM).* Este es el punto óptimo para desarrolladores individuales. Puedes ejecutar un modelo de 7B-14B parámetros cómodamente, y un modelo de 32B si tienes la RAM. La inferencia será notablemente más lenta que una API comercial — quizá 15-30 tokens por segundo para un modelo 14B, comparado con 80+ de una API comercial. Un modelo 70B técnicamente correrá en una máquina de 64GB pero será lo suficientemente lento como para poner a prueba tu paciencia. Estarás esperando 10-20 segundos por respuestas que toman 2 segundos de una API.

*Servidor GPU dedicado (NVIDIA RTX 4090 o A100).* Aquí es donde la inferencia local se vuelve genuinamente rápida. Una 4090 con 24GB de VRAM puede ejecutar un modelo 14B a velocidades cercanas a las comerciales. Una A100 con 80GB puede ejecutar un modelo 70B cómodamente. Pero ahora estás manteniendo hardware. Estás lidiando con drivers CUDA, gestión de VRAM y el ocasional "por qué está gritando el ventilador de mi GPU a las 3am".

*Hardware de consumo (MacBook Air de 16GB, máquinas antiguas, sin GPU discreta).* Estás limitado a modelos 7B, y la experiencia será mediocre. La inferencia es lenta, los modelos son demasiado pequeños para trabajo agéntico serio, y pasarás más tiempo esperando que trabajando. No recomendaría esto para nada más allá de la experimentación.

El resumen honesto: los modelos locales son prácticos para desarrolladores con un MacBook Pro reciente o una GPU dedicada. Por debajo de ese umbral de hardware, tendrás una experiencia frustrante. Por encima, tendrás una herramienta genuinamente útil — solo una herramienta diferente de una API comercial.

=== Dónde Brillan los Modelos Locales

Los modelos locales no son solo "modelos comerciales peores." Hay flujos de trabajo donde genuinamente tienen más sentido:

*Tareas de alta frecuencia y bajo riesgo.* Generar docstrings, escribir mensajes de commit, crear código boilerplate, formatear datos. Estas tareas no necesitan un modelo genio — necesitan un modelo rápido y gratis. Ejecutarlas localmente significa que puedes disparar y olvidar sin pensar en el coste.

*Códigos base sensibles.* Cubriremos esto más en la sección de privacidad, pero este es un caso de uso legítimo y creciente. Si tu código no puede salir de tu red, los modelos locales son la única opción, y "suficientemente bueno" es infinitamente mejor que "no disponible."

*Desarrollo offline.* En un avión, en un tren, en un búnker — tu modelo local funciona sin WiFi. Esto suena menor hasta que estás en un vuelo de doce horas intentando depurar algo.

*Experimentación y aprendizaje.* Cuando estás experimentando con frameworks de agentes, probando estrategias de prompts o construyendo integraciones de herramientas personalizadas, quemar créditos de API en prueba y error se siente despilfarrador. Un modelo local te deja iterar libremente.

=== Dónde Fallan los Modelos Locales

Vale la pena ser específico sobre los modos de fallo, porque "es menos capaz" es demasiado vago para ser útil.

*Razonamiento multi-archivo.* Pídele a un modelo local de 14B que trace un bug a través de cuatro archivos y un esquema de base de datos, y perderá el hilo. Podría encontrar el archivo correcto pero malinterpretar la interacción entre componentes. Esta es la brecha práctica más grande.

*Tareas de horizonte largo.* Las tareas agénticas que implican muchos pasos — leer, planificar, implementar, testear, depurar, iterar — requieren que el modelo mantenga una intención coherente a lo largo de un contexto largo. Los modelos locales tienden a desviarse. Olvidan el plan. Revisitan decisiones que ya tomaron. Se quedan atascados en bucles.

*Revisión de código matizada.* "Este código es correcto pero el enfoque es incorrecto" es un juicio que requiere comprensión profunda. Los modelos locales tienden hacia el análisis superficial — detectarán problemas de sintaxis y bugs obvios pero pasarán por alto problemas arquitectónicos.

*Orquestación compleja de herramientas.* Cuando una tarea requiere diez o más llamadas a herramientas encadenadas — leer un archivo de test, ejecutarlo, leer el error, encontrar el archivo fuente, entender el contexto, hacer un cambio, ejecutar el test de nuevo — los modelos locales tropiezan más frecuentemente en cada paso, y la tasa de error se acumula.

Nada de esto significa que los modelos locales son inútiles. Un modelo de 32B ejecutándose localmente puede manejar un rango sorprendente de tareas bien acotadas. Pero necesitas acotar las tareas en consecuencia. Pedirle a un modelo local que haga lo que hace un modelo de frontera es prepararlo para fracasar.

== El Coste del Trabajo Agéntico

Una sola sesión de codificación agéntica puede consumir fácilmente 100.000-500.000 tokens. Esto sorprende a la gente cuando ven los números por primera vez. No porque estés chateando — porque el agente está _trabajando_.

Considera lo que pasa cuando un agente aborda una corrección de bug moderadamente compleja. Lee tres o cuatro archivos para entender el contexto (quizá 8.000 tokens de entrada). Razona sobre el problema (2.000 tokens de salida). Lee dos archivos más (4.000 tokens). Escribe una corrección (1.000 tokens). Ejecuta los tests (llamada a herramienta, 500 tokens de salida). Los tests fallan. Lee el error (1.000 tokens). Revisa la corrección (1.500 tokens). Ejecuta los tests de nuevo. Pasan. Lee el diff para verificar (1.000 tokens). Total: quizá 25.000 tokens para una corrección de bug sencilla.

Ahora considera una tarea de refactorización compleja. El agente podría leer veinte archivos, generar un plan, implementar cambios en ocho archivos, ejecutar la suite de tests cuatro veces, depurar dos regresiones y escribir tests nuevos. Eso son fácilmente 200.000 tokens. A precios de modelo de frontera, eso está entre \$3 y \$15 dependiendo del modelo y la proporción entrada/salida.

Aquí hay rangos de coste aproximados que he visto en la práctica, basados en usar modelos comerciales de frontera:

- *Corrección de bug simple o funcionalidad pequeña:* \$0.30–\$1.00
- *Funcionalidad moderada con tests:* \$2–\$5
- *Refactorización compleja multi-archivo:* \$5–\$15
- *Implementación de funcionalidad grande:* \$15–\$40+
- *Sesión de depuración exploratoria que se alarga:* \$10–\$30

Multiplica estos números por un equipo de ingenieros, cada uno ejecutando varias tareas agénticas por día, y estás mirando dinero real. ¿La factura de \$2.200 de mi amigo? Es bastante acertada para ocho ingenieros activos.

=== Estrategias para Gestionar el Coste

La solución no es dejar de usar agentes. Es ser inteligente al respecto.

*Establece presupuestos de tokens.* La mayoría de los frameworks de agentes te dejan establecer un límite máximo de tokens por tarea. Esto no es solo control de costes — también es una señal de calidad. Si un agente quema 500.000 tokens en una tarea que debería llevar 50.000, algo ha salido mal. El agente está atascado, en bucle o malinterpretando la tarea. Un presupuesto lo fuerza a fallar rápido en lugar de espiralar.

*Usa enrutamiento de modelos.* No envíes cada tarea al modelo más caro. Profundizaremos más en la siguiente sección, pero la versión corta: usa un modelo barato y rápido para exploración y lectura de código, y un modelo capaz y caro para razonamiento e implementación. Solo esto puede recortar costes un 50-70%.

*Cachea agresivamente.* Si tu framework de agentes soporta caché de prompts, actívalo. Gran parte del contexto de un agente se repite entre turnos — el mismo system prompt, el mismo contexto de proyecto, los mismos archivos leídos recientemente. El caché evita reprocesar esos tokens en cada turno.

*Acota las tareas estrictamente.* Una tarea bien acotada ("arregla el bug de zona horaria en `billing/invoice.py`, el test está en `tests/test_invoice.py`") es más barata que una vaga ("arregla los bugs de facturación"). Acotar no es solo buena ingeniería — es control de costes. El agente lee menos archivos, hace menos llamadas exploratorias a herramientas y converge más rápido.

*Revisa tus fallos.* Cuando una tarea falla o consume demasiados tokens, averigua por qué. ¿El prompt era vago? ¿Al agente le faltaba contexto que necesitaba? ¿El modelo no era lo suficientemente capaz para la tarea? Cada fallo es una oportunidad de ajuste.

=== Gestionando Costes en Todo el Equipo

El control de costes individual es una cosa. Gestionar el gasto en un equipo de ocho o doce ingenieros, cada uno ejecutando agentes todo el día, es un problema diferente. Es la diferencia entre vigilar tu propia dieta y dirigir una cocina de restaurante.

*Presupuestos por ingeniero.* Establece un presupuesto mensual de tokens por ingeniero — no para restringir, sino para hacer visible los costes. Cuando todos pueden ver su propio gasto, el comportamiento cambia naturalmente. La gente empieza a acotar tareas con más cuidado, a elegir el modelo adecuado para el trabajo, a matar sesiones descontroladas antes. Un punto de partida razonable: \$200-400 por mes por ingeniero para un equipo que usa agentes activamente. Algunos ingenieros consistentemente vendrán por debajo del presupuesto. Otros tendrán picos durante semanas de depuración intensa. Eso está bien — el punto es la conciencia, no la imposición.

*Panel y visibilidad.* No puedes gestionar lo que no puedes ver. Rastrea el gasto por ingeniero, por proyecto, por tipo de tarea. La mayoría de los proveedores de API te dan desgloses de uso por API key, y si asignas keys por ingeniero o por proyecto, los datos ya están ahí. Canalízalo a un panel que el equipo pueda ver — incluso una hoja de cálculo compartida funciona para empezar. El ingeniero que descubre que quemó \$80 en una sola sesión de depuración naturalmente empezará a acotar tareas con más cuidado la próxima vez. No necesitas tener una conversación al respecto. El número habla solo.

*Alertas y cortacircuitos.* Establece alertas al 50% y 80% del presupuesto mensual para que nadie se lleve una sorpresa. Más importante, establece un límite duro de tokens por sesión como cortacircuito. Si una sola sesión de agente excede 500K tokens, algo ha salido mal — el agente está en bucle, la tarea es demasiado vaga o el modelo está luchando con algo más allá de su capacidad. Mátalo e investiga. Esto es lo que previene el escenario de "factura sorpresa de \$2.200" del inicio de este capítulo. No necesitas detectar cada sesión desbocada manualmente. Los límites automatizados hacen el trabajo.

*La conversación del ROI.* En algún momento, alguien en dirección preguntará por qué la factura de API tiene cinco cifras. Necesitas los números listos. Enmárcalo así: un ingeniero senior cuesta \$150K al año con todo incluido. Si los agentes lo hacen un 30% más productivo, eso son \$45K de valor. Los costes de agentes son \$3-4K por año por ingeniero. El ROI es aproximadamente 10x. Incluso si eres conservador — digamos 15% de ganancia de productividad en lugar de 30% — los números siguen funcionando cómodamente. La parte más difícil es medir esa ganancia de productividad con precisión. Probablemente no puedas, no con rigor científico. Pero puedes rastrear señales concretas: tiempo hasta fusionar PRs, número de tareas completadas por sprint, reducción en cambios de contexto. Combina esas métricas con los datos de coste y tienes una historia con la que finanzas puede trabajar.

*El coste como señal de calidad.* Alto consumo de tokens en una tarea no es solo caro — es una señal de que algo salió mal. La tarea estaba mal acotada, el contexto era insuficiente o el modelo no era lo suficientemente capaz para el trabajo. Empieza a rastrear coste por tipo de tarea a lo largo del tiempo. Si los costes de una categoría particular tienden al alza, investiga — tus prompts pueden haberse desviado, o el código base se ha vuelto lo suficientemente complejo como para necesitar un enfoque diferente. Si los costes tienden a la baja, eso es tu equipo mejorando en ingeniería agéntica. Están escribiendo prompts más ajustados, eligiendo mejores modelos y acotando tareas más efectivamente. Los datos de coste, bien usados, se convierten en un espejo de la habilidad del equipo.

== Privacidad y Cumplimiento

Parte del código genuinamente no puede salir del edificio. Esto no es paranoia — es la ley.

Los contratistas gubernamentales que trabajan en proyectos clasificados o controlados por exportación no pueden enviar código fuente a APIs de terceros, punto. Los requisitos de residencia de datos no son sugerencias. Vienen con sanciones penales.

Las empresas de salud que manejan datos de pacientes están sujetas a HIPAA, GDPR o regulaciones equivalentes. Si tu código toca registros de pacientes — incluso fixtures de test con datos falsos realistas que un oficial de cumplimiento podría cuestionar — necesitas pensar cuidadosamente sobre qué sale por el cable.

Las instituciones financieras tienen su propio laberinto de regulaciones. Cumplimiento SOX, PCI-DSS, requisitos de auditoría interna — los detalles varían, pero el tema es consistente: los datos se quedan dentro de límites controlados.

Y luego está el simple secreto competitivo. Tus algoritmos propietarios, tu salsa secreta, tu ventaja competitiva — enviar eso a los servidores de otra persona requiere confiar en que no entrenarán con ello, no lo registrarán, no serán vulnerados. La mayoría de los proveedores de API comerciales ofrecen garantías contractuales sólidas sobre esto. Pero "garantías contractuales sólidas" e "imposible de vulnerar" son cosas diferentes, y algunos equipos de seguridad no están dispuestos a aceptar la brecha.

Para todos estos casos, los modelos locales no son un lujo. Son la única opción.

El compromiso es real: estás aceptando capacidad reducida del modelo a cambio de control absoluto de los datos. Un modelo local de 32B haciendo un trabajo mediocre en tu código base clasificado es infinitamente más útil que un modelo de frontera que no tienes permiso de usar. Y para tareas enfocadas y bien acotadas — del tipo que deberías estar escribiendo de todas formas — la brecha de calidad es a menudo menor de lo que esperarías.

=== El Punto Medio: Despliegues Privados

Vale la pena señalar que hay un camino intermedio emergente. Los proveedores cloud ahora ofrecen despliegues de modelos privados — instancias dedicadas de modelos de frontera ejecutándose dentro de tu VPC, con garantías contractuales de que tus datos permanecen dentro de tu perímetro y no se usan para entrenamiento. AWS Bedrock, Azure OpenAI, Google Cloud Vertex AI todos ofrecen versiones de esto.

Estos no son baratos. Estás pagando por computación dedicada, no por infraestructura de API compartida. Pero para organizaciones grandes que necesitan capacidad de frontera y control estricto de datos, esta es cada vez más la respuesta. Obtienes calidad de modelo comercial con garantías de privacidad de modelo local — por un precio.

== Enrutamiento de Modelos en la Práctica

La verdadera pregunta no es "¿local o comercial?" Es "¿qué modelo, para qué parte del flujo de trabajo?"

Una configuración agéntica sofisticada enruta diferentes partes del flujo de trabajo a diferentes modelos. Esto no es teórico — equipos están haciendo esto hoy, y es la dirección hacia la que se mueve el ecosistema.

=== El Patrón de Enrutamiento

Piensa en lo que un agente realmente hace durante una tarea típica:

+ *Exploración* — leer archivos, buscar en el código base, entender la estructura. Esto es trabajo de alto volumen y bajo razonamiento. El modelo necesita decidir qué archivos leer y extraer información relevante, pero no está haciendo pensamiento profundo.

+ *Planificación* — analizar el problema, considerar enfoques, decidir una estrategia. Esto requiere razonamiento fuerte. Es la parte donde la calidad del modelo más importa.

+ *Implementación* — escribir los cambios de código reales. Esto requiere buena generación de código y la capacidad de seguir el plan del paso 2.

+ *Verificación* — ejecutar tests, leer errores, decidir si el trabajo está terminado. Razonamiento moderado, uso intensivo de herramientas.

+ *Iteración* — si la verificación falla, volver y ajustar. Esto requiere entender el fallo y conectarlo de vuelta con la implementación.

No todos estos pasos necesitan el mismo modelo. El paso 1 puede ser manejado por un modelo pequeño, rápido y barato — incluso uno local. Es leer archivos y reportar lo que hay en ellos. El paso 2 es donde quieres el modelo de frontera — este es el razonamiento caro que justifica el coste de API. Los pasos 3-5 a menudo pueden ser manejados por un modelo de nivel medio, ya que el pensamiento difícil ya está hecho y el modelo está ejecutando un plan.

=== Cómo Se Ve Esto

En la práctica, el enrutamiento de modelos puede ser tan simple como configurar tu framework de agentes para usar diferentes modelos para diferentes tipos de tareas:

```
# Pseudocode — the exact config depends on your framework
exploration_model: "local/qwen-14b"       # Free, fast, good enough for reading
reasoning_model: "claude-sonnet"           # Frontier reasoning for planning
implementation_model: "claude-haiku"       # Fast, cheap, follows plans well
```

O puede ser dinámico — un clasificador ligero que mira el paso actual y enruta en consecuencia. Algunos frameworks están empezando a incorporar esto nativamente. Otros requieren que lo conectes tú mismo.

La economía es convincente. Si el 60% de los tokens de un agente se gastan en exploración y tareas simples, y enrutas esas a un modelo que es 10x más barato, has recortado tu coste total más de la mitad sin ninguna reducción de calidad en las partes que importan.

=== Enrutamiento para Privacidad

El enrutamiento de modelos también resuelve el problema de privacidad de forma más elegante que un enfoque de todo o nada.

Digamos que estás construyendo una aplicación de salud. Los modelos de datos y la lógica de negocio tocan datos de pacientes — eso necesita quedarse local. Pero los componentes de frontend, la configuración de build, el pipeline de CI — esos no contienen datos sensibles. No hay razón por la que no puedas usar un modelo comercial de frontera para las partes no sensibles mientras enrutas el trabajo sensible a un modelo local.

Esto requiere tooling que sea consciente de los límites de sensibilidad — qué archivos pueden ir a lo externo, cuáles no. Ese tooling todavía está madurando, pero el patrón es claro. En lugar de "todo local" o "todo comercial," obtienes "local donde importa, comercial en todo lo demás."

== Empezando Sin Arruinarte

No necesitas presupuesto para empezar a aprender ingeniería agéntica. Necesitas un portátil y una tarde. Aquí hay una rampa práctica de coste cero a productividad real.

=== El Nivel Gratuito

La mayoría de los proveedores comerciales ofrecen niveles gratuitos o créditos de prueba. A principios de 2026, puedes empezar con Claude, GPT o Gemini sin introducir una tarjeta de crédito. Los niveles gratuitos tienen limitaciones de tasa y restricciones de contexto, pero son más que suficientes para aprender los fundamentos — escribe tu primer prompt agéntico, mira a un agente iterar sobre un fallo de test, familiarízate con el bucle de retroalimentación.

Combina una API key de nivel gratuito con un framework de agentes open source — el nivel gratuito de Claude Code, o Aider con su soporte de modelos gratuitos — y tienes una configuración agéntica completa a coste cero. No será rápida. No manejará trabajo complejo multi-archivo. Pero te enseñará todo lo de los capítulos dos al cinco de este libro sin gastar un céntimo.

=== El Camino Local-Primero

Si tienes un MacBook Pro con 16GB o más de RAM, puedes ejecutar modelos útiles localmente gratis, para siempre.

Instala Ollama — lleva un solo comando. Descarga un modelo — `ollama pull qwen2.5-coder:14b` toma unos minutos. Apunta un framework de agentes hacia él. Ahora tienes una configuración agéntica de codificación sin costes de API, sin límites de tasa y sin datos saliendo de tu máquina.

La experiencia no igualará a un modelo comercial de frontera. Las ventanas de contexto son más pequeñas. El razonamiento multi-archivo es más débil. El uso de herramientas es menos fiable. Pero para tareas enfocadas y bien acotadas — "escribe tests para esta función," "refactoriza esta clase para usar inyección de dependencias," "añade manejo de errores a este endpoint" — un modelo local de 14B es sorprendentemente capaz. Y como es gratis, puedes iterar sin vigilar el contador.

Un stack práctico para ingeniería agéntica de coste cero:
- *Ollama* para servir modelos (gratis, local)
- *Qwen 2.5 Coder 14B* o *DeepSeek Coder V2* para tareas de código
- *Aider* o *Claude Code* (con soporte de modelo local) como framework de agentes
- Un proyecto con suite de tests (el agente necesita retroalimentación)

Eso es todo. Sin suscripción. Sin API key. Sin computación cloud. Llegarás al techo eventualmente — una tarea que necesita una ventana de contexto más grande, o razonamiento multi-archivo que el modelo local no puede manejar. Ahí es cuando recurres a un modelo comercial. Pero la configuración gratuita te llevará más lejos de lo que esperas.

=== El Punto Óptimo: \$20/Mes

Cuando estés listo para gastar dinero, la configuración más rentable que he encontrado es una combinación de modelos locales para exploración y una suscripción comercial para razonamiento.

La mayoría de los proveedores comerciales ofrecen un plan de desarrollador en el rango de \$20/mes que incluye una asignación generosa de tokens. Usa esto para las tareas que realmente necesitan capacidad de frontera — depuración compleja, refactorización multi-archivo, planificación arquitectónica. Usa tu modelo local para todo lo demás — leer código, generar boilerplate, escribir mensajes de commit, pasar por iteraciones de tests.

Este enfoque híbrido típicamente cubre el 80-90% del trabajo agéntico de un desarrollador solo. El modelo local maneja las tareas de alto volumen y bajo razonamiento. El modelo comercial maneja los momentos que necesitan inteligencia genuina. Tu factura mensual se mantiene predecible, y no estás eligiendo entre calidad y coste — estás usando cada uno donde tiene sentido.

=== Escalando Intencionalmente

El error es empezar con la opción más cara y optimizar después. Empieza gratis. Aprende los flujos de trabajo. Entiende dónde realmente importa la calidad del modelo y dónde "suficientemente bueno" es suficientemente bueno. Luego gasta dinero en las brechas específicas que las herramientas gratuitas no pueden llenar.

Para cuando estés gastando dinero real en llamadas a API, sabrás exactamente por qué estás pagando — y más importante, por qué _no_ estás pagando. Ese conocimiento vale más que cualquier cantidad de créditos.

== El Panorama Está Cambiando

Dentro de seis meses, los detalles de este capítulo estarán desactualizados. Los números de coste cambiarán. Las brechas de capacidad se estrecharán. Un nuevo modelo saldrá que reordenará las clasificaciones. Esta es la única predicción que haré con confianza.

Lo que no cambiará es el marco para pensar sobre ello. Seguirás necesitando evaluar modelos a lo largo de los mismos ejes: capacidad, coste, privacidad, velocidad y fiabilidad. Seguirás necesitando ajustar el modelo a la tarea en lugar de elegir uno y usarlo para todo. Seguirás necesitando mantenerte flexible.

Los ingenieros que veo haciendo el mejor trabajo no son leales a ningún modelo o enfoque de despliegue particular. Son pragmáticos. Usan el modelo comercial de frontera cuando la tarea lo exige, un modelo de nivel medio cuando es suficientemente bueno, y un modelo local cuando la privacidad o el coste lo requieren. Miden lo que funciona. Cambian cuando algo mejor aparece.

No te pongas religioso con esto. El modelo es una herramienta. La habilidad está en saber por cuál herramienta alcanzar — y esa habilidad se transfiere independientemente de qué modelos existan dentro de seis meses.
