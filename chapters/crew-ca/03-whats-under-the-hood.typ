= Que hi ha sota el capó

#figure(
  image("../../assets/illustrations/crew/ch03-under-the-hood.jpg", width: 80%),
  caption: [_Cada aplicació és un restaurant — menjador, cuina i rebost._],
)

Un amic et diu que està construint una app. "És un backend amb Django, un frontend amb React, Postgres per a la base de dades i Redis per a la cache." Tu assents. Somrius. No tens absolutament ni idea del que vol dir res d'això.

Aquest capítol ho soluciona.

No et convertirem en enginyer. Et donarem el model mental — el mapa del territori — perquè quan sentis aquestes paraules, sàpigues de quina part de la màquina estan parlant. I, el que és més important, quan dirigeixis un agent perquè construeixi alguna cosa, entendràs què està construint realment.

Farem servir un exemple al llarg de tot el capítol: una eina de gestió de projectes, com una versió simplificada de Trello. Un tauler amb columnes, targetes que pots arrossegar i persones assignades a tasques. Prou senzill per entendre'l, prou complex per ser real.

== El restaurant

Cada aplicació web està construïda a partir d'uns quants blocs bàsics. Diferents apps utilitzen eines específiques diferents, però la _forma_ sempre és la mateixa. La manera més fàcil d'entendre-ho és pensar en un restaurant.

Un restaurant té un menjador — la part que veuen els clients. Té una cuina — la part que fa la feina de debò. Té un rebost — on es guarden els ingredients. I té una zona de preparació — on es mantenen a mà els ingredients més usats perquè el cuiner no hagi d'anar al rebost cada trenta segons.

Una aplicació web té les mateixes quatre parts. Simplement tenen noms diferents.

== React — El menjador

*Què és:* React és un _framework de frontend_. És la part de l'aplicació que s'executa al teu navegador web — tot el que veus, toques i amb què interactues.

*Al nostre clon de Trello:* El tauler amb les seves columnes. Les targetes que pots arrossegar de "Pendent" a "En curs". El botó que diu "Afegir tasca". El petit avatar que mostra qui està assignat. El menú desplegable quan cliques els tres punts. Tot això és React.

*Per què importa:* React no emmagatzema cap dada. No pren decisions sobre regles de negoci. És el menjador — bellament disposat, responent a cada interacció teva, però no cuina el menjar. Quan arrossegues una targeta a una nova columna, React fa que la targeta es mogui _immediatament_ a la teva pantalla. Però entre bastidors, està enviant un missatge a la cuina dient "el client vol moure aquesta targeta". Si la cuina diu que no — potser no tens permís — React torna a posar la targeta al seu lloc.

*Què sentiràs dir:* "És una app de React" vol dir que la part amb què interactues està construïda amb aquesta eina. Hi ha alternatives — Vue, Svelte, Angular — però totes fan aproximadament la mateixa feina. React és la més comuna, com la majoria de restaurants tenen un menjador independentment de quines cadires hagin triat.

== Django — La cuina

*Què és:* Django és un _framework de backend_. És el cervell de l'aplicació — la part que s'executa en un servidor, fa complir les regles, processa les peticions i decideix què passa.

*Al nostre clon de Trello:* Quan cliques "Afegir tasca" i escrius "Comprar queviures", React envia aquesta petició a Django. Django comprova: Estàs connectat? Pertanys a aquest projecte? El títol de la tasca és vàlid? El projecte encara és actiu? Si tot és correcte, Django diu a la base de dades que emmagatzemi la nova tasca i envia una confirmació a React.

*Per què importa:* Django és on viu la _lògica_. Les regles de preus. El sistema de permisos. La lògica de negoci que diu "només els administradors del projecte poden eliminar taulers". És la cuina — no li importa quin aspecte té el menjador, i al menjador no li importa quina marca de forn utilitza la cuina. Es comuniquen mitjançant una nota de comanda estandarditzada, de la qual parlarem en un moment.

*Què sentiràs dir:* "El backend retorna un error" vol dir que Django (la cuina) s'està ofegant amb una petició. "Hem d'afegir aquesta lògica al backend" vol dir que la regla ha de viure a Django, no a React. Hi ha alternatives — Rails (Ruby), Express (JavaScript), Laravel (PHP), FastAPI (Python, com Django) — però el concepte és idèntic. Una cuina és una cuina.

== Postgres — El rebost

*Què és:* Postgres (abreviatura de PostgreSQL) és una _base de dades_. És on viuen totes les dades — cada compte d'usuari, cada projecte, cada tasca, cada comentari, cada marca de temps.

*Al nostre clon de Trello:* Quan Django emmagatzema aquella nova tasca, va a parar a Postgres. Imagina't un arxivador enorme i meticulosament organitzat. Hi ha un calaix etiquetat "Tasques", i dins seu, cada tasca és una fila:

#table(
  columns: (auto, auto, auto, auto, auto),
  [*ID*], [*Títol*], [*Projecte*], [*Estat*], [*Creat*],
  [247], [Arreglar la barra de navegació], [Projecte #3], [Fet], [12 de març],
  [248], [Comprar queviures], [Projecte #3], [Pendent], [18 de març],
  [249], [Trucar al client], [Projecte #5], [En curs], [18 de març],
)

Quan carregues el teu tauler, Django demana a Postgres: "Dóna'm totes les tasques del Projecte #3, ordenades per estat." Postgres les troba i les retorna. Django les passa a React. React dibuixa el tauler. Tot el viatge dura uns 200 mil·lisegons — menys temps que un parpelleig.

*Per què importa:* La base de dades és l'única part del sistema que _recorda_ les coses. Si el servidor es reinicia, Django arrenca de nou des de zero — però totes les dades estan segures a Postgres, exactament on es van deixar. Si perds la base de dades, ho has perdut tot. Per això les còpies de seguretat importen.

*Què sentiràs dir:* "Està a la base de dades" vol dir que la informació està emmagatzemada permanentment. "Hem de consultar la base de dades" vol dir que hem de demanar a Postgres dades específiques. "La base de dades va lenta" vol dir que Postgres triga massa a trobar les coses — normalment perquè l'arxivador s'ha fet enorme i ningú ha construït un índex (pensa en un índex com les pestanyes als calaixos que et deixen saltar directament a la secció correcta).

== Redis — La zona de preparació

*Què és:* Redis és una _cache en memòria_. Manté les dades consultades freqüentment en un emmagatzematge ràpid i temporal perquè l'aplicació no hagi de consultar la base de dades per cada petició.

*Al nostre clon de Trello:* Alguna informació es demana constantment. "Quantes notificacions no llegides té aquest usuari?" "Quantes tasques hi ha al Projecte #3?" En lloc de fer que Postgres remeni l'arxivador cada vegada que algú carrega la pàgina, Django emmagatzema la resposta a Redis.

Redis manté tot en memòria — pensa-hi com una pissarra muntada a la paret de la cuina. Necessites el recompte de notificacions? Mira la pissarra. Instantani. Quan el recompte canvia (algú t'assigna una nova tasca), Django actualitza la pissarra. Si la pissarra s'esborra — un reinici del servidor, per exemple — no passa res. Django recalcula els números des de Postgres i els torna a escriure a la pissarra.

*Per què importa:* Velocitat. Postgres és fiable però relativament lent — emmagatzema dades en disc, cosa que implica lectura i escriptura físiques. Redis emmagatzema tot en RAM, que és ordres de magnitud més ràpid. Per a dades que canvien rarament però es llegeixen constantment, això és la diferència entre una app àgil i una que es nota feixuga.

*Què sentiràs dir:* "Està a la cache de Redis" vol dir que les dades s'estan servint des de la pissarra en lloc de l'arxivador. "La cache està obsoleta" vol dir que la pissarra no s'ha actualitzat i mostra números antics. "Esborra la cache" vol dir esborrar la pissarra i deixar que es reconstrueixi des de la base de dades.

== Com es comuniquen — La vida d'un clic

Aquestes quatre peces no són un gran programa. Són quatre programes separats que es comuniquen enviant-se missatges entre ells. Això és el que passa quan cliques "Afegir tasca" i escrius "Comprar queviures":

+ *React (el teu navegador):* Cliques el botó, escrius el text, prems enter. React envia un missatge a Django: "Nova tasca: Comprar queviures, al projecte \#3, de l'usuari \#42."

+ *Django (el backend):* Rep el missatge. Comprova — l'usuari \#42 està connectat? L'usuari \#42 pertany al projecte \#3? El títol no és buit i té menys de 500 caràcters? Tot correcte. Diu a Postgres que l'emmagatzemi.

+ *Postgres (la base de dades):* Crea una nova fila: Tasca \#248, "Comprar queviures", Projecte \#3, creada ara, estat "Pendent". Diu a Django: "Fet, aquí tens la nova tasca amb el seu ID."

+ *Django diu a Redis:* "Incrementa el recompte de tasques del projecte \#3 de 47 a 48." Redis actualitza la seva pissarra.

+ *Django diu a React:* "Aquí tens la nova tasca. S'ha desat. Tasca \#248." React afegeix la targeta al teu tauler.

Tot això passa en uns 200 mil·lisegons. Menys temps del que trigues a parpellejar.

Si alguna cosa falla — posem que Postgres està caigut — Django envia un error a React, i React et mostra un missatge amable: "Alguna cosa ha anat malament, si us plau torna-ho a provar." La cuina s'ha incendiat, però el cambrer no llança fum al menjador. Dóna la mala notícia educadament.

== L'API — La nota de comanda

Els missatges entre React i Django segueixen un format específic. Pensa-hi com una nota de comanda estandarditzada al restaurant — el cambrer escriu les comandes en un format que la cuina pot llegir, i la cuina envia el menjar en plats que el cambrer pot portar.

Aquest format s'anomena *API* — Application Programming Interface. És un contracte. React sap exactament com preguntar, Django sap exactament com respondre. Si React envia una petició que no coincideix amb el contracte — com demanar un plat que no és al menú — Django retorna un error.

Sentiràs la gent dir coses com "l'API retorna un 500". Aquest número és un codi d'estat — una abreviatura del que ha passat:

- *200* — Tot bé. Aquí tens el teu menjar.
- *401* — No estàs connectat. Qui ets?
- *403* — Estàs connectat, però no tens permís.
- *404* — Això no existeix. (Aquest el coneixes — "404 Not Found.")
- *500* — Alguna cosa ha explotat a la cuina. És culpa nostra, no teva.

Quan el teu amic desenvolupador diu "l'API està caiguda", vol dir que el canal de comunicació entre el frontend i el backend ha deixat de funcionar. El menjador està bé. La cuina està bé. Però la porta entre ells s'ha encallat.

== Autenticació — La polsera

Com sap Django que ets _tu_ qui fa la petició?

Quan inicies sessió — escrius el teu correu i contrasenya, o cliques "Inicia sessió amb Google" — Django verifica la teva identitat i dóna al teu navegador un *token*. Pensa-hi com una polsera en un festival. Durant la resta de la sessió, cada missatge que React envia a Django inclou aquesta polsera. Django hi fa un cop d'ull i diu: "Sí, aquest és l'usuari \#42, té permís per ser aquí."

Si la polsera caduca (la majoria de tokens duren unes hores o dies), et retornen a la pantalla d'inici de sessió. Si algú et roba la polsera — és una bretxa de seguretat. Per això "tanca la sessió en ordinadors compartits" no és només un suggeriment.

Quan el teu desenvolupador diu "l'auth està trencada", vol dir que aquest sistema de polseres té un problema. Potser els tokens no s'estan emetent. Potser caduquen massa ràpid. Potser no s'estan comprovant correctament, cosa que és molt més preocupant — vol dir que el vigilant no fa la seva feina.

== WebSockets — El walkie-talkie

La majoria de la comunicació web funciona com enviar cartes. React envia una petició, espera, i Django envia una resposta. S'anomena petició-resposta, i és com funciona la major part d'internet.

Però què passa amb les funcions en temps real? Quan un company d'equip afegeix una targeta al tauler, vols veure-ho _immediatament_ — no la pròxima vegada que refresquis la pàgina. Aquí és on entren els *WebSockets*.

Un WebSocket és com un walkie-talkie. En lloc d'enviar cartes d'anada i tornada, React i Django obren una _connexió persistent_ — una línia que es manté oberta. En el moment que alguna cosa canvia al servidor, Django ho emet a tothom que està escoltant. El teu tauler s'actualitza en temps real. Veus el cursor movent-se mentre el teu company arrossega una targeta.

Així és com funcionen les apps de xat. Per això pots veure "La Sara està escrivint..." en temps real. És un WebSocket — una línia oberta entre el teu navegador i el servidor, escoltant constantment.

== Git — El botó de desfer per a tot

#figure(
  image("../../assets/illustrations/crew/ch03-git-branches.jpg", width: 80%),
  caption: [_Cada experiment té la seva còpia segura._],
)

Abans d'aprofundir més en la infraestructura, has de conèixer Git. No perquè l'utilitzaràs directament cada dia — sinó perquè és la raó principal per la qual pots deixar que els agents treballin en el teu codi sense perdre la son.

Imagina que estàs escrivint un document llarg a Google Docs. Coneixes aquella funció d'"Historial de versions"? On pots veure cada canvi que ha fet qualsevol persona, i restaurar qualsevol versió anterior? Git és això — però molt, molt més potent. És com pràcticament tot el programari del món es construeix.

=== Els conceptes bàsics

*Repositori (repo):* Una carpeta de projecte que ho recorda tot. Cada fitxer, cada canvi, cada versió — tot des del primer dia. El teu clon de Trello viu en un repo.

*Commit:* Una instantània. Com guardar la partida. "Aquí tens com era tot a les 3 de la tarda de dimarts." Cada commit té un missatge curt descrivint què ha canviat: "Afegida calculadora de preus" o "Arreglada la transparència del vidre." Pots tornar a qualsevol instantània, en qualsevol moment.

*Branch:* Un univers paral·lel. Dius: "Vull provar d'afegir una previsualització 3D, però no estic segur que funcionarà." Crees un branch — una còpia del teu projecte on pots experimentar lliurement. Si funciona, el fusiones de nou al projecte principal. Si no, elimines el branch. L'original no s'ha tocat.

Pensa-hi com dibuixar sobre paper de calc posat sobre el teu plànol. Experimenta tot el que vulguis. El plànol de sota no canvia fins que decideixis fer-ho permanent.

*Merge:* Agafar el paper de calc i premsar-lo sobre el plànol. L'experiment ha funcionat, així que incorpores aquests canvis al projecte principal.

*Pull Request (PR):* Abans de fer el merge, pots demanar a algú que revisi el teu paper de calc. "Ei, mira el que he canviat — et sembla bé?" Aquest pas de revisió és un pull request. És on els companys d'equip — o tu, revisant la feina d'un agent — examinen els canvis abans que es facin oficials.

*GitHub:* El lloc on els repos viuen en línia. Pensa-hi com Google Drive per a codi. El teu repo s'emmagatzema allà, amb còpia de seguretat i compartible. També és on passen els pull requests i les revisions de codi.

=== Per què Git importa per treballar amb agents

Aquí tens per què això és tan important. Quan dius a un agent "afegeix una previsualització 3D amb Three.js", l'agent pot canviar quinze fitxers. Potser funciona meravellosament. Potser ho trenca tot. Sense Git, estaries atrapat — Ctrl+Z no funciona a través de quinze fitxers.

Amb Git, dius a l'agent: treballa en un branch. Ara tots els seus canvis estan continguts en aquell univers paral·lel. Ho proves. Si la previsualització 3D queda genial — merge. Si l'agent s'ha descontrolat i ha reescrit tota la lògica de preus sense motiu — elimina el branch. Cinc segons. Cap dany.

El flux és així:

```
main (la teva app estable)
  |
  |-- branch: "add-3d-preview"
  |     |-- L'agent fa canvis (commit: "Add Three.js scene")
  |     |-- L'agent arregla un bug  (commit: "Fix camera angle")
  |     |-- Ho revises -- queda bé!
  |     +-- Merge de tornada a main
  |
  |-- main ara té la previsualització 3D
  |
  |-- branch: "pdf-generation"
  |     |-- L'agent prova alguna cosa (commit: "Add PDF export")
  |     |-- És un desastre -- els PDFs surten en blanc
  |     +-- Elimina el branch. Main no s'ha tocat.
  |
  +-- main segueix segur. Torna-ho a provar.
```

Cada experiment és segur. Cada error és reversible. Aquell diagrama de branches és la teva xarxa de seguretat, dibuixada. Els enginyers viuen en aquest flux cada dia. Ara entens per què.

*Git vol dir que sempre pots tornar enrere. Això vol dir que pots ser audaç.*

== DNS — La guia telefònica d'internet

#figure(
  image("../../assets/illustrations/crew/ch03-dns-phonebook.jpg", width: 80%),
  caption: [_La guia telefònica d'internet connecta noms amb números._],
)

Escrius `trello.com` al teu navegador. Però els ordinadors no entenen noms — entenen números. En algun lloc, hi ha un sistema de cerca gegant que tradueix `trello.com` a `104.192.141.1` — l'adreça real del servidor on viu Trello.

Aquest sistema és el *DNS* — el Domain Name System. Funciona exactament com els contactes del teu telèfon. Toques "Mare", el teu telèfon sap que vol dir +45 12 34 56 78. Mai penses en el número. Però sense ell, la trucada no connecta.

Quan el teu amic desenvolupador diu "el DNS encara no s'ha propagat", vol dir: hem canviat el número de telèfon, però no tothom té la guia actualitzada. Els canvis de DNS poden trigar de minuts a hores a estendre's per internet. Per això, després de llançar un lloc web nou, algunes persones el poden veure i altres no — la seva guia encara mostra l'adreça antiga.

Cada lloc web que has visitat mai ha començat amb una consulta DNS. Simplement no t'hi has fixat, perquè triga uns 20 mil·lisegons.

== VPS — El pis on viu la teva app

El teu backend Django, la teva base de dades Postgres, la teva cache Redis — necessiten un ordinador on funcionar. No el teu portàtil. Un ordinador que està encès les 24 hores del dia, 7 dies a la setmana, connectat a internet, en un edifici amb energia de reserva i un aire condicionat de debò.

Un *VPS* — Virtual Private Server — és llogar una porció d'un d'aquests ordinadors. No tens tota la màquina. Tens una secció aïllada, amb el teu propi sistema operatiu, el teu propi emmagatzematge, la teva pròpia memòria. Com llogar un pis en lloc de comprar una casa — l'edifici és compartit, però el teu pis és teu.

Noms habituals que sentiràs: *DigitalOcean*, *Hetzner*, *Linode*, *AWS*, *Google Cloud*. Els tres primers són com llogar un pis senzill — aquí tens el teu servidor, aquí tens la clau, bona sort. AWS i Google Cloud són més com ciutats senceres — milers de serveis, aclaparador si només necessites on executar la teva app, però potents si necessites escalar a milions d'usuaris.

Quan algú diu "el servidor està caigut", vol dir que aquest ordinador — el VPS — ha deixat de respondre. Quan diuen "hem d'escalar", vol dir que el pis és massa petit i necessiten un de més gran, o diversos.

React és una mica diferent dels altres: es descarrega al _teu_ navegador i s'executa al _teu_ ordinador. Django, Postgres i Redis viuen tots al servidor. React és l'única part que viatja fins al client.

== Migracions — Remodelar la base de dades

Què passa quan vols afegir un camp "data de venciment" a les tasques? No pots simplement afegir una columna nova a l'arxivador. Postgres necessita una instrucció formal: "Afegeix una nova columna anomenada `due_date` al calaix de tasques."

Aquesta instrucció s'anomena una *migració*. Django la genera automàticament quan canvies el teu model de dades, i remodela la base de dades sense perdre cap dada existent. Cada fila del calaix de Tasques rep un nou espai buit per a "data de venciment", i a partir d'ara, les noves tasques poden incloure una data de venciment.

Les migracions també poden eliminar columnes, reanomenar-les o canviar-ne el tipus. S'apliquen en ordre, com un registre de canvis — migració 001, 002, 003. Pots veure l'historial complet de com la teva base de dades va evolucionar d'una sola taula a cent.

Quan el teu desenvolupador diu "hem d'escriure una migració per a això", vol dir que l'estructura de la base de dades ha de canviar per suportar una nova funcionalitat. Sona intimidant, però és rutinari — la majoria d'apps executen dotzenes o centenars de migracions al llarg de la seva vida.

== CI — La llista de comprovació automatitzada

Un desenvolupador acaba un canvi. Potser ha arreglat un bug. Potser ha afegit una nova funcionalitat. I ara què? No pot simplement enganxar-ho al servidor en producció i esperar que tot vagi bé. (Pot fer-ho. Els enginyers tenen un dit: mai facis deploy un divendres.)

*CI* — Continuous Integration — és una llista de comprovació automatitzada que s'executa cada vegada que algú proposa un canvi. Pensa-hi com un control de qualitat a la fàbrica abans que el producte surti de l'edifici:

+ *El codi s'executa sense errors?* De vegades un canvi trenca alguna cosa òbvia — una errada tipogràfica, un fitxer que falta, una versió incompatible.

+ *Passen tots els tests?* L'app té centenars de tests automatitzats — petits scripts que verifiquen coses com "inicia sessió com a usuari, crea una tasca, marca-la com a feta, verifica que apareix a la columna de Fets." Si algun d'aquests escenaris falla, CI ho detecta.

+ *Segueix les regles d'estil de l'equip?* Format consistent, convencions de noms, sense codi de depuració oblidat.

+ *Introdueix problemes de seguretat?* Vulnerabilitats conegudes en dependències, credencials exposades, patrons insegurs.

Si alguna cosa falla, el canvi es rebutja amb una marca vermella i un missatge explicant què s'ha trencat. El desenvolupador ho arregla i ho torna a intentar.

Si tot passa — marca verda. Ara un company revisa el canvi en un pull request, i si l'aprova, CI pot automàticament *desplegar-lo* — pujar la nova versió al VPS. La pròxima vegada que algú carregui l'app, obtindrà la versió actualitzada.

Tot el procés dura minuts, s'executa sense que cap humà hi toqui, i detecta problemes que els humans passen per alt. És la raó per la qual les apps s'actualitzen constantment sense que te n'adonis — entre bastidors, els canvis flueixen per aquest pipeline dotzenes de vegades al dia.

Eines habituals de les quals sentiràs parlar: *GitHub Actions*, *GitLab CI*, *Jenkins*. Totes fan aproximadament el mateix — executar la llista de comprovació, informar del resultat.

== Mantenir el pols

No necessites escriure codi per estar al dia del que passa al món del programari. Les millors persones no tècniques amb qui he treballat tenen una cosa en comú: saben què hi ha per allà fora. Llegeixen sobre una nova eina a Hacker News tres setmanes abans que l'equip d'enginyeria la mencioni. Descobreixen un projecte de codi obert en tendència a GitHub que resol exactament el problema del qual l'equip es queixava. No són experts en aquestes eines — però saben que existeixen, i això ja és mig camí.

Tres llocs que val la pena visitar unes quantes vegades per setmana:

*Hacker News* (news.ycombinator.com) — Un agregador d'enllaços gestionat per Y Combinator, la incubadora de startups darrere d'Airbnb, Dropbox i Stripe. Els enginyers hi publiquen i discuteixen articles sobre tecnologia, eines i canvis en la indústria. Les seccions de comentaris són or — hi veuràs enginyers reals discutint si una nova eina és realment bona o només màrqueting. Dona un cop d'ull als cinc articles principals unes quantes vegades per setmana i estaràs per davant de la majoria de gent a qualsevol reunió.

*GitHub Trending* (github.com/trending) — Una llista diària i setmanal de projectes de codi obert que guanyen tracció. No entendràs tot el codi — no cal. Llegeix les descripcions dels projectes. "Una alternativa més ràpida a Elasticsearch." "Clon de Notion auto-allotjat." "Framework d'agents d'IA per a Python." Comences a veure patrons: quins problemes resol la gent, què guanya impuls, què pot adoptar el teu equip el pròxim trimestre.

*Reddit* (r/programming, r/webdev, r/selfhosted, r/artificial) — Discussions de comunitat, més informals que Hacker News, sovint més pràctiques. La gent comparteix què està construint, què s'ha trencat, què ha après. Genial per a la perspectiva "com se sent realment la gent respecte a això?" Quan surt una nova eina d'IA, Reddit et dirà en 24 hores si és genuïnament útil o només màrqueting.

L'hàbit és senzill. Deu minuts amb el cafè del matí, tres vegades per setmana. Dona un cop d'ull a la portada. Llegeix un article que et cridi l'atenció. En un mes, començaràs a reconèixer noms — frameworks, biblioteques, empreses. En tres mesos, sentiràs el teu amic desenvolupador parlar d'alguna cosa i pensaràs: "Oh, vaig llegir sobre això la setmana passada."

Aquell moment — quan deixes de ser la persona que assenteix a les reunions i passes a ser la persona que fa la pregunta que canvia la direcció de la conversa — és quan aquest capítol ha fet la seva feina.

== Ara ja ho saps

Això és tot. Quatre blocs bàsics. Un menjador (React), una cuina (Django), un rebost (Postgres) i una zona de preparació (Redis). A més de la infraestructura que ho manté tot unit: Git per al control de versions, DNS per trobar l'app, un VPS per executar-la i CI per assegurar-se que res es trenca quan surten canvis.

Gairebé cada aplicació web que fas servir diàriament — el teu banc, el teu servei de streaming, les teves eines de gestió de projectes — és alguna variació d'aquest patró. Els noms específics canvien. La forma no.

Ara, quan el teu amic desenvolupador digui "l'API retorna un 500" o "hem d'afegir una cache Redis per a això" o "estic escrivint una migració", sabràs quina part del restaurant està tenint un mal dia. I quan et posis amb un agent i diguis "construeix-me una eina de pressupostos" — entendràs què està construint realment.

Aquesta comprensió és la teva targeta d'embarcament per a la resta d'aquest llibre.
