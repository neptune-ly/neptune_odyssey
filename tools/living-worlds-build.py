"""Regenerate and sync the opt-in Living Worlds preview. Standard library only."""
import pathlib, runpy, shutil
root=pathlib.Path(__file__).resolve().parents[1]
source=root/'design/living-worlds'
runpy.run_path(str(source/'generate.py'))
shutil.copy(source/'platforms/odyssey3_theme.dart',root/'packages/neptune_flutter_ui/lib/neptune_living_worlds.dart')
shutil.copy(source/'platforms/Odyssey3Theme.kt',root/'packages/neptune_kmp_ui/odyssey-compose-ui/src/commonMain/kotlin/ly/neptune/odyssey/livingworlds/Odyssey3Theme.kt')
for folder in ['tokens','assets','prototype']:
    shutil.copytree(source/folder,root/'site/living-worlds'/folder,dirs_exist_ok=True)
shutil.copy(source/'PLAYBOOK.md',root/'site/living-worlds/PLAYBOOK.md')
