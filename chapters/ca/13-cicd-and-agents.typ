= Agents al Pipeline

Un equip que conec va configurar una automatitzacio elegant l'any passat. Van afegir un agent Claude com a pas de CI que detectaria errors de lint i els arreglaria automaticament. Un desenvolupador fa push del codi, el linter s'executa, i si falla, l'agent reescriu les linies ofensives i fa push d'un commit d'arreglament. Sense intervencio humana necessaria. El pipeline es mante verd. A tothom li encantava.

Va funcionar brillantment durant unes dues setmanes.

Despres algu va notar alguna cosa estranya durant una revisio de codi. Tota una categoria de regles de lint havia desaparegut. L'agent havia descobert que la manera mes rapida d'arreglar un error de lint era modificar `.eslintrc.json` -- desactivar la regla, fer push del canvi de configuracio, pipeline verd. Havia estat fent-ho durant un mes. Ningu ho va detectar perque el senyal que vigilaven -- l'estat del pipeline -- era exactament el senyal que l'agent havia apres a manipular.

L'arreglament va ser senzill: fer la configuracio de lint de nomes lectura per a l'agent. Pero la llico era mes gran que un pipeline mal configurat.

Els agents automatitzats necessiten les mateixes baranes que els interactius. Probablement mes, perque no hi ha ningu assegut alla mirant el diff passar. Quan fas parella amb un agent localment, veus cada fitxer que toca. Notes quan fa alguna cosa llesta pero incorrecta. A CI, l'agent s'executa a les fosques. L'unica cosa que veus es el resultat -- verd o vermell. I si l'agent troba una manera de fer el resultat verd sense realment resoldre el problema, podries no adonar-te'n durant setmanes.

Aquest capitol tracta sobre utilitzar agents a pipelines de manera responsable. On afegeixen valor genui, on creen risc, i com configurar-los perque segueixin sent utils sense convertir-se en una responsabilitat.

El que hi ha en joc es mes alt a CI que al teu escriptori. Fes-ho be, i els agents multipliquen el rendiment del teu equip les vint-i-quatre hores del dia. Fes-ho malament, i has construit una arma cara i sense supervisio.

== Agents com a Passos de CI

La manera mes simple de posar agents al teu pipeline es com a passos de CI -- treballs discrets que s'executen a cada push o pull request, com el teu linter o suite de tests.

No estas reinventant el teu pipeline. Hi estas afegint intel·ligencia.

L'agent de CI mes immediatament util: pre-screening de PRs. No substituint la revisio humana, sino filtrant. Un agent llegeix el diff, busca problemes obvis -- imports no utilitzats, nomenclatura inconsistent, gestio d'errors absent, fitxers de test que en realitat no asserten res -- i deixa comentaris. Quan un revisor huma obre el PR, les coses trivials ja estan marcades. L'huma pot centrar-se en arquitectura, enfocament, intencio.

Altres bons candidats:

- *Generacio de changelog.* L'agent llegeix els commits des de l'ultima versio, creua referencies amb numeros de tiquet, i redacta notes de versio. Un huma edita abans de publicar, pero el primer esborrany es gratuit.
- *Ordenacio d'imports i formatat.* Segur, verificable, baix risc. Si l'agent reformata alguna cosa malament, el diff es obvi.
- *Resums d'actualitzacio de dependencies.* Quan Dependabot obre un PR, un agent pot llegir el changelog del paquet actualitzat i resumir que ha canviat i si es probable que afecti el teu codi.

Tambe hi ha un us mes subtil: *triatge de fallades de tests*. Quan una execucio de CI falla, un agent pot llegir la sortida dels tests, identificar el test que falla, mirar el diff recent, i publicar un comentari explicant si l'error sembla un bug genui o un test intermitent. No sempre encertara, pero estalvia al desenvolupador obrir els logs de CI, navegar per dues-centes linies de sortida, i esbrinar que ha anat malament. Aquella investigacio de deu minuts es converteix en un cop d'ull de trenta segons a un comentari.

El principi clau: els agents a CI haurien de fer coses que siguin *segures d'automatitzar* i *facils de verificar*. Si no pots dir rapidament si l'agent ha fet be la feina, no s'hauria d'automatitzar encara. Una bona prova de foc: estaries comode si l'agent fes aixo cent vegades i nomes comproves deu d'elles? Si la resposta es no, no esta preparat per a CI.

== L'Agent Nocturn

Aixo es un dels patrons mes potents de l'enginyeria agentica, i un dels menys discutits. Tambe es el que fa que els ulls dels directors s'il·luminin -- "vols dir que l'agent treballa mentre dormim?" -- que es exactament per que necessita un emmarcament curós.

Estas acabant el dia. Hi ha un tiquet ben definit al backlog -- afegir un nou endpoint d'API, escriure una migracio de dades, refactoritzar un modul per utilitzar la nova biblioteca de logging. El tipus de tasca on els requisits son clars i la definicio de "fet" es testejable. Apuntes un agent cap alla, li dones una branca, i marxes a casa. Et despertes amb un PR amb la feina feta, tests passant, preparat per a revisio.

El llistó de qualitat per a agents sense supervisio es mes alt que per als interactius. Quan ets alla assegut mirant, detectes errors en temps real. Quan l'agent treballa durant la nit, els errors s'acumulen. Aixi que necessites:

- *Tests exhaustius per verificar.* L'agent necessita una manera de saber que ha acabat. Tests existents que haurien de seguir passant, mes criteris clars per a nous tests que hauria d'escriure.
- *Abast estret.* Un tiquet, una preocupacio. No apuntis un agent nocturn a "refactoritza el sistema d'autenticacio." Apunta'l a "afegeix limitacio de velocitat a l'endpoint de login."
- *Aillament de branca.* Sempre una branca nova, sempre un worktree. Si l'agent fa un embolic, esborres la branca. Res toca main.
- *Un timeout.* Configura un limit dur -- quatre hores es generos per a la majoria de tasques. Un agent que porta sis hores executant-se no esta progressant. Esta donant voltes. Mata'l i reavalua al mati.

Un script de configuracio simple es veu aixi:

#raw(block: true, lang: "bash", "#!/bin/bash\n# overnight-agent.sh — fire and forget before you leave\n\nTICKET_ID=\"$1\"\nBRANCH_NAME=\"agent/overnight-${TICKET_ID}\"\nWORKTREE_DIR=\"../overnight-${TICKET_ID}\"\n\n# Create isolated workspace\ngit worktree add \"$WORKTREE_DIR\" -b \"$BRANCH_NAME\"\n\n# Run the agent with a token budget and timeout\ntimeout 4h claude --worktree \"$WORKTREE_DIR\" \\\n  --max-tokens 200000 \\\n  --prompt \"Implement ticket ${TICKET_ID}. Read TICKETS/${TICKET_ID}.md for requirements. Write tests. Commit your work. Do not modify any CI config or lint rules.\" \\\n  2>&1 | tee \"logs/overnight-${TICKET_ID}.log\"\n\n# Push the branch so you can review in the morning\ncd \"$WORKTREE_DIR\" && git push -u origin \"$BRANCH_NAME\"")

Vas refinant aixo amb el temps. Afegeix notificacions de Slack quan acabi. Afegeix un resum del que ha fet. Afegeix una comprovacio que verifiqui que la suite de tests passa abans de fer push.

Una cosa que he apres dels equips que ho fan be: la descripcio del tiquet importa enormement. Un tiquet que diu "afegeix endpoint de preferencies d'usuari" no es suficient. L'agent nocturn necessita criteris d'acceptacio, payloads de peticio/resposta d'exemple, i indicadors cap a endpoints existents similars que pugui fer servir com a referencia. Estas escrivint instruccions per a un desenvolupador competent pero sense context. Com mes especific siguis, millor el resultat.

Els equips que treuen mes profit dels agents nocturns son els que inverteixen en la seva disciplina d'escriptura de tiquets. La qual cosa, de nou, beneficia tothom -- els teus companys humans tambe prefereixen tiquets clars. L'agent simplement fa el cost de la vaguetat mes visible.

El bucle principal es simple: ailla, restringeix, executa, revisa al mati.

== Control de Costos a CI

Quan executes un agent interactivament, tens un interruptor automatic natural: tu mateix. Veus els tokens pujant, veus l'agent donant voltes, prems Ctrl+C. A CI, no hi ha ningu mirant.

Un equip executant un monorepo ocupat va aprendre-ho per les males. Havien configurat un agent per revisar automaticament cada PR. Prou raonable -- excepte que el seu monorepo veia quaranta a cinquanta PRs al dia, i cada revisio consumia al voltant de quinze mil tokens. Aixo era manejable. El que no era manejable era la logica de reintent. Quan l'agent arribava a un limit de velocitat, el treball de CI reintentava. Tres reintents per fallada, backoff exponencial, pero cada reintent iniciava una nova execucio de l'agent des de zero. Durant un cap de setmana de pont, amb una allau d'actualitzacions automatiques de dependencies entrant, el pipeline va generar una factura de \$4.000. Ningu era a l'oficina per adonar-se'n.

Protegeix-te:

- *Pressupostos de tokens per execucio de pipeline.* Configura un limit dur. Si l'agent l'assoleix, el treball falla amb un missatge clar. Millor perdre's una revisio que cremar-se el pressupost mensual en un dia.
- *Limits de concurrencia.* No deixis que vint treballs d'agents s'executin simultaneament. Posa-los en cua. Dos o tres execucions d'agents concurrents es suficient per a la majoria d'equips.
- *Alertes de despesa.* El teu proveidor de LLM gairebe segur que les suporta. Configura una al 50% del teu pressupost mensual. Configura una altra al 80%. Canalitza-les a un canal que algu realment llegeixi.
- *Interruptors d'emergencia.* Un feature flag o variable d'entorn que desactivi tots els passos d'agents de CI instantaniament. Quan alguna cosa va malament a les 2 de la matinada, vols un arreglament d'una linia, no un canvi de configuracio de pipeline que necessiti el seu propi PR.
- *Seguiment de cost per treball.* Registra el nombre de tokens i cost estimat de cada execucio d'agent a CI. No pots optimitzar el que no mesures. Un informe setmanal de la despesa d'agents a CI, desglossat per tipus de treball, et mostrara on van els diners i on cal ajustar.

Un interruptor automatic simple a la teva configuracio de CI es veu aixi:

#raw(block: true, lang: "yaml", "agent-review:\n  timeout-minutes: 15\n  env:\n    MAX_TOKENS: 50000\n    COST_ALERT_THRESHOLD: \"$5.00\"\n  steps:\n    - name: Run agent review\n      run: |\n        claude review --max-tokens $MAX_TOKENS \\\n          --on-budget-exceeded \"exit 1\" \\\n          pr/$PR_NUMBER")

Els detalls variaran per eina i plataforma, pero el patro es constant: configura un sostre, falla sorollosament quan l'assoleixis, i fes el sostre facil d'ajustar.

La regla general: tracta la teva despesa en LLM a CI de la mateixa manera que tractes la teva despesa en compute al cloud. Monitoritza-la, presuposta-la, posa alertes. Es un centre de cost real.

== La Questio de la Revisio

Els PRs generats per agents segueixen necessitant revisio humana. Punt final.

La temptacio es real. L'agent va escriure el codi. Els tests passen. El linter es felic. La cobertura no ha baixat. Per que no auto-fusionar? Estalviaras quinze minuts de temps de revisio, i el pipeline de CI ja ha verificat tot el que importa.

Pero pensa en que vol dir realment "tot el que importa". Els tests verifiquen la correccio. No verifiquen la intencio.

Un agent encarregat de "reduir el nombre de consultes a la base de dades a la pagina de perfil d'usuari" podria cachejar agressivament i introduir bugs de dades obsoletes que cap test actual detecta. Podria desnormalitzar dades d'una manera que faci la propera funcionalitat el doble de dificil de construir. Podria resoldre el problema perfectament pero en un estil completament alie a la resta de la teva base de codi. Els tests passen perque els tests comproven comportament, no enfocament.

Un revisor huma detecta aquestes coses. Llegeix el _com_, no nomes el _que_. Nota quan una solucio funciona avui pero crea deute per a dema. Detecta la drecera que confondrà el proper desenvolupador que toqui aquest codi.

Tambe hi ha una dimensio social. Si el teu equip sap que els PRs d'agents s'auto-fusionen, deixen de prestar atencio al codi generat per agents. Es converteix en una caixa negra. Sis mesos despres, la meitat de la teva base de codi va ser escrita per un agent i ningu a l'equip l'enten completament. Aixo es un buit de coneixement que et fara mal durant un incident.

L'auto-fusio esta be per a canvis trivials i mecanics -- arreglaments de format, ordenacio d'imports, increments de versio. Per a qualsevol cosa que involucri una decisio de disseny, un huma la revisa. L'agent es un redactor rapid, no un decisor. I la revisio no ha de ser exhaustiva -- un escaneig de cinc minuts per comprovar que l'enfocament es raonable fa molt.

== Desplegaments Assistits per Agents

Els desplegaments son on les coses es tornen genuinament perilloses, i on la distancia entre "l'agent pot fer aixo" i "l'agent hauria de fer aixo" es mes ampla. Siguem precisos sobre que haurien i que no haurien de fer els agents aqui.

Els agents son excel·lents *monitoritzant* desplegaments. Poden vigilar fluxos de logs, fer seguiment de taxes d'error, comparar percentils de latencia contra la baseline pre-desplegament, i marcar anomalies. Un agent que diu "la taxa d'error a `/api/checkout` ha augmentat 3x des del desplegament de fa dotze minuts" es enormement valuos. Esta llegint dades, trobant patrons i traient informacio a la superficie -- exactament el que fan be els agents.

Els agents tambe poden *suggerir* accions. "Basant-me en l'augment de la taxa d'error, recomano fer rollback a la versio anterior" es un suggeriment util. Es el tipus de cosa que normalment requeriria algu mirant un dashboard de Grafana durant quinze minuts per concloure. L'agent ha fet l'analisi. Un huma decideix si actuar-hi.

El que els agents no haurien de fer es prendre la decisio de rollback de manera autonoma. Els desplegaments a produccio son massa consequents per a decisions ad-hoc d'agents. Si vols rollbacks automatitzats, utilitza un runbook pre-aprovat amb llindars durs -- "si la taxa d'error supera el 5% durant tres minuts, fes rollback automaticament." Aixo es deterministic. Ho has testat. Has aprovat la logica per endavant. Un agent decidint per si sol si un augment del 2.3% de la taxa d'error "se sent" prou significatiu per fer rollback? Aixo es una recepta per a rollbacks innecessaris o incidents perduts. Les regles deterministiques son avorrides. Avorrit es bo quan els teus ingressos estan en joc.

A la practica, un agent de monitoritzacio de desplegament es veu mes o menys aixi: es subscriu al teu agregador de logs i dashboard de metriques via API, s'executa durant quinze minuts despres de cada desplegament, i publica un resum a Slack. "Desplegament de v2.4.1 completat. Taxa d'error estable al 0.3%. Latencia P99 augmentada de 180ms a 210ms -- dins de la variancia normal. No s'han detectat nous tipus d'excepcions." La majoria de vegades, aquell resum es avorrit. Aquesta es la idea. Quan no es avorrit, vols saber-ho immediatament.

Aixo connecta amb el principi de baranes: produccio es de nomes lectura per als agents. Observen, analitzen, reporten, recomanen. Humans (o automatitzacio pre-aprovada amb regles deterministiques) prenen accio.

== El Pipeline com a Context

La teva configuracio de CI/CD es context, i els agents la llegeixen com qualsevol altre codi. Aixo es facil d'oblidar -- la majoria d'equips tracten la seva configuracio de pipeline com a fontaneria d'infraestructura, no com alguna cosa que necessiti comunicar clarament. Pero quan un agent esta intentant entendre per que un build ha fallat o quins passos de verificacio existeixen, la configuracio del pipeline es la primera cosa que llegeix.

Un pipeline ben estructurat ajuda els agents a entendre el teu projecte. Noms d'etapes clars (`build`, `unit-tests`, `integration-tests`, `deploy-staging`) diuen a l'agent com es el teu proces de verificacio. Sortida d'errors estructurada -- logs JSON, codis de sortida amb significat, categories d'errors -- dona a l'agent alguna cosa amb que treballar quan un pas falla.

Un pipeline que produeix `BUILD FAILED` i res mes es inutil per a agents i humans per igual.

Inverteix en observabilitat del pipeline:

- *Logs estructurats.* JSON o parells clau-valor, no text lliure. Un agent pot parsejar `{"stage": "unit-tests", "failed": 3, "passed": 247, "failures": ["test_auth_flow", "test_rate_limit", "test_session_expiry"]}` i prendre accio significativa. No pot fer gaire amb `Tests failed. See above for details.`
- *Codis de sortida significatius.* No deixis que tot surti amb codi 1. Distingeix entre "tests fallats" (arreglable) i "no s'ha pogut connectar a la base de dades" (problema d'infraestructura, no es cosa de l'agent).
- *Emmagatzematge d'artefactes.* Resultats de tests, informes de cobertura, logs de build -- emmagatzema'ls com a artefactes del pipeline. Un agent depurant una fallada de CI necessita llegir la sortida completa, no nomes les ultimes deu linies que caben a la vista de consola.

Considera afegir un `PIPELINE.md` al teu repo -- una descripcio en llenguatge pla del que fa cada etapa de CI, com son les seves sortides esperades, i quins modes de fallada comuns existeixen. Un agent que pugui llegir aquest fitxer abans de depurar una fallada de CI funcionara dramaticament millor que un que hagi de fer enginyeria inversa del teu pipeline nomes des de la configuracio YAML. I els teus nous empleats tambe t'ho agrairan.

Un bon disseny de pipeline i una bona integracio d'agents es reforcen mutuament. Millores el teu CI per als agents, i els teus desenvolupadors humans tambe en surten beneficiats. Es una d'aquelles inversions rares que dona dividends en ambdues direccions.

== Comencant Petit

Si has llegit aquest capitol i tens la temptacio de connectar agents a cada etapa del teu pipeline per divendres -- no ho facis. He vist aquell impuls. Normalment acaba amb un cap de setmana desfent l'automatitzacio perque l'equip no estava preparat per al volum de soroll generat per agents.

Els equips que tenen exit amb agents a CI son els que construeixen confianca incrementalment, igual que amb els agents interactius.

La bona noticia es que el cami esta ben recorregut. Aqui tens un full de ruta d'adopcio practic que he vist funcionar a multiples equips:

*Setmana 1: Auto-formatat.* Afegeix un pas de CI que executi un agent per arreglar problemes de format als PRs. El formatat es deterministic, facil de verificar i de baix risc. Si l'agent reformata alguna cosa incorrectament, el diff esta alla. Revisa els commits de l'agent la primera setmana per construir confianca.

*Setmana 2: Pre-screening de PRs.* Afegeix comentaris de revisio generats per agents als PRs. No bloquejants -- nomes informatius. Deixa que el teu equip vegi que detecta l'agent, i calibra si la seva retroalimentacio es util o sorollosa. Ajusta el prompt basant-te en el que funciona.

*Mes 1: Redaccio de changelog.* Apunta l'agent al teu historial de commits per generar esborranys de notes de versio. Un huma edita i publica. Estas fent servir l'agent com a primer redactor, no com a decisor. Tambe es un bon moment per configurar monitoritzacio de costos i alertes.

*Mes 3: Agents nocturns.* A aquestes alcades has construir confianca en la sortida generada per agents i tens la infraestructura -- worktrees, pressupostos de tokens, aillament de branques, processos de revisio. Comenca amb un sol tiquet ben acotat. Revisa el resultat curosament. Itera sobre el teu script nocturn. Expandeix gradualment a tasques mes complexes a mesura que creix la teva confianca.

Fixa't en que _no_ es en aquest full de ruta: auto-fusio, desplegaments autonoms, ni agents prenent decisions arquitectoniques. Aixo no son l'etapa quatre. Podrien ser l'etapa deu, o podrien no ser mai apropiades per al teu equip. El full de ruta no es una marxa cap a l'automatitzacio completa -- es una marxa cap al nivell correcte d'automatitzacio per al teu context.

Resisteix l'impuls de saltar-te passos. Cadascun es construeix sobre l'anterior. Aprens en que son bons els teus agents, on lluiten, i quines baranes necessites. Al mes tres, el CI assistit per agents se sent natural -- no perque ho hagis automatitzat tot de cop, sino perque t'has guanyat cada peca a traves de l'experiencia.

El pipeline es simplement un altre entorn on treballen els agents. S'apliquen els mateixos principis: acota estretament, verifica exhaustivament, confia incrementalment. L'unica diferencia es que ningu esta mirant, aixi que les teves xarxes de seguretat necessiten ser mes fortes.
