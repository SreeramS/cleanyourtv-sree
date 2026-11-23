## launcher: green-glass, green-rim and green-halo focus styles

Three more `glass_style` values:

- `green-glass`: the frosted slab with a light green tint, a green rim and a green glow.
- `green-halo`: the halo look in green.
- `green-rim`: the rim look in green.

The colour is #34C759. The default stays `glass`.

### Change
- **`Config.glassStyle()`** knows the three new values. Matching ignores case and spaces, as for the existing ones.
- **`GlassView`:**
  - `setStyle()` sets flat/halo for the green variants, and the colour.
  - `setAccent(0)` returns to the style's own colour (white or green).
  - The fill gradient is tinted for `green-glass`.
  - Festive and cinematic accents still override the colour, as before.
- **Docs and tooling:**
  - `config.xml` and the `themes/README.md` Keys row document the values.
  - `tools/manage.py` accepts them.
  - `GlassStyleTest` and `tests/test_shipped_config_values.py` are updated.

### Tested
- On a Sony BRAVIA VU2 with `"glass_style": "green-glass"` in a theme.
- `pytest tests/test_shipped_config_values.py tests/test_manage_set_enums.py` passes.
- On the full suite, the only failure, `test_addon_tested_on_index.py::tested_on_cell`, also errors on an unchanged
  `main`.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

https://claude.ai/code/session_01JNks2QG6pJ57GLCSB3q7K5
