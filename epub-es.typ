// La Tripulación Agéntica — fuente EPUB
// Sin características exclusivas de PDF (layout de página, headers, contadores)

#set document(
  title: "La Tripulación Agéntica",
  author: "Rasmus Bornhøft Schlünsen",
)

#set text(lang: "es")
#set heading(numbering: "1.1")

// ─── Título ───

= La Tripulación Agéntica

_Cómo los ingenieros de software aprenden a construir con agentes_

Rasmus Bornhøft Schlünsen

Borrador — Marzo 2026

// ─── Dedicatoria ───

_A mis hijos — sois la mejor tripulación que he tenido. Todo esto fue para vosotros. Siempre._

// ─── Prólogo ───

== Prólogo

Llevo mucho tiempo siendo ingeniero de software. Sé lo que se siente tener un código base en la cabeza — abrir un editor, navegar al archivo correcto, y simplemente _escribir_ lo que hay que escribir. Esa memoria muscular, construida a lo largo de años de pulsaciones de teclas y sesiones de depuración, es real. Está ganada.

Y ahora el suelo se mueve bajo nuestros pies.

Los agentes de IA pueden escribir código, ejecutar tests, refactorizar módulos y entregar pull requests. No perfectamente — pero lo suficientemente bien como para que ignorarlos ya no sea una opción. Para ingenieros como nosotros, esto plantea una pregunta incómoda: si la máquina puede hacer lo que yo hago, ¿qué queda para mí?

Este libro es mi respuesta. El oficio no está muriendo — está evolucionando. Estamos pasando de escribir cada línea a mano a algo más parecido a dirigir, orquestar y colaborar. Menos teclear, más pensar. Menos editor, más ingeniería. Las habilidades que nos trajeron hasta aquí — pensamiento de sistemas, gusto, criterio, saber qué construir y por qué — importan _más_ ahora, no menos.

Pero la transición es desordenada. Escribí este libro porque la estoy viviendo, y sé que tú también.

_Rasmus Bornhøft Schlünsen — Marzo 2026_

// ─── Capítulos ───

#include "chapters/es/01-introduction.typ"
#include "chapters/es/02-context.typ"
#include "chapters/es/03-what-is-an-agent.typ"
#include "chapters/es/04-guardrails.typ"
#include "chapters/es/05-git.typ"
#include "chapters/es/06-sandboxes.typ"
#include "chapters/es/07-testing-as-the-feedback-loop.typ"
#include "chapters/es/08-convention-over-configuration.typ"
#include "chapters/es/09-tool-integrations.typ"
#include "chapters/es/10-local-vs-commercial-llms.typ"
#include "chapters/es/11-prompting-as-engineering.typ"
#include "chapters/es/12-multi-agent-orchestration.typ"
#include "chapters/es/13-cicd-and-agents.typ"
#include "chapters/es/14-war-stories.typ"
#include "chapters/es/15-when-not-to-use-agents.typ"
#include "chapters/es/16-agentic-teams.typ"
#include "chapters/es/17-final-words.typ"
