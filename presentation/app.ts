type Accent = 'blue' | 'gold' | 'green' | 'red' | 'neutral';

type IconName =
  | 'user' | 'agent' | 'brain' | 'model' | 'check'
  | 'question' | 'bolt' | 'chart' | 'route' | 'shield'
  | 'ticket' | 'arrowUp' | 'severity' | 'ban' | 'chat'
  | 'document' | 'gear';

interface SlideDefinition {
  kicker: string;
  corner: string;
  titleHtml: string;
  subtitleHtml: string;
  bodyHtml: string;
  note: string;
}

const iconPaths: Record<IconName, string> = {
  user: '<circle cx="12" cy="8" r="3.5"/><path d="M5.5 20c.7-4 3-6 6.5-6s5.8 2 6.5 6"/>',
  agent: '<rect x="5" y="6" width="14" height="12" rx="3"/><path d="M9 10h.01M15 10h.01M9 15h6M12 3v3"/>',
  brain: '<path d="M9.5 4.5A3.5 3.5 0 0 0 6 8c-2.2.2-3.5 2-3.5 4S3.8 15.8 6 16a3.5 3.5 0 0 0 6 2.4A3.5 3.5 0 0 0 18 16c2.2-.2 3.5-2 3.5-4S20.2 8.2 18 8a3.5 3.5 0 0 0-6-2.4A3.5 3.5 0 0 0 9.5 4.5Z"/><path d="M12 5.5V19M8.5 9.5c1.4.3 2.3 1.1 3.5 2.5M15.5 9.5c-1.4.3-2.3 1.1-3.5 2.5"/>',
  model: '<rect x="4" y="5" width="16" height="14" rx="3"/><path d="M8 9h8M8 13h5M8 17h3"/>',
  check: '<circle cx="12" cy="12" r="9"/><path d="m8 12 2.5 2.5L16 9"/>',
  question: '<circle cx="12" cy="12" r="9"/><path d="M9.7 9a2.5 2.5 0 1 1 4.1 1.9c-1 .7-1.8 1.2-1.8 2.6M12 17h.01"/>',
  bolt: '<path d="M13 2 5.5 13H11l-1 9L18.5 11H13l0-9Z"/>',
  chart: '<path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/>',
  route: '<path d="M4 6h7a3 3 0 0 1 3 3v6a3 3 0 0 0 3 3h3"/><path d="m17 15 3 3-3 3M4 18h4"/>',
  shield: '<path d="M12 3 5 6v5c0 5 3.1 8.4 7 10 3.9-1.6 7-5 7-10V6l-7-3Z"/><path d="m9 12 2 2 4-4"/>',
  ticket: '<path d="M5 5h14v4a3 3 0 0 0 0 6v4H5v-4a3 3 0 0 0 0-6V5Z"/><path d="M12 8v8"/>',
  arrowUp: '<path d="M12 19V5M6 11l6-6 6 6"/><path d="M5 19h14"/>',
  severity: '<path d="M5 4h14v16H5z"/><path d="M8 16h2v1H8zM11 12h2v5h-2zM14 8h2v9h-2z"/>',
  ban: '<circle cx="12" cy="12" r="9"/><path d="M6 18 18 6"/>',
  chat: '<path d="M4 5h16v11H8l-4 4V5Z"/>',
  document: '<path d="M6 3h8l4 4v14H6z"/><path d="M14 3v5h5M9 12h6M9 16h6"/>',
  gear: '<circle cx="12" cy="12" r="3"/><path d="M19 12a7 7 0 0 0-.1-1l2-1.5-2-3.4-2.4 1A8 8 0 0 0 15 6l-.3-2.6h-4L10.4 6a8 8 0 0 0-1.5.9l-2.4-1-2 3.4 2 1.5a7 7 0 0 0 0 2L4.5 14l2 3.4 2.4-1c.5.4 1 .7 1.5.9l.3 2.6h4l.3-2.6a8 8 0 0 0 1.5-.9l2.4 1 2-3.4-2-1.5c.1-.3.1-.7.1-1Z"/>'
};

function icon(name: IconName, accent: Accent = 'blue'): string {
  const cls = accent === 'neutral' ? '' : ` ${accent}`;
  return `<span class="icon-badge${cls}"><svg viewBox="0 0 24 24" aria-hidden="true">${iconPaths[name]}</svg></span>`;
}

function flowNode(name: IconName, title: string, text: string, accent: Accent = 'blue', extra = ''): string {
  return `<div class="panel flow-node ${extra}">${icon(name, accent)}<h3>${title}</h3><p>${text}</p></div>`;
}

function card(iconName: IconName, heading: string, text: string, accent: Accent = 'blue'): string {
  return `<div class="card">${icon(iconName, accent)}<h2>${heading}</h2><p>${text}</p></div>`;
}

function featureRow(iconName: IconName, text: string, accent: Accent = 'blue'): string {
  return `<div class="feature-row">${icon(iconName, accent)}<span>${text}</span></div>`;
}

const slides: SlideDefinition[] = [
  {
    kicker: 'Simple<br>Faster<br>Smarter<br>AI Workflows',
    corner: 'Right Model<br>For Every Task',
    titleHtml: 'What Is <span class="highlight-gold">JEV?</span>',
    subtitleHtml: '<span class="highlight-blue">A fast decision model</span> for routing AI work',
    bodyHtml: `
      <div class="content">
        <div class="flow-grid">
          ${flowNode('user','User Request','A question, task,<br>or goal','blue')}
          <div class="flow-arrow">→</div>
          ${flowNode('agent','Agent','Understands intent<br>and prepares context','blue')}
          <div class="flow-arrow gold">→</div>
          ${flowNode('brain','JEV','Chooses the best model<br>for the task','gold','jev')}
          <div class="flow-arrow gold">→</div>
          ${flowNode('model','Best Model','Routes to the right<br>AI model','blue')}
          <div class="flow-arrow">→</div>
          ${flowNode('check','Final Answer','Accurate, helpful<br>response','green')}
        </div>
        <div class="callout">JEV is the decision-maker, <strong>not the worker.</strong></div>
        <div class="pill-row">
          <span class="pill">TypeSafe</span><span class="pill">System One</span><span class="pill gold">Claude</span><span class="pill">GPT</span><span class="pill">Codex</span>
        </div>
      </div>`,
    note: 'JEV is a decision layer: it helps an agent choose the right model before the real work begins.'
  },
  {
    kicker: 'Route<br>Judge<br>Decide',
    corner: 'The Question<br>Behind JEV',
    titleHtml: 'Where Did the Idea <span class="highlight-gold">Come From?</span>',
    subtitleHtml: '<span class="highlight-blue">The question</span> behind JEV',
    bodyHtml: `
      <div class="content">
        <div class="cards-3">
          ${card('question','The Core Question','Why ask a large LLM to generate paragraphs when software often needs only a <strong class="highlight-blue">decision?</strong>','blue')}
          ${card('brain','System 1 Inspiration','JEV follows fast, intuitive decision-making — inspired by <strong class="highlight-blue">Daniel Kahneman</strong>, <strong class="highlight-gold">System 1</strong> vs. <strong class="highlight-blue">System 2</strong>.','gold')}
          ${card('chart','Why the name JEV?','Named after <strong class="highlight-blue">William Stanley Jevons</strong> and the <strong class="highlight-gold">Jevons paradox</strong>: when efficiency improves, total usage can grow.','green')}
        </div>
        <div class="callout">Built by <span class="highlight-blue">TypeSafe</span> as a <span class="highlight-gold">“System One”</span> decision model for automation.</div>
      </div>`,
    note: 'The idea starts from one question: why generate paragraphs when software often needs only a decision?'
  },
  {
    kicker: 'Route<br>Map<br>Execute',
    corner: 'It Decides<br>Models Execute',
    titleHtml: 'How <span class="highlight-gold">JEV</span> Works',
    subtitleHtml: '<span class="highlight-blue">It decides.</span> Another model executes.',
    bodyHtml: `
      <div class="content">
        <div class="flow-grid">
          ${flowNode('user','User Request','A goal or coding task','blue')}
          <div class="flow-arrow">→</div>
          ${flowNode('agent','Agent','Prepares context','blue')}
          <div class="flow-arrow gold">→</div>
          ${flowNode('brain','JEV','Chooses the tier','gold','jev')}
          <div class="flow-arrow gold">→</div>
          ${flowNode('route','Chosen Tier','FAST / BALANCED / STRONG','green')}
          <div class="flow-arrow">→</div>
          ${flowNode('model','Execution Model','Does the real work','blue')}
        </div>
        <div class="callout">JEV is the router, <strong>not the worker.</strong></div>
        <div class="tier-grid">
          <div class="tier-card"><span class="pill">FAST</span><h3>Claude Haiku</h3><p>Small model for simple tasks</p></div>
          <div class="tier-card"><span class="pill gold">BALANCED</span><h3>Claude Sonnet</h3><p>Mid-tier model for most tasks</p></div>
          <div class="tier-card"><span class="pill green">STRONG</span><h3>Claude Opus</h3><p>Best-quality model for complex tasks</p></div>
          <div class="tier-card"><h3>Flexible mapping</h3><p>The same tiers can point to <strong>GPT</strong>, <strong>Claude</strong>, <strong>Gemini</strong>, or other models.</p></div>
        </div>
      </div>`,
    note: 'JEV decides the tier; another model executes the work.'
  },
  {
    kicker: 'Typed<br>Useful<br>Structured',
    corner: 'No Long Essays',
    titleHtml: 'What Kind of Answers Does <span class="highlight-gold">JEV</span> Return?',
    subtitleHtml: 'Structured outputs, not long essays',
    bodyHtml: `
      <div class="content">
        <div class="cards-3">
          <div class="card">${icon('check','blue')}<h2 class="highlight-blue">Choice</h2><p>Pick one option from a defined list.</p><div class="code">FAST 0.91<br>BALANCED 0.07<br>STRONG 0.02</div><p>Best for routing or tool selection</p></div>
          <div class="card">${icon('chart','blue')}<h2 class="highlight-blue">Score</h2><p>Return a value on a scale.</p><div class="code">Complexity score<br><strong>4.6 / 5</strong></div><p>Best for ranking risk, difficulty, or urgency</p></div>
          <div class="card">${icon('shield','blue')}<h2 class="highlight-blue">Noul</h2><p>Return the probability of a statement being true.</p><div class="code">Needs deep reasoning<br><strong>0.93</strong></div><p>Best for yes/no confidence judgments</p></div>
        </div>
        <div class="callout"><span class="highlight-blue">Typed answers</span> are easier for software to use than free-form text.</div>
      </div>`,
    note: 'JEV returns typed outputs such as Choice, Score, and Noul.'
  },
  {
    kicker: 'Faster<br>Cheaper<br>Smarter',
    corner: 'Better Automation',
    titleHtml: 'Why Teams Use <span class="highlight-gold">JEV</span>',
    subtitleHtml: 'Faster decisions, lower cost, better automation',
    bodyHtml: `
      <div class="content">
        <div class="cards-4">
          <div class="card benefit-card">${icon('bolt','blue')}<h3>Lower <span class="highlight-blue">latency</span></h3><p>A fast decision layer can be quicker than asking a large model to reason in text.</p></div>
          <div class="card benefit-card">${icon('chart','gold')}<h3>Lower <span class="highlight-gold">cost</span></h3><p>Use expensive models only when the task truly needs them.</p></div>
          <div class="card benefit-card">${icon('route','green')}<h3>Better <span class="highlight-blue">routing</span></h3><p>Simple tasks go to lighter models; hard tasks go to stronger ones.</p></div>
          <div class="card benefit-card">${icon('shield','gold')}<h3>Calibrated <span class="highlight-gold">confidence</span></h3><p>JEV returns probabilities, not just guesses.</p></div>
        </div>
        <div class="callout"><span class="highlight-blue">TypeSafe</span> says JEV is trained for calibrated decisions using <span class="highlight-gold">RLCD</span>.</div>
        <div class="comparison">
          <div class="panel comparison-box"><h3>Traditional Path</h3><p>Big LLM reasons → software parses text</p></div>
          <div class="vs">VS</div>
          <div class="panel comparison-box emphasis"><h3>JEV Path</h3><p>JEV decides → best model executes</p></div>
        </div>
        <div class="takeaway">The goal is not to replace LLMs — <span class="highlight-blue">it is to use them more intelligently.</span></div>
      </div>`,
    note: 'The value is speed, cost control, routing quality, and calibrated confidence.'
  },
  {
    kicker: 'Route<br>Judgment<br>Accelerate',
    corner: 'Where It Fits',
    titleHtml: 'Where <span class="highlight-gold">JEV</span> Fits',
    subtitleHtml: 'What it does — and what it does not do',
    bodyHtml: `
      <div class="content">
        <div class="columns-2">
          <div class="panel list-card">
            <h2><span class="highlight-blue">Great</span> use cases</h2>
            <div class="feature-list">
              ${featureRow('route','Model routing','blue')}
              ${featureRow('check','Tool permission checks','blue')}
              ${featureRow('shield','Fraud or risk flags','blue')}
              ${featureRow('ticket','Support ticket triage','blue')}
              ${featureRow('arrowUp','Review / escalation decisions','blue')}
              ${featureRow('severity','Incident severity scoring','blue')}
            </div>
          </div>
          <div class="panel list-card">
            <h2><span class="highlight-gold">Important</span> limits</h2>
            <div class="feature-list">
              ${featureRow('ban','JEV does not replace <strong>Claude</strong> or <strong>GPT</strong>','red')}
              ${featureRow('chat','JEV is not a chat assistant','red')}
              ${featureRow('document','JEV does not write long answers for users','red')}
              ${featureRow('gear','JEV works best as a decision layer inside <strong class="highlight-blue">agents</strong> and <strong class="highlight-gold">automation</strong> systems','red')}
            </div>
          </div>
        </div>
        <div class="takeaway"><span class="highlight-blue">In one sentence:</span> JEV helps an agent choose the right model before the real work begins.</div>
        <div class="pill-row"><span class="pill">Next topic</span><span class="pill gold">rule-based routing</span><span class="pill">Laya</span></div>
      </div>`,
    note: 'JEV fits inside agents and automation systems; it does not replace Claude or GPT.'
  }
];

const host = document.querySelector<HTMLElement>('#slideHost')!;
const rail = document.querySelector<HTMLElement>('#progressRail')!;
const counter = document.querySelector<HTMLElement>('#counter')!;
const play = document.querySelector<HTMLButtonElement>('#play')!;
const notesPanel = document.querySelector<HTMLElement>('#notesPanel')!;
const notesButton = document.querySelector<HTMLButtonElement>('#notesButton')!;

let current = 0;
let playing = false;
let timer: number | undefined;

function slideMarkup(slide: SlideDefinition, index: number): string {
  return `
    <article class="slide${index === 0 ? ' active' : ''}" data-index="${index}">
      <header class="slide-header">
        <div class="kicker">${slide.kicker}</div>
        <div class="slide-title"><h1>${slide.titleHtml}</h1><p>${slide.subtitleHtml}</p></div>
        <div class="corner-label">${slide.corner}</div>
      </header>
      ${slide.bodyHtml}
    </article>`;
}

host.innerHTML = slides.map(slideMarkup).join('');
rail.innerHTML = slides.map((_, i) => `<button class="progress-dot${i === 0 ? ' active' : ''}" data-slide="${i}" aria-label="Go to slide ${i + 1}"></button>`).join('');

const slideEls = [...document.querySelectorAll<HTMLElement>('.slide')];
const dotEls = [...document.querySelectorAll<HTMLButtonElement>('.progress-dot')];

function formatIndex(index: number): string {
  return String(index + 1).padStart(2, '0');
}

function render(): void {
  slideEls.forEach((el, i) => el.classList.toggle('active', i === current));
  dotEls.forEach((el, i) => el.classList.toggle('active', i === current));
  counter.innerHTML = `${formatIndex(current)}<span>/${String(slides.length).padStart(2, '0')}</span>`;
  notesPanel.textContent = slides[current].note;
}

function go(index: number): void {
  current = (index + slides.length) % slides.length;
  render();
}
function next(): void { go(current + 1); }
function previous(): void { go(current - 1); }

function setPlaying(nextState: boolean): void {
  playing = nextState;
  play.textContent = playing ? 'Ⅱ' : '▶';
  play.setAttribute('aria-label', playing ? 'Pause autoplay' : 'Play automatically');
  if (timer !== undefined) window.clearInterval(timer);
  timer = undefined;
  if (playing) timer = window.setInterval(next, 6500);
}

function toggleFullscreen(): void {
  if (!document.fullscreenElement) document.documentElement.requestFullscreen?.();
  else document.exitFullscreen?.();
}

function toggleNotes(): void {
  const nextState = !notesPanel.classList.contains('show');
  notesPanel.classList.toggle('show', nextState);
  notesPanel.setAttribute('aria-hidden', String(!nextState));
  notesButton.classList.toggle('rail-btn-primary', nextState);
}

document.querySelector<HTMLButtonElement>('#prev')!.addEventListener('click', previous);
document.querySelector<HTMLButtonElement>('#next')!.addEventListener('click', next);
play.addEventListener('click', () => setPlaying(!playing));
document.querySelector<HTMLButtonElement>('#fullscreen')!.addEventListener('click', toggleFullscreen);
notesButton.addEventListener('click', toggleNotes);
dotEls.forEach((dot, i) => dot.addEventListener('click', () => go(i)));

document.addEventListener('keydown', (event) => {
  if (event.key === 'ArrowRight' || event.key === 'PageDown' || event.key === ' ') {
    next();
    event.preventDefault();
  } else if (event.key === 'ArrowLeft' || event.key === 'PageUp') {
    previous();
    event.preventDefault();
  } else if (event.key.toLowerCase() === 'f') {
    toggleFullscreen();
  } else if (event.key.toLowerCase() === 'n') {
    toggleNotes();
  } else if (event.key.toLowerCase() === 'p') {
    setPlaying(!playing);
  }
});

render();