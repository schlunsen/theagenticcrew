= Git Som Agentinfrastruktur

#figure(
  image("../../assets/illustrations/ch06-git-branches.jpg", width: 80%),
)

Du kender allerede Git. Du har committet, branchet og merged i årevis. Men i agentisk ingeniørarbejde er Git ikke bare versionskontrol — det er rygraden i hele dit workflow. Det er din fortrydelsesknap, dit parallelle eksekverings-framework, din review-grænseflade og dit dokumentationssystem på én gang.

De fleste ingeniører bruger måske 20% af hvad Git tilbyder. Agentisk ingeniørarbejde kræver de andre 80%.

== Små Commits, Altid

Den vigtigste Git-vane for agentisk ingeniørarbejde: commit småt, commit ofte.

Når en agent laver ændringer, vil du kunne reviewe hvert logisk skridt uafhængigt. Et commit der siger "refaktorerede autentificering, opdaterede tests, fiksede navbaren og ændrede databaseskemaet" er umuligt at reviewe og umuligt at rulle delvist tilbage. Fire separate commits — hvert der gør én ting — giver dig kirurgisk kontrol.

Det betyder mere med agenter end med menneskelige udviklere, fordi agenter bevæger sig hurtigt. En agent kan lave tyve filændringer på tredive sekunder. Hvis de ændringer er bundlet i ét commit, og noget går i stykker, sidder du og vikler et rod fra hinanden. Hvis de er i fem rene commits, reverterer du det ene der brød tingene og beholder resten.

Træn dig selv — og dine agenter — til at committe ved naturlige grænser:
- Efter hver logisk ændring, ikke efter hver session
- Før du skifter til en anden bekymring
- Efter tests passerer, for at fange en known-good tilstand
- Før du forsøger noget risikabelt, for at oprette et gendannelsespunkt

== Lad Agenter Skrive Dine Commit-Beskeder

Det her er en af de nemmeste gevinster i agentisk ingeniørarbejde, og det er næsten pinligt simpelt: lad agenten skrive commit-beskeden.

Tænk over det. Agenten har lige lavet ændringerne. Den ved præcis hvad den modificerede, hvorfor den modificerede det, og hvad intentionen var. Den har den fulde diff i konteksten. Den vil skrive en mere præcis, mere beskrivende commit-besked end du ville — fordi du ville opsummere fra hukommelsen, og agenten opsummerer fra fakta.

En typisk menneskelig commit-besked klokken 23: "fix auth bug"

En typisk agent commit-besked: "fix session expiry race condition when WebSocket disconnects during OAuth token refresh — the cleanup goroutine was running before the token exchange completed, leaving orphaned sessions in the database"

Den anden er nyttig seks måneder fra nu når nogen — menneske eller agent — prøver at forstå hvorfor den kode eksisterer. Den første er støj.

Gør det til en vane. Når agenten fuldfører en opgave, bed den om at committe med en beskrivende besked. Eller konfigurér dit workflow så det sker automatisk. Kvaliteten af din git-historik vil forbedre sig fra den ene dag til den anden.

== Branches Som Opgavegrænser

Hver agentopgave får sin egen branch. Det er ikke til forhandling.

Branchen tjener flere formål:
- *Isolering.* Agentens ændringer påvirker ikke din main branch før du eksplicit merger dem.
- *Review-scope.* Når du er færdig, reviewer du en enkelt PR — diffen mellem branchen og main. Det er et workflow enhver ingeniør allerede kender.
- *Rollback.* Hvis det hele er forkert, sletter du branchen. Rent. Ingen kirurgi nødvendig.
- *Parallelt arbejde.* Multiple agenter på multiple branches, der arbejder samtidigt, uden at træde hinanden over tæerne.

Navngiv dine branches beskrivende: `agent/refactor-auth-middleware`, `agent/add-user-tests`, `agent/fix-sidebar-rendering`. Når du kigger på din branchliste, bør du se et manifest over alt hvad dine agenter arbejder på.

== Worktrees Til Parallelle Agenter

Branches alene er ikke nok til ægte parallelt arbejde. Hvis to agenter er på forskellige branches men deler det samme arbejdsbibliotek, vil de kæmpe om filsystemet. Git worktrees løser dette.

Et worktree er en separat checkout af dit repo — et andet bibliotek, på en anden branch, der deler den samme `.git`-historik. At oprette et tager sekunder:

```bash
git worktree add ../my-project-feature feature-branch
```

Nu har du to biblioteker: din hoved-checkout og worktree'et. Hver agent får sit eget worktree, sin egen branch, sit eget filsystem. De kan begge køre tests, modificere filer og bygge — samtidigt, uden konflikter.

Når arbejdet er gjort:
- Godt resultat → merge branchen, fjern worktree'et
- Dårligt resultat → fjern worktree'et, slet branchen
- Behov for at iterere → behold worktree'et, fortsæt samtalen

Det er den billigste sandbox du kan bygge. Ingen containere, ingen VM'er, ingen cloud-ressourcer. Bare Git.

== Review Af Agentarbejde Gennem Diffs

Din primære grænseflade til at reviewe agentarbejde er ikke at læse kode — det er at læse diffs.

Det er et subtilt men vigtigt skift. Når du selv skriver kode, reviewer du den mens du skriver. Når en agent skriver kode, reviewer du den bagefter. Og den mest effektive måde at gøre det på er gennem diffen mod din base branch.

Udvikl dine diff-læsningsfærdigheder:
- *Start med testændringerne.* Hvis agenten skrev eller modificerede tests, læs dem først. De fortæller dig hvad agenten mener koden bør gøre. Hvis testene matcher din intention, er implementeringen sandsynligvis fin.
- *Kig efter scope creep.* Ændrede agenten filer du ikke forventede? Urelaterede formateringsændringer? Ekstra afhængigheder? Det er røde flag.
- *Tjek grænserne.* Funktionssignaturer, API-kontrakter, databaseskemaer — ændringer af grænseflader har uforholdsmæssig stor påvirkning. Review dem omhyggeligt.
- *Stol men verificer.* Hvis diffen er stor, læs ikke hver linje. Spot-check de kritiske stier, sørg for at testene er meningsfulde, og kør suiten selv.

Målet er ikke at læse hver linje agenten skrev — det modvirker formålet. Målet er at verificere at agentens ændringer matcher din intention og ikke introducerer problemer. Diffs gør det hurtigt.

== Git-Historik Som Dokumentation

Her er den indsigt de fleste ingeniører misser: agenter læser din git-historik. Når en agent forsøger at forstå hvorfor kode eksisterer, hvordan en feature udviklede sig, eller hvilken tilgang der blev prøvet før, kigger den på `git log` og `git blame`.

Det betyder at din commit-historik er dokumentation. Ikke den slags du skriver i en wiki — den slags der er indlejret i koden selv, permanent, med perfekt proveniens.

Gode commit-beskeder akkumulerer over tid. Seks måneder fra nu, når en agent arbejder på din codebase, vil den læse de beskeder for at forstå kontekst. Forskellen mellem en historik af "fix bug" og "fix race condition in session cleanup" er forskellen mellem en agent der forstår din codebase og en der gætter.

Og hvis din agent har adgang til at køre `git log` og `git blame` — hvilket den bør have — er denne dokumentation ikke noget du behøver at kopiere og indsætte i prompts. Agenten læser den direkte fra repositoriet. Dit job er at gøre historikken værd at læse, ikke at læse den for agenten.

Det gælder også for PR-beskrivelser, branchnavne og merge commit-beskeder. Hver stump tekst du vedhæfter din Git-historik er kontekst for fremtidige agenter. Skriv derefter.

== Git-Workflowet For Agentisk Ingeniørarbejde

Sat sammen ser workflowet sådan ud:

+ Opret en branch til opgaven
+ Opret eventuelt et worktree til isolering
+ Peg agenten mod worktree'et
+ Lad den arbejde — committe ved naturlige grænser
+ Agenten skriver beskrivende commit-beskeder
+ Review diffen mod main
+ Merge hvis godt, kassér hvis ikke

Dette workflow er hurtigt, sikkert og skalerer til multiple parallelle agenter. Det bruger Git-features der har eksisteret i årevis — branches, worktrees, diffs — men kombinerer dem på en måde der er formålsbygget til agentisk ingeniørarbejde.

Den bedste del: du kender allerede alt dette. Du har brugt Git i årevis. Agentisk ingeniørarbejde kræver ikke nye værktøjer — det kræver at du bruger dine eksisterende værktøjer mere bevidst.
