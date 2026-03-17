= Kontekst

Sidste måned kom der en bug fra en kunde: betalinger fejlede lydløst for brugere med ikke-ASCII-tegn i deres faktureringsadresse. En tricky en — den slags der lever i sømmen mellem din frontend-validering og din payment gateways tegnkodning.

En ingeniør på mit hold snuppede ticketten først. Han åbnede sin agent og tastede: "Der er en bug med betalinger for internationale brugere. Kan du kigge på det?" Agenten læste beredvilligt betalingsmodulet igennem, lavede nogle plausible gæt om Unicode-håndtering og producerede en patch der normaliserede al input til ASCII. Det ville have fjernet alle accenter, alle umlauts, alle tegn udenfor det engelske alfabet fra alle brugeres faktureringsadresser. Et fix der teknisk set var værre end buggen.

En time senere tog en anden ingeniør den samme ticket efter det første forsøg blev afvist i review. Hun indsatte kundens error log, det fejlende Sentry-trace, den specifikke payment gateway-svarkode, den relevante sektion af gatewayens tegnkodningsdokumentation og de tre filer involveret i faktureringspipen. Hendes agent diagnosticerede problemet på under to minutter: en UTF-8-streng blev sendt gennem en funktion der antog Latin-1-kodning før den ramte gatewayens API. Fixet var fire linjer. Det blev shippet den eftermiddag.

Modellen var den samme. Agenten var den samme. Buggen var den samme. Det der var forskelligt var hvad hver ingeniør lagde foran agenten før de bad den om at arbejde. Den ene gav den en vag beskrivelse og lod den gætte. Den anden gav den alt hvad den havde brug for til at _se_ problemet.

Den forskel — hvad agenten kan se — er hvad dette kapitel handler om.

Den vigtigste færdighed i agentisk ingeniørarbejde er ikke prompting. Det er kontekststyring.

En AI-agent er kun så god som det den kan se. Giv den en vag instruktion og et blankt lærred, og den vil hallucinere selvsikkert. Giv den de rigtige filer, de rigtige begrænsninger, det rigtige billede af systemet — og den vil gøre ting der føles som magi. Forskellen er ikke modellen. Det er dig.

Traditionelt ingeniørarbejde havde en version af dette også. En senior-ingeniør skrev ikke bare bedre kode — de holdt mere af systemet i hovedet. De vidste hvilke filer der var vigtige, hvor dragerne boede, hvilke abstraktioner der var bærende og hvilke der var dekorative. Den mentale model var konteksten, og den levede udelukkende i ingeniørens hjerne.

Nu skal du _eksternalisere_ den. Dine agenter kan ikke læse dine tanker. De læser filer, environment variables, error logs og hvad end du lægger foran dem. Håndværket i agentisk ingeniørarbejde er at lære hvad man skal fremhæve, hvornår, og hvordan.

== Kontekstvinduet Er Din Arbejdsbænk

Tænk på kontekstvinduet som en fysisk arbejdsbænk. Den har begrænset plads. Du kan ikke dumpe hele din codebase på den og forvente gode resultater. I stedet lægger du de dele ud der er vigtige for _denne_ opgave: de relevante kildefiler, den fejlende test, skemaet, måske et stykke dokumentation.

En god agentisk ingeniør kuraterer kontekst ligesom en god kirurg lægger instrumenter frem. Intet unødvendigt. Alt inden for rækkevidde.

Det betyder at man udvikler instinkter for spørgsmål som:
- Hvad har agenten brug for at se for at forstå denne opgave?
- Hvad vil forvirre den hvis jeg inkluderer det?
- Er den kontekst jeg giver _aktuel_, eller fodrer jeg den med forældet information?

== Kontekstvinduets Skat

Hver token du putter i et kontekstvindue koster dig to gange: én gang i penge, én gang i opmærksomhed.

Pengedelen er ligetil. API-kald prissættes efter tokenantal. Dump hele din codebase i konteksten og du brænder kroner af på hver interaktion. Men den mere lumske omkostning er opmærksomhedsforringelse. Sprogmodeller behandler ikke alle tokens ens — der er et veldokumenteret fænomen hvor information midt i en lang kontekst får mindre vægt end information i starten eller slutningen. Jo mere du propper ind, jo mere sandsynligt er det at modellen overser det der faktisk er vigtigt.

Jeg lærte det på den hårde måde. Tidligt troede jeg mere kontekst altid var bedre. Under arbejde på en tricky database-migration fodrede jeg agenten med alle migrationsfiler vi nogensinde havde skrevet — tre års skemaændringer, hundredvis af filer. Min logik var sund: agenten havde brug for at forstå hele historikken for at skrive den næste migration korrekt. Resultatet var en migration der duplikerede en kolonne der allerede eksisterede, fordi den relevante tidligere migration var begravet midt i en enorm kontekst og modellen reelt tabte overblikket over den.

Næste forsøg gav jeg den kun det aktuelle skema, de tre seneste migrationer og et sammendrag på ét afsnit af den relevante historie. Agenten naglede det.

Det er kontekstvinduets skat i praksis. Der er et sweet spot mellem for lidt og for meget, og at finde det er en færdighed man udvikler gennem øvelse.

For lidt kontekst producerer hallucination. Agenten har ikke nok information, så den udfylder hullerne med plausibelt klingende opfindelser. Du beder den om at fikse en funktion uden at vise den filen, og den opfinder et API der ikke eksisterer. Du beder den om at skrive en test uden at vise den dit testframework, og den vælger Jest når du bruger Vitest.

For meget kontekst producerer forvirring og spild. Agenten har svaret begravet et sted i bunken, men den kan ikke finde det — eller værre, den finder modstridende information på tværs af forskellige filer og vælger den forkerte. Du betaler også for hver token af støj du inkluderede.

Sweet spottet er _kurateret_ kontekst. Ikke alt hvad agenten muligvis kunne have brug for, men alt hvad den faktisk har brug for til denne specifikke opgave, lagt klart frem. Tænk på det mindre som at fylde et arkivskab og mere som at briefe en kollega før et møde. Du ville ikke give dem hvert eneste dokument virksomheden nogensinde har produceret. Du ville give dem de tre ting de behøver at læse og et ét-minuts sammendrag af baggrunden.

En praktisk tommelfingerregel: hvis du er ved at paste noget ind i konteksten, spørg dig selv — vil agenten træffe en anderledes (bedre) beslutning fordi den så dette? Hvis svaret er nej, lad være med at inkludere det.

== Lokalt, Sandboxet, Fjernt: Flyt Dine Agenter Rundt

Kontekst handler ikke kun om tekst i en prompt. Det handler om _hvor_ din agent opererer og hvad den har adgang til.

=== Den Lokale Maskine

Det simpleste setup: agenten kører på din maskine, læser dine filer, udfører dine kommandoer. Det er her de fleste starter — værktøjer som Claude Code der opererer direkte i dit projektbibliotek.

Fordelen er umiddelbarhed. Agenten ser hvad du ser. Den kan læse din kode, køre dine tests, tjekke din git-historik. Risikoen er også åbenlys: det er din maskine, dine credentials, din produktionskonfiguration der ligger lige der i `~/.env`.

=== Sandboxede Miljøer

En mere disciplineret tilgang er at give agenten en sandbox — en container, en VM, et worktree. Den får en kopi af koden men ikke dine nøgler. Den kan ødelægge ting uden at ødelægge _dine_ ting.

Det betyder mere end de fleste indser. Når du lader en agent iterere frit — køre kode, installere pakker, modificere filer — vil du have at den gør det i et rum hvor en fejl er billig. En sandboxet agent er en frygtløs agent, og en frygtløs agent er en produktiv en.

Worktrees er et undervurderet værktøj her. Git worktrees lader dig spinne en isoleret kopi af dit repo op på sekunder. Agenten arbejder i sin egen branch, sit eget bibliotek. Hvis resultatet er godt, merger du det. Hvis ikke, sletter du worktree'et og går videre. Intet rod.

=== Fjernudforskning

Her bliver det interessant. En dygtig agentisk ingeniør peger ikke bare agenter mod lokale filer — de lærer agenter at _udforske_ fjernsystemer.

SSH ind på en staging-server for at undersøge logs. Forespørg en database for at forstå formen på rigtige data. Curl et API-endpoint for at se hvad det faktisk returnerer, ikke hvad dokumentationen påstår det returnerer. Hent container-logs fra en kørende service.

Agenten bliver din spejder. Du peger den mod et system og siger: "gå ud og kig dig omkring og fortæl mig hvad du finder." Men du er nødt til at sætte det op. Agenten har brug for credentials (scopede og midlertidige), netværksadgang og klare grænser for hvad den må røre ved.

Det er en vurderingssag — hvor meget adgang man skal give, til hvilke systemer, med hvilke guardrails. For lidt og agenten er ubrugelig. For meget og du er én dårlig prompt fra en produktionsincident. Den agentiske ingeniør lærer at kalibrere dette over tid.

== Fodring af Kontekst Med Omtanke

De bedste agentiske ingeniører udvikler vaner omkring kontekst:

*Start med fejlen.* Beskriv ikke buggen — vis agenten stack tracet, den fejlende test-output, loglinjen. Rå kontekst slår omskrevet kontekst hver gang.

*Vis, fortæl ikke.* I stedet for at forklare dit databaseskema i prosa, giv agenten migrationsfilerne eller ORM-modellerne. I stedet for at beskrive API-kontrakten, giv den OpenAPI-specifikationen eller et curl-svar.

*Beskær aggressivt.* Hvis du debugger et renderingsproblem, behøver agenten ikke at se din authentication-middleware. Hver irrelevant fil i konteksten er støj der forringer signalet.

*Brug filsystemet som kontekst.* Et velorganiseret projekt _er_ kontekst. Meningsfulde filnavne, klar mappestruktur, en god README — disse er ikke kun til mennesker længere. Dine agenter læser dem også.

*Giv filstier, ikke skattejagter.* Når du ved hvilke filer der er relevante, sig det eksplicit. "Buggen er i `src/payments/gateway.ts`, specifikt `encodeAddress`-funktionen på linje 142" er uendeligt bedre end "der er en bug et sted i betalingskoden." Hvert minut agenten bruger på at lede efter den rigtige fil er et minut den ikke bruger på det faktiske problem — og den brænder tokens hele tiden.

*Brug git blame til at forklare _hvorfor_.* Kode fortæller agenten _hvad_ der eksisterer. Git-historik fortæller den _hvorfor_. Når du beder en agent om at modificere et stykke kode der har et ikke-oplagt design, peg den mod den relevante commit-besked eller pull request. "Denne funktion ser mærkelig ud men den blev skrevet sådan på grund af #1247 — se commit-beskeden ved `abc123`" giver agenten den begrundelse den har brug for til at lave ændringer uden at bryde den originale intention.

*Copy-paste over omskrivning.* Det er værd at gentage fordi det er den mest almindelige fejl jeg ser. Ingeniører beskriver en fejl med deres egne ord i stedet for at paste den faktiske fejl ind. "Buildet fejler med en TypeScript-fejl om typer" versus at paste det præcise compiler-output med filsti, linjenummer og fejlkode. Det første giver agenten en vag retning. Det andet giver den et specifikt mål. Paste altid det rå output. Lad agenten stå for fortolkningen.

*Lag din kontekst.* Til komplekse opgaver, dump ikke alt på én gang. Start med det overordnede billede — hvad systemet gør, hvad du forsøger at ændre, hvorfor. Giv derefter de specifikke filer. Giv derefter fejlen eller testfejlen. Det spejler hvordan du ville briefe en menneskelig kollega, og det virker af samme grund: det opbygger en mental model før man dykker ned i detaljer.

== Kontekst På Tværs Af Sessioner

Her er et problem ingen advarer dig om: kontekstvinduer er flygtige. Når en session slutter, forsvinder alt agenten lærte — hver fil den læste, hver beslutning den tog, hver blindgyde den udforskede. Næste session starter fra nul.

Til korte opgaver er det ligegyldigt. Du paster fejlen ind, agenten fikser den, færdig. Men rigtigt ingeniørarbejde strækker sig over dage, nogle gange uger. En feature der rører tolv filer på tværs af tre services. En refaktorering der skal ske i etaper. En debugging-session hvor de første to timer indsnævrer problemet og den sidste halve time fikser det — bortset fra at du var nødt til at lukke din laptop ind imellem.

Hvis du ikke planlægger for sessionsgrænser, vil du spilde enorme mængder tid på at genetablere kontekst agenten allerede havde. Jeg har set ingeniører bruge de første femten minutter af hver session på at genforklare hvad de fortalte agenten i går. Det er ikke ingeniørarbejde. Det er babysitting.

Løsningen er at gøre kontekst _holdbar_ — at gemme den et sted hvor næste session kan samle den op.

*Lad codebasen være kontinuitetslaget.* Den mest pålidelige form for kontekst på tværs af sessioner er koden selv. Hvis agenten lavede fremskridt i går, bør det fremskridt være committet. Gode commit-beskeder bliver brødkrummestien: "Refaktorerede payment gateway til at separere kodningsstepper — næste skridt er at tilføje tests for ikke-ASCII-input." Næste session starter med at læse den seneste git log, og agenten har et klart billede af hvor tingene står.

*Brug CLAUDE.md-filer (eller tilsvarende).* Mange agentværktøjer understøtter en kontekstfil på projektniveau — en markdown-fil i roden af dit repo der beskriver projektets arkitektur, konventioner og aktuelle tilstand. Denne fil persisterer på tværs af sessioner fordi den lever i filsystemet. Opdater den efterhånden som projektet udvikler sig. Inkluder ting som: hvad de vigtigste komponenter er, hvilke mønstre man skal følge, hvad der er i stykker lige nu, hvad holdet arbejder på. Det er et briefing-dokument som hver ny session automatisk læser.

*Skriv sessionsresumeer.* Når du afslutter en kompleks session, brug tres sekunder på at lade agenten opsummere hvad den opnåede, hvad der mangler, og hvad den lærte om codebasen. Gem det resumé et sted — en kommentar på ticketten, en note i projektet, selv en tekstfil i repoet. Næste session starter med at læse det resumé, og du har bevaret timers akkumuleret forståelse i nogle få afsnit.

*Commit tidligt og ofte.* Det er dækket i Git-kapitlet, men det er værd at gentage her fordi det fundamentalt er en kontekststyringsstrategi. Hvert commit er et checkpoint som fremtidige sessioner kan referere til. En session der slutter med ucommittede ændringer er en session hvis kontekst er fanget i et terminalvindue der måske ikke eksisterer i morgen.

De ingeniører der håndterer langvarigt agentisk arbejde godt er dem der behandler sessionsgrænser som en førsteklasses bekymring. De lukker ikke bare laptopen — de lukker loopet.

== Kontekst Som Arkitektur

Her er den dybere indsigt: efterhånden som du bliver bedre til agentisk ingeniørarbejde, begynder du at designe dine systemer _til_ kontekst. Du skriver klarere commit-beskeder fordi agenter læser dem. Du holder funktioner små fordi agenter arbejder bedre med fokuserede filer. Du vedligeholder opdateret dokumentation fordi agenter behandler det som sandhed.

Det her er ikke en mindre justering. Det ændrer hvordan du tænker om kodestruktur på alle niveauer.

*Små funktioner er kontekstvenlige.* En funktion på 400 linjer kræver at agenten holder hele molevitten i arbejdshukommelsen for at lave en ændring sikkert. En funktion på 30 linjer der gør én ting er noget agenten kan forstå fuldstændigt, modificere med selvtillid og verificere hurtigt. Det gamle råd — "en funktion bør gøre én ting" — var altid god ingeniørkunst. Nu er det også god kontekststyring. Hver gang du udtrækker en velnævnt funktion fra en større, skaber du en meningsenhed som en agent kan arbejde med uafhængigt.

*Filnavngivning er navigation.* Når en agent skal finde koden der håndterer brugerautentificering, starter den med at kigge på filnavne. `auth.ts` er et signal. `utils.ts` er et sort hul. `handleStuff.js` er en blindgyde. Disciplinen med at navngive filer klart — `user-authentication.ts`, `payment-gateway.ts`, `rate-limiter.middleware.ts` — er ikke længere bare en høflighed overfor fremtidige udviklere. Det er et indeks som agenter bruger til at finde vej gennem din codebase uden at læse hver eneste fil.

*Mappestruktur er arkitekturdokumentation.* En flad mappe med tres filer fortæller agenten ingenting om hvordan systemet er organiseret. Et klart hierarki — `src/api/`, `src/services/`, `src/models/`, `src/middleware/` — fortæller den alt. Agenten kan udlede arkitekturen fra mappestrukturen alene, uden at læse en eneste linje dokumentation. Jeg har set agenter navigere en velstruktureret monorepo med 10.000 filer mere effektivt end et dårligt struktureret projekt med 200, udelukkende fordi mappelayoutet gjorde systemet læsbart.

*Monorepos vs. multirepos: en kontekst-afvejning.* I en monorepo kan agenten se alt — API'et, frontenden, de delte biblioteker, infrastrukturkonfigurationen. Det er kraftfuldt til opgaver der krydser grænser. Men det betyder også at agenten kan se _for meget_, og trækker irrelevant kode ind fra urelaterede services. I et multirepo-setup er hvert repo naturligt scopet — agenten ser kun den service den arbejder på. Men opgaver på tværs af services bliver sværere fordi agenten ikke nemt kan referere til den anden side af en API-kontrakt. Ingen af tilgangene er universelt bedre. Pointen er at din repo-strategi er en kontekstbeslutning, uanset om du tænker på det sådan eller ej.

*Typer er kontekst.* En stærkt typet codebase giver en agent noget som en dynamisk typet ikke gør: en maskinlæsbar beskrivelse af hver funktions kontrakt. Agenten kan se på en funktionssignatur og vide præcis hvad der går ind og hvad der kommer ud, uden at læse implementeringen. TypeScript, Rust, Go — disse sprog bærer strukturel kontekst i deres typesystemer. Python og JavaScript lader agenten gætte medmindre du har skrevet grundige docstrings eller type hints. Det her er ikke et argument for ét sprog frem for et andet. Det er en observation om at typesystemer gør dobbelt tjeneste i den agentiske æra: de fanger bugs _og_ de kommunikerer intention.

*Dokumentation er sandhed (uanset om den er korrekt eller ej).* Agenter behandler din README, dine API-docs, dine inline-kommentarer som autoritative. Hvis din dokumentation siger at API'et returnerer et `user_id`-felt men det faktiske svar returnerer `userId`, vil agenten skrive kode mod dokumentationen og producere en bug. Forældet dokumentation var altid et irritationsmoment. Med agenter er det en aktiv kilde til defekter. Standarden for dokumentationsnøjagtighed går op — ikke fordi agenter har brug for bedre docs end mennesker, men fordi agenter vil følge dårlige docs mere trofast end et menneske ville.

Den måde du strukturerer din kode, dine repos, din infrastruktur — det hele bliver en del af den kontekst du giver dit mandskab. De ingeniører der forstår dette tidligt vil bygge systemer der ikke bare er vedligeholdelige af mennesker, men _navigerbare_ af agenter. Og over tid akkumulerer denne navigerbarhed — hver ny agentsession drager fordel af hver strukturel beslutning du tog før den.
