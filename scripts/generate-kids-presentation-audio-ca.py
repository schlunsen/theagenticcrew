#!/usr/bin/env python3
"""
Generate narration audio for the Kids' Presentation in Catalan using Qwen3-TTS.

Uses the crew voice reference (assets/voice-ref-crew.wav) as base, then pitch-shifts
up to create a child-like voice effect.

Output: website/public/presentation-audio-kids/slide-{01..09}-ca.mp3

Usage:
    python scripts/generate-kids-presentation-audio-ca.py
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
OUTPUT_DIR = BASE_DIR / "website" / "public" / "presentation-audio-kids"
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
SPEED = 0.90  # Slightly slower for kids audience

HAS_FFMPEG = shutil.which("ffmpeg") is not None

# ---------------------------------------------------------------------------
# Catalan slide narration scripts — kids presentation (9 slides)
# Written in a warm, playful tone suitable for children aged 9+
# ---------------------------------------------------------------------------

SLIDE_NARRATIONS = {
    1: (
        "Hola! Benvinguts a The Agentic Crew, la guia per a nens! "
        "Un llibre sobre vaixells, robots i entrepans explosius. "
        "Esteu preparats per conèixer la vostra tripulació? Comencem!"
    ),
    2: (
        "Imagineu-vos això. Sou a la cuina, menjant cereals. "
        "La vostra mare està al portàtil. Escriu alguna cosa i s'inclina cap enrere. "
        "A la pantalla apareixen línies verdes i vermelles. Però ningú escriu! "
        "La mare beu cafè i somriu. L'ordinador s'està arreglant sol? "
        "No és màgia. És un agent d'IA. I vosaltres esteu a punt d'aprendre a ser el seu capità!"
    ),
    3: (
        "Benvinguts a bord! Aquí ve la lliçó més important de tot el llibre. "
        "Com expliques la feina és més important que l'eina que la fa! "
        "El capità Alex diu: hi ha un problema a l'illa, aneu a arreglar-ho. "
        "La tripulació arregla tot menys el moll! "
        "La capitana Maya diu exactament què cal fer: aneu al moll nord, "
        "reemplaceu la tercera post, comproveu-ho amb aigua. "
        "Resultat? Moll arreglat. Sense fuites. Fet!"
    ),
    4: (
        "Ara coneixerem la tripulació! Són tres. "
        "Rusty, l'entusiasta! Treballa increiblement ràpid. Però no sap quan parar. "
        "Li demanes arreglar una porta i repinta tot el vaixell! "
        "Compass, la segura! Sap tones de dades. Memòria increïble. "
        "Però de vegades s'inventa les coses. Una vegada va inventar una illa sencera! "
        "I Echo, el curiós! Segueix instruccions perfectament. Súper precís. "
        "Però es queda en bucles. Intentarà el mateix error per sempre!"
    ),
    5: (
        "Les regles del vaixell! Cada feina té un color. "
        "Verd vol dir endavant! Feines segures com llegir mapes o comptar provisions. "
        "Groc vol dir pregunta'm primer! Feines mitjanes com arreglar una vela. "
        "I vermell vol dir mai tocar! Feines perilloses que només fa el capità, "
        "com obrir la cambra del tresor o navegar en tempestes. "
        "El truc és saber quina feina és de quin color!"
    ),
    6: (
        "La llista de comprovació del capità! "
        "Com saps si la tripulació ha fet bona feina? Comproves! "
        "Han navegat a l'illa correcta? Sí! "
        "Els mangos són madurs? Sí! "
        "Han portat cinquanta caixes? Sí! "
        "Sense mosques de la fruita? Sí! "
        "Tot marcat! El carregament és perfecte!"
    ),
    7: (
        "Quan les coses van malament! "
        "Rusty havia de girar una bandera cap per avall. "
        "Però va redissenyar tot el pal! Trenta-dues coses van canviar. La bandera seguia cap per avall. "
        "Compass va dibuixar un mapa preciós cap a l'Illa dels Cocos. Res era real! "
        "Echo va intentar pujar una àncora encallada. De la mateixa manera. Durant una hora sencera! "
        "I la tripulació va oblidar les instruccions del matí després d'un dia llarg. "
        "Lliçó: sigues específic, comprova sempre, i escriu les coses!"
    ),
    8: (
        "De vegades, el més intel·ligent és fer-ho tu mateix! "
        "Si explicar porta més temps que fer-ho, simplement fes-ho tu. "
        "Cordar-te la sabata? Tres segons. No cal cridar Rusty. "
        "La tripulació és genial per a feines grans i repetitives, "
        "per comptar i buscar, i per fer primers esborranys. "
        "Però les tasques petites, les coses que necessiten cor, "
        "i aprendre habilitats noves? Això ho has de fer tu!"
    ),
    9: (
        "I ara, ves a provar-ho! "
        "Agafa un paper. Escriu instruccions per fer un entrepà. "
        "Dona-les a algú de la teva família. Seguiu-les exactament. "
        "Et sorprendràs del que passa! "
        "El llibre és gratuït. Descarrega'l i converteix-te en el millor capità del món! "
        "Gràcies per escoltar!"
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


def wav_to_childlike_mp3(wav_path: Path, mp3_path: Path, speed: float = SPEED):
    """Convert WAV to MP3 with pitch shift up to sound younger/child-like.

    Uses rubberband for pitch shift (preserves tempo) then atempo for pace.
    Fallback: asetrate + aresample for simpler pitch shift if rubberband unavailable.
    """
    # Pitch up by ~3 semitones (factor 1.189) to sound younger
    # Combined with slight speed reduction for a child narrator feel
    pitch_semitones = 3
    pitch_factor = 2 ** (pitch_semitones / 12)  # ~1.189

    # Try rubberband first (best quality pitch shift)
    try:
        subprocess.run(
            ["ffmpeg", "-y", "-i", str(wav_path),
             "-af", f"rubberband=pitch={pitch_factor},atempo={speed}",
             "-codec:a", "libmp3lame", "-qscale:a", "2",
             str(mp3_path)],
            check=True, capture_output=True,
        )
        return
    except subprocess.CalledProcessError:
        pass

    # Fallback: asetrate + aresample (changes pitch by resampling)
    # asetrate changes the sample rate interpretation (pitches up),
    # aresample converts back to 44100 Hz
    original_rate = 24000  # Qwen3 TTS outputs 24000 Hz
    new_rate = int(original_rate * pitch_factor)

    subprocess.run(
        ["ffmpeg", "-y", "-i", str(wav_path),
         "-af", f"asetrate={new_rate},aresample=44100,atempo={speed}",
         "-codec:a", "libmp3lame", "-qscale:a", "2",
         str(mp3_path)],
        check=True, capture_output=True,
    )


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print("Kids Presentation Audio Generator — Catalan")
    print(f"  Voice ref: {CUSTOM_REF_AUDIO} ({'exists' if CUSTOM_REF_AUDIO.exists() else 'MISSING'})")
    print(f"  Output:    {OUTPUT_DIR}")
    print(f"  ffmpeg:    {'available' if HAS_FFMPEG else 'NOT available'}")
    print(f"  Speed:     {SPEED}x  |  Pitch: +3 semitones (child-like)")
    print()

    for slide_num in sorted(SLIDE_NARRATIONS.keys()):
        text = SLIDE_NARRATIONS[slide_num]
        mp3_path = OUTPUT_DIR / f"slide-{slide_num:02d}-ca.mp3"

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
                wav_to_childlike_mp3(tmp_wav, mp3_path, SPEED)
                tmp_wav.unlink()

                size_kb = mp3_path.stat().st_size / 1024
                print(f"OK ({size_kb:.0f} KB)")
            else:
                wav_path = OUTPUT_DIR / f"slide-{slide_num:02d}-ca.wav"
                shutil.move(str(tmp_wav), str(wav_path))
                print(f"OK (WAV, no ffmpeg)")

        except Exception as e:
            print(f"FAILED: {e}")

        # Small delay between requests
        time.sleep(2)

    print()
    print("Done! Audio files are in:", OUTPUT_DIR)


if __name__ == "__main__":
    main()
