= Lokale LLM'er vs. Kommercielle LLM'er

En ven af mig — senioringeniør i en Series B-startup — pingede mig en fredag eftermiddag. "Jeg har lige fået vores første rigtige API-regning. Toogtyve hundrede dollars. For _marts_." Han havde kørt Claude Code på tværs af sit hold på otte ingeniører, som alle itererede på features, debuggede, refaktorerede. Ingen havde sat tokenbudgetter. Ingen holdt øje med måleren. Agenterne arbejdede fremragende, og regningen var til at få vand i øjnene af.

Samme uge talte jeg med en ingeniør i et sundhedsselskab i München. Hun kørte Llama 70B på en lokal GPU-server fordi deres patientdatapipeline ikke _måtte_ røre eksterne API'er. Ikke "burde ikke" — _måtte ikke_. Deres compliance-team havde gjort det klart skriftligt. Hun fik acceptable resultater til fokuserede opgaver, men hver gang hun havde brug for kompleks multi-fil-ræsonnering, faldt modellen fra hinanden og hun endte med at lave arbejdet manuelt.

Disse to historier er bogstøtterne for det samme spørgsmål: hvor kører modellen? Det lyder som en infrastrukturbeslutning. Det er i virkeligheden en beslutning om tillid, omkostninger, kapacitet og — i stigende grad — hvordan du arkitekterer hele dit agentiske workflow.

== Kommercielle LLM'er: Frontlinjen

Kommercielle modeller — Claude, GPT, Gemini — er hvor frontlinjen er. Hvis du laver seriøst agentisk ingeniørarbejde, har du sandsynligvis brugt det meste af din tid her. Der er gode grunde til det.

=== Kontekstvinduer

Kontekst er alt for agenter. En agent læser ikke bare din prompt — den læser filer, tool-outputs, fejlbeskeder, testresultater og sin egen tidligere ræsonnering. En enkelt kompleks opgave kan nemt fylde 50.000 tokens af kontekst, og en multi-step debugging-session kan blæse forbi 100.000.

Frontier kommercielle modeller tilbyder kontekstvinduer på 128K tokens og derover. Det betyder enormt meget for agentisk arbejde fordi agenten har brug for at holde din codebase i hovedet. Når konteksten løber tør, begynder agenten at glemme tidligere filer den læste, tidligere beslutninger den tog, tidligere fejl den så. Den degraderer fra en kapabel ingeniør til nogen med hukommelsestab.

Lokale modeller topper typisk ved 8K-32K kontekst i praksis, selvom de teknisk understøtter mere på papiret. Kvaliteten af opmærksomheden degraderer når du presser mod grænsen. En kommerciel model ved 100K kontekst ræsonnerer stadig godt. En lokal model ved 32K kontekst mister ofte tråden.

=== Tool Use-Kvalitet

Agenter lever og dør af tool use. At læse filer, skrive kode, køre kommandoer, søge i codebases — det er ikke valgfrie ekstra. Det er kerneloopet. Og kvaliteten af tool use varierer dramatisk mellem modeller.

Frontier kommercielle modeller er specifikt trænet og tunet til tool calling. De formaterer argumenter korrekt, de kæder tool calls logisk, de genopretter elegant når et tool call fejler. De ved hvornår de skal læse en fil før de redigerer den. De ved hvornår de skal køre tests efter de har lavet ændringer.

Mindre modeller — inklusive de fleste lokale modeller — er mindre pålidelige her. De hallucinerer filstier, glemmer at sende påkrævede argumenter, kalder tools i forkert rækkefølge eller sidder fast i loops der kalder det samme fejlende tool igen og igen. Forskellen er ikke subtil. På en kompleks opgave med ti eller femten tool calls, kan en frontier-model lykkes 90% af gangene hvor en lokal model lykkes 40%.

=== Instruktionsfølge

Når du fortæller en frontier-model "modificer kun filer i `src/auth/`-mappen" eller "ændr ikke det offentlige API, kun den interne implementering," lytter den generelt. Den følger system prompts, respekterer begrænsninger og holder sig inden for grænser.

Mindre modeller driver. De starter godt, og ignorerer gradvist dine begrænsninger efterhånden som samtalen bliver længere og konteksten fyldes op. Det er et reelt problem for agentisk arbejde, hvor præcision tæller. En agent der "for det meste" følger instruktioner vil af og til omskrive en fil du ikke bad den om at røre, eller refaktorere noget du eksplicit sagde den skulle lade være. I et sandboxet miljø er det bare irriterende. Uden sandbox er det farligt.

=== Valg Af Den Rigtige Kommercielle Model

Ikke alle kommercielle modeller er udskiftelige, selv på frontlinjen. Her er hvad jeg har fundet i praksis:

*Til kompleks multi-fil refaktorering og arkitekturarbejde* — brug den mest kapable model du har råd til. Det er her ræsonneringskvalitet betyder mest. Prisforskellen mellem en mid-tier og top-tier model er et par dollars per opgave. Kvalitetsforskellen er ofte forskellen mellem en ren diff og et rod du er nødt til at lave om manuelt.

*Til fokuserede single-fil-opgaver* — at skrive tests, implementere en veldefineret funktion, fikse en tydelig bug — performer mid-tier-modeller næsten lige så godt som top-tier, til en brøkdel af prisen. Opgaven er scopet nok til at modellen ikke behøver at jonglere mange bekymringer på én gang.

*Til højvolumen, lavkompleksitetsarbejde* — at generere boilerplate, formatere kode, skrive commit-beskeder — er den billigste model der kan følge instruktioner det rigtige valg. Du kører disse opgaver hundredvis af gange. Per-token-besparelsen akkumulerer.

Den fejl jeg ser oftest er at bruge en enkelt model til alt. Det er som at køre en Formel 1-bil i supermarkedet. Match modellen til opgaven.

== Lokale LLM'er: Det Fulde Billede

At køre en model lokalt — Llama, Mistral, Qwen, DeepSeek, Codestral, eller nogen af de open-weight modeller via Ollama, llama.cpp eller vLLM — giver dig noget kommercielle API'er ikke kan: komplet datasuverænitet og nul marginalomkostning per token.

Din kode forlader aldrig din maskine. Du kan fodre den med proprietær kildekode, interne dokumenter, produktionslogs, kundedata, API-nøgler du ved et uheld efterlod i en konfiguration — intet af det krydser en netværksgrænse. Og når modellen er downloadet, er hver inference gratis. Kør den tusind gange, kør den hele natten, ingen sender dig en regning.

Men lad os være ærlige om oplevelsen, fordi markedsføringen omkring lokale modeller ofte ikke er det.

=== Hardware-Virkeligheden

Hardwarespørgsmålet er det første alle spørger om, og svaret er mindre glamourøst end "kør AI lokalt!"-blogindlæggene antyder.

*MacBook Pro med Apple Silicon (M2/M3/M4 Pro eller Max, 32-64GB RAM).* Det er sweet spottet for individuelle udviklere. Du kan køre en 7B-14B parameter model komfortabelt, og en 32B model hvis du har RAM'en. Inference vil være mærkbart langsommere end en kommerciel API — måske 15-30 tokens per sekund for en 14B model, sammenlignet med 80+ fra en kommerciel API. En 70B model vil teknisk køre på en 64GB maskine men den vil være langsom nok til at teste din tålmodighed. Du vil vente 10-20 sekunder på svar der tager 2 sekunder fra en API.

*Dedikeret GPU-server (NVIDIA RTX 4090 eller A100).* Det er her lokal inference bliver oprigtigt hurtig. En 4090 med 24GB VRAM kan køre en 14B model ved næsten-kommercielle hastigheder. En A100 med 80GB kan køre en 70B model komfortabelt. Men nu vedligeholder du hardware. Du håndterer CUDA-drivere, VRAM-styring og den lejlighedsvise "hvorfor skriger min GPU-blæser klokken 3 om natten"-hændelse.

*Forbrugerhardware (16GB MacBook Air, ældre maskiner, ingen diskret GPU).* Du er begrænset til 7B-modeller, og oplevelsen vil være middelmådig. Inference er langsom, modellerne er for små til seriøst agentisk arbejde, og du vil bruge mere tid på at vente end på at arbejde. Jeg ville ikke anbefale dette til andet end eksperimentering.

Det ærlige sammendrag: lokale modeller er praktiske for udviklere med en nyere MacBook Pro eller en dedikeret GPU. Under den hardware-tærskel vil du have en frustrerende oplevelse. Over den vil du have et genuint nyttigt værktøj — bare et andet værktøj end en kommerciel API.

=== Hvor Lokale Modeller Skinner

Lokale modeller er ikke bare "dårligere kommercielle modeller." Der er workflows hvor de genuint giver mere mening:

*Højfrekvente, lavrisiko-opgaver.* At generere docstrings, skrive commit-beskeder, oprette boilerplate-kode, formatere data. Disse opgaver har ikke brug for en genimodel — de har brug for en hurtig, gratis model. At køre dem lokalt betyder at du kan fyre-og-glemme uden at tænke på omkostninger.

*Følsomme codebases.* Vi dækker dette mere i privatlivssektionen, men det er en legitim og voksende use case. Hvis din kode ikke kan forlade dit netværk, er lokale modeller den eneste mulighed, og "godt nok" er uendeligt bedre end "ikke tilgængeligt."

*Offline-udvikling.* I et fly, i et tog, i en bunker — din lokale model virker uden WiFi. Det lyder underordnet indtil du er på en tolv-timers flyvetur og prøver at debugge noget.

*Eksperimentering og læring.* Når du eksperimenterer med agent-frameworks, tester promptstrategier eller bygger custom tool-integrationer, føles det sløsende at brænde API-credits af på trial-and-error. En lokal model lader dig iterere frit.

=== Hvor Lokale Modeller Kæmper

Det er værd at være specifik om fejltilstandene, for "den er mindre kapabel" er for vagt til at være nyttigt.

*Multi-fil-ræsonnering.* Bed en lokal 14B-model om at spore en bug på tværs af fire filer og et databaseskema, og den mister tråden. Den finder måske den rigtige fil men misforstår interaktionen mellem komponenter. Det er det største praktiske gab.

*Langtidshorisontopgaver.* Agentiske opgaver der involverer mange trin — læs, planlæg, implementer, test, debug, iterer — kræver at modellen opretholder kohærent intention på tværs af en lang kontekst. Lokale modeller har tendens til at drive. De glemmer planen. De genbesøger beslutninger de allerede tog. De sidder fast i loops.

*Nuanceret code review.* "Denne kode er korrekt men tilgangen er forkert" er et vurderingskald der kræver dyb forståelse. Lokale modeller har tendens til overfladeanalyse — de fanger syntaksproblemer og åbenlyse bugs men misser arkitekturproblemer.

*Kompleks tool-orchestrering.* Når en opgave kræver ti eller flere kædede tool calls — at læse en testfil, køre den, læse fejlen, finde kildefilen, forstå konteksten, lave en ændring, køre testen igen — snubler lokale modeller hyppigere ved hvert trin, og fejlraten akkumulerer.

Intet af dette betyder at lokale modeller er ubrugelige. En 32B-model der kører lokalt kan håndtere en overraskende bred vifte af velscopede opgaver. Men du skal scope opgaverne tilsvarende. At bede en lokal model om at gøre hvad en frontier-model gør er at sætte den op til at fejle.

== Omkostningen Ved Agentisk Arbejde

En enkelt agentisk kodningssession kan nemt forbruge 100.000-500.000 tokens. Det overrasker folk når de ser tallene første gang. Ikke fordi du chatter — fordi agenten _arbejder_.

Overvej hvad der sker når en agent tackler et moderat komplekst bugfix. Den læser tre eller fire filer for at forstå konteksten (måske 8.000 tokens input). Den ræsonnerer om problemet (2.000 tokens output). Den læser to filer mere (4.000 tokens). Den skriver et fix (1.000 tokens). Den kører testene (tool call, 500 tokens output). Testene fejler. Den læser fejlen (1.000 tokens). Den reviderer fixet (1.500 tokens). Den kører testene igen. De passerer. Den læser diffen for at dobbeltjekke (1.000 tokens). Total: måske 25.000 tokens for et ligetil bugfix.

Overvej nu en kompleks refaktoreringsopgave. Agenten læser måske tyve filer, genererer en plan, implementerer ændringer på tværs af otte filer, kører testsuiten fire gange, debugger to regressioner og skriver nye tests. Det er nemt 200.000 tokens. Ved frontier-modelpriser er det et sted mellem \$3 og \$15 afhængigt af modellen og input/output-forholdet.

Her er grove prisintervaller jeg har set i praksis, baseret på brug af frontier kommercielle modeller:

- *Simpelt bugfix eller lille feature:* \$0,30-\$1,00
- *Moderat feature med tests:* \$2-\$5
- *Kompleks multi-fil refaktorering:* \$5-\$15
- *Stor feature-implementering:* \$15-\$40+
- *Eksplorativ debugging-session der trækker ud:* \$10-\$30

Gang disse tal med et hold af ingeniører, der hver kører flere agentiske opgaver per dag, og du kigger på rigtige penge. Min vens \$2.200-regning? Det passer nogenlunde for otte aktive ingeniører.

=== Strategier Til Omkostningsstyring

Løsningen er ikke at stoppe med at bruge agenter. Det er at være klog omkring det.

*Sæt tokenbudgetter.* De fleste agent-frameworks lader dig sætte en maksimal tokengrænse per opgave. Det er ikke bare omkostningskontrol — det er også et kvalitetssignal. Hvis en agent brænder 500.000 tokens af på en opgave der burde tage 50.000, er noget gået galt. Agenten sidder fast, looper eller misforstår opgaven. Et budget tvinger den til at fejle hurtigt i stedet for at spiralere.

*Brug model routing.* Send ikke hver opgave til den dyreste model. Vi dykker mere ned i dette i næste sektion, men kortversionen: brug en billig, hurtig model til udforskning og kodelæsning, og en kapabel dyr model til ræsonnering og implementering. Alene dette kan skære omkostninger med 50-70%.

*Cache aggressivt.* Hvis dit agent-framework understøtter prompt caching, slå det til. Meget af en agents kontekst gentages mellem ture — den samme system prompt, den samme projektkontekst, de samme nyligt læste filer. Caching undgår at genbehandle de tokens ved hvert tur.

*Scop opgaver stramt.* En velafgrænset opgave ("fix timezone-buggen i `billing/invoice.py`, testen er i `tests/test_invoice.py`") er billigere end en vag ("fix faktureringsbugsene"). Scoping er ikke bare godt ingeniørarbejde — det er omkostningskontrol. Agenten læser færre filer, laver færre eksplorative tool calls og konvergerer hurtigere.

*Gennemgå dine fejl.* Når en opgave fejler eller bruger alt for mange tokens, find ud af hvorfor. Var prompten vag? Manglede agenten kontekst den havde brug for? Var modellen ikke kapabel nok til opgaven? Hver fejl er en tuning-mulighed.

=== Styring Af Omkostninger På Tværs Af Et Hold

Individuel omkostningskontrol er én ting. At styre forbrug på tværs af et hold på otte eller tolv ingeniører, der hver kører agenter hele dagen, er et helt andet problem. Det er forskellen mellem at holde øje med din egen kost og at drive et restaurantkøkken.

*Per-ingeniør-budgetter.* Sæt et månedligt tokenbudget per ingeniør — ikke for at begrænse, men for at gøre omkostninger synlige. Når alle kan se deres eget forbrug, ændrer adfærden sig naturligt. Folk begynder at scope opgaver mere omhyggeligt, vælge den rigtige model til jobbet, dræbe løbske sessioner tidligere. Et rimeligt udgangspunkt: \$200-400 per måned per ingeniør for et hold der aktivt bruger agenter. Nogle ingeniører vil konsekvent komme ind under budget. Andre vil spike under intense debugging-uger. Det er fint — pointen er bevidsthed, ikke håndhævelse.

*Dashboard og synlighed.* Du kan ikke styre hvad du ikke kan se. Spor forbrug per ingeniør, per projekt, per opgavetype. De fleste API-udbydere giver dig forbrugsopdelinger per API-nøgle, og hvis du tildeler nøgler per ingeniør eller per projekt, er dataene allerede der. Led det ind i et dashboard holdet kan se — selv et delt regneark virker til at starte med. Ingeniøren der opdager at de brændte \$80 på en enkelt debugging-session vil naturligt begynde at scope opgaver strammere næste gang. Du behøver ikke at have en samtale om det. Tallet taler for sig selv.

*Alarmer og sikringsafbrydere.* Sæt alarmer ved 50% og 80% af det månedlige budget så ingen bliver overrasket. Vigtigere endnu, sæt en hård per-session tokengrænse som sikringsafbryder. Hvis en enkelt agentsession overstiger 500K tokens, er noget gået galt — agenten looper, opgaven er for vag, eller modellen kæmper med noget ud over dens kapacitet. Dræb den og undersøg om morgenen. Det er det der forhindrer "\$2.200 overraskelsesregning"-scenariet fra åbningen af dette kapitel. Du behøver ikke at fange hver løbsk session manuelt. Automatiserede grænser gør jobbet.

*ROI-samtalen.* På et tidspunkt vil nogen i ledelsen spørge hvorfor API-regningen er i femcifrede. Du har brug for regnestykket klar. Framing det sådan: en senioringeniør koster 150K dollars om året fuldt loaded. Hvis agenter gør dem 30% mere produktive, er det \$45K i værdi. Agentomkostningerne er \$3-4K per år per ingeniør. ROI'en er omkring 10x. Selv hvis du er konservativ — lad os sige 15% produktivitetsforøgelse i stedet for 30% — fungerer tallene stadig komfortabelt. Den sværere del er at måle den produktivitetsforøgelse præcist. Det kan du nok ikke, ikke med videnskabelig stringens. Men du kan tracke konkrete signaler: tid til merge af PR'er, antal opgaver fuldført per sprint, reduktion i kontekstskift. Par de metrikker med omkostningsdataene og du har en historie finans kan arbejde med.

*Omkostning som kvalitetssignal.* Højt tokenforbrug på en opgave er ikke bare dyrt — det er et signal om at noget gik galt. Opgaven var dårligt scopet, konteksten var utilstrækkelig, eller modellen var ikke kapabel nok til jobbet. Begynd at tracke omkostning per opgavetype over tid. Hvis omkostningerne for en bestemt kategori trender opad, undersøg — dine prompts kan have driftet, eller codebasen er blevet kompleks nok til at kræve en anden tilgang. Hvis omkostningerne trender nedad, er det dit hold der bliver bedre til agentisk ingeniørarbejde. De skriver strammere prompts, vælger bedre modeller og scoper opgaver mere effektivt. Omkostningsdata, brugt godt, bliver et spejl for holdets færdigheder.

== Privatliv og Compliance

Noget kode kan genuint ikke forlade bygningen. Det er ikke paranoia — det er lov.

Statslige entreprenører der arbejder med klassificerede eller eksportkontrollerede projekter kan ikke sende kildekode til tredjeparts-API'er, punktum. Kravene til dataopbevaring er ikke forslag. De kommer med strafferetlige sanktioner.

Sundhedsselskaber der håndterer patientdata er bundet af HIPAA, GDPR eller tilsvarende regulering. Hvis din kode rører patientjournaler — selv testfixturer med realistiske falske data som en compliance-officer kunne skele til — skal du tænke omhyggeligt over hvad der går over nettet.

Finansielle institutioner har deres eget labyrinth af regulering. SOX-compliance, PCI-DSS, interne revisionskrav — detaljerne varierer, men temaet er konsistent: data forbliver inden for kontrollerede grænser.

Og så er der ren og skær konkurrencehemmeligholdelse. Dine proprietære algoritmer, din hemmelige sauce, din konkurrencefordel — at sende det til andres servere kræver tillid til at de ikke træner på det, ikke logger det, ikke bliver kompromitteret. De fleste kommercielle API-udbydere tilbyder stærke kontraktmæssige garantier om dette. Men "stærke kontraktmæssige garantier" og "umuligt at bryde" er forskellige ting, og nogle sikkerhedsteams er ikke villige til at acceptere gabet.

I alle disse tilfælde er lokale modeller ikke nice-to-have. De er den eneste mulighed.

Afvejningen er reel: du accepterer reduceret modelkapacitet til gengæld for absolut datakontrol. En lokal 32B-model der gør et middelmådigt job på din klassificerede codebase er uendeligt mere nyttig end en frontier-model du ikke må bruge. Og til fokuserede, velscopede opgaver — den slags du bør skrive alligevel — er kvalitetsgabet ofte mindre end du forventer.

=== Mellemvejen: Private Deployments

Det er værd at nævne at der er en fremvoksende mellemvej. Cloud-udbydere tilbyder nu private model-deployments — dedikerede instanser af frontier-modeller der kører inde i din VPC, med kontraktmæssige garantier om at dine data forbliver inden for din grænse og ikke bruges til træning. AWS Bedrock, Azure OpenAI, Google Clouds Vertex AI tilbyder alle versioner af dette.

Det er ikke billigt. Du betaler for dedikeret compute, ikke delt API-infrastruktur. Men for store organisationer der har brug for frontier-kapacitet og streng datakontrol, er dette i stigende grad svaret. Du får kommerciel modelkvalitet med lokale model-privatlivsgarantier — for en pris.

== Model Routing I Praksis

Det rigtige spørgsmål er ikke "lokalt eller kommercielt?" Det er "hvilken model, til hvilken del af workflowet?"

Et sofistikeret agentisk setup router forskellige dele af workflowet til forskellige modeller. Det er ikke teoretisk — teams gør det i dag, og det er den retning økosystemet bevæger sig.

=== Routing-Mønstret

Tænk over hvad en agent faktisk gør under en typisk opgave:

+ *Udforskning* — at læse filer, søge i codebasen, forstå struktur. Det er højvolumen, lavræsonnerings-arbejde. Modellen skal beslutte hvilke filer den skal læse og udtrække relevant information, men den tænker ikke dybt.

+ *Planlægning* — at analysere problemet, overveje tilgange, beslutte en strategi. Det kræver stærk ræsonnering. Det er den del hvor modelkvalitet tæller mest.

+ *Implementering* — at skrive de faktiske kodeændringer. Det kræver god kodegenerering og evnen til at følge planen fra trin 2.

+ *Verifikation* — at køre tests, læse fejl, beslutte om arbejdet er gjort. Moderat ræsonnering, tungt tool use.

+ *Iteration* — hvis verifikation fejler, gå tilbage og justér. Det kræver forståelse af fejlen og at forbinde den tilbage til implementeringen.

Ikke alle disse trin har brug for den samme model. Trin 1 kan håndteres af en lille, hurtig, billig model — selv en lokal. Den læser filer og rapporterer hvad der er i dem. Trin 2 er hvor du vil have frontier-modellen — det er den dyre ræsonnering der retfærdiggør API-omkostningen. Trin 3-5 kan ofte håndteres af en mid-tier model, da den svære tænkning allerede er gjort og modellen eksekverer en plan.

=== Hvad Det Ser Ud Som

I praksis kan model routing være så simpelt som at konfigurere dit agent-framework til at bruge forskellige modeller til forskellige opgavetyper:

```
# Pseudocode — the exact config depends on your framework
exploration_model: "local/qwen-14b"       # Free, fast, good enough for reading
reasoning_model: "claude-sonnet"           # Frontier reasoning for planning
implementation_model: "claude-haiku"       # Fast, cheap, follows plans well
```

Eller det kan være dynamisk — en letvægtsklassifikator der kigger på det aktuelle trin og router tilsvarende. Nogle frameworks er begyndt at bygge dette ind nativt. Andre kræver at du selv kobler det sammen.

Økonomien er overbevisende. Hvis 60% af en agents tokens bruges på udforskning og simple opgaver, og du router dem til en model der er 10x billigere, har du skåret dine samlede omkostninger med mere end halvdelen uden nogen reduktion i kvalitet på de dele der tæller.

=== Routing For Privatliv

Model routing løser også privatlivsproblemet mere elegant end en alt-eller-intet tilgang.

Lad os sige du bygger en sundhedsapplikation. Datamodellerne og forretningslogikken rører patientdata — det skal forblive lokalt. Men frontendkomponenterne, build-konfigurationen, CI-pipelinen? De indeholder ikke følsomme data. Der er ingen grund til at du ikke kan bruge en frontier kommerciel model til de ikke-følsomme dele mens du router følsomt arbejde til en lokal model.

Det kræver værktøj der er bevidst om følsomhedsgrænser — hvilke filer kan gå eksternt, hvilke kan ikke. Det værktøj modnes stadig, men mønstret er klart. I stedet for "alt lokalt" eller "alt kommercielt" får du "lokalt hvor det betyder noget, kommercielt alle andre steder."

== Kom I Gang Uden At Betale Formuen

Du behøver ikke et budget for at begynde at lære agentisk ingeniørarbejde. Du behøver en laptop og en aften. Her er en praktisk rampe fra nul omkostninger til reel produktivitet.

=== Det Gratis Niveau

De fleste kommercielle udbydere tilbyder gratis niveauer eller prøvekreditter. Per tidligt 2026 kan du komme i gang med Claude, GPT eller Gemini uden at indtaste et kreditkort. De gratis niveauer er ratebegrænsede og kontekstbegrænsede, men de er mere end nok til at lære det grundlæggende — skriv din første agentiske prompt, se en agent iterere på en testfejl, få en fornemmelse for feedback loopet.

Par en gratis-niveau API-nøgle med et open source agent-framework — Claude Codes gratis niveau, eller Aider med dens gratis-model-support — og du har et komplet agentisk setup til nul kroner. Det vil ikke være hurtigt. Det vil ikke håndtere komplekst multi-fil-arbejde. Men det vil lære dig alt i kapitel to til fem af denne bog uden at bruge en krone.

=== Den Lokal-Først-Vej

Hvis du har en MacBook Pro med 16GB eller mere RAM, kan du køre nyttige modeller lokalt gratis, for evigt.

Installér Ollama — det tager én kommando. Pull en model — `ollama pull qwen2.5-coder:14b` tager et par minutter. Peg et agent-framework mod den. Du har nu et agentisk kodningssetup uden API-omkostninger, ingen ratebegrænsninger og ingen data der forlader din maskine.

Oplevelsen vil ikke matche en frontier kommerciel model. Kontekstvinduer er mindre. Multi-fil-ræsonnering er svagere. Tool use er mindre pålideligt. Men til fokuserede, velscopede opgaver — "skriv tests til denne funktion," "refaktorér denne klasse til at bruge dependency injection," "tilføj fejlhåndtering til dette endpoint" — er en lokal 14B-model overraskende kapabel. Og fordi den er gratis, kan du iterere uden at holde øje med måleren.

En praktisk startstack til nulomkostnings agentisk ingeniørarbejde:
- *Ollama* til model serving (gratis, lokal)
- *Qwen 2.5 Coder 14B* eller *DeepSeek Coder V2* til kodeopgaver
- *Aider* eller *Claude Code* (med lokal model-support) som agent-framework
- Et projekt med en testsuite (agenten har brug for feedback)

Det er det. Intet abonnement. Ingen API-nøgle. Ingen cloud compute. Du vil ramme loftet på et tidspunkt — en opgave der har brug for et større kontekstvindue, eller multi-fil-ræsonnering den lokale model ikke kan håndtere. Det er der du rækker ud efter en kommerciel model. Men det gratis setup vil bære dig længere end du forventer.

=== Sweet Spottet: \$20/Måned

Når du er klar til at bruge penge, er det mest omkostningseffektive setup jeg har fundet en kombination af lokale modeller til udforskning og et kommercielt abonnement til ræsonnering.

De fleste kommercielle udbydere tilbyder en udviklerplan i \$20/måned-intervallet der inkluderer en generøs tokentillæg. Brug dette til de opgaver der faktisk har brug for frontier-kapacitet — kompleks debugging, multi-fil refaktorering, arkitekturplanlægning. Brug din lokale model til alt andet — at læse kode, generere boilerplate, skrive commit-beskeder, køre igennem testiterationer.

Denne hybridtilgang dækker typisk 80-90% af en solo-udviklers agentiske arbejde. Den lokale model håndterer de højvolumen, lavræsonnerings-opgaver. Den kommercielle model håndterer de øjeblikke der har brug for ægte intelligens. Din månedlige regning forbliver forudsigelig, og du vælger ikke mellem kvalitet og omkostninger — du bruger hver hvor det giver mening.

=== Skaler Op Med Intention

Fejlen er at starte med den dyreste mulighed og optimere bagefter. Start gratis. Lær workflows. Forstå hvor modelkvalitet faktisk tæller og hvor "godt nok" er godt nok. Brug derefter penge på de specifikke huller som gratis værktøjer ikke kan udfylde.

Når du bruger rigtige penge på API-kald, vil du vide præcis hvad du betaler for — og vigtigere, hvad du _ikke_ betaler for. Den viden er mere værd end nogen mængde kreditter.

== Landskabet Skifter

Seks måneder fra nu vil detaljerne i dette kapitel være forældede. Priserne vil ændre sig. Kapacitetsgabene vil indsnævres. En ny model vil komme ud der omblander rangeringerne. Det er den ene forudsigelse jeg vil lave med tillid.

Hvad der ikke ændrer sig er rammen for at tænke om det. Du vil stadig have brug for at evaluere modeller langs de samme akser: kapacitet, omkostning, privatliv, hastighed og pålidelighed. Du vil stadig have brug for at matche modellen til opgaven i stedet for at vælge én model og bruge den til alt. Du vil stadig have brug for at forblive fleksibel.

De ingeniører jeg ser gøre det bedste arbejde er ikke loyale over for nogen bestemt model eller deployment-tilgang. De er pragmatikere. De bruger frontier kommerciel model når opgaven kræver det, en mid-tier model når den er god nok, og en lokal model når privatliv eller omkostning kræver det. De måler hvad der virker. De skifter når noget bedre kommer.

Bliv ikke religiøs omkring dette. Modellen er et værktøj. Færdigheden er at vide hvilket værktøj man skal gribe efter — og den færdighed overføres uanset hvilke modeller der eksisterer seks måneder fra nu.
