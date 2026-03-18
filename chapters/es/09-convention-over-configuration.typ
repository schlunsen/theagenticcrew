= Convención Sobre Configuración

Vi al mismo agente producir código digno de una contratación senior en un proyecto y basura imposible de mantener en otro — la misma tarde, en la misma máquina, con el mismo modelo. La diferencia no fue el prompt. Fue el código base.

Dos proyectos. Mismo stack tecnológico — TypeScript, React, PostgreSQL. Mismo tamaño de equipo. Mismo tooling agéntico.

El Proyecto A tiene una disposición de directorios estricta. Cada endpoint de API sigue el mismo patrón: un archivo de handler, un archivo de esquema, un archivo de test, nombrados idénticamente. La capa de base de datos usa un patrón de repositorio consistente. Hay un `CLAUDE.md` en la raíz que describe la arquitectura en dos páginas. Cuando un ingeniero apunta un agente a un ticket — "añade un nuevo endpoint para notificaciones de usuario" — el agente lee los endpoints existentes, sigue el patrón y produce un pull request que parece escrito por alguien del equipo. La revisión lleva tres minutos.

El Proyecto B es del otro tipo. El código base creció orgánicamente durante dos años. Algunos endpoints están en `routes/`, otros en `api/`, otros en `handlers/`. La mitad de las consultas a base de datos usan un ORM, la otra mitad usa SQL directo. No hay manejo de errores consistente — algunas funciones lanzan excepciones, otras devuelven objetos de error, otras devuelven null. El agente mira este código base y hace lo que puede, pero "lo que puede" significa elegir el patrón que vio más recientemente. El código resultante funciona, técnicamente, pero no encaja con nada a su alrededor. La revisión lleva treinta minutos, la mayor parte dedicada a "así no es como lo hacemos aquí."

La diferencia entre estos proyectos no es talento. No es tooling. Es convención.

Hay un viejo principio en el software: convención sobre configuración. Haz que lo predeterminado sea lo correcto. Reduce el número de decisiones que necesitan tomarse. Cuando todos siguen los mismos patrones, el código se explica solo.

Este principio siempre fue útil para equipos humanos. Para la ingeniería agéntica, es esencial.

Si esto suena como que te estoy diciendo que hagas el trabajo poco glamuroso — escribir documentación, imponer convenciones de nombres, mantener la estructura del proyecto — es que lo estoy haciendo. Y sé cómo se siente. No te hiciste ingeniero para escribir guías de estilo. Pero este es uno de esos momentos donde el oficio te pide que te preocupes por algo que solía sentirse como overhead, porque las implicaciones han cambiado. La convención solía ser una cortesía hacia tu yo futuro. Ahora es el sistema operativo sobre el que corren tus agentes.

== Por Qué a los Agentes les Encanta la Convención

Un agente navegando un código base desconocido hace lo mismo que un nuevo empleado: busca patrones. ¿Dónde viven los tests? ¿Cómo se nombran los archivos? ¿Cuál es la convención de imports? ¿Dónde está la configuración?

Si tu proyecto sigue convenciones fuertes, el agente detecta los patrones rápidamente y produce código que encaja. Si cada archivo es un copo de nieve — nombres diferentes, estructura diferente, estilos diferentes — el agente se pierde. No sabe qué patrón seguir, así que inventa el suyo, y el resultado se siente ajeno.

Hay una razón más profunda por la que las convenciones importan, y se conecta con las herramientas. Las convenciones funcionan porque hacen que las _herramientas_ del agente sean más efectivas. Cuando un agente ejecuta `ls` o `find` o `grep`, los nombres y la estructura consistentes hacen que esas herramientas devuelvan resultados útiles. Un proyecto donde los tests siempre viven en `__tests__/` significa que `find . -name "*.test.ts"` siempre funciona. Las convenciones no son solo contexto implícito — son lo que hace que la exploración autónoma del agente sea productiva.

La convención es _contexto implícito_. Es información que el agente absorbe de la estructura de tu código sin que tengas que explicarla. Cuando tus archivos de test siempre viven junto a los archivos fuente que testean, nombrados `foo.test.ts` junto a `foo.ts`, el agente no necesita que le digan dónde poner un nuevo test. Lee el directorio, ve el patrón y lo sigue. Cuando todos tus handlers de API exportan la misma forma — una función handler, un esquema, un conjunto de middleware — el agente produce un nuevo handler que exporta exactamente la misma forma.

Esta es la razón por la que los frameworks con opiniones siempre han sido productivos, y por qué son _aún más_ productivos en la era agéntica. Rails, Next.js, Laravel — imponen una estructura. Esa estructura no es solo para humanos. Es un lenguaje que el agente habla con fluidez.

== El CLAUDE.md a Fondo

Una convención creciente en la ingeniería agéntica es el archivo `CLAUDE.md`: un documento en la raíz de tu proyecto que le dice al agente lo que necesita saber. No un README para humanos. Un briefing para agentes.

Esta es una de las cosas de mayor apalancamiento que puedes hacer para tu flujo de trabajo agéntico, y la mayoría de los equipos lo omiten o escriben unas líneas vagas y lo dan por terminado. Hablemos de cómo se ve uno bueno de verdad.

Un `CLAUDE.md` sólido tiene cinco secciones:

*Visión general del proyecto.* Dos o tres frases. Qué hace esto, cuál es el stack tecnológico, cuál es el objetivo de despliegue. Un agente que sabe que está trabajando en "una plataforma de facturación B2B SaaS construida con Go y PostgreSQL, desplegada en Kubernetes" toma decisiones fundamentalmente diferentes que uno que está adivinando.

*Comandos de build y test.* Cada comando que el agente podría necesitar, listado explícitamente. No "mira el Makefile" — los comandos reales. Los agentes leen la documentación literalmente. Si tu `CLAUDE.md` dice `make test`, el agente ejecutará `make test`. Si dice "ejecuta los tests" sin especificar cómo, el agente adivinará, y podría adivinar mal.

*Decisiones de arquitectura.* Las cosas que no son obvias desde el código. Por qué elegiste un monorepo. Por qué el servicio de autenticación es separado. Por qué usas event sourcing para el pipeline de pedidos pero CRUD simple para la gestión de usuarios. Estas son las decisiones que dan forma a cada pieza de código nuevo, y un agente que no las conoce las violará constantemente.

*Convenciones.* Tu estilo. Cómo nombras las cosas. Cómo manejas los errores. Cómo se ve tu orden de imports. Si prefieres retornos tempranos o condicionales anidados. Las cosas que hacen que el código se sienta como que pertenece a _este_ proyecto.

*Trampas comunes.* Dónde están enterrados los cuerpos. La migración de base de datos que siempre debe ejecutarse antes del seed. La variable de entorno que no está en `.env.example` pero es necesaria para el flujo de pagos. El test que es inestable en CI pero no localmente. Todo proyecto tiene estos — escríbelos.

Así se ve un `CLAUDE.md` real para un proyecto de tamaño mediano:

```markdown
# Project: Meridian (billing platform)

TypeScript monorepo (pnpm workspaces). React frontend, Express API,
PostgreSQL with Drizzle ORM. Deployed to Fly.io.

## Commands
- `pnpm install` — install all dependencies
- `pnpm test` — run all tests (vitest)
- `pnpm test:api` — API tests only
- `pnpm test:web` — frontend tests only
- `pnpm lint` — eslint + prettier check
- `pnpm lint:fix` — auto-fix lint issues
- `pnpm db:migrate` — run pending migrations
- `pnpm db:generate` — generate migration from schema changes
- `pnpm dev` — start all services locally

## Architecture
- /packages/api — Express REST API
- /packages/web — React SPA (Vite)
- /packages/shared — shared types and utilities
- /packages/db — Drizzle schema, migrations, seed data

All API routes follow the pattern:
  routes/{resource}/index.ts — route definitions
  routes/{resource}/handlers.ts — request handlers
  routes/{resource}/schemas.ts — Zod validation schemas
  routes/{resource}/__tests__/ — tests for this resource

## Conventions
- All errors go through the AppError class (packages/api/src/errors.ts)
- Never throw raw Error objects in API handlers
- Use Zod schemas for ALL request validation, no manual checks
- Database queries live in packages/db/src/queries/, not in handlers
- Prefer early returns over deeply nested conditionals
- Import order: node builtins, external deps, internal packages, relative

## Pitfalls
- The Stripe webhook handler uses raw body parsing — don't add
  json middleware to that route
- Test database must be created manually: createdb meridian_test
- The `BILLING_SECRET` env var isn't in .env.example (it's in 1Password)
- Flaky test: invoice.concurrent.test.ts — known race condition,
  skip locally if it blocks you
```

Eso no es largo. Llevó quizá treinta minutos escribirlo. Pero cada sesión de agente que lee este archivo empieza con más contexto del que la mayoría de los desarrolladores humanos obtienen en su primera semana.

La disciplina más importante: mantenlo actualizado. Un `CLAUDE.md` desactualizado es peor que no tener ninguno, porque el agente confiará en él. Cuando cambies una convención, actualiza el archivo. Cuando añadas un nuevo servicio, añádelo a la sección de arquitectura. Cuando alguien descubra una nueva trampa, documéntala. Trátalo como código — vive en control de versiones, se revisa en PRs, es parte del proyecto.

Algunos equipos van más allá: ponen archivos `CLAUDE.md` también en subdirectorios. Un `packages/api/CLAUDE.md` que cubre patrones específicos de la API. Un `packages/web/CLAUDE.md` que documenta las convenciones de la biblioteca de componentes. Cuanto más profundo va el agente en el proyecto, más contexto específico obtiene. Es como una cebolla de documentación — contexto amplio en la raíz, contexto específico a medida que profundizas.

== Las Convenciones Como Memoria del Agente

Las convenciones son lo más parecido que los agentes tienen a memoria a largo plazo. Una vez que ves esto, cambia cómo piensas sobre todas ellas.

La ventana de contexto de un agente se reinicia en cada sesión. No recuerda lo que hizo ayer. No recuerda la discusión de arquitectura que tuviste la semana pasada. No recuerda que las últimas tres veces que usó `fetch` directamente, le pediste que usara el wrapper del cliente API en su lugar.

Pero la estructura de tu proyecto persiste. Tu nomenclatura de archivos persiste. Tu `CLAUDE.md` persiste. Las reglas de tu linter persisten. Tus patrones de test persisten. Todo lo que codificas en la forma de tu proyecto está ahí cada vez que el agente abre los ojos.

Esto reenmarca las convenciones por completo. No se tratan solo de consistencia para humanos. Son _memoria externa_ para agentes. Cada convención que estableces es una lección que el agente no tiene que reaprender.

Piensa en lo que pasa sin convenciones. Sesión uno: el agente crea un nuevo endpoint y pone el manejo de errores inline. Lo corriges en la revisión: "Usamos la clase AppError." Sesión dos: el agente crea otro endpoint y comete el mismo error, porque no recuerda la sesión uno. Sesión tres: lo mismo. Estás teniendo la misma conversación una y otra vez.

Ahora añade una convención — un patrón documentado de manejo de errores, reforzado por una regla del linter — y el problema desaparece permanentemente. El agente lee el código existente, ve el patrón, lo sigue. El linter detecta cualquier desviación. La lección está codificada en el propio proyecto, no en la memoria de nadie.

Esta es la razón por la que los equipos agénticos más efectivos se obsesionan con convenciones que parecen tediosas. Orden de imports consistente. Nomenclatura de archivos estricta. Firmas de funciones estándar. Estas no son preferencias estéticas — son memoria. Son la sabiduría acumulada del equipo, almacenada en un formato que sobrevive a los reinicios de ventana de contexto.

La analogía a la que vuelvo constantemente: las convenciones son para los agentes lo que el conocimiento institucional es para las organizaciones. Una empresa donde todo vive en la cabeza de una persona es frágil. Una empresa con procesos y documentación sólidos es resiliente. Lo mismo se aplica a los códigos base. Un proyecto donde "cómo hacemos las cosas" vive solo en la memoria del desarrollador senior es frágil. Un proyecto donde está codificado en la estructura, el tooling y la documentación es resiliente — para humanos y agentes por igual.

== Convenciones Prácticas Que Ayudan a los Agentes

*Nomenclatura de archivos consistente.* Si tus rutas de API viven en `routes/`, tus modelos en `models/`, y tus tests en `__tests__/` — el agente puede navegar tu proyecto sin mapa. Nombra los archivos según lo que contienen. Mantenlo aburrido.

*Formateadores y linters.* Herramientas como Prettier, ESLint, `gofmt` o Ruff no son solo para estilo de código — son barandillas que aseguran que el código generado por agentes coincida con los estándares de tu proyecto automáticamente. Ejecútalos al guardar, ejecútalos en CI, hazlos innegociables.

*Disposición de proyecto estándar.* Ya sea la disposición estándar de Go, las convenciones de Rails o la estructura propia de tu equipo — elige una y cíñete a ella. Un `justfile` o `Makefile` en la raíz que liste los comandos estándar (`build`, `test`, `lint`, `dev`) les da a los agentes un punto de entrada a cualquier proyecto.

*Archivos pequeños y enfocados.* Los agentes trabajan mejor con archivos de menos de unos cientos de líneas. Cuando un archivo contiene una sola preocupación — un componente, un módulo, un conjunto de funciones relacionadas — el agente puede leerlo, entenderlo y modificarlo sin tener que vadear código no relacionado.

*Mensajes de commit descriptivos.* Los agentes leen el historial de git. Un commit que dice "fix bug" no enseña nada. Un commit que dice "fix race condition in session cleanup when WebSocket disconnects during auth" le da al agente contexto sobre qué era importante, qué era frágil y cómo piensa el equipo sobre los problemas.

*Manejo de errores consistente.* Elige un patrón y aplícalo en todas partes. Clases de error personalizadas con códigos de error. Un handler de errores central. Una forma estándar de respuesta de error. Cuando el agente encuentra un caso de error en código nuevo, debería tener cero ambigüedad sobre cómo manejarlo. Si tu proyecto usa tres enfoques diferentes de manejo de errores en tres archivos diferentes, el agente producirá un cuarto.

*Formatos de respuesta de API estándar.* Cada endpoint devuelve la misma forma: `{ data, error, meta }` o lo que elijas. Los códigos de estado siguen las mismas reglas en todas partes. La paginación funciona igual en cada endpoint de lista. Esta es el tipo de consistencia en la que los agentes destacan manteniéndola — pero solo si la convención es clara desde el código existente.

*Convenciones de logging.* Logging estructurado con campos consistentes. Cada entrada de log incluye un ID de petición, un timestamp y un nivel de severidad. Cada log de error incluye el código de error y una traza de pila. Cuando el agente añade logging a código nuevo — y debería — los logs deberían verse idénticos a todos los demás logs del sistema.

*Estructura de directorios que cuente una historia.* Un agente debería poder hacer `ls` en el nivel superior de tu proyecto y entender la arquitectura. Así se ve un proyecto bien estructurado desde la perspectiva de un agente:

```
src/
  routes/         # HTTP handlers — one file per resource
  services/       # Business logic — one file per domain concept
  repositories/   # Database access — one file per table/entity
  middleware/      # Express/Koa middleware
  utils/          # Pure utility functions
  types/          # Shared TypeScript types
  errors/         # Custom error classes
tests/
  fixtures/       # Test data factories
  helpers/        # Test utilities
migrations/       # Database migrations (numbered)
scripts/          # One-off and maintenance scripts
```

Cada nombre de directorio es un sustantivo. Cada archivo dentro contiene exactamente lo que el nombre del directorio promete. No hay lugar para confusión sobre dónde debe ir el código nuevo. Un agente leyendo esta estructura sabe inmediatamente: "Necesito añadir una nueva consulta de base de datos, eso va en `repositories/`. Necesito un nuevo endpoint, eso empieza en `routes/`."

Compara eso con un proyecto donde las consultas de base de datos están dispersas en archivos de handlers, la lógica de negocio vive en funciones utilitarias y hay tres directorios diferentes que parecen contener "helpers." El agente pondrá código en _algún_ lugar, pero probablemente no será el lugar _correcto_.

== El Impuesto de la Convención

Seamos honestos sobre el coste. Establecer convenciones lleva tiempo y se siente como overhead — especialmente al principio.

Escribir un `CLAUDE.md` lleva una tarde. Configurar linters y formateadores lleva un día. Refactorizar un código base inconsistente para seguir un solo patrón lleva una semana, quizá más. Imponer convenciones en la revisión de código significa ralentizar PRs que "funcionan bien" pero no siguen el estándar.

Hay una tentación real de saltarse todo esto. El código funciona. Los tests pasan. ¿Por qué pasar tiempo en convenciones de nomenclatura cuando hay funcionalidades que entregar?

La respuesta honesta: si eres un desarrollador solo construyendo un prototipo desechable, el impuesto de convención probablemente no vale la pena. Muévete rápido, entrégalo, tíralo.

Pero en el momento en que un segundo par de ojos toca tu código base — humano _o_ agente — las convenciones empiezan a pagarse solas. Y los retornos se acumulan.

La primera vez que estableces una convención, te cuesta una hora. Cada vez subsiguiente que un agente sigue esa convención en lugar de preguntarte cómo manejar algo, ahorras cinco minutos. Haz las cuentas: después de doce sesiones de agente, la convención se ha pagado sola. Después de cien sesiones, has ahorrado _horas_.

Esto se acumula en todo el equipo. Cinco ingenieros, cada uno ejecutando múltiples sesiones de agente por día, todos beneficiándose de las mismas convenciones. La inversión inicial de una tarde de un ingeniero ahorra al equipo cientos de horas a lo largo de un año.

Los equipos que invierten en convenciones temprano parecen más lentos al principio. Pasan tiempo en cosas "aburridas" — configuraciones de linter, estructura de proyecto, documentación. Pero tres meses después, sus agentes producen código que requiere revisión mínima. Seis meses después, entregan el doble de rápido que el equipo que se saltó el trabajo de convención. Un año después, la brecha es embarazosa.

Esta es la misma dinámica que la deuda técnica, solo que invertida. La convención es _riqueza_ técnica — y como la riqueza financiera, cuanto antes empieces a invertir, más dramático es el efecto acumulativo.

El mayor error que veo es que los equipos esperan hasta que su código base es un desastre antes de intentar establecer convenciones. Ese es el momento más caro para hacerlo. El momento más barato es al inicio de un proyecto — pero el segundo más barato es hoy.

== El Efecto Acumulativo

Cada convención que estableces, cada estándar que impones, cada pieza de documentación que mantienes — todo se acumula. Cada una hace que los agentes sean ligeramente más efectivos, ligeramente más autónomos, ligeramente más propensos a producir código que encaja en tu proyecto como un guante.

Pero la acumulación no es solo aditiva. Las convenciones interactúan. Una convención de nomenclatura consistente _más_ una estructura de directorios estándar _más_ un `CLAUDE.md` que describe la arquitectura — juntas, estas le dan al agente un modelo mental de todo el proyecto. Sabe dónde encontrar cosas, cómo nombrarlas y cómo encajan. Quita cualquiera de las tres, y la efectividad del agente cae desproporcionadamente.

Esta es la razón por la que las convenciones a medias son casi tan malas como no tener convenciones. Un proyecto con nomenclatura de archivos consistente pero estructura de directorios caótica envía señales mixtas. El agente ve orden en una dimensión y caos en otra, y no sabe en qué señal confiar.

Los ingenieros que invierten en convención temprano no solo tienen códigos base más limpios. Tienen códigos base que están listos para el futuro agéntico. Sus agentes producen mejores resultados. Sus revisiones son más rápidas. Sus ciclos de iteración son más ajustados.

La convención no es trabajo glamuroso. Es el capítulo menos emocionante de este libro. Pero es el que hace que todos los demás capítulos funcionen. Los sandboxes, las estrategias de testing, la orquestación multi-agente — todo funciona mejor cuando el código base subyacente es consistente, documentado y convencional.

Tu código base es el entorno en el que viven tus agentes. Hazlo legible. Hazlo predecible. Hazlo aburrido. Los agentes te lo agradecerán escribiendo código que parece que pertenece.
