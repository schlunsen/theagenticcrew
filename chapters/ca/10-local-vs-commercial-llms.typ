= LLMs Locals vs. LLMs Comercials

Un amic meu -- enginyer senior a una startup de Serie B -- em va enviar un missatge un divendres a la tarda. "Acabo de rebre la nostra primera factura real de l'API. Dos mil dos-cents dolars. Pel _marc_." Havia estat executant Claude Code a tot el seu equip de vuit enginyers, cadascun d'ells iterant en funcionalitats, depurant, refactoritzant. Ningu havia configurat pressupostos de tokens. Ningu vigilava el comptador. Els agents funcionaven de meravella, i la factura feia mal als ulls.

Aquella mateixa setmana, vaig parlar amb una enginyera d'una empresa sanitaria a Munich. Executava Llama 70B en un servidor GPU local perque el seu pipeline de dades de pacients no podia tocar APIs externes. No "no hauria de" -- _no podia_. El seu equip de compliment normatiu ho havia deixat clar per escrit. Obtenia resultats decents per a tasques enfocades, pero cada vegada que necessitava raonament complex multi-fitxer, el model fallava i es trobava fent la feina manualment.

Aquestes dues histories son els extrems de la mateixa pregunta: on s'executa el model? Sona com una decisio d'infraestructura. Realment es una decisio sobre confianca, cost, capacitat, i -- cada vegada mes -- com arquitectures tot el teu flux de treball agentic.

== LLMs Comercials: La Frontera

Els models comercials -- Claude, GPT, Gemini -- son on viu la frontera. Si estas fent enginyeria agentica seria, probablement has passat la majoria del teu temps aqui. Hi ha bones raons per aixo.

=== Finestres de Context

El context ho es tot per als agents. Un agent no nomes llegeix el teu prompt -- llegeix fitxers, sortides d'eines, missatges d'error, resultats de tests, i el seu propi raonament anterior. Una sola tasca complexa pot omplir facilment 50.000 tokens de context, i una sessio de depuracio multi-pas pot superar els 100.000.

Els models comercials de frontera ofereixen finestres de context de 128K tokens i mes. Aixo importa enormement per al treball agentic perque l'agent necessita mantenir la teva base de codi al cap. Quan el context s'esgota, l'agent comenca a oblidar fitxers anteriors que va llegir, decisions anteriors que va prendre, errors anteriors que va veure. Es degrada d'un enginyer capac a algu amb amnesia.

Els models locals generalment arriben a un maxim de 8K-32K de context a la practica, fins i tot si tecnicament suporten mes sobre el paper. La qualitat de l'atencio es degrada a mesura que empenys cap al limit. Un model comercial a 100K de context segueix raonant be. Un model local a 32K de context sovint perd el fil.

=== Qualitat d'Us d'Eines

Els agents viuen i moren per l'us d'eines. Llegir fitxers, escriure codi, executar comandes, buscar a bases de codi -- no son extres opcionals. Son el bucle central. I la qualitat de l'us d'eines varia dramaticament entre models.

Els models comercials de frontera han estat especificament entrenats i ajustats per a crides d'eines. Formaten arguments correctament, encadenen crides d'eines logicament, es recuperen graciosament quan una crida d'eina falla. Saben quan llegir un fitxer abans d'editar-lo. Saben quan executar tests despres de fer canvis.

Els models mes petits -- incloent la majoria de models locals -- son menys fiables aqui. Al·lucinaran camins de fitxers, oblidaran passar arguments requerits, cridaran eines en l'ordre incorrecte, o es quedaran atrapats en bucles cridant la mateixa eina fallida una i altra vegada. La diferencia no es subtil. En una tasca complexa que involucra deu o quinze crides d'eines, un model de frontera podria tenir exit el 90% de les vegades on un model local te exit el 40%.

=== Seguiment d'Instruccions

Quan dius a un model de frontera "nomes modifica fitxers al directori `src/auth/`" o "no canviis l'API publica, nomes la implementacio interna," generalment escolta. Segueix system prompts, respecta restriccions, i es mante dins dels limits.

Els models mes petits deriven. Comencaran be, despres gradualment ignoraran les teves restriccions a mesura que la conversa es fa mes llarga i el context s'omple. Aixo es un problema real per al treball agentic, on la precisio importa. Un agent que "majoritariament" segueix instruccions ocasionalment reescriura un fitxer que no li has demanat que toqui, o refactoritzara alguna cosa que explicitament li has dit que deixi. En un entorn sandbox aixo es nomes molest. Sense sandbox es perillos.

=== Triant el Model Comercial Correcte

No tots els models comercials son intercanviables, ni tan sols a la frontera. Aqui tens el que he trobat a la practica:

*Per a refactoritzacions complexes multi-fitxer i treball arquitectonic* -- utilitza el model mes capac que et puguis permetre. Aqui es on la qualitat del raonament importa mes. La diferencia de cost entre un model de gamma mitjana i un de gamma alta es uns quants dolars per tasca. La diferencia de qualitat sovint es la diferencia entre un diff net i un embolic que has de refer manualment.

*Per a tasques enfocades d'un sol fitxer* -- escriure tests, implementar una funcio ben definida, arreglar un bug clar -- els models de gamma mitjana funcionen gairebe tan be com els de gamma alta, a una fraccio del cost. La tasca es prou acotada perque el model no necessita fer malabars amb moltes preocupacions alhora.

*Per a treball d'alt volum i baixa complexitat* -- generar boilerplate, formatar codi, escriure missatges de commit -- el model mes barat que pugui seguir instruccions es la tria correcta. Executaras aquestes tasques centenars de vegades. L'estalvi per token es composa.

L'error que veig mes sovint es utilitzar un sol model per a tot. Aixo es com conduir un Formula 1 al supermercat. Fes coincidir el model amb la tasca.

== LLMs Locals: La Imatge Completa

Executar un model localment -- Llama, Mistral, Qwen, DeepSeek, Codestral, o qualsevol dels models de pesos oberts via Ollama, llama.cpp, o vLLM -- et dona alguna cosa que les APIs comercials no poden: sobirania de dades completa i zero cost marginal per token.

El teu codi mai surt de la teva maquina. Pots alimentar-lo amb codi font propietari, documents interns, logs de produccio, dades de clients, claus d'API que has deixat accidentalment en una configuracio -- res d'aixo creua un limit de xarxa. I un cop el model esta descarregat, cada inferencia es gratuita. Executa'l mil vegades, executa'l tota la nit, ningu t'envia una factura.

Pero siguem honestos sobre l'experiencia, perque el marketing al voltant dels models locals sovint no ho es.

=== La Realitat del Hardware

La questio del hardware es la primera que tothom pregunta, i la resposta es menys glamurosa del que els articles de blog de "executa IA localment!" suggereixen.

*MacBook Pro amb Apple Silicon (M2/M3/M4 Pro o Max, 32-64GB de RAM).* Aixo es el punt optim per a desenvolupadors individuals. Pots executar un model de 7B-14B parametres comodament, i un model de 32B si tens la RAM. La inferencia sera notablement mes lenta que una API comercial -- potser 15-30 tokens per segon per a un model de 14B, comparat amb 80+ d'una API comercial. Un model de 70B tecnicament funcionara en una maquina de 64GB pero sera prou lent per posar a prova la teva paciencia. Esperaras 10-20 segons per respostes que triguen 2 segons des d'una API.

*Servidor GPU dedicat (NVIDIA RTX 4090 o A100).* Aqui es on la inferencia local es torna genuinament rapida. Una 4090 amb 24GB de VRAM pot executar un model de 14B a velocitats properes a les comercials. Una A100 amb 80GB pot executar un model de 70B comodament. Pero ara estas mantenint hardware. Estas lluitant amb drivers de CUDA, gestio de VRAM, i l'ocasional "per que crida el ventilador de la meva GPU a les 3 de la matinada."

*Hardware de consum (MacBook Air de 16GB, maquines antigues, sense GPU dedicada).* Estas limitat a models de 7B, i l'experiencia sera mediocre. La inferencia es lenta, els models son massa petits per a treball agentic seri, i passaras mes temps esperant que treballant. No ho recomanaria per a res mes enlla de l'experimentacio.

El resum honest: els models locals son practics per a desenvolupadors amb un MacBook Pro recent o una GPU dedicada. Per sota d'aquell llindar de hardware, tindras una experiencia frustrant. Per sobre, tindras una eina genuinament util -- nomes una eina diferent d'una API comercial.

=== On Brillen els Models Locals

Els models locals no son simplement "models comercials pitjors." Hi ha fluxos de treball on genuinament tenen mes sentit:

*Tasques d'alta frequencia i baix risc.* Generar docstrings, escriure missatges de commit, crear codi boilerplate, formatar dades. Aquestes tasques no necessiten un model geni -- necessiten un model rapid i gratuit. Executar-les localment vol dir que pots disparar-i-oblidar sense pensar en el cost.

*Bases de codi sensibles.* Ho cobrirem mes a la seccio de privacitat, pero aixo es un cas d'us legitim i creixent. Si el teu codi no pot sortir de la teva xarxa, els models locals son l'unica opcio, i "prou bo" es infinitament millor que "no disponible."

*Desenvolupament offline.* En un avio, en un tren, en un bunquer -- el teu model local funciona sense WiFi. Aixo sona menor fins que estas en un vol de dotze hores intentant depurar alguna cosa.

*Experimentacio i aprenentatge.* Quan estas experimentant amb frameworks d'agents, provant estrategies de prompts, o construint integracions d'eines personalitzades, cremar credits d'API en assaig-error se sent malbaratat. Un model local et permet iterar lliurement.

=== On Pateixen els Models Locals

Val la pena ser especific sobre els modes de fallada, perque "es menys capac" es massa vague per ser util.

*Raonament multi-fitxer.* Demana a un model local de 14B que segueixi un bug a traves de quatre fitxers i un esquema de base de dades, i perdra el fil. Podria trobar el fitxer correcte pero malinterpretar la interaccio entre components. Aquesta es la diferencia practica mes gran.

*Tasques de llarg recorregut.* Les tasques agentiques que involucren molts passos -- llegir, planificar, implementar, testejar, depurar, iterar -- requereixen que el model mantingui una intencio coherent a traves d'un context llarg. Els models locals tendeixen a derivar. Obliden el pla. Revisiten decisions que ja havien pres. Es queden atrapats en bucles.

*Revisio de codi matisada.* "Aquest codi es correcte pero l'enfocament es equivocat" es una decisio de judici que requereix comprensio profunda. Els models locals tendeixen cap a l'analisi superficial -- detectaran problemes de sintaxi i bugs obvis pero passaran per alt problemes arquitectonics.

*Orquestracio d'eines complexa.* Quan una tasca requereix deu o mes crides d'eines encadenades -- llegir un fitxer de test, executar-lo, llegir l'error, trobar el fitxer font, entendre el context, fer un canvi, tornar a executar el test -- els models locals tropessen mes frequentment a cada pas, i la taxa d'error es composa.

Res d'aixo vol dir que els models locals siguin inutilitzables. Un model de 32B executant-se localment pot gestionar un rang sorprenent de tasques ben acotades. Pero necessites acotar les tasques en consequencia. Demanar a un model local que faci el que fa un model de frontera es preparar-lo per al fracas.

== El Cost del Treball Agentic

Una sola sessio de codi agentic pot consumir facilment 100.000-500.000 tokens. Aixo sorpren la gent quan veuen els numeros per primera vegada. No perque estiguis xatejant -- perque l'agent esta _treballant_.

Considera que passa quan un agent aborda un arreglament de bug moderadament complex. Llegeix tres o quatre fitxers per entendre el context (potser 8.000 tokens d'entrada). Raona sobre el problema (2.000 tokens de sortida). Llegeix dos fitxers mes (4.000 tokens). Escriu un arreglament (1.000 tokens). Executa els tests (crida d'eina, 500 tokens de sortida). Els tests fallen. Llegeix l'error (1.000 tokens). Revisa l'arreglament (1.500 tokens). Torna a executar els tests. Passen. Llegeix el diff per verificar (1.000 tokens). Total: potser 25.000 tokens per a un arreglament de bug senzill.

Ara considera una tasca de refactoritzacio complexa. L'agent podria llegir vint fitxers, generar un pla, implementar canvis a vuit fitxers, executar la suite de tests quatre vegades, depurar dues regressions, i escriure tests nous. Aixo son facilment 200.000 tokens. Als preus de models de frontera, aixo es entre \$3 i \$15 depenent del model i la ratio entrada/sortida.

Aqui tens rangs de cost aproximats que he vist a la practica, basats en l'us de models comercials de frontera:

- *Arreglament de bug simple o funcionalitat petita:* \$0.30-\$1.00
- *Funcionalitat moderada amb tests:* \$2-\$5
- *Refactoritzacio complexa multi-fitxer:* \$5-\$15
- *Implementacio de funcionalitat gran:* \$15-\$40+
- *Sessio de depuracio exploratoria que s'allarga:* \$10-\$30

Multiplica aquests numeros per un equip d'enginyers, cadascun executant diverses tasques agentiques per dia, i estas mirant diners reals. La factura de \$2.200 del meu amic? Es mes o menys correcta per a vuit enginyers actius.

=== Estrategies per Gestionar el Cost

La solucio no es deixar d'utilitzar agents. Es ser intel·ligent al respecte.

*Configura pressupostos de tokens.* La majoria de frameworks d'agents et permeten configurar un limit maxim de tokens per tasca. Aixo no es nomes control de costos -- tambe es un senyal de qualitat. Si un agent crema 500.000 tokens en una tasca que n'hauria de trigar 50.000, alguna cosa ha anat malament. L'agent esta atrapat, fent bucles, o malinterpretant la tasca. Un pressupost el forca a fallar rapid en lloc d'espiralar.

*Utilitza routing de models.* No enviis cada tasca al model mes car. Aprofundirem en aixo a la propera seccio, pero la versio curta: utilitza un model barat i rapid per a exploracio i lectura de codi, i un model car i capac per a raonament i implementacio. Aixo sol pot reduir costos un 50-70%.

*Cacheja agressivament.* Si el teu framework d'agents suporta cache de prompts, activa-ho. Molt del context d'un agent es repeteix entre torns -- el mateix system prompt, el mateix context del projecte, els mateixos fitxers llegits recentment. El caching evita re-processar aquells tokens a cada torn.

*Acota les tasques estretament.* Una tasca ben acotada ("arregla el bug de zona horaria a `billing/invoice.py`, el test es a `tests/test_invoice.py`") es mes barata que una de vaga ("arregla els bugs de facturacio"). Acotar no es nomes bona enginyeria -- es control de costos. L'agent llegeix menys fitxers, fa menys crides d'eines exploratories, i convergeix mes rapid.

*Revisa els teus fracassos.* Quan una tasca falla o consumeix massa tokens, esbrina per que. El prompt era vague? Faltava context a l'agent? El model no era prou capac per a la tasca? Cada fracas es una oportunitat d'ajustament.

=== Gestionar Costos a Traves d'un Equip

El control individual de costos es una cosa. Gestionar la despesa a traves d'un equip de vuit o dotze enginyers, cadascun executant agents tot el dia, es un problema completament diferent. Es la diferencia entre vigilar la teva propia dieta i gestionar una cuina de restaurant.

*Pressupostos per enginyer.* Configura un pressupost mensual de tokens per enginyer -- no per restringir, sino per fer els costos visibles. Quan tothom pot veure la seva propia despesa, el comportament canvia naturalment. La gent comenca a acotar tasques mes curosament, a triar el model correcte per a la feina, a matar sessions desbocades mes aviat. Un punt de partida raonable: \$200-400 al mes per enginyer per a un equip que utilitza activament agents. Alguns enginyers vindran consistentment per sota del pressupost. Altres tindran pics durant setmanes intenses de depuracio. Aixo esta be -- la qüestio es la consciencia, no l'aplicacio.

*Dashboard i visibilitat.* No pots gestionar el que no pots veure. Fes seguiment de la despesa per enginyer, per projecte, per tipus de tasca. La majoria de proveiors d'APIs et donen desglossos d'us per clau d'API, i si assignes claus per enginyer o per projecte, les dades ja hi son. Canalitza-ho cap a un dashboard que l'equip pugui veure -- fins i tot un full de calcul compartit funciona per comencar. L'enginyer que descobreix que va cremar \$80 en una sola sessio de depuracio naturalment comencara a acotar tasques mes estretament la propera vegada. No necessites tenir-ne una conversa. El numero parla sol.

*Alertes i interruptors automatics.* Configura alertes al 50% i 80% del pressupost mensual perque ningu es porti sorpreses. Mes important, configura un limit dur de tokens per sessio com a interruptor automatic. Si una sola sessio d'agent supera els 500K tokens, alguna cosa ha anat malament -- l'agent esta fent bucles, la tasca es massa vaga, o el model esta lluitant amb alguna cosa mes enlla de la seva capacitat. Mata-la i investiga. Aixo es el que preveu l'escenari de "factura sorpresa de \$2.200" del principi d'aquest capitol. No necessites detectar cada sessio desbocada manualment. Els limits automatitzats fan la feina.

*La conversa del ROI.* En algun moment, algu de la direccio preguntara per que la factura de l'API es de cinc xifres. Necessites les matematiques preparades. Emmarca-ho aixi: un enginyer senior costa \$150K a l'any completament carregat. Si els agents el fan un 30% mes productiu, son \$45K de valor. Els costos dels agents son \$3-4K a l'any per enginyer. El ROI es aproximadament 10x. Fins i tot si ets conservador -- diguem un 15% de guany de productivitat en lloc de 30% -- els numeros segueixen funcionant comodament. La part mes dificil es mesurar aquell guany de productivitat amb precisio. Probablement no pots, no amb rigor cientific. Pero pots fer seguiment de senyals concretes: temps fins a fusionar PRs, nombre de tasques completades per sprint, reduccio del canvi de context. Combina aquelles metriques amb les dades de cost i tens una historia amb la qual finances pot treballar.

*El cost com a senyal de qualitat.* Un consum alt de tokens en una tasca no es nomes car -- es un senyal que alguna cosa ha anat malament. La tasca estava mal acotada, el context era insuficient, o el model no era prou capac per a la feina. Comenca a fer seguiment del cost per tipus de tasca al llarg del temps. Si els costos d'una categoria particular tendeixen a l'alca, investiga -- els teus prompts poden haver derivat, o la base de codi s'ha tornat prou complexa per necessitar un enfocament diferent. Si els costos tendeixen a la baixa, es que el teu equip esta millorant en enginyeria agentica. Estan escrivint prompts mes ajustats, triant millors models, i acotant tasques mes efectivament. Les dades de cost, ben utilitzades, es converteixen en un mirall de l'habilitat de l'equip.

== Privacitat i Compliment Normatiu

Hi ha codi que genuinament no pot sortir de l'edifici. Aixo no es paranoia -- es llei.

Contractistes governamentals treballant en projectes classificats o de control d'exportacio no poden enviar codi font a APIs de tercers, punt. Els requisits de residencia de dades no son suggeriments. Venen amb penalitats criminals.

Empreses sanitaries que gestionen dades de pacients estan vinculades per HIPAA, GDPR, o regulacions equivalents. Si el teu codi toca registres de pacients -- fins i tot fixtures de test amb dades falses realistes que un responsable de compliment podria mirar amb desconfianca -- necessites pensar curosament sobre que envia per la xarxa.

Les institucions financeres tenen el seu propi laberint de regulacions. Compliment SOX, PCI-DSS, requisits d'auditoria interna -- els detalls varien, pero el tema es consistent: les dades es queden dins de limits controlats.

I despres hi ha la simple competitivitat i secret. Els teus algoritmes propietaris, la teva salsa secreta, el teu avantatge competitiu -- enviar-ho als servidors d'algu altre requereix confiar que no ho entrenaran, no ho registraran, no seran vulnerats. La majoria de proveiors d'APIs comercials ofereixen garanties contractuals fortes al respecte. Pero "garanties contractuals fortes" i "impossible de vulnerar" son coses diferents, i alguns equips de seguretat no estan disposats a acceptar la diferencia.

Per a tots aquests casos, els models locals no son un luxe. Son l'unica opcio.

L'equilibri es real: estas acceptant capacitat del model reduida a canvi de control absolut de les dades. Un model local de 32B fent una feina mediocre a la teva base de codi classificada es infinitament mes util que un model de frontera que no tens permes d'utilitzar. I per a tasques enfocades i ben acotades -- el tipus que hauries d'estar escrivint de totes maneres -- la diferencia de qualitat sovint es menor del que esperaries.

=== El Terme Mig: Desplegaments Privats

Val la pena mencionar que hi ha un cami intermedi emergent. Els proveiors de cloud ara ofereixen desplegaments de models privats -- instancies dedicades de models de frontera executant-se dins del teu VPC, amb garanties contractuals que les teves dades es queden dins el teu perimeter i no s'utilitzen per a entrenament. AWS Bedrock, Azure OpenAI, Google Cloud Vertex AI tots ofereixen versions d'aixo.

No son barats. Estas pagant per compute dedicat, no per infraestructura d'API compartida. Pero per a grans organitzacions que necessiten capacitat de frontera i control estricte de dades, aixo es cada vegada mes la resposta. Obtens qualitat de model comercial amb garanties de privacitat de model local -- per un preu.

== Model Routing a la Practica

La pregunta real no es "local o comercial?" Es "quin model, per a quina part del flux de treball?"

Una configuracio agentica sofisticada encamina parts diferents del flux de treball a models diferents. Aixo no es teoric -- equips ho estan fent avui, i es la direccio cap a la qual es mou l'ecosistema.

=== El Patro de Routing

Pensa en el que un agent realment fa durant una tasca tipica:

+ *Exploracio* -- llegir fitxers, buscar a la base de codi, entendre l'estructura. Aixo es treball d'alt volum i baix raonament. El model necessita decidir quins fitxers llegir i extreure informacio rellevant, pero no esta fent pensament profund.

+ *Planificacio* -- analitzar el problema, considerar enfocaments, decidir una estrategia. Aixo requereix raonament fort. Es la part on la qualitat del model importa mes.

+ *Implementacio* -- escriure els canvis de codi reals. Aixo requereix bona generacio de codi i la capacitat de seguir el pla del pas 2.

+ *Verificacio* -- executar tests, llegir errors, decidir si la feina esta feta. Raonament moderat, us intens d'eines.

+ *Iteracio* -- si la verificacio falla, tornar enrere i ajustar. Aixo requereix entendre l'error i connectar-lo amb la implementacio.

No tots aquests passos necessiten el mateix model. El pas 1 pot ser gestionat per un model petit, rapid i barat -- fins i tot un de local. Esta llegint fitxers i reportant que hi ha. El pas 2 es on vols el model de frontera -- aquest es el raonament car que justifica el cost de l'API. Els passos 3-5 sovint poden ser gestionats per un model de gamma mitjana, ja que el pensament dificil ja esta fet i el model esta executant un pla.

=== Com Es Veu Aixo

A la practica, el routing de models pot ser tan simple com configurar el teu framework d'agents per utilitzar models diferents per a tipus de tasques diferents:

```
# Pseudocode — the exact config depends on your framework
exploration_model: "local/qwen-14b"       # Free, fast, good enough for reading
reasoning_model: "claude-sonnet"           # Frontier reasoning for planning
implementation_model: "claude-haiku"       # Fast, cheap, follows plans well
```

O pot ser dinamic -- un classificador lleuger que mira el pas actual i encamina en consequencia. Alguns frameworks estan comencant a construir-ho de manera nativa. Altres requereixen que ho cablegis tu mateix.

L'economia es convincent. Si el 60% dels tokens d'un agent es gasten en exploracio i tasques simples, i els encamines a un model que es 10x mes barat, has reduint el teu cost total en mes de la meitat sense cap reduccio de qualitat a les parts que importen.

=== Routing per a Privacitat

El routing de models tambe resol el problema de privacitat de manera mes elegant que un enfocament de tot o res.

Posem que estas construint una aplicacio sanitaria. Els models de dades i la logica de negoci toquen dades de pacients -- aixo ha de quedar-se local. Pero els components de frontend, la configuracio de build, el pipeline de CI? No contenen dades sensibles. No hi ha cap rao per la qual no puguis utilitzar un model comercial de frontera per a les parts no sensibles mentre encamines el treball sensible a un model local.

Aixo requereix eines que siguin conscients dels limits de sensibilitat -- quins fitxers poden sortir a l'exterior, quins no. Aquella eina encara esta madurant, pero el patro es clar. En lloc de "tot local" o "tot comercial," obtens "local on importa, comercial a la resta."

== Comencant Sense Pagar una Fortuna

No necessites un pressupost per comencar a aprendre enginyeria agentica. Necessites un portatil i un vespre. Aqui tens una rampa practica de zero cost a productivitat real.

=== La Capa Gratuita

La majoria de proveiors comercials ofereixen capes gratuites o credits de prova. A principis de 2026, pots comencar amb Claude, GPT, o Gemini sense introduir una targeta de credit. Les capes gratuites estan limitades en taxa i context, pero son mes que suficients per aprendre els fonaments -- escriu el teu primer prompt agentic, mira un agent iterar sobre un test que falla, aconsegueix una sensacio del bucle de retroalimentacio.

Combina una clau d'API de capa gratuita amb un framework d'agents de codi obert -- la capa gratuita de Claude Code, o Aider amb el seu suport de models gratuitis -- i tens una configuracio agentica completa a zero cost. No sera rapida. No gestionara treball complex multi-fitxer. Pero t'ensenyara tot dels capitols dos a cinc d'aquest llibre sense gastar ni un centric.

=== El Cami Local-Primer

Si tens un MacBook Pro amb 16GB o mes de RAM, pots executar models utils localment de franc, per sempre.

Instal·la Ollama -- triga una comanda. Descarrega un model -- `ollama pull qwen2.5-coder:14b` triga uns minuts. Apunta un framework d'agents cap a ell. Ara tens una configuracio de codi agentic sense costos d'API, sense limits de taxa, i sense dades sortint de la teva maquina.

L'experiencia no igualara un model comercial de frontera. Les finestres de context son mes petites. El raonament multi-fitxer es mes feble. L'us d'eines es menys fiable. Pero per a tasques enfocades i ben acotades -- "escriu tests per a aquesta funcio," "refactoritza aquesta classe per fer servir injeccio de dependencies," "afegeix gestio d'errors a aquest endpoint" -- un model local de 14B es sorprenentment capac. I com que es gratuit, pots iterar sense vigilar el comptador.

Un stack de partida practic per a enginyeria agentica de zero cost:
- *Ollama* per servir models (gratuit, local)
- *Qwen 2.5 Coder 14B* o *DeepSeek Coder V2* per a tasques de codi
- *Aider* o *Claude Code* (amb suport de model local) com a framework d'agents
- Un projecte amb una suite de tests (l'agent necessita retroalimentacio)

Ja esta. Sense subscripcio. Sense clau d'API. Sense compute al cloud. Arribaras al sostre eventualment -- una tasca que necessita una finestra de context mes gran, o raonament multi-fitxer que el model local no pot gestionar. Llavors es quan agafes un model comercial. Pero la configuracio gratuita et portara mes lluny del que esperes.

=== El Punt Optim: \$20/Mes

Quan estiguis preparat per gastar diners, la configuracio mes cost-efectiva que he trobat es una combinacio de models locals per a exploracio i una subscripcio comercial per a raonament.

La majoria de proveiors comercials ofereixen un pla de desenvolupador al voltant dels \$20/mes que inclou una assignacio generosa de tokens. Utilitza'l per a les tasques que realment necessiten capacitat de frontera -- depuracio complexa, refactoritzacio multi-fitxer, planificacio arquitectonica. Utilitza el teu model local per a tota la resta -- llegir codi, generar boilerplate, escriure missatges de commit, iterar a traves de cicles de tests.

Aquest enfocament hibrid tipicament cobreix el 80-90% del treball agentic d'un desenvolupador individual. El model local gestiona les tasques d'alt volum i baix raonament. El model comercial gestiona els moments que necessiten intel·ligencia genuina. La teva factura mensual es manté previsible, i no estas triant entre qualitat i cost -- estas utilitzant cadascun on te sentit.

=== Escalant Amb Intencio

L'error es comencar amb l'opcio mes cara i optimitzar despres. Comenca gratuit. Apren els fluxos de treball. Enten on la qualitat del model realment importa i on "prou bo" es prou bo. Despres gasta diners a les brecces especifiques que les eines gratuites no poden omplir.

Quan estiguis gastant diners reals en crides d'API, sabras exactament per que estas pagant -- i mes important, per que _no_ estas pagant. Aquell coneixement val mes que qualsevol quantitat de credits.

== El Paisatge Esta Canviant

D'aqui sis mesos, els detalls d'aquest capitol estaran desfasats. Els numeros de cost canviaran. Les diferencies de capacitat s'escurcaran. Sortira un nou model que reorganitzara el ranking. Aquesta es l'unica prediccio que fare amb confianca.

El que no canviara es el marc per pensar-hi. Seguiras necessitant avaluar models al llarg dels mateixos eixos: capacitat, cost, privacitat, velocitat i fiabilitat. Seguiras necessitant fer coincidir el model amb la tasca en lloc de triar un model i fer-lo servir per a tot. Seguiras necessitant ser flexible.

Els enginyers que veig fent la millor feina no son lleials a cap model o enfocament de desplegament particular. Son pragmatics. Utilitzen el model comercial de frontera quan la tasca ho demana, un model de gamma mitjana quan es prou bo, i un model local quan la privacitat o el cost ho requereix. Mesuren que funciona. Canvien quan apareix alguna cosa millor.

No et tornis religiosa sobre aixo. El model es una eina. L'habilitat es saber per quina eina estirar la ma -- i aquella habilitat es transfereix independentment de quins models existeixin d'aqui sis mesos.
