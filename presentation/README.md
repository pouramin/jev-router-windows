# JEV Visual Deck

Browser-playable presentation for the JEV explainer video.

## Stack

- HTML
- CSS
- TypeScript
- Inline SVG icons
- No runtime framework or external CDN required

## Build

```bash
cd presentation
npm install
npm run build
```

The TypeScript source is `app.ts` and the browser loads the compiled `app.js`.

## Controls

- Arrow keys / Page Up / Page Down: navigate
- Space: next slide
- P: autoplay
- F: fullscreen
- N: speaker notes

The compact controls are intentionally vertical on the left so they never cover slide content.
