import sys
from pathlib import Path

# Allow direct import of scripts from bin/
sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent / "bin"))
