= Benvingut a la tripulacio

#figure(
  image("../../assets/illustrations/crew/ch01-welcome.jpg", width: 80%),
  caption: [_L'horitzó és més ampli del que penses._],
)

Fa sis mesos, el meu amic Morten em va dir que volia construir una aplicacio per al seu negoci. En Morten instal·la finestres -- les de vidre, no les de Microsoft. Fa quinze anys que s'hi dedica. Coneix cada model de finestra, cada tipus de marc, cada truc per aconseguir un segellat perfecte en una vella masia danesa. Dirigeix un equip de quatre homes, gestiona pressupostos en paper i fa el seguiment dels treballs en un full de calcul que faria plorar un comptable.

En Morten es brillant amb els ordinadors. Es va muntar el seu propi NAS, te un servidor Plex, va automatitzar la meitat de la seva llar intel·ligent amb scripts que va trobar a Reddit. Pero no ha escrit mai una linia de codi.

Li vaig parlar dels agents d'IA -- eines que poden escriure codi, construir interficies, configurar bases de dades, tot a partir d'instruccions en llenguatge natural. Li vaig ensenyar el basic. Com descriure el que vols. Com dividir una gran idea en petites tasques. Com revisar el resultat i corregir el rumb quan les coses se'n van de mare.

El que va passar despres ens va sorprendre a tots dos. En un cap de setmana, en Morten tenia un prototip funcional. Una eina de pressupostos on podia introduir les mides de la paret, triar un model de finestra, veure una previsualitzacio en 3D de com quedaria i generar un pressupost en PDF per enviar per correu al client. No era perfecte -- la previsualitzacio 3D tenia un problema d'il·luminacio i el format del PDF necessitava feina. Pero era _real_. Funcionava. I ho va construir sense escriure ni una sola linia de codi.

Els seus clients van comecar a comentar com de professionals quedaven els seus pressupostos. El seu equip va comecar a utilitzar-ho en tauletes a les obres. Un competidor li va preguntar qui li havia fet el programari.

En Morten te zero anys d'experiencia en programacio. Simplement va aprendre a dirigir alguna cosa que si que en sap.

== Que es aquest llibre

Aquesta es la guia que m'hauria agradat poder donar a en Morten abans que comences. Esta construida sobre els mateixos principis que l'edicio d'enginyeria de _La Tripulacio Agentica_, pero traduida per a persones que treballen _amb_ la tecnologia sense construir-la des de zero.

Aprendras que son realment els agents d'IA -- despullats del llenguatge de marketing. Aprendras com funciona el programari modern per dins, perque entenguis que estan construint els agents quan construeixen. Aprendras a comunicar-te amb els agents amb prou claredat perque facin el que vols dir, no el que has dit. I aprendras quan confiar en el resultat, quan objectar i quan fer la feina tu mateix.

Aixo no es un llibre sobre prompts i trucs. Es un llibre sobre _pensar_ -- el tipus de pensament que converteix una bona idea en un producte funcional, tant si ets tu qui escriu el codi com si no.

== Per a qui es

Ets bo amb els ordinadors. Potser molt bo. Gestiones sistemes, domines dades, configures eines i resols problemes que enviarien la majoria de la gent al servei d'assistencia tecnica. Ets la persona a qui truquen els teus amics quan la impressora no es connecta.

Pero no has obert mai un editor de codi i has escrit `function`. No has desplegat mai un servidor web. No t'has quedat mai mirant una terminal plena de missatges d'error i has sabut, instintivament, quina linia arreglar.

No passa res. No cal que ho facis.

El que necessites es un model mental -- una manera d'entendre que son aquestes eines, que poden fer i com dirigir-les. Perque la persona que sap _que_ construir i ho pot descriure clarament es, cada vegada mes, la persona mes important de la sala. Mes important que la persona que pot teclejar el codi. La part del codi s'abarateix dia a dia. La part del pensament no ho fara mai.

== Com llegir aquest llibre

Aquest llibre es un viatge, no un manual de referencia.

Comencem amb el que esta canviant al mon i per que et concerneix. Despres obrim el capo del programari modern -- no per convertir-te en enginyer, sino per donar-te el vocabulari i el model mental per entendre amb que treballen els agents. A partir d'aqui, entrem en els agents mateixos: que son, com parlar-hi, com posar-hi limits i com verificar la seva feina.

A la segona meitat, construim alguna cosa real. No un exemple de joguina. Una aplicacio funcional per a un negoci real, dirigida completament a traves de conversa amb un agent. I tanquem amb les preguntes mes dificils -- quan les coses van malament, quan intervenir i quin es el teu paper en un mon on el codi s'escriu sol.

Quan acabis, no seras programador. Pero seras alguna cosa que potser importa mes: algu que en pot dirigir un.

== El tema nautic

Potser notes que aquest llibre parla molt de vaixells, tripulacions i capitans. No es casualitat. L'edicio principal de _La Tripulacio Agentica_ utilitza la metafora d'una tripulacio de vaixell al llarg de tot el text -- l'enginyer com a capita, els agents com a membres de la tripulacio. L'edicio infantil ho porta encara mes lluny, amb personatges il·lustrats i aventures al mar.

En aquesta edicio, tu ets el tripulant. No el capita -- aquest es l'enginyer que construeix el vaixell. No un passatger -- no estas aqui nomes per fer el viatge. Ets una part vital de la tripulacio. Saps coses que el capita no sap. Veus coses des de coberta que no son visibles des del timo. I cada vegada mes, ets tu qui diu a la tripulacio cap a on navegar.

Tot gran vaixell necessita un capita. Pero cap capita ha navegat mai sol.
