= Lo Que Aprendí Construyendo Mi Propio Tooling Agéntico

Esto es lo que nadie te dice cuando empiezas a trabajar con agentes de IA: lo difícil no es conseguir que un agente haga algo útil. Lo difícil es gestionar el caos cuando tienes tres ejecutándose a la vez. Cuatro ventanas de terminal abiertas, agentes trabajando en tareas diferentes, uno se ha colgado silenciosamente hace veinte minutos y no te has dado cuenta. Los agentes están bien. _Tú_ eres el cuello de botella.

Pasé cien horas construyendo mi propia herramienta para resolver esto — Clovr Code Terminal, un panel de control basado en navegador para ejecutar múltiples sesiones de agentes. Esas horas me enseñaron más sobre ingeniería agéntica de lo que cualquier cantidad de lectura podría haberme enseñado. Este capítulo destila los principios que emergieron. CCT es el caso de estudio, no el objetivo.

== El Trabajo Agéntico Es Inherentemente Paralelo

Los flujos de trabajo con un solo agente son una muleta. No siempre — a veces un agente en una tarea es exactamente lo correcto. Pero el verdadero poder de la ingeniería agéntica aparece cuando ejecutas múltiples agentes en paralelo, cada uno enfocado en una pieza diferente del problema.

Esto es contraintuitivo. La mayoría venimos de un mundo donde _nosotros_ somos el único hilo de ejecución. Escribir código, luego tests, luego documentación. Secuencial. Los agentes rompen ese modelo — todos pueden trabajar simultáneamente, pero solo si puedes llevar la cuenta de ellos.

Si tu flujo de trabajo no te da visibilidad sobre el trabajo en paralelo, o bien serializarás todo (desperdiciando el potencial de los agentes) o ejecutarás cosas en paralelo y perderás el hilo (desperdiciando tu propio tiempo limpiando el desastre). Sea cual sea la herramienta que uses — paneles de tmux, múltiples proyectos de Cursor, incluso un post-it rastreando qué está ejecutándose dónde — resuelve el problema de visibilidad primero. Los agentes no se van a gestionar solos.

#figure(
  image("../../assets/cct-dashboard.png", width: 100%),
  caption: [Panel principal de CCT — múltiples sesiones de agentes ejecutándose en paralelo, con estado en tiempo real y seguimiento de costes.],
)

== Los Agentes Necesitan Paso de Contexto Estructurado

Tienes un agente que acaba de terminar de planificar una funcionalidad. Conoce los requisitos, la estructura de archivos, los casos límite. Ahora quieres que un agente diferente implemente lo que se planificó. ¿Cómo transfieres ese conocimiento?

El enfoque ingenuo es copiar y pegar — tomar el plan de la salida del agente uno, pegarlo en el prompt del agente dos. Esto funciona, apenas. Pierdes matices, olvidas cosas, y te conviertes en un portapapeles humano, que es exactamente el tipo de trabajo de bajo valor que se supone que los agentes deben eliminar.

El mejor enfoque son los traspasos estructurados: un formato definido para pasar contexto de un agente a otro. Escribe una plantilla de traspaso. Haz que los agentes resuman su trabajo en un formato consistente antes de terminar. Alimenta ese resumen al siguiente agente. Esta es la metáfora de la "tripulación" hecha operativa — agentes colaborando no a través de memoria compartida, sino a través de comunicación estructurada.

He usado este patrón para encadenar tres agentes en secuencia: uno para planificar, uno para diseñar, uno para implementar. Cada uno lee el traspaso del agente anterior. El resultado es consistentemente mejor que un solo agente intentando hacer todo, porque cada agente trabaja dentro de un contexto enfocado en lugar de uno extenso.

== La Confianza Debe Ser Configurable

Cada llamada a herramienta que un agente hace — cada comando de bash, cada escritura de archivo, cada petición de red — es una decisión de confianza. Ejecutar agentes sin barandillas es rápido y aterrador. Uno de los míos ejecutó `rm -rf` en un directorio que me importaba. (Estaba en un worktree, así que no hubo daño real. Lección aprendida de todas formas.) El extremo opuesto — aprobar cada operación manualmente — hace inútiles a los agentes. Pasas todo tu tiempo haciendo clic en "permitir" en `git status` y `ls`.

La verdadera respuesta es un espectro de confianza configurable. Reglas de siempre-permitir para comandos seguros, aprobación manual para operaciones sensibles, y modo completamente automático para prototipado rápido en entornos desechables. Con el tiempo, tu configuración de permisos se convierte en un documento vivo de tu relación de confianza con los agentes.

Cualquier flujo de trabajo agéntico necesita una forma de ajustar la confianza. Si tu herramienta solo ofrece "permitir todo" o "aprobar todo", oscilarás entre ansiedad y frustración. La capa de permisos no es overhead — es lo que hace posible el trabajo agéntico sostenido.

== El Control de Versiones Es Infraestructura de Agentes

Cada vez que un agente hacía un desastre, mi primer instinto era `git diff` y `git stash`. El control de versiones ya era mi red de seguridad. Hacerlo de primera clase en el tooling solo formalizó lo que estaba haciendo manualmente.

El principio es simple: _nunca dejes que un agente trabaje en tu rama principal_. Dale una rama. Dale un worktree. Dale un contenedor. Sea cual sea el mecanismo de aislamiento que prefieras, úsalo. Los buenos resultados se fusionan. Los malos se eliminan. Sin desorden, sin riesgo, sin drama.

#figure(
  image("../../assets/cct-new-session.png", width: 80%),
  caption: [Creando una nueva sesión con aislamiento de worktree, modo de permisos y selección de modelo — cada principio de este libro incorporado en un solo diálogo.],
)

Si estás usando Claude Code en un terminal, un simple script de shell que crea un worktree e inicia una sesión te da el ochenta por ciento de este beneficio. El tooling no importa. El aislamiento sí.

== No Necesitas Construir el Tuyo Propio

Quiero ser directo: _no construyas tu propio IDE agéntico._ Lo hice porque tenía necesidades específicas que rascar y porque construirlo me enseñó cosas sobre las que quería escribir. Pero podría haber sido productivo con Claude Code en un terminal y unos buenos scripts de shell.

Los principios de este capítulo — visibilidad paralela, traspasos estructurados, confianza configurable, control de versiones como infraestructura — se pueden implementar con cualquier herramienta:

- *Visibilidad paralela:* paneles de tmux, un archivo de log simple, incluso un post-it rastreando qué se está ejecutando dónde.
- *Traspasos estructurados:* una plantilla markdown que los agentes rellenan cuando terminan. Cópiala al prompt del siguiente agente.
- *Confianza configurable:* los flags de permisos de Claude Code, `.claude/settings.json`, o simplemente ejecutar agentes en un sandbox restringido.
- *Aislamiento Git:* un script de shell de tres líneas que crea un worktree e inicia una sesión.

La herramienta no importa. El modelo mental sí.

== La Verdadera Lección

La ingeniería agéntica no se trata realmente de los agentes. Se trata de los _sistemas alrededor de los agentes_ — la visibilidad, el paso de contexto, los límites de confianza, el aislamiento, los bucles de retroalimentación. Consigue que esos estén bien y casi cualquier modelo capaz producirá buenos resultados. Consigue que estén mal y hasta el mejor modelo creará caos costoso.

El resto de este libro trata sobre esos sistemas.
