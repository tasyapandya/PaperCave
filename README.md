# PaperCave

**Read papers. Understand more.**

PaperCave is an iOS app designed to make academic papers easier to understand. Select a part of a paper you find difficult, ask PaperCave to explain or simplify it, and revisit what you've learned whenever you come back to the paper.

> 📸 **App Preview**
> *Screenshots coming soon.*

---

## About
PaperCave started from a problem I often had while reading academic papers: encountering unfamiliar concepts, looking them up, understanding them for a moment, and then forgetting what they meant when I returned to the paper later. Instead of constantly switching between a paper and other tools, PaperCave brings that learning process directly into the reading experience. This project is also a personal learning challenge to explore Apple's on-device technologies, particularly **Foundation Models** and **SwiftData**, while building something around a problem I experience myself.

---

## Core Features

### 📄 Read Papers
Import and read PDF papers directly inside the app with a full PDF reading experience.

### ✨ Explain
Select a concept or passage and get an explanation based on the context of what you're reading.

### 🪄 Simplify
Turn complex academic language into something easier to understand while preserving its original meaning.

### 💾 Save Your Learning
Interactions are automatically saved, allowing you to revisit explanations and simplified passages later.

### 🖍️ Revisit Previous Interactions
Return to a paper and see the parts you've previously explored, without having to search for the same concepts again.

---

## How It Works

```text
Import a Paper
      ↓
Read & Select Text
      ↓
Explain / Simplify
      ↓
Get an AI Response
      ↓
Automatically Saved
      ↓
Revisit Anytime
```
PaperCave keeps the interaction close to the paper itself, so understanding something doesn't require constantly leaving your reading context.

---

## Tech Stack

| Technology            | Used For                                                  |
| --------------------- | --------------------------------------------------------- |
| **Swift**             | Core application development                              |
| **SwiftUI**           | User interface and application flow                       |
| **PDFKit**            | PDF rendering, navigation, and text selection             |
| **Foundation Models** | On-device AI for explaining and simplifying selected text |
| **SwiftData**         | Local persistence for papers and previous interactions    |

The project currently focuses on Apple's native frameworks and on-device capabilities.

---

## What I Learned

PaperCave is not only about building the final app. A major goal of this project was understanding more of what happens behind the features I was building instead of simply relying on an LLM to generate the implementation. Some of the things I explored along the way:

* Working with Apple's **Foundation Models** framework and `LanguageModelSession`
* Understanding prompts, instructions, and model sessions
* Using **guided generation** with `@Generable`
* Connecting **PDFKit** with SwiftUI
* Handling PDF text selection through `PDFSelection`
* Bridging PDFKit events into SwiftUI using `Coordinator`, `NotificationCenter`, `@State`, and `@Binding`
* Designing local data persistence using **SwiftData**
* Structuring AI interactions so they can be saved and revisited later

The project became an opportunity to understand not only *how to make a feature work*, but also *why it works*.

---

## Current Status

> 🚧 **Work in Progress**

PaperCave is currently an experimental project and is still actively being developed. The current version focuses on completing the core reading and learning experience:
**Read → Select → Understand → Save → Revisit**

The app is not intended to be production-ready yet. There are still areas that need further iteration, particularly around the reading experience, AI context, interaction flow, and overall UI/UX. The goal for the current stage is to build a solid foundation first before exploring more advanced ways of helping readers understand and connect ideas across academic papers.
