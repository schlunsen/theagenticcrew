= Ampliant l'Abast de l'Agent

#figure(
  image("../../assets/illustrations/ch09-mcp-connections.jpg", width: 70%),
)

El mes passat estava depurant un problema de produccio -- 502s intermitents en un endpoint de checkout. Els logs estaven a Datadog. La configuracio rellevant era al nostre cluster de Kubernetes. L'historial del tiquet era a Linear. L'esquema de la base de dades era a PostgreSQL. El codi estava al meu editor.

Tenia sis pestanyes del navegador obertes, copiant i enganxant entre elles, intentant assemblar prou context per entendre el problema. L'agent seia al meu terminal, preparat per ajudar, pero nomes podia veure els meus fitxers locals. Era com tenir un col·lega brillant encadenat a un escriptori -- desitjos d'ajudar, pero cec a tot el que hi havia fora del repo.

Despres vaig configurar servidors MCP per a Datadog, la nostra base de dades, i Linear. La seguent sessio de depuracio va ser diferent. Li vaig dir a l'agent: "L'endpoint de checkout esta llançant 502s intermitents. Comprova els logs de Datadog de l'ultima hora, mira les taules de base de dades rellevants, i llegeix el tiquet de Linear per al context." L'agent va obtenir logs, va consultar l'esquema, va llegir l'historial del tiquet, va correlacionar els timestamps, i va identificar el problema en quatre minuts: un exhauriment del pool de connexions causat per un timeout que faltava en una crida a un servei extern. No vaig copiar res. No vaig canviar ni una sola pestanya.

Aixo es el que fan les integracions d'eines. Amplien el mon de l'agent de "fitxers al teu disc" a "tots els sistemes amb els quals treballes."

== Que Es MCP?

El Model Context Protocol -- MCP -- es un estandard obert per connectar agents d'IA a fonts de dades externes i eines. Pensa-hi com un USB per a agents: un connector estandard que permet a qualsevol agent parlar amb qualsevol servei, sense codi d'integracio personalitzat per a cada combinacio.

Abans de MCP, connectar un agent a la teva base de dades significava escriure un wrapper a mida. Connectar-lo a Jira significava un wrapper diferent. Connectar-lo a Slack, un altre. Cada framework d'agents tenia el seu propi sistema de plugins, el seu propi format de definicio d'eines, la seva propia manera de gestionar l'autenticacio. Si canviaves de framework, ho reescrivies tot.

MCP estandarditza aixo. Un servidor MCP es un petit programa que exposa un conjunt d'eines -- funcions que l'agent pot cridar -- a traves d'un protocol consistent. El framework d'agents es connecta a qualsevol servidor MCP de la mateixa manera. Vols donar a l'agent acces a PostgreSQL? Executa un servidor MCP de Postgres. Vols que llegeixi les teves notes de Notion? Executa un servidor MCP de Notion. Vols que consulti el teu stack de monitoratge? Hi ha un servidor MCP per a aixo.

L'agent no sap ni li importa que hi ha darrere el protocol. Veu eines: "consulta la base de dades," "cerca pagines de Notion," "obte logs de Datadog." Les crida de la mateixa manera que crida qualsevol altra eina -- llegir un fitxer, executar una comanda. El servidor MCP gestiona la traduccio entre la peticio de l'agent i l'API del sistema extern.

Aixo es mes important del que sembla. Significa que l'ecosistema de capacitats d'agents creix independentment de qualsevol framework d'agents unic. Algu construeix un servidor MCP de Stripe, i _tots_ els agents compatibles amb MCP ara poden treballar amb Stripe. L'efecte de xarxa es el mateix que va fer que USB fos ubicu: un estandard, molts dispositius, tothom se'n beneficia.

== Per Que Aixo Importa per a l'Enginyeria

Si has llegit el capitol del context, saps que un agent es tan bo com el que pot veure. Les integracions d'eines son com li dones ulls mes enlla del sistema de fitxers.

Considera el que una tasca tipica d'enginyeria realment implica:

- El *codi* viu al teu repo.
- L'*informe de bug* viu a Jira, Linear, o GitHub Issues.
- Els *logs d'errors* viuen a Datadog, Sentry, o CloudWatch.
- L'*esquema de la base de dades* viu a PostgreSQL, MySQL, o MongoDB.
- La *documentacio de l'API* viu a Notion, Confluence, o una wiki.
- L'*estat del desplegament* viu a la teva plataforma de CI/CD.
- L'*especificacio de disseny* viu a Figma o un Google Doc.

Un agent amb acces nomes al teu repo esta treballant amb potser el 30% del context que necessita. La resta esta escampada per sis sistemes diferents, cadascun amb la seva propia interficie, la seva propia autenticacio, el seu propi llenguatge de consulta. Passes el dia com una capa de middleware humana -- copiant logs d'errors de Datadog, enganxant-los al context de l'agent, copiant les preguntes de l'agent, buscant la resposta a Confluence, enganxant-la de nou.

Les integracions d'eines eliminen aquella capa de middleware. L'agent consulta Datadog directament. Llegeix el document de Notion ell mateix. Comprova l'estat del desplegament sense que tu canviis de pestanya. Passes de ser un portaretalls a ser un capita -- donant direccio en lloc de transportant dades.

== La Configuracio Practica

Configurar servidors MCP es mes simple del que sembla. La majoria de frameworks d'agents que suporten MCP -- Claude Code, Cline, Continue, i altres -- et permeten configurar servidors en un fitxer JSON. Aqui tens com es veu una configuracio tipica:

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

Aixo es tot. Dos servidors. El teu agent ara pot consultar la teva base de dades i interactuar amb GitHub -- llegir issues, comprovar l'estat de PRs, cercar codi. Els servidors s'inicien automaticament quan comença la sessio de l'agent. Sense codi a escriure. Sense plugins a instal·lar mes enlla dels paquets del servidor MCP.

L'ecosistema creix rapidament. A principis del 2026, hi ha servidors MCP mantinguts per la comunitat per a:

- *Bases de dades:* PostgreSQL, MySQL, SQLite, MongoDB, Redis
- *Gestio de projectes:* GitHub, GitLab, Linear, Jira, Notion
- *Monitoratge:* Datadog, Sentry, Grafana
- *Comunicacio:* Slack, Discord
- *Cloud:* AWS, GCP, Kubernetes
- *Documentacio:* Confluence, Notion, Google Docs
- *APIs:* REST generic, GraphQL, servidors basats en OpenAPI

No necessites tots aquests. Comença amb els dos o tres sistemes als quals canvies de context mes sovint. Per a la majoria d'enginyers, aixo es una base de dades i una eina de gestio de projectes. Afegeix-ne mes a mesura que el flux de treball ho demani.

== Construint el Teu Propi Servidor MCP

Els servidors existents cobreixen eines comunes. Pero cada equip te sistemes interns -- un panell d'administracio personalitzat, una API propietaria, una eina de desplegament interna, un pipeline de dades a mida. Aqui es on val la pena construir el teu propi servidor MCP.

Un servidor MCP es un petit programa que implementa el protocol MCP i exposa eines. El protocol gestiona la comunicacio; tu escrius les eines. Aqui tens com es veu un servidor personalitzat minimal en TypeScript:

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
  "Get the current deployment status for a service",
  { service: z.string().describe("Service name, e.g. 'checkout-api'") },
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
  "List recent deployments across all services",
  { hours: z.number().default(24).describe("How many hours back") },
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

Aixo es un servidor MCP funcional. Exposa dues eines: una per comprovar l'estat de desplegament d'un servei especific, una altra per llistar desplegaments recents. L'agent ara pot preguntar "quin es l'estat de desplegament de checkout-api?" i obtenir una resposta real dels teus sistemes interns.

El patro sempre es el mateix: defineix una eina amb un nom, una descripcio, un esquema per a les entrades, i una funcio que fa la feina. La descripcio importa mes del que penses -- es el que l'agent llegeix per decidir _quan_ cridar la teva eina. Una descripcio vaga com "fa coses de desplegament" confondra l'agent sobre quan usar-la. Una descripcio precisa com "Obte l'estat de desplegament actual per a un servei, incloent versio, salut i timestamp de l'ultim desplegament" dona a l'agent exactament la informacio que necessita per cridar l'eina correcta en el moment correcte.

La majoria de servidors MCP personalitzats son de menys de 200 linies de codi. Si pots escriure un client d'API, pots escriure un servidor MCP. La inversio es petita i el benefici es immediat: el teu agent ara parla el llenguatge de la teva infraestructura.

== Com Funciona Realment la Crida d'Eines

Hem estat parlant d'eines com si l'agent simplement les "crida" -- com una crida de funcio al teu codi. Pero el que realment passa entre bastidors val la pena entendre, perque explica molt de comportament de l'agent que d'altra manera sembla misterios.

Quan envies un missatge a un agent, el LLM no executa codi. Genera text. La crida d'eines es una forma estructurada d'aquella generacio de text. Aqui esta el cicle:

+ *Tu envies un prompt.* "Quines taules existeixen a la base de dades?"
+ *El model veu les eines disponibles.* Juntament amb el teu missatge, el model rep una llista de totes les eines que pot usar -- els seus noms, descripcions i esquemes d'entrada. Aixo forma part del prompt del sistema o la configuracio d'eines, injectada pel framework d'agents abans que el model vegi el teu missatge.
+ *El model decideix cridar una eina.* En lloc de generar una resposta de text, el model emet una crida d'eina estructurada: el nom de l'eina i els arguments, formatats com a JSON. No esta "executant" res -- esta _demanant_ que el framework executi alguna cosa.
+ *El framework executa l'eina.* El framework d'agents agafa aquella sortida estructurada, valida els arguments contra l'esquema, i realment crida la funcio -- consulta la base de dades, llegeix el fitxer, crida l'API.
+ *El resultat torna al model.* La sortida de l'eina s'injecta a la conversa com un nou missatge, i el model genera la seva seguent resposta basant-se en aquell resultat.
+ *Repeteix.* El model podria cridar una altra eina, o podria finalment respondre't amb text. Les tasques complexes poden implicar deu, vint o mes crides d'eines en sequencia, cadascuna informada pels resultats de l'anterior.

Aquest es el bucle fonamental del comportament agentic. El model _pensa_ en que fer, _actua_ demanant una crida d'eina, _observa_ el resultat, i _pensa_ de nou. Es un bucle de raonament amb efectes secundaris del mon real.

Entendre aquest bucle explica diverses coses que confonen els nous usuaris d'agents:

*Per que els agents de vegades criden l'eina incorrecta.* El model tria eines basant-se en descripcions i el context de la conversa actual. Si dues eines tenen descripcions similars, el model podria triar la incorrecta. Si la descripcio es vaga, el model endevina. La seleccio d'eines es una tasca de _llenguatge_ -- el model esta fent correspondencia del teu request amb descripcions d'eines, no executant una taula de cerca.

*Per que els agents de vegades passen arguments incorrectes.* El model genera arguments com a text estructurat. Si l'esquema no esta clar sobre el que significa un parametre, el model omple la seva millor suposicio. Un parametre anomenat `id` sense descripcio podria ser un ID d'usuari, un ID de comanda, o un ID de fila de base de dades. El model endevinara basant-se en el context de la conversa, i de vegades endevinar malament.

*Per que els agents de vegades criden eines innecessariament.* El model no te una funcio de cost per a les crides d'eines. No sap que consultar la base de dades triga 200ms o que comprovar Datadog costa credits d'API. Si una eina _podria_ ser rellevant, el model podria cridar-la -- fins i tot quan la resposta ja es al context. Per aixo importa curar la llista d'eines.

*Per que els agents milloren amb millors descripcions.* Aquesta es la cosa mes important a interioritzar. La _unica_ informacio del model sobre una eina es el seu nom, descripcio i esquema de parametres. Millors descripcions porten a millor seleccio d'eines. Millors descripcions de parametres porten a millors arguments. Aixo no es una optimitzacio menor -- es la diferencia entre un agent que funciona i un que trontolla.

== Dissenyant Bones Eines

Si construeixes servidors MCP -- o fins i tot nomes configurant a quines eines pot accedir el teu agent -- el disseny d'eines importa enormement. Una eina ben dissenyada fa l'agent mes intel·ligent. Una de mal dissenyada el confon.

Aqui estan els principis que he apres per les males:

*Nomena les eines com a verbs, no com a substantius.* `get-deploy-status` es millor que `deploy-status`. `search-logs` es millor que `logs`. `create-ticket` es millor que `ticket`. El verb diu al model que _fa_ l'eina, la qual cosa l'ajuda a decidir _quan_ usar-la.

*Escriu descripcions per al model, no per als humans.* Podries escriure un README que diu "Consulta la base de dades PostgreSQL." Per a una descripcio d'eina, sigues especific: "Executa una consulta SQL de nomes lectura contra la base de dades PostgreSQL de produccio. Retorna resultats com a files JSON. Usa aixo quan necessitis comprovar dades, verificar esquemes, o investigar problemes relacionats amb dades. No l'uses per a operacions d'escriptura -- aquesta connexio es de nomes lectura i les escriptures fallaran." Com mes context dones al model sobre _quan_ i _com_ usar l'eina, millor funciona.

*Descriu cada parametre.* No nomes defineixis `{ query: z.string() }`. Defineix `{ query: z.string().describe("Una consulta PostgreSQL SELECT valida. No incloguis sentencies INSERT, UPDATE, DELETE, o DDL -- seran rebutjades per la connexio de nomes lectura.") }`. La descripcio es la documentacio del model. Si no donaries a un intern una funcio sense docstring i esperaries un us correcte, no ho facis al model.

*Retorna missatges d'error utils.* Quan una crida d'eina falla, el missatge d'error torna al model com a resultat de l'eina. Un bon missatge d'error permet al model autocorregir-se. "La consulta ha fallat: la columna 'user_id' no existeix. Volies dir 'id'? Columnes disponibles a la taula d'usuaris: id, email, name, created_at" es infinitament millor que "SQL error." El model llegira aquell error, entendrà l'error, i tornara a intentar-ho amb el nom de columna correcte. Un error vague porta a fallades repetides o arreglaments al·lucinats.

*Mantin les eines enfocades.* Una eina que fa una sola cosa be es millor que una eina que fa cinc coses basant-se en un parametre `mode`. `search-logs`, `get-log-entry`, i `count-log-events` son millors que `logs-tool` amb un camp `mode` que accepta "search", "get", o "count". Les eines enfocades tenen descripcions mes clares, esquemes mes simples, i menys modes de fallada. El model pot raonar sobre elles independentment.

*Limita la mida de la sortida.* Si una eina pot retornar megabytes de dades, ho fara -- i aquelles dades van a la finestra de context del model, desplacant tota la resta. Afegeix paginacio, truncament, o resum a les teves eines. Retorna les primeres 50 files, no totes les 50.000. Retorna fragments de log, no fitxers de log sencers. El model funciona millor amb dades enfocades i rellevants que amb una manguera contra incendis.

*Inclou exemples a les descripcions quan el format d'entrada no es obvi.* Si la teva eina espera una data en format ISO 8601, digues-ho: "Data d'inici en format ISO 8601, per exemple '2026-01-15T00:00:00Z'." Si espera un format d'ID especific, mostra'n un: "ID de servei, per exemple 'svc-checkout-prod'." Els exemples eliminen tota una classe d'errors de formatat.

Aquests no son preferencies d'estil arbitraries. Cada principi afecta directament la capacitat del model per usar l'eina correctament. He vist el mateix agent passar d'una taxa d'exit del 40% al 95% en una tasca, simplement reescrivint les descripcions d'eines i afegint documentacio de parametres. Les eines no van canviar. El model no va canviar. La _interficie_ entre ells va millorar.

Aquesta es la part del desenvolupament agentic que se sent mes com el disseny d'API -- perque aixo es exactament el que es. Les teves eines son una API per al model. Dissenya-les com dissenyaries qualsevol bona API: nomenclatura clara, documentacio exhaustiva, errors utils, i un principi de menys sorpreses.

== Recursos MCP: Donant als Agents Context, No Nomes Eines

Les eines permeten als agents _fer_ coses. Pero MCP tambe te un concepte anomenat *recursos* -- dades estructurades que els agents poden _llegir_. La distincio importa.

Una eina es una accio: "consulta la base de dades," "crea un tiquet," "comprova l'estat del desplegament." Un recurs es material de referencia: "l'esquema de la base de dades," "la documentacio de l'API," "el full de ruta actual del projecte."

Els recursos es carreguen al context de l'agent al principi d'una sessio o sota demanda. Son l'equivalent MCP d'obrir un document de referencia abans de comencar a treballar. No demanarIes a un nou company d'equip que comences a programar sense mostrar-li el diagrama d'arquitectura. Els recursos son com el mostres a l'agent.

Un exemple practic: construeixes un servidor MCP que exposa l'esquema de la teva base de dades com a recurs. Cada sessio d'agent comença amb l'esquema al context. Quan l'agent necessita escriure una consulta, no endevina els noms de taules -- ja els coneix. Quan necessita afegir una columna, sap que ja hi ha. El recurs es context passiu que fa millor cada crida d'eina.

La combinacio d'eines i recursos es potent. Els recursos donen a l'agent el _mapa_. Les eines li donen les _mans_. Junts, permeten a l'agent navegar per la teva infraestructura de la mateixa manera que tu -- amb tant coneixement com capacitat.

== Confiança i Baranes per a Agents Connectats

Aqui es on el capitol de baranes torna amb força.

Un agent amb acces al teu sistema de fitxers pot esborrar fitxers. Un agent amb acces a la teva base de dades pot esborrar _dades_. Un agent amb acces al teu pipeline de desplegament pot desplegar a produccio. Les apostes augmenten amb cada integracio que afegeixes.

Els principis de les baranes son els mateixos -- minim privilegi, portes d'aprovacio, valors per defecte de nomes lectura -- pero la implementacio ha de ser especifica per a cada integracio.

*Bases de dades: nomes lectura per defecte.* El teu servidor MCP de base de dades hauria de connectar-se amb un usuari de nomes lectura. L'agent pot consultar taules, inspeccionar esquemes, i entendre formes de dades. No pot inserir, actualitzar, ni esborrar. Si necessites acces d'escriptura per a tasques especifiques -- executar una migracio en una base de dades de desenvolupament, inserir fixtures de test -- utilitza un servidor separat amb una cadena de connexio separada, i nomes activa'l quan la tasca ho requereixi.

Una configuracio segura minimal:

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

*Gestio de projectes: llegir i comentar, no crear.* Deixa que l'agent llegeixi tiquets, cerqui issues, i afegeixi comentaris. No el deixis crear tiquets, tancar issues, o reassignar feina -- aquelles son decisions humanes amb consequencies humanes. L'enginyer que descobreixi que el seu agent ha tancat automaticament vint tiquets perque estaven "resolts pels canvis de codi" no tindra un bon mati.

*Monitoratge: nomes lectura, sempre.* L'agent llegeix logs, consulta metriques, i cerca traces. Mai modifica alertes, dashboards, o configuracions. Els sistemes de monitoratge son la _font de veritat_ durant incidents. Un agent que pot modificar aquella veritat es un agent que pot amagar problemes.

*Eines de comunicacio: procedeix amb extrema precaucio.* Donar a un agent acces a Slack significa que pot enviar missatges com tu. Pensa detingudament si "l'agent ha publicat a \#enginyeria" es alguna cosa amb la qual et sents comode. Si es aixi, delimita'l a canals especifics. Si no, deixa que l'agent _esborranyi_ missatges que tu revisis abans d'enviar.

El principi general: cada nova integracio es una nova superficie d'atac. Afegeix-les deliberadament, delimita-les estretament, i comença amb nomes lectura. Amplia els permisos nomes quan hagis vist prou sessions d'exit de nomes lectura per confiar en el flux de treball.

== Que Canvia Quan els Agents Ho Poden Veure Tot

Passa alguna cosa subtil quan dones a un agent acces al teu entorn de treball complet -- no nomes codi, sino logs, tiquets, documentacio, bases de dades, monitoratge. L'agent deixa de ser un generador de codi i comença a ser un _company d'enginyeria_.

El flux de treball de depuracio canvia. En lloc de "aqui hi ha un error, arregla'l," pots dir "els usuaris reportan un checkout lent. Investiga." L'agent comprova els logs, consulta la base de dades per a consultes lentes, llegeix l'historial recent de desplegaments, mira la taxa d'errors al monitoratge, i torna amb un diagnostic. Esta fent el que tu faries -- nomes que mes rapid, i sense l'impost de canviar de pestanya.

El flux de treball de planificacio canvia. "Necessito afegir una funcionalitat de notificacions. Comprova el model de dades existent, mira com vam construir el sistema de correu electronic (hi ha un tiquet de Linear sobre aixo), i proposa un enfocament." L'agent llegeix l'esquema, troba el tiquet, llegeix el codi relacionat, i produeix un pla que te en compte la teva arquitectura existent. No esta endevinant -- esta _informat_.

El flux de treball de resposta a incidents canvia. "Estem veient taxes d'error elevades. Comprova Datadog dels ultims trenta minuts, mira el desplegament mes recent, i digues'm que ha canviat." L'agent correlaciona logs, diffs i timestamps de desplegament, i acota el problema a un commit especific en menys d'un minut.

El flux de treball de desenvolupament mobil canvia -- i aquest encara em sorpren. Amb un servidor MCP d'Xcode, l'agent pot compilar la teva app d'iOS, engegar el simulador, navegar per les pantalles, i fer captures de pantalla per verificar la seva propia feina. Li dius "afegeix una pantalla de configuracio amb un commutador de mode fosc," i el veus escriure el SwiftUI, compilar el projecte, llançar el simulador, navegar fins a la nova pantalla, fer una captura de pantalla, notar que l'alineacio del commutador esta malament, arreglar-ho, recompilar, i fer una altra captura de pantalla. Tot el cicle -- codi, compilar, executar, verificar visualment, iterar -- passa sense que tu toquis Xcode. Es com programar en parella amb algu que tambe pot ser l'assistent de QA alhora.

Construir apps per a iPhone solia significar canviar context constantment entre el teu editor, Interface Builder, el simulador, la consola i el dispositiu. Ara l'agent gestiona el bucle compilar-executar-verificar mentre tu et centres en el que hauria de _fer_ l'app. L'he vist iterar a traves de tres rondes de refinament de la interficie en el temps que m'hauria trigat trobar el modificador SwiftUI correcte. El simulador engegant-se sol, l'agent navegant per la teva app, captures de pantalla apareixent a la conversa -- fa que el desenvolupament mobil sembli alguna cosa nou. No mes facil, exactament. _Mes fluid._ La distancia entre "vull aixo" i "puc veure que funciona" col·lapsa de minuts a segons.

Res d'aixo es magia. Es el que tu ja fas, manualment, cada dia. Les integracions d'eines simplement eliminen la friccio. L'agent fa la mateixa investigacio que tu faries -- nomes que ho fa sense els deu minuts de canviar de pestanya, iniciar sessio, construir consultes, i copiar sortida.

== El Problema de la Creep d'Integracio

Hi ha un mode de fallada aqui, i val la pena nombrar-lo: la creep d'integracio.

Comences amb una connexio de base de dades. Despres afegeixes Datadog. Despres Notion. Despres Slack. Despres Jira. Despres el teu panell d'administracio intern. Despres Stripe. Despres la teva plataforma d'analitiques. Aviat, el teu agent te acces a _tot_, i sorgeixen dos problemes.

Primer, *sobrecàrrega de context*. L'agent ara te tantes eines disponibles que gasta tokens decidint quina usar. Per a un canvi de codi simple, podria intentar comprovar logs de Datadog, consultar la base de dades, i llegir tiquets de Jira -- cap dels quals es rellevant. Mes eines significa mes oportunitats perque l'agent faci desviaments innecessaris.

Segon, *superficie de seguretat*. Cada integracio es un conjunt de credencials que l'agent pot usar. Cada una es un sistema amb el qual l'agent pot interactuar, intencionadament o accidentalment. Com mes integracions afegeixes, mes dificil es raonar sobre el que l'agent pot fer. Perds la capacitat de mantenir la imatge completa al cap -- la qual cosa es ironica, donat que el punt dels agents es gestionar la complexitat que no pots.

L'arreglament es el mateix que amb la gestio del context: cura deliberadament. No connectis tot perque pots. Connecta els sistemes que son _rellevants per a la feina que fas ara_. Utilitza configuracions per projecte -- el teu projecte de servei de facturacio es connecta a Stripe i la base de dades de facturacio; el teu projecte de frontend es connecta a Figma i el CDN. No tots els projectes necessiten totes les integracions.

Una heuristica util: si no tindries una pestanya del navegador oberta a aquell sistema durant una sessio de treball tipica en aquest projecte, l'agent tampoc necessita acces a ell.

== L'Ecosistema Es Jove

Vull ser honest sobre com estan les coses. MCP es real, funciona, i es el mes semblant a un estandard que tenim per a la integracio d'eines d'agents. Pero l'ecosistema segueix madurant.

Alguns servidors MCP son solids -- els servidors de base de dades oficials, el servidor de GitHub, el servidor del sistema de fitxers. Altres son projectes secundaris mantinguts per la comunitat que podrien fallar en casos extrems o quedar enrere en els canvis d'API. Abans de connectar el teu agent a un sistema critic a traves d'un servidor MCP de tercers, llegeix el codi font. Normalment son unes poques centenars de linies. Enten que fa, quins permisos demana, i on envia les dades.

El protocol en si segueix evolucionant. S'estan afegint noves capacitats -- respostes en streaming, fluxos OAuth, interaccions d'eines de multiples passos. Els servidors que configures avui podrien necessitar actualitzar-se en sis mesos. Esta be. El patro no canvia, fins i tot quan els detalls ho fan.

I algunes integracions que _haurien_ d'existir encara no ho fan. Si el teu equip utilitza una eina interna de nínxol, probablement hauris de construir el servidor MCP tu mateix. La bona noticia es que no es dificil -- unes quantes hores com a maxim per a un servidor basic de nomes lectura. La millor noticia es que un cop el construeixes, tots al teu equip se'n beneficien, i cada futura sessio d'agent te acces a aquell sistema.

Aquesta es la mateixa corba d'adopcio primerenca que hem vist amb cada ecosistema d'eines de desenvolupadors. La gent que inverteix ara -- construint servidors, contribuint a l'estandard, esbrinant els patrons -- tindra un avantatge significatiu quan l'ecosistema maduri. I madurara. El problema que MCP resol es massa real i massa universal perque no ho faci.

== Comença Aqui

Si vas a configurar una integracio avui, fes que sigui la teva base de dades. La capacitat de dir "comprova l'esquema per a la taula d'usuaris" o "quins indexs existeixen a la taula de comandes" elimina tota una categoria de canvis de context. Una connexio de base de dades de nomes lectura es de baix risc, alta recompensa, i triga cinc minuts a configurar.

Si vas a configurar dues, afegeix la teva eina de gestio de projectes -- GitHub Issues, Linear, Jira, el que faci servir el teu equip. La capacitat de dir "llegeix el tiquet PROJ-1234 i implementa-ho" o "quins tiquets em son assignats en aquest sprint" converteix l'agent d'un generador de codi en un executor de tasques.

Si vas a configurar tres, afegeix el teu stack de monitoratge. La capacitat d'investigar problemes de produccio sense sortir del teu terminal es una transformacio del flux de treball que, un cop experimentada, mai voldras abandonar.

Mes enlla d'aixo, deixa que la feina et guii. Quan et trobes copiant dades d'un sistema al context de l'agent mes de dues vegades, aixo es un senyal: construeix o instal·la el servidor MCP. La friccio que sents es la friccio que la integracio elimina.

Els agents ja son capaces. La pregunta es si poden veure prou del teu mon per ser utils. Les integracions d'eines son la resposta.
