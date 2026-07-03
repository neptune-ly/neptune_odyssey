`listening_room.html` is generated (base64-embeds the mp3 previews of
whatever's in `../output/`) and gitignored — it's large (audio payloads) and
fully reproducible. Regenerate after running `generate.mjs`:

```sh
# re-encode each output/*/*.wav to a small preview mp3, then rebuild the page
# (see the README in the parent directory for the exact ffmpeg flags —
# 64kbps mono, never a high-bitrate encode; a high-bitrate build of this
# page failed to load once already)
```
