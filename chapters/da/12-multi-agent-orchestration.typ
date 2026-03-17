= Multi-Agent Orchestrering

Én agent er kraftfuld. Multiple agenter der arbejder sammen er noget helt andet.

Tænk på det sådan. En enkelt tømrer kan bygge et skur. Men et hus? Du har brug for en elektriker, en blikkenslager, en tagdækker — specialister der arbejder parallelt, hver fokuseret på det de gør bedst, der koordinerer lige nok til at holde sig ude af hinandens vej. Huset rejser sig hurtigere og arbejdet er bedre end hvis én person forsøger at gøre alt.

Agentisk ingeniørarbejde fungerer på samme måde. En enkelt agent på en kompleks opgave vil male sig igennem den sekventielt — planlæg, implementér, test, debug, iterer. Det virker, men det er langsomt. Tre agenter, der hver håndterer en velafgrænset del af problemet, kan afslutte på en tredjedel af tiden. Nogle gange mindre, fordi fokuserede agenter laver færre fejl end én agent der jonglerer for mange bekymringer.

Men der er en hage. Parallelle agenter kræver _koordinering_. Og koordinering har en omkostning. Dette kapitel handler om hvornår man skal betale den omkostning, og hvordan man betaler den godt.

== Nedbrydningsstrategier

Den sværeste del af multi-agent-arbejde er ikke at køre multiple agenter. Det er at beslutte hvordan man deler arbejdet op.

Den gyldne regel: opgaver skal have _minimal kobling_. Hvis agent A's arbejde afhænger af agent B's output, kan de ikke køre parallelt — de er sekventielle, og du bør behandle dem sådan. Kunsten er at finde sømme i dit arbejde hvor du kan skære rent.

Der er tre pålidelige nedbrydningsmønstre.

*Per lag.* Én agent håndterer backend-API'et, en anden bygger frontendkomponenten, en tredje skriver testene. Det virker godt fordi lag har naturlige grænser — en defineret grænseflade mellem dem. Så længe du aftaler API-kontrakten på forhånd, kan hver agent arbejde uafhængigt.

*Per feature.* Hvis du bygger tre uafhængige features, giv hver til en separat agent. Det er den simpleste nedbrydning. Featuresene rører forskellige filer, forskellige mapper, forskellige bekymringer. Merge-konflikter er sjældne.

*Per bekymring.* Én agent refaktorerer, en anden skriver tests til den refaktorerede kode, en tredje opdaterer dokumentationen. Det er et sekventielt mønster — mere pipeline end parallel — men det lader hver agent fokusere på en enkelt type tænkning. Refaktoreringsagenten behøver ikke at kontekstskifte ind i testskrivningstilstand. Den refaktorerer bare, og giver stafetten videre.

Den nedbrydning du vælger afhænger af arbejdets form. Men princippet er konstant: _find sømmene, skær langs dem, minimér overfladearealet hvor agenter skal være enige_.

== Branch-Per-Agent

Hver agent får sin egen branch. Vi dækkede dette i Git-kapitlet. I multi-agent-arbejde bliver det absolut essentielt.

Men branches alene er ikke nok. To agenter på forskellige branches der deler det samme arbejdsbibliotek vil kæmpe om filsystemet — de vil overskrive hinandens filer, korrumpere hinandens builds, bryde hinandens testkørsler. Du har brug for _worktrees_.

Hver agent får sit eget git worktree: et separat bibliotek, på sin egen branch, med sin egen kopi af codebasen. Agenterne deler historik men intet andet. De kan bygge, køre tests, installere afhængigheder og lave rod — alt uden at påvirke hinanden.

Opsætningen er hurtig:

```bash
git worktree add ../project-api agent/api-endpoint
git worktree add ../project-frontend agent/frontend-component
git worktree add ../project-tests agent/integration-tests
```

Tre biblioteker. Tre branches. Tre agenter. Fuld isolering. Det er sandboxmodellen fra tidligere kapitler gjort konkret for multi-agent-arbejde. Når en agent er færdig, reviewer du dens branch, merger hvis den er god, og fjerner worktree'et. Hvis arbejdet er dårligt, smider du det hele væk. Nul omkostning.

== Overleveringsmønstret

Ikke alt multi-agent-arbejde er parallelt. Nogle gange arbejder agenter _sekventielt_, hvor hver bygger på den forrige. Agent A planlægger. Agent B implementerer. Agent C reviewer.

Det er overleveringsmønstret, og det er kraftfuldt — men kun hvis selve overleveringen er ren.

Problemet med sekventielle agenter er konteksttab. Agent A har en rig forståelse af problemet når den er færdig med at planlægge. Agent B starter koldt. Hvis du bare fortæller Agent B "implementér planen," vil den misse nuancer. Den vil antage anderledes. Den vil løse et lidt anderledes problem end det Agent A planlagde for.

Fixet er _struktureret overlevering_. Agent A planlægger ikke bare — den producerer en artefakt der fanger dens ræsonnering. Det kan tage flere former:

- *Et sammendragsdokument.* En markdown-fil droppet i repoet: `PLAN.md`. Den beskriver hvad der skal ske, hvilke afvejninger der blev overvejet, hvad der blev afvist og hvorfor. Agent B læser dette før den skriver en eneste linje kode.
- *Et sæt filer.* Agent A opretter stub-filer — tomme funktioner med docstrings, grænsefladedefintioner, typesignaturer. Agent B udfylder dem. Stubbene _er_ overleveringen.
- *En struktureret prompt.* Agent A's output bliver Agent B's input, formateret som en detaljeret opgavebeskrivelse med acceptkriterier. Du paster den direkte ind i Agent B's kontekst.

Nøglen er at overleveringen skal være _eksplicit og komplet_. Ingen implicitte antagelser. Ingen "den næste agent finder nok ud af det." Enhver beslutning, enhver begrænsning, enhver edge case — skrevet ned.

Det kræver disciplin. Men det er den samme disciplin du ville anvende når du skriver en ticket til en menneskelig kollega på et andet kontinent og i en anden tidszone. Hvis du ikke ville stole på en mundtlig overlevering, stol ikke på en implicit en mellem agenter.

== Merge-Problemet

Her bliver multi-agent-arbejde genuint svært.

Tre agenter arbejdede parallelt. Hver producerede en ren, testet branch. Nu skal du merge dem alle ind i main. Nogle gange er det smertefrit — tre branches der rører helt forskellige filer merger uden en eneste konflikt. Smukt.

Nogle gange er det ikke. Agent A ændrede databaseskemaet. Agent B tilføjede en migration der antager det gamle skema. Agent C opdaterede API-handleren som både A og B også rørte. Nu har du en trevejes-konflikt og ingen enkelt agent har det fulde billede.

Der er tre strategier til at håndtere dette.

*Forebyggelse.* De bedste merge-konflikter er dem der aldrig sker. Når du nedbryder arbejde, tænk over filejerskab. Tildel forskellige mapper, forskellige moduler, forskellige filer til forskellige agenter. Hvis agenter aldrig rører den samme fil, kan de aldrig konflikte. Det er den billigste strategi og du bør bruge den når det er muligt.

*Merge-agenten.* Når konflikter opstår, spin en ny agent op hvis eneste job er at merge. Giv den branches, konflikterne og konteksten fra hver agents arbejde. En god merge-agent kan løse de fleste konflikter automatisk — den læser begge sider, forstår intentionen og producerer et sammenhængende resultat. Det er som en senioringeniør der sætter sig ned med to PR'er og finder ud af hvordan de passer sammen.

*Menneskelig review.* Nogle gange er konflikten semantisk, ikke syntaktisk. Koden merger rent men _logikken_ modsiger sig selv. To agenter tog inkompatible designbeslutninger. Ingen automatisk merge vil fange dette. Her er du tjener dine penge som ingeniør. Review branches før du merger. Læs diffs side om side. Sørg for at brikkerne faktisk passer sammen.

I praksis vil du bruge alle tre. Forebyg hvad du kan. Automatisér resten. Review alt.

== Orchestreringsoverhead

Flere agenter er ikke altid bedre.

Hver ekstra agent tilføjer koordineringsomkostninger. Du skal nedbryde arbejdet. Sætte worktrees op. Definere grænseflader. Håndtere merges. Reviewe multiple branches i stedet for én. For en opgave der tager en enkelt agent tredive minutter, kan det tage femogfyrre at spinne tre agenter op — tyve minutters parallelt agentarbejde plus femogtyve minutter af din tid til orchestrering.

Break-even-punktet er højere end du tror. Efter min erfaring begynder multi-agent orchestrering at betale sig når den samlede opgave ville tage en enkelt agent _mindst to timer_. Under det æder overheadet gevinsterne.

Der er også andre omkostninger. Kontekst fragmenteres. Hver agent ser kun sin del. Ingen enkelt agent forstår hele systemet på den måde én agent der arbejder alene ville. Det kan føre til inkonsistenser — forskellige navnekonventioner, forskellige fejlhåndteringsmønstre, forskellige antagelser om delt tilstand.

Færdigheden er ikke at køre så mange agenter som muligt. Færdigheden er at vide _hvornår_ man skal parallelisere og hvornår en enkelt fokuseret agent er det rigtige værktøj. Et mandskab på fem er ikke altid hurtigere end én erfaren sømand der kender båden.

== Et Praktisk Eksempel

Lad os gøre det konkret. Du bygger en webapplikation og du skal tilføje en ny feature: brugernotifikationer. Brugere skal se et klokkeikon med en tæller, klikke på det for at se en liste, og markere notifikationer som læst. Du har brug for et API, en frontendkomponent og tests.

Det er en lærebogssag for tre parallelle agenter.

*Trin 1: Definér grænsefladen.* Før du spinner nogen agenter op, bruger du fem minutter på at skrive API-kontrakten ned. `GET /api/notifications` returnerer en liste. `PATCH /api/notifications/:id` markerer én som læst. Notifikationsobjektet har `id`, `message`, `read`, `created_at`. Skriv dette i et delt dokument eller en stub-fil. Det er kontrakten alle tre agenter arbejder mod.

*Trin 2: Opret worktrees.*

```bash
git worktree add ../app-api agent/notifications-api
git worktree add ../app-frontend agent/notifications-frontend
git worktree add ../app-tests agent/notifications-tests
```

*Trin 3: Start agenterne.* Hver agent får en klar, afgrænset opgave:

- Agent 1: "Implementér notifications API-endpointene i `../app-api`. Følg kontrakten i `API_CONTRACT.md`. Inkludér model, route og controller. Skriv unit tests til controlleren."
- Agent 2: "Byg notifications UI-komponenten i `../app-frontend`. Den kalder `GET /api/notifications` og `PATCH /api/notifications/:id`. Vis et klokkeikon med ulæst-tæller. Klik åbner en dropdown-liste."
- Agent 3: "Skriv integrationstests i `../app-tests`. Dæk det fulde flow: opret en notifikation, hent listen, markér som læst, verificér at tælleren opdateres."

*Trin 4: Lad dem arbejde.* De tre agenter kører simultant. Hver committer til sin egen branch. Du overvåger fremskridt men griber ikke ind medmindre noget går galt.

*Trin 5: Review og merge.* Når alle tre er færdige, reviewer du hver branch. API-branchen merges først — den er fundamentet. Så frontend-branchen. Så testene. Du kører den fulde testsuite efter hvert merge for at fange integrationsproblemer tidligt.

Samlet tid: måske fyrre minutter. API-agenten tog tredive, frontendagenten tog femogtyve, og testagenten tog femogtredive. Men de kørte parallelt, så urfekketid var femogtredive minutter plus ti minutter af din orchestreringstid.

En enkelt agent der gør alt sekventielt? Sandsynligvis halvfems minutter.

Matematikken virker når opgaven er stor nok. Og efterhånden som du bliver bedre til nedbrydning, vil du udvikle en intuition for hvilke opgaver der er værd at splitte og hvilke der ikke er. Som det meste i ingeniørarbejde er det et vurderingskald. Men nu har du værktøjerne til at tage det.
