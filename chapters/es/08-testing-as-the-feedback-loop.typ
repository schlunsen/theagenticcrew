= Los Tests Como Bucle de Retroalimentación

Dos códigos base. Mismo agente. Misma tarea: "Añade un limitador de tasa a la API que devuelva 429 después de 100 peticiones por minuto por usuario."

En el primer código base, no hay tests. El agente lee los handlers de rutas, elige un punto de inserción de middleware, escribe la lógica de limitación de tasa y... se detiene. No tiene forma de saber si funcionó. No puede arrancar el servidor y enviar 101 peticiones para ver qué pasa. No puede comprobar si los endpoints existentes siguen respondiendo correctamente. Produce un diff, dice "He añadido limitación de tasa" y espera lo mejor. Tú revisas el código, lo miras con los ojos entrecerrados, piensas que parece razonable, lo fusionas y descubres en producción tres días después que el middleware se montó en el orden equivocado y nunca se ejecutó. Todas las peticiones pasaban. El limitador de tasa era decoración.

En el segundo código base, hay una suite de tests. El agente escribe el middleware de limitación de tasa, luego ejecuta los tests. Dos tests existentes fallan — un test de health check que no esperaba headers de middleware, y un test de autenticación donde el setup del test hacía 150 peticiones rápidas y ahora se ve limitado. El agente lee los fallos, ajusta el middleware para saltar el endpoint de health, actualiza la fixture del test para reiniciar el contador de tasa entre tests, y ejecuta de nuevo. Verde. Luego escribe tres tests nuevos: uno que verifica que la petición 101 devuelve 429, uno que verifica que el contador se reinicia después de un minuto, y uno que verifica que diferentes usuarios tienen límites independientes. Todos pasan.

Mismo agente. Misma tarea. Resultados como la noche y el día. La diferencia fue la suite de tests.

En el desarrollo tradicional, los tests verifican que tu código funciona. En la ingeniería agéntica, los tests hacen algo más fundamental: le dicen al agente si tuvo éxito. Esto cambia todo sobre cómo piensas en los tests.

Hay algo inquietante en esto al principio. Tu suite de tests — lo que escribiste para verificar _tu_ código — se convierte en la especificación contra la que un agente implementa. Los tests sobre los que sudaste ya no son solo aseguramiento de calidad. Son la definición de lo que significa "correcto". Es una sensación extraña: tu esfuerzo pasado convirtiéndose en la base de un flujo de trabajo que no existía cuando lo escribiste. Pero también es, si lo permites, profundamente reconfortante. ¿Todas esas horas escribiendo tests exhaustivos? No eran solo buena práctica. Eran _inversión_ — y los retornos están llegando ahora.

== Los Ojos del Agente

Un agente no puede mirar una interfaz de usuario y saber si se ve bien. No puede sentir si una respuesta de API es "suficientemente rápida." No puede intuir si una refactorización preservó el comportamiento sutil del que dependen los usuarios. Lo que _sí puede_ hacer es ejecutar tu suite de tests y leer los resultados.

Los tests se convierten en el mecanismo principal de retroalimentación del agente. Verde significa "sigue adelante." Rojo significa "intenta de nuevo." Sin tests significa que el agente vuela a ciegas — adivinando si sus cambios funcionan, sin forma de verificar.

Por eso los códigos base sin tests son difíciles de trabajar agénticamente. No es solo un problema de calidad — es un problema de información. Sin tests, el agente no tiene señal. Es como pedir a alguien que cuelgue un cuadro con los ojos vendados. Podría acertar, pero no apostarías por ello.

Y la calidad de esa señal importa enormemente. Un test que dice `FAIL: expected 429, got 200` es accionable. El agente sabe exactamente qué salió mal y puede razonar sobre por qué. Un test que dice `FAIL: assertion error` sin contexto apenas es mejor que el silencio. La claridad de tu salida de tests es la claridad de la visión del agente.

== TDD Adquiere Nuevo Significado

El Desarrollo Guiado por Tests siempre fue una buena idea. Con agentes, se convierte en un superpoder.

El flujo de trabajo es simple: escribe el test primero, luego dáselo al agente y di "haz que pase esto." El agente ahora tiene un criterio de éxito claro e inequívoco. Puede iterar — escribir código, ejecutar el test, leer el fallo, ajustar, repetir — en un bucle cerrado que toma segundos por ciclo.

Esto es lo que parece concretamente. Digamos que necesitas una función que parsee una cadena de duración como `"2h30m"` en segundos totales. Escribes el test:

```python
def test_parse_duration():
    assert parse_duration("1h") == 3600
    assert parse_duration("30m") == 1800
    assert parse_duration("2h30m") == 9000
    assert parse_duration("45s") == 45
    assert parse_duration("1h15m30s") == 4530
    assert parse_duration("") == 0
    with pytest.raises(ValueError):
        parse_duration("abc")
```

Luego le dices al agente: "Haz que `test_parse_duration` pase."

El primer intento del agente podría manejar horas y minutos pero olvidar los segundos. Ejecuta el test: `FAIL: parse_duration("45s") returned 0, expected 45`. Señal clara. Añade el manejo de segundos, ejecuta de nuevo: `FAIL: parse_duration("abc") did not raise ValueError`. Otra señal clara. Añade la validación de entrada. Verde. Hecho.

Cada ciclo tomó segundos. El agente nunca necesitó preguntarte qué significa "correcto" — los tests lo definieron. Y porque el test cubre casos límite que pensaste de antemano, la implementación los maneja desde el principio, no como bugs descubiertos después.

Esto es fundamentalmente diferente de pedirle a un agente "construye un parser de duración." Eso es vago. ¿Qué formato? ¿Qué casos límite? ¿Qué debería pasar con entrada inválida? Pero "haz que estas siete aserciones pasen" es preciso. El agente sabe exactamente cómo se ve el éxito, y puede medir su propio progreso hacia él.

El ingeniero agéntico aprende a expresar intención a través de tests. Cada test es un contrato. Cada aserción es un requisito. Cuanto mejores sean tus tests, mejor rendirán tus agentes. Dejas de pensar en escribir tests como overhead y empiezas a pensarlo como _programar al agente_ — estás especificando comportamiento en el lenguaje más inequívoco disponible: código que pasa o no.

== Qué Hace un Buen Test Agéntico

No todos los tests son igualmente útiles para agentes. Los tests que sirven bien a los humanos durante el desarrollo podrían activamente engañar a un agente. Un buen test agéntico tiene propiedades específicas, y vale la pena ser deliberado al respecto.

*Rápido.* Un agente itera en un bucle. Si cada ciclo toma diez minutos, el agente prueba seis enfoques por hora. Si cada ciclo toma diez segundos, prueba 360. La velocidad no es solo conveniencia — es la diferencia entre un agente que converge a una solución y uno que agota el tiempo. Ejecuta la suite completa si es rápida; ejecuta solo los tests relevantes si no lo es. De cualquier forma, el bucle de retroalimentación necesita ser ajustado.

*Determinista.* Un test inestable es peor que ningún test para un agente. Cuando un test falla aleatoriamente, un humano se encoge de hombros y lo vuelve a ejecutar. Un agente ve un fallo e intenta arreglarlo. Cambia código que funciona para perseguir un fantasma. Luego el test inestable pasa — no porque el cambio del agente fuera correcto, sino porque las estrellas se alinearon. Ahora tienes un cambio de código inútil que parece una corrección pero no lo es. El agente ha sido recompensado por no hacer nada útil. Si tienes tests inestables, ponlos en cuarentena antes de dar al agente acceso a la suite.

*Aislado.* Los tests que dependen del orden de ejecución, estado compartido o servicios externos crean fallos desconcertantes. El agente cambia la función A y el test B falla — no por una dependencia real, sino porque el test B depende de estado que el test A estableció. El agente pasará ciclos intentando entender una relación entre A y B que no existe en el código, solo en el harness de tests. Aísla tus tests. Cada uno debería montar su propio mundo y desmontarlo.

*Mensajes de error claros.* `AssertionError: False is not True` no le dice nada al agente. `Expected user.status to be 'active' after calling activate(), but got 'pending'` le dice exactamente qué salió mal. Los buenos mensajes de aserción son documentación gratuita. Úsalos. Los mensajes de error personalizados en tus aserciones son la inversión más barata que puedes hacer en productividad agéntica.

*Enfocado en comportamiento, no implementación.* Un test que aserta la estructura interna de un valor de retorno se rompe cuando el agente refactoriza. Un test que aserta el _comportamiento_ — "dada esta entrada, obtengo esta salida" — sobrevive refactorizaciones y le da libertad al agente para encontrar mejores soluciones. Si tus tests restringen la implementación demasiado estrictamente, el agente no puede mejorarla.

El test de fuego: si le mostraras solo el archivo de tests a un ingeniero competente sin otro contexto, ¿podría escribir una implementación correcta? Si sí, esos tests funcionarán bien para un agente. Si no — si los tests son demasiado vagos, demasiado acoplados o demasiado inestables para servir como especificación fiable — arregla los tests antes de dárselos al agente.

== La Pregunta de la Cobertura

"¿Cuánta cobertura de tests necesito para un trabajo agéntico efectivo?"

El instinto es decir 100%. Cobertura completa. Cada línea, cada rama, cada camino. Pero eso no es práctico ni necesario. Lo que realmente necesitas es cobertura _dirigida_: suficiente para que el agente pueda verificar lo específico que está cambiando.

Piénsalo así. Si le pides a un agente que modifique el módulo de procesamiento de pagos, necesitas cobertura de tests sólida del procesamiento de pagos. No necesitas necesariamente cobertura completa del sistema de plantillas de email, el panel de administración o la funcionalidad de exportación a CSV. El agente necesita tests alrededor del código que está tocando, más suficientes tests de integración para confirmar que no ha roto las interfaces entre sistemas.

Esto lleva a una estrategia práctica: _cubre las rutas calientes primero._ Mira dónde realmente apuntarás a los agentes. Tu lógica de negocio principal. Tus contratos de API. Tus transformaciones de datos. Estas son las áreas que necesitan tests rigurosos — no por objetivos abstractos de calidad, sino porque estas son las áreas donde los agentes trabajarán.

Las métricas de cobertura incluso pueden ser engañosas. Un código base con 90% de cobertura de líneas pero sin tests en el flujo de pagos es peor, para propósitos agénticos, que un código base con 40% de cobertura que testea exhaustivamente pagos, autenticación y la capa de API. El agente no necesita una insignia de cobertura. Necesita tests donde ocurre el trabajo.

Dicho esto, los tests de integración tienen un valor desproporcionado. Un test unitario le dice al agente "esta función funciona aisladamente." Un test de integración le dice "estos componentes funcionan juntos." Cuando un agente cambia una función, los tests unitarios detectan regresiones locales y los tests de integración detectan efectos cascada. Ambos importan, pero si empiezas desde cero, los tests de integración te dan más rendimiento por el esfuerzo porque verifican las _costuras_ — los lugares donde las cosas tienden a romperse.

Una cosa más: no olvides los tests negativos. Los tests que verifican que tu sistema _rechaza_ entrada inválida son críticos para los agentes. Sin ellos, un agente puede "simplificar" tu lógica de validación, hacer que todos los tests positivos pasen y dejarte con un sistema que acepta basura. Si tienes una regla de validación, testea ambos lados.

== La Velocidad Importa

Cuando un agente itera en un bucle de tests, la velocidad de tu suite de tests afecta directamente la productividad. Una suite de tests que tarda diez minutos en ejecutarse significa que el agente espera diez minutos entre intentos. Una suite que tarda diez segundos significa que el agente puede probar docenas de enfoques en el tiempo que te lleva ir a por un café.

Esto crea un fuerte incentivo para:
- Mantener los tests unitarios rápidos y aislados
- Separar tests rápidos de tests de integración lentos
- Usar modos de observación que re-ejecuten solo los tests afectados
- Invertir en infraestructura de tests de la misma forma que inviertes en CI

Los tests rápidos ya no son solo una mejora de la experiencia del desarrollador. Son infraestructura de agentes.

En la práctica, esto significa que quieres una estrategia de tests por capas. Una suite unitaria rápida que se ejecuta en segundos — el bucle interno del agente. Una suite de integración media que se ejecuta en un minuto — el agente la ejecuta antes de dar la tarea por terminada. Y una suite end-to-end lenta que se ejecuta en CI — la verificación final antes del merge.

Dile a tus agentes qué suite usar. "Ejecuta `pytest tests/unit` después de cada cambio. Ejecuta `pytest tests/integration` cuando creas que has terminado." Esto mantiene el bucle interno rápido mientras sigue detectando problemas de integración antes de que lleguen a ti.

== Tests Más Allá del Código

Los agentes no solo escriben código de aplicación. Escriben configuraciones de infraestructura, scripts de despliegue, documentación y más. Cada uno de estos puede — y debería — tener alguna forma de verificación automatizada.

*La comprobación de tipos* es el bucle de retroalimentación más rápido que puedes darle a un agente. Un error de tipos aparece en milisegundos, antes de que se ejecute un solo test. En lenguajes tipados, o en Python con mypy, o en JavaScript con TypeScript, la comprobación de tipos detecta una enorme clase de errores instantáneamente. El agente renombra un campo y el comprobador de tipos marca inmediatamente cada lugar que referencia el nombre antiguo. Ese es un bucle de retroalimentación más ajustado que cualquier suite de tests puede proporcionar.

*Linting y formateo* detectan otra clase de problemas. Una regla de ESLint mal configurada podría parecer una molestia menor, pero para un agente, un fallo de lint es una señal inequívoca. "Tu import no se usa." "Esta variable está declarada pero nunca se lee." Estas son correcciones pequeñas que se suman a código más limpio con cero esfuerzo de tu parte.

*La validación de esquemas* para contratos de API asegura que los cambios del agente no rompan la interfaz entre servicios. Si tienes especificaciones OpenAPI, definiciones de JSON Schema o definiciones de tipos GraphQL, valida contra ellas. Un agente que cambia un payload de respuesta aprenderá inmediatamente que violó el contrato, en lugar de descubrir la rotura cuando un servicio downstream se cuelgue en staging.

*Los tests de contrato* entre servicios llevan esto más lejos. Si el servicio A depende de la API del servicio B, un test de contrato verifica que B sigue satisfaciendo lo que A espera — sin necesidad de ejecutar ambos servicios simultáneamente. Cuando un agente modifica el servicio B, los tests de contrato detectan cambios que rompen la compatibilidad que los tests unitarios dentro de B pasarían por alto completamente.

*La validación de archivos de configuración* es criminalmente infrautilizada. Un lint de YAML en tus manifiestos de Kubernetes. Un terraform validate en tu código de infraestructura. Un docker-compose config check. Estos toman segundos en ejecutarse y detectan errores que de otra forma aparecerían como fallos misteriosos durante el despliegue. Cada comprobación automatizada que añades es otra señal que el agente puede usar para autocorregirse.

El ingeniero agéntico piensa en la testabilidad de forma amplia: no "¿devuelve mi función el valor correcto?" sino "¿puedo verificar automáticamente que este cambio es correcto?"

== Cuando los Tests Engañan

Una mala suite de tests es peor que ninguna suite de tests. Esto es incómodo pero vale la pena reflexionar sobre ello.

Sin tests, el agente sabe que vuela a ciegas. Será conservador. Te dirá que no puede verificar sus cambios. Revisarás con más cuidado. La falta de señal es al menos una falta honesta de señal.

Con malos tests, el agente vuela con falsa confianza. Hace un cambio, los tests pasan y reporta éxito. Tú ves verde y relajas tu revisión. Pero los tests realmente no estaban verificando lo correcto.

Esto pasa de varias formas predecibles.

*Tests que testean el mock, no el código.* Cuando tu test hace mock de la base de datos, el cliente HTTP, el sistema de archivos y la cola — y luego aserta que la función mockeada fue llamada con los argumentos correctos — estás testeando tu setup de tests, no la lógica de tu aplicación. Un agente puede hacer que el código "real" haga absolutamente cualquier cosa y el test seguirá pasando, mientras se cumplan las expectativas del mock. Estos tests proporcionan una señal verde que no significa nada.

*Tests demasiado laxos.* `assert response.status_code == 200` te dice que el endpoint no falló. No te dice que la respuesta contiene los datos correctos. Un agente podría devolver un cuerpo vacío, los datos del usuario equivocado, o una respuesta que le falta la mitad de sus campos, y esa aserción seguiría pasando. La especificidad en las aserciones es especificidad en la señal de retroalimentación.

*Tests que duplican la implementación.* Si tu test esencialmente reimplementa la función bajo test y comprueba que ambas devuelven lo mismo, no verifica nada. El agente puede cambiar la implementación y el test juntos — y lo hará, si piensa que deberían coincidir. Terminas con código y tests que concuerdan entre sí pero no con la realidad.

Esto conecta directamente con el patrón de "Respuesta Equivocada con Confianza" del capítulo de historias de guerra. ¿El agente que añadió un `time.Sleep(500)` para arreglar una condición de carrera? Los tests pasaron. Pasaron porque el entorno de tests tenía baja concurrencia donde 500ms siempre era suficiente. Los tests eran _técnicamente correctos_ pero _prácticamente engañosos_. Dieron una señal verde para una corrección que fallaría bajo carga de producción.

La defensa es directa pero requiere disciplina. Revisa tus tests con el mismo rigor con el que revisas tu código. Pregunta: "Si el agente introdujera un bug sutil, ¿lo detectaría este test?" Si la respuesta es no, el test es mobiliario — hace que la habitación parezca ocupada pero realmente no hace nada.

== El Ciclo Virtuoso

Cuando juntas todo esto — buenos tests, retroalimentación rápida, entornos en sandbox y un agente en el bucle — algo hace clic.

El agente toma una tarea. Lee los tests existentes para entender el comportamiento esperado. Hace un cambio. Ejecuta la suite de tests rápida — diez segundos. Dos fallos. Lee los mensajes de error, entiende el problema, ajusta. Ejecuta de nuevo. Verde. Escribe tests nuevos para el nuevo comportamiento. Ejecuta la suite completa de integración — un minuto. Todo verde. Hace commit con un mensaje descriptivo y te entrega un diff que sabes que pasa cada comprobación automatizada de tu sistema.

Revisas un diff que sabes que pasa todos los tests. Tu trabajo pasa de "comprobar si esto funciona" a "comprobar si este es el enfoque correcto." Ese es un uso mucho mejor de tu tiempo, y un uso mucho mejor de tu experiencia. Ya no eres un ejecutor humano de tests. Eres un arquitecto revisando diseños.

Y aquí está el efecto acumulativo. Cada vez que un agente trabaja en tu código base y la suite de tests le ayuda a tener éxito, has demostrado el valor de esos tests. Cada vez que un test faltante causa un bug, sientes el dolor inmediatamente — y añades el test. Tu suite de tests crece exactamente en los lugares que importan, guiada por retroalimentación real de trabajo agéntico real.

Este es el ciclo virtuoso de la ingeniería agéntica: mejores tests llevan a agentes más autónomos, que llevan a iteración más rápida, que te da más tiempo para escribir mejores tests. Cada vuelta del ciclo hace la siguiente más rápida.

Los ingenieros que sacarán más provecho de las herramientas agénticas no son los que tienen los prompts más ingeniosos ni los modelos más potentes. Son los que tienen las mejores suites de tests. Un código base bien testeado es un multiplicador de fuerza que se acumula con cada tarea que le das a un agente. Un código base sin tests es un impuesto que hace cada tarea más lenta y arriesgada.

Si te llevas una sola cosa de este capítulo, que sea esta: antes de optimizar tus prompts, antes de experimentar con nuevos modelos, antes de construir orquestación elaborada — ve a escribir tests. Escríbelos para el código que tus agentes tocarán. Hazlos rápidos, deterministas, aislados y específicos. Esa inversión rendirá más que cualquier otra cosa en este libro.

Tu suite de tests no es overhead. Es la base sobre la que todo lo demás se construye.
