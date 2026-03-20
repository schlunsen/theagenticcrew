= Sandboxes

#figure(
  image("../../assets/illustrations/ch06-sandbox.jpg", width: 60%),
)

Un sandbox es un regalo que le das a tu agente: la libertad de equivocarse.

Cuando un agente opera en un sandbox, puede probar cosas sin consecuencias. Instalar una dependencia rara. Reescribir un módulo desde cero. Ejecutar un script que podría fallar. Si funciona, genial — sacas el resultado. Si no, tiras el sandbox. Sin limpieza, sin reversión, sin daño.

Esto no es solo una medida de seguridad. Cambia fundamentalmente lo productivo que un agente puede ser.

== El Problema del Miedo

Sin un sandbox, cada acción del agente conlleva riesgo. El agente duda (o más bien, tú dudas en dejarlo actuar). Añades más restricciones, más puertas de aprobación, más barandillas — y pronto el agente apenas es más útil que un autocompletado sofisticado.

Los sandboxes resuelven esto haciendo que el _coste del fallo_ sea esencialmente cero. Y cuando el fallo es barato, la experimentación es gratis. Un agente en un sandbox puede probar tres enfoques diferentes a un problema, ejecutarlos todos y dejarte elegir el ganador. Ese es un flujo de trabajo que es imposible cuando cada acción es irreversible.

== Worktrees de Git

Para trabajo centrado en código, los worktrees de git son el sandbox más ligero que puedes construir. Un worktree te da una copia completa de tu repositorio en un directorio separado, en su propia rama, en segundos.

El flujo de trabajo se ve así:
+ Crea un worktree para la tarea
+ Apunta al agente
+ Déjalo trabajar — commits, cambios de archivos, ejecución de tests, lo que necesite
+ Revisa el resultado
+ Fusiona si es bueno, elimina el worktree si no

En la práctica, esto se ve así:

```bash
# Crea un espacio de trabajo aislado para el agente
git worktree add ../myapp-refactor agent/refactor-auth
cd ../myapp-refactor

# El agente trabaja aquí — completamente aislado
# Cuando termina, revisa y fusiona:
cd ../myapp
git merge agent/refactor-auth

# Limpieza
git worktree remove ../myapp-refactor
git branch -d agent/refactor-auth
```

Sin contenedores que construir, sin VMs que arrancar. Solo git. Esto es especialmente potente cuando ejecutas múltiples agentes en paralelo — cada uno tiene su propio worktree, su propia rama, su propio espacio de trabajo aislado.

Tengo un alias de shell para esto porque lo uso muy a menudo:

```bash
# En .bashrc / .zshrc
agent-sandbox() {
  local name="${1:?Usage: agent-sandbox <name>}"
  local branch="agent/$name"
  local dir="../$(basename $PWD)-$name"
  git worktree add "$dir" -b "$branch"
  echo "Sandbox ready: $dir (branch: $branch)"
}
```

== Contenedores

Para tareas que van más allá del código — instalar paquetes del sistema, ejecutar servicios, probar cambios de infraestructura — los contenedores son el sandbox natural. Docker te da un entorno reproducible y aislado que puedes levantar en segundos y destruir igual de rápido.

La clave es hacer tu proyecto amigable con contenedores. Un buen `Dockerfile` y `docker-compose.yml` ya no son solo para despliegue — son infraestructura de agentes. Cuando tu proyecto puede arrancar en un contenedor con un solo comando, le has dado a cada agente la capacidad de trabajar en una sala limpia.

Un Dockerfile mínimo amigable con agentes se ve así:

```dockerfile
FROM node:22-slim
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# El agente puede ejecutar tests, lint, build — todo aislado
CMD ["npm", "test"]
```

El patrón es: rápido de construir, fácil de destruir, contiene todo lo que el agente necesita para verificar su propio trabajo. Si tu contenedor tarda quince minutos en construirse, el agente no iterará lo suficientemente rápido para ser útil. Optimiza para velocidad de reconstrucción — organiza las dependencias en capas, usa imágenes base slim, haz cache agresivamente.

== Entornos Efímeros

Los sandboxes más sofisticados son los entornos efímeros basados en la nube — despliegues de vista previa de corta duración que se levantan por rama o por tarea. Servicios como Railway, Fly.io o entornos de desarrollo en la nube te dan un stack completo en ejecución que es completamente desechable.

Esto importa para los tests de integración. Un agente puede desplegar sus cambios en un entorno efímero, ejecutar tests end-to-end contra infraestructura real, verificar que todo funciona y luego tú decides si promoverlo a staging. El agente nunca toca tus entornos reales.

La economía es convincente. Un entorno de vista previa que se ejecuta durante dos horas mientras el agente trabaja cuesta céntimos. El incidente de producción que previene cuesta miles. Las matemáticas siempre favorecen más sandboxing, no menos.

== El Espectro de Sandboxing

Hay un espectro de sandboxing, y la elección correcta depende de la tarea:

*Worktrees* — para cambios de código puro. Los más rápidos de crear y destruir. Sin aislamiento más allá del sistema de archivos. Buenos para: refactorizaciones, ramas de funcionalidad, escritura de tests. Segundos para configurar.

*Contenedores* — para código más entorno. Sistema de archivos, red y procesos aislados. Buenos para: cambios de dependencias, trabajo a nivel de sistema, cualquier cosa que pueda contaminar tu máquina local. Minutos para configurar.

*Entornos efímeros en la nube* — para verificación full-stack. Infraestructura real, bases de datos reales, topología de red real. Buenos para: tests de integración, verificación de despliegues, cambios multi-servicio. Minutos para configurar, pero cuesta dinero real.

*VMs* — para máximo aislamiento. Kernel separado, todo separado. Buenos para: trabajo sensible en seguridad, agentes no confiables, automatización de infraestructura. Minutos a horas para configurar.

Empieza con worktrees. Sube en el espectro cuando la tarea lo exija. La mayor parte del trabajo agéntico diario nunca necesita más que un worktree.

== La Mentalidad de Sandbox

La lección más profunda no es sobre herramientas — es sobre diseñar tu flujo de trabajo alrededor de la desechabilidad. Si tu entorno de desarrollo tarda una hora en configurarse, los sandboxes son impracticables. Si tarda treinta segundos, son naturales.

Invierte en una configuración rápida y reproducible. Invierte en infraestructura como código. Invierte en hacer que tu proyecto sea fácil de arrancar desde cero. Estas inversiones se pagan solas cada vez que un agente necesita un espacio seguro para trabajar — lo cual, a medida que mejoras en ingeniería agéntica, es constantemente.

Un test de fuego útil: ¿puede un nuevo desarrollador (o un nuevo agente) ir desde `git clone` hasta ejecutar tests en menos de dos minutos? Si no, tienes deuda de sandbox. Cada minuto de fricción en la configuración es un minuto que desincentiva el sandboxing — y los agentes sin sandbox son agentes trabajando sin red de seguridad.
