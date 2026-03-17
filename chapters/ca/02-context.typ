= Context

El mes passat, va arribar un bug d'un client: els pagaments fallaven silenciosament per als usuaris amb caracters no-ASCII a la seva adreca de facturacio. Un cas complicat -- del tipus que viu a la costura entre la validacio del teu frontend i la codificacio de caracters de la passarel·la de pagament.

Un enginyer del meu equip va agafar el tiquet primer. Va obrir el seu agent i va escriure: "Hi ha un bug amb els pagaments per a usuaris internacionals. Pots mirar-ho?" L'agent va llegir diligentment el modul de pagaments, va fer algunes suposicions plausibles sobre la gestio d'Unicode, i va produir un pedac que normalitzava tota l'entrada a ASCII. Hauria eliminat cada accent, cada dieresi, cada caracter fora de l'alfabet angles de cada adreca de facturacio de cada usuari. Un arreglament tecnicament pitjor que el bug.

Una hora despres, un segon enginyer va agafar el mateix tiquet despres que el primer intent fos rebutjat a la revisio. Va enganxar el log d'errors del client, la traca de Sentry que fallava, el codi de resposta especific de la passarel·la de pagament, la seccio rellevant de la documentacio de codificacio de caracters de la passarel·la, i els tres fitxers involucrats en el pipeline de facturacio. El seu agent va diagnosticar el problema en menys de dos minuts: una cadena UTF-8 estava passant per una funcio que assumia codificacio Latin-1 abans d'arribar a l'API de la passarel·la. L'arreglament eren quatre linies. Es va desplegar aquella tarda.

El model era el mateix. L'agent era el mateix. El bug era el mateix. El que va diferir va ser el que cada enginyer va posar davant de l'agent abans de demanar-li que treballes. Un li va donar una descripcio vaga i el va deixar endevinar. L'altra li va donar tot el que necessitava per _veure_ el problema.

Aquesta diferencia -- el que l'agent pot veure -- es del que tracta aquest capitol.

L'habilitat mes important en enginyeria agentica no es el prompting. Es la gestio del context.

Un agent d'IA nomes es tan bo com el que pot veure. Dona-li una instruccio vaga i un full en blanc, i al·lucinara amb confianca. Dona-li els fitxers correctes, les restriccions correctes, la vista correcta del sistema -- i fara coses que semblen magia. La diferencia no es el model. Ets tu.

L'enginyeria tradicional tambe tenia una versio d'aixo. Un enginyer senior no nomes escrivia millor codi -- tenia mes del sistema al cap. Sabia quins fitxers importaven, on vivien els dracs, quines abstraccions eren estructurals i quines eren decoratives. Aquell model mental era el context, i vivia enterament al cervell de l'enginyer.

Ara l'has d'_externalitzar_. Els teus agents no poden llegir la teva ment. Llegeixen fitxers, variables d'entorn, logs d'errors, i el que sigui que posis davant d'ells. L'ofici de l'enginyeria agentica es aprendre que treure a la superficie, quan i com.

== La Finestra de Context Es el Teu Banc de Treball

Pensa en la finestra de context com un banc de treball fisic. Te espai limitat. No pots bolcar tota la teva base de codi alla i esperar bons resultats. En lloc d'aixo, hi col·loques les peces que importen per a _aquesta_ tasca: els fitxers font rellevants, el test que falla, l'esquema, potser un fragment de documentacio.

Un bon enginyer agentic cura el context de la mateixa manera que un bon cirurgia disposa els instruments. Res innecessari. Tot a l'abast.

Aixo vol dir desenvolupar instints per a preguntes com:
- Que necessita veure l'agent per entendre aquesta tasca?
- Que el confondra si ho incloc?
- El context que estic proporcionant es _actual_, o li estic donant informacio obsoleta?

== L'Impost de la Finestra de Context

Cada token que poses en una finestra de context et costa dues vegades: un cop en diners, un cop en atencio.

La part dels diners es directa. Les crides a l'API es cobren per nombre de tokens. Bolca tota la teva base de codi al context i estas cremant diners a cada interaccio. Pero el cost mes insidios es la degradacio de l'atencio. Els models de llenguatge no tracten tots els tokens per igual -- hi ha un fenomen ben documentat on la informacio al mig d'un context llarg rep menys pes que la informacio al principi o al final. Com mes coses hi fiques, mes probable es que el model es perdi la cosa que realment importa.

Vaig aprendre-ho per les males. Al principi, pensava que mes context sempre era millor. Treballant en una migracio de base de dades complicada, vaig alimentar l'agent amb tots els fitxers de migracio que haviem escrit mai -- tres anys de canvis d'esquema, centenars de fitxers. El meu raonament era solid: l'agent necessitava entendre l'historial complet per escriure la propera migracio correctament. El resultat va ser una migracio que duplicava una columna que ja existia, perque la migracio anterior rellevant estava enterrada al mig d'un context enorme i el model efectivament la va perdre de vista.

Al seguent intent, li vaig donar nomes l'esquema actual, les tres migracions mes recents, i un resum d'un paragraf de l'historial rellevant. L'agent ho va clavar.

Aixo es l'impost de la finestra de context en accio. Hi ha un punt optim entre massa poc i massa, i trobar-lo es una habilitat que es desenvolupa amb la practica.

Massa poc context produeix al·lucinacio. L'agent no te prou informacio, aixi que omple els buits amb invencions que sonen plausibles. Li demanes que arregli una funcio sense mostrar-li el fitxer, i inventa una API que no existeix. Li demanes que escrigui un test sense mostrar-li el teu framework de testing, i tria Jest quan fas servir Vitest.

Massa context produeix confusio i malbaratament. L'agent te la resposta enterrada en algun lloc de la pila, pero no la pot trobar -- o pitjor, troba informacio contradictoria entre diferents fitxers i tria la incorrecta. A mes, estas pagant per cada token de soroll que has inclos.

El punt optim es context _curat_. No tot el que l'agent podria necessitar, sino tot el que realment necessita per a aquesta tasca especifica, presentat clarament. Pensa-ho menys com omplir un arxivador i mes com preparar un col·lega abans d'una reunio. No li donaries tots els documents que l'empresa ha produit mai. Li donaries les tres coses que necessita llegir i un resum d'un minut del context.

Una heuristica practica: si estas a punt d'enganxar alguna cosa al context, pregunta't -- l'agent prendra una decisio diferent (millor) perque ha vist aixo? Si la resposta es no, deixa-ho fora.

== Local, Sandbox, Remot: Movent els Teus Agents

El context no es nomes text en un prompt. Es sobre _on_ opera el teu agent i a que te acces.

=== La Maquina Local

La configuracio mes simple: l'agent s'executa a la teva maquina, llegeix els teus fitxers, executa les teves comandes. Aqui es on la majoria de gent comenca -- eines com Claude Code operant directament al directori del teu projecte.

L'avantatge es la immediatesa. L'agent veu el que tu veus. Pot llegir el teu codi, executar els teus tests, consultar el teu historial de git. El risc tambe es obvi: es la teva maquina, les teves credencials, la teva configuracio de produccio alla asseguda a `~/.env`.

=== Entorns Sandbox

Un enfocament mes disciplinat es donar a l'agent un sandbox -- un contenidor, una VM, un worktree. Obte una copia del codi pero no les teves claus. Pot trencar coses sense trencar _les teves_ coses.

Aixo importa mes del que la majoria de gent creu. Quan deixes un agent iterar lliurement -- executant codi, instal·lant paquets, modificant fitxers -- vols que ho faci en un espai on un error sigui barat. Un agent en sandbox es un agent sense por, i un agent sense por es un agent productiu.

Els worktrees son una eina infravalorada aqui. Els git worktrees et permeten crear una copia aillada del teu repo en segons. L'agent treballa a la seva propia branca, al seu propi directori. Si el resultat es bo, el fusiones. Si no, elimines el worktree i segueixes endavant. Sense embolic.

=== Exploracio Remota

Aqui es on les coses es posen interessants. Un enginyer agentic habil no nomes apunta agents a fitxers locals -- ensenya als agents a _explorar_ sistemes remots.

SSH a un servidor de staging per examinar logs. Consultar una base de dades per entendre la forma de les dades reals. Fer curl a un endpoint d'API per veure el que realment retorna, no el que la documentacio diu que retorna. Baixar logs de contenidors d'un servei en execucio.

L'agent es converteix en el teu explorador. L'apuntes a un sistema i dius: "ves a mirar i explica'm que trobes." Pero has de configurar-ho. L'agent necessita credencials (amb abast i temporals), acces a la xarxa, i limits clars sobre el que te permes de tocar.

Aixo es una decisio de judici -- quant d'acces donar, a quins sistemes, amb quines baranes. Massa poc i l'agent es inutil. Massa i estas a un mal prompt de distancia d'un incident de produccio. L'enginyer agentic apren a calibrar-ho amb el temps.

== Alimentant el Context Deliberadament

Els millors enginyers agentics desenvolupen habits al voltant del context:

*Comenca per l'error.* No descriguis el bug -- mostra a l'agent la traca de la pila, la sortida del test que falla, la linia del log. Context en brut guanya a context parafrasejat cada vegada.

*Mostra, no expliquis.* En lloc d'explicar l'esquema de la teva base de dades en prosa, dona a l'agent els fitxers de migracio o els models de l'ORM. En lloc de descriure el contracte de l'API, dona-li l'especificacio OpenAPI o una resposta de curl.

*Poda agressivament.* Si estas depurant un problema de renderitzat, l'agent no necessita veure el teu middleware d'autenticacio. Cada fitxer irrellevant al context es soroll que degrada el senyal.

*Utilitza el sistema de fitxers com a context.* Un projecte ben organitzat _es_ context. Noms de fitxers amb significat, estructura de directoris clara, un bon README -- ja no son nomes per a humans. Els teus agents tambe els llegeixen.

*Dona camins de fitxers, no recerques del tresor.* Quan saps quins fitxers son rellevants, digues-ho explicitament. "El bug es a `src/payments/gateway.ts`, concretament a la funcio `encodeAddress` a la linia 142" es infinitament millor que "hi ha un bug en algun lloc del codi de pagaments." Cada minut que l'agent passa buscant el fitxer correcte es un minut que no esta dedicant al problema real -- i esta cremant tokens tot el temps.

*Utilitza git blame per explicar _per que_.* El codi diu a l'agent _que_ existeix. L'historial de Git li diu _per que_. Quan demanes a un agent que modifiqui un tros de codi amb un disseny no obvi, apunta'l al missatge de commit o pull request rellevant. "Aquesta funcio sembla estranya pero es va escriure aixi per #1247 -- mira el missatge de commit a `abc123`" dona a l'agent la justificacio que necessita per fer canvis sense trencar la intencio original.

*Copia i enganxa per sobre de parafrasejar.* Aixo val la pena repetir-ho perque es l'error mes comu que veig. Els enginyers descriuen un error amb les seves propies paraules en lloc d'enganxar l'error real. "El build falla amb algun error de TypeScript sobre tipus" versus enganxar la sortida exacta del compilador amb el cami del fitxer, numero de linia i codi d'error. El primer dona a l'agent una direccio vaga. El segon li dona un objectiu especific. Sempre enganxa la sortida en brut. Deixa que l'agent faci la interpretacio.

*Capes el teu context.* Per a tasques complexes, no ho bolquis tot de cop. Comenca amb la imatge general -- que fa el sistema, que vols canviar, per que. Despres proporciona els fitxers especifics. Despres proporciona l'error o el test que falla. Aixo reflecteix com prepararies un col·lega huma, i funciona pel mateix motiu: construeix un model mental abans d'entrar en els detalls.

== Context Entre Sessions

Aqui hi ha un problema del qual ningu t'avisa: les finestres de context son efimeres. Quan una sessio acaba, tot el que l'agent va aprendre -- cada fitxer que va llegir, cada decisio que va prendre, cada cami sense sortida que va explorar -- s'esfuma. La propera sessio comenca de zero.

Per a tasques curtes, aixo no importa. Enganxes l'error, l'agent l'arregla, fet. Pero la feina d'enginyeria real abarca dies, de vegades setmanes. Una funcionalitat que toca dotze fitxers a tres serveis. Una refactoritzacio que ha de passar per etapes. Una sessio de depuracio on les dues primeres hores acoten el problema i els ultims trenta minuts l'arreglen -- excepte que vas haver de tancar el portatil entremig.

Si no planifiques per als limits de sessio, perdras quantitats enormes de temps reestablint context que l'agent ja tenia. He vist enginyers passar els primers quinze minuts de cada sessio re-explicant el que li van dir a l'agent ahir. Aixo no es enginyeria. Aixo es fer de cangur.

La solucio es fer el context _durador_ -- emmagatzemar-lo en algun lloc on la propera sessio el pugui recuperar.

*Deixa que la base de codi sigui la capa de continuitat.* La forma mes fiable de context entre sessions es el propi codi. Si l'agent va fer progres ahir, aquest progres hauria d'estar commitejat. Bons missatges de commit es converteixen en el rastre d'engrunes: "Refactoritzat la passarel·la de pagament per separar el pas de codificacio -- el seguent pas es afegir tests per a entrada no-ASCII." La propera sessio comenca llegint el log de git recent, i l'agent te una imatge clara de com estan les coses.

*Utilitza fitxers CLAUDE.md (o el seu equivalent).* Moltes eines d'agents suporten un fitxer de context a nivell de projecte -- un fitxer markdown a l'arrel del teu repo que descriu l'arquitectura, les convencions i l'estat actual del projecte. Aquest fitxer persisteix entre sessions perque viu al sistema de fitxers. Actualitza'l a mesura que el projecte evoluciona. Inclou coses com: quins son els components principals, quins patrons seguir, que esta trencat actualment, en que esta treballant l'equip. Es un document de briefing que cada sessio nova llegeix automaticament.

*Escriu resums de sessio.* Quan acabis una sessio complexa, dedica seixanta segons a fer que l'agent resumeixi que ha aconseguit, que queda per fer, i que ha apres sobre la base de codi. Desa aquell resum en algun lloc -- un comentari al tiquet, una nota al projecte, fins i tot un fitxer de text al repo. La propera sessio comenca llegint aquell resum, i has preservat hores de comprensio acumulada en uns quants paragrafs.

*Commiteja aviat i sovint.* Aixo es cobreix al capitol de Git, pero val la pena repetir-ho aqui perque es fonamentalment una estrategia de gestio de context. Cada commit es un punt de control que futures sessions poden referenciar. Una sessio que acaba amb canvis sense commitejar es una sessio el context de la qual esta atrapat en una finestra de terminal que potser no existira dema.

Els enginyers que gestionen be el treball agentic de llarga durada son els que tracten els limits de sessio com una preocupacio de primera classe. No nomes tanquen el portatil -- tanquen el cercle.

== El Context com a Arquitectura

Aqui esta la perspectiva mes profunda: a mesura que millores en enginyeria agentica, comences a dissenyar els teus sistemes _per al_ context. Escrius missatges de commit mes clars perque els agents els llegeixen. Mantens les funcions petites perque els agents treballen millor amb fitxers enfocats. Mantens la documentacio actualitzada perque els agents la tracten com a veritat absoluta.

Aixo no es un ajust menor. Canvia com penses sobre l'estructura del codi a tots els nivells.

*Les funcions petites son amigables amb el context.* Una funcio de 400 linies requereix que l'agent mantingui tota la cosa a la memoria de treball per fer un canvi amb seguretat. Una funcio de 30 linies que fa una cosa es alguna cosa que l'agent pot entendre completament, modificar amb confianca i verificar rapidament. El consell antic -- "una funcio ha de fer una cosa" -- sempre va ser bona enginyeria. Ara tambe es bona gestio de context. Cada vegada que extreus una funcio ben nomenada d'una de mes gran, estas creant una unitat de significat amb la qual un agent pot treballar independentment.

*El nom dels fitxers es navegacio.* Quan un agent necessita trobar el codi que gestiona l'autenticacio d'usuaris, comenca mirant els noms dels fitxers. `auth.ts` es un senyal. `utils.ts` es un forat negre. `handleStuff.js` es un carrero sense sortida. La disciplina de nomenar fitxers clarament -- `user-authentication.ts`, `payment-gateway.ts`, `rate-limiter.middleware.ts` -- ja no es nomes una cortesia cap als futurs desenvolupadors. Es un index que els agents utilitzen per trobar el seu cami a traves de la teva base de codi sense llegir cada fitxer.

*L'estructura de directoris es documentacio d'arquitectura.* Un directori pla amb seixanta fitxers no diu res a l'agent sobre com esta organitzat el sistema. Una jerarquia clara -- `src/api/`, `src/services/`, `src/models/`, `src/middleware/` -- li ho diu tot. L'agent pot inferir l'arquitectura nomes de l'estructura de carpetes, sense llegir ni una sola linia de documentacio. He vist agents navegar un monorepo ben estructurat de 10.000 fitxers mes efectivament que un projecte mal estructurat de 200, purament perque el disseny del directori feia el sistema llegible.

*Monorepos vs. multirepos: un equilibri de context.* En un monorepo, l'agent ho pot veure tot -- l'API, el frontend, les biblioteques compartides, la configuracio d'infraestructura. Aixo es potent per a tasques que creuen fronteres. Pero tambe vol dir que l'agent podria veure _massa_, arrossegant codi irrellevant de serveis no relacionats. En una configuracio multirepo, cada repo te un abast natural -- l'agent nomes veu el servei en el que esta treballant. Pero les tasques entre serveis es tornen mes dificils perque l'agent no pot referenciar facilment l'altra banda d'un contracte d'API. Cap enfocament es universalment millor. La questio es que la teva estrategia de repos es una decisio de context, ho pensis aixi o no.

*Els tipus son context.* Una base de codi fortament tipada dona a un agent alguna cosa que una de tipada dinamic no dona: una descripcio llegible per maquina del contracte de cada funcio. L'agent pot mirar la signatura d'una funcio i saber exactament que hi entra i que en surt, sense llegir la implementacio. TypeScript, Rust, Go -- aquests llenguatges porten context estructural als seus sistemes de tipus. Python i JavaScript deixen l'agent endevinant tret que hagis escrit docstrings o type hints exhaustius. Aixo no es un argument a favor d'un llenguatge o un altre. Es una observacio que els sistemes de tipus fan doble feina a l'era agentica: detecten bugs _i_ comuniquen intencio.

*La documentacio es veritat absoluta (sigui precisa o no).* Els agents tracten el teu README, la documentacio de la teva API, els teus comentaris inline com a autoritatius. Si la teva documentacio diu que l'API retorna un camp `user_id` pero la resposta real retorna `userId`, l'agent escriura codi contra la documentacio i produira un bug. La documentacio obsoleta sempre va ser una molestia. Amb agents, es una font activa de defectes. El llistó de precisio de la documentacio puja -- no perque els agents necessitin millor documentacio que els humans, sino perque els agents seguiran la documentacio dolenta mes fidelment que un huma.

La manera com estructures el teu codi, els teus repos, la teva infraestructura -- tot es converteix en part del context que estas proporcionant a la teva tripulacio. Els enginyers que entenguin aixo d'hora construiran sistemes que no nomes son mantenibles per humans, sino _navegables_ per agents. I amb el temps, aquesta navegabilitat es composa -- cada nova sessio d'agent es beneficia de cada decisio estructural que vas prendre abans.
