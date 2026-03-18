= Udvidelse Af Agentens Rækkevidde

#figure(
  image("../../assets/illustrations/ch09b-mcp-connections.jpg", width: 70%),
)

Sidste måned debuggede jeg et produktionsproblem — periodiske 502-fejl på et checkout-endpoint. Loggene var i Datadog. Den relevante konfiguration var i vores Kubernetes-cluster. Ticket-historikken var i Linear. Databaseskemaet var i PostgreSQL. Koden var i min editor.

Jeg havde seks browser-faner åbne, kopierede og indsatte mellem dem, og forsøgte at samle nok kontekst til at forstå problemet. Agenten sad i min terminal, klar til at hjælpe, men den kunne kun se mine lokale filer. Det var som at have en genial kollega lænket til et skrivebord — ivrig efter at hjælpe, men blind for alt udenfor repoet.

Så satte jeg MCP-servere op til Datadog, vores database og Linear. Den næste debugging-session var anderledes. Jeg fortalte agenten: "Checkout-endpointet kaster periodiske 502-fejl. Tjek Datadog-loggene for den seneste time, kig på de relevante databasetabeller, og læs Linear-ticketen for kontekst." Agenten hentede logs, forespurgte skemaet, læste ticket-historikken, korrelerede tidsstemplerne og identificerede problemet på fire minutter: en connection pool-udtømning forårsaget af en manglende timeout på et downstream service-kald. Jeg kopierede ikke én eneste ting. Jeg skiftede ikke én eneste fane.

Det er hvad værktøjsintegrationer gør. De udvider agentens verden fra "filer på din disk" til "hvert system du arbejder med."

== Hvad Er MCP?

Model Context Protocol — MCP — er en åben standard til at forbinde AI-agenter med eksterne datakilder og værktøjer. Tænk på det som USB til agenter: et standardstik der lader enhver agent tale med enhver service, uden brugerdefineret integrationskode til hver kombination.

Før MCP betød at forbinde en agent til din database at skrive en skræddersyet wrapper. At forbinde den til Jira betød en anden wrapper. At forbinde den til Slack, endnu en. Hvert agentframework havde sit eget plugin-system, sit eget værktøjsdefinitionsformat, sin egen måde at håndtere autentificering på. Hvis du skiftede framework, omskrev du alt.

MCP standardiserer dette. En MCP-server er et lille program der eksponerer et sæt værktøjer — funktioner agenten kan kalde — over en konsistent protokol. Agentframeworket forbinder til enhver MCP-server på samme måde. Vil du give din agent adgang til PostgreSQL? Kør en Postgres MCP-server. Vil du have den til at læse dine Notion-docs? Kør en Notion MCP-server. Vil du have den til at forespørge din overvågningsstack? Der er en MCP-server til det.

Agenten ved ikke og bekymrer sig ikke om hvad der er bag protokollen. Den ser værktøjer: "forespørg databasen," "søg Notion-sider," "hent Datadog-logs." Den kalder dem på samme måde som den kalder ethvert andet værktøj — læs en fil, kør en kommando. MCP-serveren håndterer oversættelsen mellem agentens forespørgsel og det eksterne systems API.

Det er en større sag end det lyder. Det betyder at økosystemet af agentkapabiliteter vokser uafhængigt af noget enkelt agentframework. Nogen bygger en Stripe MCP-server, og _alle_ MCP-kompatible agenter kan nu arbejde med Stripe. Netværkseffekten er den samme der gjorde USB allestedsnærværende: én standard, mange enheder, alle drager fordel.

== Hvorfor Det Betyder Noget For Ingeniørarbejde

Hvis du har læst kontekstkapitlet, ved du at en agent kun er så god som det den kan se. Værktøjsintegrationer er måden du giver den øjne ud over filsystemet.

Overvej hvad en typisk ingeniøropgave faktisk involverer:

- *Koden* lever i dit repo.
- *Fejlrapporten* lever i Jira, Linear eller GitHub Issues.
- *Fejlloggene* lever i Datadog, Sentry eller CloudWatch.
- *Databaseskemaet* lever i PostgreSQL, MySQL eller MongoDB.
- *API-dokumentationen* lever i Notion, Confluence eller en wiki.
- *Deployment-status* lever i din CI/CD-platform.
- *Designspecifikationen* lever i Figma eller et Google Doc.

En agent med adgang kun til dit repo arbejder med måske 30% af den kontekst den har brug for. Resten er spredt over seks forskellige systemer, hvert med sin egen grænseflade, sin egen autentificering, sit eget forespørgselssprog. Du bruger din dag som et menneskeligt middleware-lag — kopierer fejllog fra Datadog, indsætter dem i agentens kontekst, kopierer agentens spørgsmål, slår svaret op i Confluence, indsætter det tilbage.

Værktøjsintegrationer eliminerer det middleware-lag. Agenten forespørger Datadog direkte. Den læser Notion-dokumentet selv. Den tjekker deployment-status uden at du skifter faner. Du går fra at være et udklipsholder til at være en kaptajn — giver retning i stedet for at fragte data.

== Den Praktiske Opsætning

At sætte MCP-servere op er enklere end det lyder. De fleste agentframeworks der understøtter MCP — Claude Code, Cline, Continue og andre — lader dig konfigurere servere i en JSON-fil. Her er hvad en typisk konfiguration ser ud:

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

Det er det. To servere. Din agent kan nu forespørge din database og interagere med GitHub — læse issues, tjekke PR-status, søge i kode. Serverne starter automatisk når agentsessionen begynder. Ingen kode at skrive. Ingen plugins at installere ud over MCP-serverpakkerne.

Økosystemet vokser hurtigt. Fra begyndelsen af 2026 er der community-vedligeholdte MCP-servere til:

- *Databaser:* PostgreSQL, MySQL, SQLite, MongoDB, Redis
- *Projektledelse:* GitHub, GitLab, Linear, Jira, Notion
- *Overvågning:* Datadog, Sentry, Grafana
- *Kommunikation:* Slack, Discord
- *Cloud:* AWS, GCP, Kubernetes
- *Dokumentation:* Confluence, Notion, Google Docs
- *API'er:* Generisk REST, GraphQL, OpenAPI-baserede servere

Du behøver ikke alle disse. Start med de to eller tre systemer du hyppigst skifter kontekst til. For de fleste ingeniører er det en database og et projektledelsesværktøj. Tilføj flere efterhånden som workflowet kræver det.

== Byg Din Egen MCP-Server

De eksisterende servere dækker almindelige værktøjer. Men hvert hold har interne systemer — et brugerdefineret admin-panel, et proprietært API, et internt deployment-værktøj, en skræddersyet datapipeline. Det er her det betaler sig at bygge din egen MCP-server.

En MCP-server er et lille program der implementerer MCP-protokollen og eksponerer værktøjer. Protokollen håndterer kommunikationen; du skriver værktøjerne. Her er hvad en minimal brugerdefineret server ser ud i TypeScript:

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

Det er en fungerende MCP-server. Den eksponerer to værktøjer: et til at tjekke en specifik services deployment-status, et andet til at liste nylige deployments. Agenten kan nu spørge "hvad er deployment-status for checkout-api?" og få et rigtigt svar fra dine interne systemer.

Mønstret er altid det samme: definer et værktøj med et navn, en beskrivelse, et skema for input, og en funktion der gør arbejdet. Beskrivelsen betyder mere end du tror — det er hvad agenten læser for at beslutte _hvornår_ den skal kalde dit værktøj. En vag beskrivelse som "gør deploy-ting" vil forvirre agenten om hvornår den skal bruge det. En præcis beskrivelse som "Get the current deployment status for a service, including version, health, and last deploy timestamp" giver agenten præcis den information den har brug for til at kalde det rigtige værktøj på det rigtige tidspunkt.

De fleste brugerdefinerede MCP-servere er under 200 linjer kode. Hvis du kan skrive en API-klient, kan du skrive en MCP-server. Investeringen er lille og afkastet er umiddelbart: din agent taler nu din infrastrukturs sprog.

== Hvordan Værktøjskald Faktisk Fungerer

Vi har talt om værktøjer som om agenten bare "kalder" dem — som et funktionskald i din kode. Men hvad der faktisk sker under hjelmen er værd at forstå, fordi det forklarer meget agentadfærd der ellers virker mystisk.

Når du sender en besked til en agent, udfører LLM'en ikke kode. Den genererer tekst. Værktøjskald er en struktureret form af den tekstgenerering. Her er cyklussen:

+ *Du sender en prompt.* "Hvilke tabeller eksisterer i databasen?"
+ *Modellen ser tilgængelige værktøjer.* Sammen med din besked modtager modellen en liste over hvert værktøj den kan bruge — deres navne, beskrivelser og inputskemaer. Det er en del af system-prompten eller værktøjskonfigurationen, injiceret af agentframeworket før modellen ser din besked.
+ *Modellen beslutter at kalde et værktøj.* I stedet for at generere et tekstsvar, outputter modellen et struktureret værktøjskald: værktøjets navn og argumenterne, formateret som JSON. Den "kører" ikke noget — den _anmoder_ om at frameworket kører noget.
+ *Frameworket udfører værktøjet.* Agentframeworket tager det strukturerede output, validerer argumenterne mod skemaet og kalder faktisk funktionen — forespørger databasen, læser filen, rammer API'et.
+ *Resultatet sendes tilbage til modellen.* Værktøjets output injiceres i samtalen som en ny besked, og modellen genererer sit næste svar baseret på det resultat.
+ *Gentag.* Modellen kan kalde et andet værktøj, eller den kan til sidst svare dig med tekst. Komplekse opgaver kan involvere ti, tyve eller flere værktøjskald i rækkefølge, hvert informeret af resultaterne fra det forrige.

Det er den fundamentale loop af agentisk adfærd. Modellen _tænker_ over hvad den skal gøre, _handler_ ved at anmode om et værktøjskald, _observerer_ resultatet og _tænker_ igen. Det er en ræsonnerings-loop med virkelige bivirkninger.

At forstå denne loop forklarer flere ting der snubler nye agentbrugere:

*Hvorfor agenter nogle gange kalder det forkerte værktøj.* Modellen vælger værktøjer baseret på beskrivelser og den aktuelle samtalekontekst. Hvis to værktøjer har lignende beskrivelser, kan modellen vælge det forkerte. Hvis beskrivelsen er vag, gætter modellen. Værktøjsvalget er en _sprog_-opgave — modellen mønstermatche din forespørgsel mod værktøjsbeskrivelser, ikke udfører et opslagsværk.

*Hvorfor agenter nogle gange sender forkerte argumenter.* Modellen genererer argumenter som struktureret tekst. Hvis skemaet ikke er klart om hvad en parameter betyder, udfylder modellen sit bedste gæt. En parameter kaldet `id` uden beskrivelse kunne være et bruger-ID, et ordre-ID eller et database-række-ID. Modellen gætter baseret på samtalekontekst, og den gætter nogle gange forkert.

*Hvorfor agenter nogle gange kalder værktøjer unødvendigt.* Modellen har ikke en omkostningsfunktion for værktøjskald. Den ved ikke at databaseforespørgsler tager 200ms eller at tjek af Datadog koster API-credits. Hvis et værktøj _muligvis_ er relevant, kan modellen kalde det — selv når svaret allerede er i kontekst. Det er derfor at kuratere værktøjslisten er vigtigt.

*Hvorfor agenter bliver bedre med bedre beskrivelser.* Det er den vigtigste ting at internalisere. Modellens _eneste_ information om et værktøj er dets navn, beskrivelse og parameterskema. Bedre beskrivelser fører til bedre værktøjsvalg. Bedre parameterbeskrivelser fører til bedre argumenter. Det er ikke en mindre optimering — det er forskellen mellem en agent der virker og en der tøver.

== Design Af Gode Værktøjer

Hvis du bygger MCP-servere — eller bare konfigurerer hvilke værktøjer din agent kan tilgå — betyder værktøjsdesign enormt. Et veldesignet værktøj gør agenten klogere. Et dårligt designet gør den forvirret.

Her er principperne jeg har lært på den hårde måde:

*Navngiv værktøjer som verber, ikke substantiver.* `get-deploy-status` er bedre end `deploy-status`. `search-logs` er bedre end `logs`. `create-ticket` er bedre end `ticket`. Verbet fortæller modellen hvad værktøjet _gør_, hvilket hjælper den med at beslutte _hvornår_ den skal bruge det.

*Skriv beskrivelser til modellen, ikke til mennesker.* Du skriver måske en README der siger "Forespørger PostgreSQL-databasen." Til en værktøjsbeskrivelse, vær specifik: "Execute a read-only SQL query against the production PostgreSQL database. Returns results as JSON rows. Use this when you need to check data, verify schema, or investigate data-related issues. Do not use for write operations — this connection is read-only and writes will fail." Jo mere kontekst du giver modellen om _hvornår_ og _hvordan_ den skal bruge værktøjet, jo bedre performer den.

*Beskriv hver parameter.* Definer ikke bare `{ query: z.string() }`. Definer `{ query: z.string().describe("A valid PostgreSQL SELECT query. Do not include INSERT, UPDATE, DELETE, or DDL statements — they will be rejected by the read-only connection.") }`. Beskrivelsen er modellens dokumentation. Hvis du ikke ville give en praktikant en funktion uden docstring og forvente korrekt brug, gør det ikke til modellen.

*Returnér nyttige fejlbeskeder.* Når et værktøjskald fejler, går fejlbeskeden tilbage til modellen som værktøjsresultatet. En god fejlbesked lader modellen selvkorrigere. "Query failed: column 'user_id' does not exist. Did you mean 'id'? Available columns in the users table: id, email, name, created_at" er uendeligt bedre end "SQL error." Modellen vil læse den fejl, forstå fejltagelsen og prøve igen med det korrekte kolonnenavn. En vag fejl fører til gentagne fejl eller hallucinerede fixes.

*Hold værktøjer fokuserede.* Et værktøj der gør én ting godt er bedre end et værktøj der gør fem ting baseret på en `mode`-parameter. `search-logs`, `get-log-entry` og `count-log-events` er bedre end `logs-tool` med et `mode`-felt der accepterer "search", "get" eller "count". Fokuserede værktøjer har klarere beskrivelser, enklere skemaer og færre fejltilstande. Modellen kan ræsonnere om dem uafhængigt.

*Begræns outputstørrelsen.* Hvis et værktøj kan returnere megabytes af data, vil det — og de data går ind i modellens kontekstvindue og fortrænger alt andet. Tilføj paginering, truncering eller opsummering til dine værktøjer. Returnér de første 50 rækker, ikke alle 50.000. Returnér log-uddrag, ikke hele logfiler. Modellen arbejder bedre med fokuserede, relevante data end med en brandslange.

*Inkluder eksempler i beskrivelser når inputformatet ikke er åbenlyst.* Hvis dit værktøj forventer en dato i ISO 8601-format, sig det: "Start date in ISO 8601 format, e.g. '2026-01-15T00:00:00Z'." Hvis det forventer et specifikt ID-format, vis et: "Service ID, e.g. 'svc-checkout-prod'." Eksempler eliminerer en hel klasse af formateringsfejl.

Disse er ikke vilkårlige stilpræferencer. Hvert princip påvirker direkte modellens evne til at bruge værktøjet korrekt. Jeg har set den samme agent gå fra 40% succesrate til 95% succesrate på en opgave, bare ved at omskrive værktøjsbeskrivelser og tilføje parameterdokumentation. Værktøjerne ændrede sig ikke. Modellen ændrede sig ikke. _Grænsefladen_ mellem dem blev bedre.

Det er den del af agentisk udvikling der føles mest som API-design — fordi det er præcis hvad det er. Dine værktøjer er et API til modellen. Design dem som du ville designe ethvert godt API: klart navngivning, omfattende dokumentation, hjælpsomme fejl og et princip om mindste overraskelse.

== MCP-Ressourcer: Giv Agenter Kontekst, Ikke Bare Værktøjer

Værktøjer lader agenter _gøre_ ting. Men MCP har også et koncept kaldet *ressourcer* — strukturerede data som agenter kan _læse_. Distinktionen er vigtig.

Et værktøj er en handling: "forespørg databasen," "opret en ticket," "tjek deployment-status." En ressource er referencemateriale: "databaseskemaet," "API-dokumentationen," "den aktuelle projekt-roadmap."

Ressourcer indlæses i agentens kontekst ved starten af en session eller efter behov. De er MCP-ækvivalenten til at åbne et referencedokument inden arbejdet begynder. Du ville ikke bede et nyt teammedlem om at begynde at kode uden at vise dem arkitekturdiagrammet. Ressourcer er måden du viser det til agenten.

Et praktisk eksempel: du bygger en MCP-server der eksponerer dit databaseskema som en ressource. Hver agentsession starter med skemaet i kontekst. Når agenten skal skrive en forespørgsel, gætter den ikke på tabelnavne — den kender dem allerede. Når den skal tilføje en kolonne, ved den hvad der allerede er der. Ressourcen er passiv kontekst der gør hvert værktøjskald bedre.

Kombinationen af værktøjer og ressourcer er kraftfuld. Ressourcer giver agenten _kortet_. Værktøjer giver den _hænderne_. Tilsammen lader de agenten navigere din infrastruktur på den måde du gør — med både viden og kapabilitet.

== Tillid Og Guardrails Til Forbundne Agenter

Her vender guardrails-kapitlet tilbage med fuld kraft.

En agent med adgang til dit filsystem kan slette filer. En agent med adgang til din database kan slette _data_. En agent med adgang til din deployment-pipeline kan pushe til produktion. Indsatserne eskalerer med hver integration du tilføjer.

Guardrails-principperne er de samme — mindste privilegium, godkendelsesporte, read-only som standard — men implementeringen skal være specifik for hver integration.

*Databaser: read-only som standard.* Din database MCP-server bør forbinde med en read-only bruger. Agenten kan forespørge tabeller, inspicere skemaer og forstå dataformer. Den kan ikke indsætte, opdatere eller slette. Hvis du har brug for skriveadgang til specifikke opgaver — kørsel af en migration i en dev-database, indsætning af testfixtures — brug en separat server med en separat forbindelsesstreng, og aktiver den kun når opgaven kræver det.

En minimal sikker opsætning:

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

*Projektledelse: læs og kommenter, ikke opret.* Lad agenten læse tickets, søge issues og tilføje kommentarer. Lad den ikke oprette tickets, lukke issues eller omtildele arbejde — det er menneskelige beslutninger med menneskelige konsekvenser. Ingeniøren der opdager at deres agent auto-lukkede tyve tickets fordi de var "løst af kodeændringerne" vil ikke have en god morgen.

*Overvågning: read-only, altid.* Agenten læser logs, forespørger metrikker og søger i traces. Den ændrer aldrig alarmer, dashboards eller konfigurationer. Overvågningssystemer er _sandheden_ under incidents. En agent der kan ændre den sandhed er en agent der kan skjule problemer.

*Kommunikationsværktøjer: fortsæt med ekstrem forsigtighed.* At give en agent adgang til Slack betyder at den kan sende beskeder som dig. Tænk grundigt over om "agenten postede i \#engineering" er noget du er fortrolig med. Hvis ja, scop det til specifikke kanaler. Hvis nej, lad agenten _udkaste_ beskeder som du gennemser inden afsendelse.

Det generelle princip: hver ny integration er en ny angrebsflade. Tilføj dem bevidst, scop dem stramt og start read-only. Udvid tilladelser kun når du har set nok vellykkede read-only sessioner til at stole på workflowet.

== Hvad Der Ændrer Sig Når Agenter Kan Se Alt

Noget subtilt sker når du giver en agent adgang til dit fulde arbejdsmiljø — ikke bare kode, men logs, tickets, docs, databaser, overvågning. Agenten holder op med at være en kodegenerator og begynder at være en _ingeniørpartner_.

Debugging-workflowet ændrer sig. I stedet for "her er en fejl, fix den," kan du sige "brugere rapporterer langsom checkout. Undersøg." Agenten tjekker loggene, forespørger databasen for langsomme forespørgsler, læser den seneste deployment-historik, kigger på fejlraten i overvågningen og kommer tilbage med en diagnose. Den gør hvad du ville gøre — bare hurtigere og uden fane-skifteskatten.

Planlægnings-workflowet ændrer sig. "Jeg skal tilføje en notifikations-feature. Tjek den eksisterende datamodel, kig på hvordan vi byggede e-mail-systemet (der er en Linear-ticket om det), og foreslå en tilgang." Agenten læser skemaet, finder ticketen, læser den relaterede kode og producerer en plan der tager din eksisterende arkitektur i betragtning. Den gætter ikke — den er _informeret_.

Incident-respons-workflowet ændrer sig. "Vi ser forhøjede fejlrater. Tjek Datadog for de seneste tredive minutter, kig på den seneste deployment og fortæl mig hvad der ændrede sig." Agenten korrelerer logs, diffs og deployment-tidsstempler, og indsnævrer problemet til et specifikt commit på under et minut.

Mobil-udviklings-workflowet ændrer sig — og det overrasker mig stadig. Med en Xcode MCP-server kan agenten bygge din iOS-app, spinne simulatoren op, navigere gennem skærme og tage screenshots for at verificere sit eget arbejde. Du fortæller den "tilføj en indstillingsskærm med en mørk tilstand-toggle," og du ser den skrive SwiftUI, bygge projektet, starte simulatoren, trykke ind til den nye skærm, tage et screenshot, bemærke at toggle-justeringen er forkert, fikse det, genbygge og screenshot igen. Hele cyklussen — kode, byg, kør, verificér visuelt, iterer — sker uden at du rører Xcode. Det er som parprogrammering med nogen der også _kan_ være QA-testeren på samme tid.

At bygge iPhone-apps plejede at betyde konstant kontekstskift mellem din editor, Interface Builder, simulatoren, konsollen og enheden. Nu håndterer agenten byg-kør-verificér-loopet mens du fokuserer på hvad appen skal _gøre_. Jeg har set den iterere gennem tre runder af UI-forfining i den tid det ville have taget mig at finde den rigtige SwiftUI-modifier. Simulatoren der spinner op af sig selv, agenten der trykker gennem din app, screenshots der dukker op i samtalen — det får mobiludvikling til at føles som noget nyt. Ikke nemmere, præcis. _Mere flydende._ Gabet mellem "jeg vil have dette" og "jeg kan se dette virke" kollapser fra minutter til sekunder.

Intet af dette er magi. Det er hvad du allerede gør, manuelt, hver dag. Værktøjsintegrationer fjerner bare friktionen. Agenten gør den samme undersøgelse du ville — den gør det bare uden de ti minutters fane-skift, indlogning, konstruktion af forespørgsler og kopiering af output.

== Integrationsudskridningsproblemet

Der er en fejltilstand her, og den er værd at navngive: integrationsudskridning.

Du starter med en databaseforbindelse. Så tilføjer du Datadog. Så Notion. Så Slack. Så Jira. Så dit interne admin-panel. Så Stripe. Så din analyseplattform. Inden længe har agenten adgang til _alt_, og to problemer opstår.

Først, *kontekstoverbelastning*. Agenten har nu så mange værktøjer tilgængelige at den bruger tokens på at beslutte hvilken en den skal bruge. For en simpel kodeændring kan den prøve at tjekke Datadog-logs, forespørge databasen og læse Jira-tickets — ingen af hvilke er relevante. Flere værktøjer betyder flere muligheder for at agenten tager unødvendige omveje.

For det andet, *sikkerhedsoverflade*. Hver integration er et sæt credentials agenten kan bruge. Hver er et system agenten kan interagere med, bevidst eller utilsigtet. Jo flere integrationer du tilføjer, jo sværere er det at ræsonnere om hvad agenten kan gøre. Du mister evnen til at holde hele billedet i hovedet — hvilket er ironisk, givet at hele pointen med agenter er at håndtere kompleksitet du ikke kan.

Løsningen er den samme som med kontekststyring: kurater bevidst. Forbind ikke alt fordi du kan. Forbind de systemer der er _relevante for det arbejde du laver nu_. Brug per-projekt konfigurationer — dit faktureringsservice-projekt forbinder til Stripe og fakturingsdatabasen; dit frontend-projekt forbinder til Figma og CDN'et. Ikke alle projekter har brug for alle integrationer.

En nyttig tommelfingerregel: hvis du ikke ville have en browser-fane åben til det system under en typisk arbejdssession på dette projekt, har agenten heller ikke brug for adgang til det.

== Økosystemet Er Ungt

Jeg vil være ærlig om hvor tingene står. MCP er reelt, det virker, og det er det tætteste vi har på en standard til agent-værktøjsintegration. Men økosystemet er stadig ved at modne.

Nogle MCP-servere er solide — de officielle databaseservere, GitHub-serveren, filsystemserveren. Andre er community-vedligeholdte sideprosjekter der kan knække på edge cases eller falde bagud på API-ændringer. Før du forbinder din agent til et kritisk system via en tredjepartss MCP-server, læs kildekoden. Det er normalt et par hundrede linjer. Forstå hvad den gør, hvilke tilladelser den anmoder om og hvilke data den sender hvor.

Protokollen selv udvikler sig stadig. Nye kapabiliteter — streaming-svar, OAuth-flows, multi-step værktøjsinteraktioner — tilføjes. De servere du sætter op i dag kan have brug for opdatering om seks måneder. Det er fint. Mønstret ændrer sig ikke, selv når detaljerne gør det.

Og nogle integrationer der _burde_ eksistere gør det endnu ikke. Hvis dit hold bruger et nicheinternt værktøj, skal du sandsynligvis bygge MCP-serveren selv. Den gode nyhed er at det ikke er svært — et par timer på det meste for en grundlæggende read-only server. Den bedre nyhed er at når du bygger den, drager alle på dit hold fordel, og hver fremtidig agentsession har adgang til det system.

Det er den samme early-adopter-kurve vi har set med hvert udviklerværktøjsøkosystem. De mennesker der investerer nu — bygger servere, bidrager til standarden, finder ud af mønstrene — vil have en betydelig fordel når økosystemet modner. Og det vil modne. Det problem MCP løser er for reelt og for universelt til at det ikke gør det.

== Start Her

Hvis du vil sætte én integration op i dag, så gør det til din database. Evnen til at sige "tjek skemaet for brugertabellen" eller "hvilke indekser eksisterer på ordretabellen" eliminerer en hel kategori af kontekstskift. En read-only databaseforbindelse er lav-risiko, høj-belønning og tager fem minutter at konfigurere.

Hvis du vil sætte to op, tilføj dit projektledelsesværktøj — GitHub Issues, Linear, Jira, hvad end dit hold bruger. Evnen til at sige "læs ticket PROJ-1234 og implementér den" eller "hvilke tickets er tildelt mig i denne sprint" forvandler agenten fra en kodegenerator til en opgaveeksekutør.

Hvis du vil sætte tre op, tilføj din overvågningsstack. Evnen til at undersøge produktionsproblemer uden at forlade din terminal er en workflow-transformation som, når man først har prøvet det, aldrig vil man give slip på.

Ud over det, lad arbejdet guide dig. Når du finder dig selv i at kopiere data fra et system ind i agentens kontekst mere end to gange, er det et signal: byg eller installer MCP-serveren. Den friktion du føler er den friktion integrationen fjerner.

Agenterne er allerede kapable. Spørgsmålet er om de kan se nok af din verden til at være nyttige. Værktøjsintegrationer er svaret.
