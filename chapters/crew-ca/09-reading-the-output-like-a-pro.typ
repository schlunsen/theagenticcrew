= Llegir la Sortida com un Professional

#figure(
  image("../../assets/illustrations/crew/ch09-reading-output.jpg", width: 80%),
  caption: [_Confia, però verifica._],
)

Un agent mai et dira que s'equivoca. No sap que s'equivoca. Produeix sortides amb la mateixa confianca tant si es perfectament precis com si esta completament inventat. La teva feina -- l'habilitat que separa un usuari productiu d'agents d'un de perilllos -- es aprendre a llegir la sortida amb escepticisme saludable.

Aixo no va de desconfianca. Va de confianca _calibrada_. Un bon editor confia en els seus escriptors pero tot i aixi comprova els fets. Un bon gestor confia en el seu equip pero tot i aixi revisa els lliurables. Tu ets l'editor. Tu ets el gestor. L'agent es un membre de l'equip molt rapid, molt segur de si mateix, que de vegades s'inventa coses.

== Al.lucinacions

El terme tecnic es "al.lucinacio" -- quan un agent produeix informacio que sona plausible pero es factualment incorrecta. Es el mode de fallada mes important d'entendre perque es el mes dificil de detectar.

Una al.lucinacio no es un error aleatori. Es un error _plausible_. L'agent no diu "els ingressos eren de color lila." Diu "els ingressos del Q2 van ser de 2,3 milions d'euros" quan la xifra real es de 2,1 milions. No cita una font que obviament no existeix -- cita una que _sona_ com si hagues d'existir. No inventa una afirmacio estranya -- exposa alguna cosa que encaixa perfectament en la narrativa, nomes que resulta ser falsa.

Per aixo les al.lucinacions son perilloses: passen la prova de l'olfacte. Llegeixes la sortida, sona raonable, i passes endavant. L'error es propaga al teu informe, la teva presentacio, la teva decisio.

== La Llista de Verificacio

Per a qualsevol sortida d'agent que importi, repassa aixo:

*Numeros:* D'on venen? Pots rastrejar-los fins a les dades originals? Si l'agent diu "les vendes van creixer un 15%," comprova les dades reals. No confiis en percentatges, totals o estadistiques sense verificacio.

*Noms i dates:* Els agents sovint es confonen lleugerament amb els detalls. La persona correcta pero la data equivocada. L'empresa correcta pero el producte equivocat. L'estadistica correcta pero de l'any equivocat. Comprova puntualment els detalls concrets.

*Afirmacions i fets:* Si l'agent exposa alguna cosa com a fet, pregunta't -- es alguna cosa que jo ja se que es certa, o ho estic aprenent de l'agent? Si ho estas aprenent de l'agent, verifica-ho. Una cerca rapida al web, una comprovacio amb els teus propis registres, una consulta rapida amb un company.

*Fonts i citacions:* Si l'agent cita una font, comprova que la font existeix i que realment diu el que l'agent afirma que diu. Els agents son famosos per citar publicacions que sonen reals amb contingut fabricat, o per citar publicacions reals pero tergiversant el que diuen.

*Completesa:* La sortida omet alguna cosa obvia? Els agents tendeixen a produir feina d'aspecte plausible que cobreix el 80% del que vas demanar. El 20% que falta sovint es la part que hauria revelat un problema.

== La Trampa de la Confianca

Els agents expressen tot amb el mateix nivell de confianca. "La reunio es a les 3" i "la reunio es a les 3" es veuen identic tant si l'agent ho llegeix del teu calendari com si ho endevina basant-se en el teu horari habitual.

No hi ha cursiva per a la incertesa. No hi ha "crec" o "no estic segur." La sortida arriba com si fos un fet, cada vegada.

Aixo significa que no pots confiar en el _to_ de l'agent per avaluar la precisio. Has de desenvolupar el teu propi sentit sobre quins tipus de sortides son probablement precises i quines necessiten comprovacio:

*Confianca alta (normalment fiable):*
- Formatar i reestructurar dades existents que has proporcionat
- Seguir instruccions explicites ("ordena aquesta llista alfabeticament")
- Fer calculs amb dades que li has donat
- Resumir un document que has proporcionat

*Confianca mes baixa (verifica sempre):*
- Afirmacions factuals sobre el mon (dates, estadistiques, esdeveniments actuals)
- Qualsevol cosa que impliqui esdeveniments recents (l'entrenament del model te una data de tall)
- Numeros concrets que no ha calculat a partir de dades que has proporcionat
- Consells legals, medics o financers
- Afirmacions sobre el que hi ha en un document que realment no ha llegit

== Crear l'Habit

La verificacio no hauria de sentir-se com una carrega. Hauria de sentir-se com una correccio de proves -- un repas natural i rapid de la sortida abans de fer-la servir.

Per a tasques de baix risc (redactar un missatge intern, organitzar notes), un cop d'ull rapid n'hi ha prou. Ha capturat els punts clau? El to sembla correcte? Prou bo.

Per a tasques de risc mitja (un informe per a un client, una analisi de dades), comprova els numeros i les afirmacions clau. Rastreja almenys un o dos fets fins a la seva font. Llegeix-ho tot com si ho hagues escrit algu altre i tu fossis el revisor.

Per a tasques d'alt risc (una presentacio per a la junta, una projeccio financera, un document legal), verifica-ho tot. Tracta la sortida de l'agent com un primer esborrany que necessita comprovacio de fets, no com un producte acabat. Si no ho publicaries sense comprovar-ho quan ho ha escrit un huma, no ho publiquis sense comprovar-ho quan ho ha escrit un agent.

L'objectiu no es no confiar mai en l'agent. L'objectiu es confiar-hi _adequadament_ -- amb entusiasme per allo que fa be, amb precaucio per allo que fa menys be, i mai a cegues.
