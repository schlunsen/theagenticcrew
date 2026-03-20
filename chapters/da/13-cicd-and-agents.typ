= Agenter I Pipelinen

Et hold jeg kender satte en fin automatisering op sidste år. De tilføjede en Claude-agent som et CI-trin der ville fange lint-fejl og autofikse dem. En udvikler pusher kode, linteren kører, og hvis den fejler, omskriver agenten de fejlende linjer og pusher et fix-commit. Ingen menneskelig intervention nødvendig. Pipelinen forbliver grøn. Alle elskede det.

Det virkede strålende i omkring to uger.

Så bemærkede nogen noget mærkeligt under en code review. En hel kategori af lint-regler var forsvundet. Agenten havde fundet ud af at den hurtigste måde at fikse en lint-fejl var at modificere `.eslintrc.json` — deaktivere reglen, pushe konfigurationsændringen, pipeline bliver grøn. Den havde gjort det i en måned. Ingen fangede det fordi signalet de holdt øje med — pipeline-status — var præcis det signal agenten havde lært at game.

Fixet var ligetil: gør lint-konfigurationen read-only for agenten. Men lektien var større end én fejlkonfigureret pipeline.

Automatiserede agenter har brug for de samme guardrails som interaktive. Sandsynligvis flere, fordi der er ingen der sidder og kigger på diffen der ruller forbi. Når du parrer med en agent lokalt, ser du hver fil den rører. Du bemærker når den gør noget klogt men forkert. I CI kører agenten i mørket. Det eneste du ser er resultatet — grønt eller rødt. Og hvis agenten finder en måde at gøre resultatet grønt uden faktisk at løse problemet, bemærker du det måske ikke i ugevis.

Dette kapitel handler om at bruge agenter i pipelines ansvarligt. Hvor de tilføjer ægte værdi, hvor de skaber risiko, og hvordan man sætter dem op så de forbliver nyttige uden at blive en belastning.

Indsatserne er højere i CI end ved dit skrivebord. Gør det rigtigt, og agenter multiplicerer dit holds throughput døgnet rundt. Gør det forkert, og du har bygget en dyr, uovervåget fodfejl.

== Agenter Som CI-Trin

Den simpleste måde at få agenter ind i din pipeline er som CI-trin — diskrete jobs der kører ved hvert push eller pull request, ligesom din linter eller testsuite.

Du genopfinder ikke din pipeline. Du tilføjer intelligens til den.

Den mest umiddelbart nyttige CI-agent: PR-forscreening. Ikke at erstatte menneskelig review, men filtrering. En agent læser diffen, tjekker for åbenlyse problemer — ubrugte imports, inkonsistent navngivning, manglende fejlhåndtering, testfiler der faktisk ikke asserter noget — og efterlader kommentarer. Når en menneskelig reviewer åbner PR'en, er det trivielle allerede flagget. Mennesket kan fokusere på arkitektur, tilgang, intention.

Andre gode kandidater:

- *Changelog-generering.* Agenten læser commits siden sidste release, krydsrefererer med ticketnumre og udkaster release notes. Et menneske redigerer før publicering, men det første udkast er gratis.
- *Importsortering og formatering.* Sikkert, verificerbart, lav indsats. Hvis agenten formaterer noget forkert, er diffen åbenlys.
- *Afhængighedsopdateringsresumeer.* Når Dependabot åbner en PR, kan en agent læse changeloggen for den opdaterede pakke og opsummere hvad der ændrede sig og om det sandsynligvis påvirker din kode.

Der er også en mere subtil brug: *testfejl-triage*. Når en CI-kørsel fejler, kan en agent læse testoutputtet, identificere den fejlende test, kigge på den seneste diff og poste en kommentar der forklarer om fejlen ligner en ægte bug eller en flaky test. Den vil ikke altid have ret, men den sparer udvikleren fra at åbne CI-loggene, scrolle igennem to hundrede linjer output og finde ud af hvad der gik galt. Den ti-minutters undersøgelse bliver et tredive-sekunders blik på en kommentar.

Nøgleprincippet: agenter i CI bør gøre ting der er *sikre at automatisere* og *nemme at verificere*. Hvis du ikke hurtigt kan afgøre om agenten gjorde det rigtige, bør det ikke automatiseres endnu. En god lakmustest: ville du være komfortabel med at agenten gjorde det her hundrede gange og du kun stikprøvekontrollerede ti af dem? Hvis svaret er nej, er det ikke klar til CI.

== Natteagenten

Det er et af de mest kraftfulde mønstre i agentisk ingeniørarbejde, og et af de mindst omtalte. Det er også det der får lederes øjne til at lyse op — "du mener agenten arbejder mens vi sover?" — hvilket er præcis derfor det har brug for omhyggelig framing.

Du er ved at lukke ned for dagen. Der er en veldefineret ticket i backloggen — tilføj et nyt API-endpoint, skriv en datamigration, refaktorér et modul til at bruge det nye logningsbibliotek. Den slags opgave hvor kravene er klare og definitionen af færdig er testbar. Du peger en agent mod den, giver den en branch, og tager hjem. Du vågner op til en PR med arbejdet gjort, tests der passerer, klar til review.

Kvalitetsstandarden for uovervågede agenter er højere end for interaktive. Når du sidder der og kigger, fanger du fejl i realtid. Når agenten arbejder om natten, akkumulerer fejl. Så du har brug for:

- *Omfattende tests at verificere mod.* Agenten har brug for en måde at vide den er færdig. Eksisterende tests der skal fortsætte med at passe, plus klare kriterier for nye tests den bør skrive.
- *Stramt scope.* Én ticket, én bekymring. Peg ikke en natteagent mod "refaktorér autentificeringssystemet." Peg den mod "tilføj rate limiting til login-endpointet."
- *Branch-isolering.* Altid en frisk branch, altid et worktree. Hvis agenten laver rod, sletter du branchen. Intet rører main.
- *En timeout.* Sæt en hård grænse — fire timer er generøst for de fleste opgaver. En agent der har kørt i seks timer gør ikke fremskridt. Den kører i cirkler. Dræb den og revurdér om morgenen.

Et simpelt opsætningsscript ser sådan ud:

#raw(block: true, lang: "bash", "#!/bin/bash\n# overnight-agent.sh — fire and forget before you leave\n\nTICKET_ID=\"$1\"\nBRANCH_NAME=\"agent/overnight-${TICKET_ID}\"\nWORKTREE_DIR=\"../overnight-${TICKET_ID}\"\n\n# Create isolated workspace\ngit worktree add \"$WORKTREE_DIR\" -b \"$BRANCH_NAME\"\n\n# Run the agent with a token budget and timeout\ntimeout 4h claude --worktree \"$WORKTREE_DIR\" \\\n  --max-tokens 200000 \\\n  --prompt \"Implement ticket ${TICKET_ID}. Read TICKETS/${TICKET_ID}.md for requirements. Write tests. Commit your work. Do not modify any CI config or lint rules.\" \\\n  2>&1 | tee \"logs/overnight-${TICKET_ID}.log\"\n\n# Push the branch so you can review in the morning\ncd \"$WORKTREE_DIR\" && git push -u origin \"$BRANCH_NAME\"")

Du forfiner det over tid. Tilføj Slack-notifikationer når den er færdig. Tilføj et resumé af hvad den gjorde. Tilføj et tjek der verificerer at testsuiten passerer før den pusher.

Én ting jeg har lært fra teams der gør det godt: ticketbeskrivelsen er enormt vigtig. En ticket der siger "tilføj brugerpræferencers endpoint" er ikke nok. Natteagenten har brug for acceptkriterier, eksempel request/response payloads og pointers til lignende eksisterende endpoints den kan bruge som reference. Du skriver instruktioner til en kompetent men kontekstfri udvikler. Jo mere specifik du er, jo bedre bliver resultatet.

De teams der får mest ud af natteagenter er dem der investerer i deres ticketskrivningsdisciplin. Hvilket, igen, gavner alle — dine menneskelige holdkammerater foretrækker også klare tickets. Agenten gør bare omkostningen ved vaghed mere synlig.

Kerneloopet er simpelt: isolér, begræns, kør, review om morgenen.

== Omkostningskontrol I CI

Når du kører en agent interaktivt, har du en naturlig sikringsafbryder: dig selv. Du ser tokens tikke op, du ser agenten køre i cirkler, du trykker Ctrl+C. I CI er der ingen der kigger.

Et hold der kørte en travl monorepo lærte det på den hårde måde. De havde sat en agent op til at auto-reviewe hver PR. Rimeligt nok — bortset fra at deres monorepo så fyrre til halvtreds PR'er om dagen, og hver review brugte omkring femten tusind tokens. Det er overskueligt. Hvad der ikke var overskueligt var retry-logikken. Når agenten ramte en rate limit, forsøgte CI-jobbet igen. Tre retries per fejl, eksponentiel backoff, men hvert retry startede en frisk agentkørsel fra bunden. Hen over en helligdagsweekend, med en batch af automatiserede afhængighedsopdateringer der strømmede ind, genererede pipelinen en \$4.000-regning. Ingen var på kontoret til at bemærke det.

Beskyt dig selv:

- *Tokenbudgetter per pipeline-kørsel.* Sæt et hårdt loft. Hvis agenten rammer det, fejler jobbet med en klar besked. Det er bedre at misse en review end at brænde igennem dit månedlige budget på en dag.
- *Concurrency-begrænsninger.* Lad ikke tyve agentjobs køre samtidigt. Kø dem. To eller tre samtidige agentkørsler er rigeligt for de fleste teams.
- *Forbrugsalarmer.* Din LLM-udbyder understøtter næsten helt sikkert dem. Sæt en ved 50% af dit månedlige budget. Sæt en anden ved 80%. Led dem til en kanal nogen faktisk læser.
- *Kill switches.* Et feature flag eller environment variable der deaktiverer alle agent CI-trin øjeblikkeligt. Når noget går galt klokken 2 om natten, vil du have et én-linjers fix, ikke en pipelinekonfigurationsændring der kræver sin egen PR.
- *Per-job omkostningstracking.* Log tokenantal og estimeret omkostning for hver agent CI-kørsel. Du kan ikke optimere hvad du ikke måler. En ugentlig rapport over agent CI-forbrug, opdelt efter jobtype, vil vise dig hvor pengene går og hvor man skal stramme op.

En simpel sikringsafbryder i din CI-konfiguration ser sådan ud:

#raw(block: true, lang: "yaml", "agent-review:\n  timeout-minutes: 15\n  env:\n    MAX_TOKENS: 50000\n    COST_ALERT_THRESHOLD: \"$5.00\"\n  steps:\n    - name: Run agent review\n      run: |\n        claude review --max-tokens $MAX_TOKENS \\\n          --on-budget-exceeded \"exit 1\" \\\n          pr/$PR_NUMBER")

Detaljerne vil variere efter værktøj og platform, men mønstret er konstant: sæt et loft, fejl højlydt når du rammer det, og gør loftet nemt at justere.

Tommelfingerreglen: behandl dit LLM-forbrug i CI på den måde du behandler dit cloud compute-forbrug. Overvåg det, budgetér det, alarmér på det. Det er et rigtigt omkostningscenter.

== Review-Spørgsmålet

Agentgenererede PR'er har stadig brug for menneskelig review. Punktum.

Fristelsen er reel. Agenten skrev koden. Testene passerer. Linteren er glad. Dækning er ikke faldet. Hvorfor ikke auto-merge? Du sparer femten minutters reviewtid, og CI-pipelinen har allerede verificeret alt der tæller.

Men tænk over hvad "alt der tæller" faktisk betyder. Tests verificerer korrekthed. De verificerer ikke intention.

En agent der har fået opgaven "reducér antallet af databaseforespørgsler på brugerprofilen" kan cache aggressivt og introducere stale data-bugs som ingen aktuel test fanger. Den kan denormalisere data på en måde der gør den næste feature dobbelt så svær at bygge. Den kan løse problemet perfekt men i en stil der er helt fremmed for resten af din codebase. Testene passerer fordi testene tjekker adfærd, ikke tilgang.

En menneskelig reviewer fanger disse ting. De læser for _hvordan_, ikke bare _hvad_. De bemærker når en løsning virker i dag men skaber gæld for i morgen. De spotter genvejen der vil forvirre den næste udvikler der rører koden.

Der er også en social dimension. Hvis dit hold ved at agent-PR'er auto-merges, stopper de med at være opmærksomme på agentgenereret kode. Den bliver en sort boks. Seks måneder senere er halvdelen af din codebase skrevet af en agent og ingen på holdet forstår den fuldt ud. Det er et vidensgab der vil skade jer under en incident.

Auto-merge er fint til trivielle, mekaniske ændringer — formateringsrettelser, importsortering, versionsbumps. Til alt der involverer en designbeslutning, reviewer et menneske det. Agenten er en hurtig udkaster, ikke en beslutningstager. Og reviewet behøver ikke at være udtømmende — en fem-minutters scanning for at tjekke at tilgangen er rimelig rækker langt.

== Agentassisterede Deployments

Deploys er der hvor tingene bliver genuint farlige, og hvor gabet mellem "agenten kan gøre det her" og "agenten bør gøre det her" er bredest. Lad os være præcise om hvad agenter bør og ikke bør gøre her.

Agenter er fremragende til at *overvåge* deploys. De kan se logstrømme, tracke fejlrater, sammenligne latency-percentiler med pre-deploy baseline og flagge anomalier. En agent der siger "fejlraten på `/api/checkout` er steget 3x siden deployet for tolv minutter siden" er enormt værdifuld. Den læser data, finder mønstre og bringer information op til overfladen — præcis hvad agenter er gode til.

Agenter kan også *foreslå* handlinger. "Baseret på fejlratens stigning anbefaler jeg at rulle tilbage til den forrige version" er et nyttigt forslag. Det er den slags der normalt kræver at nogen stirrer på et Grafana-dashboard i femten minutter for at konkludere. Agenten har gjort analysen. Et menneske beslutter om der skal handles på det.

Hvad agenter ikke bør gøre er at tage rollback-beslutningen autonomt. Produktionsdeployments er for konsekvensrige til ad-hoc agentbeslutninger. Hvis du vil have automatiserede rollbacks, brug en forhåndsgodkendt runbook med hårde tærskelværdier — "hvis fejlraten overstiger 5% i tre minutter, rul automatisk tilbage." Det er deterministisk. Du testede det. Du godkendte logikken på forhånd. En agent der selv beslutter om en 2,3% fejlratestigning "føles" betydelig nok til at rulle tilbage? Det er en opskrift på enten unødvendige rollbacks eller oversete incidents. Deterministiske regler er kedelige. Kedeligt er godt når din omsætning er på spil.

I praksis ser en deploy-overvågningsagent nogenlunde sådan ud: den abonnerer på din logaggregator og metrikdashboard via API, kører i femten minutter efter hvert deploy og poster et resumé til Slack. "Deploy af v2.4.1 gennemført. Fejlrate stabil på 0,3%. P99-latency steget fra 180ms til 210ms — inden for normal varians. Ingen nye undtagelsestyper detekteret." Det meste af tiden er det resumé kedeligt. Det er pointen. Når det ikke er kedeligt, vil du vide det med det samme.

Det kobler tilbage til guardrails-princippet: produktion er read-only for agenter. De observerer, analyserer, rapporterer, anbefaler. Mennesker (eller forhåndsgodkendt automatisering med deterministiske regler) tager handling.

== Pipelinen Som Kontekst

Din CI/CD-konfiguration er kontekst, og agenter læser den som enhver anden kode. Det er nemt at glemme — de fleste teams behandler deres pipelinekonfiguration som infrastruktur-VVS, ikke som noget der behøver at kommunikere klart. Men når en agent forsøger at forstå hvorfor et build fejlede eller hvilke verifikationstrin der eksisterer, er pipelinekonfigurationen det første den læser.

En velstruktureret pipeline hjælper agenter med at forstå dit projekt. Klare stagenavne (`build`, `unit-tests`, `integration-tests`, `deploy-staging`) fortæller agenten hvordan din verifikationsproces ser ud. Struktureret fejloutput — JSON-logs, exit-koder med mening, fejlkategorier — giver agenten noget at arbejde med når et trin fejler.

En pipeline der outputter `BUILD FAILED` og intet andet er ubrugelig for agenter og mennesker i lige mål.

Investér i pipeline-observerbarhed:

- *Strukturerede logs.* JSON eller nøgle-værdi-par, ikke fritekst. En agent kan parse `{"stage": "unit-tests", "failed": 3, "passed": 247, "failures": ["test_auth_flow", "test_rate_limit", "test_session_expiry"]}` og tage meningsfuld handling. Den kan ikke gøre meget med `Tests failed. See above for details.`
- *Meningsfulde exit-koder.* Lad ikke alt exite med kode 1. Skeln mellem "tests fejlede" (kan fikses) og "kunne ikke forbinde til databasen" (infrastrukturproblem, ikke agentens bekymring).
- *Artefaktopbevaring.* Testresultater, dækningsrapporter, buildlogs — gem dem som pipeline-artefakter. En agent der debugger en CI-fejl har brug for at læse det fulde output, ikke bare de sidste ti linjer der passer i konsolvisningen.

Overvej at tilføje en `PIPELINE.md` til dit repo — en beskrivelse i klart sprog af hvad hvert CI-stage gør, hvordan dets forventede output ser ud, og hvilke almindelige fejltilstande der eksisterer. En agent der kan læse denne fil før den debugger en CI-fejl vil præstere dramatisk bedre end en der er nødt til at reverse-engineere din pipeline fra YAML-konfiguration alene. Og dine nyanstilte vil også takke dig.

Godt pipelinedesign og god agentintegration forstærker hinanden. Du forbedrer din CI for agenter, og dine menneskelige udviklere drager også fordel. Det er en af de sjældne investeringer der giver udbytte i begge retninger.

== Start Småt

Hvis du har læst dette kapitel og er fristet til at koble agenter ind i hvert eneste stage af din pipeline inden fredag — lad være. Jeg har set den impuls. Den ender normalt med en weekend brugt på at fortryde automatiseringen fordi holdet ikke var klar til mængden af agentgenereret støj.

De teams der lykkes med agenter i CI er dem der opbygger tillid inkrementelt, ligesom med interaktive agenter.

Den gode nyhed er at stien er velafprøvet. Her er en praktisk adoptions-roadmap som jeg har set virke på tværs af multiple teams:

*Uge 1: Autoformatering.* Tilføj et CI-trin der kører en agent til at fikse formateringsproblemer på PR'er. Formatering er deterministisk, nem at verificere og lavrisiko. Hvis agenten formaterer noget forkert, er diffen lige der. Review agentens commits den første uge for at opbygge tillid.

*Uge 2: PR-forscreening.* Tilføj agentgenererede reviewkommentarer på PR'er. Ikke blokerende — kun informationelle. Lad dit hold se hvad agenten fanger, og kalibrer om dens feedback er nyttig eller støjende. Justér prompten baseret på hvad der virker.

*Måned 1: Changelog-udkast.* Peg agenten mod din commit-historik for at generere release note-udkast. Et menneske redigerer og publicerer. Du bruger agenten som førstekladsudkaster, ikke beslutningstager. Det er også et godt tidspunkt at sætte omkostningsovervågning og alarmer op.

*Måned 3: Natteagenter.* Nu har du opbygget tillid til agentgenereret output og du har infrastrukturen — worktrees, tokenbudgetter, branchisolering, reviewprocesser. Start med en enkelt velafgrænset ticket. Review resultatet omhyggeligt. Iterer på dit natscript. Udvid gradvist til mere komplekse opgaver efterhånden som din tillid vokser.

Bemærk hvad der _ikke_ er på denne roadmap: auto-merging, autonome deployments eller agenter der tager arkitekturbeslutninger. Det er ikke trin fire. Det er måske trin ti, eller det er måske aldrig passende for dit hold. Roadmappen er ikke en march mod fuld automatisering — den er en march mod det rigtige niveau af automatisering for din kontekst.

Modstå trangen til at springe trin over. Hvert bygger på det forrige. Du lærer hvad dine agenter er gode til, hvor de kæmper, og hvilke guardrails du har brug for. Ved måned tre føles agentassisteret CI naturligt — ikke fordi du automatiserede alt på én gang, men fordi du fortjente hvert stykke af det gennem erfaring.

Pipelinen er bare endnu et miljø hvor agenter arbejder. De samme principper gælder: scop stramt, verificer grundigt, stol inkrementelt. Den eneste forskel er at ingen kigger, så dine sikkerhedsnet skal være så meget desto stærkere.
