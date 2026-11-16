/**
 * Home LiteLLM Interactive Application Logic
 * Zero dependencies, semantic, resilient JS
 */

// Model Catalog Dataset (All 37 configured models from config.yaml)
const MODELS_DATA = [
  { name: "gpt-4o", target: "openai/gpt-4o", provider: "openai", category: "cloud", key: "OPENAI_API_KEY", failover: "gemini-2.0-flash -> claude-3-5-sonnet" },
  { name: "gpt-4o-mini", target: "openai/gpt-4o-mini", provider: "openai", category: "cloud", key: "OPENAI_API_KEY", failover: "None" },
  { name: "o3-mini", target: "openai/o3-mini", provider: "openai", category: "cloud", key: "OPENAI_API_KEY", failover: "None" },
  { name: "claude-3-5-sonnet", target: "anthropic/claude-3-5-sonnet-20241022", provider: "anthropic", category: "cloud", key: "ANTHROPIC_API_KEY", failover: "gpt-4o -> gemini-2.0-flash" },
  { name: "claude-3-5-haiku", target: "anthropic/claude-3-5-haiku-20241022", provider: "anthropic", category: "cloud", key: "ANTHROPIC_API_KEY", failover: "None" },
  { name: "gemini-2.0-flash", target: "gemini/gemini-2.0-flash", provider: "gemini", category: "cloud", key: "GEMINI_API_KEY", failover: "None" },
  { name: "gemini-1.5-pro", target: "gemini/gemini-1.5-pro", provider: "gemini", category: "cloud", key: "GEMINI_API_KEY", failover: "None" },
  { name: "gemini-1.5-flash", target: "gemini/gemini-1.5-flash", provider: "gemini", category: "cloud", key: "GEMINI_API_KEY", failover: "None" },
  { name: "deepseek-chat", target: "deepseek/deepseek-chat", provider: "deepseek", category: "cloud", key: "DEEPSEEK_API_KEY", failover: "gpt-4o-mini -> gemini-1.5-flash" },
  { name: "deepseek-reasoner", target: "deepseek/deepseek-reasoner", provider: "deepseek", category: "cloud", key: "DEEPSEEK_API_KEY", failover: "None" },
  { name: "grok-2", target: "xai/grok-2-1212", provider: "xai", category: "cloud", key: "XAI_API_KEY", failover: "None" },
  { name: "grok-2-vision", target: "xai/grok-2-vision-1212", provider: "xai", category: "cloud", key: "XAI_API_KEY", failover: "None" },
  { name: "grok-beta", target: "xai/grok-beta", provider: "xai", category: "cloud", key: "XAI_API_KEY", failover: "None" },
  { name: "mistral-large", target: "mistral/mistral-large-latest", provider: "mistral", category: "cloud", key: "MISTRAL_API_KEY", failover: "None" },
  { name: "mistral-small", target: "mistral/mistral-small-latest", provider: "mistral", category: "cloud", key: "MISTRAL_API_KEY", failover: "None" },
  { name: "groq-llama-3.3-70b", target: "groq/llama-3.3-70b-versatile", provider: "groq", category: "groq", key: "GROQ_API_KEY", failover: "None" },
  { name: "groq-llama-3.1-8b", target: "groq/llama-3.1-8b-instant", provider: "groq", category: "groq", key: "GROQ_API_KEY", failover: "None" },
  { name: "groq-deepseek-r1-70b", target: "groq/deepseek-r1-distill-llama-70b", provider: "groq", category: "groq", key: "GROQ_API_KEY", failover: "None" },
  { name: "groq-gemma2-9b", target: "groq/gemma2-9b-it", provider: "groq", category: "groq", key: "GROQ_API_KEY", failover: "None" },
  { name: "groq-mixtral-8x7b", target: "groq/mixtral-8x7b-32768", provider: "groq", category: "groq", key: "GROQ_API_KEY", failover: "None" },
  { name: "command-r-plus", target: "cohere/command-r-plus", provider: "cohere", category: "cloud", key: "COHERE_API_KEY", failover: "None" },
  { name: "together-llama-3.3-70b", target: "together_ai/meta-llama/Llama-3.3-70B-Instruct-Turbo", provider: "together_ai", category: "cloud", key: "TOGETHERAI_API_KEY", failover: "None" },
  { name: "fireworks-llama-3.3-70b", target: "fireworks_ai/accounts/fireworks/models/llama-v3p3-70b-instruct", provider: "fireworks_ai", category: "cloud", key: "FIREWORKS_API_KEY", failover: "None" },
  { name: "openrouter-auto", target: "openrouter/auto", provider: "openrouter", category: "cloud", key: "OPENROUTER_API_KEY", failover: "None" },
  { name: "sonar-pro", target: "perplexity/sonar-pro", provider: "perplexity", category: "cloud", key: "PERPLEXITYAI_API_KEY", failover: "None" },
  { name: "azure-gpt-4o", target: "azure/gpt-4o", provider: "azure", category: "cloud", key: "AZURE_API_KEY", failover: "None" },
  { name: "bedrock-claude-3-5-sonnet", target: "bedrock/anthropic.claude-3-5-sonnet-20241022-v2:0", provider: "bedrock", category: "cloud", key: "AWS Credentials", failover: "None" },
  { name: "ollama-llama3.3", target: "ollama/llama3.3", provider: "ollama", category: "local", key: "Direct / Local", failover: "None" },
  { name: "ollama-llama3.1", target: "ollama/llama3.1", provider: "ollama", category: "local", key: "Direct / Local", failover: "None" },
  { name: "ollama-deepseek-r1", target: "ollama/deepseek-r1", provider: "ollama", category: "local", key: "Direct / Local", failover: "None" },
  { name: "ollama-qwen2.5", target: "ollama/qwen2.5", provider: "ollama", category: "local", key: "Direct / Local", failover: "None" },
  { name: "ollama-mistral", target: "ollama/mistral", provider: "ollama", category: "local", key: "Direct / Local", failover: "None" },
  { name: "ollama-nomic-embed", target: "ollama/nomic-embed-text", provider: "ollama", category: "local", key: "Direct / Local", failover: "None" },
  { name: "lmstudio-local", target: "openai/local-model", provider: "lmstudio", category: "local", key: "not-needed", failover: "None" },
  { name: "vllm-llama3", target: "openai/meta-llama/Meta-Llama-3-8B-Instruct", provider: "vllm", category: "local", key: "None", failover: "None" },
  { name: "vllm-deepseek-r1", target: "openai/deepseek-ai/DeepSeek-R1-Distill-Qwen-7B", provider: "vllm", category: "local", key: "None", failover: "None" },
  { name: "localai-model", target: "openai/local-model", provider: "localai", category: "local", key: "None", failover: "None" }
];

document.addEventListener("DOMContentLoaded", () => {
  initTheme();
  initMobileNav();
  initModelCatalog();
  initTabs();
  initCopyButtons();
});

// 1. Theme Management (Light / Dark)
function initTheme() {
  const themeToggle = document.getElementById("theme-toggle");
  const storedTheme = localStorage.getItem("theme");
  const systemPrefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
  
  const activeTheme = storedTheme || (systemPrefersDark ? "dark" : "light");
  setTheme(activeTheme);

  if (themeToggle) {
    themeToggle.addEventListener("click", () => {
      const currentTheme = document.documentElement.getAttribute("data-theme") || "light";
      const nextTheme = currentTheme === "dark" ? "light" : "dark";
      setTheme(nextTheme);
      localStorage.setItem("theme", nextTheme);
    });
  }

  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", (e) => {
    if (!localStorage.getItem("theme")) {
      setTheme(e.matches ? "dark" : "light");
    }
  });
}

function setTheme(theme) {
  document.documentElement.setAttribute("data-theme", theme);
  const themeToggle = document.getElementById("theme-toggle");
  if (themeToggle) {
    themeToggle.setAttribute("aria-label", `Switch to ${theme === "dark" ? "light" : "dark"} theme`);
    themeToggle.innerHTML = theme === "dark" 
      ? `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>`
      : `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>`;
  }
}

// 2. Mobile Navigation Toggle
function initMobileNav() {
  const menuBtn = document.getElementById("mobile-menu-btn");
  const navDrawer = document.getElementById("mobile-nav-drawer");

  if (!menuBtn || !navDrawer) return;

  menuBtn.addEventListener("click", () => {
    const isOpen = navDrawer.classList.contains("open");
    if (isOpen) {
      closeMenu();
    } else {
      openMenu();
    }
  });

  function openMenu() {
    navDrawer.classList.add("open");
    menuBtn.setAttribute("aria-expanded", "true");
  }

  function closeMenu() {
    navDrawer.classList.remove("open");
    menuBtn.setAttribute("aria-expanded", "false");
  }

  // Close on Escape key
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && navDrawer.classList.contains("open")) {
      closeMenu();
      menuBtn.focus();
    }
  });

  // Close on link click
  navDrawer.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => closeMenu());
  });
}

// 3. Model Catalog Search & Filtering
let activeCategory = "all";
let searchQuery = "";

function initModelCatalog() {
  const searchInput = document.getElementById("catalog-search");
  const filterPills = document.querySelectorAll(".filter-pill");

  if (searchInput) {
    searchInput.addEventListener("input", (e) => {
      searchQuery = e.target.value.toLowerCase().trim();
      renderModels();
    });
  }

  filterPills.forEach((pill) => {
    pill.addEventListener("click", () => {
      filterPills.forEach((p) => p.classList.remove("active"));
      pill.classList.add("active");
      activeCategory = pill.getAttribute("data-category") || "all";
      renderModels();
    });
  });

  renderModels();
}

function renderModels() {
  const tableBody = document.getElementById("models-table-body");
  const emptyState = document.getElementById("models-empty-state");
  const countBadge = document.getElementById("catalog-count");

  if (!tableBody) return;

  const filtered = MODELS_DATA.filter((model) => {
    const matchesCategory = activeCategory === "all" || model.category === activeCategory;
    const matchesQuery = 
      !searchQuery ||
      model.name.toLowerCase().includes(searchQuery) ||
      model.provider.toLowerCase().includes(searchQuery) ||
      model.target.toLowerCase().includes(searchQuery) ||
      model.key.toLowerCase().includes(searchQuery);

    return matchesCategory && matchesQuery;
  });

  if (countBadge) {
    countBadge.textContent = `${filtered.length} of ${MODELS_DATA.length} models`;
  }

  if (filtered.length === 0) {
    tableBody.innerHTML = "";
    if (emptyState) emptyState.classList.add("visible");
    return;
  }

  if (emptyState) emptyState.classList.remove("visible");

  tableBody.innerHTML = filtered.map((model) => {
    const badgeClass = model.category === "local" 
      ? "type-local" 
      : (model.category === "groq" ? "type-groq" : "type-cloud");
    const categoryLabel = model.category === "local" 
      ? "Local" 
      : (model.category === "groq" ? "LPU (Groq)" : "Cloud");

    return `
      <tr>
        <td class="model-name-cell">${escapeHtml(model.name)}</td>
        <td><span class="model-type-badge ${badgeClass}">${categoryLabel}</span></td>
        <td><code>${escapeHtml(model.target)}</code></td>
        <td><code>${escapeHtml(model.key)}</code></td>
        <td>${escapeHtml(model.failover)}</td>
      </tr>
    `;
  }).join("");
}

// 4. Tab Navigation (Integrations)
function initTabs() {
  const tabButtons = document.querySelectorAll(".tab-btn");
  const tabPanes = document.querySelectorAll(".tab-pane");

  tabButtons.forEach((btn) => {
    btn.addEventListener("click", () => {
      const targetId = btn.getAttribute("data-tab");
      
      tabButtons.forEach((b) => {
        b.classList.remove("active");
        b.setAttribute("aria-selected", "false");
      });
      tabPanes.forEach((p) => p.classList.remove("active"));

      btn.classList.add("active");
      btn.setAttribute("aria-selected", "true");
      
      const activePane = document.getElementById(targetId);
      if (activePane) {
        activePane.classList.add("active");
      }
    });

    // Keyboard arrow navigation between tabs
    btn.addEventListener("keydown", (e) => {
      const tabs = Array.from(tabButtons);
      const index = tabs.indexOf(btn);

      if (e.key === "ArrowRight") {
        const next = tabs[(index + 1) % tabs.length];
        next.focus();
        next.click();
      } else if (e.key === "ArrowLeft") {
        const prev = tabs[(index - 1 + tabs.length) % tabs.length];
        prev.focus();
        prev.click();
      }
    });
  });
}

// 5. Clipboard Copy Buttons
function initCopyButtons() {
  const copyBtns = document.querySelectorAll(".copy-btn");

  copyBtns.forEach((btn) => {
    btn.addEventListener("click", async () => {
      const targetSelector = btn.getAttribute("data-target");
      if (!targetSelector) return;

      const targetEl = document.querySelector(targetSelector);
      if (!targetEl) return;

      const textToCopy = targetEl.textContent.trim();

      try {
        await navigator.clipboard.writeText(textToCopy);
        const originalText = btn.textContent;
        btn.textContent = "Copied!";
        btn.style.backgroundColor = "var(--success-text)";
        btn.style.color = "#ffffff";

        setTimeout(() => {
          btn.textContent = originalText;
          btn.style.backgroundColor = "";
          btn.style.color = "";
        }, 2000);
      } catch (err) {
        console.error("Failed to copy text:", err);
      }
    });
  });
}

function escapeHtml(str) {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}
