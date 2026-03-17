= Hvad Jeg Lærte Af At Bygge Mit Eget Agentværktøj

Her er hvad ingen fortæller dig når du begynder at arbejde med AI-agenter: det svære er ikke at få én agent til at gøre noget nyttigt. Det svære er at håndtere kaosset når du har tre af dem kørende på én gang. Fire terminalvinduer åbne, agenter der arbejder på forskellige opgaver, én der crashede lydløst for tyve minutter siden og du har ikke opdaget det. Agenterne har det fint. _Du_ er flaskehalsen.

Jeg brugte hundrede timer på at bygge mit eget værktøj til at løse dette — Clovr Code Terminal, en browserbaseret kontrolflade til at køre multiple agentsessioner. De timer lærte mig mere om agentisk ingeniørarbejde end nogen mængde læsning kunne have gjort. Dette kapitel destillerer de principper der kom ud af det. CCT er casestudiet, ikke pointen.

== Agentisk Arbejde Er Iboende Parallelt

Single-agent workflows er en krykke. Ikke altid — nogle gange er én agent på én opgave præcis det rigtige. Men den virkelige styrke ved agentisk ingeniørarbejde viser sig når du kører multiple agenter parallelt, hver fokuseret på en forskellig del af problemet.

Det er kontraintuitivt. De fleste af os er vokset op i en verden hvor _vi_ er den enkelte udførelsestråd. Skriv kode, så tests, så docs. Sekventielt. Agenter bryder den model — de kan alle arbejde samtidigt, men kun hvis du kan holde styr på dem.

Hvis dit workflow ikke giver dig synlighed over parallelt arbejde, vil du enten serialisere alt (og spilde agenternes potentiale) eller køre ting parallelt og miste overblikket (og spilde din egen tid på at rydde op i rodet). Uanset hvilket værktøj du bruger — tmux-paneler, multiple Cursor-projekter, selv en post-it der tracker hvad der kører hvor — løs synlighedsproblemet først. Agenterne styrer ikke sig selv.

#figure(
  image("../../assets/cct-dashboard.png", width: 100%),
  caption: [CCT's hoveddashboard — multiple agentsessioner kørende parallelt, med realtidsstatus og omkostningssporing.],
)

== Agenter Har Brug For Struktureret Kontekstoverlevering

Du har en agent der lige er færdig med at planlægge en feature. Den kender kravene, filstrukturen, edge cases. Nu vil du have en anden agent til at implementere det der blev planlagt. Hvordan overfører du den viden?

Den naive tilgang er copy-paste — grib planen fra agent éts output, paste den ind i agent tos prompt. Det virker, lige akkurat. Du mister nuancer, glemmer ting og bliver et menneskeligt clipboard, hvilket er præcis den slags lavværdiarbejde agenter skal eliminere.

Den bedre tilgang er strukturerede overleveringer: et defineret format til at sende kontekst fra én agent til en anden. Skriv en overleveringsskabelon. Få agenter til at opsummere deres arbejde i et konsistent format før de afslutter. Fodér det resumé til den næste agent. Det er "mandskab"-metaforen gjort operationel — agenter der samarbejder ikke gennem delt hukommelse, men gennem struktureret kommunikation.

Jeg har brugt dette mønster til at kæde tre agenter i sekvens: én til at planlægge, én til at designe, én til at implementere. Hver læser den forrige agents overlevering. Resultatet er konsekvent bedre end en enkelt agent der forsøger at gøre alt, fordi hver agent arbejder inden for en fokuseret kontekst i stedet for en udflydende en.

== Tillid Skal Være Konfigurerbar

Hvert tool call en agent laver — hver bash-kommando, hver filskrivning, hver netværksforespørgsel — er en tillidsbeslutning. At køre agenter uden guardrails er hurtigt og skræmmende. Én af mine kørte `rm -rf` på et bibliotek jeg brød mig om. (Det var i et worktree, så ingen reel skade. Lektien lærte jeg alligevel.) Den modsatte ekstrem — at godkende hver eneste operation manuelt — gør agenter ubrugelige. Du bruger al din tid på at klikke "tillad" på `git status` og `ls`.

Det rigtige svar er et konfigurerbart tillidsspektrum. Always-allow-regler for sikre kommandoer, manuel godkendelse for sensitive operationer og fuld-auto-tilstand til hurtig prototyping i disposable miljøer. Over tid bliver din tilladelseskonfiguration et levende dokument over dit tillidsforhold med agenterne.

Ethvert agentisk workflow har brug for en måde at tune tillid på. Hvis dit værktøj kun tilbyder "tillad alt" eller "godkend alt," vil du svinge mellem angst og frustration. Tilladelseslaget er ikke overhead — det er det der gør vedvarende agentisk arbejde muligt.

== Versionskontrol Er Agentinfrastruktur

Hver gang en agent lavede rod, var mit første instinkt `git diff` og `git stash`. Versionskontrol var allerede mit sikkerhedsnet. At gøre det til en førsteklasses del af værktøjet formaliserede bare det jeg allerede gjorde manuelt.

Princippet er simpelt: _lad aldrig en agent arbejde på din main-branch_. Giv den en branch. Giv den et worktree. Giv den en container. Uanset hvilken isoleringsmekanisme du foretrækker, brug den. Gode resultater bliver merged. Dårlige resultater bliver slettet. Intet rod, ingen risiko, intet drama.

#figure(
  image("../../assets/cct-new-session.png", width: 80%),
  caption: [Oprettelse af en ny session med worktree-isolering, tilladelsesmode og modelvalg — hvert princip fra denne bog bagt ind i en enkelt dialog.],
)

Hvis du bruger Claude Code i en terminal, giver et simpelt shell-script der opretter et worktree og starter en session dig firs procent af denne fordel. Værktøjet er ligegyldigt. Isoleringen er det der tæller.

== Du Behøver Ikke At Bygge Dit Eget

Jeg vil være direkte: _byg ikke din egen agentiske IDE._ Jeg gjorde det fordi jeg havde specifikke kløer der skulle klås og fordi det at bygge det lærte mig ting jeg ville skrive om. Men jeg kunne have været produktiv med Claude Code i en terminal og et par gode shell-scripts.

Principperne i dette kapitel — parallel synlighed, strukturerede overleveringer, konfigurerbar tillid, versionskontrol som infrastruktur — kan implementeres med ethvert værktøj:

- *Parallel synlighed:* tmux-paneler, en simpel logfil, selv en post-it der tracker hvad der kører hvor.
- *Strukturerede overleveringer:* en markdown-skabelon som agenter udfylder når de er færdige. Kopiér den til den næste agents prompt.
- *Konfigurerbar tillid:* Claude Codes tilladelsesflags, `.claude/settings.json`, eller bare at køre agenter i en begrænset sandbox.
- *Git-isolering:* et tre-linjers shell-script der opretter et worktree og starter en session.

Værktøjet er ligegyldigt. Den mentale model er det der tæller.

== Den Egentlige Lektie

Agentisk ingeniørarbejde handler ikke rigtig om agenterne. Det handler om _systemerne omkring agenterne_ — synligheden, kontekstoverleveringen, tillidsgrænser, isoleringen, feedback loops. Få dem rigtigt og næsten enhver kapabel model vil producere gode resultater. Få dem forkert og selv den bedste model vil skabe dyrt kaos.

Resten af denne bog handler om de systemer.
