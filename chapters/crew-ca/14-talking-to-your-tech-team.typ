= Parlant amb el Teu Equip Tècnic

#figure(
  image("../../assets/illustrations/crew/ch14-talking-tech-team.jpg", width: 80%),
  caption: [_Ara parles dos idiomes._],
)

Acabes de passar tretze capítols aprenent com funciona el programari, què són els agents i com dirigir-los. Ara tens una cosa que la majoria de persones no tècniques no tenen: un vocabulari compartit amb els teus desenvolupadors.

Aquest capítol tracta de com fer-lo servir. No per fer veure que ets enginyer — sinó per tancar l'escletxa entre "no entenc què esteu construint" i "entenc prou per ajudar-vos a construir la cosa correcta."

== El Vocabulari

Aquí tens una referència dels termes que has après, emmarcats tal com apareixen en converses reals:

Quan el teu desenvolupador diu *"l'API està retornant un 500"* — la cuina (Django) s'ha espatllat. Alguna cosa ha explotat al costat del servidor. El menjador (React) funciona bé. El problema és entre bastidors.

Quan diuen *"hem d'escriure una migració"* — l'estructura de la base de dades (Postgres) ha de canviar per donar suport a una nova funcionalitat. Com afegir un calaix nou a l'arxivador.

Quan diuen *"està en memòria cau a Redis"* — les dades s'estan servint des de la pissarra ràpida en lloc de l'arxivador gran. Si les dades semblen desfasades, la pissarra potser necessita actualitzar-se.

Quan diuen *"ho posaré en una branca"* — estan treballant en un univers paral·lel (branca de Git) perquè l'aplicació principal no es vegi afectada. L'experiment és segur.

Quan diuen *"el PR necessita revisió"* — hi ha un pull request a punt. Algú ha proposat canvis i vol un segon parell d'ulls abans de fusionar-los.

Quan diuen *"el CI està fallant"* — la llista de verificació automatitzada ha detectat un problema. El canvi ha trencat un test o ha violat una regla. Cal arreglar-ho abans de poder-ho publicar.

Quan diuen *"el DNS no s'ha propagat"* — la guia telefònica d'internet encara no s'ha actualitzat a tot arreu. Algunes persones poden veure el canvi, d'altres no. Espera.

Quan diuen *"hauríem d'afegir un WebSocket per a això"* — en lloc que la pàgina comprovi si hi ha actualitzacions refrescant-se, volen afegir una connexió en directe perquè les actualitzacions apareguin instantàniament.

Quan diuen *"la finestra de context"* — el banc de treball de l'agent. Quanta informació pot retenir alhora.

Quan diuen *"ha al·lucinat"* — l'agent s'ha inventat alguna cosa. Amb confiança. Sembla real però no ho és.

== Preguntes que Val la Pena Fer

La cosa més valuosa que pots fer en una conversa tècnica no és entendre cada detall. És fer les preguntes correctes. Aquí en tens algunes que et faran guanyar respecte:

*"Què veu realment l'usuari quan passa això?"* — Això ancora qualsevol discussió tècnica a la realitat. Els desenvolupadors de vegades es perden en detalls d'implementació. Aquesta pregunta els fa tornar a l'experiència.

*"Quin és el risc si això surt malament?"* — Això és el gradient de confiança aplicat a la conversa. Separa les coses que val la pena preocupar-se de les que sonen espantoses però no ho són.

*"Podem provar-ho primer en una branca?"* — Ja saps què és una branca. Suggerir això demostra que entens que els experiments poden ser segurs.

*"Això és alguna cosa que un agent podria gestionar?"* — No per substituir el teu desenvolupador — sinó per suggerir que potser l'script de migració tediós o la tasca d'estilització repetitiva es podrien delegar. Els desenvolupadors de vegades s'obliden d'utilitzar les seves pròpies eines.

*"Què faria això més fàcil de testejar?"* — Això demostra que entens que la verificació importa. És una de les preguntes més fluides en enginyeria que pot fer algú que no és enginyer.

*"Com és el model de dades?"* — Ja saps què és una base de dades. Saps de taules i files. Preguntar pel model de dades demostra que estàs pensant en l'estructura, no només en les funcionalitats.

== Ser Útil en la Planificació

La contribució més gran que pots fer a un equip tècnic no és escriure codi ni revisar pull requests. És _definir el problema correctament_.

Els enginyers estan optimitzats per construir solucions. Sovint no són tan bons qüestionant si és la solució correcta. Aquí és on entres tu — especialment si estàs més a prop dels usuaris:

*"Estem construint un sistema de notificacions"* — pots preguntar: "Hem parlat amb els usuaris sobre si volen notificacions? De quin tipus? Amb quina freqüència? Les últimes tres aplicacions que he fet servir tenen un problema de 'fatiga de notificacions'."

*"Estem afegint un mode fosc"* — pots preguntar: "Qui ho ha demanat? Els nostres usuaris són instal·ladors de finestres en obres amb molta llum. Potser hauríem de fer un mode clar d'alt contrast."

*"L'agent gestionarà l'onboarding de clients"* — pots preguntar: "Què passa quan l'agent s'equivoca? Hi ha un traspàs a un humà? Com sabrà el client que està parlant amb un agent?"

Aquestes no són preguntes tècniques. Són preguntes de _producte_. I sovint són més valuoses que qualsevol decisió tècnica que es prengui a la mateixa reunió.

== El Pont

Ets un pont. Ara parles dues llengües — no amb fluïdesa en la tècnica, però prou bé per traduir entre les persones que construeixen el producte i les persones que el fan servir.

Aquest pont no existia abans que llegissis aquest llibre. Els desenvolupadors parlaven en APIs i migracions i pipelines de CI. Els usuaris parlaven en frustracions i desitjos i "estaria bé si." L'escletxa entre aquestes dues converses és on els productes fracassen.

Ara estàs al mig d'aquesta escletxa. No com a enginyer. No com a usuari. Com algú que entén prou d'ambdós costats per assegurar-se que estan construint la mateixa cosa.

Això no és un paper petit. És el paper que determina si el vaixell arriba a l'illa correcta.
