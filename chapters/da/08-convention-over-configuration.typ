= Konvention Over Konfiguration

Jeg så den samme agent producere kode der var en senioransættelse værdig i ét projekt og uvedligeholdelig skrald i et andet — på den samme eftermiddag, på den samme maskine, med den samme model. Forskellen var ikke prompten. Det var codebasen.

To projekter. Samme tech stack — TypeScript, React, PostgreSQL. Samme holdstørrelse. Samme agentværktøj.

Projekt A har et strengt mappelayout. Hvert API-endpoint følger det samme mønster: en handler-fil, en skemafil, en testfil, navngivet identisk. Databaselaget bruger et konsistent repository-mønster. Der er en `CLAUDE.md` i roden der beskriver arkitekturen på to sider. Når en ingeniør peger en agent mod en ticket — "tilføj et nyt endpoint til brugernotifikationer" — læser agenten de eksisterende endpoints, følger mønstret og producerer en pull request der ser ud som om et menneske på holdet skrev den. Reviewet tager tre minutter.

Projekt B er den anden slags. Codebasen er vokset organisk over to år. Nogle endpoints er i `routes/`, nogle i `api/`, nogle i `handlers/`. Halvdelen af databaseforespørgslerne bruger en ORM, den anden halvdel bruger rå SQL. Der er ingen konsistent fejlhåndtering — nogle funktioner thrower, nogle returnerer fejlobjekter, nogle returnerer null. Agenten kigger på denne codebase og gør sit bedste, men "sit bedste" betyder at vælge det mønster den så senest. Den resulterende kode virker, teknisk set, men matcher ikke noget omkring den. Reviewet tager tredive minutter, det meste brugt på "sådan gør vi det ikke her."

Forskellen mellem disse projekter er ikke talent. Det er ikke værktøj. Det er konvention.

Der er et gammelt princip i software: konvention over konfiguration. Gør standarden til det rigtige. Reducér antallet af beslutninger der skal tages. Når alle følger de samme mønstre, forklarer koden sig selv.

Det princip var altid nyttigt for menneskelige teams. For agentisk ingeniørarbejde er det essentielt.

Hvis det lyder som om jeg fortæller dig at gøre det glamourløse arbejde — skrive dokumentation, håndhæve navnekonventioner, vedligeholde projektstruktur — så er det præcis det jeg gør. Og jeg ved hvordan det føles. Du blev ikke ingeniør for at skrive stilguider. Men det er et af de øjeblikke hvor håndværket beder dig om at bekymre dig om noget der plejede at føles som overhead, fordi indsatsen har ændret sig. Konvention plejede at være en høflighed mod dit fremtidige jeg. Nu er det operativsystemet dine agenter kører på.

== Hvorfor Agenter Elsker Konvention

En agent der navigerer i en ukendt codebase gør det samme som en nyansat: den leder efter mønstre. Hvor bor tests? Hvordan er filer navngivet? Hvad er importkonventionen? Hvor er konfigurationen?

Hvis dit projekt følger stærke konventioner, opfanger agenten mønstrene hurtigt og producerer kode der passer ind. Hvis hver fil er en snefnug — forskellige navne, forskellig struktur, forskellige stile — famler agenten. Den ved ikke hvilket mønster den skal følge, så den opfinder sit eget, og resultatet føles fremmed.

Der er en dybere grund til at konventioner er vigtige, og den hænger sammen med værktøjer. Konventioner virker fordi de gør agentens _værktøjer_ mere effektive. Når en agent kører `ls` eller `find` eller `grep`, betyder konsistent navngivning og struktur at de værktøjer returnerer nyttige resultater. Et projekt hvor tests altid bor i `__tests__/` betyder at `find . -name "*.test.ts"` altid virker. Konventioner er ikke bare implicit kontekst — de er det der gør agentens autonome udforskning produktiv.

Konvention er _implicit kontekst_. Det er information agenten absorberer fra strukturen af din kode uden at du behøver at forklare det. Når dine testfiler altid bor ved siden af de kildefiler de tester, navngivet `foo.test.ts` ved siden af `foo.ts`, behøver agenten ikke at få at vide hvor den skal putte en ny test. Den læser mappen, ser mønstret og følger det. Når dine API-handlers alle eksporterer den samme form — en handler-funktion, et skema, et sæt middleware — producerer agenten en ny handler der eksporterer præcis den samme form.

Det er derfor meningsfulde frameworks altid har været produktive, og hvorfor de er _endnu mere_ produktive i den agentiske æra. Rails, Next.js, Laravel — de påtvinger en struktur. Den struktur er ikke bare for mennesker. Det er et sprog agenten taler flydende.

== CLAUDE.md Dybt Dyk

En voksende konvention i agentisk ingeniørarbejde er `CLAUDE.md`-filen: et dokument i roden af dit projekt der fortæller agenten hvad den behøver at vide. Ikke en README til mennesker. En briefing til agenter.

Det er en af de ting med højest løftestangseffekt du kan gøre for dit agentiske workflow, og de fleste teams springer det enten over eller skriver et par vage linjer og kalder det gjort. Lad os snakke om hvad en god en faktisk ser ud.

En stærk `CLAUDE.md` har fem sektioner:

*Projektoversigt.* To eller tre sætninger. Hvad gør den her ting, hvad er tech stacken, hvad er deployment-målet. En agent der ved at den arbejder på "en B2B SaaS faktureringsplatform bygget med Go og PostgreSQL, deployet til Kubernetes" træffer fundamentalt anderledes beslutninger end en der gætter.

*Build- og testkommandoer.* Hver kommando agenten kan have brug for, listet eksplicit. Ikke "tjek Makefilen" — de faktiske kommandoer. Agenter læser dokumentation bogstaveligt. Hvis din `CLAUDE.md` siger `make test`, vil agenten køre `make test`. Hvis den siger "kør testene" uden at specificere hvordan, vil agenten gætte, og den gætter måske forkert.

*Arkitekturbeslutninger.* De ting der ikke er åbenlyse fra koden. Hvorfor du valgte en monorepo. Hvorfor auth-servicen er separat. Hvorfor du bruger event sourcing til ordrepipen men simpel CRUD til brugeradministration. Det er de beslutninger der former hvert stykke ny kode, og en agent der ikke kender dem vil bryde dem konstant.

*Konventioner.* Din stil. Hvordan du navngiver ting. Hvordan du håndterer fejl. Hvordan din importrækkefølge ser ud. Om du foretrækker tidlige returns eller nestede conditionals. De ting der får kode til at føles som om den hører til i _dette_ projekt.

*Almindelige faldgruber.* Hvor ligene er begravet. Databasemigrationen der altid skal køres før seed. Den environment variable der ikke er i `.env.example` men er påkrævet for betalingsflowet. Testen der er flaky på CI men ikke lokalt. Ethvert projekt har disse — skriv dem ned.

Her er hvad en rigtig `CLAUDE.md` ser ud for et mellemstort projekt:

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

Det er ikke langt. Det tog måske tredive minutter at skrive. Men hver agentsession der læser denne fil starter med mere kontekst end de fleste menneskelige udviklere får i deres første uge.

Den vigtigste disciplin: hold den opdateret. En forældet `CLAUDE.md` er værre end slet ingen, fordi agenten vil stole på den. Når du ændrer en konvention, opdater filen. Når du tilføjer en ny service, tilføj den til arkitektursektionen. Når nogen opdager en ny faldgrube, dokumenter den. Behandl den som kode — den lever i versionskontrol, den bliver reviewed i PR'er, den er en del af projektet.

Nogle teams går videre: de putter `CLAUDE.md`-filer i undermapper også. En `packages/api/CLAUDE.md` der dækker API-specifikke mønstre. En `packages/web/CLAUDE.md` der dokumenterer komponentbibliotekets konventioner. Jo dybere agenten går ind i projektet, jo mere specifik kontekst den får. Det er som et løg af dokumentation — bred kontekst ved roden, specifik kontekst efterhånden som du dykker ned.

== Konventioner Som Agenthukommelse

Konventioner er det tætteste agenter kommer på langtidshukommelse. Når du ser det, ændrer det hvordan du tænker om dem alle.

En agents kontekstvindue nulstilles hver session. Den husker ikke hvad den gjorde i går. Den husker ikke arkitekturdiskussionen du havde i sidste uge. Den husker ikke at de sidste tre gange den brugte `fetch` direkte, bad du den om at bruge API-client wrapperen i stedet.

Men din projektstruktur persisterer. Dine filnavne persisterer. Din `CLAUDE.md` persisterer. Dine linter-regler persisterer. Dine testmønstre persisterer. Alt du koder ind i formen af dit projekt er der hver gang agenten åbner sine øjne.

Det reframer konventioner fuldstændigt. De handler ikke bare om konsistens for mennesker. De er _ekstern hukommelse_ for agenter. Hver konvention du etablerer er en lektion agenten ikke behøver at genlære.

Tænk over hvad der sker uden konventioner. Session ét: agenten opretter et nyt endpoint og lægger fejlhåndteringen inline. Du retter det i review: "Vi bruger AppError-klassen." Session to: agenten opretter endnu et endpoint og laver den samme fejl, fordi den ikke husker session ét. Session tre: det samme. Du har den samme samtale igen og igen.

Tilføj nu én konvention — et dokumenteret fejlhåndteringsmønster, håndhævet af en linter-regel — og problemet forsvinder permanent. Agenten læser den eksisterende kode, ser mønstret, følger det. Linteren fanger enhver afvigelse. Lektien er kodet ind i selve projektet, ikke i nogens hukommelse.

Det er derfor de mest effektive agentiske teams er besat af konventioner der virker kedelige. Konsistent importrækkefølge. Streng filnavngivning. Standard funktionssignaturer. Det er ikke æstetiske præferencer — det er hukommelse. Det er holdets akkumulerede visdom, gemt i et format der overlever kontekstvindue-nulstillinger.

Analogien jeg bliver ved med at vende tilbage til: konventioner er for agenter hvad institutionel viden er for organisationer. En virksomhed hvor alt lever i én persons hoved er skrøbelig. En virksomhed med stærke processer og dokumentation er resilient. Det samme gælder for codebases. Et projekt hvor "hvordan vi gør tingene" kun lever i seniorudviklerens hukommelse er skrøbeligt. Et projekt hvor det er kodet ind i strukturen, værktøjerne og dokumentationen er resilient — for mennesker og agenter i lige mål.

== Praktiske Konventioner Der Hjælper Agenter

*Konsistent filnavngivning.* Hvis dine API-routes lever i `routes/`, dine modeller i `models/`, og dine tests i `__tests__/` — kan agenten navigere dit projekt uden et kort. Navngiv filer efter hvad de indeholder. Hold det kedeligt.

*Formatters og linters.* Værktøjer som Prettier, ESLint, `gofmt` eller Ruff er ikke bare til kodestil — de er guardrails der sikrer at agentgenereret kode matcher dit projekts standarder automatisk. Kør dem ved gem, kør dem i CI, gør dem ufravigelige.

*Standard projektlayout.* Uanset om det er Go standard-layoutet, Rails-konventioner eller dit teams egen struktur — vælg ét og hold dig til det. En `justfile` eller `Makefile` i roden der lister standardkommandoerne (`build`, `test`, `lint`, `dev`) giver agenter et indgangspunkt til ethvert projekt.

*Små, fokuserede filer.* Agenter arbejder bedre med filer under et par hundrede linjer. Når en fil indeholder én bekymring — én komponent, ét modul, ét sæt relaterede funktioner — kan agenten læse den, forstå den og modificere den uden at vade igennem urelateret kode.

*Beskrivende commit-beskeder.* Agenter læser git-historik. Et commit der siger "fix bug" lærer ingenting. Et commit der siger "fix race condition in session cleanup when WebSocket disconnects during auth" giver agenten kontekst om hvad der var vigtigt, hvad der var skrøbeligt, og hvordan holdet tænker om problemer.

*Konsistent fejlhåndtering.* Vælg et mønster og håndhæv det overalt. Custom fejlklasser med fejlkoder. En central fejlhåndterer. En standard fejlsvar-form. Når agenten støder på en fejlsituation i ny kode, bør der være nul tvetydighed om hvordan den skal håndteres. Hvis dit projekt bruger tre forskellige fejlhåndteringstilgange i tre forskellige filer, vil agenten producere en fjerde.

*Standard API-svarformater.* Hvert endpoint returnerer den samme form: `{ data, error, meta }` eller hvad du vælger. Statuskoder følger de samme regler overalt. Paginering virker på samme måde på hvert listeendpoint. Det er den slags konsistens agenter excellerer i at vedligeholde — men kun hvis konventionen er klar fra den eksisterende kode.

*Logningskonventioner.* Struktureret logning med konsistente felter. Hver logindgang inkluderer et request-ID, et tidsstempel og et alvorlighedsniveau. Hver fejllog inkluderer fejlkoden og et stack trace. Når agenten tilføjer logning til ny kode — og det bør den — skal loggen se identisk ud med alle andre logs i systemet.

*Mappestruktur der fortæller en historie.* En agent bør kunne `ls` topniveauet af dit projekt og forstå arkitekturen. Her er hvad et velstruktureret projekt ser ud fra en agents perspektiv:

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

Hvert mappenavn er et substantiv. Hver fil inden i indeholder præcis hvad mappenavnet lover. Der er intet sted at blive forvirret om hvor ny kode bør gå. En agent der læser denne struktur ved øjeblikkeligt: "Jeg skal tilføje en ny databaseforespørgsel, den hører til i `repositories/`. Jeg skal lave et nyt endpoint, det starter i `routes/`."

Sammenlign det med et projekt hvor databaseforespørgsler er spredt ud over handler-filer, forretningslogik lever i hjælpefunktioner, og der er tre forskellige mapper der alle ser ud til at indeholde "helpers." Agenten vil putte kode _et_ sted, men det er nok ikke det _rigtige_ sted.

== Konventionsskatten

Lad os være ærlige om omkostningen. At etablere konventioner tager tid, og det føles som overhead — særligt i starten.

At skrive en `CLAUDE.md` tager en eftermiddag. At sætte linters og formatters op tager en dag. At refaktorere en inkonsistent codebase til at følge ét enkelt mønster tager en uge, måske mere. At håndhæve konventioner i code review betyder at bremse PR'er der "virker fint" men ikke følger standarden.

Der er en reel fristelse til at springe alt dette over. Koden virker. Testene passerer. Hvorfor bruge tid på navnekonventioner når der er features der skal shippes?

Det ærlige svar: hvis du er en solotvikler der bygger en prototype til at smide væk, er konventionsskatten nok ikke det værd. Kør hurtigt, ship det, smid det væk.

Men i det øjeblik et andet par øjne rører din codebase — menneskelige _eller_ agent — begynder konventioner at betale sig selv. Og afkastet akkumulerer.

Første gang du etablerer en konvention koster det dig en time. Hver efterfølgende gang en agent følger den konvention i stedet for at spørge dig hvordan den skal håndtere det, sparer du fem minutter. Lav regnestykket: efter tolv agentsessioner har konventionen betalt sig selv. Efter hundrede sessioner har du sparet _timer_.

Det akkumulerer på tværs af holdet. Fem ingeniører, der hver kører multiple agentsessioner per dag, der alle drager fordel af de samme konventioner. Den initiale investering af én ingeniørs eftermiddag sparer holdet hundredvis af timer over et år.

De teams der investerer i konventioner tidligt ser langsommere ud i starten. De bruger tid på "kedelige" ting — linterkonfigurationer, projektstruktur, dokumentation. Men tre måneder inde producerer deres agenter kode der kræver minimal review. Seks måneder inde shipper de dobbelt så hurtigt som holdet der sprang konventionsarbejdet over. Et år inde er gabet pinligt.

Det er den samme dynamik som teknisk gæld, bare vendt om. Konvention er teknisk _formue_ — og ligesom finansiel formue, jo tidligere du begynder at investere, jo mere dramatisk er renters rente.

Den største fejl jeg ser er teams der venter til deres codebase er et rod før de forsøger at etablere konventioner. Det er det dyreste tidspunkt at gøre det. Det billigste tidspunkt er ved starten af et projekt — men det næstbilligste tidspunkt er i dag.

== Den Akkumulerende Effekt

Hver konvention du etablerer, hver standard du håndhæver, hvert stykke dokumentation du vedligeholder — det akkumulerer alt sammen. Hvert gør agenter en smule mere effektive, en smule mere autonome, en smule mere tilbøjelige til at producere kode der passer til dit projekt som en handske.

Men akkumuleringen er ikke bare additiv. Konventioner interagerer. En konsistent filnavnekonvention _plus_ en standard mappestruktur _plus_ en `CLAUDE.md` der beskriver arkitekturen — tilsammen giver disse agenten en mental model af hele projektet. Den ved hvor den finder ting, hvad den skal kalde dem, og hvordan de passer sammen. Fjern bare én af de tre, og agentens effektivitet falder uforholdsmæssigt.

Det er derfor halvhjertede konventioner er næsten lige så dårlige som ingen konventioner. Et projekt med konsistent filnavngivning men kaotisk mappestruktur sender blandede signaler. Agenten ser orden i én dimension og kaos i en anden, og den ved ikke hvilket signal den skal stole på.

De ingeniører der investerer i konvention tidligt har ikke bare renere codebases. De har codebases der er klar til den agentiske fremtid. Deres agenter producerer bedre resultater. Deres reviews er hurtigere. Deres iterationscyklusser er strammere.

Konvention er ikke glamourøst arbejde. Det er det mindst spændende kapitel i denne bog. Men det er det der får alle andre kapitler til at fungere. Sandboxene, teststrategierne, multi-agent orchestrationen — det hele fungerer bedre når den underliggende codebase er konsistent, dokumenteret og konventionel.

Din codebase er det miljø dine agenter lever i. Gør det læseligt. Gør det forudsigeligt. Gør det kedeligt. Agenterne vil takke dig ved at skrive kode der ser ud som om den hører til.
