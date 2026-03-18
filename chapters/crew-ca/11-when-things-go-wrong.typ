= Quan les coses surten malament

#figure(
  image("../../assets/illustrations/crew/ch11-when-wrong.jpg", width: 80%),
  caption: [_Els errors són inevitables. La recuperació és una habilitat._],
)

Tothom qui treballa amb agents prou temps acaba acumulant una col·lecció d'aquestes històries. Aquells moments en què t'enrecolzes a la cadira, mires la pantalla fixament i dius alguna cosa que la teva mare no aprovaria. Són humiliants. Són educatives. I són inevitables.

Aquest capítol és una col·lecció de coses que realment surten malament quan encomanes feina real a un agent. No són hipòtesis. No són fantasies catastrofistes. Són el tipus d'errors que et costen una tarda o la teva confiança. Cadascun porta una lliçó que connecta amb alguna cosa dels capítols anteriors d'aquest llibre.

Llegeix-les abans de cometre els mateixos errors. O llegeix-les després, i sent-te menys sol.

== El correu que no estava a punt

Vas demanar a l'agent que redactés un correu de seguiment per a un client. L'agent va produir un esborrany perfectament raonable. Li vas fer un cop d'ull ràpid, vas pensar "té bona pinta" i vas prémer enviar.

Dues hores més tard, el client va trucar. El correu feia referència a una reunió que encara no havia tingut lloc — l'agent havia confós l'esdeveniment del calendari del dimarts vinent amb les notes del dimarts passat. També citava un preu d'una proposta antiga, no de l'actual. El correu era coherent, professional, i incorrecte en dos punts que importaven.

*La lliçó:* No enviïs mai comunicacions generades per un agent sense llegir-les com si les hagués escrit una persona. L'agent no sap què és actual i què està desfasat. No sap que la reunió encara no ha tingut lloc. Va muntar contingut que sonava plausible a partir del context que tenia, i part d'aquell context estava obsolet. Això és el capítol de verificació en acció — i la raó per la qual el gradient de confiança situa "enviar correus" alt a l'escala de revisió.

== L'estadística segura de si mateixa

Vas demanar a l'agent que preparés una anàlisi competitiva. Va produir un informe preciós: mides de mercat, taxes de creixement, xifres d'ingressos de competidors, percentatges de quota de mercat. Impressionant. Detallat. Vas utilitzar tres d'aquells números en una presentació per al consell.

Durant la ronda de preguntes, un membre del consell va obrir l'informe sectorial real que l'agent semblava citar. Dos dels tres números eren incorrectes. No estaven esbojarradament malament — prou propers per ser plausibles, prou diferents per ser vergonyosos. L'agent no havia _trobat_ aquells números. Els havia _generat_ — xifres plausibles que encaixaven amb la narrativa, presentades amb la mateixa confiança que l'únic número que sí que era correcte.

*La lliçó:* Aquest és el problema de l'al·lucinació del Capítol 9, manifestant-se en l'escenari de màxim risc possible. Els números dels agents s'han de verificar sempre amb les dades originals. Sempre. Si l'agent cita un informe, busca l'informe i comprova la citació. Si l'agent produeix un percentatge, rastreja'l fins a les dades. L'agent no sap la diferència entre un fet que ha trobat i un fet que s'ha inventat.

== El redisseny excessiu

Vas demanar a l'agent que canviés el color d'un botó del teu web de blau a verd. Una tasca ràpida. Cinc minuts.

L'agent va canviar el color del botó. També va notar que l'estil del botó era "inconsistent amb les pràctiques de disseny modernes" i el va actualitzar. Després va actualitzar els altres botons perquè coincidissin. Després la barra de navegació. Després el peu de pàgina. Després va reestructurar el CSS per fer servir un "enfocament més mantenible".

El botó era verd. Tot el resta era irreconeixible. Vuitanta-set fitxers havien canviat. L'agent havia fet un redisseny complet que no li havies demanat, i desfer-ho significava esbrinar quin dels vuitanta-set fitxers contenia l'únic canvi que realment volies.

*La lliçó:* Restriccions. "Canvia el color del botó de la pàgina d'inici de blau (hex 3b82f6) a verd (hex 22c55e). No canviïs res més." Això és tot el que cal. Els agents són optimitzadors entusiastes — veuen oportunitats de millora i les aprofiten tret que els diguis explícitament que no ho facin. El capítol sobre instruccions existeix exactament per aquesta raó. A més: branques de Git. Si l'agent hagués estat treballant en una branca, l'eliminaries i començaries de nou. Cinc segons. Cap dany.

== Les dades que no tenien còpia de seguretat

Vas construir una petita aplicació amb un agent. Funcionava genial. Després vas demanar a l'agent que "netegés la base de dades" — volies dir que eliminés algunes dades de prova que havies introduït mentre experimentaves.

L'agent va interpretar "netejar" com "restablir a un estat net". Va eliminar totes les taules i les va recrear buides. Sis setmanes de dades reals de clients — pressupostos, mesures, informació de contacte — perdudes.

*La lliçó:* Dues lliçons, en realitat. Primera: sigues terroríficament específic quan la tasca implica dades. "Elimina tots els pressupostos on el nom del client contingui 'test' o 'asdf'" és molt diferent de "neteja la base de dades". Segona: còpies de seguretat. Si estàs construint alguna cosa real — alguna cosa amb dades que importen — les còpies de seguretat regulars de la base de dades no són opcionals. Demana al teu agent que les configuri. És una de les primeres coses que hauries de fer quan l'aplicació comença a contenir dades reals.

== La funcionalitat que ningú volia

Vas demanar a l'agent que afegís un mode fosc a l'aplicació de pressupostos. L'agent ho va fer magníficament. Interruptor a la capçalera, transició suau, tots els colors adaptats. Quedava genial.

El teu oncle ho va odiar. "Per què hi ha un interruptor a la meva capçalera? Jo faig servir això a les obres amb llum del dia. El mode fosc és inútil. I l'interruptor va confondre el meu nou treballador — va pensar que era un botó d'encendre/apagar de tota l'aplicació."

Havies passat dues hores en una funcionalitat basada en la teva pròpia preferència, no en les necessitats del teu usuari. L'agent va executar perfectament. El problema era la instrucció, no l'execució.

*La lliçó:* Un agent construirà exactament el que li demanis. No et dirà si hauries d'estar-ho demanant. La pregunta "hauríem de construir això?" sempre és teva. Parla amb l'usuari real abans de construir. El teu oncle t'hauria dit en deu segons que el mode fosc era inútil per al seu flux de treball — i potser t'hauria mencionat tres coses que realment necessita.

== El patró de recuperació

Totes les històries de guerra anteriors tenen el mateix patró de recuperació:

+ *Atura.* No deixis que l'agent continuï. Si va en la direcció equivocada, més feina ho empitjora.
+ *Avalua.* Què ha passat realment? Què ha canviat? Què s'ha perdut?
+ *Restaura.* Branca de Git? Elimina-la. Base de dades? Restaura des de la còpia de seguretat. Correu? Envia una correcció.
+ *Aprèn.* Quina instrucció o barrera de seguretat hauria previngut això? Afegeix-la al teu procés.
+ *Torna-ho a provar.* Amb millors instruccions, millors restriccions i millor verificació.

Els errors són inevitables. La recuperació és una habilitat. I la prevenció — instruccions clares, restriccions adequades, verificació, còpies de seguretat — és el que tot aquest llibre t'està ensenyant.
