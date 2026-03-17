= Hvornår Man Ikke Skal Bruge Agenter

Denne bog handler om at bruge agenter godt. Dette kapitel handler om at vide hvornår man slet ikke skal bruge dem.

Hvis du har læst så langt, er du sandsynligvis solgt på agentisk ingeniørarbejde. Godt. Men den hurtigste måde at miste troværdighed — og spilde tid — er at gribe efter en agent når jobbet kræver et menneske. De bedste agentiske ingeniører er ikke dem der bruger agenter mest. De er dem der ved _præcis_ hvornår de skal lægge agenten væk og gøre arbejdet selv.

== Overheadskatten

Enhver agentinteraktion har en omkostning. Du skriver prompten. Du venter på outputtet. Du reviewer hvad den producerede. Du fikser fejlene. Du genkører hvis den missede pointen. Det er overhead, og det er reelt.

For komplekse opgaver der ville tage dig en time er to minutter på prompt og review en god handel. Men for opgaver du kan gøre på tredive sekunder? Overheadet gør agenter _langsommere_, ikke hurtigere.

At omdøbe en variabel. Fikse en tastefejl. Justere en konfigurationsværdi. Tilføje en loglinje. Det er muskelhukommelsesopgaver. Dine fingre kender tastetrykkene. Inden du har tastet en prompt der beskriver hvad du vil, kunne du allerede have gjort det.

Det er ikke en fejl ved agenter. Det er aritmetik. Små opgaver har små gevinster, og de faste omkostninger ved agentinteraktion æder marginen. Lad ikke nyhedsværdien af agenter narre dig til at bruge dem til alt. Noget arbejde er bare hurtigere i hånden.

== Nye Arkitekturbeslutninger

Når du designer et system fra bunden — vælger mellem en monolit og microservices, beslutter din datamodel, vælger dine kommunikationsmønstre — er _tænkningen arbejdet_. Værdien ligger ikke i diagrammet eller dokumentet. Værdien ligger i den mentale model du bygger mens du kæmper med afvejningerne.

En agent kan hjælpe dig med at udforske muligheder. Den kan liste fordele og ulemper ved event sourcing versus CRUD. Den kan skitsere hvordan en bestemt arkitektur kan se ud. Det er nyttigt som input.

Men at delegere selve arkitekturen til en agent betyder at du ikke forstår dit eget system. Du vil kæmpe med at debugge det, udvide det eller forklare det til dit hold. Senioringeniørens job er at tage de svære beslutninger — at afveje de afvejninger der ikke har rene svar, at beslutte hvilken kompleksitet der er værd at bære og hvilken der ikke er. Den dømmekraft kommer af at gøre arbejdet, ikke af at læse en agents sammendrag af det.

Brug agenter som sparringspartner til arkitektur. Ikke som arkitekten.

== Sikkerhedskritisk Kode

Autentificeringsflows. Kryptering. Adgangskontrol. Inputvalidering. Tokenhåndtering. Det er områder hvor "ser korrekt ud" ikke er godt nok.

Sikkerhedsbugs er anderledes end almindelige bugs. En ødelagt sorteringsfunktion producerer forkert output som nogen bemærker. En ødelagt auth-kontrol producerer _ingen synlige symptomer_ indtil en angriber finder den. Koden ser fin ud. Testene passerer. Og seks måneder senere skriver du en incidentrapport.

Agenter producerer plausibel kode. Det er deres styrke og, i sikkerhedskontekster, deres fare. En subtil fejl i et JWT-valideringsflow, en manglende kontrol på en redirect-URL, en timing-sidekanal i en adgangskodesammenligning — det er den slags fejl der overlever code review fordi de _ser rigtige ud_.

Skriv sikkerhedskritisk kode selv. Review den omhyggeligt. Få et andet par menneskelige øjne på den. Hvis du bruger en agent til at udkaste sikkerhedskode, behandl det udkast med mere mistanke end du ville give en juniorudviklers første forsøg, ikke mindre.

== Når Du Har Brug For At Lære

Du tager et nyt sprog op. Et nyt framework. Et nyt paradigme. Fristelsen er åbenlys: lad agenten skrive koden mens du fokuserer på det overordnede billede.

Modstå det.

Hvis du lader agenten skrive al Rust-koden mens du lærer Rust, har du ikke lært Rust. Du har bygget noget du ikke kan vedligeholde, debugge eller udvide uden agenten. Du har skabt en afhængighed, ikke en færdighed.

Der er en afgørende forskel mellem at bruge en agent til at _forklare_ noget og bruge den til at _gøre_ noget. At spørge "hvorfor opstår denne borrow checker-fejl?" opbygger forståelse. At spørge "fix denne borrow checker-fejl" gør det ikke.

Når målet er læring, sæt farten ned. Skriv koden selv. Lav fejlene selv. Brug agenter som tutorer, ikke ghostwriters. Den forståelse du opbygger ved at kæmpe igennem de svære dele er hele pointen.

== Følelsesladede Beslutninger

Ikke enhver ingeniørbeslutning er teknisk. Nogle af de sværeste er menneskelige.

At deprecate et API som en partner afhænger af. At fortælle en stakeholder at deres feature request ikke når med. At skubbe tilbage på en deadline du ved er urealistisk. At beslutte at lukke et produkt der stadig har brugere.

Disse beslutninger kræver empati. De kræver at man læser rummet, forstår politikken, afvejer de menneskelige omkostninger ved siden af de tekniske. De kræver _ansvarlighed_ — nogen der vil eje beslutningen og dens konsekvenser.

En agent kan udkaste emailen. Den kan hjælpe dig med at gennemtænke talende punkter. Men selve beslutningen, og samtalen der leverer den, skal komme fra et menneske. Folk fortjener at høre svære nyheder fra en person, ikke fra nogen der copy-pastede en agents output.

== Når Codebasen Er For Rodet

Agenter forstærker hvad der allerede er der. I en ren, velstruktureret codebase med stærke konventioner producerer agenter ren, velstruktureret kode. De opfanger mønstrene og følger dem.

I et rod? De producerer mere rod.

Hvis din codebase har inkonsistent navngivning, sammenfiltrede afhængigheder, ingen klare modulgrænser og tre forskellige måder at gøre det samme på — vil en agent opfange _alle_ de mønstre. Den kan kombinere de værste dele af hvert. Den ved ikke hvilke mønstre der er tilsigtede og hvilke der er teknisk gæld. Den ser bare hvad der er der og producerer mere af det.

Nogle gange er det rigtige træk at rydde op før du bringer agenter ind. Refaktorér modulet. Etablér konventionen. Slet den døde kode. Gør codebasen til et sted hvor en agent kan gøre godt arbejde. Det er glamourløst, manuelt slid. Men det er det fundament der gør alt andet muligt.

Tænk på det som et værksted. Du giver ikke elværktøj til nogen i et rodet, uorganiseret værksted. Du rydder op først, _så_ bringer du værktøjerne ind.

== At Arbejde Med Legacy-Kode

Den værkstedsmetafor er pæn. Men ikke alle har den luksus at rydde op først. Nogle af os vedligeholder 500.000-linjers Java-monolitter der blev startet i 2014 og har været igennem tre framework-migrationer, to opkøb og en kort periode hvor nogen syntes XML-konfiguration var en god idé. Rådet om at "refaktorere før du bringer agenter ind" er sundt i teorien og latterligt i praksis når du stirrer på en codebase der ville tage år at refaktorere.

Så hvordan _bruger_ man agenter i legacy-kode? Forsigtigt. Og med en specifik strategi.

*Start med testene.* Før du peger en agent mod legacy-kode, skriv karakteriseringstests — tests der fanger hvad koden _aktuelt_ gør, ikke hvad den _burde_ gøre. De er ikke aspirationelle. De er beskrivende. De siger "når du kalder denne funktion med disse inputs, er det her der kommer ud, og det er den nuværende kontrakt uanset om nogen havde det som intention eller ej."

Karakteriseringstests giver agenten et sikkerhedsnet. Uden dem vil agenten ændre adfærd den ikke forstår, og du vil ikke vide det før produktion fortæller dig det. Med dem viser enhver adfærdsændring sig som en testfejl _før_ koden forlader din maskine. Det er ufravigeligt. Legacy-kode uden tests er legacy-kode du ikke sikkert kan lade agenter røre.

*Scop brutalt.* I en legacy-codebase kan agenten ikke forstå hele systemet. Forsøg ikke at få den til det. Peg den mod én fil, én funktion, én bug. Giv den den umiddelbare kontekst — funktionssignaturen, kallerne, den forventede adfærd — og intet andet. Legacy-kode er fuld af implicitte antagelser, udokumenterede sideeffekter og bærende mærkværdigheder. Jo mindre agenten ser, jo mindre kan den misfortolke. Et snævert scope med klar kontekst slår et bredt scope med arkæologisk kompleksitet.

*Brug agenter til de kedelige dele.* Legacy-codebases er fulde af mekanisk arbejde: opdatering af deprecated API-kald på tværs af hundredvis af filer, migrering fra én afhængighedsversion til en anden, tilføjelse af type-annotationer til utypet kode, standardisering af fejlhåndteringsmønstre, udskiftning af ét lognings-framework med et andet. Det er _perfekte_ agentopgaver — repetitive, veldefinerede, let verificerbare af automatiserede checks. Lad agenter gøre det kedsommelige. Gem din energi til de dele der kræver forståelse af _hvorfor_ koden er som den er. Det er arbejde kun et menneske der har levet med systemet kan gøre.

*Dokumentér undervejs.* Hver gang en agent arbejder på en legacy-fil med succes, tilføj en kort kommentar der forklarer hvad koden gør, eller opdater projektets `CLAUDE.md` med kontekst om det modul. Over tid sker der noget interessant: de dele af legacy-codebasen som agenter har rørt bliver bedre dokumenteret end de dele de ikke har. Ikke fordi du satte dig for at dokumentere systemet, men fordi at bruge agenter _tvang_ dig til at artikulere hvad hver del gør for at prompte effektivt. Agenterne gør langsomt codebasen mere læsbar — ikke ved at refaktorere den, men ved at få dig til at forklare den.

== Håndværksargumentet

Der er én grund mere til nogle gange at lægge agenten væk, og den handler ikke om effektivitet eller risiko. Den handler om håndværk.

At skrive kode i hånden opbygger noget agenter ikke kan give dig. Muskelhukommelse. Mønstergenkendelse der lever i dine fingre, ikke bare dit hoved. Den dybe, intuitive forståelse der kommer af at have skrevet den samme slags funktion dusinvis af gange. Den stille tilfredsstillelse ved at løse et svært problem gennem din egen ræsonnering.

De ting er vigtige. Ikke fordi de er romantiske, men fordi de gør dig til en bedre ingeniør. Udvikleren der har håndskrevet en parser forstår parsing anderledes end en der kun har promptet en agent til at skrive en. Udvikleren der har debugget et concurrency-problem klokken to om natten _mærker_ faren ved delt muterbar tilstand på en måde som at læse om det aldrig giver.

Agenter er værktøjer. Kraftfulde. Men hvis du lader dem gøre alt arbejdet, atrofierer dine egne færdigheder. Og når du rammer et problem som agenten ikke kan løse — og det gør du — har du brug for at de færdigheder stadig er skarpe.

Hold dig i øvelse. Skriv kode i hånden regelmæssigt. Ikke fordi det er hurtigere, men fordi det holder dig farlig.

== Den Dømmekraft Der Tæller

Den centrale færdighed i agentisk ingeniørarbejde er ikke prompting. Det er ikke værktøjskonfiguration. Det er ikke at vide hvilken model man skal bruge til hvilken opgave.

Det er _dømmekraft_.

At vide hvornår en agent vil spare dig en time og hvornår den vil spilde en. At vide hvornår du skal stole på outputtet og hvornår du skal omskrive det fra bunden. At vide hvornår du skal delegere og hvornår du skal grave dig ned selv.

De bedste agentiske ingeniører bruger agenter aggressivt — men selektivt. De rækker ud efter agenter når løftestangseffekten er reel: storstilede refaktoreringer, boilerplate-generering, kodeudforskning, testskrivning, dokumentation. Og de lægger agenten væk når arbejdet kræver menneskelig tænkning, menneskelig ansvarlighed eller menneskeligt håndværk.

Den dømmekraft er hvad der adskiller agentiske ingeniører fra promptjockeys. Alle kan taste en prompt. At vide _hvornår man ikke skal_ er den sværere færdighed.
