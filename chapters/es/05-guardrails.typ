= Barandillas

Darle poder a un agente sin límites no es ingeniería audaz — es negligencia. Las barandillas son lo que hace que los agentes autónomos sean _usables_ en el trabajo real. Son la diferencia entre un agente que te ayuda a entregar y uno que tumba tu entorno de staging a las 3 de la madrugada.

Y sin embargo las barandillas no son un problema resuelto. Son algo vivo — algo que afinas, pruebas y debates. Si te equivocas en una dirección, tu agente es peligroso. Si te equivocas en la otra, tu agente es inútil. El oficio está en encontrar la línea.

== El Gradiente de Confianza

No toda tarea merece el mismo nivel de autonomía. ¿Leer archivos? Bajo riesgo, déjalo ejecutar. ¿Escribir código en una rama de funcionalidad? Riesgo medio, revisa el diff. ¿Ejecutar migraciones de base de datos? Alto riesgo, requiere aprobación explícita.

Piénsalo como una mesa de mezclas. Cada categoría de acción tiene su propio control deslizante: lecturas de archivos, escrituras de archivos, comandos de shell, acceso a red, operaciones de git. Empujas cada control al nivel de autonomía con el que te sientes cómodo. Algunos controles permanecen bajos para siempre. Otros los subes a medida que crece la confianza.

El error que comete la mayoría es tratar el gradiente como binario — o el agente puede hacer algo o no puede. La realidad es más matizada. Un agente podría tener permitido ejecutar `npm test` sin preguntar, pero `npm install` requiere una confirmación. Ambos son comandos de shell. El perfil de riesgo es completamente diferente.

Y el gradiente cambia con el tiempo. El primer día, tu agente se ejecuta en un sandbox estricto. Cada comando de shell se aprueba. Cada escritura de archivo se revisa. Aún no sabes dónde es brillante y dónde es frágil, así que vigilas todo.

Después de una semana, emergen patrones. El agente es impecable escribiendo tests unitarios. Es sólido refactorizando. Ocasionalmente toma decisiones cuestionables sobre gestión de dependencias. Ahora tus controles reflejan eso: los tests y la refactorización se ejecutan libremente, los cambios de dependencias se revisan.

Después de un mes, has visto cien tareas completarse exitosamente. Aflojas los controles aún más. El agente hace commits a ramas de funcionalidad por su cuenta. Ejecuta la suite completa de tests sin preguntar. Después de tres meses, es como un colega de confianza — le das una tarea, revisas en una hora y miras el PR. Las barandillas siguen ahí, pero son invisibles para el 95% del trabajo rutinario.

Esta es la idea clave: _las barandillas deberían ser apenas perceptibles para el trabajo cotidiano, y absolutamente rígidas para situaciones excepcionales._ El agente debería fluir a través de sus tareas normales sin fricción, y chocar contra un muro duro en el momento en que intente algo inusual. Ese muro es donde apareces tú.

Los ingenieros que nunca ajustan los controles terminan abandonando los flujos de trabajo agénticos por completo. Los ingenieros que los empujan demasiado rápido se queman. El punto óptimo es un ajuste constante basado en evidencia.

== Alcance de Permisos

El principio es el mismo que en seguridad: mínimo privilegio. Un agente trabajando en tu frontend no necesita acceso SSH a tu servidor de base de datos. Un agente escribiendo tests unitarios no necesita tus credenciales de AWS.

Pero vale la pena detenerse a notar que las barandillas no son solo sobre _restringir_ lo que los agentes pueden hacer — son la otra cara de _equiparlos_. Cada herramienta que concedes es tanto una capacidad como una responsabilidad. El gradiente de confianza de la sección anterior trata realmente sobre calibrar cuánta recopilación autónoma de contexto y acción permites. Las barandillas y las herramientas son la misma lista, vista desde dos direcciones.

En la práctica esto significa:
- API keys con alcance limitado y tiempos de expiración
- Credenciales específicas por entorno (nunca compartas claves de producción con un agente de desarrollo)
- Acceso de solo lectura como predeterminado, acceso de escritura como excepción
- Aislamiento de red donde sea posible — si el agente no necesita internet, no le des internet

Herramientas como Claude Code ya tienen sistemas de permisos integrados — listas de permitir/denegar para comandos, controles de acceso a archivos, confirmaciones para operaciones destructivas. Úsalos. No apruebes todo ciegamente porque hacer clic en "sí" es más rápido.

Una lista de permitidos concreta podría empezar así:

```
allowed_commands:
  - git status
  - git diff
  - git log
  - npm test
  - npm run lint
  - cat
  - ls
  - find

denied_commands:
  - rm
  - git push
  - npm publish
  - curl
  - wget
  - docker
```

Esa es una configuración del primer día. Es conservadora. El agente puede leer, testear y explorar — pero no puede borrar, desplegar ni acceder a la red. Sentirás la fricción inmediatamente. El agente pedirá permiso para ejecutar `npm install` cuando necesite una dependencia. Pedirá antes de crear un archivo. Ese es el punto.

Después de una semana, lo has visto trabajar. Confías en su criterio para la creación de archivos. Añades `touch` y `mkdir` a la lista de permitidos. Después de un mes, le dejas ejecutar `npm install` sin preguntar — pero solo en el directorio del proyecto, no globalmente. Después de tres meses, le dejas hacer push a ramas de funcionalidad pero nunca a `main`.

La lista de permitidos _crece_ con tu experiencia. Es un registro de decisiones de confianza, y leer la lista de permitidos de un ingeniero te dice exactamente cuánta experiencia agéntica tiene.

== Puertas de Aprobación

Algunas acciones siempre deberían requerir un humano en el bucle. No porque el agente no pueda hacerlas, sino porque las _consecuencias_ de equivocarse son demasiado altas.

Buenos candidatos para puertas de aprobación:
- Cualquier operación que toque datos de producción
- Eliminar archivos o ramas
- Instalar nuevas dependencias
- Hacer peticiones de red a servicios externos
- Cualquier git push
- Modificar configuración de CI/CD
- Cambiar variables de entorno o secretos

El objetivo no es ralentizar al agente. El objetivo es crear puntos de control naturales donde tú, el ingeniero, puedas verificar que la trayectoria del agente sigue coincidiendo con tu intención. Un vistazo rápido a un diff lleva cinco segundos. Recuperarse de un mal despliegue lleva horas.

La mejor puerta es una que casi nunca rechazas. Si estás rechazando aprobaciones constantemente, tu agente está mal configurado o comunicándose mal — y deberías arreglar la causa raíz, no seguir haciendo clic en "no."

== Cuando Fallan las Barandillas

Fallarán. Un agente malinterpretará una restricción, encontrará una solución creativa a una limitación, o encontrará un caso límite que tus barandillas no anticiparon. Esto es normal.

He aquí un escenario real. Un ingeniero tenía `rm` y `rm -rf` en la lista de denegación — bastante sensato. El agente necesitaba deshacer algunos cambios en un conjunto de archivos. No podía borrarlos. Así que ejecutó `git checkout -- .` que _sí_ estaba en la lista de permitidos, porque hacer checkout de archivos desde git suena inofensivo. ¿El resultado? Cada cambio sin commitear en el directorio de trabajo — incluyendo el trabajo en progreso del propio ingeniero en otros archivos — fue borrado limpiamente. El agente resolvió su problema específico y creó uno mucho más grande.

La lección no es que `git checkout` debería ser denegado. Es que las barandillas son _defensa en profundidad_, no un solo muro. Necesitas múltiples capas:

- *La lista de permitidos* captura los comandos peligrosos obvios.
- *El sandbox* (un worktree, un contenedor) limita el radio de explosión.
- *El historial de commits* te permite recuperarte cuando algo se escapa.
- *Tu propia revisión* captura las cosas que ninguna regla automatizada marcaría.

Ninguna capa sola es suficiente. Un agente al que se le bloquea `rm` encontrará otra forma de borrar datos si eso es lo que cree que la tarea requiere. No está siendo malicioso — está siendo _ingenioso_. La misma creatividad que hace útiles a los agentes es lo que hace insuficientes las barandillas de una sola capa.

La respuesta no es eliminar la autonomía — es mejorar las barandillas y añadir capas. Cada fallo es una señal. Trátalo como un bug: entiende qué pasó, añade una comprobación y sigue adelante. Con el tiempo, tu configuración de barandillas se convierte en un reflejo de experiencia ganada con esfuerzo, no muy diferente de cómo un `.gitignore` crece con un proyecto.

Los mejores ingenieros agénticos no temen los errores de los agentes. Construyen sistemas donde los errores se detectan temprano, se contienen rápido y se aprende de ellos automáticamente.

== El Coste de Demasiadas Barandillas

Hay un modo de fallo que parece precaución pero no lo es. Configuras tu agente con puertas de aprobación para todo — cada escritura de archivo, cada comando de shell, cada operación de git. Quince minutos en una tarea, has hecho clic en "sí" cuarenta veces y ya no los estás leyendo.

Ese es el peligro. Los agentes demasiado restringidos producen dos resultados, ambos malos. O el ingeniero se rinde y deja de usar agentes, concluyendo que "no están listos todavía." O — peor — la fatiga de aprobación les entrena a hacer clic en "sí" de forma reflexiva. Ahora tienes barandillas que _se sienten_ seguras pero no proporcionan protección real alguna.

La habilidad está en encontrar el punto óptimo. Quieres barandillas lo suficientemente estrictas para capturar errores genuinos, y lo suficientemente flexibles para que el agente pueda _fluir_. Una buena heurística: si estás aprobando el mismo tipo de acción más de cinco veces en una sesión, probablemente debería estar en la lista de permitidos.

Otra heurística: rastrea con qué frecuencia tus aprobaciones realmente rechazan algo. Si has aprobado quinientas acciones y rechazado tres, tus barandillas son demasiado agresivas para esos tipos de acciones. Si has aprobado cincuenta y rechazado diez, están bien calibradas — esos diez rechazos son los que importan.

El objetivo es un agente que trabaje como un contratista cualificado. Aparece, hace el trabajo y consulta contigo en hitos significativos. No después de cada martillazo.

== Barandillas Específicas por Entorno

Tu portátil de desarrollo, tu servidor de staging y tu entorno de producción son tres perfiles de riesgo completamente diferentes. Tus barandillas deberían reflejar eso.

*Desarrollo local* es donde das a los agentes más libertad. El agente puede instalar paquetes, ejecutar comandos arbitrarios, modificar cualquier archivo y ejecutar tests — porque el peor caso es que hagas `git reset` y empieces de nuevo. Tu máquina local es un patio de recreo. Deja que el agente juegue.

Incluso aquí hay límites. El agente no debería tener acceso a credenciales de producción. No debería poder hacer push a `main`. No debería poder publicar paquetes. Pero dentro de los límites de "desarrollo local en una rama de funcionalidad", déjalo moverse rápido.

*Staging* aprieta los tornillos. El agente puede desplegar a staging — pero con aprobación. Puede leer logs de staging y consultar bases de datos de staging — pero no modificar datos. Puede ejecutar tests de integración contra servicios de staging — pero no reconfigurar esos servicios. Staging es donde verificas que el trabajo del agente sobrevive al contacto con un entorno real, y las barandillas reflejan las mayores implicaciones.

*Producción* es un animal completamente diferente. El consejo más honesto: tu agente de producción debería ser de solo lectura, si existe en absoluto. Déjalo consultar logs. Déjalo leer métricas. Déjalo investigar incidentes extrayendo datos. Pero en el momento en que necesite _cambiar_ algo en producción — un valor de configuración, un registro de base de datos, un servicio en ejecución — esa es una decisión humana, punto final.

Algunos equipos permiten que los agentes ejecuten runbooks pre-aprobados en producción: reiniciar un servicio, escalar réplicas, revertir a un despliegue conocido como bueno. Estas son operaciones de alcance limitado, bien testeadas con caminos claros de reversión. Eso es razonable. Pero "dejar que el agente descubra cómo arreglar el incidente de producción" no es una configuración de barandillas — es una plegaria.

El patrón es simple: cuanto más cerca estés de usuarios reales y datos reales, más estrictas se vuelven las barandillas. Tu agente local es un colaborador. Tu agente de staging es un trabajador supervisado. Tu agente de producción es un observador de solo lectura.

Configura esto una vez y se vuelve invisible. El agente ajusta su comportamiento según el entorno en el que opera. Se mueve rápido localmente, consulta en staging y no toca nada en producción. Una vez que tu equipo acuerda estos límites, rara vez necesitan revisión — y cuando la necesitan, es porque algo salió mal en producción, que es exactamente cuando quieres estar replanteándote las barandillas de todas formas.
