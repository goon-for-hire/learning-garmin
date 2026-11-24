"""Generate koans/ (blanks) and koans-solutions/ (answers) from tools/koans-master/*.mc.

In the master files an answer is written as /*K*/answer/*K*/.
  koans/            gets FILL_ME_IN in its place
  koans-solutions/  gets the answer itself
"""
import pathlib, re, shutil

ROOT = pathlib.Path(__file__).resolve().parent.parent
MASTER = ROOT / "tools" / "koans-master"
MARK = re.compile(r"/\*K\*/(.*?)/\*K\*/")

for target, repl in (("koans", "FILL_ME_IN"), ("koans-solutions", r"\1")):
    src_dir = ROOT / target / "source" / "koans"
    if src_dir.exists():
        shutil.rmtree(src_dir)
    src_dir.mkdir(parents=True)
    for f in sorted(MASTER.glob("*.mc")):
        (src_dir / f.name).write_text(MARK.sub(repl, f.read_text()))
print("ok")
