#!/usr/bin/env python3
"""
Generate Spanish narration audio for the slide presentation using Qwen3-TTS.

Uses the author's voice reference (assets/voice-ref.wav) to clone the voice
via the HuggingFace faster-qwen3-tts FastAPI mirror.

Output: website/public/presentation-audio/slide-{01..11}-es.mp3
"""

import base64
import os
import shutil
import subprocess
import tempfile
import time
from pathlib import Path

import requests

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent.parent
OUTPUT_DIR = BASE_DIR / "website" / "public" / "presentation-audio"
CUSTOM_REF_AUDIO = BASE_DIR / "assets" / "voice-ref.wav"
CUSTOM_REF_TEXT = (
    "The best software is built by people who care deeply about the problem "
    "they are solving. It's not about the tools you use or the frameworks you "
    "pick. It's about understanding what matters, making smart trade-offs and "
    "shipping something that actually works in the real world."
)

FASTAPI_BASE = "https://huggingfacem4-faster-qwen3-tts-demo.hf.space"
MAX_RETRIES = 5
INITIAL_BACKOFF = 10
SPEED = 0.92  # Slow down slightly for natural narration pace

HAS_FFMPEG = shutil.which("ffmpeg") is not None

# ---------------------------------------------------------------------------
# Spanish slide narration scripts
# ---------------------------------------------------------------------------

SLIDE_NARRATIONS_ES = {
    1: (
        "Bienvenidos a todos. Soy Rasmus, y esto es The Agentic Crew. "
        "Una guía práctica para la ingeniería en la era de los agentes de inteligencia artificial. "
        "Permítanme presentarles las ideas clave del libro."
    ),
    2: (
        "Durante veinte años, ser ingeniero de software significaba una cosa. "
        "Abres un editor, escribes código, lo despliegas. "
        "Las herramientas cambiaron, de Vim a VS Code, de SVN a Git, pero el ciclo fundamental seguía igual. "
        "Ese ciclo se está rompiendo. Y se está rompiendo rápido. "
        "Los agentes de IA no solo autocompletan tu código. Leen toda tu base de código, "
        "razonan sobre la arquitectura, hacen cambios en docenas de archivos, ejecutan tus tests "
        "e iteran sobre los fallos. Todo sin que toques el teclado."
    ),
    3: (
        "El oficio no está muriendo. Está mudando. "
        "La cáscara exterior, las pulsaciones, la sintaxis, el código repetitivo, esa parte se está cayendo. "
        "Pero el animal interior? "
        "La parte que sabe qué construir y por qué, "
        "que detecta una mala abstracción desde tres archivos de distancia, "
        "que puede mantener un sistema entero en mente y sentir dónde es frágil? "
        "Esa parte está más viva que nunca. "
        "No nos están reemplazando. Nos están ascendiendo. De mecanógrafos a pensadores."
    ),
    4: (
        "Entonces, qué es exactamente un agente? Seamos precisos. "
        "En un extremo, el autocompletado sugiere los próximos tokens. Reactivo, sin pensar. "
        "Un copiloto ve más contexto pero sigue siendo pasivo. Preguntas, responde. "
        "Luego vienen los agentes con herramientas. No solo generan texto, actúan. "
        "Leen archivos, escriben archivos, ejecutan comandos, inspeccionan resultados, y lo hacen en un ciclo. "
        "Intentar, observar, ajustar, intentar de nuevo. "
        "La mayor parte de la ingeniería agéntica práctica hoy ocurre justo aquí, en esa zona de uso de herramientas."
    ),
    5: (
        "La mejor analogía que he encontrado es Rain Man. "
        "Tú eres Tom Cruise. El agente es Dustin Hoffman. "
        "Raymond puede contar cartas como ningún humano. "
        "Ve patrones en montañas de datos, los procesa al instante, nunca se cansa. "
        "Pero no puede navegar el piso de un casino. No sabe por qué están contando cartas. "
        "Charlie es el que tiene el plan. Sabe a qué casino ir, cuándo apostar fuerte, cuándo cobrar. "
        "Eso es la ingeniería agéntica. Tú proporcionas dirección, juicio y gusto. "
        "El agente proporciona velocidad y amplitud. La combinación es más poderosa que cualquiera por separado."
    ),
    6: (
        "Tres capacidades separan a un agente de un chatbot sofisticado. "
        "Primero, planificación. Un agente descompone un objetivo en pasos. "
        "Agregar autenticación a esta app se convierte en una serie de acciones. "
        "Segundo, uso de herramientas. Un agente interactúa con el mundo, lee tus archivos, ejecuta tus tests. "
        "Las herramientas que le das a un agente definen qué tipo de agente es. "
        "Y tercero, iteración. Un agente puede intentar, fallar e intentar de nuevo. "
        "Escribir una función, ejecutar los tests, ver un fallo, leer el error, ajustar, volver a ejecutar. "
        "Ese ciclo es la magia."
    ),
    7: (
        "Los agentes van a fallar. Entender cómo fallan te ayuda a construir mejores flujos de trabajo. "
        "Expansión del alcance: pides una corrección de bug y el agente refactoriza tres archivos y actualiza el sistema de build. "
        "APIs alucinadas: el agente llama funciones o librerías que no existen. "
        "Exceso de confianza: el agente dice que terminó, y parece terminado, pero hay un bug sutil. "
        "Pérdida de contexto: en tareas largas, el agente pierde el hilo de decisiones anteriores. "
        "Cada modo de fallo tiene una mitigación, y esas mitigaciones son los capítulos de este libro."
    ),
    8: (
        "Cinco prácticas forman el kit de herramientas de ingeniería para trabajar con agentes. "
        "Las barandillas mantienen a los agentes en el camino con linters, verificadores de tipos y puertas de aprobación. "
        "Git te da control de versiones como red de seguridad, con ramas para aislamiento y diffs para revisión. "
        "Los sandboxes proporcionan entornos aislados donde los agentes pueden experimentar con seguridad. "
        "El testing es el ciclo de retroalimentación que hace a los agentes confiables, no solo rápidos. "
        "Y las convenciones, patrones de nombres y estructura que los agentes pueden seguir sin que se les diga. "
        "Estas cinco se refuerzan mutuamente. Juntas, son el barco que hace productiva a cualquier tripulación."
    ),
    9: (
        "Construí Clovr Code Terminal como una forma de practicar lo que predico. "
        "Es un panel web auto-alojado para ejecutar múltiples sesiones de agentes de IA desde tu navegador. "
        "Construido en Go, un solo binario de quince megabytes, sin dependencias. "
        "Tiene entrada de voz, métricas en vivo, soporte multi-sesión y controles de permisos. "
        "La mejor manera de aprender ingeniería agéntica es construir herramientas agénticas. "
        "Eso es lo que me enseñó este proyecto."
    ),
    10: (
        "Esta es la metáfora central del libro. "
        "Tú eres el capitán. Los agentes son tu tripulación. La base de código es el barco. "
        "La mayoría de los días, inicio un agente, le doy una tarea, tomo el resultado y lo descarto. "
        "Luego inicio otro. No recuerdan la sesión anterior. "
        "La tripulación es desechable. El barco no lo es. "
        "Tus convenciones, tus suites de tests, las reglas de tu proyecto, eso es el barco. "
        "Y si has construido bien el barco, cualquier nuevo miembro de la tripulación será productivo en minutos."
    ),
    11: (
        "Esto es lo que quiero que hagas. "
        "Esta noche, no mañana, no la próxima semana, esta noche, abre tu terminal. "
        "Elige un bug que has estado evitando. Apunta un agente hacia él. Dale contexto. Establece una barandilla. "
        "Observa qué pasa. "
        "Los ingenieros que definirán esta era no están esperando permiso. "
        "Están desplegando, rompiendo cosas, aprendiendo y desplegando de nuevo, "
        "con una tripulación a su lado que mejora un poco cada día. "
        "Gracias."
    ),
}


# ---------------------------------------------------------------------------
# TTS generation (reuses the audiobook pipeline's approach)
# ---------------------------------------------------------------------------

def tts_generate(text: str) -> bytes:
    """Call the faster-qwen3-tts FastAPI mirror with voice cloning and return WAV bytes."""
    form_data = {
        "text": text,
        "ref_text": CUSTOM_REF_TEXT,
    }

    use_custom_ref = CUSTOM_REF_AUDIO.exists()

    if not use_custom_ref:
        form_data["ref_preset"] = "ref_audio_3"

    backoff = INITIAL_BACKOFF
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            files = None
            if use_custom_ref:
                files = {"ref_audio": ("ref.wav", open(CUSTOM_REF_AUDIO, "rb"), "audio/wav")}

            resp = requests.post(
                f"{FASTAPI_BASE}/generate",
                data=form_data,
                files=files,
                timeout=300,
            )
            if resp.status_code == 429 or resp.status_code >= 500:
                raise RuntimeError(f"HTTP {resp.status_code}: {resp.text[:200]}")
            resp.raise_for_status()

            result = resp.json()
            if "audio_b64" in result:
                return base64.b64decode(result["audio_b64"])
            else:
                raise RuntimeError(f"No audio_b64 in response: {list(result.keys())}")

        except Exception as e:
            print(f"  [attempt {attempt}/{MAX_RETRIES}] Error: {e}")
            if attempt < MAX_RETRIES:
                print(f"  Retrying in {backoff}s ...")
                time.sleep(backoff)
                backoff = min(backoff * 2, 120)
            else:
                raise RuntimeError(f"Failed after {MAX_RETRIES} attempts: {e}")


def wav_to_mp3(wav_path: Path, mp3_path: Path):
    """Convert WAV to MP3 using ffmpeg."""
    subprocess.run(
        ["ffmpeg", "-y", "-i", str(wav_path), "-codec:a", "libmp3lame", "-qscale:a", "2", str(mp3_path)],
        check=True, capture_output=True,
    )


def slow_down_audio(input_path: Path, output_path: Path, speed: float = SPEED):
    """Slow down audio using atempo filter."""
    subprocess.run(
        ["ffmpeg", "-y", "-i", str(input_path),
         "-af", f"atempo={speed}",
         "-codec:a", "libmp3lame", "-qscale:a", "2",
         str(output_path)],
        check=True, capture_output=True,
    )


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print("Spanish Presentation Audio Generator")
    print(f"  Voice ref: {CUSTOM_REF_AUDIO} ({'exists' if CUSTOM_REF_AUDIO.exists() else 'MISSING'})")
    print(f"  Output:    {OUTPUT_DIR}")
    print(f"  Slides:    {len(SLIDE_NARRATIONS_ES)}")
    print(f"  ffmpeg:    {'available' if HAS_FFMPEG else 'NOT available'}")
    print(f"  Speed:     {SPEED}x")
    print()

    for slide_num in sorted(SLIDE_NARRATIONS_ES.keys()):
        text = SLIDE_NARRATIONS_ES[slide_num]
        mp3_path = OUTPUT_DIR / f"slide-{slide_num:02d}-es.mp3"

        if mp3_path.exists() and mp3_path.stat().st_size > 1000:
            print(f"  Slide {slide_num:2d}: already exists ({mp3_path.stat().st_size / 1024:.0f} KB), skipping")
            continue

        print(f"  Slide {slide_num:2d}: generating ({len(text)} chars) ...", end=" ", flush=True)

        try:
            wav_bytes = tts_generate(text)

            with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
                tmp.write(wav_bytes)
                tmp_wav = Path(tmp.name)

            if HAS_FFMPEG:
                # Convert to MP3
                tmp_mp3 = tmp_wav.with_suffix(".mp3")
                wav_to_mp3(tmp_wav, tmp_mp3)
                tmp_wav.unlink()

                # Slow down for natural pace
                slow_down_audio(tmp_mp3, mp3_path, SPEED)
                tmp_mp3.unlink()

                size_kb = mp3_path.stat().st_size / 1024
                print(f"OK ({size_kb:.0f} KB)")
            else:
                # No ffmpeg — save as WAV
                wav_path = OUTPUT_DIR / f"slide-{slide_num:02d}-es.wav"
                shutil.move(str(tmp_wav), str(wav_path))
                print(f"OK (WAV, no ffmpeg)")

        except Exception as e:
            print(f"FAILED: {e}")

    print("\nDone! Spanish audio files are in:", OUTPUT_DIR)


if __name__ == "__main__":
    main()
