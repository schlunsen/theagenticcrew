#!/usr/bin/env python3
"""Check generated narration against its script: transcribe each clip with
faster-whisper and report word coverage, the ending, and loudness.

  pip install --user faster-whisper
  python3 scripts/verify-narration.py [--slides 1,2] [--lang en|es|both]
"""
import argparse, json, re, subprocess
from difflib import SequenceMatcher
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
SCRIPTS = BASE / "scripts" / "narration" / "presentation.json"
AUDIO = BASE / "website" / "public" / "presentation-audio"


def words(t):
    return re.findall(r"[a-záéíóúñü0-9']+", t.lower())


def loudness(path):
    err = subprocess.run(["ffmpeg", "-hide_banner", "-i", str(path), "-af", "loudnorm=print_format=json", "-f", "null", "-"],
                         capture_output=True, text=True).stderr
    j = json.loads(err[err.rindex("{"):err.rindex("}") + 1])
    return float(j["input_i"]), float(j["input_tp"])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--slides"); ap.add_argument("--lang", default="both")
    a = ap.parse_args()
    from faster_whisper import WhisperModel
    model = WhisperModel("small", device="cpu", compute_type="int8")
    wanted = {int(x) for x in a.slides.split(",")} if a.slides else None
    bad = 0
    for s in json.loads(SCRIPTS.read_text())["slides"]:
        if wanted and s["n"] not in wanted:
            continue
        for lang, suffix in (("en", ""), ("es", "-es")):
            if a.lang not in (lang, "both"):
                continue
            f = AUDIO / f"slide-{s['n']:02d}{suffix}.mp3"
            if not f.exists():
                print(f"{f.name:18} MISSING"); bad += 1; continue
            segs, _ = model.transcribe(str(f), language=lang)
            heard = " ".join(x.text for x in segs)
            ref, hyp = words(s[lang]), words(heard)
            cover = SequenceMatcher(None, ref, hyp).ratio()
            end_ok = SequenceMatcher(None, ref[-4:], hyp[-4:]).ratio() >= 0.5
            lufs, tp = loudness(f)
            ok = cover >= 0.85 and end_ok and abs(lufs + 16) <= 1.0 and tp <= -1.0
            bad += not ok
            print(f"{f.name:18} match={cover:.2f} end={'ok' if end_ok else 'CUT?'} {lufs:6.1f} LUFS {tp:5.1f} dBTP  {'OK' if ok else 'CHECK'}")
            if not ok:
                print(f"    heard: …{heard[-120:]}")
    print("all good" if not bad else f"{bad} clip(s) need attention")


if __name__ == "__main__":
    main()
