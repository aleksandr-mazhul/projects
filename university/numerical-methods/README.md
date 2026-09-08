# Numerical methods

BSU labs in Wolfram Mathematica. Nested under `university/numerical-methods` in [projects](https://github.com/aleksandr-mazhul/projects).

To reproduce this Cursor agent flow on another machine (ask for **that** student's lab variant, do not copy variant 6), give the agent [AGENT-PLAYBOOK.md](AGENT-PLAYBOOK.md).

## Lab 1

Variant 6. Submit `lab1/output/lab1-variant-6.pdf`.

```
lab1/
  generate-lab1.wl          rebuild the notebook and PDF
  input/                    course materials
    theory-and-practice-topic-1.pdf
    example.pdf
    answer-key.pdf
    style-math.nb           conspectus stylesheet (Input/Output rules reused)
  output/
    lab1-variant-6.nb
    lab1-variant-6.pdf
```

Rebuild (needs a local Wolfram installation):

```bash
/Applications/Wolfram.app/Contents/MacOS/wolframscript -file lab1/generate-lab1.wl
```
