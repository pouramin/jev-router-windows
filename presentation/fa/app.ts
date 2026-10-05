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
    kicker: 'گردش‌کارهای AI<br>ساده‌تر<br>سریع‌تر<br>هوشمندتر',
    corner: 'مدل مناسب<br>برای هر کار',
    titleHtml: 'مدل <span class="ltr highlight-gold">JEV</span> چیست؟',
    subtitleHtml: 'یک <span class="highlight-blue">مدل تصمیم‌گیری سریع</span> برای مسیریابی کارهای AI',
    bodyHtml: `
      <div class="content">
        <div class="flow-grid">
          ${flowNode('user','درخواست کاربر','یک سؤال، وظیفه<br>یا هدف','blue')}
          <div class="flow-arrow">←</div>
          ${flowNode('agent','Agent','منظور را می‌فهمد<br>و Context را آماده می‌کند','blue')}
          <div class="flow-arrow gold">←</div>
          ${flowNode('brain','JEV','بهترین مدل را<br>برای کار انتخاب می‌کند','gold','jev')}
          <div class="flow-arrow gold">←</div>
          ${flowNode('model','مدل مناسب','درخواست به مدل<br>مناسب می‌رود','blue')}
          <div class="flow-arrow">←</div>
          ${flowNode('check','پاسخ نهایی','خروجی دقیق<br>و مفید','green')}
        </div>
        <div class="callout"><span class="ltr">JEV</span> تصمیم‌گیرنده است، <strong>نه اجراکننده.</strong></div>
        <div class="pill-row">
          <span class="pill ltr">TypeSafe</span><span class="pill ltr">System One</span><span class="pill gold ltr">Claude</span><span class="pill ltr">GPT</span><span class="pill ltr">Codex</span>
        </div>
      </div>`,
    note: 'مدل JEV یک لایه‌ی تصمیم‌گیری است؛ قبل از شروع کار واقعی به Agent کمک می‌کند مدل مناسب را انتخاب کند.'
  },
  {
    kicker: 'مسیریابی<br>قضاوت<br>تصمیم',
    corner: 'سؤال اصلی<br>پشت JEV',
    titleHtml: 'ایده‌ی <span class="ltr highlight-gold">JEV</span> از کجا آمد؟',
    subtitleHtml: 'سؤالی که پشت <span class="ltr highlight-blue">JEV</span> قرار دارد',
    bodyHtml: `
      <div class="content">
        <div class="cards-3">
          ${card('question','سؤال اصلی','چرا از یک LLM بزرگ بخواهیم چند پاراگراف تولید کند، وقتی نرم‌افزار اغلب فقط به یک <strong class="highlight-blue">تصمیم</strong> نیاز دارد؟','blue')}
          ${card('brain','الهام از System 1','مدل JEV از تصمیم‌گیری سریع و شهودی الهام می‌گیرد؛ همان تفکیک معروف <strong class="ltr highlight-blue">Daniel Kahneman</strong> بین <strong class="ltr highlight-gold">System 1</strong> و <strong class="ltr highlight-blue">System 2</strong>.','gold')}
          ${card('chart','چرا نام JEV؟','این نام از <strong class="ltr highlight-blue">William Stanley Jevons</strong> و <strong class="ltr highlight-gold">Jevons paradox</strong> می‌آید: وقتی بهره‌وری بیشتر می‌شود، مصرف کلی یک منبع می‌تواند افزایش پیدا کند.','green')}
        </div>

        <div class="origin-lower-grid">
          <div class="panel founder-card">
            <div class="founder-icon">${icon('user','blue')}</div>
            <div>
              <span class="origin-eyebrow ltr">FOUNDER &amp; CEO</span>
              <h2 class="ltr">Diogo Almeida</h2>
              <p>بنیان‌گذار و مدیرعامل شرکت <strong class="ltr highlight-blue">TypeSafe</strong>؛ پژوهشگر سابق <span class="ltr">OpenAI</span> و پیش‌تر عضو <span class="ltr">Google Brain</span>.</p>
            </div>
          </div>
          <div class="panel system-compare">
            <div class="system-card system-one">
              <span class="system-label ltr">System 1</span>
              <h3>سریع و شهودی</h3>
              <p>قضاوت‌های سریع، خودکار و کم‌زحمت که بدون تحلیل طولانی انجام می‌شوند.</p>
            </div>
            <div class="system-vs ltr">VS</div>
            <div class="system-card system-two">
              <span class="system-label ltr">System 2</span>
              <h3>آهسته و تحلیلی</h3>
              <p>استدلال آگاهانه، مرحله‌به‌مرحله و پرزحمت برای تصمیم‌های پیچیده‌تر.</p>
            </div>
          </div>
        </div>
        <div class="callout">شرکت <span class="ltr highlight-blue">TypeSafe</span> مدل JEV را به‌عنوان یک مدل تصمیم‌گیری <span class="ltr highlight-gold">System One</span> برای Automation معرفی کرده است.</div>
      </div>`,
    note: 'شرکت TypeSafe توسط Diogo Almeida هدایت می‌شود. ایده‌ی JEV از تفاوت System 1 سریع و شهودی با System 2 آهسته و تحلیلی الهام می‌گیرد.'
  },
  {
    kicker: 'مسیریابی<br>انتخاب<br>اجرا',
    corner: 'JEV تصمیم می‌گیرد<br>مدل‌ها اجرا می‌کنند',
    titleHtml: '<span class="ltr highlight-gold">JEV</span> چطور کار می‌کند؟',
    subtitleHtml: '<span class="ltr highlight-blue">JEV</span> تصمیم می‌گیرد؛ یک مدل دیگر کار را انجام می‌دهد.',
    bodyHtml: `
      <div class="content">
        <div class="flow-grid">
          ${flowNode('user','درخواست کاربر','یک هدف یا Coding task','blue')}
          <div class="flow-arrow">←</div>
          ${flowNode('agent','Agent','Context را آماده می‌کند','blue')}
          <div class="flow-arrow gold">←</div>
          ${flowNode('brain','JEV','سطح مناسب را انتخاب می‌کند','gold','jev')}
          <div class="flow-arrow gold">←</div>
          ${flowNode('route','سطح انتخاب‌شده','FAST / BALANCED / STRONG','green')}
          <div class="flow-arrow">←</div>
          ${flowNode('model','مدل اجراکننده','کار واقعی را انجام می‌دهد','blue')}
        </div>
        <div class="callout"><span class="ltr">JEV</span> Router است، <strong>نه Worker.</strong></div>
        <div class="tier-grid">
          <div class="tier-card"><span class="pill ltr">FAST</span><h3 class="ltr">Claude Haiku</h3><p>مدل سبک برای کارهای ساده</p></div>
          <div class="tier-card"><span class="pill gold ltr">BALANCED</span><h3 class="ltr">Claude Sonnet</h3><p>مدل میانی برای بیشتر کارها</p></div>
          <div class="tier-card"><span class="pill green ltr">STRONG</span><h3 class="ltr">Claude Opus</h3><p>مدل قوی برای کارهای پیچیده</p></div>
          <div class="tier-card"><h3>نگاشت انعطاف‌پذیر</h3><p>همین سطح‌ها می‌توانند به <strong class="ltr">GPT</strong>، <strong class="ltr">Claude</strong>، <strong class="ltr">Gemini</strong> یا مدل‌های دیگر متصل شوند.</p></div>
        </div>
      </div>`,
    note: 'مدل JEV فقط سطح مناسب را انتخاب می‌کند؛ مدل دیگری اجرای واقعی کار را برعهده می‌گیرد.'
  },
  {
    kicker: 'ساختاریافته<br>قابل‌استفاده<br>Typed',
    corner: 'بدون متن‌های طولانی',
    titleHtml: '<span class="ltr highlight-gold">JEV</span> چه نوع پاسخی برمی‌گرداند؟',
    subtitleHtml: 'خروجی ساختاریافته، نه مقاله‌ی طولانی',
    bodyHtml: `
      <div class="content">
        <div class="cards-3">
          <div class="card">${icon('check','blue')}<h2 class="ltr highlight-blue">Choice</h2><p>یک گزینه را از فهرست تعریف‌شده انتخاب می‌کند.</p><div class="code">FAST 0.91<br>BALANCED 0.07<br>STRONG 0.02</div><p>مناسب برای Routing یا انتخاب Tool</p></div>
          <div class="card">${icon('chart','blue')}<h2 class="ltr highlight-blue">Score</h2><p>یک مقدار را روی یک مقیاس برمی‌گرداند.</p><div class="code">Complexity score<br><strong>4.6 / 5</strong></div><p>مناسب برای رتبه‌بندی ریسک، سختی یا فوریت</p></div>
          <div class="card">${icon('shield','blue')}<h2 class="ltr highlight-blue">Noul</h2><p>احتمال درست‌بودن یک گزاره را برمی‌گرداند.</p><div class="code">Needs deep reasoning<br><strong>0.93</strong></div><p>مناسب برای تصمیم‌های احتمالی بله/خیر</p></div>
        </div>
        <div class="callout"><span class="highlight-blue">پاسخ‌های Typed</span> برای نرم‌افزار قابل‌استفاده‌تر از متن آزاد هستند.</div>
      </div>`,
    note: 'خروجی JEV می‌تواند از نوع Choice، Score یا Noul باشد؛ یعنی خروجی‌هایی که نرم‌افزار مستقیم می‌تواند از آن‌ها استفاده کند.'
  },
  {
    kicker: 'سریع‌تر<br>ارزان‌تر<br>هوشمندتر',
    corner: 'Automation بهتر',
    titleHtml: 'چرا تیم‌ها از <span class="ltr highlight-gold">JEV</span> استفاده می‌کنند؟',
    subtitleHtml: 'تصمیم سریع‌تر، هزینه کمتر، Automation بهتر',
    bodyHtml: `
      <div class="content">
        <div class="cards-4">
          <div class="card benefit-card">${icon('bolt','blue')}<h3><span class="highlight-blue">Latency</span> کمتر</h3><p>یک لایه‌ی تصمیم‌گیری سریع می‌تواند بسیار سریع‌تر از Reasoning متنی یک مدل بزرگ باشد.</p></div>
          <div class="card benefit-card">${icon('chart','gold')}<h3><span class="highlight-gold">هزینه</span> کمتر</h3><p>مدل‌های گران فقط زمانی استفاده می‌شوند که کار واقعاً به آن‌ها نیاز داشته باشد.</p></div>
          <div class="card benefit-card">${icon('route','green')}<h3><span class="highlight-blue">Routing</span> بهتر</h3><p>کارهای ساده به مدل‌های سبک و کارهای سخت به مدل‌های قوی‌تر می‌روند.</p></div>
          <div class="card benefit-card">${icon('shield','gold')}<h3><span class="highlight-gold">Confidence</span> کالیبره‌شده</h3><p>مدل JEV احتمال برمی‌گرداند، نه فقط یک حدس بدون Confidence.</p></div>
        </div>
        <div class="callout">شرکت <span class="ltr highlight-blue">TypeSafe</span> می‌گوید JEV برای تصمیم‌های کالیبره‌شده با روش <span class="ltr highlight-gold">RLCD</span> آموزش دیده است.</div>
        <div class="comparison">
          <div class="panel comparison-box"><h3>مسیر معمول</h3><p>LLM بزرگ Reasoning می‌کند ← نرم‌افزار متن را Parse می‌کند</p></div>
          <div class="vs ltr">VS</div>
          <div class="panel comparison-box emphasis"><h3>مسیر JEV</h3><p>JEV تصمیم می‌گیرد ← بهترین مدل اجرا می‌کند</p></div>
        </div>
        <div class="takeaway">هدف جایگزین‌کردن LLMها نیست؛ <span class="highlight-blue">هدف استفاده‌ی هوشمندانه‌تر از آن‌هاست.</span></div>
      </div>`,
    note: 'ارزش اصلی JEV در سرعت، کنترل هزینه، Routing بهتر و Confidence کالیبره‌شده است.'
  },
  {
    kicker: 'مسیریابی<br>قضاوت<br>شتاب',
    corner: 'جایگاه JEV',
    titleHtml: 'جایگاه <span class="ltr highlight-gold">JEV</span> کجاست؟',
    subtitleHtml: 'چه کاری انجام می‌دهد و چه کاری انجام نمی‌دهد',
    bodyHtml: `
      <div class="content">
        <div class="columns-2">
          <div class="panel list-card">
            <h2><span class="highlight-blue">کاربردهای</span> مناسب</h2>
            <div class="feature-list">
              ${featureRow('route','Model routing','blue')}
              ${featureRow('check','بررسی Permission برای Toolها','blue')}
              ${featureRow('shield','شناسایی Fraud یا Risk','blue')}
              ${featureRow('ticket','دسته‌بندی Support ticket','blue')}
              ${featureRow('arrowUp','تصمیم برای Review یا Escalation','blue')}
              ${featureRow('severity','امتیازدهی شدت Incident','blue')}
            </div>
          </div>
          <div class="panel list-card">
            <h2><span class="highlight-gold">محدودیت‌های</span> مهم</h2>
            <div class="feature-list">
              ${featureRow('ban','مدل JEV جای <strong class="ltr">Claude</strong> یا <strong class="ltr">GPT</strong> را نمی‌گیرد','red')}
              ${featureRow('chat','مدل JEV یک Chat assistant نیست','red')}
              ${featureRow('document','مدل JEV برای کاربر پاسخ‌های طولانی تولید نمی‌کند','red')}
              ${featureRow('gear','مدل JEV بهترین عملکرد را به‌عنوان یک لایه‌ی تصمیم‌گیری داخل <strong class="ltr highlight-blue">Agent</strong>ها و سیستم‌های <strong class="ltr highlight-gold">Automation</strong> دارد','red')}
            </div>
          </div>
        </div>
        <div class="takeaway"><span class="highlight-blue">در یک جمله:</span> مدل JEV قبل از شروع کار واقعی به Agent کمک می‌کند مدل مناسب را انتخاب کند.</div>
        <div class="pill-row"><span class="pill">موضوع بعدی</span><span class="pill gold">Rule-based routing</span><span class="pill ltr">Laya</span></div>
      </div>`,
    note: 'جایگاه JEV داخل Agentها و سیستم‌های Automation است؛ نه جایگزین Claude یا GPT.'

  },
  {
    kicker: 'رایگان<br>متن‌باز<br>جایگزین‌ها',
    corner: 'سبک ← سنگین',
    titleHtml: '۵ جایگزین رایگان برای <span class="ltr highlight-gold">JEV</span>',
    subtitleHtml: 'مدل‌های <span class="highlight-blue">مسیریابی و تصمیم‌گیری متن‌باز</span> با نیاز سخت‌افزاری متفاوت',
    bodyHtml: `
      <div class="content alt-slide">
        <div class="callout">از گزینه‌های مناسب <strong>CPU</strong> تا Routerهای تحقیقاتی با مصرف منابع بالا.</div>
        <div class="resource-spectrum panel">
          <div class="spectrum-labels"><span>خیلی سبک</span><span>مصرف منابع بالا</span></div>
          <div class="spectrum-line">
            <span class="spectrum-stop light" style="left: 7%;"><b class="ltr">Laya</b><small class="ltr">322M–421M</small></span>
            <span class="spectrum-stop mid" style="left: 29%;"><b class="ltr">JevK5</b><small class="ltr">4B / 9B</small></span>
            <span class="spectrum-stop mid" style="left: 49%;"><b class="ltr">SemIf</b><small class="ltr">4B</small></span>
            <span class="spectrum-stop heavy" style="left: 72%;"><b class="ltr">Nimble</b><small class="ltr">9B</small></span>
            <span class="spectrum-stop max" style="left: 92%;"><b class="ltr">Open Alt</b><small class="ltr">0.6B–27B</small></span>
          </div>
        </div>
        <div class="alt-grid-5">
          <div class="card alt-card">
            <div class="alt-head"><div>${icon('bolt','green')}</div><div><h3 class="ltr">Laya</h3><span class="resource-pill green">خیلی کم</span></div></div>
            <p>اندازه مدل: <strong class="ltr">322M–421M</strong></p>
            <p>اجرای منطقی: روی <span class="ltr">CPU</span> یا حدود <span class="ltr">2–3GB</span> حافظه GPU</p>
            <p>گیت‌هاب: <a class="ltr" href="https://github.com/haddock-development/laya_new" target="_blank" rel="noopener">haddock-development/laya_new</a></p>
          </div>
          <div class="card alt-card">
            <div class="alt-head"><div>${icon('route','blue')}</div><div><h3 class="ltr">JevK5</h3><span class="resource-pill blue">متوسط</span></div></div>
            <p>اندازه مدل: <strong class="ltr">4B / 9B</strong></p>
            <p>اجرای منطقی: روی CPU با <span class="ltr">GGUF</span> یا حدود <span class="ltr">9GB VRAM</span> برای مدل <span class="ltr">4B BF16</span></p>
            <p>گیت‌هاب: <a class="ltr" href="https://github.com/allebee/jevk5" target="_blank" rel="noopener">allebee/jevk5</a></p>
          </div>
          <div class="card alt-card">
            <div class="alt-head"><div>${icon('chart','blue')}</div><div><h3 class="ltr">SemIf</h3><span class="resource-pill blue">متوسط</span></div></div>
            <p>اندازه مدل: <strong class="ltr">4B</strong></p>
            <p>اجرای منطقی: روی CPU با <span class="ltr">GGUF</span> یا حدود <span class="ltr">10–12GB VRAM</span></p>
            <p>گیت‌هاب: <a class="ltr" href="https://github.com/stevewithington/semif" target="_blank" rel="noopener">stevewithington/semif</a></p>
          </div>
          <div class="card alt-card">
            <div class="alt-head"><div>${icon('brain','gold')}</div><div><h3 class="ltr">Bespoke Nimble</h3><span class="resource-pill gold">زیاد</span></div></div>
            <p>اندازه مدل: <strong class="ltr">9B</strong></p>
            <p>اجرای منطقی: GPU قوی یا <span class="ltr">Apple Silicon</span> با RAM زیاد</p>
            <p>گیت‌هاب: <a class="ltr" href="https://github.com/bespokelabsai/nimble" target="_blank" rel="noopener">bespokelabsai/nimble</a></p>
          </div>
          <div class="card alt-card alt-card-wide">
            <div class="alt-head"><div>${icon('gear','red')}</div><div><h3 class="ltr">Open Alternative to Jev</h3><span class="resource-pill red">متغیر تا خیلی زیاد</span></div></div>
            <p>اندازه مدل: <strong class="ltr">0.6B–27B</strong></p>
            <p>اجرای منطقی: از یک سیستم معمولی تا حدود <span class="ltr">35GB</span> حافظه GPU</p>
            <p>گیت‌هاب: <a class="ltr" href="https://github.com/ikermoel/open-alternative-jev" target="_blank" rel="noopener">ikermoel/open-alternative-jev</a></p>
          </div>
        </div>
      </div>`,
    note: 'اسلاید آخر پنج جایگزین رایگان JEV را از گزینه‌های سبک و CPU-friendly تا پروژه‌های سنگین‌تر مقایسه می‌کند.'

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
    <article class="slide${index === 0 ? ' active' : ''}" data-index="${index}" dir="rtl" lang="fa">
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