= Orquestracio Multi-Agent

Un agent es potent. Multiples agents treballant junts es una altra cosa completament diferent.

Pensa-ho aixi. Un sol fuster pot construir una caseta. Pero una casa? Necessites un electricista, un lampista, un coberturer -- especialistes treballant en paral·lel, cadascun enfocat en el que fa millor, coordinant-se just el necessari per no estorbar-se. La casa s'aixeca mes rapid i la feina es millor que una sola persona intentant fer-ho tot.

L'enginyeria agentica funciona de la mateixa manera. Un sol agent en una tasca complexa la recorrera seqüencialment -- planificar, implementar, testejar, depurar, iterar. Funciona, pero es lent. Tres agents, cadascun gestionant una peca ben acotada del problema, poden acabar en un terc del temps. De vegades menys, perque agents enfocats cometen menys errors que un agent fent malabars amb massa preocupacions.

Pero hi ha un problema. Agents paral·lels requereixen _coordinacio_. I la coordinacio te un cost. Aquest capitol tracta sobre quan pagar aquell cost, i com pagar-lo be.

== Estrategies de Descomposicio

La part mes dificil del treball multi-agent no es executar multiples agents. Es decidir com dividir la feina.

La regla d'or: les tasques han de tenir _acoblament minim_. Si la feina de l'agent A depen de la sortida de l'agent B, no poden executar-se en paral·lel -- son seqüencials, i hauries de tractar-les aixi. L'art es trobar costures a la teva feina on pots tallar netament.

Hi ha tres patrons de descomposicio fiables.

*Per capa.* Un agent gestiona l'API de backend, un altre construeix el component de frontend, un tercer escriu els tests. Aixo funciona be perque les capes tenen fronteres naturals -- una interficie definida entre elles. Mentre acordeu el contracte d'API per endavant, cada agent pot treballar independentment.

*Per funcionalitat.* Si estas construint tres funcionalitats independents, dona cadascuna a un agent separat. Aquesta es la descomposicio mes simple. Les funcionalitats toquen fitxers diferents, directoris diferents, preocupacions diferents. Els conflictes de fusio son rars.

*Per preocupacio.* Un agent refactoritza, un altre escriu tests per al codi refactoritzat, un tercer actualitza la documentacio. Aixo es un patro seqüencial -- mes pipeline que paral·lel -- pero permet a cada agent enfocar-se en un sol tipus de pensament. L'agent de refactoritzacio no ha de canviar de context al mode d'escriptura de tests. Simplement refactoritza, i passa el relleu.

La descomposicio que triis depen de la forma de la feina. Pero el principi es constant: _troba les costures, talla per elles, minimitza la superficie on els agents necessiten estar d'acord_.

== Branca-per-Agent

Cada agent te la seva propia branca. Aixo ho vam cobrir al capitol de Git. En treball multi-agent, es converteix en absolutament essencial.

Pero les branques soles no son prou. Dos agents en branques diferents compartint el mateix directori de treball es barallaran pel sistema de fitxers -- sobreescriuran fitxers de l'altre, corrompran els builds de l'altre, trencaran les execucions de tests de l'altre. Necessites _worktrees_.

Cada agent te el seu propi git worktree: un directori separat, a la seva propia branca, amb la seva propia copia de la base de codi. Els agents comparteixen historial pero res mes. Poden compilar, executar tests, instal·lar dependencies, i fer un embolic -- tot sense afectar-se mutuament.

La configuracio es rapida:

```bash
git worktree add ../project-api agent/api-endpoint
git worktree add ../project-frontend agent/frontend-component
git worktree add ../project-tests agent/integration-tests
```

Tres directoris. Tres branques. Tres agents. Aillament complet. Aixo es el model de sandbox dels capitols anteriors fet concret per a treball multi-agent. Quan un agent acaba, revises la seva branca, fusiones si es bona, i elimines el worktree. Si la feina es dolenta, ho llences tot. Zero cost.

== El Patro de Traspas

No tot el treball multi-agent es paral·lel. De vegades els agents treballen _seqüencialment_, cadascun construint sobre l'anterior. L'agent A planifica. L'agent B implementa. L'agent C revisa.

Aixo es el patro de traspas, i es potent -- pero nomes si el propi traspas es net.

El problema amb agents seqüencials es la perdua de context. L'agent A te una comprensio rica del problema quan acaba de planificar. L'agent B comenca en fred. Si simplement dius a l'Agent B "implementa el pla," es perdra matisos. Fara suposicions diferents. Resoldra un problema lleugerament diferent del que l'Agent A va planificar.

L'arreglament es _traspas estructurat_. L'agent A no nomes planifica -- produeix un artefacte que captura el seu raonament. Aixo pot prendre diverses formes:

- *Un document resum.* Un fitxer markdown deixat al repo: `PLAN.md`. Descriu que ha de passar, quins compromisos es van considerar, que es va rebutjar i per que. L'agent B llegeix aixo abans d'escriure una sola linia de codi.
- *Un conjunt de fitxers.* L'agent A crea fitxers esquelet -- funcions buides amb docstrings, definicions d'interficies, signatures de tipus. L'agent B els omple. Els esqueletons _son_ el traspas.
- *Un prompt estructurat.* La sortida de l'agent A es converteix en l'entrada de l'agent B, formatada com una descripcio detallada de tasca amb criteris d'acceptacio. L'enganxes directament al context de l'Agent B.

La clau es que el traspas ha de ser _explicit i complet_. Sense suposicions implicites. Sense "el proxim agent ja ho descovrira." Cada decisio, cada restriccio, cada cas limit -- escrit.

Aixo requereix disciplina. Pero es la mateixa disciplina que aplicaries quan escrius un tiquet per a un col·lega huma en un altre continent i una altra zona horaria. Si no confiessis en un traspas verbal, no confiis en un d'implicit entre agents.

== El Problema de la Fusio

Aqui es on el treball multi-agent es torna genuinament dificil.

Tres agents van treballar en paral·lel. Cadascun va produir una branca neta i testejada. Ara necessites fusionar-les totes a main. De vegades aixo es indolor -- tres branques tocant fitxers completament diferents es fusionen sense un sol conflicte. Bonic.

De vegades no. L'agent A va canviar l'esquema de la base de dades. L'agent B va afegir una migracio que assumeix l'esquema antic. L'agent C va actualitzar el handler de l'API que tant A com B tambe van tocar. Ara tens un conflicte a tres bandes i cap agent sol te la imatge completa.

Hi ha tres estrategies per gestionar-ho.

*Prevencio.* Els millors conflictes de fusio son els que mai passen. Quan descomponguis la feina, pensa en la propietat de fitxers. Assigna directoris, moduls, fitxers diferents a agents diferents. Si els agents mai toquen el mateix fitxer, mai poden entrar en conflicte. Aquesta es l'estrategia mes barata i hauries d'utilitzar-la sempre que sigui possible.

*L'agent de fusio.* Quan sorgeixen conflictes, crea un nou agent la unica feina del qual es fusionar. Dona-li les branques, els conflictes, i el context de la feina de cada agent. Un bon agent de fusio pot resoldre la majoria de conflictes automaticament -- llegeix ambdos costats, enten la intencio, i produeix un resultat coherent. Es com un enginyer senior que s'asseu amb dos PRs i esbrina com encaixen.

*Revisio humana.* De vegades el conflicte es semantic, no sintactic. El codi es fusiona netament pero la _logica_ es contradiu. Dos agents van prendre decisions de disseny incompatibles. Cap fusio automatitzada ho detectara. Aqui es on guanyes el teu sou com a enginyer. Revisa les branques abans de fusionar. Llegeix els diffs costat a costat. Assegura't que les peces realment encaixen.

A la practica, faras servir les tres. Preven el que puguis. Automatitza la resta. Revisa-ho tot.

== Sobrecost d'Orquestracio

Mes agents no sempre es millor.

Cada agent addicional afegeix cost de coordinacio. Has de descompondre la feina. Configurar worktrees. Definir interficies. Gestionar fusions. Revisar multiples branques en lloc d'una. Per a una tasca que a un sol agent li costa trenta minuts, crear tres agents podria trigar quaranta-cinc -- vint minuts de treball d'agents en paral·lel mes vint-i-cinc minuts del teu temps orquestrant.

El punt d'equilibri es mes alt del que penses. En la meva experiencia, l'orquestracio multi-agent comenca a compensar quan la tasca total trigaria a un sol agent _almenys dues hores_. Per sota d'aixo, el sobrecost es menja els guanys.

Hi ha altres costos tambe. El context es fragmenta. Cada agent nomes veu la seva peca. Cap agent sol enten tot el sistema de la manera que ho faria un agent treballant sol. Aixo pot portar a inconsistencies -- convencions de noms diferents, patrons de gestio d'errors diferents, suposicions diferents sobre estat compartit.

L'habilitat no es executar tants agents com sigui possible. L'habilitat es saber _quan_ paral·lelitzar i quan un sol agent enfocat es l'eina correcta. Una tripulacio de cinc no sempre es mes rapida que un mariner experimentat que coneix el vaixell.

== Un Exemple Practic

Fem-ho concret. Estas construint una aplicacio web i necessites afegir una nova funcionalitat: notificacions d'usuari. Els usuaris haurien de veure una icona de campana amb un comptador, clicar-la per veure una llista, i marcar notificacions com a llegides. Necessites una API, un component de frontend, i tests.

Aixo es un cas de llibre de text per a tres agents en paral·lel.

*Pas 1: Defineix la interficie.* Abans de crear cap agent, dediques cinc minuts a escriure el contracte d'API. `GET /api/notifications` retorna una llista. `PATCH /api/notifications/:id` marca una com a llegida. L'objecte de notificacio te `id`, `message`, `read`, `created_at`. Escriu-ho en un document compartit o un fitxer esquelet. Aixo es el contracte contra el qual treballen els tres agents.

*Pas 2: Crea els worktrees.*

```bash
git worktree add ../app-api agent/notifications-api
git worktree add ../app-frontend agent/notifications-frontend
git worktree add ../app-tests agent/notifications-tests
```

*Pas 3: Llanca els agents.* Cada agent rep una tasca clara i acotada:

- Agent 1: "Implementa els endpoints de l'API de notificacions a `../app-api`. Segueix el contracte a `API_CONTRACT.md`. Inclou model, ruta i controlador. Escriu tests unitaris per al controlador."
- Agent 2: "Construeix el component d'interficie de notificacions a `../app-frontend`. Crida `GET /api/notifications` i `PATCH /api/notifications/:id`. Mostra una icona de campana amb comptador de no llegides. Clicar obre una llista desplegable."
- Agent 3: "Escriu tests d'integracio a `../app-tests`. Cobreix el flux complet: crear una notificacio, obtenir la llista, marcar com a llegida, verificar que el comptador s'actualitza."

*Pas 4: Deixa'ls treballar.* Els tres agents s'executen simultaneament. Cadascun commiteja a la seva propia branca. Monitors el progres pero no intervens tret que alguna cosa vagi malament.

*Pas 5: Revisa i fusiona.* Quan tots tres acaben, revises cada branca. La branca d'API es fusiona primer -- es la base. Despres la branca de frontend. Despres els tests. Executes la suite de tests completa despres de cada fusio per detectar problemes d'integracio aviat.

Temps total: potser quaranta minuts. L'agent d'API va trigar trenta, l'agent de frontend va trigar vint-i-cinc, i l'agent de tests va trigar trenta-cinc. Pero van executar-se en paral·lel, aixi que el temps real va ser trenta-cinc minuts mes deu minuts de la teva feina d'orquestracio.

Un sol agent fent-ho tot seqüencialment? Probablement noranta minuts.

Les matematiques funcionen quan la tasca es prou gran. I a mesura que millores en descomposicio, desenvoluparas una intuicio per quines tasques val la pena dividir i quines no. Com la majoria de coses en enginyeria, es una decisio de judici. Pero ara tens les eines per prendre-la.
