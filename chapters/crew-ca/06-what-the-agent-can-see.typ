= Què pot veure l'agent

#figure(
  image("../../assets/illustrations/crew/ch06-workbench.jpg", width: 80%),
  caption: [_Un agent només pot treballar amb el que té al banc._],
)

La cosa més important de treballar amb agents no és com els dones instruccions. És què els poses al davant abans de fer la pregunta.

Un agent és tan bo com el que pot veure. Dóna-li una descripció vaga i un full en blanc, i al·lucinarà amb confiança. Dóna-li els fitxers correctes, les restriccions correctes, la visió correcta del problema — i farà coses que semblen màgia. La diferència no és el model. Ets tu.

== El banc de treball

Pensa en la visió de l'agent com un banc de treball físic. Té un espai limitat. No pots abocar-hi tota la teva vida i esperar bons resultats. En canvi, hi disposes les peces que importen per a _aquesta_ tasca: els documents rellevants, el missatge d'error específic, la captura de pantalla, l'exemple del que vols.

Bona gestió del banc de treball:

- Treballant en una eina de pressupostos? Posa la versió actual davant de l'agent, a més d'un exemple de com hauria de ser un pressupost acabat.
- Intentant arreglar un bug? No descriguis el bug — enganxa el missatge d'error real. Mostra la captura de pantalla. Inclou els passos que l'han provocat.
- Dissenyant una nova funcionalitat? Proporciona un esbós, l'exemple d'un competidor o una descripció detallada del flux d'usuari.

Mala gestió del banc de treball:

- Enganxar tot el teu projecte i dir "alguna cosa està trencada."
- Descriure un problema de memòria en lloc de compartir l'error real.
- Donar a l'agent informació sobre deu tasques diferents i demanar-li que endevini quina vols dir.

El principi del banc de treball s'aplica a tot — no només al codi. Si demanes a un agent que redacti un informe, dóna-li les dades en brut, l'audiència, el format que vols i un exemple d'un bon informe. Si li demanes que planifiqui un esdeveniment, dóna-li les restriccions (pressupost, data, capacitat del local) en lloc de simplement "planifica un esdeveniment d'equip."

== Materials en brut vs. descripcions

Hi ha una diferència crucial entre _descriure_ alguna cosa i _mostrar-la_.

*Descripció:* "Els números de vendes estan en un full de càlcul. Els totals semblen incorrectes per al T2."

*Material en brut:* Enganxa les dades reals del full de càlcul. O millor — dóna a l'agent accés al fitxer. Ara pot veure les fórmules, trobar l'error i arreglar-lo. Tu has descrit el símptoma. El material en brut mostra la causa.

Aquesta és la millora més gran que la majoria de gent pot fer: deixar de descriure, començar a mostrar. Enganxa el missatge d'error. Adjunta la captura de pantalla. Puja el document. Dóna a l'agent la mateixa informació que donaries a un col·lega assegut al teu costat.

Cada vegada que parafraseges, perds senyal. Comprimeixes el problema real a través del tub estret de la teva interpretació, i l'agent l'ha de descomprimir — malament — a l'altre costat. És com descriure una pintura per telèfon i demanar a algú que la reprodueixi.

== Nivells de qualitat del context

Hi ha una manera útil de pensar sobre com de bo és el teu context:

*Nivell 0 — Descripció vaga:* "L'informe sembla incorrecte." L'agent endevina quin informe, endevina què està malament i endevina com arreglar-ho. Amb tres suposicions de profunditat, les probabilitats d'encertar-ho són baixes.

*Nivell 1 — Descripció específica:* "Els ingressos del T2 a l'informe trimestral mostren 2,3 M\$ però haurien de ser 2,1 M\$. Crec que la fórmula inclou les transaccions reemborsades." Molt millor. L'agent coneix el símptoma i la teva teoria sobre la causa.

*Nivell 2 — Dades en brut:* Enganxes la secció rellevant del full de càlcul, la fórmula i la llista de transaccions. Ara l'agent pot verificar la teva teoria o descobrir la causa real. Potser la fórmula està bé però dues transaccions estaven duplicades. No ho hauries detectat descrivint el problema.

*Nivell 3 — Accés:* L'agent pot obrir el full de càlcul ell mateix, executar les fórmules, comprovar la font de dades i investigar independentment. Tu proporciones la _intenció_ ("esbrina per què els ingressos del T2 estan inflats") i l'agent fa la feina de detectiu.

La majoria de gent viu al Nivell 0 o 1. L'objectiu és arribar al Nivell 2 com a predeterminat, i al Nivell 3 quan les eines ho permetin.

== Menys és més (de vegades)

No es tracta de donar a l'agent _tot_. Es tracta de donar-li _les coses adequades_.

Massa poc context i l'agent endevina. Massa context i l'agent queda enterrat. Imagina donar a algú una pila de mil pàgines i dir "la resposta és en algun lloc d'aquí dins." Bona sort.

Per a cada tasca, pregunta't:
- Què necessita veure l'agent per entendre aquesta tasca?
- Què el confondrà si ho incloc?
- La informació que estic proporcionant és actual, o li estic donant dades obsoletes?

Un banc de treball enfocat supera un de desordenat. Tres fitxers rellevants són millors que trenta d'irrellevants. El missatge d'error específic és millor que tot el fitxer de registre.

== L'efecte compost

Cada vegada que dones a un agent bon context, el resultat és millor. Millor resultat vol dir menys temps corregint. Menys correccions vol dir més temps per a la tasca següent. Al llarg d'una setmana, la diferència entre algú que aboca descripcions vagues i algú que proporciona context net i enfocat és enorme — no perquè sigui més intel·ligent, sinó perquè ha après a preparar l'agent per a l'èxit.

Aquesta habilitat es compon. I és exactament la mateixa habilitat que et fa millor delegant a humans, escrivint correus més clars i fent millors informes de bugs. L'agent simplement et dóna retroalimentació més ràpida sobre si la teva comunicació era prou clara.
