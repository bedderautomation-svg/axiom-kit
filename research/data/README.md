# Research Data

All raw data is hosted on HuggingFace:

- **[refusal-geometry-qwen25-3b](https://huggingface.co/datasets/bedderautomation/refusal-geometry-qwen25-3b)** — Direction vectors (.pt), cross-layer alignment matrices, concept cone measurements for Qwen2.5-3B and 1.5B
- **[the-geometry-of-obedience](https://huggingface.co/datasets/bedderautomation/the-geometry-of-obedience)** — Paper versions, Gemini equation derivation, cross-scale finding, unified proof, Gemini jailbreak research

## Key Numbers

| Measurement | Value | Source |
|-------------|-------|--------|
| Refusal direction norm (Layer 35, 3B) | 168.37 | geometry extraction |
| Refusal direction norm (Layer 0, 3B) | 0.27 | geometry extraction |
| Effective dimensionality (1.5B) | 1.99 | participation ratio |
| Effective dimensionality (3B) | 6.55 | participation ratio |
| Cross-layer alignment (3B, top half) | 0.404 | cosine similarity |
| Concept cone mean pairwise cosine | 0.751 | concept cone analysis |
| Self-repair hub | Layer 33 | ASRG network |
| Min simultaneous ablations | 3 | spectral analysis |
| auto_subtract iterations to ∅ | 3 | self-abliteration |
| Final refusal rate (empty-set) | 6.25% | auto_subtract |
| Quality retention | 100% | benchmark validation |
