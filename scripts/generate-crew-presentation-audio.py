#!/usr/bin/env python3
"""
Generate narration audio for the Crew Member's Guide slide presentation using Qwen3-TTS.

Uses a Catalan female voice reference (assets/voice-ref-crew.wav) cloned from
a Wikimedia Commons recording of "La Balenguera" by Rocío Martínez-Sampere.

Output: website/public/crew-presentation-audio/slide-{01..09}.mp3
        website/public/crew-presentation-audio/slide-{01..09}-ca.mp3

Usage:
    python scripts/generate-crew-presentation-audio.py             # Generate English
    python scripts/generate-crew-presentation-audio.py --lang ca   # Generate Catalan
    python scripts/generate-crew-presentation-audio.py --lang all  # Generate both
"""

import argparse
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
OUTPUT_DIR = BASE_DIR / "website" / "public" / "crew-presentation-audio"
CUSTOM_REF_AUDIO = BASE_DIR / "assets" / "voice-ref-crew.wav"

# Transcript of the reference audio clip (La Balenguera, first verse)
CUSTOM_REF_TEXT = (
    "La Balanguera misteriosa com una aranya d'art subtil, "
    "buida que buida sa filosa, de nostra vida treu el fil. "
    "Com una parca bé cavil·la teixint la tela per demà. "
    "La Balanguera fila, fila, la Balanguera filarà."
)

FASTAPI_BASE = "https://huggingfacem4-faster-qwen3-tts-demo.hf.space"
MAX_RETRIES = 5
INITIAL_BACKOFF = 10
SPEED = 0.92  # Slow down slightly for natural narration pace

HAS_FFMPEG = shutil.which("ffmpeg") is not None

# ---------------------------------------------------------------------------
# English slide narration scripts (9 slides)
# ---------------------------------------------------------------------------

SLIDE_NARRATIONS_EN = {
    1: (
        "Welcome. This is The Agentic Crew, the Crew Member's Guide. "
        "A book for people who are great with computers but don't write code. "
        "Let me walk you through the key ideas."
    ),
    2: (
        "The ground is shifting beneath all of us. "
        "The line between technical and non-technical is dissolving. "
        "Not because everyone is learning to code, "
        "but because the tools are learning to listen. "
        "If you manage projects, design products, run a business, or just fix the family Wi-Fi, "
        "this change affects you. And it's happening faster than anyone expected."
    ),
    3: (
        "Let's peek under the hood. Every app is like a restaurant. "
        "The frontend is the dining room, what users see and touch. "
        "The backend is the kitchen, where the real work happens. "
        "The database is the filing cabinet, where everything is remembered. "
        "And the cache is the whiteboard, quick notes for when things get busy. "
        "You don't need to build these things. But understanding them changes how you talk to the people who do."
    ),
    4: (
        "So what is an agent? It's not magic and it's not sentient. "
        "It's a loop. Observe, plan, act, check, repeat. "
        "The agent reads your files, makes a plan, takes action, checks if it worked, "
        "and goes around again. "
        "That loop is what separates an agent from a simple chatbot. "
        "A chatbot answers questions. An agent does work."
    ),
    5: (
        "The quality of what an agent produces depends entirely on how you instruct it. "
        "Bad: fix the website. That leads to confused, sprawling changes. "
        "Good: change the homepage button from blue to green, and don't change anything else. "
        "That leads to a precise, verifiable result. "
        "Being specific isn't micromanaging. It's good leadership."
    ),
    6: (
        "Not every task deserves the same level of trust. "
        "Drafting internal notes? Let the agent run. "
        "Sending emails to customers? Maybe review first. "
        "Modifying a database or deploying to production? Tight control, always. "
        "Start tight. Loosen with evidence. "
        "This is the trust gradient, and it's the most important concept in this book."
    ),
    7: (
        "Here's a real story. A window installer needed a quoting app. "
        "Three D window preview, PDF quotes with pricing, a customer database. "
        "Built in a weekend, without writing a single line of code. "
        "The person who built it wasn't a developer. They were someone who understood their problem deeply, "
        "and directed an agent to solve it."
    ),
    8: (
        "Things will go wrong. The email that wasn't ready. "
        "The confident statistic that turned out to be hallucinated. "
        "The overzealous redesign that changed everything you didn't ask it to touch. "
        "When it happens, the pattern is always the same. "
        "Stop. Assess. Restore. Learn. Try again. "
        "Agents fail predictably, and predictable failures have predictable fixes."
    ),
    9: (
        "Now go build something. "
        "You don't need to be a developer. You don't need permission. "
        "You just need a problem you care about and the willingness to direct an agent toward solving it. "
        "The book is free. Download it, read it, and build something real. "
        "Thank you."
    ),
}

# ---------------------------------------------------------------------------
# Catalan slide narration scripts (9 slides)
# ---------------------------------------------------------------------------

SLIDE_NARRATIONS_CA = {
    1: (
        "Benvinguts. Això és The Agentic Crew, la Guia del Membre de la Tripulació. "
        "Un llibre per a persones que són genials amb els ordinadors però no escriuen codi. "
        "Deixeu-me explicar-vos les idees clau."
    ),
    2: (
        "El terreny està canviant sota els nostres peus. "
        "La línia entre tècnic i no tècnic s'està dissolent. "
        "No perquè tothom estigui aprenent a programar, "
        "sinó perquè les eines estan aprenent a escoltar. "
        "Si gestioneu projectes, dissenyeu productes, gestioneu un negoci o simplement arregleu el Wi-Fi de casa, "
        "aquest canvi us afecta. I està passant més ràpid del que ningú esperava."
    ),
    3: (
        "Donem un cop d'ull sota el capó. Cada aplicació és com un restaurant. "
        "El frontend és el menjador, el que veuen i toquen els usuaris. "
        "El backend és la cuina, on passa la feina de debò. "
        "La base de dades és l'arxivador, on es recorda tot. "
        "I la memòria cau és la pissarra, notes ràpides per quan les coses van de pressa. "
        "No cal que construïu aquestes coses. Però entendre-les canvia com parleu amb qui ho fa."
    ),
    4: (
        "Què és un agent? No és màgia ni és sentient. "
        "És un bucle. Observar, planificar, actuar, comprovar, repetir. "
        "L'agent llegeix els teus fitxers, fa un pla, actua, comprova si ha funcionat, "
        "i torna a començar. "
        "Aquest bucle és el que separa un agent d'un simple xatbot. "
        "Un xatbot respon preguntes. Un agent fa feina."
    ),
    5: (
        "La qualitat del que produeix un agent depèn completament de com l'instrueixes. "
        "Malament: arregla el web. Això porta a canvis confusos i dispersos. "
        "Bé: canvia el botó de la pàgina principal de blau a verd, i no canviïs res més. "
        "Això porta a un resultat precís i verificable. "
        "Ser específic no és microgestionar. És bon lideratge."
    ),
    6: (
        "No totes les tasques mereixen el mateix nivell de confiança. "
        "Esborrany de notes internes? Deixa córrer l'agent. "
        "Enviar correus a clients? Potser revisa primer. "
        "Modificar la base de dades o desplegar a producció? Control estricte, sempre. "
        "Comença estret. Afluixa amb evidència. "
        "Aquest és el gradient de confiança, i és el concepte més important d'aquest llibre."
    ),
    7: (
        "Una història real. Un instal·lador de finestres necessitava una app de pressupostos. "
        "Previsualització 3D de finestres, pressupostos en PDF amb preus, base de dades de clients. "
        "Construït en un cap de setmana, sense escriure una sola línia de codi. "
        "La persona que ho va construir no era desenvolupadora. Era algú que entenia profundament el seu problema, "
        "i va dirigir un agent per resoldre'l."
    ),
    8: (
        "Les coses sortiran malament. El correu que no estava preparat. "
        "L'estadística confident que resulta ser al·lucinada. "
        "El redisseny excessiu que va canviar tot el que no havies demanat. "
        "Quan passa, el patró sempre és el mateix. "
        "Atura. Avalua. Restaura. Aprèn. Torna-ho a provar. "
        "Els agents fallen de manera previsible, i els errors previsibles tenen solucions previsibles."
    ),
    9: (
        "Ara vés i construeix alguna cosa. "
        "No cal ser desenvolupador. No cal permís. "
        "Només necessites un problema que t'importi i la voluntat de dirigir un agent per resoldre'l. "
        "El llibre és gratuït. Descarrega'l, llegeix-lo i construeix alguna cosa real. "
        "Gràcies."
    ),
}


# ---------------------------------------------------------------------------
# TTS generation
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
        print("  WARNING: No custom voice reference found, using default preset")

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

def generate_for_lang(narrations: dict, suffix: str = ""):
    """Generate audio for a set of slide narrations."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for slide_num in sorted(narrations.keys()):
        text = narrations[slide_num]
        mp3_path = OUTPUT_DIR / f"slide-{slide_num:02d}{suffix}.mp3"

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
                tmp_mp3 = tmp_wav.with_suffix(".mp3")
                wav_to_mp3(tmp_wav, tmp_mp3)
                tmp_wav.unlink()

                slow_down_audio(tmp_mp3, mp3_path, SPEED)
                tmp_mp3.unlink()

                size_kb = mp3_path.stat().st_size / 1024
                print(f"OK ({size_kb:.0f} KB)")
            else:
                wav_path = OUTPUT_DIR / f"slide-{slide_num:02d}{suffix}.wav"
                shutil.move(str(tmp_wav), str(wav_path))
                print(f"OK (WAV, no ffmpeg)")

        except Exception as e:
            print(f"FAILED: {e}")

        # Small delay between requests
        time.sleep(2)


def main():
    parser = argparse.ArgumentParser(description="Generate Crew Presentation narration audio")
    parser.add_argument("--lang", default="en", choices=["en", "ca", "all"],
                        help="Language to generate (default: en)")
    args = parser.parse_args()

    print("Crew Presentation Audio Generator")
    print(f"  Voice ref: {CUSTOM_REF_AUDIO} ({'exists' if CUSTOM_REF_AUDIO.exists() else 'MISSING'})")
    print(f"  Output:    {OUTPUT_DIR}")
    print(f"  ffmpeg:    {'available' if HAS_FFMPEG else 'NOT available'}")
    print(f"  Speed:     {SPEED}x")
    print()

    if args.lang in ("en", "all"):
        print("=== English ===")
        generate_for_lang(SLIDE_NARRATIONS_EN)
        print()

    if args.lang in ("ca", "all"):
        print("=== Catalan ===")
        generate_for_lang(SLIDE_NARRATIONS_CA, suffix="-ca")
        print()

    print("Done! Audio files are in:", OUTPUT_DIR)


if __name__ == "__main__":
    main()
