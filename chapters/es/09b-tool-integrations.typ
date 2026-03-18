= Ampliando el Alcance del Agente

#figure(
  image("../../assets/illustrations/ch09b-mcp-connections.jpg", width: 70%),
)

El mes pasado estaba depurando un problema en producción — 502s intermitentes en un endpoint de checkout. Los logs estaban en Datadog. La configuración relevante estaba en nuestro clúster de Kubernetes. El historial del ticket estaba en Linear. El esquema de base de datos estaba en PostgreSQL. El código estaba en mi editor.

Tenía seis pestañas del navegador abiertas, copiando y pegando entre ellas, intentando ensamblar suficiente contexto para entender el problema. El agente estaba en mi terminal, listo para ayudar, pero solo podía ver mis archivos locales. Era como tener un colega brillante encadenado a un escritorio — ansioso por ayudar, pero ciego a todo lo que estaba fuera del repositorio.

Luego configuré servidores MCP para Datadog, nuestra base de datos y Linear. La siguiente sesión de depuración fue diferente. Le dije al agente: "El endpoint de checkout está lanzando 502s intermitentes. Comprueba los logs de Datadog de la última hora, mira las tablas de base de datos relevantes y lee el ticket de Linear para contexto." El agente descargó logs, consultó el esquema, leyó el historial del ticket, correlacionó los timestamps e identificó el problema en cuatro minutos: un agotamiento del pool de conexiones causado por un timeout ausente en una llamada a un servicio downstream. No copié ni una sola cosa. No cambié ni una sola pestaña.

Eso es lo que hacen las integraciones de herramientas. Expanden el mundo del agente de "archivos en tu disco" a "cada sistema con el que trabajas."

== ¿Qué Es MCP?

El Model Context Protocol — MCP — es un estándar abierto para conectar agentes de IA a fuentes de datos y herramientas externas. Piénsalo como USB para agentes: un conector estándar que permite que cualquier agente hable con cualquier servicio, sin código de integración personalizado para cada combinación.

Antes de MCP, conectar un agente a tu base de datos significaba escribir un wrapper a medida. Conectarlo a Jira significaba otro wrapper diferente. Conectarlo a Slack, otro más. Cada framework de agentes tenía su propio sistema de plugins, su propio formato de definición de herramientas, su propia forma de manejar la autenticación. Si cambiabas de framework, reescribías todo.

MCP estandariza esto. Un servidor MCP es un pequeño programa que expone un conjunto de herramientas — funciones que el agente puede llamar — a través de un protocolo consistente. El framework del agente se conecta a cualquier servidor MCP de la misma forma. ¿Quieres darle a tu agente acceso a PostgreSQL? Ejecuta un servidor MCP de Postgres. ¿Quieres que lea tus docs de Notion? Ejecuta un servidor MCP de Notion. ¿Quieres que consulte tu stack de monitorización? Hay un servidor MCP para eso.

El agente no sabe ni le importa qué hay detrás del protocolo. Ve herramientas: "consultar la base de datos," "buscar páginas de Notion," "obtener logs de Datadog." Las llama de la misma forma que llama a cualquier otra herramienta — leer un archivo, ejecutar un comando. El servidor MCP maneja la traducción entre la solicitud del agente y la API del sistema externo.

Esto es más importante de lo que parece. Significa que el ecosistema de capacidades de los agentes crece independientemente de cualquier framework de agentes. Alguien construye un servidor MCP de Stripe, y _todos_ los agentes compatibles con MCP ahora pueden trabajar con Stripe. El efecto de red es el mismo que hizo que USB fuera ubicuo: un estándar, muchos dispositivos, todos se benefician.

== Por Qué Importa Esto para la Ingeniería

Si has leído el capítulo de contexto, sabes que un agente es tan bueno como lo que puede ver. Las integraciones de herramientas son cómo le das ojos más allá del sistema de archivos.

Considera lo que implica realmente una tarea de ingeniería típica:

- El *código* vive en tu repositorio.
- El *informe de bug* vive en Jira, Linear o GitHub Issues.
- Los *logs de error* viven en Datadog, Sentry o CloudWatch.
- El *esquema de base de datos* vive en PostgreSQL, MySQL o MongoDB.
- La *documentación de API* vive en Notion, Confluence o una wiki.
- El *estado del despliegue* vive en tu plataforma CI/CD.
- La *especificación de diseño* vive en Figma o un Google Doc.

Un agente con acceso solo a tu repositorio está trabajando con quizá el 30% del contexto que necesita. El resto está disperso en seis sistemas diferentes, cada uno con su propia interfaz, su propia autenticación, su propio lenguaje de consulta. Pasas el día como una capa de middleware humana — copiando logs de error de Datadog, pegándolos en el contexto del agente, copiando las preguntas del agente, buscando la respuesta en Confluence, pegándola de vuelta.

Las integraciones de herramientas eliminan esa capa de middleware. El agente consulta Datadog directamente. Lee el doc de Notion por sí mismo. Comprueba el estado del despliegue sin que cambies de pestaña. Pasas de ser un portapapeles a ser un capitán — dando dirección en lugar de transportar datos.

== La Configuración Práctica

Configurar servidores MCP es más simple de lo que suena. La mayoría de los frameworks de agentes que soportan MCP — Claude Code, Cline, Continue y otros — te dejan configurar servidores en un archivo JSON. Así se ve una configuración típica:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb"
      }
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_..."
      }
    }
  }
}
```

Eso es todo. Dos servidores. Tu agente ahora puede consultar tu base de datos e interactuar con GitHub — leer issues, comprobar el estado de PRs, buscar código. Los servidores arrancan automáticamente cuando comienza la sesión del agente. Sin código que escribir. Sin plugins que instalar más allá de los paquetes del servidor MCP.

El ecosistema está creciendo rápido. A principios de 2026, hay servidores MCP mantenidos por la comunidad para:

- *Bases de datos:* PostgreSQL, MySQL, SQLite, MongoDB, Redis
- *Gestión de proyectos:* GitHub, GitLab, Linear, Jira, Notion
- *Monitorización:* Datadog, Sentry, Grafana
- *Comunicación:* Slack, Discord
- *Cloud:* AWS, GCP, Kubernetes
- *Documentación:* Confluence, Notion, Google Docs
- *APIs:* REST genérico, GraphQL, servidores basados en OpenAPI

No necesitas todos estos. Empieza con los dos o tres sistemas a los que cambias de pestaña con más frecuencia. Para la mayoría de los ingenieros, eso es una base de datos y una herramienta de gestión de proyectos. Añade más a medida que el flujo de trabajo lo exija.

== Construyendo Tu Propio Servidor MCP

Los servidores existentes cubren herramientas comunes. Pero cada equipo tiene sistemas internos — un panel de administración personalizado, una API propietaria, una herramienta de despliegue interna, un pipeline de datos a medida. Aquí es donde construir tu propio servidor MCP compensa.

Un servidor MCP es un pequeño programa que implementa el protocolo MCP y expone herramientas. El protocolo maneja la comunicación; tú escribes las herramientas. Así se ve un servidor personalizado mínimo en TypeScript:

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from
  "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "internal-deploy",
  version: "1.0.0",
});

server.tool(
  "get-deploy-status",
  "Obtener el estado de despliegue actual de un servicio",
  { service: z.string().describe("Nombre del servicio, ej. 'checkout-api'") },
  async ({ service }) => {
    const status = await fetchDeployStatus(service);
    return {
      content: [{
        type: "text",
        text: JSON.stringify(status, null, 2)
      }]
    };
  }
);

server.tool(
  "list-recent-deploys",
  "Listar despliegues recientes en todos los servicios",
  { hours: z.number().default(24).describe("Cuántas horas hacia atrás") },
  async ({ hours }) => {
    const deploys = await fetchRecentDeploys(hours);
    return {
      content: [{
        type: "text",
        text: deploys.map(d =>
          `${d.service} → ${d.version} (${d.status}) at ${d.timestamp}`
        ).join("\n")
      }]
    };
  }
);

const transport = new StdioServerTransport();
await server.connect(transport);
```

Ese es un servidor MCP funcional. Expone dos herramientas: una para comprobar el estado de despliegue de un servicio específico, otra para listar despliegues recientes. El agente ahora puede preguntar "¿cuál es el estado de despliegue de checkout-api?" y obtener una respuesta real de tus sistemas internos.

El patrón es siempre el mismo: define una herramienta con un nombre, una descripción, un esquema para las entradas y una función que hace el trabajo. La descripción importa más de lo que crees — es lo que el agente lee para decidir _cuándo_ llamar a tu herramienta. Una descripción vaga como "hace cosas de deploy" confundirá al agente sobre cuándo usarla. Una descripción precisa como "Obtener el estado de despliegue actual de un servicio, incluyendo versión, salud y timestamp del último despliegue" le da al agente exactamente la información que necesita para llamar a la herramienta correcta en el momento correcto.

La mayoría de los servidores MCP personalizados tienen menos de 200 líneas de código. Si puedes escribir un cliente de API, puedes escribir un servidor MCP. La inversión es pequeña y el beneficio es inmediato: tu agente ahora habla el idioma de tu infraestructura.

== Cómo Funciona Realmente la Llamada a Herramientas

Hemos estado hablando de herramientas como si el agente simplemente las "llamara" — como una llamada a función en tu código. Pero lo que realmente pasa bajo el capó vale la pena entender, porque explica mucho del comportamiento del agente que de otro modo parece misterioso.

Cuando envías un mensaje a un agente, el LLM no ejecuta código. Genera texto. La llamada a herramientas es una forma estructurada de esa generación de texto. Así es el ciclo:

+ *Envías un prompt.* "¿Qué tablas existen en la base de datos?"
+ *El modelo ve las herramientas disponibles.* Junto con tu mensaje, el modelo recibe una lista de cada herramienta que puede usar — sus nombres, descripciones y esquemas de entrada. Esto es parte del prompt del sistema o configuración de herramientas, inyectado por el framework del agente antes de que el modelo vea tu mensaje.
+ *El modelo decide llamar a una herramienta.* En lugar de generar una respuesta de texto, el modelo produce una llamada a herramienta estructurada: el nombre de la herramienta y los argumentos, formateados como JSON. No está "ejecutando" nada — está _solicitando_ que el framework ejecute algo.
+ *El framework ejecuta la herramienta.* El framework del agente toma esa salida estructurada, valida los argumentos contra el esquema y realmente llama a la función — consulta la base de datos, lee el archivo, llama a la API.
+ *El resultado vuelve al modelo.* La salida de la herramienta se inyecta en la conversación como un nuevo mensaje, y el modelo genera su siguiente respuesta basándose en ese resultado.
+ *Repetir.* El modelo podría llamar a otra herramienta, o podría finalmente responderte con texto. Las tareas complejas pueden implicar diez, veinte o más llamadas a herramientas en secuencia, cada una informada por los resultados de la anterior.

Este es el bucle fundamental del comportamiento agéntico. El modelo _piensa_ sobre qué hacer, _actúa_ solicitando una llamada a herramienta, _observa_ el resultado, y _piensa_ de nuevo. Es un bucle de razonamiento con efectos secundarios en el mundo real.

Entender este bucle explica varias cosas que confunden a los nuevos usuarios de agentes:

*Por qué los agentes a veces llaman a la herramienta equivocada.* El modelo elige herramientas basándose en descripciones y el contexto de la conversación actual. Si dos herramientas tienen descripciones similares, el modelo podría elegir la equivocada. Si la descripción es vaga, el modelo adivina. La selección de herramientas es una tarea de _lenguaje_ — el modelo está haciendo coincidencia de patrones entre tu solicitud y las descripciones de herramientas, no ejecutando una tabla de búsqueda.

*Por qué los agentes a veces pasan argumentos incorrectos.* El modelo genera argumentos como texto estructurado. Si el esquema no es claro sobre qué significa un parámetro, el modelo completa con su mejor estimación. Un parámetro llamado `id` sin descripción podría ser un ID de usuario, un ID de pedido o un ID de fila de base de datos. El modelo adivinará basándose en el contexto de la conversación, y a veces adivinará mal.

*Por qué los agentes a veces llaman a herramientas innecesariamente.* El modelo no tiene una función de coste para las llamadas a herramientas. No sabe que consultar la base de datos tarda 200ms o que comprobar Datadog cuesta créditos de API. Si una herramienta _podría_ ser relevante, el modelo podría llamarla — incluso cuando la respuesta ya está en el contexto. Por eso importa curar la lista de herramientas.

*Por qué los agentes mejoran con mejores descripciones.* Esto es lo más importante que interiorizar. La _única_ información del modelo sobre una herramienta es su nombre, descripción y esquema de parámetros. Mejores descripciones llevan a mejor selección de herramientas. Mejores descripciones de parámetros llevan a mejores argumentos. Esto no es una optimización menor — es la diferencia entre un agente que funciona y uno que se debate.

== Diseñando Buenas Herramientas

Si estás construyendo servidores MCP — o incluso solo configurando qué herramientas puede acceder tu agente — el diseño de herramientas importa enormemente. Una herramienta bien diseñada hace al agente más inteligente. Una mal diseñada lo confunde.

Estos son los principios que he aprendido por las malas:

*Nombra las herramientas como verbos, no sustantivos.* `get-deploy-status` es mejor que `deploy-status`. `search-logs` es mejor que `logs`. `create-ticket` es mejor que `ticket`. El verbo le dice al modelo qué _hace_ la herramienta, lo que le ayuda a decidir _cuándo_ usarla.

*Escribe descripciones para el modelo, no para humanos.* Podrías escribir un README que diga "Consulta la base de datos PostgreSQL." Para una descripción de herramienta, sé específico: "Ejecuta una consulta SQL de solo lectura contra la base de datos PostgreSQL de producción. Devuelve resultados como filas JSON. Úsala cuando necesites comprobar datos, verificar esquemas o investigar problemas relacionados con datos. No la uses para operaciones de escritura — esta conexión es de solo lectura y las escrituras fallarán." Cuanto más contexto le des al modelo sobre _cuándo_ y _cómo_ usar la herramienta, mejor rendirá.

*Describe cada parámetro.* No solo definas `{ query: z.string() }`. Define `{ query: z.string().describe("Una consulta PostgreSQL SELECT válida. No incluyas sentencias INSERT, UPDATE, DELETE o DDL — serán rechazadas por la conexión de solo lectura.") }`. La descripción es la documentación del modelo. Si no le darías a un becario una función sin docstring y esperarías un uso correcto, no lo hagas con el modelo.

*Devuelve mensajes de error útiles.* Cuando una llamada a herramienta falla, el mensaje de error vuelve al modelo como el resultado de la herramienta. Un buen mensaje de error permite al modelo autocorregirse. "Consulta fallida: la columna 'user_id' no existe. ¿Quisiste decir 'id'? Columnas disponibles en la tabla users: id, email, name, created_at" es infinitamente mejor que "Error SQL." El modelo leerá ese error, entenderá el error y reintentará con el nombre de columna correcto. Un error vago lleva a fallos repetidos o correcciones alucinadas.

*Mantén las herramientas enfocadas.* Una herramienta que hace una cosa bien es mejor que una herramienta que hace cinco cosas basándose en un parámetro `mode`. `search-logs`, `get-log-entry` y `count-log-events` son mejores que `logs-tool` con un campo `mode` que acepta "search", "get" o "count". Las herramientas enfocadas tienen descripciones más claras, esquemas más simples y menos modos de fallo. El modelo puede razonar sobre ellas independientemente.

*Limita el tamaño de la salida.* Si una herramienta puede devolver megabytes de datos, lo hará — y esos datos van a la ventana de contexto del modelo, desplazando todo lo demás. Añade paginación, truncación o summarización a tus herramientas. Devuelve las primeras 50 filas, no las 50.000 todas. Devuelve fragmentos de log, no archivos de log completos. El modelo funciona mejor con datos enfocados y relevantes que con un chorro de información.

*Incluye ejemplos en las descripciones cuando el formato de entrada no sea obvio.* Si tu herramienta espera una fecha en formato ISO 8601, dilo: "Fecha de inicio en formato ISO 8601, ej. '2026-01-15T00:00:00Z'." Si espera un formato de ID específico, muestra uno: "ID de servicio, ej. 'svc-checkout-prod'." Los ejemplos eliminan toda una clase de errores de formato.

Estos no son preferencias de estilo arbitrarias. Cada principio afecta directamente la capacidad del modelo para usar la herramienta correctamente. He visto al mismo agente pasar de una tasa de éxito del 40% al 95% en una tarea, simplemente reescribiendo las descripciones de herramientas y añadiendo documentación de parámetros. Las herramientas no cambiaron. El modelo no cambió. La _interfaz_ entre ellos mejoró.

Esta es la parte del desarrollo agéntico que más se parece al diseño de API — porque eso es exactamente lo que es. Tus herramientas son una API para el modelo. Diseñalas como diseñarías cualquier buena API: nombres claros, documentación completa, errores útiles y un principio de mínima sorpresa.

== Recursos MCP: Dando Contexto a los Agentes, No Solo Herramientas

Las herramientas permiten a los agentes _hacer_ cosas. Pero MCP también tiene un concepto llamado *recursos* — datos estructurados que los agentes pueden _leer_. La distinción importa.

Una herramienta es una acción: "consultar la base de datos," "crear un ticket," "comprobar el estado del despliegue." Un recurso es material de referencia: "el esquema de base de datos," "la documentación de API," "la hoja de ruta actual del proyecto."

Los recursos se cargan en el contexto del agente al inicio de una sesión o bajo demanda. Son el equivalente MCP de abrir un documento de referencia antes de empezar a trabajar. No le pedirías a un nuevo miembro del equipo que empezara a codificar sin mostrarle el diagrama de arquitectura. Los recursos son cómo se lo muestras al agente.

Un ejemplo práctico: construyes un servidor MCP que expone el esquema de tu base de datos como recurso. Cada sesión de agente empieza con el esquema en contexto. Cuando el agente necesita escribir una consulta, no adivina los nombres de tablas — ya los conoce. Cuando necesita añadir una columna, sabe lo que ya hay. El recurso es contexto pasivo que hace mejor cada llamada a herramienta.

La combinación de herramientas y recursos es poderosa. Los recursos le dan al agente el _mapa_. Las herramientas le dan las _manos_. Juntos, permiten al agente navegar tu infraestructura de la misma forma que tú lo haces — con tanto conocimiento como capacidad.

== Confianza y Barandillas para Agentes Conectados

Aquí es donde el capítulo de barandillas vuelve con fuerza.

Un agente con acceso a tu sistema de archivos puede borrar archivos. Un agente con acceso a tu base de datos puede borrar _datos_. Un agente con acceso a tu pipeline de despliegue puede hacer push a producción. Las apuestas escalan con cada integración que añades.

Los principios de barandillas son los mismos — mínimo privilegio, puertas de aprobación, predeterminados de solo lectura — pero la implementación necesita ser específica para cada integración.

*Bases de datos: solo lectura por defecto.* Tu servidor MCP de base de datos debería conectarse con un usuario de solo lectura. El agente puede consultar tablas, inspeccionar esquemas y entender formas de datos. No puede insertar, actualizar ni borrar. Si necesitas acceso de escritura para tareas específicas — ejecutar una migración en una base de datos de desarrollo, insertar fixtures de test — usa un servidor separado con una cadena de conexión separada, y solo habilítalo cuando la tarea lo requiera.

Una configuración segura mínima:

```json
{
  "mcpServers": {
    "db-readonly": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://readonly_user:pass@localhost/mydb"
      }
    }
  }
}
```

*Gestión de proyectos: leer y comentar, no crear.* Deja que el agente lea tickets, busque issues y añada comentarios. No le dejes crear tickets, cerrar issues ni reasignar trabajo — esas son decisiones humanas con consecuencias humanas. El ingeniero que descubra que su agente cerró automáticamente veinte tickets porque estaban "resueltos por los cambios de código" no tendrá una buena mañana.

*Monitorización: solo lectura, siempre.* El agente lee logs, consulta métricas y busca trazas. Nunca modifica alertas, dashboards ni configuraciones. Los sistemas de monitorización son la _fuente de verdad_ durante los incidentes. Un agente que puede modificar esa verdad es un agente que puede ocultar problemas.

*Herramientas de comunicación: proceder con extrema cautela.* Darle a un agente acceso a Slack significa que puede enviar mensajes en tu nombre. Piensa detenidamente si "el agente publicó en \#engineering" es algo con lo que te sientes cómodo. Si es así, limita el alcance a canales específicos. Si no, deja que el agente _borre_ mensajes que tú revisas antes de enviar.

El principio general: cada nueva integración es una nueva superficie de ataque. Añádelas deliberadamente, limita su alcance, y empieza en solo lectura. Amplía los permisos solo cuando hayas visto suficientes sesiones de solo lectura exitosas para confiar en el flujo de trabajo.

== Qué Cambia Cuando los Agentes Pueden Ver Todo

Algo sutil ocurre cuando le das a un agente acceso a tu entorno de trabajo completo — no solo código, sino logs, tickets, docs, bases de datos, monitorización. El agente deja de ser un generador de código y empieza a ser un _compañero de ingeniería_.

El flujo de trabajo de depuración cambia. En lugar de "aquí hay un error, arréglalo," puedes decir "los usuarios están reportando checkout lento. Investiga." El agente comprueba los logs, consulta la base de datos en busca de consultas lentas, lee el historial de despliegues recientes, mira la tasa de errores en monitorización y vuelve con un diagnóstico. Está haciendo lo que tú harías — solo más rápido y sin el impuesto de cambiar de pestaña.

El flujo de trabajo de planificación cambia. "Necesito añadir una funcionalidad de notificaciones. Comprueba el modelo de datos existente, mira cómo construimos el sistema de email (hay un ticket de Linear al respecto), y propón un enfoque." El agente lee el esquema, encuentra el ticket, lee el código relacionado y produce un plan que tiene en cuenta tu arquitectura existente. No está adivinando — está _informado_.

El flujo de trabajo de respuesta a incidentes cambia. "Estamos viendo tasas de error elevadas. Comprueba Datadog de los últimos treinta minutos, mira el despliegue más reciente, y dime qué cambió." El agente correlaciona logs, diffs y timestamps de despliegue, y reduce el problema a un commit específico en menos de un minuto.

El flujo de trabajo de desarrollo móvil cambia — y este todavía me sorprende. Con un servidor MCP de Xcode, el agente puede compilar tu app iOS, lanzar el simulador, navegar por las pantallas y tomar capturas de pantalla para verificar su propio trabajo. Le dices "añade una pantalla de configuración con un toggle de modo oscuro," y lo ves escribir el SwiftUI, compilar el proyecto, lanzar el simulador, navegar a la nueva pantalla, tomar una captura, notar que la alineación del toggle está mal, arreglarlo, recompilar y capturar de nuevo. Todo el ciclo — código, compilar, ejecutar, verificar visualmente, iterar — ocurre sin que toques Xcode.

Nada de esto es magia. Es lo que tú ya haces, manualmente, cada día. Las integraciones de herramientas simplemente eliminan la fricción. El agente hace la misma investigación que harías tú — solo lo hace sin los diez minutos de cambiar de pestaña, iniciar sesión, construir consultas y copiar salida.

== El Problema de la Proliferación de Integraciones

Hay un modo de fallo aquí que vale la pena nombrar: la proliferación de integraciones.

Empiezas con una conexión a la base de datos. Luego añades Datadog. Luego Notion. Luego Slack. Luego Jira. Luego tu panel de administración interno. Luego Stripe. Luego tu plataforma de analíticas. Antes de que te des cuenta, tu agente tiene acceso a _todo_, y emergen dos problemas.

Primero, *sobrecarga de contexto*. El agente ahora tiene tantas herramientas disponibles que gasta tokens decidiendo cuál usar. Para un simple cambio de código, podría intentar comprobar logs de Datadog, consultar la base de datos y leer tickets de Jira — ninguno de los cuales es relevante. Más herramientas significa más oportunidades para que el agente tome desvíos innecesarios.

Segundo, *superficie de seguridad*. Cada integración es un conjunto de credenciales que el agente puede usar. Cada una es un sistema con el que el agente puede interactuar, intencionada o accidentalmente. Cuantas más integraciones añades, más difícil es razonar sobre lo que el agente puede hacer. Pierdes la capacidad de mantener la imagen completa en tu cabeza — lo cual es irónico, dado que todo el punto de los agentes es manejar la complejidad que no puedes.

La solución es la misma que con la gestión de contexto: cura deliberadamente. No conectes todo porque puedes. Conecta los sistemas que son _relevantes para el trabajo que estás haciendo ahora_. Usa configuraciones por proyecto — tu proyecto de servicio de facturación se conecta a Stripe y la base de datos de facturación; tu proyecto de frontend se conecta a Figma y la CDN. No todos los proyectos necesitan todas las integraciones.

Una heurística útil: si no tendrías una pestaña del navegador abierta en ese sistema durante una sesión de trabajo típica en este proyecto, el agente tampoco necesita acceso a él.

== El Ecosistema Es Joven

Quiero ser honesto sobre dónde están las cosas. MCP es real, funciona y es lo más cercano que tenemos a un estándar para la integración de agentes con herramientas. Pero el ecosistema todavía está madurando.

Algunos servidores MCP son sólidos — los servidores de base de datos oficiales, el servidor de GitHub, el servidor de sistema de archivos. Otros son proyectos secundarios mantenidos por la comunidad que pueden fallar en casos límite o quedarse atrás en los cambios de API. Antes de conectar tu agente a un sistema crítico a través de un servidor MCP de terceros, lee el código fuente. Suele ser unos pocos cientos de líneas. Entiende qué hace, qué permisos solicita y qué datos envía a dónde.

El protocolo en sí todavía está evolucionando. Se están añadiendo nuevas capacidades — respuestas en streaming, flujos OAuth, interacciones de herramientas en múltiples pasos. Los servidores que configures hoy podrían necesitar actualización en seis meses. Eso está bien. El patrón no cambia, incluso cuando los detalles lo hacen.

Y algunas integraciones que _deberían_ existir todavía no existen. Si tu equipo usa una herramienta interna especializada, probablemente necesitarás construir el servidor MCP tú mismo. La buena noticia es que no es difícil — unas pocas horas como máximo para un servidor básico de solo lectura. La mejor noticia es que una vez que lo construyes, todo tu equipo se beneficia, y cada sesión de agente futura tiene acceso a ese sistema.

Esta es la misma curva de adopción temprana que hemos visto con todo ecosistema de herramientas para desarrolladores. Las personas que invierten ahora — construyendo servidores, contribuyendo al estándar, descubriendo los patrones — tendrán una ventaja significativa cuando el ecosistema madure. Y madurará. El problema que MCP resuelve es demasiado real y demasiado universal para que no lo haga.

== Por Dónde Empezar

Si vas a configurar una integración hoy, que sea tu base de datos. La capacidad de decir "comprueba el esquema de la tabla de usuarios" o "¿qué índices existen en la tabla de pedidos?" elimina toda una categoría de cambio de contexto. Una conexión de base de datos de solo lectura es de bajo riesgo, alta recompensa y tarda cinco minutos en configurar.

Si vas a configurar dos, añade tu herramienta de gestión de proyectos — GitHub Issues, Linear, Jira, lo que use tu equipo. La capacidad de decir "lee el ticket PROJ-1234 e impleméntalo" o "¿qué tickets tengo asignados este sprint?" convierte al agente de un generador de código en un ejecutor de tareas.

Si vas a configurar tres, añade tu stack de monitorización. La capacidad de investigar problemas en producción sin salir de tu terminal es una transformación del flujo de trabajo que, una vez experimentada, nunca querrás abandonar.

Más allá de eso, deja que el trabajo te guíe. Cuando te encuentres copiando datos de un sistema al contexto del agente más de dos veces, esa es una señal: construye o instala el servidor MCP. La fricción que sientes es la fricción que elimina la integración.

Los agentes ya son capaces. La pregunta es si pueden ver suficiente de tu mundo para ser útiles. Las integraciones de herramientas son la respuesta.
