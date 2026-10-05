# Streamcoy

---

## Inspiration

Mosquito-borne diseases kill over 700,000 people every year. I grew up watching malaria hurt me and people around me: family, neighbors, friends; The pain it puts people through has never left me. And what always struck me is how *preventable* it is. It starts with something as simple as knowing where the breeding sources are.

But detection happens too late. By the time a health department dispatches a team to test water, the outbreak is already spreading. The bottleneck isn't technology, it's **access**. Lab equipment is expensive. Internet connectivity in rural riparian corridors is unreliable. Training field workers takes months.

I asked a simple question: **what if a phone could listen to a stream and tell you if mosquitoes are breeding there?**

Female mosquitoes beat their wings at 450–650 Hz, a narrow, distinctive acoustic signature. Stagnant water sounds different from flowing water. Healthy ecosystems hum with frog calls and birdsong. All of this is encoded in 30 seconds of audio. The OneAquaHealth hackathon gave me the perfect framework to turn that question into a working tool: one that connects ecosystem health, vector surveillance, and human well-being through the One Health lens;

---

## What it does

Streamcoy turns any smartphone into a **bioacoustic vector surveillance sensor**. A citizen scientist such as a community volunteer, a school student, a park ranger, e.t.c. walks up to a stream, taps one button, and gets a full One Health diagnostic in 30 seconds. No internet, lab equipment or training required.

**The workflow:**

1. **Scan:** The app records a 30-second, 16 kHz audio buffer (480,000 raw PCM samples), all processed on-device. A tilt gauge captures the device angle to classify stream bank morphology because mosquitoes breed in still water, not rapids.

2. **AI Review:** A dual-engine inference system analyzes the buffer:
   - A **pure-Dart Radix-2 FFT engine** performs spectral analysis to detect the Culicidae wingbeat frequency band (450–650 Hz), measuring peak frequency, prominence above the noise floor, and bioacoustic index.
   - A **YAMNet MobileNet classifier** cross-validates with deep learning, producing independent probability scores for insect biophony, mosquito presence, amphibian activity, flowing water, and anthropic noise.
   - The AI doesn't just say "detected", it explains **why** with full transparency into both engines.  Explainable, auditable, and never autonomous.

3. **Verify:** The Human-in-the-Loop (HITL) triage form asks the citizen scientist to confirm: did you see standing water? What's the bank morphology? Could this be a false positive? **The machine proposes. The human disposes.** The AI never makes the final call alone.

4. **Report:** The One Health Triad Card synthesizes three pillars:
   - 🌊 **Freshwater Ecosystem Integrity**: bioacoustic index and ecosystem health score
   - 🦟 **Vector Proliferation Dynamics**: outbreak probability and risk classification
   - 🏥 **Human Well-being**: actionable municipal biocontrol recommendations (deploy larvicide, clear standing water, schedule follow-up)

5. **Export:** Every observation is serialized as **HL7 FHIR R4 compliant JSON**, the international digital health standard. This data can be ingested directly by municipal health registries, DHIS2 systems, or WHO surveillance pipelines making each citizen scan interoperable from day one.

---

## How we built it

**Platform:** A single codebase targeting Android, iOS, and desktop written with Flutter & Dart. Entirely offline-capable with zero cloud dependencies.

**Signal Processing:** A custom **Radix-2 FFT engine** written in pure Dart (no native plugins, no TensorFlow Lite dependency). This performs spectral decomposition of the 16 kHz audio buffer, extracting power spectrum density, peak frequency detection, vector band energy ratios, and bioacoustic index calculations — all on-device in milliseconds.

**Deep Learning:** A **YAMNet-based MobileNet classifier** provides parallel inference across 5 acoustic classes (insect biophony, Culicidae/mosquito, amphibian/frog, flowing water, anthropic rumble). The dual-engine approach means two independent verification paths converge on a single verdict.

**State Management:** Riverpod with a centralized `ScanPod` provider that manages the entire application state from raw audio buffers through spectral analysis to FHIR bundle generation.

**Health Interoperability:** A custom `FhirBundleBuilder` constructs standards-compliant HL7 FHIR R4 `DiagnosticReport` and `Observation` resources with proper LOINC coding (96608-5), enabling direct integration with municipal health information systems.

**Architecture:** Feature-first modular architecture with clean separation between UI, logic, and data layers. Custom `CustomPaint` renderers for the real-time spectrogram heatmap and waveform visualizer.

**AI-Assisted Development:** We used **Claude Opus 4.6 Thinking** for architectural design, UI/UX planning, code generation, and debugging, leveraging its extended thinking capabilities to reason through complex signal processing logic and FHIR R4 compliance. **Gemini 3.8 Flash** was used for rapid iteration on widget layouts, static analysis feedback loops, and real-time code refactoring via the Dart MCP toolchain. Both models served as pair-programming partners accelerating development without replacing engineering judgment, which mirrors the same human-in-the-loop philosophy the app itself is built on.

---

## Challenges we ran into

**Writing an FFT in pure Dart.** Most bioacoustics projects lean on Python's NumPy/SciPy or TensorFlow's native DSP. We needed everything to run on-device without native plugins, so we implemented a Radix-2 Cooley-Tukey FFT from scratch in Dart. Getting the butterfly operations, bit-reversal permutations, and windowing functions (Hanning) correct while maintaining performance on mobile hardware required careful optimization. We look forward to exploring more battle-tested libraries in future.

**Balancing explainability with information density.** Track 3 demands transparency. The AI must show its reasoning. But showing raw spectral data, probability distributions, and dual-engine breakdowns to a citizen scientist creates cognitive overload. We iterated significantly on the UI to make the technical depth *available* without making it *overwhelming*: key metrics are always visible, detailed breakdowns collapse behind expandable panels, and the plain-language diagnostic card translates frequencies and probabilities into sentences anyone can understand.

**FHIR R4 compliance without a FHIR library.** There's no mature FHIR R4 library for Dart/Flutter. With the help of AI assisted development, we hand-built the bundle structure following the HL7 specification, mapping our One Health assessment fields to proper `Observation`, `DiagnosticReport`, and `Patient` resources with correct LOINC codes. Validating that the output would actually be accepted by real health systems required careful cross-referencing with the FHIR spec.

**Making the One Health Triad meaningful, not performative.** It's easy to slap three scores on a card and call it "One Health." The hard part is making the synthesis *actionable*, turning a peak frequency reading and a citizen's standing-water observation into a specific municipal biocontrol recommendation that a health department can actually execute.

---

## Accomplishments that we're proud of

- **Zero cloud dependency.** The entire pipeline consisting of audio capture, FFT spectral analysis, deep learning inference, HITL verification, One Health synthesis, and FHIR export runs completely on-device. A citizen scientist in a rural area with no cellular signal can complete a full assessment.

- **Dual-engine cross-validation.** Two independent ML approaches (signal processing + deep learning) converge on a single verdict. This isn't just one model making a guess, it's two fundamentally different analytical methods agreeing (or disagreeing), which dramatically reduces false positives.

- **The Human-in-the-Loop design philosophy.** The AI is powerful, but it's never autonomous. Every assessment passes through citizen verification before becoming an official observation. This isn't a checkbox, it's a core architectural principle.

- **Real FHIR R4 output.** Not a mockup. Not a "we plan to add this." The app generates standards-compliant HL7 FHIR JSON right now, with proper resource typing, LOINC codes, and bundle structure. Plug it into a DHIS2 instance and it works.

- **Accessibility.** A 12-year-old with a smartphone can use this app. The workflow is one button, one form, one report. The complexity is there for the judges and researchers who want it but it's never forced on the citizen scientist.

---

## What we learned

- **Explainability is a UX problem, not just an AI problem.** Making an AI explainable isn't about dumping model weights on screen. It's about translating technical signals into human understanding and giving users the *choice* to dig deeper if they want.

- **The One Health framework is more than a buzzword.** When you actually try to synthesize ecosystem data, vector risk, and human impact into a single assessment, you realize how deeply interconnected these domains are. A bioacoustic index score alone doesn't tell the full story, it needs citizen context, environmental metadata, and municipal actionability to become meaningful.

- **Citizen science works best when it respects citizens.** The app doesn't ask users to become entomologists. It asks them three simple questions: "Did you see standing water? What does the bank look like? Could this be wrong?" That's the sweet spot expert-level output from layperson input.

- **Standards matter more than features.** A beautiful dashboard means nothing if the data can't leave the app. FHIR R4 compliance is invisible to the user, but it's what transforms a local observation into a data point that can reach a WHO surveillance pipeline.

---

## What's next for Streamcoy

- **Real microphone integration:** replacing the simulated audio pipeline with live `dart:io` PCM capture for field deployment.

- **On-device TFLite YAMNet:** loading the actual YAMNet `.tflite` model for production-grade deep learning inference directly on mobile hardware.

- **GPS auto-capture:** automatic geolocation tagging so the citizen scientist doesn't need to input coordinates manually.

- **Longitudinal trend analysis:** aggregating historical scan data across locations to detect emerging breeding patterns before outbreaks start. A stream that was safe last month but is stagnating now should trigger an early warning.

- **DHIS2 / municipal registry integration:** direct API sync with national health information systems so FHIR observations flow from the field to the decision-maker's dashboard in real time.

- **Community deployment pilot:** field-testing with citizen science groups in malaria-endemic regions to validate acoustic detection accuracy against entomological ground truth.

- **Offline mesh sync:** peer-to-peer data sharing between devices in areas with no connectivity, so a team of citizen scientists can sync observations when one device finally reaches a signal.
