= Sandboxes

#figure(
  image("../../assets/illustrations/ch07-sandbox.jpg", width: 60%),
)

En sandbox er en gave du giver din agent: friheden til at tage fejl.

Når en agent opererer i en sandbox, kan den prøve ting uden konsekvenser. Installer en mærkelig afhængighed. Omskriv et modul fra bunden. Kør et script der måske crasher. Hvis det virker, fedt — du trækker resultatet ud. Hvis ikke, smider du sandboxen væk. Ingen oprydning, ingen rollback, ingen skade.

Det er ikke bare en sikkerhedsforanstaltning. Det ændrer fundamentalt hvor produktiv en agent kan være.

== Frygten

Uden en sandbox bærer hver agenthandling risiko. Agenten tøver (eller rettere, du tøver med at lade den handle). Du tilføjer flere begrænsninger, flere godkendelsesporte, flere guardrails — og snart er agenten knap mere nyttig end en fancy autocomplete.

Sandboxes løser dette ved at gøre _omkostningen ved fejl_ i bund og grund nul. Og når fejl er billigt, er eksperimentering gratis. En agent i en sandbox kan prøve tre forskellige tilgange til et problem, køre dem alle og lade dig vælge vinderen. Det er et workflow der er umuligt når hver handling er irreversibel.

== Git Worktrees

Til kodefokuseret arbejde er git worktrees den letteste sandbox du kan bygge. Et worktree giver dig en fuld kopi af dit repo i et separat bibliotek, på sin egen branch, på sekunder.

Workflowet ser sådan ud:
+ Opret et worktree til opgaven
+ Peg agenten mod det
+ Lad den arbejde — commits, filændringer, testkørsler, hvad end den behøver
+ Review resultatet
+ Merge hvis godt, slet worktree'et hvis ikke

I praksis ser det sådan ud:

```bash
# Opret et isoleret arbejdsrum til agenten
git worktree add ../myapp-refactor agent/refactor-auth
cd ../myapp-refactor

# Agenten arbejder her — fuldstændig isoleret
# Når den er færdig, review og merge:
cd ../myapp
git merge agent/refactor-auth

# Ryd op
git worktree remove ../myapp-refactor
git branch -d agent/refactor-auth
```

Ingen containere at bygge, ingen VM'er at boote. Bare git. Det er særligt kraftfuldt når du kører multiple agenter parallelt — hver får sit eget worktree, sin egen branch, sit eget isolerede arbejdsrum.

Jeg har et shell-alias til dette fordi jeg bruger det så ofte:

```bash
# I .bashrc / .zshrc
agent-sandbox() {
  local name="${1:?Usage: agent-sandbox <name>}"
  local branch="agent/$name"
  local dir="../$(basename $PWD)-$name"
  git worktree add "$dir" -b "$branch"
  echo "Sandbox ready: $dir (branch: $branch)"
}
```

== Containere

Til opgaver der rækker ud over kode — installation af systempakker, kørsel af services, test af infrastruktuændringer — er containere den naturlige sandbox. Docker giver dig et reproducerbart, isoleret miljø du kan spinne op på sekunder og ødelægge lige så hurtigt.

Nøglen er at gøre dit projekt containervenligt. En god `Dockerfile` og `docker-compose.yml` er ikke bare til deployment længere — de er agentinfrastruktur. Når dit projekt kan boote i en container med én kommando, har du givet enhver agent evnen til at arbejde i et rent rum.

En minimal agentvenlig Dockerfile ser sådan ud:

```dockerfile
FROM node:22-slim
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# Agenten kan køre tests, lint, build — alt isoleret
CMD ["npm", "test"]
```

Mønstret er: hurtig at bygge, nem at destruere, indeholder alt agenten behøver for at verificere sit eget arbejde. Hvis din container tager femten minutter at bygge, vil agenten ikke iterere hurtigt nok til at være nyttig. Optimér for rebuild-hastighed — lag dine afhængigheder, brug slanke base images, cache aggressivt.

== Efemere Miljøer

De mest sofistikerede sandboxes er cloudbaserede efemere miljøer — kortlivede preview-deployments der spinnes op per branch eller per opgave. Services som Railway, Fly.io eller cloud dev environments giver dig en fuld kørende stack der er fuldstændig til at smide væk.

Det er vigtigt for integrationstest. En agent kan deploye sine ændringer til et efemert miljø, køre end-to-end tests mod rigtig infrastruktur, verificere at alt virker, og så beslutter du om det skal promoveres til staging. Agenten rører aldrig dine rigtige miljøer.

Økonomien er overbevisende. Et preview-miljø der kører i to timer mens agenten arbejder koster ører. Den produktionsincident det forhindrer koster tusindvis. Matematikken favoriserer altid mere sandboxing, ikke mindre.

== Sandbox-Spektrummet

Der er et spektrum af sandboxing, og det rigtige valg afhænger af opgaven:

*Worktrees* — til rene kodeændringer. Hurtigst at oprette og destruere. Ingen isolering ud over filsystemet. Godt til: refaktoreringer, feature branches, testskrivning. Sekunder at sætte op.

*Containere* — til kode plus miljø. Isoleret filsystem, netværk og processer. Godt til: afhængighedsændringer, systemniveau-arbejde, alt der kan forurene din lokale maskine. Minutter at sætte op.

*Efemere cloud-miljøer* — til full-stack-verifikation. Rigtig infrastruktur, rigtige databaser, rigtig netværkstopologi. Godt til: integrationstest, deployment-verifikation, multi-service-ændringer. Minutter at sætte op, men koster rigtige penge.

*VM'er* — til maksimal isolering. Separat kerne, separat alt. Godt til: sikkerhedsfølsomt arbejde, upålidelige agenter, infrastrukturautomatisering. Minutter til timer at sætte op.

Start med worktrees. Bevæg dig op ad spektrummet når opgaven kræver det. Det meste dagligdags agentiske arbejde har aldrig brug for mere end et worktree.

== Sandbox-Tankegangen

Den dybere lektie handler ikke om værktøjer — det handler om at designe dit workflow omkring disponibilitet. Hvis dit udviklingsmiljø tager en time at sætte op, er sandboxes upraktiske. Hvis det tager tredive sekunder, er de naturlige.

Investér i hurtig, reproducerbar opsætning. Investér i infrastructure as code. Investér i at gøre dit projekt nemt at boote fra bunden. De investeringer betaler sig selv tilbage hver gang en agent har brug for et sikkert rum at arbejde i — hvilket, efterhånden som du bliver bedre til agentisk ingeniørarbejde, er konstant.

En nyttig lakmustest: kan en ny udvikler (eller en ny agent) gå fra `git clone` til kørende tests på under to minutter? Hvis ikke, har du sandbox-gæld. Hvert minut af opsætningsfriktion er et minut der modvirker sandboxing — og usandboxede agenter er agenter der arbejder uden net.
