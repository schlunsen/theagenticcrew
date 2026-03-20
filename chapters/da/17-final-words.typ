= Afsluttende Ord

Min ældste søn er fem. Han kan ikke rigtig læse endnu — han staver sig igennem ord på morgenmadspakker og vejskilte, stolt af hver stavelse. Men han ved hvad min computer gør. Han har set mig tale til den, set tekst dukke op på skærmen som svar, set mig nikke eller ryste på hovedet og tale igen. En aften kravlede han op i mit skød, så en agent refaktorere et modul i realtid — filer der åbnede og lukkede, tests der kørte, grønne flueben der dukkede op — og sagde: "Reparerer computeren sig selv?"

Jeg havde ikke et godt svar. Det har jeg stadig ikke, ikke helt. Men det spørgsmål fulgte mig gennem hvert kapitel af denne bog. For hvad jeg indså, siddende der med ham, var at jeg ikke skrev en bog om værktøjer. Jeg skrev en bog om hvad det vil sige at være ingeniør i det præcise øjeblik definitionen af ingeniørarbejde bliver omskrevet — og om hvad vi bærer med ind i hvad end der kommer derefter.

Dette kapitel er ikke et resumé. Du behøver ikke at jeg opsummerer femten kapitler du lige har læst. Det her er det jeg vil sige direkte til dig, én ingeniør til en anden, før vores veje skilles.

== Hvad Jeg Tror

Jeg tror at håndværket ikke er ved at dø. Det bliver _komprimeret_. Et årti af boilerplate og VVS og ceremoni kollapser til intention og dømmekraft. Det der er tilbage når man fjerner tastningen er det der altid var det egentlige job: at vide hvad man skal bygge og vide hvornår det er rigtigt.

Jeg tror agenter er forstærkere, ikke erstatninger. Giv en agent til en middelmådig ingeniør og du får middelmådig software med skræmmende hastighed. Giv en til en fremragende ingeniør og du får noget der, ærligt talt, får de sidste tyve års softwareudvikling til at ligne at vi byggede motorveje med skovle.

Jeg tror de ingeniører der trives vil være dem der mestrer de _kedelige_ ting — kontekst, guardrails, testing, konventioner, klar tænkning — mens alle andre jager den skinnende nye modelannoncering. Værktøjer skifter hvert kvartal. Dømmekraft akkumulerer over en karriere.

Jeg tror vi ikke bliver erstattet. Vi bliver forfremmet. Fra maskinskrivere til kaptajner. Fra kodere til _ingeniører_, i ordets fuldeste forstand. Spørgsmålet er om du accepterer forfremmelsen.

Jeg tror dette skift er _godt_. Ikke nemt. Ikke smertefrit. Men godt. For den del af vores arbejde der bliver automatiseret var aldrig den del vi elskede. Ingen blev ingeniør fordi de drømte om at skrive boilerplate JSON-parsere. Vi blev ingeniører fordi vi ville bygge ting der betyder noget. Nu kan vi.

== Hvad Jeg Tog Fejl I

Jeg skal være ærlig overfor dig: jeg skiftede mening mindst tre gange mens jeg skrev denne bog.

Da jeg startede kapitlet om sandboxes, troede jeg containerisolering var overkill til de fleste workflows. Da jeg var færdig med det, efter at en agent havde rm -rf'et et bibliotek jeg brød mig om en tirsdag eftermiddag, troede jeg sandboxing var ufravigeligt. Den oplevelse kom med i kapitlet. Overbevisningen bag det er arvæv.

Jeg skrev oprindeligt multi-agent-kapitlet med den antagelse at orchestrering af fem eller seks agenter samtidigt var den naturlige slutttilstand — en fabriksgulv af autonome arbejdere. Jeg har trukket mig fra det. Koordineringsoverheadet er reelt, fejltilstandene multiplicerer, og jeg har fundet at to eller tre velstyrede agenter udperformer seks uovervågede næsten hver gang. Kapitlet afspejler hvor jeg landede, men jeg lander måske et andet sted om seks måneder.

Jeg var også, i en periode, for afvisende overfor lokale modeller. Jeg skrev et tidligt udkast der basalt sagt sagde "brug bare de kommercielle API'er." Så brugte jeg en weekend på at køre en fintunnet lokal model på en codebase med proprietære begrænsninger og indså at der er en hel verden af use cases hvor lokalt ikke bare er levedygtigt men _nødvendigt_. Kapitlet om lokale versus kommercielle modeller eksisterer fordi jeg tog fejl og måtte rette mig selv.

Dele af denne bog er sandsynligvis allerede forkerte på måder jeg ikke kan se endnu. Landskabet bevæger sig så hurtigt. Men de specifikke værktøjer var aldrig pointen. Hvis jeg har hjulpet dig med at opbygge en mental model — en måde at tænke om autonomi, tillid og struktur — så har bogen gjort sit job, selv når alle kodeeksempler i den er forældede.

== Mandskabsmetaforen, Én Sidste Gang

Jeg voksede op i Danmark, tæt på vandet. Hvis du har sejlet i skandinaviske farvande, kender du lyset om sent om sommeren — lavt og gyldent, den slags lys der får havet til at ligne hamret kobber. Jeg husker en overfart engang, en lille båd, fire af os. Vinden drejede hårdt og pludseligt bevægede vi os alle uden at tale. Én person på fokken, én på storsejlet, én der trimmede, én ved roret. Ingen kommandoer. Bare tillid opbygget over snesevis af tidligere ture.

Det er hvad agentisk ingeniørarbejde føles som på en god dag. Du ved roret, agenter der trimmer og justerer, arbejdet der flyder fordi du har lagt timerne i at opbygge fælles kontekst — gennem konventioner, gennem guardrails, gennem testsuiter der fanger fejl før de tæller. Du behøver ikke at råbe instruktioner. Systemet _ved_.

Og så er der de dårlige dage. De dage vinden lægger sig og en agent hallucinerer et API der ikke eksisterer, eller omskriver et modul du ikke bad den om at røre, eller passerer alle testene fordi den slettede dem der fejlede. De dage øser du vand og bander. Det er også sejlads.

Men jeg bør være ærlig om noget, for denne bog virker ikke hvis jeg ikke er det.

Metaforen om et _mandskab_ antyder loyalitet. Kontinuitet. Skibskammerater du har sejlet med før, der kender dine vaner, der foregriber den næste kommando. Det er et smukt billede. Det er heller ikke sådan jeg faktisk arbejder.

De fleste dage er hvad jeg faktisk gør at spinne en agent op, give den et job, tage outputtet og smide den over bord. Så spinner jeg en anden op. De husker ikke den sidste session. De ved ikke hvad jeg bad den forrige agent om at gøre. Hver ankommer frisk, gør sit arbejde og forsvinder. Det er mindre et loyalt mandskab og mere som at hyre havnearbejdere i hver havn — du briefer dem, du ser dem arbejde, du betaler dem af, og i næste havn gør du det igen.

Og det er fint. Det er sådan de fleste rigtige mandskaber fungerede gennem maritim historie. Skibet var kontinuiteten. Kaptajnen var kontinuiteten. Kortene, logbogen, rigningen — det persisterede mellem rejser. Mandskabet blev ofte samlet til én enkelt overfart og opløst ved destinationen. Det der fik det til at fungere var ikke at søfolkene kendte kaptajnen. Det var at kaptajnen kendte _skibet_ — og havde systemer gode nok til at enhver kompetent sømand kunne gå om bord og være nyttig.

Det er hvad din codebase er. Det er hvad dine konventioner, dine testsuiter, dine CLAUDE.md-filer, dine guardrails er. De er skibet. Hver ny agent du spinner op er et friskt besætningsmedlem der træder om bord på et velrigget fartøj. De behøver ikke at kende din historie. De behøver at kende skibet. Og hvis du har bygget skibet godt, vil de være produktive på minutter.

Så ja — smid dem over bord. Spin nye op. Det er ikke et svigt af metaforen. Det er metaforen der virker præcis som tiltænkt. Mandskabet er til at smide væk. Skibet er det ikke.

Du er kaptajnen. Du var altid kaptajnen. Mandskabet er netop ankommet — og de vil blive ved med at ankomme, friske og klar, hver gang du har brug for dem.

== Tak

Tak fordi du læste denne bog. Det mener jeg. Du byttede din tid og opmærksomhed for mine ord, og det tager jeg ikke let på. Jeg håber jeg fortjente det.

Tak til communityet — ingeniørerne i fora, i Discord-servere, i open source-repos — der deler deres eksperimenter, deres fejl, deres hårdt tilkæmpede indsigter. Denne bog blev formet af hundredvis af samtaler jeg ikke havde alene.

Og tak, formoder jeg, til agenterne selv — der hjalp mig med at skrive kode, debugge problemer og af og til generere prosa så dårlig at det mindede mig om hvorfor menneskelig dømmekraft stadig er vigtig. I er et godt mandskab. I bliver bedre. Og jeg har en mistanke om at inden min søn er gammel nok til at læse denne bog, vil I være noget ingen af os helt forudså.

== Gå Ud Og Byg Noget

Her er hvad jeg vil have dig til at gøre.

I aften — ikke i morgen, ikke i næste uge, _i aften_ — åbn din terminal. Vælg en bug du har undgået. Den du bliver ved med at flytte til bunden af backloggen, den der er irriterende men ikke presserende, den der bor i en del af codebasen du helst ikke vil røre. Peg en agent mod den. Giv den kontekst. Sæt en guardrail. Se hvad der sker.

Måske fikser den buggen på fire minutter og du føler grunden flytte sig under dine fødder, som den flyttede sig under mine den aften med migrationsscriptet. Måske laver den rod og du lærer noget om hvordan man giver bedre instruktioner. Uanset hvad ved du mere end du gjorde før.

Så gå større. Sæt worktree-isolering op og kør to agenter parallelt. Skriv en CLAUDE.md-fil til et projekt du holder af. Byg en testsuite der er god nok til at være dit sikkerhedsnet når agenter committer kode. Refaktorér det modul alle er bange for — men denne gang med et mandskab.

Så gå endnu større. Introducér agentiske workflows til dit hold. Del hvad du har lært — sejrene _og_ katastroferne. Skriv dine egne krigshistorier ned. Bidrag til den kollektive viden om en disciplin der stadig er ved at blive opfundet.

For det er hvad det her er: en disciplin der opfindes, lige nu, af de mennesker der er villige til at gøre arbejdet. Ikke af dem der skriver blogindlæg om fremtiden. Ikke af dem der venter på det perfekte værktøj. Af de mennesker der åbner en terminal i dag og bygger noget rigtigt med det de har.

De ingeniører der vil definere denne æra venter ikke på tilladelse. De venter ikke på sikkerhed. De shipper, bryder ting, lærer og shipper igen — med et mandskab ved deres side der bliver lidt bedre hver dag.

Jeg håber du vil være en af dem.

#align(right)[
  _Rasmus Bornhøft Schlünsen_ \
  _Marts 2026_
]
