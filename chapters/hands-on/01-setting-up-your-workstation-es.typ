#import "_os-helpers.typ": *
= Configuración de tu Entorno de Trabajo

Antes de poder contribuir a un proyecto, corregir un error o simplemente leer código fuente correctamente, necesitas un entorno de trabajo funcional. Este capítulo prepara tu máquina desde cero, cualquiera que sea el sistema operativo que uses.

Al final de este capítulo, tendrás una terminal, un gestor de paquetes, Git, el CLI de GitHub y, opcionalmente, un asistente de inteligencia artificial, todo listo para funcionar.

#if sys.inputs.at("illustrations", default: "true") == "true" [#include "_illus-workshop.typ"]

== Abre tu Terminal

La terminal es tu línea de comandos: el lugar donde ejecutarás todo en este libro.

#if is-windows [
PowerShell viene preinstalado en Windows 10 y 11.

+ Presiona `Win + X`
+ Selecciona *Terminal* (o *Windows PowerShell*)

Verifica que funciona:

```
$PSVersionTable.PSVersion
```

Deberías ver la versión *5.1* o superior.
]

#if is-mac [
La Terminal está integrada. Ábrela desde Spotlight:

+ Presiona `Cmd + Espacio`
+ Escribe *Terminal* y presiona Intro

O encuéntrala en *Aplicaciones → Utilidades → Terminal*.

Verifica que usas un shell moderno:

```
echo $SHELL
```

Deberías ver `/bin/zsh` (predeterminado desde macOS Catalina) o `/bin/bash`. Ambos funcionan con esta guía.
]

#if is-linux [
Cómo abrir la terminal depende de tu entorno de escritorio, pero estos atajos funcionan en la mayoría de las distribuciones:

- *Ubuntu / GNOME:* `Ctrl + Alt + T`
- *KDE Plasma:* clic derecho en el escritorio → *Abrir Terminal*
- *Cualquier distro:* busca "Terminal" en el lanzador de aplicaciones

Verifica el shell:

```
echo $SHELL
```

Deberías ver `/bin/bash` o `/bin/zsh`.
]

#quote(block: true)[
  *¿Por qué la terminal?* Los agentes de programación IA viven en la terminal. No puedes trabajar en pareja con un agente si no tienes un lugar donde pueda operar. Piensa en esto como preparar tu taller antes de empezar a construir.
]

== Instala un Gestor de Paquetes

Un gestor de paquetes te permite instalar software escribiendo un solo comando en lugar de descargar instaladores y hacer clic en asistentes. Cada plataforma tiene el suyo.

#if is-windows [
=== WinGet

WinGet viene con Windows 10 (versión 1809+) y Windows 11.

Comprueba si lo tienes:

```
winget --version
```

Si obtienes un error, instálalo desde la Microsoft Store buscando *App Installer*, luego cierra y vuelve a abrir la terminal.
]

#if is-mac [
=== Homebrew

Homebrew es el gestor de paquetes estándar para macOS. Instálalo con:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Esto descarga y ejecuta el instalador oficial de Homebrew. Sigue las instrucciones: pedirá tu contraseña e instalará algunos elementos. Cuando termine, verifica:

```
brew --version
```

En Macs con Apple Silicon (M1/M2/M3), Homebrew se instala en `/opt/homebrew`. Si `brew` no se encuentra después de la instalación, busca una sección "Next steps" al final de la salida del instalador: mostrará dos comandos que debes ejecutar. Cópialos, ejecútalos y abre una nueva ventana de terminal.
]

#if is-linux [
=== apt / dnf

Las distribuciones Linux incluyen un gestor de paquetes. Los más comunes:

#quote(block: true)[
  *¿Qué es `sudo`?* En Linux, `sudo` ejecuta un comando como administrador, similar a "Ejecutar como administrador" en Windows. Se te pedirá tu contraseña de usuario. No se muestra nada mientras escribes; eso es normal.
]

*Ubuntu, Debian y derivados:*
```
sudo apt update
```

*Fedora, RHEL y derivados:*
```
sudo dnf check-update
```

*Arch Linux:*
```
sudo pacman -Sy
```

No necesitas instalar nada: estos gestores vienen con tu sistema operativo. Los ejemplos de esta guía usan `apt`; sustitúyelo por el equivalente de tu distribución.
]

== Instala Git

Git es el control de versiones. Registra cada cambio en cada archivo de un proyecto y es la forma en que los equipos colaboran sin sobrescribir el trabajo de los demás. Todos los proyectos de este libro usan Git.

#if is-windows [
```
winget install Git.Git
```

*Cierra y vuelve a abrir tu terminal* tras la instalación.
]

#if is-mac [
Git viene incluido con las Xcode Command Line Tools, que probablemente ya tienes. Prueba:

```
git --version
```

Si ves un número de versión, ya está listo. Si macOS te pide instalar las herramientas de desarrollo, haz clic en *Instalar* y espera.

Para obtener una versión más reciente con Homebrew:

```
brew install git
```
]

#if is-linux [
*Ubuntu / Debian:*
```
sudo apt install git
```

*Fedora:*
```
sudo dnf install git
```

*Arch:*
```
sudo pacman -S git
```
]

---

Verifica:

```
git --version
```

Deberías ver un número de versión como `git version 2.47.1`.

Ahora configura tu identidad para que Git sepa quién realiza los cambios:

```
git config --global user.name "Tu Nombre"
git config --global user.email "tu@correo.com"
```

Usa el mismo correo que en tu cuenta de GitHub.

== Git en Acción

Git está instalado, pero todavía no lo has usado. Hagamos una prueba rápida de 60 segundos para que Git no sea un misterio cuando llegue el Capítulo 2.

Crea una carpeta de práctica y entra en ella:

#if is-windows [
```
mkdir test-repo
cd test-repo
```
]

#if is-mac [
```
mkdir test-repo && cd test-repo
```
]

#if is-linux [
```
mkdir test-repo && cd test-repo
```
]

Dile a Git que empiece a rastrear esta carpeta:

```
git init
```

Comprueba el estado:

```
git status
```

Deberías ver algo como: `On branch main — nothing to commit`. Git te está diciendo que está vigilando esta carpeta y que aún no hay nada nuevo que registrar.

En el Capítulo 2 usarás `git status` constantemente: es como verificas qué ha cambiado. Ahora ya sabes cómo se ve cuando todo está limpio.

Vuelve a tu carpeta de inicio cuando hayas terminado:

```
cd ..
```

#quote(block: true)[
  *¿Qué acaba de pasar?* `git init` creó una carpeta oculta `.git` dentro de `test-repo`. Ahí es donde Git almacena todo su historial. Todos los proyectos que usan Git tienen una. Nunca necesitas tocarla directamente.
]

== Instala el CLI de GitHub

El CLI de GitHub (`gh`) te permite hacer forks de repositorios, crear pull requests y gestionar issues, todo sin salir de la terminal.

#if is-windows [
```
winget install GitHub.cli
```

Cierra y vuelve a abrir tu terminal.
]

#if is-mac [
```
brew install gh
```
]

#if is-linux [
*Ubuntu / Debian* — `gh` no está en los repositorios predeterminados, así que primero debes añadir el repositorio oficial de GitHub. Estos comandos lo hacen y luego instalan `gh`:

```
sudo mkdir -p -m 755 /etc/apt/keyrings
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh
```

Puedes pegar todo el bloque a la vez: la terminal ejecutará cada línea en secuencia. Se te pedirá la contraseña en el primer `sudo`.

*Fedora:*
```
sudo dnf install gh
```

*Todas las distribuciones de Linux* — o instala directamente desde #link("https://github.com/cli/cli/releases")[github.com/cli/cli/releases] descargando el binario para tu arquitectura.
]

---

Verifica:

```
gh --version
```

== Crea una Cuenta de GitHub

Si aún no tienes una, regístrate en #link("https://github.com/signup")[github.com/signup]. Es gratuita. La necesitarás para todo a partir del Capítulo 2.

== Autentícate

Ahora conecta tu terminal a tu cuenta de GitHub:

```
gh auth login
```

Cuando se te pida, elige:
- *GitHub.com*
- *HTTPS*
- *Login with a web browser*

Te dará un código de un solo uso y abrirá tu navegador. Pega el código, autoriza y ya estarás conectado.

Verifica que funcionó:

```
gh auth status
```

Deberías ver `Logged in to github.com`.

== (Opcional) Instala un Asistente de Programación IA

Este libro trata sobre trabajar con agentes de IA. Aunque no es estrictamente necesario para los ejercicios, tener un asistente IA en tu terminal hace que la experiencia sea real.

Tanto Claude Code como Gemini CLI requieren Node.js. Instálalo primero.

=== Instala Node.js

#if is-windows [
```
winget install OpenJS.NodeJS.LTS
```
]

#if is-mac [
```
brew install node
```
]

#if is-linux [
*Ubuntu / Debian:*
```
sudo apt install nodejs npm
```

*Fedora:*
```
sudo dnf install nodejs npm
```
]

Cierra y vuelve a abrir tu terminal, luego verifica:

```
node --version
npm --version
```

=== Opción A: Claude Code

Claude Code es el agente de programación IA de Anthropic. Se ejecuta en tu terminal y puede leer, escribir y razonar sobre código.

Instálalo usando el instalador oficial (el método recomendado):

#if is-mac [
```
curl -fsSL https://claude.ai/install.sh | bash
```
]

#if is-linux [
```
curl -fsSL https://claude.ai/install.sh | bash
```
]

#if is-windows [
```
winget install Anthropic.Claude
```
]

O mediante npm:
```
npm install -g @anthropic-ai/claude-code
```

Ejecútalo:

```
claude
```

Se te pedirá que te autentiques con tu cuenta Anthropic la primera vez.

=== Opción B: Gemini CLI

Gemini CLI es el agente de programación IA de Google. Mismo concepto, modelo diferente.

```
npm install -g @google/gemini-cli
gemini
```

Necesitarás una clave API de Google. Configúrala en tu sesión actual:

#if is-windows [
```
$env:GEMINI_API_KEY = "tu-clave-aquí"
```
]

#if is-mac [
```
export GEMINI_API_KEY="tu-clave-aquí"
```
]

#if is-linux [
```
export GEMINI_API_KEY="tu-clave-aquí"
```
]

#if is-mac [
Para hacerla permanente, añade la línea `export` a tu archivo de configuración del shell. Este archivo se ejecuta automáticamente cuando se inicia tu terminal:

Abre `~/.zshrc` con:
```
open -e ~/.zshrc
```

Añade `export GEMINI_API_KEY="tu-clave-aquí"` en una nueva línea al final, guarda y cierra. Luego ejecuta `source ~/.zshrc` para aplicar el cambio en la sesión actual.
]

#if is-linux [
Para hacerla permanente, añade la línea `export` a tu archivo de configuración del shell. Este archivo se ejecuta automáticamente cuando se inicia tu terminal:

Abre `~/.bashrc` con:
```
nano ~/.bashrc
```

Añade `export GEMINI_API_KEY="tu-clave-aquí"` en una nueva línea al final, guarda y cierra. Luego ejecuta `source ~/.bashrc` para aplicar el cambio en la sesión actual.
]

Si no sabes dónde obtener una clave API de Google, ve a #link("https://aistudio.google.com")[aistudio.google.com], inicia sesión y crea una clave en *Get API key*. Es gratuita para empezar.

=== ¿Cuál elegir?

Cualquiera funciona para este libro. Claude Code destaca en razonamiento de código y ediciones de múltiples archivos. Gemini CLI tiene una fuerte integración con el ecosistema de Google. Prueba ambos si quieres: son gratuitos para empezar. Los ejercicios mostrarán prompts que funcionan con cualquiera de los dos.

== Verifica Todo

Ejecuta esta lista de verificación rápida:

```
git --version
gh --version
gh auth status
```

Si los tres comandos funcionan, estás listo. Tu entorno de trabajo está configurado, tu identidad está ajustada y tienes conexión directa a GitHub.

== El Enfoque Basado en Prompts

Una vez instalado Claude Code o Gemini CLI, no tienes que recordar cada comando: puedes describir lo que quieres en español natural. Así es como pedirías a un agente IA que verifique toda tu configuración.

Abre tu asistente IA en la terminal:

```
claude
```

Luego prueba prompts como estos:

- _"Comprueba si Git está instalado y correctamente configurado con nombre y correo electrónico."_
- _"¿Está instalado y autenticado el CLI de GitHub? Muéstrame el estado."_
- _"Ejecuta una lista de verificación rápida: git, gh y gh auth status — dime qué funciona y qué no."_

El agente ejecutará los comandos, interpretará la salida y te dirá en lenguaje natural qué está listo y qué aún necesita atención. Si algo falta o está roto, pregúntale:

- _"Git no está configurado con mi correo electrónico — ¿cómo lo arreglo?"_
- _"Guíame paso a paso para autenticar el CLI de GitHub."_
- _"Estoy en macOS y Homebrew no está en mi PATH — ¿cómo lo soluciono?"_

#quote(block: true)[
  *Comandos vs. prompts.* Ambos enfoques te llevan al mismo lugar. Los comandos son rápidos y precisos una vez que los conoces. Los prompts son más tolerantes: te encuentran donde estás. A medida que ganes experiencia, cambiarás entre los dos de forma natural.
]

En el próximo capítulo, pondremos todo en práctica: harás un fork de un repositorio real, leerás un capítulo real de un libro real, escribirás una reseña honesta y enviarás tu primer pull request.
