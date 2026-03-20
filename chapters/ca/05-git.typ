= Git com a Infraestructura d'Agents

#figure(
  image("../../assets/illustrations/ch05-git-branches.jpg", width: 80%),
)

Ja coneixes Git. Portes anys commitejant, creant branques i fusionant. Pero en enginyeria agentica, Git no es nomes control de versions -- es la columna vertebral de tot el teu flux de treball. Es el teu boto de desfer, el teu marc d'execucio paral·lela, la teva interficie de revisio, i el teu sistema de documentacio tot alhora.

La majoria d'enginyers utilitzen potser el 20% del que Git ofereix. L'enginyeria agentica demana l'altre 80%.

== Commits Petits, Sempre

L'habit de Git mes important per a l'enginyeria agentica: commiteja petit, commiteja sovint.

Quan un agent fa canvis, vols poder revisar cada pas logic independentment. Un commit que diu "refactoritzat l'autenticacio, actualitzats els tests, arreglada la barra de navegacio, i canviat l'esquema de la base de dades" es impossible de revisar i impossible de revertir parcialment. Quatre commits separats -- cadascun fent una cosa -- et donen control quirurgic.

Aixo importa mes amb agents que amb desenvolupadors humans, perque els agents es mouen rapid. Un agent pot fer vint canvis de fitxers en trenta segons. Si aquells canvis estan agrupats en un commit, i alguna cosa es trenca, estas desembolicant un embolic. Si estan en cinc commits nets, reverteixes el que ha trencat les coses i mantens la resta.

Entrena't -- i els teus agents -- a commitejar en fronteres naturals:
- Despres de cada canvi logic, no despres de cada sessio
- Abans de canviar a una preocupacio diferent
- Despres que els tests passin, capturant un estat conegut com a bo
- Abans d'intentar alguna cosa arriscada, creant un punt de salvament

== Deixa que els Agents Escriguin els Teus Missatges de Commit

Aquesta es una de les victories mes facils en enginyeria agentica, i es gairebe vergonyosament simple: deixa que l'agent escrigui el missatge de commit.

Pensa-ho. L'agent acaba de fer els canvis. Sap exactament que ha modificat, per que ho ha modificat, i quina era la intencio. Te el diff complet al context. Escriura un missatge de commit mes precis i mes descriptiu que tu -- perque tu estaries resumint de memoria, i l'agent esta resumint a partir de fets.

Un missatge de commit huma tipic a les 11 de la nit: "fix auth bug"

Un missatge de commit tipic d'un agent: "fix session expiry race condition when WebSocket disconnects during OAuth token refresh -- the cleanup goroutine was running before the token exchange completed, leaving orphaned sessions in the database"

El segon es util sis mesos despres quan algu -- huma o agent -- esta intentant entendre per que existeix aquell codi. El primer es soroll.

Fes-ho un habit. Despres que l'agent completi una tasca, demana-li que commitegi amb un missatge descriptiu. O configura el teu flux de treball perque passi automaticament. La qualitat del teu historial de git millorara d'un dia per l'altre.

== Branques com a Limits de Tasca

Cada tasca d'agent te la seva propia branca. Aixo no es negociable.

La branca serveix multiples proposits:
- *Aillament.* Els canvis de l'agent no afecten la teva branca principal fins que explicitament els fusiones.
- *Abast de revisio.* Quan acabes, revises un sol PR -- el diff entre la branca i main. Aixo es un flux de treball que tots els enginyers ja coneixen.
- *Retorn.* Si tot esta malament, esborres la branca. Net. Sense cirurgia necessaria.
- *Treball en paral·lel.* Multiples agents en multiples branques, treballant simultaneament, sense trepitjar-se mai.

Nomena les teves branques descriptivament: `agent/refactor-auth-middleware`, `agent/add-user-tests`, `agent/fix-sidebar-rendering`. Quan miris la teva llista de branques, hauries de veure un manifest de tot el que els teus agents estan treballant.

== Worktrees per a Agents Paral·lels

Les branques soles no son suficients per a treball paral·lel real. Si dos agents estan en branques diferents pero compartint el mateix directori de treball, es barallaran pel sistema de fitxers. Els git worktrees resolen aixo.

Un worktree es un checkout separat del teu repo -- un directori diferent, en una branca diferent, compartint el mateix historial `.git`. Crear-ne un triga segons:

```bash
git worktree add ../my-project-feature feature-branch
```

Ara tens dos directoris: el teu checkout principal i el worktree. Cada agent te el seu propi worktree, la seva propia branca, el seu propi sistema de fitxers. Tots dos poden executar tests, modificar fitxers i compilar -- simultaneament, sense conflictes.

Quan la feina esta feta:
- Bon resultat -> fusiona la branca, elimina el worktree
- Mal resultat -> elimina el worktree, esborra la branca
- Necessites iterar -> mantin el worktree, continua la conversa

Aixo es el sandbox mes barat que pots construir. Sense contenidors, sense VMs, sense recursos al cloud. Nomes Git.

== Revisant la Feina dels Agents a Traves de Diffs

La teva interficie principal per revisar la feina dels agents no es llegir codi -- es llegir diffs.

Aixo es un canvi subtil pero important. Quan escrius codi tu mateix, el revises mentre l'escrius. Quan un agent escriu codi, el revises despres del fet. I la manera mes eficient de fer-ho es a traves del diff contra la teva branca base.

Desenvolupa les teves habilitats de lectura de diffs:
- *Comenca pels canvis de tests.* Si l'agent va escriure o modificar tests, llegeix-los primer. Et diuen que creu l'agent que el codi ha de fer. Si els tests coincideixen amb la teva intencio, la implementacio probablement esta be.
- *Busca desviacions d'abast.* L'agent ha canviat fitxers que no esperaves? Canvis de format no relacionats? Dependencies extra? Aixo son senyals d'alarma.
- *Comprova els limits.* Signatures de funcions, contractes d'API, esquemes de base de dades -- els canvis a les interficies tenen un impacte desproporcionat. Revisa-los amb cura.
- *Confia pero verifica.* Si el diff es gran, no llegeixis cada linia. Fes comprovacions puntuals dels camins critics, assegura't que els tests son significatius, i executa la suite tu mateix.

L'objectiu no es llegir cada linia que l'agent ha escrit -- aixo derrota el proposit. L'objectiu es verificar que els canvis de l'agent coincideixen amb la teva intencio i no introdueixen problemes. Els diffs fan aixo rapid.

== L'Historial de Git com a Documentacio

Aqui tens la perspectiva que la majoria d'enginyers es perden: els agents llegeixen el teu historial de git. Quan un agent esta intentant entendre per que existeix un codi, com va evolucionar una funcionalitat, o quin enfocament es va provar abans, mira `git log` i `git blame`.

Aixo vol dir que el teu historial de commits es documentacio. No del tipus que escrius a una wiki -- del tipus que esta incrustat al propi codi, permanentment, amb proveniencia perfecta.

Els bons missatges de commit es composen amb el temps. Sis mesos a partir d'ara, quan un agent estigui treballant a la teva base de codi, llegira aquells missatges per entendre el context. La diferencia entre un historial de "fix bug" i "fix race condition in session cleanup" es la diferencia entre un agent que enten la teva base de codi i un que esta endevinant.

I si el teu agent te acces per executar `git log` i `git blame` -- que hauria de tenir -- aquesta documentacio no es alguna cosa que has de copiar i enganxar als prompts. L'agent la llegeix directament del repositori. La teva feina es fer que l'historial valgui la pena llegir, no llegir-lo per a l'agent.

Aixo tambe s'aplica a les descripcions de PR, els noms de branques i els missatges de commits de fusio. Cada tros de text que adjuntes al teu historial de Git es context per a futurs agents. Escriu en consequencia.

== El Flux de Treball Git per a Enginyeria Agentica

Posant-ho tot junt, aqui tens el flux de treball:

+ Crea una branca per a la tasca
+ Opcionalment crea un worktree per a l'aillament
+ Apunta l'agent al worktree
+ Deixa'l treballar -- commitejant en fronteres naturals
+ L'agent escriu missatges de commit descriptius
+ Revisa el diff contra main
+ Fusiona si es bo, descarta si no

Aquest flux de treball es rapid, segur, i escala a multiples agents en paral·lel. Utilitza funcionalitats de Git que existeixen des de fa anys -- branques, worktrees, diffs -- pero les combina d'una manera construida a proposit per a l'enginyeria agentica.

La millor part: ja saps tot aixo. Portes anys utilitzant Git. L'enginyeria agentica no requereix eines noves -- requereix utilitzar les teves eines existents de manera mes deliberada.
