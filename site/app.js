document.querySelectorAll('.bento-card').forEach(card => {
  card.addEventListener('mousemove', e => {
    const rect = card.getBoundingClientRect();
    card.style.setProperty('--mouse-x', `${e.clientX - rect.left}px`);
    card.style.setProperty('--mouse-y', `${e.clientY - rect.top}px`);
  });
});

const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) entry.target.classList.add('active');
  });
}, { threshold: 0.1 });
document.querySelectorAll('.reveal').forEach(el => observer.observe(el));

async function copyText(text) {
  if (navigator.clipboard && window.isSecureContext) {
    try {
      await navigator.clipboard.writeText(text);
      showToast('Copied to clipboard');
      return;
    } catch {}
  }
  const textarea = document.createElement('textarea');
  textarea.value = text;
  document.body.appendChild(textarea);
  textarea.select();
  try {
    document.execCommand('copy');
    showToast('Copied to clipboard');
  } catch {
    showToast('Press Ctrl+C to copy');
  }
  document.body.removeChild(textarea);
}

let toastTimeout;
function showToast(msg) {
  const toast = document.getElementById('toast');
  document.getElementById('toast-message').textContent = msg;
  toast.classList.remove('translate-y-20', 'opacity-0');
  clearTimeout(toastTimeout);
  toastTimeout = setTimeout(() => toast.classList.add('translate-y-20', 'opacity-0'), 2400);
}

const simRoutes = {
  ollama: {
    req: `{\n  "model": "local/qwen2.5-coder",\n  "messages": [\n    { "role": "user", "content": "Optimize SQL query" }\n  ],\n  "stream": true\n}`,
    badge: '200 OK • 18ms',
    res: `→ Target: http://host.docker.internal:11434\n→ Provider: Ollama (Local GPU)\n→ Cost: $0.00000 (Local Inference)\n→ Cache: MISS • Tokens: 142 tok/s`
  },
  claude: {
    req: `{\n  "model": "claude-3-7-sonnet",\n  "messages": [\n    { "role": "user", "content": "Refactor AST parser" }\n  ],\n  "max_tokens": 4096\n}`,
    badge: '200 OK • 310ms',
    res: `→ Target: api.anthropic.com/v1/messages\n→ Provider: Anthropic (Cloud)\n→ Cost: $0.00412 (Budget: $19.84 left)\n→ Virtual Key: sk-dev-workstation`
  },
  deepseek: {
    req: `{\n  "model": "deepseek-reasoner",\n  "messages": [\n    { "role": "user", "content": "Prove consensus safety" }\n  ]\n}`,
    badge: '200 OK • 420ms',
    res: `→ Target: api.deepseek.com/v1\n→ Provider: DeepSeek R1\n→ Cost: $0.00089 • Reasoning Tokens: 612\n→ Rate Limit: 58/60 RPM remaining`
  },
  fallback: {
    req: `{\n  "model": "smart-coding-group",\n  "messages": [\n    { "role": "user", "content": "Generate unit tests" }\n  ]\n}`,
    badge: 'FAILOVER • 200 OK',
    res: `⚠ Primary (Ollama) busy → Triggered Fallback\n→ Rerouted: Groq (llama-3.3-70b-versatile)\n→ Speed: 490 tok/s • Zero Client Error\n→ Logged to Grafana Alerting`
  }
};

function selectSimRoute(routeKey) {
  const data = simRoutes[routeKey];
  document.getElementById('sim-request').innerHTML = `<code>${data.req}</code>`;
  document.getElementById('sim-response').innerHTML = `<code>${data.res}</code>`;
  document.getElementById('sim-badge').textContent = data.badge;
  document.querySelectorAll('.sim-tab').forEach(btn => {
    btn.classList.toggle('bg-indigo-600', btn.dataset.route === routeKey);
    btn.classList.toggle('text-white', btn.dataset.route === routeKey);
    btn.classList.toggle('text-slate-400', btn.dataset.route !== routeKey);
  });
}

const archData = {
  clients: {
    tag: 'INSPECTING: 01. INGRESS LAYER',
    title: 'Drop-in OpenAI API Compatibility',
    desc: 'Point any tool supporting OPENAI_API_BASE to http://localhost:4000/v1. Includes pre-built Bruno & Postman collections for 17+ test endpoints.',
    pills: ['Cline / Roo', 'Open WebUI', 'Bruno CLI']
  },
  gateway: {
    tag: 'INSPECTING: 02. LITELLM CORE PROXY',
    title: 'Virtual Keys, Redis Cache & Smart Routing',
    desc: 'Validates virtual keys against PostgreSQL, serves cached completions from Redis in <5ms, and enforces per-key budgets, retries, and cooldowns.',
    pills: ['PostgreSQL DB', 'Redis Cache', 'Rate Limiter']
  },
  upstreams: {
    tag: 'INSPECTING: 03. HYBRID MODEL MESH',
    title: 'Seamless Local GPU & Cloud Provider Orchestration',
    desc: 'Combines local Ollama, LM Studio, and vLLM servers with OpenAI, Anthropic, Gemini, DeepSeek, Grok, and Groq under unified model aliases.',
    pills: ['Ollama / vLLM', 'Anthropic / OpenAI', 'Gemini / Groq']
  }
};

function inspectNode(key) {
  const info = archData[key];
  document.getElementById('node-tag').textContent = info.tag;
  document.getElementById('node-title').textContent = info.title;
  document.getElementById('node-desc').textContent = info.desc;
  document.getElementById('node-pills').innerHTML = info.pills
    .map(p => `<span class="px-3 py-1 rounded-lg bg-white/5 text-xs font-mono text-slate-300">${p}</span>`)
    .join('');
}

const tunnelData = {
  tailscale: {
    badge: 'Recommended • Zero Open Ports',
    title: 'Tailscale Private WireGuard Mesh',
    desc: 'Expose your LiteLLM gateway exclusively to your authenticated devices over encrypted WireGuard without opening firewall ports or exposing a public URL.',
    features: ['MagicDNS HTTPS certificates out of the box', 'Docker Compose sidecar ready'],
    file: 'tunnels/tailscale/start-tailscale.sh',
    code: `cd tunnels/tailscale\nchmod +x start-tailscale.sh\n./start-tailscale.sh`
  },
  cloudflare: {
    badge: 'Zero-Trust Public Edge',
    title: 'Cloudflare Zero Trust Tunnel',
    desc: 'Publish your gateway to a custom subdomain with automatic TLS, DDoS protection, and Cloudflare Access policies—without port forwarding.',
    features: ['Custom domain HTTPS (e.g. llm.yourdomain.com)', 'Protected by Cloudflare Edge & Access'],
    file: 'tunnels/cloudflare/start-cloudflare.sh',
    code: `cd tunnels/cloudflare\nchmod +x start-cloudflare.sh\n./start-cloudflare.sh`
  },
  ngrok: {
    badge: 'Instant Webhook & Mobile Testing',
    title: 'ngrok Ephemeral or Static Edge',
    desc: 'Spin up an instant HTTPS endpoint in seconds for testing mobile AI apps or sharing temporary access with collaborators.',
    features: ['Built-in traffic inspector & replay', 'One-command Docker Compose launch'],
    file: 'tunnels/ngrok/start-ngrok.sh',
    code: `cd tunnels/ngrok\nchmod +x start-ngrok.sh\n./start-ngrok.sh`
  },
  ddns: {
    badge: 'Direct Self-Hosted Networking',
    title: 'Router Port Forwarding + Dynamic DNS',
    desc: 'Automated Dynamic DNS updater script for home routers with static port forwarding and reverse proxy TLS termination.',
    features: ['Automated IP change detection via setup-ddns.sh', 'Full control over network path & latency'],
    file: 'tunnels/port-forwarding/setup-ddns.sh',
    code: `cd tunnels/port-forwarding\nchmod +x setup-ddns.sh\n./setup-ddns.sh`
  }
};

let currentTunnelCmd = tunnelData.tailscale.code;

function selectTunnel(key) {
  const t = tunnelData[key];
  currentTunnelCmd = t.code;
  document.getElementById('tunnel-badge').textContent = t.badge;
  document.getElementById('tunnel-title').textContent = t.title;
  document.getElementById('tunnel-desc').textContent = t.desc;
  document.getElementById('tunnel-file').textContent = t.file;
  document.getElementById('tunnel-code').innerHTML = `<code>${t.code}</code>`;
  document.getElementById('tunnel-features').innerHTML = t.features
    .map(f => `<li class="flex items-center gap-2"><i class="fa-solid fa-check text-emerald-400"></i> ${f}</li>`)
    .join('');
  document.querySelectorAll('.tunnel-btn').forEach(btn => {
    const active = btn.dataset.tunnel === key;
    btn.classList.toggle('bg-indigo-600', active);
    btn.classList.toggle('text-white', active);
    btn.classList.toggle('bg-white/5', !active);
    btn.classList.toggle('text-slate-400', !active);
  });
}

function copyTunnelCmd() {
  copyText(currentTunnelCmd);
}
