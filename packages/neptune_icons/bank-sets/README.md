# bank-sets — the three banks' icon sets

The Neptune mobile app ships as three banks, and each one draws its own icon
set. This directory is where those sets come from: **one roster, three
profiles**, and a generator that writes the Flutter apps' SVG assets from them.

It lives here rather than in the app because the profiles are a *design-system*
fact, not an app fact — `src/profiles.ts` exports the same numbers for the web,
and `test/profiles.test.ts` reads `emit.py` and fails if the two drift. A bank
cannot be one weight on the phone and another on the web.

```
roster.json   the single central declaration: 136 names, what each is, where it
              comes from, which banks carry it, which ones mirror in RTL
emit.py       PROFILES — the three banks as data — and the transform
install.py    writes assets/icons, assets/nuran/icons and assets/fglb/icons
```

## Running it

```sh
# from the Flutter app's repository root
python3 tools/icons/install.py .
dart run vector_graphics_compiler --input-dir assets/nuran/icons --out-dir /tmp/x
flutter test test/core/brand/brand_icon_set_test.dart
```

`install.py` is idempotent: every file it writes carries a header naming its
bank and its source, and a re-run reads that header rather than guessing.

## The rules that make it a system rather than a script

- **Per-bank difference is data.** The only place a bank name appears is
  `PROFILES`. Nothing below that table branches on which bank it is drawing.
- **No fall-through.** A bank missing a glyph fails the app's
  `brand_icon_set_test`; so does a glyph sitting in the wrong bank's root,
  because the header declares its bank. There is no default profile — an
  unknown bank throws.
- **A brand mark is never restyled.** Third-party trademarks are carried
  verbatim and belong only to the banks that have that partner.
- **A dot is a circle, never a zero-length stroke.** Library sets write a dot as
  `M12 17h.01` and rely on a round cap; a bank with butt terminals draws nothing
  there. The idiom is rewritten before any profile is applied.
- **Arc flags are single characters.** `a5 5 0 014-2` is legal SVG and a naive
  tokeniser reads `014` as one number, silently dropping two of the seven
  arguments. `emit.py`'s tokeniser is arc-aware; this was a real bug that
  produced five unparseable glyphs.

The full account — every source, every licence, and the measured evidence for
Andalus's rule — is `assets/ICON_LICENSES.md` in the app repository.
