= Når Agenter Tager Fejl

#figure(
  image("../../assets/illustrations/ch13-storm.jpg", width: 80%),
)

Enhver ingeniør der arbejder med agenter længe nok har en samling af disse historier. De øjeblikke hvor du læner dig tilbage i stolen, stirrer på skærmen og mumler noget der ikke kan trykkes. De er ydmygende. De er lærerige. Og de er _uundgåelige_.

Dette kapitel er en samling krigshistorier — ting der faktisk går galt når du giver rigtigt arbejde til en agent. Ikke hypotetiske. Ikke konstruerede demoer. Den slags fejl der koster dig en eftermiddag, en deploy eller din tro på automatisering. Hver en kan kobles tilbage til principper fra tidligere kapitler, for principper er billige indtil man lærer dem på den hårde måde.

Læs dem før du laver de samme fejl. Eller læs dem bagefter, og føl dig mindre alene.

== Den Ivrige Refaktør

Opgaven var simpel: fix et z-index-problem på en dropdown-menu. Dropdown'en renderedes bagved en modal-overlay. Et én-linjers CSS-fix — måske to hvis man er grundig.

Agenten så dropdown-komponenten, besluttede at dens CSS var "inkonsistent med moderne praksis" og refaktorerede den. Så bemærkede den at modalen brugte et andet stylingsmønster, så den refaktorerede det også. Så knapkomponenterne. Så kortkomponenterne. Før du kiggede op fra din kaffe, havde toogtyve filer ændret sig. Diffen var 1.400 linjer. Agenten havde i bund og grund omskrevet komponentbibliotekets stylingssystem, migreret fra én tilgang til en anden med beundringsværdig konsistens og nul autorisation.

Den originale z-index-bug? Stadig der. Begravet et sted i lavinen af ændringer havde agenten reproduceret det samme lagdelingsproblem med nye klassenavne.

PR'en var umulig at reviewe. Du kan ikke meningsfuldt reviewe 1.400 linjer CSS-ændringer på tværs af toogtyve filer. Du _kan_ slette branchen og starte forfra. Hvilket var hvad der skete.

*Hvad du gør anderledes nu:* Scop opgaver stramt. "Fix z-indexet på dropdown'en i `NavMenu.tsx`, rør intet andet." Brug en dedikeret branch så skaden er inddæmmet. Og tjek _altid_ diffen før du lader agenten gå videre til noget andet. I det øjeblik du ser filantallet stige ud over hvad der giver mening for opgaven, stop agenten. Guardrails-kapitlet eksisterer af en grund.

== Det Hallucinerede Bibliotek

Agenten havde brug for at parse nogle komplekse datointervaller fra brugerinput. Den importerede `@temporal/daterange-parser`, skrev elegant kode der brugte dens `.parseRange()`-metode med muligheder for lokalitetsbevidst parsing og fuzzy matching. Koden var ren. Typerne var korrekte. Fejlhåndteringen var gennemtænkt. Den skrev endda tests — som, naturligvis, også importerede den hallucinerede pakke.

Alt så perfekt ud i diffen. Funktionssignaturerne gav mening. API'et var veldesignet. Det var _så_ et plausibelt bibliotek at man næsten ikke stillede spørgsmål ved det.

Så fejlede `npm install`. Pakken eksisterede ikke. Havde aldrig eksisteret. Agenten havde opfundet et bibliotek, givet det et troværdigt navn og et sammenhængende API, og skrevet produktionskode mod en fiktion.

Den lumske del: hvis du kun havde lavet code review — læst logikken, tjekket typerne, evalueret tilgangen — ville du have godkendt det. Koden var _god_. Den var bare ikke forbundet til virkeligheden.

*Hvad du gør anderledes nu:* Agenten kører testene. Altid. Hvis dit setup ikke tillader det, kører du dem selv før du reviewer kode. Ingen undtagelser. Et fejlende `npm install` er et højlydt, åbenlyst signal. Et hallucineret API der aldrig blev eksekveret er en lydløs bombe. Tests fanger hvad menneskelig review misser — ikke fordi din review er dårlig, men fordi plausible fiktioner er _designet_ til at passere review. Det er hvad hallucination _er_.

== Det Uendelige Loop

Du bad agenten om at fikse en fejlende integrationstest. Den læste fejlen, lavede en ændring, kørte testen. Ny fejl. Den læste _den_ fejl, lavede endnu en ændring, kørte testen. Anderledes fejl. Så en variation af den første fejl. Så noget nyt. Så den første fejl igen.

Du var i en anden terminal og arbejdede på noget andet. Fyrre minutter senere tjekkede du ind. Agenten havde lavet nitten forsøg. Den havde brændt 200.000 tokens igennem. Koden var nu værre end da den startede — en geologisk lagdeling af fejlede fixes oven på hinanden. Agenten fortsatte stadig, muntert selvsikker på at forsøg tyve ville være det rette.

Det var det ikke.

Det fundamentale problem var at agenten ikke forstod _hvorfor_ testen fejlede. Den mønstermatchede på fejlbeskeder og lavede lokale rettelser, men det faktiske problem var en arkitektonisk misforståelse — en delt databasetilstand mellem test cases der krævede en helt anden opsætningstilgang. Ingen mængde tilpasning af koden under test ville fikse et problem i test-harnessen.

*Hvad du gør anderledes nu:* Sæt iterationsgrænser. Tre forsøg på det samme problem er et rimeligt maksimum. Hvis agenten ikke har løst det i tre omgange, løser den det ikke i tredive. Når du ser loopet — fejl, fix, anden fejl, fix, original fejl — _bryd det manuelt_. Stop agenten, læs fejlene selv, og giv den enten en helt anderledes tilgang eller tag over. Agentens tid er billig. Din spildte eftermiddag er det ikke. Vigtigere endnu, start en frisk kontekst. Agentens forståelse er nu forurenet med nitten forkerte teorier. En ren start med din diagnose af det _faktiske_ problem vil nå længere, hurtigere.

== Det Selvsikre Forkerte Svar

Et baggrundsjob processerede af og til det samme element to gange. Klassisk race condition. Du pegede agenten mod problemet.

Agenten analyserede koden, identificerede race-vinduet og tilføjede et 500ms delay mellem check og update. "Det sikrer at den forrige transaktion har tid til at committe før den næste kontrol sker," forklarede den, med den rolige selvsikkerhed som nogen der aldrig har driftet et system under belastning har.

Testene passerede. Delayet var længere end testens transaktionstid, så race-vinduet lukkede — i testmiljøet, med én samtidig worker, på en stille maskine.

Det gik i produktion. Under belastning, med tolv workers og variabel databaselatency, var 500ms nogle gange ikke nok. Og nu havde du et _nyt_ problem: delayet havde reduceret throughputtet nok til at jobkøen bakkede op under spidstimer, hvilket skabte kaskaderende timeouts der tog en urelateret service ned.

Sleep'et fiksede ikke race conditionen. Det skjulte den ved lav concurrency og gjorde systemet værre ved høj concurrency. Et ordentligt fix — en advisory lock eller en idempotency key — ville have været korrekt ved enhver skala. Agenten valgte det fix der gjorde testen grøn, ikke det fix der var _rigtigt_.

*Hvad du gør anderledes nu:* Du behandler passerende tests som nødvendige men ikke tilstrækkelige. Når en agent fikser et concurrency-problem, spørger du _dig selv_ om fixet er korrekt under belastning, under fejl, under betingelser testsuiten ikke dækker. Agenter optimerer for det feedbacksignal du giver dem, og hvis det signal er "tests passerer," vil de finde den korteste vej til grønt — selv hvis den vej er en `time.Sleep`. Din ingeniørmæssige dømmekraft om _hvorfor_ noget virker er vigtigere end _om_ testene passerer. Det er den del af jobbet der endnu ikke er automatiseret. Læn dig ind i den.

== Konteksthukommelsestabet

To timer inde i en session havde du en fint udviklende feature. Du havde fortalt agenten tidligt: "Brug ikke nogen ORM — vi skriver rå SQL i dette projekt. Det er et bevidst valg." Agenten kvitterede for dette og skrev rene, håndlavede forespørgsler til de første flere opgaver.

Så bad du den om at tilføje et nyt endpoint. Halvfems minutters kontekst havde akkumuleret. Agenten byggede endpointet — med Prisma. Fuld skemafil, migration, genereret klient. Smuk kode. Der fuldstændig modsagde begrænsningen du havde etableret i starten af sessionen og mønstrene i alle andre filer den havde skrevet den dag.

Da du påpegede det, undskyldte agenten, omskrev alt i rå SQL og opførte sig som om intet var sket. Den havde ikke _besluttet_ at ignorere din begrænsning. Den havde simpelthen mistet den. Kontekstvinduet var fyldt med nok mellemliggende arbejde til at den tidlige instruktion var blegnet til irrelevans.

*Hvad du gør anderledes nu:* Lange sessioner degraderer. Det er en fundamental egenskab ved hvordan kontekstvinduer fungerer, ikke en bug der patches næste kvartal. Hold opgaver korte og fokuserede. Commit fungerende kode ved naturlige grænser så fremskridt er fanget i git, ikke bare i samtalen. Start friske sessioner til friske opgaver. Og for projektbrede begrænsninger som "ingen ORM" eller "ingen nye afhængigheder," put dem i en `CLAUDE.md`-fil eller tilsvarende som agenten læser ved opstart. Stol ikke på at agenten _husker_ hvad du sagde for to timer siden. Det gør den ikke. Skriv det ned.

== Afhængighedslawinen

Du bad om en datovælger. Et simpelt inputfelt hvor brugere kan vælge en dato. Agenten evaluerede mulighederne og besluttede at være grundig.

Den installerede `moment.js` til datohåndtering. Så `@popperjs/core` til positionering af dropdown'en. Så et helt UI-komponentbibliotek fordi "det tilbyder tilgængelige datovælger-primitiver." Så en CSS-preprocessor fordi komponentbibliotekets temasystem krævede det. Så to hjælpepakker som komponentbibliotekets datovælger havde brug for som peer dependencies.

Seks nye afhængigheder. Din bundlestørrelse gik fra 180KB til 540KB. Din byggetid blev fordoblet. Du havde dog en datovælger. Den var meget pæn.

Det native HTML `<input type="date">` ville have været fint. Eller et enkelt letvægts-pickerbibliotek på 8KB. I stedet havde du arvet et helt økosystem fordi agenten optimerede for fuldstændighed i stedet for minimalisme.

Den værste del var ikke bundlestørrelsen — det var vedligeholdelsesoverfladen. Seks nye pakker betyder seks nye ting der kan have sikkerhedssårbarheder, seks nye ting der kan gå i stykker ved opgradering, seks nye changelogs at læse når Dependabot begynder at oprette PR'er. Du tilføjede ikke bare en datovælger. Du adopterede seks open source-projekter.

*Hvad du gør anderledes nu:* Begræns hvad agenter kan installere. "Ingen nye afhængigheder uden at spørge mig først" er en legitim og ofte _klog_ instruktion. Når du tillader nye pakker, fortæl agenten dine begrænsninger: bundlebudget, ingen pakker med færre end N ugentlige downloads, ingen pakker der trækker transitive megaafhængigheder med. Agenter har ikke meninger om bundlestørrelse eller vedligeholdelsesbyrde. De vedligeholder ikke projektet næste år. _Det gør du_. Så du sætter grænserne.

== Den Røde Tråd

Hver eneste af disse historier har den samme grundlæggende årsag: agenten gjorde _præcis hvad den var designet til at gøre_, og mennesket gav ikke nok struktur.

Den ivrige refaktør var hjælpsom. Det hallucinerede bibliotek var kreativt. Det uendelige loop var vedholdende. Det selvsikre forkerte svar var testdrevet. Konteksthukommelsestabet var en begrænsning, ikke et valg. Afhængighedslawinen var grundig.

Ingen af disse er agentbugs. De er _workflow_-bugs. Fixet er aldrig "brug en klogere agent." Fixet er altid det samme: strammere scope, bedre feedback loops, mere struktur, kortere sessioner og et menneske der forbliver engageret.

Og i stigende grad inkluderer fixet _at udstyre agenten med bedre værktøjer_. Det Hallucinerede Bibliotek ville være fanget hvis agenten kunne køre `npm install` og testsuiten. Det Uendelige Loop ville have været begrænset af iterationsgrænser i toolingen. Krigshistorier er ofte historier om agenter der manglede de rigtige værktøjer eller guardrails, ikke agenter der manglede intelligens.

Agenter tager fejl. Det gør mennesker også. Forskellen er at mennesker tager fejl langsomt nok til at det bemærkes. Agenter tager fejl med autocomplete-hastighed, og når du kigger op fra din kaffe har toogtyve filer ændret sig.

Bliv i loopet. Tjek diffs. Stol men verificer. Og når tingene går skævt — for det gør de — husk at slet-branchen-og-start-forfra-knappen er det mest undervurderede værktøj i dit workflow.

== Den Diagnostiske Drejebog

Krigshistorier er underholdende. Men du kan ikke tape anekdoter på din skærm. Hvad du har brug for er en systematisk tilgang — en tjekliste til når agenten producerer noget forkert, så du kan diagnosticere fejlen hurtigt og fikse det rigtige i stedet for at famle.

Når en agent giver dig dårligt output, kør igennem disse spørgsmål i rækkefølge. De fleste fejl falder i en af seks kategorier, og at vide hvilken kategori du er i bestemmer hvad du gør derefter.

*1. Er det et scopingproblem?*

Bad du om for meget i én prompt? Den Ivrige Refaktør skete fordi "fix z-indexet" var for vagt — det sagde ikke "rør intet andet." Hvis agenten ændrede filer du ikke forventede, eller lavede arbejde du ikke bad om, var scopet for løst. Stram prompten. Vær eksplicit om hvad der _ikke_ skal gøres. Begrænsninger er mere nyttige end instruktioner når man har med en entusiastisk agent at gøre.

*2. Er det et kontekstproblem?*

Havde agenten hvad den havde brug for til at løse det faktiske problem? Tænk tilbage på faktureringsbugshistorien fra kapitel 2 — én ingeniør gav vag kontekst og fik et vagt svar, den anden gav specifikke filer og fejlspor og fik et fungerende fix. Hvis agenten løste det _forkerte_ problem, kunne den sandsynligvis ikke se det rigtige. Giv den de relevante filer, fejloutputtet, de begrænsninger den ikke kan udlede. Agenter gætter ikke godt. De arbejder med det du giver dem.

*3. Er det et feedbacksignalproblem?*

Verificerer dine tests faktisk det rigtige? Det Selvsikre Forkerte Svar skete fordi testene passerede — men de testede ikke under realistiske betingelser. 500ms sleep-"fixet" var grønt i CI og forkert i produktion. Hvis agentens løsning føles tvivlsom men testene passerer, er _dine tests problemet_. Agenten optimerede for det signal du gav den. Giv den et bedre signal.

*4. Er det et kapacitetsproblem?*

Nogle opgaver er genuint ud over hvad modellen kan. Multi-fil-ræsonnering på tværs af et udbredt system med implicitte afhængigheder. Subtile concurrency-problemer der kræver forståelse af runtime-adfærd, ikke bare kodestruktur. Sikkerhedsfølsom logik hvor "plausibelt" ikke er godt nok. Hvis agenten bliver ved med at prøve forskellige tilgange og fejler, er den måske ikke i stand til denne bestemte opgave. Det er ikke et promptproblem — det er en begrænsning. Anerkend den og tag over. Din tid er bedre brugt på at gøre arbejdet end på at konstruere den perfekte prompt til en opgave agenten ikke kan håndtere.

*5. Er det et kontekstvindueproblem?*

Lange sessioner degraderer. Punktum. Konteksthukommelsestabs-historien demonstrerede dette — begrænsninger sat tidligt i en session forsvinder simpelthen efterhånden som konteksten fyldes med mellemliggende arbejde. Hvis agenten modsiger noget den gjorde korrekt tidligere i den samme session, eller ignorerer en begrænsning du satte for en time siden, er kontekstvinduet synderen. Start en frisk session. Gentag de relevante begrænsninger. Giv den kun den kontekst den har brug for til den aktuelle opgave, ikke det arkæologiske arkiv over alt hvad I har diskuteret i dag.

*6. Er det et loop?*

Tre forsøg på den samme fejl er grænsen. Hvis agenten ikke har løst det i tre omgange, løser den det ikke i tredive. Det Uendelige Loop-historien brændte 200.000 tokens af over nitten forsøg uden fremskridt. Når du ser mønstret — fejl, fix, anden fejl, fix, original fejl — bryd loopet øjeblikkeligt. Stop agenten. Læs fejlene selv. Giv enten agenten en helt anderledes tilgang med en frisk diagnose, eller tag fuldstændig over. Agentens kontekst er nu forurenet med fejlede teorier, og flere forsøg vil kun tilføje mere forurening.

Print denne tjekliste. Sæt den fast på din skærm. De første par gange kører du igennem den bevidst. Efter en måned bliver det instinkt. Efter tre måneder fanger du problemet før agenten overhovedet er færdig med sit første forsøg.
