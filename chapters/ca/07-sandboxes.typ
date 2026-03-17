= Sandboxes

Un sandbox es un regal que dones al teu agent: la llibertat d'equivocar-se.

Quan un agent opera en un sandbox, pot provar coses sense consequencies. Instal·lar una dependencia estranya. Reescriure un modul de zero. Executar un script que podria petar. Si funciona, genial -- n'extreus el resultat. Si no, llences el sandbox. Sense netejar, sense rollback, sense danys.

Aixo no es nomes una mesura de seguretat. Canvia fonamentalment com de productiu pot ser un agent.

== El Problema de la Por

Sense un sandbox, cada accio de l'agent comporta risc. L'agent dubta (o mes aviat, tu dubtes en deixar-lo actuar). Afegeixes mes restriccions, mes portes d'aprovacio, mes baranes -- i aviat l'agent es a penes mes util que un autocompletat sofisticat.

Els sandboxes resolen aixo fent el _cost del fracas_ essencialment zero. I quan el fracas es barat, l'experimentacio es gratuita. Un agent en un sandbox pot provar tres enfocaments diferents a un problema, executar-los tots, i deixar que tu triis el guanyador. Aixo es un flux de treball que es impossible quan cada accio es irreversible.

== Git Worktrees

Per a treball centrat en codi, els git worktrees son el sandbox mes lleuger que pots construir. Un worktree et dona una copia completa del teu repo en un directori separat, a la seva propia branca, en segons.

El flux de treball es aixi:
+ Crea un worktree per a la tasca
+ Apunta l'agent cap alla
+ Deixa'l treballar -- commits, canvis de fitxers, execucions de tests, el que necessiti
+ Revisa el resultat
+ Fusiona si es bo, esborra el worktree si no

A la practica, aixo es veu aixi:

```bash
# Crea un espai de treball aillat per a l'agent
git worktree add ../myapp-refactor agent/refactor-auth
cd ../myapp-refactor

# L'agent treballa aqui -- completament aillat
# Quan acabi, revisa i fusiona:
cd ../myapp
git merge agent/refactor-auth

# Neteja
git worktree remove ../myapp-refactor
git branch -d agent/refactor-auth
```

Sense contenidors per construir, sense VMs per arrencar. Nomes git. Aixo es especialment potent quan executes multiples agents en paral·lel -- cadascun te el seu propi worktree, la seva propia branca, el seu propi espai de treball aillat.

Tinc un alias de shell per a aixo perque ho faig servir molt sovint:

```bash
# In .bashrc / .zshrc
agent-sandbox() {
  local name="${1:?Usage: agent-sandbox <name>}"
  local branch="agent/$name"
  local dir="../$(basename $PWD)-$name"
  git worktree add "$dir" -b "$branch"
  echo "Sandbox ready: $dir (branch: $branch)"
}
```

== Contenidors

Per a tasques que van mes enlla del codi -- instal·lar paquets de sistema, executar serveis, provar canvis d'infraestructura -- els contenidors son el sandbox natural. Docker et dona un entorn reproduible i aillat que pots crear en segons i destruir igual de rapid.

La clau es fer el teu projecte amigable amb contenidors. Un bon `Dockerfile` i `docker-compose.yml` ja no son nomes per a desplegament -- son infraestructura d'agents. Quan el teu projecte pot arrencar en un contenidor amb una sola comanda, has donat a cada agent la capacitat de treballar en una sala neta.

Un Dockerfile minim amigable amb agents es veu aixi:

```dockerfile
FROM node:22-slim
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# L'agent pot executar tests, lint, build -- tot aillat
CMD ["npm", "test"]
```

El patro es: rapid de construir, facil de destruir, conte tot el que l'agent necessita per verificar la seva propia feina. Si el teu contenidor triga quinze minuts a construir-se, l'agent no iterara prou rapid per ser util. Optimitza per a velocitat de reconstruccio -- posa les dependencies en capes, utilitza imatges base lleugeres, cacheja agressivament.

== Entorns Efimers

Els sandboxes mes sofisticats son entorns efimers basats al cloud -- desplegaments de previsualitzacio de curta durada que s'aixequen per branca o per tasca. Serveis com Railway, Fly.io, o entorns de desenvolupament al cloud et donen una pila completa en execucio que es completament d'un sol us.

Aixo importa per als tests d'integracio. Un agent pot desplegar els seus canvis a un entorn efimer, executar tests end-to-end contra infraestructura real, verificar que tot funciona, i llavors tu decides si promocionar-ho a staging. L'agent mai toca els teus entorns reals.

L'economia es convincent. Un entorn de previsualitzacio que funciona dues hores mentre l'agent treballa costa centims. L'incident de produccio que preveu costa milers. Les matematiques sempre afavoreixen mes sandboxing, no menys.

== L'Espectre del Sandbox

Hi ha un espectre de sandboxing, i la tria correcta depen de la tasca:

*Worktrees* -- per a canvis de codi purs. El mes rapid de crear i destruir. Sense aillament mes enlla del sistema de fitxers. Bo per a: refactoritzacions, branques de funcionalitat, escriptura de tests. Segons per configurar.

*Contenidors* -- per a codi mes entorn. Sistema de fitxers, xarxa i processos aillats. Bo per a: canvis de dependencies, treball a nivell de sistema, qualsevol cosa que pugui contaminar la teva maquina local. Minuts per configurar.

*Entorns efimers al cloud* -- per a verificacio de tota la pila. Infraestructura real, bases de dades reals, topologia de xarxa real. Bo per a: tests d'integracio, verificacio de desplegament, canvis multi-servei. Minuts per configurar, pero costa diners reals.

*VMs* -- per a maxim aillament. Kernel separat, tot separat. Bo per a: treball sensible a la seguretat, agents no confiables, automatitzacio d'infraestructura. Minuts a hores per configurar.

Comenca amb worktrees. Puja a l'espectre quan la tasca ho demani. La majoria del treball agentic diari mai necessita mes que un worktree.

== La Mentalitat del Sandbox

La llico mes profunda no es sobre eines -- es sobre dissenyar el teu flux de treball al voltant de la disponibilitat. Si el teu entorn de desenvolupament triga una hora a configurar-se, els sandboxes son impracticables. Si triga trenta segons, son naturals.

Inverteix en una configuracio rapida i reproduible. Inverteix en infraestructura com a codi. Inverteix en fer el teu projecte facil d'arrencar de zero. Aquestes inversions es retornen cada vegada que un agent necessita un espai segur per treballar -- que, a mesura que millores en enginyeria agentica, es constantment.

Una prova de lleixiu util: pot un nou desenvolupador (o un nou agent) anar de `git clone` a executar tests en menys de dos minuts? Si no, tens deute de sandbox. Cada minut de friccio de configuracio es un minut que desincentiva el sandboxing -- i agents sense sandbox son agents treballant sense xarxa.
