= El Prompting com a Enginyeria

No hi ha cap sintaxi secreta. Cap encantament magic que faci un agent produir codi perfecte. El prompting es _comunicacio_ -- i tu ja saps com comunicar.

Si alguna vegada has escrit un bon informe de bug, saps com fer prompts. Si alguna vegada has escrit un document de disseny que un company d'equip podria implementar sense fer-te vint preguntes, saps com fer prompts. Si alguna vegada has creat un tiquet de Jira que no va tornar com alguna cosa completament diferent del que volies -- saps com fer prompts.

Les habilitats es transfereixen directament. Claredat, especificitat, context, restriccions. Les mateixes coses que fan la col·laboracio humana eficient fan la col·laboracio amb agents eficient. La diferencia es que els agents no faran preguntes de clarificacio quan el teu prompt es vague. Simplement endevinaran. I endevinaran amb confianca.

Aqui es on molts enginyers experimentats lluiten discretament. Has passat anys construint l'habilitat de _fer_ -- escriure codi, depurar, construir sistemes. Ara l'habilitat que importa es _articular_ -- explicar el que vols amb prou precisio perque algu altre ho pugui fer. Es un muscul diferent. I pot sentir-se, als primers dies, com un descens de categoria. No ho es. Pero la incomoditat es real, i fingir que no existeix no ajuda.

== L'Anatomia d'un Bon Prompt de Tasca

Un bon prompt te tres parts: _que_ vols que es faci, _per que_ importa, i _com_ es l'exit. La majoria de gent nomes proporciona la primera, i fins i tot aixo sol ser vague.

Considera la diferencia:

*Dolent:* "Arregla el bug d'autenticacio."

Aixo no diu quasi res a l'agent. Quin bug d'autenticacio? On es manifesta? Quin es el comportament esperat? L'agent anira a cacar per la teva base de codi, formara una teoria sobre que podries voler dir, i aplicara un arreglament que podria ser completament equivocat. Has convertit un arreglament de cinc minuts en una revisio de vint minuts d'alguna cosa que no has demanat.

*Bo:* "L'endpoint de login retorna 401 per a tokens valids quan la cache de sessions esta freda. El bug es probablement a `middleware/auth.go` a la funcio `validateSession`. El test a `auth_test.go:TestColdCacheLogin` el reprodueix. Arregla el bug i assegura't que tots els tests d'autenticacio existents segueixen passant."

Aixo es un animal completament diferent. L'agent sap el simptoma, la localitzacio sospitada, i com verificar l'arreglament. Pot anar directament al codi rellevant, entendre el problema, i validar la seva solucio -- tot sense endevinar.

El patro es simple. _Que_ esta trencat o es necessita. _On_ mirar. _Com_ verificar. Cada minut que dediques a fer el teu prompt precis t'estalvia cinc minuts revisant la sortida equivocada.

== Especificacio de Restriccions

Dir a un agent que ha de fer es nomes la meitat de la feina. Dir-li que _no_ ha de fer es igualment important.

Els agents son entusiastes. Optimitzen per resoldre el problema que has descrit, i felicment refactoritzaran tot el teu modul, afegiran tres noves dependencies, i canviaran l'API publica per fer-ho. Aixo no es malicia -- es un optimitzador fent el que fan els optimitzadors. La teva feina es establir els limits.

Restriccions utils es veuen aixi:

- "No modifiquis la superficie de l'API publica."
- "Mantin l'estructura de tests existent -- afegeix nous casos de test, no reorganitzis."
- "No afegeixis noves dependencies."
- "Queda't dins dels patrons de gestio d'errors existents en aquesta base de codi."
- "No canviis cap fitxer fora del directori `services/`."

Pensa en les restriccions com les baranes d'un pont. L'agent pot conduir on vulgui dins dels carrils, pero no pot sortir per la vora. Sense baranes, obtens solucions creatives que tecnicament funcionen pero creen malsons de manteniment. Amb elles, obtens solucions que encaixen a la teva base de codi com si sempre hi haguessin estat.

Com mes experiencia adquireixes amb enginyeria agentica, mes els teus prompts es defineixen per les seves restriccions en lloc de per les seves instruccions. Aprens quines llibertats porten a bons resultats i quines porten al caos.

== Descomposicio de Tasques

Un error comu: demanar a un agent que construeixi alguna cosa gran en un sol prompt. "Construeix un dashboard d'usuari amb metriques en temps real, acces basat en rols, i exportacio a CSV." Aixo no es un prompt -- es un projecte. I els projectes necessiten ser descompostos en tasques.

La descomposicio de tasques es la practica de dividir peticions grans en passos petits i _verificables_. Cada pas te una entrada clara, una sortida clara, i una manera clara de comprovar si ha funcionat.

En lloc de "construeix un dashboard d'usuari," escrius:

+ Crea el model de dades per a les metriques del dashboard a `models/dashboard.go` amb l'esquema definit al document de disseny. Escriu tests unitaris per a la validacio del model.
+ Construeix l'endpoint d'API `GET /api/dashboard` que retorni metriques per a l'usuari autenticat. Escriu tests d'integracio.
+ Afegeix filtratge basat en rols perque els usuaris admin vegin totes les metriques i els usuaris normals nomes les seves. Actualitza els tests existents per cobrir ambdos rols.
+ Construeix el component React que mostri les dades del dashboard. Utilitza el component `DataTable` existent per a la graella de metriques.

Cada pas es un prompt autocontingut. Cadascun te un resultat verificable. Cadascun es construeix sobre la sortida verificada del pas anterior. Si el pas dos va malament, ho detectes abans d'haver malbaratat temps al pas tres.

Aixo no es nomes bon prompting -- es bona enginyeria. Estas aplicant les mateixes habilitats de descomposicio que faries servir quan planifiques un sprint o divideixes un pull request. La unitat de treball es prou petita per revisar, prou petita per testejar, i prou petita per llencar si esta malament.

== El Prompt com a Especificacio

Els millors prompts que he vist es llegeixen com a documents de disseny en miniatura. Descriuen el resultat desitjat, no els passos d'implementacio. Llisten les restriccions. Defineixen criteris d'acceptacio. Proporcionen just prou context perque l'agent prengui bones decisions sense ofegar-lo en informacio irrellevant.

Aqui tens com es veu un prompt-com-a-especificacio:

_"Afegeix limitacio de velocitat a l'endpoint `/api/search`. Utilitza el middleware `RateLimiter` existent a `middleware/ratelimit.go`. Configura el limit a 100 peticions per minut per usuari autenticat, i 20 per minut per a peticions no autenticades. Retorna un estat 429 amb una capsalera `Retry-After` quan el limit es superi. Afegeix tests per als camins autenticat i no autenticat, incloent el cas limit on un usuari arriba exactament al limit. No modifiquis el propi middleware de limitacio de velocitat -- nomes configura'l i aplica'l."_

Aixo es una especificacio. Un agent pot implementar-ho sense ambiguitat. Un revisor huma pot comprovar el resultat contra els requisits. El resultat desitjat es clar, les restriccions son explicites, i els criteris de verificacio estan definits.

Escriure prompts d'aquesta manera requereix practica. Tambe requereix disciplina -- la disciplina de pensar en el que realment vols abans de comencar a teclejar. Pero aquella disciplina dona dividends. Un prompt ben especificat produeix un resultat que pots fusionar. Un prompt vague produeix un resultat que has de reescriure.

== Iteracio per Sobre de Perfeccio

El teu primer prompt no sera perfecte. Esta be. El prompting es un proces iteratiu, i l'habilitat no es escriure el prompt perfecte -- es _llegir la sortida_, entendre on la comunicacio ha fallat, i refinar.

Quan un agent produeix alguna cosa incorrecta, resisteix l'impuls de culpar l'eina. En lloc d'aixo, pregunta't: que he fallat en comunicar? He deixat fora alguna restriccio? El context era insuficient? He assumit coneixement que l'agent no tenia?

Aixo es depuracio -- pero en lloc de depurar codi, estas depurant la teva propia comunicacio. El missatge d'error es la sortida de l'agent. La traca de pila es el teu prompt. En algun lloc alla hi ha la mala comunicacio, i trobar-la fa el teu proper prompt millor.

Els enginyers agentics experimentats desenvolupen un instint de retroalimentacio. Veuen la sortida de l'agent i immediatament saben quina part del seu prompt va causar la desviacio. "Ah, vaig dir 'gestiona errors' pero no vaig especificar _quins_ errors ni _com_ gestionar-los. Es clar que ha posat un catch-all generic."

Cada iteracio ajusta el bucle. El primer prompt t'arriba al 70%. Una correccio de seguiment t'arriba al 90%. Un refinament final t'arriba al final. Amb el temps, els teus primers prompts milloren, i necessites menys iteracions. Pero mai no necessites zero.

== Desenvolupament Guiat per Veu

La majoria de nosaltres fem prompts teclejant. Aixo te sentit -- som enginyers, vivim en text. Pero hi ha un altre canal d'entrada que es mes rapid, mes natural, i sorprenentment infrautilitzat: la teva veu.

La conversio de veu a text moderna ha arribat al punt on pots parlar un prompt al teu terminal i tenir-lo transcrit amb precisio gairebe perfecta. Eines com Whisper, la dictacio de macOS, i SuperWhisper et permeten parlar amb el teu agent en lloc de teclejar. El resultat es el mateix -- entra text, surt codi. Pero l'experiencia es fonamentalment diferent.

Aqui tens per que: teclejar i parlar son modes de pensar diferents. Quan tecleges, edites sobre la marxa. Esborres una paraula, reformules, esborres, reestructures. El text que produeixes esta _polit_ -- has tingut temps de suavitzar les asprors abans que sortis dels teus dits. Parlar no et dona aquell luxe. Quan parles, et compromets. Les paraules surten de la teva boca i ja estan. No hi ha tecla d'esborrar.

Aixo sona com un desavantatge. En realitat es un camp d'entrenament.

Quan parles un prompt, ets forcat a organitzar els teus pensaments _abans_ d'obrir la boca. No pots confiar en la crossa d'editar a mitja frase. Has de saber que vols, estructurar-ho mentalment, i lliurar-ho clarament -- en temps real. Les primeres vegades que ho provis, divagares. Diras "eh" i "mm" i tornares enrere i et contradiras. L'agent rebra un transcrit desordenat, i la sortida reflectira aquell desordre.

Pero passa alguna cosa si continues fent-ho. Millores. No nomes en prompting -- en _parlar clarament sobre problemes tecnics_. Desenvolupes la capacitat de descriure un bug, una funcionalitat, o una tasca de refactoritzacio en un unic flux coherent. Aprens a posar el context al davant, establir restriccions aviat, i acabar amb una peticio clara. Deixes de divagar perque divagar produeix mals resultats.

Aquesta habilitat es transfereix a tot arreu. Reunions d'standup. Discussions d'arquitectura. Programacio en parella. Trucades d'incidents. Cada situacio on necessites articular una idea tecnica clarament, sota pressio de temps, sense la xarxa de seguretat d'un editor de text. El desenvolupament guiat per veu no es nomes una manera mes rapida de fer prompts -- es practica per a cada conversa tecnica que mai tindras.

Tambe hi ha un avantatge practic de velocitat. La majoria de gent parla a 130 paraules per minut. La majoria de gent tecleja a 40-80. Per al tipus de prompts d'alt nivell i basats en intencio que produeixen la millor sortida d'agents -- "aqui esta el problema, aqui esta el context, aqui esta el que vull, aqui esta el que no vull" -- parlar es simplement mes rapid. Dediques menys temps a l'entrada i mes temps revisant la sortida.

Prova-ho durant una setmana. Tria una eina de veu a text, connecta-la al teu flux de treball, i parla els teus prompts en lloc de teclejar-los. El primer dia se sentira incomode. Al tercer dia, notaras que els teus prompts parlats es tornen mes ajustats. Al final de la setmana, notaras que la teva _comunicacio parlada en general_ s'esta tornant mes ajustada.

Tambe val la pena destacar que els models de veu a text poden executar-se enterament a la teva maquina. La familia de models Parakeet de NVIDIA -- models ASR compactes i d'alta precisio -- s'executen localment sense cap dependencia del cloud. Eines com SuperWhisper i whisper.cpp fan el mateix utilitzant els pesos de Whisper d'OpenAI. Un MacBook modern pot executar aquests models gairebe en temps real amb transcripcio precisa i baixa latencia. No necessites un servei al cloud per convertir veu en text -- les eines locals ja hi son.

Als agents els es igual si el teu prompt va ser teclejat o parlat. Pero _tu_ seras un pensador mes clar per haver-lo parlat.

== Context Visual: Quan les Paraules No Son Prou

No tot es facil de descriure en text. Un layout trencat, un error de renderitzat estrany, un dialog d'error amb una traca de pila -- de vegades la manera mes rapida de comunicar el que estas veient es _mostrar-ho_.

Els LLMs moderns son multimodals. Poden llegir captures de pantalla, diagrames, fotos de pissarres, i missatges d'error capturats de la teva pantalla. Aixo no es una funcio de novetat -- es una de les eines mes infrautilitzades del flux de treball d'enginyeria agentica.

Aqui tens un flux de treball que faig servir diariament: veig un bug al meu telefon -- un layout que esta trencat, un modal que esta descentrat, un formulari que s'empassi l'entrada. Faig una captura de pantalla a iOS, i gracies a Universal Clipboard, l'enganxo directament a la meva sessio de terminal al Mac. L'agent veu el que jo veig. No cal descriure "el boto se superposa amb la capsalera al viewport mobil" -- la captura de pantalla _es_ la descripcio.

Aixo importa perque els bugs visuals son notoriament dificils de descriure en text. Acabes escrivint tres paragrafs sobre padding i z-index quan una sola captura de pantalla comunica el problema instantaniament. L'agent pot veure l'estat trencat, raonar sobre que esta malament, i proposar un arreglament -- sovint mes rapid del que podries acabar de teclejar la descripcio.

Pero va mes enlla dels informes de bugs. Alguns fluxos de treball comuns de context visual:

- *Captures de pantalla d'errors.* Una consola de navegador plena de vermell, una traca de pila al terminal, un dashboard de desplegament mostrant health checks fallats. Captura-ho, enganxa-ho, demana a l'agent que diagnostiqui. Aixo es especialment util quan els missatges d'error son llargs o contenen formatat que es penosa de copiar com a text.
- *References de disseny.* Un mockup de Figma, un esbos, la interficie d'un competidor que vols aproximar. Enganxa la imatge i digues "fes que la nostra pagina de configuracio s'assembli a aixo." L'agent pot extreure estructura de layout, eleccions de color, i jerarquia de components d'una referencia visual.
- *Depuracio d'estat visual.* "Per que es veu malament aquesta pagina?" es un prompt terrible. Una captura de pantalla de la pagina _mes_ "per que es veu malament aquesta pagina?" es un de genial. L'agent pot comparar el que veu amb el layout esperat i identificar problemes de CSS, dades que falten, o bugs de renderitzat.
- *Fotos de pissarres.* Despres d'una discussio d'arquitectura, fes una foto de la pissarra i enganxa-la. L'agent pot llegir les caixes, fletxes i etiquetes, i ajudar-te a traduir aquell esbos en estructura de codi, definicions d'API, o documentacio.

El pipeline de portaretalls d'iOS-a-Mac mereix mencio especial perque elimina tota la friccio d'aquest flux de treball. No necessites desar la captura de pantalla, fer AirDrop, trobar-la al Finder i arrossegar-la a una eina. Veus el problema, el captures, l'enganxes. Tres segons de "aixo esta trencat" a "l'agent ho esta mirant." Aquella velocitat importa perque et mante en el flux. Qualsevol pas extra -- fins i tot trenta segons de gestio de fitxers -- crea prou friccio perque per defecte tornis a teclejar una descripcio en text, que es mes lenta i menys precisa.

La perspectiva clau es que _el context no es nomes text_. Quan parlaven de que el context es l'ingredient mes important del treball agentic, parlavem de totes les formes de context -- fitxers de codi, documentacio, sortida de tests, _i_ estat visual. Una captura de pantalla val mil tokens, i els agents que poden veure son dramaticament mes utils que els agents que nomes poden llegir.

Si no estas fent servir context visual al teu flux de treball agentic, comenca. Captura els teus bugs. Enganxa els teus missatges d'error. Comparteix les teves references de disseny. Els agents ara poden veure. Deixa'ls.

== Anti-patrons

Alguns habits de prompting produeixen consistentment mals resultats. Apren a reconeixer-los.

*Ser massa vague.* "Fes aquest codi millor." Millor com? Mes rapid? Mes llegible? Mes mantenible? L'agent triara _alguna cosa_ per millorar, i probablement no sera la que tenies al cap. Si no pots articular que vol dir "millor," no estas preparat per fer prompts.

*Ser massa prescriptiu.* L'error oposat. "A la linia 47, canvia el nom de la variable de `x` a `count`, despres afegeix un if a la linia 48 que comprovi si count es mes gran que zero, despres..." Estas escrivint el codi en catala i demanant a l'agent que el tradueixi. Aixo es mes lent que escriure el codi tu mateix. Descriu el _resultat_, no les pulsacions de tecles.

*Bolcat de context.* Enganxar tota la teva base de codi, tots els teus documents de disseny, i una transcripcio de les teves tres ultimes reunions d'equip al prompt. Mes context no sempre es millor. Context irrellevant es soroll, i el soroll ofega el senyal. Dona a l'agent el que necessita -- camins de fitxers, noms de funcions, el comportament especific que vols -- i confia que explorara a partir d'alla.

*Prompts de tot inclòs.* "Arregla el bug d'autenticacio, tambe refactoritza la capa de base de dades, i ja que hi ets actualitza el README i afegeix tipus TypeScript al client de l'API." Aquestes son quatre tasques separades ficades en un prompt. L'agent intentara totes, no fara cap be, i produira un diff tan gran que revisar-lo trigara mes que fer la feina tu mateix. Un prompt, una tasca.

*Assumir context compartit.* "Fes-ho de la mateixa manera que vam fer el modul de pagaments." L'agent no recorda la teva ultima sessio. No sap que va decidir "nosaltres" a l'standup. Cada prompt comenca de zero. Proporciona el context explicitament, cada vegada.

== El Prompting Es una Habilitat

El prompting no es un truc de saló. No es tracta de descobrir la frase rara que desbloqueja millor sortida. Es una habilitat de comunicacio -- i com totes les habilitats de comunicacio, millora amb la practica, la retroalimentacio i l'atencio deliberada.

Els enginyers que treuen mes profit de les eines agentiques son els que tracten el prompting amb el mateix rigor que apliquen a escriure codi. Pensen abans de teclejar. Especifiquen abans d'implementar. Verifiquen abans de continuar.

Aixo no es una habilitat nova. Aixo es simplement enginyeria.
