# ASPIRE - issue list

Working notes from the architecture review of 2026-08-19..21. Uncommitted on
purpose. Cross-repository items are in `issues-stack.md` (X0..X7). Full
evidence: https://claude.ai/code/artifact/1dcb7a4a-4523-46fc-af23-7c5b0ecc3688

State refers to branch `claude/julia-repos-architecture-review-tj1zzz`.

9k lines of MATLAB, effectively frozen since 2018 and superseded by the Julia
MCPC-3D-S. It would be a pure archive except for one line in its README.

---

## Open

### A1. F4 / X7.2 - the patent is the only live thing here
US10605885B2 covers ASPIRE / MCPC-3D-S. The README states that a licence is
required for commercial use and that the method "may not be used for diagnosis
in humans". MCPC-3D-S ships today in MriResearchTools.jl, in every mritools
binary release, and as a Rust crate.

What changed on this branch, downstream rather than here: the patent is now
recorded in KorecSWI's `THIRD_PARTY_NOTICES.md`, in `NOTICE.md` shipped with the
Rust binaries, and, via the `NOTICES` registry, written into the citations file
of any run that actually executed MCPC-3D-S (always for `mcpc3ds`, conditionally
for `romeo`, never for a run that did not use it). That is documentation, not
resolution. Whether rights exist through the original assignment or a licence is
needed is a legal question and it has the longest lead time of anything in the
review.

### A2. No LICENSE file
The README carries the terms; there is no LICENSE. For an archive whose terms
are the interesting part, the terms should be in the file that tooling reads.
Note this one is genuinely not MIT, unlike the other two repositories missing a
licence, so it needs the owner's wording rather than a standard file.

### A3. Mark it archived, explicitly
Superseded by MriResearchTools' MCPC-3D-S. A README banner and GitHub's archive
flag stop people from starting here. Keep it readable: it is the origin of the
method and the reference the patent attaches to.

### A4. Stay out of the monorepo (X5)
Frozen, different language, and its licence position is distinct. Nothing to
gain from moving it.
