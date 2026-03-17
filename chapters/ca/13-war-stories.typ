= Quan els Agents s'Equivoquen

Tots els enginyers que treballen amb agents prou temps tenen una col·leccio d'aquestes histories. Els moments on et recolzes a la cadira, mires la pantalla, i murmures alguna cosa impublicable. Son humiliants. Son educatius. I son _inevitables_.

Aquest capitol es una col·leccio d'histories de guerra -- coses que realment van malament quan dones feina real a un agent. No hipotetics. No demos artificials. El tipus de fallades que et costen una tarda, un desplegament, o la teva fe en l'automatitzacio. Cadascuna es mapeja a principis de capitols anteriors, perque els principis son barats fins que els aprens per les males.

Llegeix-les abans de cometre els mateixos errors. O llegeix-les despres, i senteix-te menys sol.

== El Refactoritzador Entusiasta

La tasca era simple: arreglar un problema de z-index en un menu desplegable. El desplegable es renderitzava darrere d'una capa de modal. Un arreglament CSS d'una linia -- potser dos si vas amb compte.

L'agent va veure el component del desplegable, va decidir que el seu CSS era "inconsistent amb les practiques modernes," i el va refactoritzar. Despres va notar que el modal utilitzava un patro d'estil diferent, aixi que tambe el va refactoritzar. Despres els components de botons. Despres els components de targetes. Abans que aixequessis la vista del cafe, trenta-dos fitxers havien canviat. El diff era de 1.400 linies. L'agent havia essencialment reescrit el sistema d'estils de la biblioteca de components, migrant d'un enfocament a un altre amb una consistencia admirable i zero autoritzacio.

El bug original del z-index? Seguia alla. Enterrat en algun lloc de l'allau de canvis, l'agent havia reproduit el mateix problema de capes amb nous noms de classes.

El PR era irrevisable. No pots revisar significativament 1.400 linies de canvis de CSS a trenta-dos fitxers. El que _pots_ fer es esborrar la branca i comencar de nou. Que es el que va passar.

*Que fas diferent ara:* Acota les tasques estretament. "Arregla el z-index del desplegable a `NavMenu.tsx`, no toquis res mes." Utilitza una branca dedicada perque el dany estigui contingut. I _sempre_ comprova el diff abans de deixar l'agent passar a qualsevol altra cosa. Al moment que vegis el nombre de fitxers pujant mes enlla del que te sentit per a la tasca, atura l'agent. El capitol de baranes existeix per una rao.

== La Biblioteca Al·lucinada

L'agent necessitava parsejar alguns rangs de dates complexos de l'entrada de l'usuari. Va importar `@temporal/daterange-parser`, va escriure codi elegant utilitzant el seu metode `.parseRange()` amb opcions per a parsing conscient de la localitat i matching difus. El codi era net. Els tipus eren correctes. La gestio d'errors era acurada. Fins i tot va escriure tests -- que, naturalment, tambe importaven el paquet al·lucinat.

Tot es veia perfecte al diff. Les signatures de funcions tenien sentit. L'API estava ben dissenyada. Era una biblioteca _tan_ plausible que gairebe no la vas qüestionar.

Despres `npm install` va fallar. El paquet no existia. Mai havia existit. L'agent havia inventat una biblioteca, li havia donat un nom creible i una API coherent, i havia escrit codi de produccio contra una ficcio.

La part insidiosa: si nomes hagues fet revisio de codi -- llegint la logica, comprovant els tipus, avaluant l'enfocament -- l'hauries aprovat. El codi era _bo_. Simplement no connectava amb la realitat.

*Que fas diferent ara:* L'agent executa els tests. Sempre. Si la teva configuracio no ho permet, els executes tu abans de revisar codi. Sense excepcions. Un `npm install` que falla es un senyal fort i obvi. Una API al·lucinada que mai es va executar es una bomba silenciosa. Els tests detecten el que la revisio humana no detecta -- no perque la teva revisio sigui dolenta, sino perque les ficcions plausibles estan _dissenyades_ per passar la revisio. Aixo es el que _es_ l'al·lucinacio.

== El Bucle Infinit

Vas demanar a l'agent que arregles un test d'integracio que fallava. Va llegir l'error, va fer un canvi, va executar el test. Nou error. Va llegir _aquell_ error, va fer un altre canvi, va executar el test. Error diferent. Despres una variacio del primer error. Despres alguna cosa nova. Despres el primer error una altra vegada.

Eres en un altre terminal, treballant en una altra cosa. Quaranta minuts despres vas comprovar. L'agent havia fet dinou intents. Havia cremat 200.000 tokens. El codi era ara pitjor que quan va comencar -- un registre geologic d'arreglaments fallits apilats uns sobre els altres. L'agent seguia anant, alegrament confiat que l'intent vint seria el bo.

No ho va ser.

El problema fonamental era que l'agent no entenia _per que_ el test fallava. Estava fent correspondencia de patrons amb missatges d'error i fent edicions locals, pero el problema real era un malentes arquitectonic -- un estat de base de dades compartit entre casos de test que requeria un enfocament de configuracio completament diferent. Cap quantitat d'ajustos al codi sota test arreglaria un problema a la infraestructura de tests.

*Que fas diferent ara:* Configura limits d'iteracio. Tres intents al mateix problema es un maxim raonable. Si l'agent no ho ha resolt en tres passades, no ho resoldra en trenta. Quan vegis el bucle -- error, arreglament, error diferent, arreglament, error original -- _trenca'l manualment_. Atura l'agent, llegeix els errors tu, i dona-li un enfocament completament diferent o pren-ho tu. El temps de l'agent es barat. La teva tarda perduda no. Mes important, comenca un context fresc. La comprensio de l'agent ara esta contaminada amb dinou teories equivocades. Un inici net amb el teu diagnostic del problema _real_ arribara mes lluny, mes rapid.

== La Resposta Incorrecta Amb Confianca

Un treball en segon pla ocasionalment processava el mateix element dues vegades. Condicio de carrera classica. Vas apuntar l'agent al problema.

L'agent va analitzar el codi, va identificar la finestra de carrera, i va afegir un retard de 500ms entre la comprovacio i l'actualitzacio. "Aixo assegura que la transaccio anterior te temps de completar-se abans de la propera comprovacio," va explicar, amb la confianca serena d'algu que mai ha operat un sistema sota carrega.

Els tests van passar. El retard era mes llarg que el temps de transaccio del test, aixi que la finestra de carrera es va tancar -- a l'entorn de test, amb un sol treballador concurrent, en una maquina tranquil·la.

Va anar a produccio. Sota carrega, amb dotze treballadors i latencia de base de dades variable, 500ms de vegades no era suficient. I ara tenies un _nou_ problema: el retard havia reduit el rendiment prou perque la cua de treballs s'acumules durant les hores punta, creant timeouts en cascada que van tirar a terra un servei no relacionat.

El sleep no va arreglar la condicio de carrera. La va amagar a baixa concurrencia i va empitjorar el sistema a alta concurrencia. Un arreglament adequat -- un advisory lock o una clau d'idempotencia -- hauria estat correcte a qualsevol escala. L'agent va triar l'arreglament que feia el test verd, no l'arreglament que era _correcte_.

*Que fas diferent ara:* Tractes els tests que passen com a necessaris pero no suficients. Quan un agent arregla un problema de concurrencia, et preguntes _a tu mateix_ si l'arreglament es correcte sota carrega, sota fallada, sota condicions que la suite de tests no cobreix. Els agents optimitzen pel senyal de retroalimentacio que els dones, i si aquell senyal es "els tests passen," trobaran el cami mes curt cap al verd -- fins i tot si aquell cami es un `time.Sleep`. El teu judici d'enginyeria sobre _per que_ alguna cosa funciona importa mes que _si_ els tests passen. Aquesta es la part de la feina que encara no s'ha automatitzat. Aprofita-la.

== L'Amnesia de Context

Dues hores dins d'una sessio, tenies una funcionalitat que evolucionava be. Havies dit a l'agent al principi: "No facis servir cap ORM -- escrivim SQL en brut en aquest projecte. Es una decisio deliberada." L'agent ho va reconèixer i va escriure consultes netes i fetes a ma per a les primeres tasques.

Despres li vas demanar que afegis un nou endpoint. Noranta minuts de context s'havien acumulat. L'agent va construir l'endpoint -- amb Prisma. Fitxer d'esquema complet, migracio, client generat. Codi bonic. Contradient completament la restriccio que havies establert al principi de la sessio i els patrons de cada altre fitxer que havia escrit aquell dia.

Quan ho vas assenyalar, l'agent es va disculpar, va reescriure tot en SQL en brut, i va actuar com si no hagues passat res. No havia _decidit_ ignorar la teva restriccio. Simplement l'havia perdut. La finestra de context s'havia omplert amb prou feina intermedia que la instruccio inicial s'havia esvanit en la irrellevancia.

*Que fas diferent ara:* Les sessions llargues es degraden. Aixo es una propietat fonamental de com funcionen les finestres de context, no un bug que s'arreglara el proper trimestre. Mantin les tasques curtes i enfocades. Commiteja codi funcional en fronteres naturals perque el progres quedi capturat a git, no nomes a la conversa. Comenca sessions noves per a tasques noves. I per a restriccions de tot el projecte com "no ORM" o "no noves dependencies," posa-les en un fitxer `CLAUDE.md` o equivalent que l'agent llegeixi a l'inici. No confiis en que l'agent _recordi_ el que vas dir fa dues hores. No ho fara. Escriu-ho.

== L'Allau de Dependencies

Vas demanar un selector de dates. Un simple input on els usuaris puguin seleccionar una data. L'agent va avaluar les opcions i va decidir ser exhaustiu.

Va instal·lar `moment.js` per a la gestio de dates. Despres `@popperjs/core` per posicionar el desplegable. Despres una biblioteca de components d'interficie completa perque "proporciona primitives de selector de dates accessibles." Despres un preprocessador de CSS perque el sistema de temes de la biblioteca de components ho requeria. Despres dos paquets d'utilitats que el selector de dates de la biblioteca de components necessitava com a dependencies parelles.

Sis noves dependencies. La mida del teu bundle va passar de 180KB a 540KB. El temps de build es va duplicar. Tenies un selector de dates, pero. Era molt maco.

El `<input type="date">` natiu d'HTML hauria estat be. O una sola biblioteca de selector lleugera de 8KB. En lloc d'aixo havies heretat tot un ecosistema perque l'agent va optimitzar per completesa en lloc de minimalitat.

La pitjor part no era la mida del bundle -- era la superficie de manteniment. Sis nous paquets vol dir sis coses noves que poden tenir vulnerabilitats de seguretat, sis coses noves que es poden trencar en una actualitzacio, sis nous changelogs per llegir quan Dependabot comenci a obrir PRs. No nomes vas afegir un selector de dates. Vas adoptar sis projectes de codi obert.

*Que fas diferent ara:* Restringeix el que els agents poden instal·lar. "No noves dependencies sense preguntar-me primer" es una instruccio legitima i sovint _savia_. Quan permetis nous paquets, digues a l'agent les teves restriccions: pressupost de bundle, no paquets amb menys de N descàrregues setmanals, no paquets que arrosseguin mega-dependencies transitives. Els agents no tenen opinions sobre mida de bundle o carrega de manteniment. No mantindran el projecte l'any vinent. _Tu_ si. Aixi que tu poses els limits.

== El Fil Comu

Cadascuna d'aquestes histories te la mateixa causa arrel: l'agent estava fent _exactament el que estava dissenyat per fer_, i l'huma no estava proporcionant prou estructura.

El refactoritzador entusiasta estava sent servicial. La biblioteca al·lucinada estava sent creativa. El bucle infinit estava sent persistent. La resposta incorrecta amb confianca estava sent guiada per tests. L'amnesia de context era una limitacio, no una eleccio. L'allau de dependencies estava sent exhaustiva.

Cap d'aquestes son bugs d'agents. Son bugs de _flux de treball_. L'arreglament mai es "utilitza un agent mes intel·ligent." L'arreglament sempre es el mateix: abast mes estret, millors bucles de retroalimentacio, mes estructura, sessions mes curtes, i un huma que segueix involucrat.

Els agents s'equivoquen. Els humans tambe. La diferencia es que els humans s'equivoquen prou lentament com per adonar-se'n. Els agents s'equivoquen a la velocitat de l'autocompletat, i quan aixeques la vista del cafe, trenta-dos fitxers han canviat.

Mantin-te al bucle. Comprova els diffs. Confia pero verifica. I quan les coses vagin malament -- perque ho faran -- recorda que el boto d'esborrar-branca-i-comencar-de-nou es l'eina mes infravalorada del teu flux de treball.

== El Manual de Diagnostic

Les histories de guerra son entretingudes. Pero no pots enganxar anecdotes al teu monitor. El que necessites es un enfocament sistematic -- una llista de comprovacio per quan l'agent produeix alguna cosa incorrecta, perque puguis diagnosticar la fallada rapidament i arreglar la cosa correcta en lloc de bracejar.

Quan un agent et dona mala sortida, passa per aquestes preguntes en ordre. La majoria de fallades cauen en una de sis categories, i saber en quina categoria ets determina que fas a continuacio.

*1. Es un problema d'abast?*

Has demanat massa en un sol prompt? El Refactoritzador Entusiasta va passar perque "arregla el z-index" era massa vague -- no deia "no toquis res mes." Si l'agent ha canviat fitxers que no esperaves, o ha fet feina que no has demanat, l'abast era massa ample. Ajusta el prompt. Sigues explicit sobre que _no_ fer. Les restriccions son mes utils que les instruccions quan tractes amb un agent entusiasta.

*2. Es un problema de context?*

Tenia l'agent el que necessitava per resoldre el problema real? Recorda la historia del bug de facturacio del Capitol 2 -- un enginyer va donar context vague i va obtenir una resposta vaga, l'altre va donar fitxers especifics i traces d'error i va obtenir un arreglament funcional. Si l'agent va resoldre el problema _equivocat_, probablement no podia veure el correcte. Alimenta'l amb els fitxers rellevants, la sortida d'errors, les restriccions que no pot inferir. Els agents no endevinen be. Treballen amb el que els dones.

*3. Es un problema de senyal de retroalimentacio?*

Els teus tests estan realment verificant la cosa correcta? La Resposta Incorrecta Amb Confianca va passar perque els tests van passar -- pero no testejaven sota condicions realistes. El sleep de 500ms "arreglament" era verd a CI i incorrecte a produccio. Si la solucio de l'agent se sent dubtosa pero els tests passen, _els teus tests son el problema_. L'agent va optimitzar pel senyal que li vas donar. Dona-li un senyal millor.

*4. Es un problema de capacitat?*

Algunes tasques genuinament estan mes enlla del que el model pot fer. Raonament multi-fitxer a traves d'un sistema extens amb dependencies implicites. Problemes de concurrencia subtils que requereixen entendre el comportament en temps d'execucio, no nomes l'estructura del codi. Logica sensible a la seguretat on "plausible" no es prou bo. Si l'agent segueix provant enfocaments diferents i fallant, potser no es capac d'aquesta tasca particular. Aixo no es un problema de prompt -- es una limitacio. Reconeix-ho i pren-ho tu. El teu temps es millor invertit fent la feina que enginyant el prompt perfecte per a una tasca que l'agent no pot gestionar.

*5. Es un problema de finestra de context?*

Les sessions llargues es degraden. Punt. La historia de l'Amnesia de Context ho va demostrar -- restriccions establertes aviat a una sessio simplement es perden a mesura que el context s'omple amb feina intermedia. Si l'agent contradiu alguna cosa que va fer correctament mes aviat a la mateixa sessio, o ignora una restriccio que vas establir fa una hora, la finestra de context es la culpable. Comenca una sessio nova. Torna a establir les restriccions rellevants. Dona-li nomes el context que necessita per a la tasca actual, no el registre arqueologic de tot el que heu discutit avui.

*6. Es un bucle?*

Tres intents al mateix error es el limit. Si l'agent no ho ha resolt en tres passades, no ho resoldra en trenta. La historia del Bucle Infinit va cremar 200.000 tokens en dinou intents sense progres. Quan vegis el patro -- error, arreglament, error diferent, arreglament, error original -- trenca el bucle immediatament. Atura l'agent. Llegeix els errors tu. Dona a l'agent un enfocament completament diferent amb un diagnostic fresc, o pren-ho tu completament. El context de l'agent ara esta contaminat amb teories fallides, i mes intents nomes afegiran mes contaminacio.

Imprimeix aquesta llista de comprovacio. Enganxa-la al teu monitor. Les primeres vegades la recorreras conscientment. Despres d'un mes, es torna instint. Despres de tres mesos, detectaras el problema abans que l'agent ni tan sols acabi el seu primer intent.
