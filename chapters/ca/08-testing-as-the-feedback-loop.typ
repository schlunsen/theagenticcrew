= Els Tests com a Bucle de Retroalimentacio

Dues bases de codi. El mateix agent. La mateixa tasca: "Afegeix un limitador de velocitat a l'API que retorni 429 despres de 100 peticions per minut per usuari."

A la primera base de codi, no hi ha tests. L'agent llegeix els handlers de rutes, tria un punt d'insercio del middleware, escriu la logica de limitacio de velocitat, i... s'atura. No te manera de saber si ha funcionat. No pot engegar el servidor i enviar 101 peticions per veure que passa. No pot comprovar si els endpoints existents segueixen responent correctament. Produeix un diff, diu "He afegit limitacio de velocitat," i espera que vagi be. Tu revises el codi, hi entreobres els ulls, penses que sembla raonable, el fusiones, i descobreixes en produccio tres dies despres que el middleware estava muntat en l'ordre incorrecte i mai es va executar. Totes les peticions passaven. El limitador de velocitat era decoracio.

A la segona base de codi, hi ha una suite de tests. L'agent escriu el middleware de limitacio de velocitat, despres executa els tests. Dos tests existents fallen -- un test de health check que no esperava les capsaleres del middleware, i un test d'autenticacio on la configuracio del test feia 150 peticions rapides i ara queda limitat. L'agent llegeix les fallades, ajusta el middleware per saltar-se l'endpoint de health, actualitza la fixture del test per reiniciar el comptador de velocitat entre tests, i torna a executar. Verd. Despres escriu tres tests nous: un que verifica que la peticio 101 retorna 429, un que verifica que el comptador es reinicia despres d'un minut, i un que verifica que usuaris diferents tenen limits independents. Tots passen.

El mateix agent. La mateixa tasca. Resultats com la nit i el dia. La diferencia va ser la suite de tests.

En el desenvolupament tradicional, els tests verifiquen que el teu codi funciona. En enginyeria agentica, els tests fan alguna cosa mes fonamental: diuen a l'agent si ha tingut exit. Aixo canvia tot sobre com penses dels tests.

Hi ha alguna cosa inquietant en aixo al principi. La teva suite de tests -- la cosa que vas escriure per verificar el _teu_ codi -- es converteix en l'especificacio contra la qual un agent implementa. Els tests pels quals vas suar no son nomes assegurament de qualitat. Son la definicio del que vol dir "correcte". Es una sensacio estranya: el teu esforc passat convertint-se en la base per a un flux de treball que no existia quan els vas escriure. Pero tambe es, si ho permets, profundament validador. Totes aquelles hores escrivint tests exhaustius? No eren nomes bona practica. Eren _inversio_ -- i els retorns estan arribant ara.

== Els Ulls de l'Agent

Un agent no pot mirar una interficie i dir si es veu be. No pot sentir si una resposta d'API es "prou rapida." No pot intuir si una refactoritzacio ha preservat el comportament subtil del qual depenen els usuaris. El que _pot_ fer es executar la teva suite de tests i llegir els resultats.

Els tests es converteixen en el mecanisme principal de retroalimentacio de l'agent. Verd vol dir "continua." Vermell vol dir "torna-ho a provar." Sense tests vol dir que l'agent vola a cegues -- endevinant si els seus canvis funcionen, sense manera de verificar.

Per aixo les bases de codi sense tests son dificils de treballar de manera agentica. No es nomes un problema de qualitat -- es un problema d'informacio. Sense tests, l'agent no te senyal. Es com demanar a algu que pengi un quadre amb els ulls embenats. Potser ho fa be, pero no hi apostaries.

I la qualitat d'aquell senyal importa enormement. Un test que diu `FAIL: expected 429, got 200` es accionable. L'agent sap exactament que ha anat malament i pot raonar sobre per que. Un test que diu `FAIL: assertion error` sense context es a penes millor que el silenci. La claredat de la sortida dels teus tests es la claredat de la visio de l'agent.

== El TDD Adquireix un Nou Significat

El Test-Driven Development sempre va ser una bona idea. Amb agents, es converteix en un superpoder.

El flux de treball es simple: escriu el test primer, despres dona-li'l a l'agent i digues "fes que passi." L'agent ara te un criteri d'exit clar i inequivoc. Pot iterar -- escriure codi, executar el test, llegir l'error, ajustar, repetir -- en un bucle ajustat que triga segons per cicle.

Aqui tens com es veu concretament. Posem que necessites una funcio que analitzi una cadena de duracio com `"2h30m"` en total de segons. Escrius el test:

```python
def test_parse_duration():
    assert parse_duration("1h") == 3600
    assert parse_duration("30m") == 1800
    assert parse_duration("2h30m") == 9000
    assert parse_duration("45s") == 45
    assert parse_duration("1h15m30s") == 4530
    assert parse_duration("") == 0
    with pytest.raises(ValueError):
        parse_duration("abc")
```

Despres dius a l'agent: "Fes que `test_parse_duration` passi."

El primer intent de l'agent podria gestionar hores i minuts pero oblidar els segons. Executa el test: `FAIL: parse_duration("45s") returned 0, expected 45`. Senyal clar. Afegeix gestio de segons, torna a executar: `FAIL: parse_duration("abc") did not raise ValueError`. Un altre senyal clar. Afegeix validacio d'entrada. Verd. Fet.

Cada cicle va trigar segons. L'agent mai va necessitar preguntar-te que vol dir "correcte" -- els tests ho definien. I com que el test cobreix casos limits que vas pensar per endavant, la implementacio els gestiona des del principi, no com a bugs descoberts mes tard.

Aixo es fonamentalment diferent de demanar a un agent que "construeixi un parser de duracio." Aixo es vague. Quin format? Quins casos limits? Que hauria de passar amb entrada incorrecta? Pero "fes que aquestes set assercions passin" es precis. L'agent sap exactament com es l'exit, i pot mesurar el seu propi progres cap a ell.

L'enginyer agentic apren a expressar la intencio a traves de tests. Cada test es un contracte. Cada assercio es un requisit. Com millors son els teus tests, millor funcionen els teus agents. Deixes de pensar en escriure tests com a sobrecost i comences a pensar-ho com a _programar l'agent_ -- estas especificant comportament en el llenguatge mes inequivoc disponible: codi que o passa o no.

== Que Fa un Bon Test Agentic

No tots els tests son igualment utils per als agents. Els tests que serveixen be als humans durant el desenvolupament podrien activament enganyar un agent. Un bon test agentic te propietats especifiques, i val la pena ser deliberat sobre elles.

*Rapid.* Un agent itera en un bucle. Si cada cicle triga deu minuts, l'agent prova sis enfocaments per hora. Si cada cicle triga deu segons, en prova 360. La velocitat no es nomes conveniencia -- es la diferencia entre un agent que convergeix cap a una solucio i un que esgota el temps. Executa la suite completa si es rapida; executa nomes els tests rellevants si no ho es. En qualsevol cas, el bucle de retroalimentacio ha de ser ajustat.

*Deterministic.* Un test intermitent es pitjor que cap test per a un agent. Quan un test falla aleatoriament, un huma s'encongeix d'espatlles i torna a executar. Un agent veu una fallada i intenta arreglar-la. Canvia codi que funcionava per perseguir un fantasma. Despres el test intermitent passa -- no perque el canvi de l'agent fos correcte, sino perque les estrelles aleatories es van alinear. Ara tens un canvi de codi inutil que sembla un arreglament pero no ho es. L'agent ha estat recompensat per no fer res util. Si tens tests intermitents, posa'ls en quarantena abans de donar a l'agent acces a la suite.

*Aillat.* Tests que depenen de l'ordre d'execucio, estat compartit, o serveis externs creen fallades desconcertants. L'agent canvia la funcio A i el test B falla -- no per una dependencia real, sino perque el test B depenia d'un estat que el test A havia configurat. L'agent perdra cicles intentant entendre una relacio entre A i B que no existeix al codi, nomes a l'infraestructura de tests. Ailla els teus tests. Cadascun hauria de configurar el seu propi mon i desmuntar-lo.

*Missatges d'error clars.* `AssertionError: False is not True` no diu res a l'agent. `Expected user.status to be 'active' after calling activate(), but got 'pending'` li diu exactament que ha anat malament. Els bons missatges d'assercio son documentacio gratuita. Utilitza'ls. Missatges d'error personalitzats a les teves assercions son la inversio mes barata que pots fer en productivitat agentica.

*Enfocats en el comportament, no en la implementacio.* Un test que asserta l'estructura interna d'un valor de retorn es trenca quan l'agent refactoritza. Un test que asserta el _comportament_ -- "donada aquesta entrada, obtinc aquesta sortida" -- sobreviu refactoritzacions i dona a l'agent llibertat per trobar millors solucions. Si els teus tests restringeixen la implementacio massa estrictament, l'agent no pot millorar-la.

La prova de foc: si mostressis nomes el fitxer de tests a un enginyer competent sense cap altre context, podria escriure una implementacio correcta? Si es que si, aquells tests funcionaran be per a un agent. Si es que no -- si els tests son massa vagues, massa acoblats, o massa intermitents per servir com a especificacio fiable -- arregla els tests abans de donar-los a l'agent.

== La Questio de la Cobertura

"Quanta cobertura de tests necessito per a treball agentic efectiu?"

L'instint es dir 100%. Cobertura completa. Cada linia, cada branca, cada cami. Pero aixo no es ni practic ni necessari. El que realment necessites es cobertura _dirigida_: prou perque l'agent pugui verificar la cosa especifica que esta canviant.

Pensa-ho aixi. Si demanes a un agent que modifiqui el modul de processament de pagaments, necessites cobertura de tests solida del processament de pagaments. No necessites necessariament cobertura completa del sistema de plantilles d'email, el panell d'administracio, o la funcionalitat d'exportacio a CSV. L'agent necessita tests al voltant del codi que esta tocant, mes prou tests d'integracio per confirmar que no ha trencat les interficies entre sistemes.

Aixo porta a una estrategia practica: _cobreix primer els camins calents._ Mira on apuntaras realment els agents. La teva logica de negoci central. Els teus contractes d'API. Les teves transformacions de dades. Aquestes son les arees que necessiten tests rigurosos -- no per objectius de qualitat abstractes, sino perque aquestes son les arees on treballaran els agents.

Les metriques de cobertura poden fins i tot ser engannyoses. Una base de codi amb 90% de cobertura de linies pero sense tests al flux de pagament es pitjor, per a proposits agentics, que una base de codi amb 40% de cobertura que testa exhaustivament pagaments, autenticacio i la capa d'API. L'agent no necessita una insignia de cobertura. Necessita tests alla on passa la feina.

Dit aixo, els tests d'integracio tenen un valor desproporcionat. Un test unitari diu a l'agent "aquesta funcio funciona aillada." Un test d'integracio diu a l'agent "aquests components funcionen junts." Quan un agent canvia una funcio, els tests unitaris detecten regressions locals i els tests d'integracio detecten efectes ondulatoris. Tots dos importen, pero si parteixes de zero, els tests d'integracio et donen mes per l'esforc perque verifiquen les _costures_ -- els llocs on les coses tendeixen a trencar-se.

Una cosa mes: no oblidis els tests negatius. Tests que verifiquen que el teu sistema _rebutja_ entrada dolenta son critics per als agents. Sense ells, un agent pot "simplificar" la teva logica de validacio, fer que tots els tests positius passin, i deixar-te amb un sistema que accepta escombraries. Si tens una regla de validacio, testa ambdos costats.

== La Velocitat Importa

Quan un agent itera en un bucle de tests, la velocitat de la teva suite de tests afecta directament la productivitat. Una suite de tests que triga deu minuts a executar-se vol dir que l'agent espera deu minuts entre intents. Una suite de tests que triga deu segons vol dir que l'agent pot provar desenes d'enfocaments en el temps que trigues a buscar cafe.

Aixo crea un incentiu fort per a:
- Mantenir els tests unitaris rapids i aillats
- Separar tests rapids de tests d'integracio lents
- Utilitzar modes de vigilancia que re-executen nomes els tests afectats
- Invertir en infraestructura de tests de la mateixa manera que inverteixes en CI

Els tests rapids ja no son nomes una millora d'experiencia del desenvolupador. Son infraestructura d'agents.

Practicament, aixo vol dir que vols una estrategia de tests en capes. Una suite unitaria rapida que s'executa en segons -- el bucle intern de l'agent. Una suite d'integracio mitjana que s'executa en un minut -- l'agent l'executa abans de donar la tasca per acabada. I una suite end-to-end lenta que s'executa a CI -- la verificacio final abans de fusionar.

Digues als teus agents quina suite utilitzar. "Executa `pytest tests/unit` despres de cada canvi. Executa `pytest tests/integration` quan creguis que has acabat." Aixo mante el bucle intern rapid alhora que detecta problemes d'integracio abans que arribin a tu.

== Testejar Mes Enlla del Codi

Els agents no nomes escriuen codi d'aplicacio. Escriuen configuracions d'infraestructura, scripts de desplegament, documentacio i mes. Cadascun d'aquests pot -- i hauria de -- tenir alguna forma de verificacio automatitzada.

*La verificacio de tipus* es el bucle de retroalimentacio mes rapid que pots donar a un agent. Un error de tipus apareix en mil·lisegons, abans que s'executi ni un sol test. En llenguatges tipats, o en Python amb mypy, o en JavaScript amb TypeScript, la verificacio de tipus detecta una classe enorme d'errors instantaniament. L'agent renomena un camp, i el verificador de tipus marca immediatament cada lloc que referencia el nom antic. Aixo es un bucle de retroalimentacio mes ajustat del que qualsevol suite de tests pot proporcionar.

*El linting i el formatat* detecten una altra classe de problemes. Una regla d'ESLint mal configurada podria semblar una molestia menor, pero per a un agent, una fallada de lint es un senyal inequivoc. "El teu import no es fa servir." "Aquesta variable esta declarada pero mai es llegeix." Son correccions diminutes que s'acumulen en codi mes net sense esforc per la teva part.

*La validacio d'esquemes* per a contractes d'API assegura que els canvis de l'agent no trenquen la interficie entre serveis. Si tens especificacions OpenAPI, definicions de JSON Schema, o definicions de tipus GraphQL, valida contra elles. Un agent que canvia un payload de resposta apendra immediatament que ha violat el contracte, en lloc de descobrir la ruptura quan un servei downstream peti a staging.

*Els tests de contracte* entre serveis van mes enlla. Si el servei A depen de l'API del servei B, un test de contracte verifica que B encara satisfa el que A espera -- sense necessitat d'executar ambdos serveis simultaneament. Quan un agent modifica el servei B, els tests de contracte detecten canvis trencadors que els tests unitaris dins de B passarien per alt completament.

*La validacio de fitxers de configuracio* esta criminalment infrautilitzada. Un lint de YAML als teus manifests de Kubernetes. Un terraform validate al teu codi d'infraestructura. Un docker-compose config check. Triguen segons a executar-se i detecten errors que d'altra manera apareixerien com a fallades misterioses durant el desplegament. Cada comprovacio automatitzada que afegeixes es un altre senyal que l'agent pot utilitzar per autocorregir-se.

L'enginyer agentic pensa sobre la testabilitat de manera amplia: no "la meva funcio retorna el valor correcte?" sino "puc verificar automaticament que aquest canvi es correcte?"

== Quan els Tests Enganyen

Una suite de tests dolenta es pitjor que cap suite de tests. Aixo es incomode pero val la pena reflexionar-hi.

Sense tests, l'agent sap que vola a cegues. Sera conservador. Et dira que no pot verificar els seus canvis. Revisaras amb mes cura. La manca de senyal es almenys una manca de senyal honesta.

Amb tests dolents, l'agent vola amb falsa confianca. Fa un canvi, els tests passen, i reporta exit. Tu veus verd i relaxes la teva revisio. Pero els tests no estaven verificant realment el que tocava.

Aixo passa de diverses maneres previsibles.

*Tests que testen el mock, no el codi.* Quan el teu test mockeja la base de dades, el client HTTP, el sistema de fitxers i la cua -- i despres asserta que la funcio mockeada es va cridar amb els arguments correctes -- estas testejant la configuracio del test, no la logica de la teva aplicacio. Un agent pot fer que el codi "real" faci absolutament qualsevol cosa i el test seguira passant, mentre les expectatives del mock es compleixin. Aquests tests proporcionen un senyal verd que no significa res.

*Tests massa flexibles.* `assert response.status_code == 200` et diu que l'endpoint no ha petat. No et diu que la resposta contigui les dades correctes. Un agent podria retornar un cos buit, les dades de l'usuari equivocat, o una resposta a la qual li falten la meitat dels camps, i aquella assercio seguiria passant. L'especificitat a les assercions es especificitat al senyal de retroalimentacio.

*Tests que dupliquen la implementacio.* Si el teu test essencialment reimplementa la funcio sota test i comprova que ambdos retornen el mateix, no verifica res. L'agent pot canviar la implementacio i el test junts -- i ho fara, si creu que haurien de coincidir. Acabes amb codi i tests que estan d'acord entre ells pero no amb la realitat.

Aixo connecta directament amb el patro de "Resposta Incorrecta amb Confianca" del capitol d'histories de guerra. L'agent que va afegir un `time.Sleep(500)` per arreglar una condicio de carrera? Els tests van passar. Van passar perque l'entorn de test tenia baixa concurrencia on 500ms sempre era suficient. Els tests eren _tecnicament correctes_ pero _practicament engannyosos_. Van donar un senyal verd per a un arreglament que fallaria sota carrega de produccio.

La defensa es directa pero requereix disciplina. Revisa els teus tests amb el mateix rigor amb el que revises el teu codi. Pregunta: "Si l'agent introduis un bug subtil, aquest test el detectaria?" Si la resposta es no, el test es mobiliari -- fa que l'habitacio sembli ocupada pero realment no fa res.

== El Cercle Virtuos

Quan ho poses tot junt -- bons tests, retroalimentacio rapida, entorns sandbox, i un agent al bucle -- alguna cosa fa clic.

L'agent agafa una tasca. Llegeix els tests existents per entendre el comportament esperat. Fa un canvi. Executa la suite de tests rapida -- deu segons. Dues fallades. Llegeix els missatges d'error, enten el problema, ajusta. Torna a executar. Verd. Escriu nous tests per al nou comportament. Executa la suite d'integracio completa -- un minut. Tot verd. Commiteja amb un missatge descriptiu, i et dona un diff que saps que passa cada comprovacio automatitzada del teu sistema.

Revises un diff que saps que passa tots els tests. La teva feina canvia de "comprovar si funciona" a "comprovar si es l'enfocament correcte." Aixo es un us molt millor del teu temps, i un us molt millor de la teva experiencia. Ja no ets un executor de tests huma. Ets un arquitecte revisant dissenys.

I aqui esta l'efecte compost. Cada vegada que un agent treballa a la teva base de codi i la suite de tests l'ajuda a tenir exit, has demostrat el valor d'aquells tests. Cada vegada que un test absent causa un bug, sents el dolor immediatament -- i afegeixes el test. La teva suite de tests creix exactament als llocs que importen, guiada per retroalimentacio real de treball agentic real.

Aixo es el cercle virtuos de l'enginyeria agentica: millors tests porten a agents mes autonoms, que porten a iteracio mes rapida, que et dona mes temps per escriure millors tests. Cada torn del cicle fa el seguent mes rapid.

Els enginyers que trauran mes profit de les eines agentiques no son els que tenen els prompts mes llestos o els models mes potents. Son els que tenen les millors suites de tests. Una base de codi ben testejada es un multiplicador de forca que es composa amb cada tasca que dones a un agent. Una base de codi sense tests es un impost que fa cada tasca mes lenta i arriscada.

Si t'emportes una cosa d'aquest capitol, que sigui aixo: abans d'optimitzar els teus prompts, abans d'experimentar amb nous models, abans de construir orquestracio elaborada -- ves a escriure tests. Escriu-los per al codi que els teus agents tocaran. Fes-los rapids, deterministics, aillats i especifics. Aquesta inversio rendira mes que qualsevol altra cosa d'aquest llibre.

La teva suite de tests no es sobrecost. Es la base sobre la qual es construeix tota la resta.
