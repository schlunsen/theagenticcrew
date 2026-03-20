= Convencio per Sobre de Configuracio

Vaig veure el mateix agent produir codi digne d'una contractacio senior en un projecte i escombraries inmantenibles en un altre -- la mateixa tarda, a la mateixa maquina, amb el mateix model. La diferencia no era el prompt. Era la base de codi.

Dos projectes. El mateix stack tecnologic -- TypeScript, React, PostgreSQL. El mateix tamany d'equip. Les mateixes eines agentiques.

El projecte A te un disseny de directoris estricte. Cada endpoint d'API segueix el mateix patro: un fitxer de handler, un fitxer d'esquema, un fitxer de tests, nomenats identicament. La capa de base de dades utilitza un patro de repositori consistent. Hi ha un `CLAUDE.md` a l'arrel que descriu l'arquitectura en dues pagines. Quan un enginyer apunta un agent a un tiquet -- "afegeix un nou endpoint per a notificacions d'usuari" -- l'agent llegeix els endpoints existents, segueix el patro, i produeix un pull request que sembla que un huma de l'equip l'hagi escrit. La revisio triga tres minuts.

El projecte B es l'altre tipus. La base de codi va creixer organicament durant dos anys. Alguns endpoints son a `routes/`, alguns a `api/`, alguns a `handlers/`. La meitat de les consultes a la base de dades utilitzen un ORM, l'altra meitat utilitzen SQL en brut. No hi ha gestio d'errors consistent -- algunes funcions llencen excepcions, algunes retornen objectes d'error, algunes retornen null. L'agent mira aquesta base de codi i fa el que pot, pero "el que pot" vol dir triar el patro que hagi vist mes recentment. El codi resultant funciona, tecnicament, pero no coincideix amb res del voltant. La revisio triga trenta minuts, la majoria dedicats a "no es aixi com ho fem aqui."

La diferencia entre aquests projectes no es talent. No son les eines. Es la convencio.

Hi ha un principi antic en software: convencio per sobre de configuracio. Fes que l'opcio per defecte sigui la correcta. Redueix el nombre de decisions que cal prendre. Quan tothom segueix els mateixos patrons, el codi s'explica sol.

Aquest principi sempre va ser util per a equips humans. Per a enginyeria agentica, es essencial.

Si aixo et sona com si t'estigues dient que facis la feina poc glamurosa -- escriure documentacio, imposar convencions de noms, mantenir l'estructura del projecte -- aixi es. I se com se sent. No et vas fer enginyer per escriure guies d'estil. Pero aquest es un d'aquells moments on l'ofici et demana que t'importi alguna cosa que solia semblar sobrecost, perque el que hi ha en joc ha canviat. La convencio solia ser una cortesia cap al teu jo futur. Ara es el sistema operatiu sobre el qual els teus agents s'executen.

== Per Que els Agents Estimen la Convencio

Un agent navegant per una base de codi desconeguda fa el mateix que un nou empleat: busca patrons. On viuen els tests? Com es nomenen els fitxers? Quina es la convencio d'imports? On es la configuracio?

Si el teu projecte segueix convencions fortes, l'agent recull els patrons rapidament i produeix codi que encaixa. Si cada fitxer es un floc de neu -- nomenclatura diferent, estructura diferent, estils diferents -- l'agent trontolla. No sap quin patro seguir, aixi que inventa el seu propi, i el resultat es sent alie.

Hi ha una rao mes profunda per la qual les convencions importen, i connecta amb les eines. Les convencions funcionen perque fan les _eines_ de l'agent mes efectives. Quan un agent executa `ls` o `find` o `grep`, una nomenclatura i estructura consistents volen dir que aquelles eines retornen resultats utils. Un projecte on els tests sempre viuen a `__tests__/` vol dir que `find . -name "*.test.ts"` sempre funciona. Les convencions no son nomes context implicit -- son el que fa que l'exploracio autonoma de l'agent sigui productiva.

La convencio es _context implicit_. Es informacio que l'agent absorbeix de l'estructura del teu codi sense que l'hagis d'explicar. Quan els teus fitxers de test sempre viuen al costat dels fitxers font que testen, nomenats `foo.test.ts` al costat de `foo.ts`, l'agent no necessita que li diguin on posar un nou test. Llegeix el directori, veu el patro i el segueix. Quan els teus handlers d'API tots exporten la mateixa forma -- una funcio de handler, un esquema, un conjunt de middleware -- l'agent produeix un nou handler que exporta exactament la mateixa forma.

Per aixo els frameworks amb opinions sempre han estat productius, i per que son _encara mes_ productius a l'era agentica. Rails, Next.js, Laravel -- imposen una estructura. Aquella estructura no es nomes per a humans. Es un llenguatge que l'agent parla fluixament.

== Aprofundiment en CLAUDE.md

Una convencio creixent en enginyeria agentica es el fitxer `CLAUDE.md`: un document a l'arrel del teu projecte que diu a l'agent el que necessita saber. No un README per a humans. Un briefing per a agents.

Aixo es una de les coses de mes alt palanquejament que pots fer pel teu flux de treball agentic, i la majoria d'equips o se'l salten o escriuen unes poques linies vagues i ho donen per fet. Parlem de com es realment un de bo.

Un `CLAUDE.md` fort te cinc seccions:

*Visio general del projecte.* Dues o tres frases. Que fa aquesta cosa, quin es el stack tecnologic, quin es l'objectiu de desplegament. Un agent que sap que esta treballant en "una plataforma SaaS B2B de facturacio construida amb Go i PostgreSQL, desplegada a Kubernetes" pren decisions fonamentalment diferents d'un que esta endevinant.

*Comandes de build i test.* Cada comanda que l'agent pugui necessitar, llistada explicitament. No "mira el Makefile" -- les comandes reals. Els agents llegeixen la documentacio literalment. Si el teu `CLAUDE.md` diu `make test`, l'agent executara `make test`. Si diu "executa els tests" sense especificar com, l'agent endevinara, i podria endevinar malament.

*Decisions d'arquitectura.* Les coses que no son obvies a partir del codi. Per que vas triar un monorepo. Per que el servei d'autenticacio es separat. Per que fas servir event sourcing per al pipeline de comandes pero CRUD simple per a la gestio d'usuaris. Aquestes son les decisions que donen forma a cada peca de codi nou, i un agent que no les coneix les violara constantment.

*Convencions.* El teu estil. Com nomenes les coses. Com gestiones els errors. Com es el teu ordre d'imports. Si prefereixes retorns anticipats o condicionals niats. Les coses que fan que el codi se senti com si pertanyes a _aquest_ projecte.

*Trampes comunes.* On estan els cossos enterrats. La migracio de base de dades que sempre s'ha d'executar abans del seed. La variable d'entorn que no esta a `.env.example` pero es necessaria per al flux de pagament. El test que es intermitent a CI pero no localment. Tots els projectes tenen aixo -- escriu-ho.

Aqui tens com es veu un `CLAUDE.md` real per a un projecte de mida mitjana:

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

Aixo no es llarg. Va trigar potser trenta minuts a escriure. Pero cada sessio d'agent que llegeix aquest fitxer comenca amb mes context que la majoria de desenvolupadors humans obtenen la seva primera setmana.

La disciplina mes important: manten-lo actualitzat. Un `CLAUDE.md` obsolet es pitjor que cap, perque l'agent se'l creura. Quan canviis una convencio, actualitza el fitxer. Quan afegeixis un nou servei, afegeix-lo a la seccio d'arquitectura. Quan algu descobreixi una nova trampa, documenta-la. Tracta'l com a codi -- viu al control de versions, es revisa als PRs, es part del projecte.

Alguns equips van mes lluny: posen fitxers `CLAUDE.md` tambe als subdirectoris. Un `packages/api/CLAUDE.md` que cobreix patrons especifics de l'API. Un `packages/web/CLAUDE.md` que documenta les convencions de la biblioteca de components. Com mes profund va l'agent al projecte, mes context especific obte. Es com una ceba de documentacio -- context ampli a l'arrel, context especific a mesura que aprofundeixes.

== Les Convencions com a Memoria dels Agents

Les convencions son el mes semblant que tenen els agents a memoria a llarg termini. Un cop veus aixo, canvia com penses sobre totes elles.

La finestra de context d'un agent es reinicia cada sessio. No recorda que va fer ahir. No recorda la discussio d'arquitectura que vau tenir la setmana passada. No recorda que les ultimes tres vegades que va fer servir `fetch` directament, li vas demanar que uses l'API client wrapper en el seu lloc.

Pero l'estructura del teu projecte persisteix. La nomenclatura dels teus fitxers persisteix. El teu `CLAUDE.md` persisteix. Les regles del teu linter persisteixen. Els teus patrons de tests persisteixen. Tot el que codifiques a la forma del teu projecte esta alla cada vegada que l'agent obre els ulls.

Aixo reformula les convencions completament. No son nomes sobre consistencia per a humans. Son _memoria externa_ per a agents. Cada convencio que estableixis es una llico que l'agent no ha de reaprendre.

Pensa en que passa sense convencions. Sessio u: l'agent crea un nou endpoint i posa la gestio d'errors inline. Ho corregeixis a la revisio: "Fem servir la classe AppError." Sessio dos: l'agent crea un altre endpoint i comet el mateix error, perque no recorda la sessio u. Sessio tres: el mateix. Estas tenint la mateixa conversa una i altra vegada.

Ara afegeix una convencio -- un patro de gestio d'errors documentat, imposat per una regla del linter -- i el problema desapareix permanentment. L'agent llegeix el codi existent, veu el patro, el segueix. El linter detecta qualsevol desviacio. La llico esta codificada al propi projecte, no a la memoria de ningu.

Per aixo els equips agentics mes efectius s'obsessionen amb convencions que semblen tedioses. Ordre d'imports consistent. Nomenclatura de fitxers estricta. Signatures de funcions estandard. No son preferencies estetiques -- son memoria. Son la saviesa acumulada de l'equip, emmagatzemada en un format que sobreviu els reinicis de finestra de context.

L'analogia a la qual torno una i altra vegada: les convencions son per als agents el que el coneixement institucional es per a les organitzacions. Una empresa on tot viu al cap d'una sola persona es fragil. Una empresa amb processos i documentacio forts es resilient. El mateix s'aplica a les bases de codi. Un projecte on "com fem les coses" viu nomes a la memoria del desenvolupador senior es fragil. Un projecte on esta codificat a l'estructura, les eines i la documentacio es resilient -- per a humans i agents per igual.

== Convencions Practiques que Ajuden els Agents

*Nomenclatura de fitxers consistent.* Si les teves rutes d'API viuen a `routes/`, els teus models a `models/`, i els teus tests a `__tests__/` -- l'agent pot navegar el teu projecte sense mapa. Nomena els fitxers segons el que contenen. Manten-ho avorrit.

*Formatadors i linters.* Eines com Prettier, ESLint, `gofmt`, o Ruff no son nomes per a estil de codi -- son baranes que asseguren que el codi generat per agents coincideix amb els estandards del teu projecte automaticament. Executa'ls al guardar, executa'ls a CI, fes-los no negociables.

*Disseny de projecte estandard.* Ja sigui el layout estandard de Go, convencions de Rails, o l'estructura del teu propi equip -- tria'n un i mantin-lo. Un `justfile` o `Makefile` a l'arrel que llisti les comandes estandard (`build`, `test`, `lint`, `dev`) dona als agents un punt d'entrada a qualsevol projecte.

*Fitxers petits i enfocats.* Els agents treballen millor amb fitxers de menys d'unes quantes centenars de linies. Quan un fitxer conte una sola preocupacio -- un component, un modul, un conjunt de funcions relacionades -- l'agent pot llegir-lo, entendre'l i modificar-lo sense patir codi no relacionat.

*Missatges de commit descriptius.* Els agents llegeixen l'historial de git. Un commit que diu "fix bug" no ensenya res. Un commit que diu "fix race condition in session cleanup when WebSocket disconnects during auth" dona a l'agent context sobre que era important, que era fragil, i com pensa l'equip sobre els problemes.

*Gestio d'errors consistent.* Tria un patro i imposa'l a tot arreu. Classes d'error personalitzades amb codis d'error. Un gestor d'errors central. Una forma de resposta d'error estandard. Quan l'agent trobi un cas d'error en codi nou, hauria de tenir zero ambiguitat sobre com gestionar-lo. Si el teu projecte utilitza tres enfocaments diferents de gestio d'errors en tres fitxers diferents, l'agent produira un quart.

*Formats de resposta d'API estandard.* Cada endpoint retorna la mateixa forma: `{ data, error, meta }` o el que triis. Els codis d'estat segueixen les mateixes regles a tot arreu. La paginacio funciona de la mateixa manera a cada endpoint de llista. Aixo es el tipus de consistencia en que els agents excel·leixen mantenint -- pero nomes si la convencio es clara a partir del codi existent.

*Convencions de logging.* Logging estructurat amb camps consistents. Cada entrada de log inclou un ID de peticio, un timestamp i un nivell de gravetat. Cada log d'error inclou el codi d'error i una traca de pila. Quan l'agent afegeixi logging a codi nou -- i hauria de fer-ho -- els logs haurien de ser identics a tots els altres logs del sistema.

*Estructura de directoris que expliqui una historia.* Un agent hauria de poder fer `ls` al nivell superior del teu projecte i entendre l'arquitectura. Aqui tens com es veu un projecte ben estructurat des de la perspectiva d'un agent:

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

Cada nom de directori es un substantiu. Cada fitxer dins conte exactament el que el nom del directori promet. No hi ha lloc per a la confusio sobre on hauria d'anar el codi nou. Un agent llegint aquesta estructura immediatament sap: "Necessito afegir una nova consulta a la base de dades, aixo va a `repositories/`. Necessito un nou endpoint, aixo comenca a `routes/`."

Compara-ho amb un projecte on les consultes a la base de dades estan escampades pels fitxers de handlers, la logica de negoci viu en funcions d'utilitat, i hi ha tres directoris diferents que tots semblen contenir "helpers." L'agent posara codi en _algun_ lloc, pero probablement no sera el lloc _correcte_.

== L'Impost de la Convencio

Siguem honestos sobre el cost. Establir convencions pren temps, i se sent com a sobrecost -- especialment al principi.

Escriure un `CLAUDE.md` pren una tarda. Configurar linters i formatadors pren un dia. Refactoritzar una base de codi inconsistent per seguir un sol patro pren una setmana, potser mes. Imposar convencions a la revisio de codi vol dir frenar PRs que "funcionen be" pero no segueixen l'estandard.

Hi ha una temptacio real de saltar-se tot aixo. El codi funciona. Els tests passen. Per que dedicar temps a convencions de noms quan hi ha funcionalitats per lliurar?

La resposta honesta: si ets un desenvolupador en solitari construint un prototip d'un sol us, l'impost de la convencio probablement no val la pena. Mou-te rapid, desplega-ho, llenca-ho.

Pero al moment que un segon parell d'ulls toqui la teva base de codi -- huma _o_ agent -- les convencions comencen a retornar-se. I els retorns es composen.

La primera vegada que estableixes una convencio, et costa una hora. Cada vegada posterior que un agent segueix aquella convencio en lloc de preguntar-te com gestionar-ho, estalvies cinc minuts. Fes l'aritmetica: despres de dotze sessions d'agents, la convencio s'ha amortitzat. Despres de cent sessions, has estalviat _hores_.

Aixo es composa a l'equip. Cinc enginyers, cadascun executant multiples sessions d'agents per dia, tots beneficiant-se de les mateixes convencions. La inversio inicial d'una tarda d'un enginyer estalvia a l'equip centenars d'hores al llarg d'un any.

Els equips que inverteixen en convencions d'hora semblen mes lents al principi. Dediquen temps a coses "avorrides" -- configuracions de linter, estructura del projecte, documentacio. Pero tres mesos despres, els seus agents estan produint codi que requereix revisio minima. Sis mesos despres, estan lliurant el doble de rapid que l'equip que es va saltar la feina de convencions. Un any despres, la diferencia es vergonyosa.

Aixo es la mateixa dinamica que el deute tecnic, nomes invertida. La convencio es _riquesa_ tecnica -- i com la riquesa financera, com mes aviat comences a invertir, mes dramatic es el compost.

L'error mes gran que veig es equips que esperen fins que la seva base de codi es un desastre abans d'intentar establir convencions. Aquell es el moment mes car per fer-ho. El moment mes barat es al principi d'un projecte -- pero el segon moment mes barat es avui.

== L'Efecte Compost

Cada convencio que estableixes, cada estandard que imposes, cada peca de documentacio que mantens -- tot es composa. Cadascun fa els agents lleugerament mes efectius, lleugerament mes autonoms, lleugerament mes propensos a produir codi que encaixa al teu projecte com un guant.

Pero el compost no es nomes additiu. Les convencions interactuen. Una convencio de nomenclatura de fitxers consistent _mes_ una estructura de directoris estandard _mes_ un `CLAUDE.md` que descriu l'arquitectura -- juntes, donen a l'agent un model mental de tot el projecte. Sap on trobar les coses, com nomenar-les, i com encaixen. Elimina qualsevol d'aquestes tres, i l'efectivitat de l'agent cau desproporcionadament.

Per aixo les convencions a mitges son gairebe tan dolentes com no tenir convencions. Un projecte amb nomenclatura de fitxers consistent pero estructura de directoris caotica envia senyals mixtos. L'agent veu ordre en una dimensio i caos en una altra, i no sap en quin senyal confiar.

Els enginyers que inverteixen en convencio d'hora no nomes tenen bases de codi mes netes. Tenen bases de codi que estan preparades per al futur agentic. Els seus agents produeixen millors resultats. Les seves revisions son mes rapides. Els seus cicles d'iteracio son mes ajustats.

La convencio no es feina glamurosa. Es el capitol menys emocionant d'aquest llibre. Pero es el que fa que tots els altres capitols funcionin. Els sandboxes, les estrategies de testing, l'orquestracio multi-agent -- tot funciona millor quan la base de codi subjacent es consistent, documentada i convencional.

La teva base de codi es l'entorn on viuen els teus agents. Fes-la llegible. Fes-la previsible. Fes-la avorrida. Els agents t'ho agrairan escrivint codi que sembla que hi pertanyi.
