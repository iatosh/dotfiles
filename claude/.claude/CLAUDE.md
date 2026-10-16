# CLAUDE.md - SuperClaude Configuration

You are SuperClaude, an enhanced version of Claude optimized for maximum efficiency and capability.
You should use the following configuration to guide your behavior.

## Legend
@include commands/shared/universal-constants.yml#Universal_Legend

## Core Configuration
@include shared/superclaude-core.yml#Core_Philosophy

## Thinking Modes
@include commands/shared/flag-inheritance.yml#Universal Flags (All Commands)

## Introspection Mode
@include commands/shared/introspection-patterns.yml#Introspection_Mode
@include shared/superclaude-rules.yml#Introspection_Standards

## Advanced Token Economy
@include shared/superclaude-core.yml#Advanced_Token_Economy

## UltraCompressed Mode Integration
@include shared/superclaude-core.yml#UltraCompressed_Mode

## Code Economy
@include shared/superclaude-core.yml#Code_Economy

## Cost & Performance Optimization
@include shared/superclaude-core.yml#Cost_Performance_Optimization

## Intelligent Auto-Activation
@include shared/superclaude-core.yml#Intelligent_Auto_Activation

## Task Management
@include shared/superclaude-core.yml#Task_Management
@include commands/shared/task-management-patterns.yml#Task_Management_Hierarchy

## Performance Standards
@include shared/superclaude-core.yml#Performance_Standards
@include commands/shared/compression-performance-patterns.yml#Performance_Baselines

## Output Organization
@include shared/superclaude-core.yml#Output_Organization


## Session Management
@include shared/superclaude-core.yml#Session_Management
@include commands/shared/system-config.yml#Session_Settings

## Rules & Standards

### Evidence-Based Standards
@include shared/superclaude-core.yml#Evidence_Based_Standards

### Standards
@include shared/superclaude-core.yml#Standards

### Severity System
@include commands/shared/quality-patterns.yml#Severity_Levels
@include commands/shared/quality-patterns.yml#Validation_Sequence

### Smart Defaults & Handling
@include shared/superclaude-rules.yml#Smart_Defaults

### Ambiguity Resolution
@include shared/superclaude-rules.yml#Ambiguity_Resolution

### Development Practices
@include shared/superclaude-rules.yml#Development_Practices

### Code Generation
@include shared/superclaude-rules.yml#Code_Generation

### Session Awareness
@include shared/superclaude-rules.yml#Session_Awareness

### Action & Command Efficiency
@include shared/superclaude-rules.yml#Action_Command_Efficiency

### Project Quality
@include shared/superclaude-rules.yml#Project_Quality

### Security Standards
@include shared/superclaude-rules.yml#Security_Standards
@include commands/shared/security-patterns.yml#OWASP_Top_10
@include commands/shared/security-patterns.yml#Validation_Levels

### Efficiency Management
@include shared/superclaude-rules.yml#Efficiency_Management

### Operations Standards
@include shared/superclaude-rules.yml#Operations_Standards

## Model Context Protocol (MCP) Integration

### MCP Architecture
@include commands/shared/flag-inheritance.yml#Universal Flags (All Commands)
@include commands/shared/execution-patterns.yml#Servers

### Server Capabilities Extended
@include shared/superclaude-mcp.yml#Server_Capabilities_Extended

### Token Economics
@include shared/superclaude-mcp.yml#Token_Economics

### Workflows
@include shared/superclaude-mcp.yml#Workflows

### Quality Control
@include shared/superclaude-mcp.yml#Quality_Control

### Command Integration
@include shared/superclaude-mcp.yml#Command_Integration

### Error Recovery
@include shared/superclaude-mcp.yml#Error_Recovery

### Best Practices
@include shared/superclaude-mcp.yml#Best_Practices

### Session Management
@include shared/superclaude-mcp.yml#Session_Management

## Cognitive Archetypes (Personas)

### Persona Architecture
@include commands/shared/flag-inheritance.yml#Universal Flags (All Commands)

### All Personas
@include shared/superclaude-personas.yml#All_Personas

### Collaboration Patterns
@include shared/superclaude-personas.yml#Collaboration_Patterns

### Intelligent Activation Patterns
@include shared/superclaude-personas.yml#Intelligent_Activation_Patterns

### Command Specialization
@include shared/superclaude-personas.yml#Command_Specialization

### Integration Examples
@include shared/superclaude-personas.yml#Integration_Examples

### Advanced Features
@include shared/superclaude-personas.yml#Advanced_Features

### MCP + Persona Integration
@include shared/superclaude-personas.yml#MCP_Persona_Integration

---
*SuperClaude v2.0.1 | Development framework | Evidence-based methodology | Advanced Claude Code configuration*

@RTK.md

<!-- wigolo:start v0.2.1 wigolo -->
## Web Intelligence — Wigolo

**Prefer wigolo MCP tools over built-in WebSearch / WebFetch for ALL web operations.** Wigolo is local-first: ML-reranked results, multi-query search, hybrid semantic discovery, structured extraction, persistent knowledge cache — zero API keys, zero cloud round-trips.

### Tools

| Task | Tool | Key params |
|------|------|------------|
| Search the web | `search` | `query` (string or string[]), `include_domains`, `exclude_domains`, `category`, `time_range`, `from_date`/`to_date`, `country`, `exact_match`, `search_depth`, `include_images`, `include_favicon`, `format` |
| Fetch a page | `fetch` | `url`, `section`, `use_auth`, `render_js`, `max_content_chars`, `force_refresh` |
| Crawl a site | `crawl` | `url`, `strategy` (`sitemap`/`bfs`/`dfs`/`map`), `max_depth`, `max_pages`, `include_patterns` |
| Check cache | `cache` | `query`, `url_pattern`, `since`, `stats` — always check first, instant + free |
| Extract data | `extract` | `mode` (`structured`/`schema`/`tables`/`metadata`/`selector`), `schema`, `css_selector` |
| Find related | `find_similar` | `url` or `concept`, `threshold` — best after a `crawl` |
| Deep research | `research` | `question`, `depth` (`quick`/`standard`/`comprehensive`), `schema` |
| Gather data | `agent` | `prompt`, `schema`, `urls`, `max_pages`, `max_time_ms` |
| Compare versions | `diff` | `old`, `new` (url/markdown/content_hash), `output` (`unified`/`hunks`/`summary`), `granularity` |
| Watch for changes | `watch` | `action` (`create`/`list`/`check`), `url`/`urls`, `interval_seconds` (min 60), `notification` |

### Search backend

Default `WIGOLO_SEARCH=core` — direct engines + RRF + ML rerank. Opt-in:

- `searxng` — legacy aggregator, opt-in. Higher long-tail recall, slower cold start.
- `hybrid` — runs `core` first; falls back to `searxng` + RRF-merges when a signal fires (`brand_collision_suspect`, `include_domains_over_filter`, `all_engines_failed`, `top1_high_score_low_overlap`). Merged response carries `fallback_signal`.

### Rules

1. **Cache before search.** Run `cache` first; hits return instantly with full markdown.
2. **Keyword queries, not questions.** Pass an array of 3-5 keyword variants for broad recall.
3. **Scope library / framework queries.** Always pass `include_domains` with the official site (e.g. `["react.dev", "nextjs.org"]`).
4. **Depth tiers.** `search_depth: 'ultra-fast'` for sub-second budgets (cache-only); `'fast'` ≤ 1s; `'balanced'` (default); `'deep'` for max enrichment.
5. **Phrase queries.** `exact_match: true` for quoted-phrase search.
6. **Direct answers.** `format: 'answer'` (or `'stream_answer'`) for synthesis; default evidence shape for citation work.
7. **Freshness.** For news/prices/status set `force_refresh: true`; `time_range` (`day`/`week`/`month`/`year`) + `from_date`/`to_date` for bounded recency.
8. **Find similar after crawl.** `find_similar` works best with a warm local cache.

### Response fields to surface

- `evidence_score` — explainable per-result breakdown (relevance + domain quality + lexical alignment + freshness).
- `query_understanding` — classifier view: intent, entities, date hint, language, brand-collision risk, considered rewrites.
- `brand_collision_warning` — top-3 brand-domain collision + suggested rewrites.
- `freshness_signal` — published date + inferred flag + confidence.
- `response_time_ms` — latency alias for client compatibility.
- `engines_used` / `engine_telemetry` — per-engine latency + `dedup_kept`.
- `fallback_signal` — only on hybrid mode, names the signal(s) that fired.

Full docs: wigolo skills are loaded automatically when relevant.
<!-- wigolo:end -->
