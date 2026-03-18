= Testing Som Feedback Loop

#figure(
  image("../../assets/illustrations/ch08-feedback-loop.jpg", width: 50%),
)

To codebases. Samme agent. Samme opgave: "Tilføj en rate limiter til API'et der returnerer 429 efter 100 requests per minut per bruger."

I den første codebase er der ingen tests. Agenten læser route handlers, vælger et middleware-indsætningspunkt, skriver rate-limiting-logikken og... stopper. Den har ingen måde at vide om det virkede. Den kan ikke starte serveren og sende 101 requests for at se hvad der sker. Den kan ikke tjekke om eksisterende endpoints stadig svarer korrekt. Den producerer en diff, siger "Jeg har tilføjet rate limiting," og håber på det bedste. Du reviewer koden, kniber øjnene sammen, synes den ser rimelig ud, merger den, og opdager i produktion tre dage senere at middlewaren var mountet i forkert rækkefølge og aldrig blev eksekveret. Hver request sejlede igennem. Rate limiteren var dekoration.

I den anden codebase er der en testsuite. Agenten skriver rate-limiting-middlewaren, kører så testene. To eksisterende tests fejler — en health check-test der ikke forventede middleware-headers, og en auth-test hvor test-setupet lavede 150 hurtige requests og nu bliver throttlet. Agenten læser fejlene, justerer middlewaren til at skippe health-endpointet, opdaterer test-fixturen til at nulstille rate-counteren mellem tests, og kører igen. Grønt. Så skriver den tre nye tests: én der verificerer at den 101. request returnerer 429, én der verificerer at counteren nulstilles efter et minut, og én der verificerer at forskellige brugere har uafhængige limits. Alle passerer.

Samme agent. Samme opgave. Nat og dag i resultater. Forskellen var testsuiten.

I traditionel udvikling verificerer tests at din kode virker. I agentisk ingeniørarbejde gør tests noget mere fundamentalt: de fortæller agenten om den lykkedes. Det ændrer alt ved hvordan du tænker om testing.

Der er noget foruroligende ved det i starten. Din testsuite — den du skrev for at verificere _din_ kode — bliver den spec en agent implementerer mod. De tests du svedte over er ikke bare kvalitetssikring længere. De er definitionen af hvad "korrekt" betyder. Det er en mærkelig følelse: din tidligere indsats der bliver fundamentet for et workflow der ikke eksisterede da du skrev det. Men det er også, hvis du lader det være, dybt bekræftende. Alle de timer brugt på at skrive grundige tests? De var ikke bare god praksis. De var _investering_ — og afkastet kommer nu.

== Agentens Øjne

En agent kan ikke kigge på en UI og fortælle om den ser rigtig ud. Den kan ikke mærke om et API-svar er "hurtigt nok." Den kan ikke intuitivt vide om en refaktorering bevarede den subtile adfærd brugere afhænger af. Hvad den _kan_ gøre er at køre din testsuite og læse resultaterne.

Tests bliver agentens primære feedback-mekanisme. Grønt betyder "fortsæt." Rødt betyder "prøv igen." Ingen tests betyder at agenten flyver blindt — gætter om dens ændringer virker, uden mulighed for at verificere.

Men tests er ikke bare feedback — de er et _værktøj_ agenten bruger autonomt. Når en agent kan køre `npm test` eller `pytest` på egen hånd, bliver testsuiten et selvbetjeningsverifikationssystem. Agenten behøver ikke at du kører testene og indsætter outputtet. Den kører dem, læser dem og itererer — alt via sine værktøjer. Den autonomi er det der forvandler en testsuite fra et sikkerhedsnet til en motor.

Det er derfor utestede codebases er svære at arbejde med agentisk. Det er ikke bare et kvalitetsproblem — det er et informationsproblem. Uden tests har agenten intet signal. Det er som at bede nogen om at hænge en billedramme op med bind for øjnene. De rammer måske rigtigt, men det ville du ikke satse på.

Og kvaliteten af det signal er enormt vigtig. En test der siger `FAIL: expected 429, got 200` er handlingsbar. Agenten ved præcis hvad der gik galt og kan ræsonnere om hvorfor. En test der siger `FAIL: assertion error` uden kontekst er knap bedre end stilhed. Klarheden af dit testoutput er klarheden af agentens syn.

== TDD Får Ny Betydning

Test-Driven Development var altid en god idé. Med agenter bliver det en superkraft.

Workflowet er simpelt: skriv testen først, giv den så til agenten og sig "få denne til at passe." Agenten har nu et klart, utvetydigt succeskriterium. Den kan iterere — skrive kode, køre testen, læse fejlen, justere, gentage — i et stramt loop der tager sekunder per cyklus.

Her er hvad det ser ud i praksis. Lad os sige du har brug for en funktion der parser en varighedsstreng som `"2h30m"` til totale sekunder. Du skriver testen:

```python
def test_parse_duration():
    assert parse_duration("1h") == 3600
    assert parse_duration("30m") == 1800
    assert parse_duration("2h30m") == 9000
    assert parse_duration("45s") == 45
    assert parse_duration("1h15m30s") == 4530
    assert parse_duration("") == 0
    with pytest.raises(ValueError):
        parse_duration("abc")
```

Så fortæller du agenten: "Få `test_parse_duration` til at passe."

Agentens første forsøg håndterer måske timer og minutter men glemmer sekunder. Den kører testen: `FAIL: parse_duration("45s") returned 0, expected 45`. Klart signal. Den tilføjer sekundhåndtering, kører igen: `FAIL: parse_duration("abc") did not raise ValueError`. Endnu et klart signal. Den tilføjer inputvalidering. Grønt. Færdig.

Hver cyklus tog sekunder. Agenten behøvede aldrig at spørge dig hvad "korrekt" betyder — testene definerede det. Og fordi testen dækker edge cases du tænkte over på forhånd, håndterer implementeringen dem fra starten, ikke som bugs opdaget senere.

Det er fundamentalt anderledes end at bede en agent om at "bygge en varighedsparser." Det er vagt. Hvilket format? Hvilke edge cases? Hvad skal ske med dårligt input? Men "få disse syv assertions til at passe" er præcist. Agenten ved præcis hvordan succes ser ud, og den kan måle sin egen fremgang mod det.

Den agentiske ingeniør lærer at udtrykke intention gennem tests. Hver test er en kontrakt. Hver assertion er et krav. Jo bedre dine tests, jo bedre performer dine agenter. Du stopper med at tænke på testskrivning som overhead og begynder at tænke på det som at _programmere agenten_ — du specificerer adfærd i det mest utvetydige sprog der findes: kode der enten passerer eller ikke gør.

== Hvad Gør en God Agentisk Test

Ikke alle tests er lige nyttige for agenter. De tests der tjener mennesker godt under udvikling kan aktivt vildlede en agent. En god agentisk test har specifikke egenskaber, og det er værd at være bevidst om dem.

*Hurtig.* En agent itererer i et loop. Hvis hver cyklus tager ti minutter, prøver agenten seks tilgange per time. Hvis hver cyklus tager ti sekunder, prøver den 360. Hastighed er ikke bare bekvemmelighed — det er forskellen mellem en agent der konvergerer mod en løsning og en der timer ud. Kør den fulde suite hvis den er hurtig; kør kun de relevante tests hvis den ikke er. Under alle omstændigheder skal feedback loopet være stramt.

*Deterministisk.* En flaky test er værre end ingen test for en agent. Når en test fejler tilfældigt, trækker et menneske på skuldrene og kører igen. En agent ser en fejl og forsøger at fikse den. Den ændrer fungerende kode for at jagte et spøgelse. Så passerer den flaky test — ikke fordi agentens ændring var korrekt, men fordi de tilfældige stjerner stod rigtigt. Nu har du en meningsløs kodeændring der ligner et fix men ikke er det. Agenten er blevet belønnet for at gøre noget unyttigt. Hvis du har flaky tests, sæt dem i karantæne før du giver agenten adgang til suiten.

*Isoleret.* Tests der afhænger af eksekveringsrækkefølge, delt tilstand eller eksterne services skaber forvirrende fejl. Agenten ændrer funktion A og test B fejler — ikke på grund af en reel afhængighed, men fordi test B afhænger af tilstand som test A satte op. Agenten vil bruge cyklusser på at forsøge at forstå et forhold mellem A og B der ikke eksisterer i koden, kun i test-harnessen. Isolér dine tests. Hver enkelt bør sætte sin egen verden op og rive den ned.

*Klare fejlbeskeder.* `AssertionError: False is not True` fortæller agenten ingenting. `Expected user.status to be 'active' after calling activate(), but got 'pending'` fortæller den præcis hvad der gik galt. Gode assertion-beskeder er gratis dokumentation. Brug dem. Custom fejlbeskeder i dine assertions er den billigste investering du kan gøre i agentisk produktivitet.

*Fokuseret på adfærd, ikke implementering.* En test der asserter den interne struktur af en returværdi bryder når agenten refaktorerer. En test der asserter _adfærden_ — "givet dette input, får jeg dette output" — overlever refaktoreringer og giver agenten frihed til at finde bedre løsninger. Hvis dine tests begrænser implementeringen for stramt, kan agenten ikke forbedre den.

Lakmustesten: hvis du kun viste testfilen til en kompetent ingeniør uden anden kontekst, kunne de så skrive en korrekt implementering? Hvis ja, vil de tests fungere godt for en agent. Hvis nej — hvis testene er for vage, for koblede eller for flaky til at tjene som en pålidelig specifikation — fix testene før du giver dem til agenten.

== Dækningsspørgsmålet

"Hvor meget testdækning har jeg brug for til effektivt agentisk arbejde?"

Instinktet er at sige 100%. Fuld dækning. Hver linje, hver branch, hver sti. Men det er hverken praktisk eller nødvendigt. Hvad du faktisk har brug for er _målrettet_ dækning: nok til at agenten kan verificere den specifikke ting den ændrer.

Tænk på det sådan. Hvis du beder en agent om at modificere betalingsbehandlingsmodulet, har du brug for solid testdækning af betalingsbehandling. Du har ikke nødvendigvis brug for fuld dækning af e-mail-skabelonsystemet, admin-dashboardet eller CSV-eksportfunktionen. Agenten har brug for tests omkring den kode den rører, plus nok integrationstests til at bekræfte at den ikke har brudt grænsefladerne mellem systemer.

Det fører til en praktisk strategi: _dæk de varme stier først._ Se på hvor du faktisk vil pege agenter. Din kerne forretningslogik. Dine API-kontrakter. Dine datatransformationer. Det er de områder der behøver rigoristiske tests — ikke på grund af abstrakte kvalitetsmål, men fordi det er de områder hvor agenter vil arbejde.

Dækningsmetrikker kan endda være vildledende. En codebase med 90% linjedækning men ingen tests på betalingsflowet er værre, til agentiske formål, end en codebase med 40% dækning der grundigt tester betalinger, auth og API-laget. Agenten har ikke brug for et dækningsbadge. Den har brug for tests hvor arbejdet sker.

Når det er sagt, har integrationstests uforholdsmæssig stor værdi. En unit test fortæller agenten "denne funktion virker isoleret." En integrationstest fortæller agenten "disse komponenter virker sammen." Når en agent ændrer en funktion, fanger unit tests lokale regressioner og integrationstests fanger ripplevirkninger. Begge tæller, men hvis du starter fra nul, giver integrationstests mere for indsatsen fordi de verificerer _sømmene_ — de steder hvor ting har tendens til at gå i stykker.

Én ting mere: glem ikke negative tests. Tests der verificerer at dit system _afviser_ dårligt input er kritiske for agenter. Uden dem kan en agent "forenkle" din valideringslogik, få alle positive tests til at passe, og efterlade dig med et system der accepterer skrald. Hvis du har en valideringsregel, test begge sider af den.

== Hastighed Betyder Noget

Når en agent itererer i et testloop, påvirker hastigheden af din testsuite direkte produktiviteten. En testsuite der tager ti minutter at køre betyder at agenten venter ti minutter mellem forsøg. En testsuite der tager ti sekunder betyder at agenten kan prøve dusinvis af tilgange i den tid det tager dig at hente kaffe.

Det skaber et stærkt incitament til at:
- Holde unit tests hurtige og isolerede
- Separere hurtige tests fra langsomme integrationstests
- Bruge watch modes der kun genkører påvirkede tests
- Investere i testinfrastruktur på samme måde som du investerer i CI

Hurtige tests er ikke bare en forbedring af udvikleroplevelsen længere. De er agentinfrastruktur.

Praktisk betyder det at du vil have en lagdelt teststrategi. En hurtig unit suite der kører på sekunder — agentens indre loop. En medium integrationssuite der kører på et minut — agenten kører denne før den kalder opgaven færdig. Og en langsom end-to-end suite der kører i CI — den endelige verifikation før merge.

Fortæl dine agenter hvilken suite de skal bruge. "Kør `pytest tests/unit` efter hver ændring. Kør `pytest tests/integration` når du tror du er færdig." Det holder det indre loop hurtigt mens det stadig fanger integrationsproblemer før de når dig.

== Testing Ud Over Kode

Agenter skriver ikke kun applikationskode. De skriver infrastrukturkonfigurationer, deployment-scripts, dokumentation og mere. Hver af disse kan — og bør — have en form for automatiseret verifikation.

*Type checking* er det hurtigste feedback loop du kan give en agent. En typefejl viser sig på millisekunder, før en eneste test kører. I typede sprog, eller i Python med mypy, eller i JavaScript med TypeScript, fanger type checking en enorm klasse af fejl øjeblikkeligt. Agenten omdøber et felt, og type checkeren flagger øjeblikkeligt hvert sted der refererer til det gamle navn. Det er et strammere feedback loop end nogen testsuite kan give.

*Linting og formattering* fanger en anden klasse af problemer. En fejlkonfigureret ESLint-regel kan virke som en mindre irritation, men for en agent er en lint-fejl et utvetydigt signal. "Dit import er ubrugt." "Denne variabel er erklæret men aldrig læst." Det er små korrektioner der akkumulerer til renere kode med nul indsats fra dig.

*Skemavalidering* for API-kontrakter sikrer at agentens ændringer ikke bryder grænsefladen mellem services. Hvis du har OpenAPI-specs, JSON Schema-definitioner eller GraphQL-typedefinitioner, validér mod dem. En agent der ændrer en response-payload vil øjeblikkeligt lære at den brød kontrakten, i stedet for at opdage bruddet når en downstream-service crasher i staging.

*Kontrakttest* mellem services tager dette videre. Hvis service A afhænger af service B's API, verificerer en kontrakttest at B stadig opfylder hvad A forventer — uden at skulle køre begge services samtidigt. Når en agent modificerer service B, fanger kontrakttestene brydende ændringer som unit tests inden i B ville misse helt.

*Konfigurationsfilvalidering* er kriminelt underbrugt. En YAML-lint på dine Kubernetes-manifester. En terraform validate på din infrastrukturkode. Et docker-compose config-check. Det tager sekunder at køre og fanger fejl der ellers ville dukke op som mystiske fejl under deployment. Hvert automatiseret tjek du tilføjer er endnu et signal agenten kan bruge til at selvkorrigere.

Den agentiske ingeniør tænker bredt om testbarhed: ikke "returnerer min funktion den rigtige værdi?" men "kan jeg automatisk verificere at denne ændring er korrekt?"

== Når Tests Vildleder

En dårlig testsuite er værre end ingen testsuite. Det er ubehageligt men værd at sidde med.

Uden tests ved agenten at den flyver blindt. Den vil være konservativ. Den vil fortælle dig at den ikke kan verificere sine ændringer. Du vil reviewe mere omhyggeligt. Manglen på signal er i det mindste en ærlig mangel på signal.

Med dårlige tests flyver agenten med falsk tillid. Den laver en ændring, testene passerer, og den rapporterer succes. Du ser grønt og slapper af i din review. Men testene verificerede faktisk ikke den rigtige ting.

Det sker på flere forudsigelige måder.

*Tests der tester mocken, ikke koden.* Når din test mocker databasen, HTTP-klienten, filsystemet og køen — og så asserter at den mockede funktion blev kaldt med de rigtige argumenter — tester du din testopsætning, ikke din applikationslogik. En agent kan få den "rigtige" kode til at gøre hvad som helst og testen vil stadig passe, så længe mock-forventningerne er opfyldt. De tests giver et grønt signal der ikke betyder noget.

*Tests der er for løse.* `assert response.status_code == 200` fortæller dig at endpointet ikke crashede. Det fortæller dig ikke at svaret indeholder de rigtige data. En agent kunne returnere en tom body, den forkerte brugers data, eller et svar der mangler halvdelen af sine felter, og den assertion ville stadig passe. Specificitet i assertions er specificitet i feedbacksignalet.

*Tests der duplikerer implementeringen.* Hvis din test i bund og grund genimplementerer funktionen under test og tjekker at begge returnerer det samme, verificerer den ingenting. Agenten kan ændre implementeringen og testen sammen — og vil, hvis den mener de bør matche. Du ender med kode og tests der er enige med hinanden men ikke med virkeligheden.

Det hænger direkte sammen med "Det Selvsikre Forkerte Svar"-mønstret fra krigshistoriekapitlet. Agenten der tilføjede en `time.Sleep(500)` for at fikse en race condition? Testene passerede. De passerede fordi testmiljøet havde lav concurrency hvor 500ms altid var nok. Testene var _teknisk korrekte_ men _praktisk vildledende_. De gav et grønt signal for et fix der ville fejle under produktionsbelastning.

Forsvaret er ligetil men kræver disciplin. Review dine tests med samme grundighed som du reviewer din kode. Spørg: "Hvis agenten introducerede en subtil bug, ville denne test fange den?" Hvis svaret er nej, er testen møbler — den får rummet til at se beboet ud men gør faktisk ingenting.

== Den Dydige Cyklus

Når du sætter alt dette sammen — gode tests, hurtig feedback, sandboxede miljøer og en agent i loopet — klikker noget.

Agenten tager en opgave op. Den læser de eksisterende tests for at forstå forventet adfærd. Den laver en ændring. Den kører den hurtige testsuite — ti sekunder. To fejl. Den læser fejlbeskederne, forstår problemet, justerer. Kører igen. Grønt. Den skriver nye tests til den nye adfærd. Kører den fulde integrationssuite — ét minut. Alt grønt. Den committer med en beskrivende besked og giver dig en diff som du ved passerer hvert automatiseret tjek i dit system.

Du reviewer en diff som du ved passerer alle tests. Dit job skifter fra "tjek om dette virker" til "tjek om dette er den rigtige tilgang." Det er en meget bedre brug af din tid, og en meget bedre brug af din ekspertise. Du er ikke længere en menneskelig testkører. Du er en arkitekt der reviewer designs.

Og her er den akkumulerende effekt. Hver gang en agent arbejder på din codebase og testsuiten hjælper den med at lykkes, har du bevist værdien af de tests. Hver gang en manglende test forårsager en bug, mærker du smerten med det samme — og du tilføjer testen. Din testsuite vokser præcis de steder der tæller, styret af reel feedback fra rigtigt agentisk arbejde.

Det er den dydige cyklus i agentisk ingeniørarbejde: bedre tests fører til mere autonome agenter, som fører til hurtigere iteration, som giver dig mere tid til at skrive bedre tests. Hver omgang af cyklussen gør den næste hurtigere.

De ingeniører der får mest ud af agentiske værktøjer er ikke dem med de klogeste prompts eller de mest kraftfulde modeller. De er dem med de bedste testsuiter. En veltestet codebase er en kraftmultiplikator der akkumulerer med hver opgave du giver til en agent. En utestet codebase er en skat der gør hver opgave langsommere og mere risikabel.

Hvis du tager én ting med fra dette kapitel, lad det være dette: før du optimerer dine prompts, før du eksperimenterer med nye modeller, før du bygger avanceret orchestration — gå og skriv tests. Skriv dem til den kode dine agenter vil røre. Gør dem hurtige, deterministiske, isolerede og specifikke. Den investering vil betale sig mere end noget andet i denne bog.

Din testsuite er ikke overhead. Den er fundamentet alt andet er bygget på.
