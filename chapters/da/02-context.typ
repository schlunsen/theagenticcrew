= Kontekst

Sidste måned kom der en bug fra en kunde: betalinger fejlede lydløst for brugere med ikke-ASCII-tegn i deres faktureringsadresse. En tricky en — den slags der lever i sømmen mellem din frontend-validering og din payment gateways tegnkodning.

En ingeniør på mit hold snuppede ticketten først. Han åbnede sin agent og tastede: "Der er en bug med betalinger for internationale brugere. Kan du kigge på det?" Agenten læste beredvilligt betalingsmodulet igennem, lavede nogle plausible gæt om Unicode-håndtering og producerede en patch der normaliserede al input til ASCII. Det ville have fjernet alle accenter, alle umlauts, alle tegn udenfor det engelske alfabet fra alle brugeres faktureringsadresser. Et fix der teknisk set var værre end buggen.

En time senere tog en anden ingeniør den samme ticket efter det første forsøg blev afvist i review. Hun indsatte kundens error log, det fejlende Sentry-trace, den specifikke payment gateway-svarkode, den relevante sektion af gatewayens tegnkodningsdokumentation og de tre filer involveret i faktureringspipen. Hendes agent diagnosticerede problemet på under to minutter: en UTF-8-streng blev sendt gennem en funktion der antog Latin-1-kodning før den ramte gatewayens API. Fixet var fire linjer. Det blev shippet den eftermiddag.

Modellen var den samme. Agenten var den samme. Buggen var den samme. Det der var forskelligt var hvad hver ingeniør lagde foran agenten før de bad den om at arbejde. Den ene gav den en vag beskrivelse og lod den gætte. Den anden gav den alt hvad den havde brug for til at _se_ problemet.

Men her er sagen: den anden ingeniør gav ikke bare bedre kontekst. Hun gav agenten de _råmaterialer_ den havde brug for — fejlsporet, dokumentationen, de relevante filer. Det er et betydeligt skridt op. Den endnu bedre version? At give agenten _værktøjer_ til at finde de materialer selv. Hvis det Sentry-trace var tilgængeligt via en MCP-integration, hvis agenten kunne læse gateway-dokumentationen fra en konfigureret kilde, hvis den kunne køre `git log` på faktureringspipen — ville hun ikke have behøvet at samle konteksten manuelt. Agenten ville have indsamlet den, og hun kunne have fokuseret på det kun hun kunne bidrage med: dømmekraften om at dette var et tegnkodningsproblem, ikke et valideringsproblem.

Den forskel — hvad agenten kan se, og hvad den kan _nå_ — er hvad dette kapitel handler om.

Den vigtigste færdighed i agentisk ingeniørarbejde er ikke prompting. Det er kontekststyring.

En AI-agent er kun så god som det den kan se. Giv den en vag instruktion og et blankt lærred, og den vil hallucinere selvsikkert. Giv den de rigtige filer, de rigtige begrænsninger, det rigtige billede af systemet — og den vil gøre ting der føles som magi. Forskellen er ikke modellen. Det er dig.

Traditionelt ingeniørarbejde havde en version af dette også. En senior-ingeniør skrev ikke bare bedre kode — de holdt mere af systemet i hovedet. De vidste hvilke filer der var vigtige, hvor dragerne boede, hvilke abstraktioner der var bærende og hvilke der var dekorative. Den mentale model var konteksten, og den levede udelukkende i ingeniørens hjerne.

Nu skal du _eksternalisere_ den. Dine agenter kan ikke læse dine tanker. De læser filer, environment variables, error logs og hvad end du lægger foran dem — og i stigende grad kan de _finde_ de ting selv hvis du giver dem de rigtige værktøjer. Håndværket i agentisk ingeniørarbejde er at lære hvad man skal fremhæve, hvornår, og hvordan — og, vigtigere endnu, at bygge den infrastruktur der lader agenter fremhæve ting for sig selv.

== Kontekstvinduet Er Din Arbejdsbænk

Tænk på kontekstvinduet som en fysisk arbejdsbænk. Den har begrænset plads. Du kan ikke dumpe hele din codebase på den og forvente gode resultater. I stedet lægger du de dele ud der er vigtige for _denne_ opgave: de relevante kildefiler, den fejlende test, skemaet, måske et stykke dokumentation.

Men her er udviklingen i tænkningen: du er ikke kirurgens assistent der nervøst afleverer instrumenter én ad gangen. Du er personen der _designede operationsstuen_. En god agentisk ingeniør kuraterer kontekst, ja — men den egentlige færdighed er at bygge et velorganiseret værksted hvor agenten kan finde hvad den har brug for. Klar filstruktur, tilgængelige værktøjer, velmærkede skuffer. Når værkstedet er sat rigtigt op, tager agenten selv det rigtige instrument ned fra væggen. Du træder til kun når den har brug for noget der ikke er på nogen hylde — din dømmekraft, din intention, din viden om hvorfor tingene er som de er.

#image("../../assets/illustrations/ch02-context-workbench.jpg", width: 80%)

Det betyder at man udvikler instinkter for spørgsmål som:
- Hvad har agenten brug for at se for at forstå denne opgave?
- Hvad vil forvirre den hvis jeg inkluderer det?
- Er den kontekst jeg giver _aktuel_, eller fodrer jeg den med forældet information?

== Kontekstinfrastruktur Versus Direkte Kontekst

Før vi går ind i mekanikken, er det værd at navngive de to lag af kontekst der er vigtige i agentisk arbejde — fordi de fleste ingeniører kun tænker på det ene af dem.

*Lag 1: Kontekstinfrastruktur.* Det er den varige investering. Det er alt hvad du sætter op _én gang_ der betaler sig i hver session: filsystemadgang, kommandoudførelse, MCP-integrationer med din fejlsporing og projektledelsesværktøjer, velorganiseret repo-struktur, `CLAUDE.md`-filer der beskriver din arkitektur og konventioner. Når du investerer i kontekstinfrastruktur, bygger du et værksted hvor agenten kan finde sine egne værktøjer. Det er _ingeniørarbejde_ — det akkumulerer.

*Lag 2: Direkte kontekst.* Det er det manuelle, sessions-specifikke arbejde: at indsætte error logs, skrive begrænsninger op, forklare domæneviden, beskrive intention. Det er stadig essentielt — der er ting intet værktøj kan opdage, som hvorfor en bestemt designbeslutning blev truffet, eller at marketingholdet har brug for denne feature torsdag. Men det bør være _tilbagefaldet_, ikke standarden. Hver gang du finder dig selv i at indsætte den samme slags information igen og igen, er det et signal om at opgradere det fra Lag 2 til Lag 1 ved at sætte et værktøj eller en integration op.

De bedste agentiske ingeniører bruger det meste af deres indsats på Lag 1 og har kun brug for Lag 2 til ting der er genuint flygtige eller tavse. Resten bruger al deres tid på Lag 2 og undrer sig over hvorfor hver session føles som at starte fra nul.

=== Niveauer Af Kontekstlevering

Der er en nyttig måde at tænke om hvordan kontekst når din agent, fra mindst effektiv til mest:

*Niveau 0: Beskriv problemet med egne ord.* "Buildet er i stykker, noget med typer." Det er den mest tabsgivende form for kontekst. Du komprimerer en detaljeret fejl gennem det snævre rør af din omformulering, og agenten skal dekomprimere den — dårligt — i den anden ende. Det er som at beskrive et maleri til nogen over telefonen og bede dem reproducere det.

*Niveau 1: Indsæt rådata.* Kopiér stack tracet, det fejlende testoutput, logfilen, den relevante kildekode. Det er her de fleste kompetente ingeniører lander i dag, og det er et meningsfuldt skridt op. Agenten ser præcis hvad du så. Ingen tabsgivende komprimering. Begrænsningen er at det er manuelt, det er flygtigt, og det skalerer ikke — næste session skal du indsætte det hele igen.

*Niveau 2: Giv agenten værktøjer til at finde dataene selv — og giv kun det værktøjer ikke kan opdage.* Agenten kører den fejlende test, læser fejlsporet, grepper efter den relevante kode, tjekker `git blame` for historikken. Du giver _intentionen_ ("vi skal fikse dette uden at ændre det lagrede format fordi tre downstream-services er afhængige af det") og _begrænsningerne_ ("payment gatewayen har en særhed der ikke er dokumenteret noget sted"). Det er hvad du bør sigte efter. Det er varigt, det skalerer, og det lader dig fokusere på den del af jobbet der faktisk er svær: dømmekraft.

De fleste teams er et sted mellem Niveau 0 og Niveau 1. Målet med dette kapitel er at bringe dig til Niveau 2 — eller i det mindste at vise dig vejen derhen.

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

== Fodring Af Kontekst Med Omtanke

Der er to lag til at levere kontekst, og de bedste agentiske ingeniører investerer tungt i det første så de sjældent har brug for det andet.

=== Tier 1: Kontekstinfrastruktur

Det mest effektive du kan gøre er at give din agent _værktøjer_ til at indsamle kontekst på egen hånd. Det er en varig investering — du sætter det op én gang og hver fremtidig session drager fordel af det.

*Giv agenter adgang til dine værktøjer.* Filsystemadgang og kommandoudførelse er basislinjen. En agent der kan køre `git log`, `git blame`, `grep` og din testsuite kan besvare de fleste af sine egne spørgsmål. Men stop ikke der. MCP-servere kan forbinde agenter til eksterne systemer — din fejlsporing (Sentry, Datadog), dit projektledelsesværktøj (Linear, Jira), din database, din CI-pipeline. Hver integration er én ting mindre du skal kopiere og indsætte manuelt, for evigt.

*Gør din projektstruktur navigerbar.* Et velorganiseret projekt _er_ kontekstinfrastruktur. Meningsfulde filnavne, klar mappestruktur, en god README — disse er ikke kun til mennesker længere. Dine agenter læser dem også. Når filsystemet er læsbart, kan en udstyret agent finde den rigtige fil uden at du peger på den.

*Vedligehold CLAUDE.md-filer (eller tilsvarende).* En kontekstfil på projektniveau der beskriver arkitektur, konventioner og aktuelle prioriteter er en af de billigste og mest kraftfulde former for kontekstinfrastruktur. Den lever i filsystemet, persisterer på tværs af sessioner og læses automatisk. Tænk på den som et briefing-dokument som hver ny agentsession automatisk samler op.

*Scop dine værktøjer, fjern dem ikke.* Instinktet om at begrænse agentadgang er forståeligt, men at overbegrænse er lige så dyrt som at overbevæbne. I stedet for at forhindre filadgang, scop den til de relevante mapper. I stedet for at blokere kommandoudførelse, hvidlist de kommandoer der er vigtige. En velscopet agent er både sikker og kompetent.

=== Tier 2: Direkte Konteksttilførsel

Værktøjer kan ikke give alt. Din mentale model af hvorfor noget blev designet på en bestemt måde, begrænsninger der aldrig blev nedskrevet, stammeviden om hvordan holdet arbejder, domæneekspertise om forretningen — det er hvad _du_ bringer. Det er her kopier-indsæt og direkte instruktion stadig er vigtige.

*Start med fejlen — eller lad agenten finde den.* Hvis din agent har adgang til dit fejlsporings-system via MCP, lad den selv hente Sentry-tracet eller Datadog-alarmen. Hvis den ikke har det, indsæt stack tracet, det fejlende testoutput, loglinjen. Rå kontekst slår omskrevet kontekst hver gang — men den bedste version er at agenten tilgår råkilden direkte.

*Giv intention, ikke bare implementeringsdetaljer.* En udstyret agent er overraskende god til at finde de rigtige filer. Hvad den _ikke_ kan finde er din intention. "Vi skal fikse kodningsbuggen i faktureringspipen, og fixet må ikke ændre det lagrede format fordi tre downstream-services er afhængige af det" er den slags kontekst intet værktøj kan opdage. Fokusér din manuelle input på _hvorfor_ og _begrænsningerne_, ikke _hvor_.

*Rådata frem for omformulering — og lad ideelt agenten tilgå kilden.* Det er den mest almindelige fejl jeg ser: ingeniører beskriver en fejl med egne ord i stedet for at give den faktiske fejl. "Buildet fejler med en TypeScript-fejl om typer" versus det præcise compiler-output med filsti, linjenummer og fejlkode. Det første giver agenten en vag retning. Det andet giver den et specifikt mål. Men den bedste version er en agent der selv kan køre buildet og se fejlen direkte.

*Brug git blame til at forklare _hvorfor_ — eller lad agenten køre det.* Kode fortæller agenten _hvad_ der eksisterer. Git-historik fortæller den _hvorfor_. Når du beder en agent om at modificere kode der har et ikke-oplagt design, giver den relevante commit-besked eller pull request den begrundelsen den har brug for. Hvis din agent kan køre `git blame` og `git log` selv, kan den finde denne historik. Hvad den stadig har brug for fra dig er _fortolkningen_: "Denne funktion ser mærkelig ud men den blev skrevet sådan på grund af en payment gateway-særhed der ikke er dokumenteret noget sted — se `abc123`."

*Beskær aggressivt — ved at scope værktøjer.* Hvis du debugger et renderingsproblem, behøver agenten ikke at se din authentication-middleware. Med manuel kontekst betyder det at være selektiv med hvad du indsætter. Med udstyrede agenter betyder det at scope filadgang eller arbejde i et fokuseret worktree. Hver irrelevant fil i konteksten er støj der forringer signalet, uanset om den kom der via indsæt eller via værktøj.

*Lag din kontekst.* Til komplekse opgaver, dump ikke alt på én gang. Start med det overordnede billede — hvad systemet gør, hvad du forsøger at ændre, hvorfor. Giv derefter de specifikke filer. Giv derefter fejlen eller testfejlen. Det spejler hvordan du ville briefe en menneskelig kollega, og det virker af samme grund: det opbygger en mental model før man dykker ned i detaljer.

*Udstyr, spisfod ikke.* Når du er ved at indsætte en fil i kontekstvinduet, spørg: kunne agenten have fundet dette selv hvis den havde de rigtige værktøjer? Hvis ja, invester tiden i at sætte den adgang op i stedet. Indsætning er en engangsløsning. Værktøjer er en permanent opgradering. Målet er en agent der har brug for dig for din dømmekraft, ikke dit udklipsholder.

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
