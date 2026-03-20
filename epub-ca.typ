// La Tripulacio Agentica — EPUB source
// Stripped of PDF-only features (page layout, headers, counters)

#set document(
  title: "La Tripulacio Agentica",
  author: "Rasmus Bornhoft Schlunsen",
)

#set text(lang: "ca")
#set heading(numbering: "1.1")

// ─── Title ───

= La Tripulacio Agentica

_Com els enginyers de software aprenen a construir amb agents_

Rasmus Bornhoft Schlunsen

Esborrany -- Marc 2026

// ─── Dedication ───

_Als meus fills -- sou la millor tripulacio que he tingut mai. Tot aixo era per a vosaltres. Sempre._

// ─── Foreword ───

== Proleg

He estat enginyer de software durant molt de temps. Se el que es sent tenir una base de codi al cap -- obrir un editor, navegar fins al fitxer correcte i simplement _escriure_ la cosa. Aquesta memoria muscular, construida al llarg d'anys de pulsacions de tecles i sessions de depuracio, es real. Esta guanyada.

I ara el terra s'esta movent sota els nostres peus.

Els agents d'IA poden escriure codi, executar tests, refactoritzar moduls i enviar pull requests. No perfectament -- pero prou be com perque ignorar-los ja no sigui una opcio. Per a enginyers com nosaltres, aixo planteja una pregunta incomoda: si la maquina pot fer el que jo faig, que em queda?

Aquest llibre es la meva resposta. L'ofici no s'esta morint -- esta evolucionant. Estem passant d'escriure cada linia a ma a quelcom mes semblant a dirigir, orquestrar i col·laborar. Menys teclejar, mes pensar. Menys editor, mes enginyeria. Les habilitats que ens han portat fins aqui -- pensament sistemic, gust, judici, saber que construir i per que -- ara importen _mes_, no menys.

Pero la transicio es desordenada. Vaig escriure aquest llibre perque l'estic vivint, i se que tu tambe.

_Rasmus Bornhoft Schlunsen -- Marc 2026_

// ─── Chapters ───

#include "chapters/ca/01-introduction.typ"
#include "chapters/ca/02-context.typ"
#include "chapters/ca/03-what-is-an-agent.typ"
#include "chapters/ca/04-guardrails.typ"
#include "chapters/ca/05-git.typ"
#include "chapters/ca/06-sandboxes.typ"
#include "chapters/ca/07-testing-as-the-feedback-loop.typ"
#include "chapters/ca/08-convention-over-configuration.typ"
#include "chapters/ca/09-tool-integrations.typ"
#include "chapters/ca/10-local-vs-commercial-llms.typ"
#include "chapters/ca/11-prompting-as-engineering.typ"
#include "chapters/ca/12-multi-agent-orchestration.typ"
#include "chapters/ca/13-cicd-and-agents.typ"
#include "chapters/ca/14-war-stories.typ"
#include "chapters/ca/15-when-not-to-use-agents.typ"
#include "chapters/ca/16-agentic-teams.typ"
#include "chapters/ca/17-final-words.typ"
