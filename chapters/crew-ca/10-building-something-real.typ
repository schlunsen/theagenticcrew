= Construir Alguna Cosa Real

#figure(
  image("../../assets/illustrations/crew/ch10-building-real.jpg", width: 80%),
  caption: [_De la idea al prototip funcional en un cap de setmana._],
)

Aquest es el capitol on tot encaixa. Recorrerem la construccio d'una aplicacio real -- des de la idea fins al producte funcional -- fent servir un agent. Sense codi. Sense experiencia en programacio. Nomes pensament clar, bones instruccions, i tot el que has apres fins ara.

L'aplicacio es real. El sector es real. El proces es exactament el que sembla quan algu que coneix el seu domini s'asseu amb un agent i construeix alguna cosa.

== La Idea

El teu oncle instal.la finestres per guanyar-se la vida. No les de Microsoft -- les de vidre. Bon negoci, feina constant. Fa quinze anys que s'hi dedica i coneix cada model de finestra, cada tipus de marc, cada truc per aconseguir un segellat perfecte en una casa vella i torta.

Pero el seu proces de pressupostos esta ancorat al 2005. Mesura la paret, tria una finestra d'un cataleg de paper, calcula el preu amb una calculadora, ho escriu tot en un document de Word, el desa com a PDF i l'envia per correu al client. La meitat del temps, el client no pot imaginar com quedara realment la finestra a la seva paret. L'altra meitat, perden el PDF i truquen demanant-ne un altre.

Li construiras alguna cosa millor. Una aplicacio on introdueix les mesures, tria un model de finestra, veu una previsualitzacio 3D de com quedara, i genera un pressupost professional -- tot en un sol lloc, accessible des de la seva tauleta al lloc de treball.

Ho construiras aquest cap de setmana.

== Abans de Tocar l'Agent

L'error mes gran que comet la gent es obrir l'agent i escriure immediatament "construeix-me una app de pressupostos de finestres." Aixo es el Capita Alex. Nosaltres serem la Capitana Maya.

Abans d'escriure un sol prompt, has de pensar com una persona de producte. Pregunta't:

*Qui ho fara servir?* Instal.ladors de finestres, amb un portatil o tauleta a casa del client. Ha de ser simple, rapid i funcionar en una pantalla de tauleta.

*Quina es l'accio principal?* Introduir mesures, veure la previsualitzacio, enviar el pressupost. Aixo es el flux. Tot el demes es secundari.

*Quines dades hem d'emmagatzemar?* Clients (nom, adreca, telefon). Models de finestra (nom, dimensions, preu per metre quadrat). Pressupostos (client, model de finestra, mesures, preu total, data).

*Quin es el moment "uau"?* La previsualitzacio 3D. El client esta al seu menjador i veu, en una tauleta, exactament com quedara la nova finestra a la seva paret. Aixo es el que ho fa millor que un document de Word.

Acabes de dissenyar una aplicacio. Sense codi. Sense titol tecnic. Nomes pensament clar sobre qui necessita que.

== Dividir-ho en Tasques

Ara dividim el projecte en peces. Cada peca es una feina autocontinguda que donaras a l'agent. El principi clau: cada feina ha de tenir sentit per si sola, produir un resultat verificable, i construir sobre l'anterior.

=== Tasca 1: Configurar el Projecte

Aquests son els fonaments. Estas dient a l'agent que construeixi l'edifici buit abans de comencar a mobiliar les habitacions.

"Crea un nou projecte amb un backend de Django i un frontend de React. Configura una base de dades Postgres amb tres models: Customer (nom, email, telefon, adreca), WindowModel (nom, rang d'amplada, rang d'alcada, tipus de vidre, preu per metre quadrat), i Quote (vinculat a un client i un model de finestra, amplada de paret, alcada de paret, amplada de finestra, alcada de finestra, posicio x de finestra, posicio y de finestra, preu total, data de creacio). Crea un panell d'administracio de Django perque pugui afegir models de finestra manualment. Assegura't que l'aplicacio React pugui comunicar-se amb el backend de Django a traves d'una API."

Aixo es un sol prompt. Configura tota la pila del Capitol 3 -- el menjador, la cuina i el rebost. L'agent creara desenes de fitxers, configurara la base de dades, muntara la API i ho connectara tot.

Quan acabi, hauries de poder obrir el panell d'administracio de Django al navegador, afegir un model de finestra i veure'l retornat des de la API. Aquesta es la teva verificacio. Si aixo funciona, els fonaments son solids.

=== Tasca 2: El Formulari de Pressupost

Ara construim la interficie on l'instal.lador introdueix la informacio.

"Construeix una pagina a l'aplicacio React amb un formulari per crear un nou pressupost. El formulari ha de tenir: un desplegable per seleccionar un client existent o un boto per afegir-ne un de nou, un desplegable per seleccionar un model de finestra, camps numerics per a amplada de paret, alcada de paret, amplada de finestra, alcada de finestra, i posicio de finestra (horitzontal i vertical, mesurada des de la cantonada inferior esquerra de la paret). Totes les mesures han de ser en centimetres. Quan l'usuari ompli les mesures i seleccioni un model, mostra el preu calculat a sota del formulari: area de la finestra en metres quadrats multiplicada pel preu per metre quadrat del model, mes una tarifa fixa d'instal.lacio de 1.500 DKK. Afegeix un boto Desar Pressupost que enviia les dades a Django."

Fixa't en el nivell de detall. Has especificat els camps, la unitat, la formula de preus i la interaccio. L'agent no ha d'endevinar res.

=== Tasca 3: La Previsualitzacio 3D

Aquesta es la peca estrella -- i la part que sona mes espantosa per a algu que no programa. No ho es. No estas escrivint codi de Three.js. Estas descrivint una escena.

"Utilitzant la llibreria Three.js, afegeix un panell de previsualitzacio 3D al costat del formulari de pressupost. La previsualitzacio ha de mostrar:

- Una paret, representada com un rectangle beix pla, utilitzant l'amplada i alcada de paret del formulari
- Un retall rectangular a la paret on va la finestra, posicionat segons els valors de posicio i mida de finestra del formulari
- Un vidre al retall -- lleugerament transparent, amb un tint blau clar
- Un marc de finestra simple al voltant del vidre, gris fosc, de 5 centimetres de gruix
- La camera ha de comencar amb un lleuger angle perque es pugui veure que la paret te una mica de profunditat (fes la paret de 20cm de gruix)
- L'usuari ha de poder girar la vista arrossegant amb el ratoli (utilitza OrbitControls)
- Afegeix llum ambiental suau i una llum direccional des de la part superior dreta perque el vidre tingui un reflex subtil
- L'escena s'ha d'actualitzar en temps real mentre l'usuari canvia les mesures al formulari

Posa el formulari a l'esquerra de la pantalla i la previsualitzacio 3D a la dreta. En pantalles de tauleta, apila'ls verticalment amb la previsualitzacio a dalt."

Acabes de descriure una escena 3D. Com dir-li a un escenograf que vols a l'escenari. L'agent coneix Three.js. La teva feina es saber com ha de semblar una instal.lacio de finestra -- i _aixo_, el teu oncle t'ho pot dir amb els ulls tancats.

=== Tasca 4: El PDF del Pressupost

"Quan l'usuari faci clic a Desar Pressupost, genera un PDF amb: una capcalera amb el nom de l'empresa 'Hansen Vinduer' i el logotip (proporcionare el fitxer del logotip mes tard), el nom i l'adreca del client, una taula amb les especificacions de la finestra (model, dimensions, tipus de vidre), la previsualitzacio 3D renderitzada com a imatge estatica, el desglossament del preu (area de finestra, preu per metre quadrat, tarifa d'instal.lacio, total), i un peu de pagina amb la informacio de contacte de l'empresa i el numero de CVR. Utilitza la llibreria WeasyPrint per a la generacio de PDF al costat de Django. Despres de desar, mostra un boto 'Descarregar PDF' i un boto 'Enviar per Correu al Client'."

=== Tasca 5: Historial de Pressupostos

"Afegeix una pagina que llisti tots els pressupostos anteriors. Mostra'ls en una taula amb columnes: data, nom del client, model de finestra, preu total i estat (esborrany o enviat). L'usuari ha de poder fer clic a qualsevol fila per obrir el pressupost complet. Afegeix un quadre de cerca que filtri per nom de client. Ordena per data, del mes recent al mes antic."

=== Tasca 6: Poliment

"Dona estil a tota l'aplicacio perque es vegi neta i professional. Utilitza un esquema de colors de blau mari (hex 1a365d) per a la capcalera i els botons, blanc per als fons de les targetes, gris clar (hex f7f7f7) per al fons de la pagina. Fes que tots els botons i camps de formulari siguin prou grans per tocar facilment en una tauleta. Afegeix el nom de l'empresa 'Hansen Vinduer' a la capcalera. Assegura't que tot funcioni en un iPad en orientacio horitzontal."

== El Moment Three.js

Fixem-nos en la Tasca 3, perque il.lustra la llico mes important d'aquest capitol: pots dirigir un agent perque utilitzi tecnologia de la qual mai has sentit a parlar.

Three.js es una llibreria que dibuixa grafics 3D en un navegador web. Mai l'has utilitzat. Probablement mai n'has sentit a parlar. I no necessites aprendre-la. Necessites aprendre a _descriure el que vols en 3D_.

L'agent coneix la llibreria. Tu coneixes el domini. Aquesta combinacio es mes potent que qualsevol de les dues sola.

Quan arribi la primera versio, no sera perfecta. Potser la paret esta al reves -- estas mirant la cara interior en lloc de l'exterior. Potser el vidre es massa opac. Potser la camera comenca dins la paret, mirant cap a fora.

Aixo es normal. Iteres:

- "La paret mostra la cara del darrere. Gira-la perque vegem la cara exterior."
- "El vidre es massa fosc. Fes-lo un 80% transparent amb nomes un toc de blau."
- "La camera comenca massa a prop. Mou-la enrere perque pugui veure tota la paret."
- "Quan canvio l'amplada de la finestra, el marc no es redimensiona. Fes que el marc s'actualitzi en temps real mentre escric."

Cada correccio li pren a l'agent uns trenta segons. Estas dirigint, no depurant. Ets el client assegut amb l'arquitecte, dient "mou aquella finestra una mica a l'esquerra." L'arquitecte fa el dibuix.

== Que et Trobaras pel Cami

Siguem honestos sobre els obstacles, perque formen part del proces:

*L'agent fara suposicions.* A la Tasca 1, podria configurar la base de dades de manera diferent del que esperaves. Potser posa el preu al pressupost en lloc de calcular-lo. Revisa la sortida. Si alguna cosa no quadra, digues-ho.

*Les coses es trencaran entre tasques.* La Tasca 2 podria no connectar-se correctament amb el que la Tasca 1 va crear. El endpoint de la API podria tenir un nom diferent del que el frontend espera. Aixo es normal en el desenvolupament de software -- s'anomena _integracio_. Digues-li a l'agent: "El formulari intenta enviar dades a `/api/quotes/` pero el endpoint de la API es a `/api/quote/create/`. Corregeix el frontend perque faci servir el endpoint correcte."

*La previsualitzacio 3D es veura estranya al principi.* Els grafics 3D son delicats. Il.luminacio, angles de camera, propietats dels materials -- tot necessita ajust. Aquesta es la part mes iterativa del projecte. Reserva temps extra aqui.

*El PDF no es veura professional immediatament.* La generacio de PDF es notoriament capritxosa. L'espaiat anira malament. El logotip sera de la mida incorrecta. La taula no s'alineara. Itera. Cada correccio es especifica i rapida.

== El Calendari del Cap de Setmana

Aqui tens un calendari realista:

*Dissabte al mati:* Tasques 1 i 2. Configura el projecte i construeix el formulari. A l'hora de dinar, pots introduir dades de pressupost i desar-les.

*Dissabte a la tarda:* Tasca 3. La previsualitzacio 3D. Aixo requereix mes iteracio. A l'hora de sopar, tens una paret 3D giratoria amb una finestra que s'actualitza quan canvies el formulari.

*Diumenge al mati:* Tasca 4. Generacio de PDF. A mig mati, pots generar un document de pressupost professional.

*Diumenge a la tarda:* Tasques 5 i 6. Historial de pressupostos i poliment. Al vespre, l'aplicacio es veu i funciona com un producte real.

Set tasques. Dos dies. Una aplicacio que fa que el teu oncle sembli una empresa deu vegades mes gran.

== La Llico Mes Gran

Mai has escrit una linia de codi. Pero has pres totes les decisions que importaven. Has decidit el model de dades. Has decidit el flux d'usuari. Has decidit com havia de ser la previsualitzacio 3D. Has decidit la formula de preus. Has decidit el disseny visual.

L'agent ha escrit el codi. Tu has fet el pensament. I el pensament -- la comprensio del domini, el gust per allo que es veu professional, el criteri sobre el que necessita l'usuari -- aixo es la part que cap agent pot fer.

Aixo es el que significa ser un membre de la tripulacio que dirigeix. No un passatger. No un capita. Algu que coneix les aigues, veu els corrents, i diu a la tripulacio cap a on navegar.
