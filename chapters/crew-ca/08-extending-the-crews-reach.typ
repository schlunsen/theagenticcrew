= Ampliant l'Abast de la Tripulacio

#figure(
  image("../../assets/illustrations/crew/ch08-extending-reach.jpg", width: 80%),
  caption: [_Connectant l'agent amb el món més enllà de la seva finestra._],
)

Un agent que nomes pot llegir i escriure text es util. Un agent que es pot connectar a les teves eines -- el teu calendari, els teus fulls de calcul, la teva aplicacio de gestio de projectes, el teu correu -- es transformador.

Aquest capitol tracta de donar _mans_ al teu agent. No la fontaneria tecnica (el teu desenvolupador se n'encarrega) sino el concepte del que es possible quan un agent pot anar mes enlla de la finestra de conversa i interactuar amb els sistemes que ja fas servir.

== L'Escriptori Buit vs. L'Estacio de Treball Connectada

Recordes la metafora del nou empleat? Una persona intel.ligent sense acces a cap sistema es nomes algu assegut davant d'un escriptori buit. Dona-li acces al teu calendari i podra programar reunions. Dona-li acces al teu CRM i podra actualitzar registres de clients. Dona-li acces al teu emmagatzematge de documents i podra investigar respostes a les teves preguntes.

Els agents funcionen de la mateixa manera. Cada connexio que afegeixes -- cada _integracio_ -- amplia el que l'agent pot fer:

- *Connectat al teu sistema de fitxers:* L'agent pot llegir els teus documents, analitzar fulls de calcul, organitzar carpetes.
- *Connectat al web:* L'agent pot investigar competidors, consultar documentacio, buscar informacio actual.
- *Connectat al teu correu:* L'agent pot redactar respostes, resumir fils, marcar missatges urgents.
- *Connectat a la teva eina de gestio de projectes:* L'agent pot crear tasques, actualitzar estats, generar informes.
- *Connectat a la teva base de dades:* L'agent pot consultar dades, generar informes i trobar patrons que et passarien per alt en un full de calcul.

Cadascuna d'aquestes es una eina a les mans de l'agent. Mes eines significa mes capacitat -- pero tambe mes responsabilitat, per aixo existeix el gradient de confianca.

== Fontaneria Sense Codi

No cal ser desenvolupador per connectar coses entre si. Hi ha un ecosistema creixent d'eines per connectar sistemes sense escriure codi:

*Zapier, Make (anteriorment Integromat), n8n* -- Aquestes son plataformes d'automatitzacio. Et permeten crear fluxos de treball "si passa aixo, fes allo": "Quan aparegui una nova fila al meu full de calcul, crea una tasca a la meva eina de gestio de projectes." "Quan rebi un correu d'un client concret, resumeix-lo i publica el resum a Slack."

Aquests no son agents -- son pipelines. Pero poden treballar _amb_ agents. Un agent redacta un pressupost, i un flux de treball de Zapier l'envia al client i el registra al CRM. L'agent fa el pensament. El pipeline fa la fontaneria.

*Apple Shortcuts, Power Automate* -- Versions mes lleugeres per a fluxos de treball personals. "Cada mati, fes que un agent resumeixi els meus correus no llegits i posi el resum a la meva aplicacio de Notes." Son petits, pero s'acumulen.

*MCP (Model Context Protocol)* -- Aixo es un estandard mes nou que permet als agents connectar-se directament a eines externes d'una manera estandaritzada. Es tecnic per dins, pero el resultat es simple: en lloc de tu copiar dades _cap a_ l'agent, l'agent pot anar a _buscar_ dades de les teves eines. El teu desenvolupador ho configurara. Tu gaudieras dels resultats.

== L'Efecte Multiplicador

Cada integracio d'eines no nomes suma -- multiplica. Un agent que pot llegir les teves dades de vendes _i_ accedir al teu correu _i_ consultar el teu calendari pot fer coses que cap d'aquestes connexions podria fer sola:

"Consulta les meves dades de vendes del Q2, troba els tres comptes mes grans que no s'han contactat en mes de 30 dies, redacta correus de seguiment per a cadascun, i suggereix horaris de reunio basats en la disponibilitat del meu calendari la setmana vinent."

Aixo es un sol prompt. Quatre eines. Una tasca que t'hauria pres noranta minuts, feta en cinc.

Aixo es l'efecte compost de la integracio d'eines. Cada nova connexio obre combinacions que abans no eren possibles. Les persones que mes treuen dels agents rarament son les que tenen el model mes potent -- son les que tenen l'espai de treball mes connectat.

== La Questio de la Privacitat

Cada eina que connectes a un agent es una porta que obres. Abans de connectar alguna cosa, pregunta't:

- *Quines dades podra veure l'agent?* Connectar el teu correu significa que l'agent pot llegir _tot_ el teu correu, no nomes el fil en que estaves treballant.
- *Que pot fer l'agent amb elles?* L'acces de nomes lectura es molt diferent de l'acces de lectura i escriptura. L'agent pot nomes veure el teu calendari, o pot crear i eliminar esdeveniments?
- *On van les dades?* Quan l'agent llegeix el teu full de calcul, aquestes dades s'envien als servidors del proveidord'IA. Aixo es acceptable per a aquestes dades? Ho seria per a les dades dels teus clients?
- *Que passaria si alguna cosa anes malament?* Un agent amb acces d'eliminacio al teu sistema de fitxers pot eliminar fitxers accidentalment. Un agent amb acces d'enviament al teu correu pot enviar un correu accidentalment. Pensa en el pitjor cas.

Aixo no es una rao per evitar la integracio d'eines. Es una rao per ser intencional. Connecta el que necessites. Dona l'acces minim necessari. I aplica el gradient de confianca: comenca amb nomes lectura, passa a lectura i escriptura despres d'haver guanyat confianca.
