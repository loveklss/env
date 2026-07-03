---
name: mempalace-memory
description: >
  Bind or unbind a workspace to a MemPalace palace, ingest Cursor AI
  transcripts, maintain periodic incremental memory sync, and recall past
  conversation content. Use when user asks to bind/unbind a project, record
  AI dialogues, or — most importantly — wants to recall/remember specific
  past discussions, code decisions, bug investigations, design choices, or
  any conversation history. Trigger on phrases like "回忆", "有没有记录",
  "之前讨论过", "帮我找一下", "有没有关于XXX的历史", "记录过吗".
---

# MemPalace Memory Skill

## Purpose

Provide user-level memory operations for Cursor workspaces:

1. Bind project to palace.
2. Periodically ingest all bound projects.
3. Unbind project from palace without deleting palace data.
4. Force record current project AI dialogues.
5. **Recall past conversations** about any topic (primary use case).

## Trigger Intents (semantic)

Treat the following as equivalent intents, grouped by operation:

### 绑定 / Bind
- "请为这个工程绑定到宫殿/palace"
- "把这个工程加入记忆"
- "开始记录这个工程"

### 记录会话 / Ingest
- "记录当前工程的AI对话/对话记录"
- "帮我记忆这个工程的所有会话"
- "把这个工程的对话都存进记忆"
- "同步一下这个工程的会话"
- "定期同步/定时记录所有工程会话"
- "更新一下记忆"

### 解绑 / Unbind
- "请为这个工程解绑宫殿/palace"
- "删除这个工程的会话记忆"
- "取消这个工程的记忆"
- "不再记录这个工程"
- "清除这个工程的记忆绑定"

### 回忆检索 / Recall
- **"回忆一下 XXX 相关的记录"**
- **"有没有关于 XXX 的历史对话/记录"**
- **"之前我们讨论过 XXX 吗"**
- **"帮我找一下 XXX 的记录"**
- **"XXX 是怎么决定的"**
- **"XXX 当时怎么解决的"**
- **"有没有 XXX 的历史"**
- **"之前 XXX 怎么处理的"**

## Script Location

Use scripts in this skill directory:

- `scripts/bind.sh`
- `scripts/unbind.sh`
- `scripts/ingest.sh`
- `scripts/ingest_all.sh`
- `scripts/install_timer.sh`
- `scripts/run_mcp_server.sh`

Always run these scripts by absolute path under:
`~/.cursor/skills/mempalace-memory/scripts/`.

---

## Workflow 1: Bind project to palace

```bash
bash ~/.cursor/skills/mempalace-memory/scripts/bind.sh "<workspace>"
```

Behavior:
- If already bound: report already bound and return.
- If workspace has `.mempalace-palace` but no binding: bind to that palace and full-ingest.
- If workspace has no palace: create/select family palace, init, bind, then full-ingest.
- Write workspace MCP config to `<workspace>/.cursor/mcp.json`.

## Workflow 2: Periodic incremental ingestion

Install timer:

```bash
bash ~/.cursor/skills/mempalace-memory/scripts/install_timer.sh 10
```

Manual all-project incremental ingest:

```bash
bash ~/.cursor/skills/mempalace-memory/scripts/ingest_all.sh
```

## Workflow 3: Unbind project from palace

```bash
bash ~/.cursor/skills/mempalace-memory/scripts/unbind.sh "<workspace>"
```

Behavior:
- Remove workspace binding and workspace MCP link.
- Do not delete palace data.

## Workflow 4: Record current project dialogues

Run bind first, then force incremental ingest:

```bash
bash ~/.cursor/skills/mempalace-memory/scripts/bind.sh "<workspace>" "yes"
```

---

## Workflow 5: Recall Past Conversations ★ (Primary Use Case)

Use this workflow whenever the user asks to recall or find past conversation
content. **Use `recall.sh` — all search logic is inside the script, making
it a single allowlisted Shell call.**

### Step 1: Call recall.sh

```bash
bash ~/.cursor/skills/mempalace-memory/scripts/recall.sh \
  "<workspace_path>" \
  "<primary_keyword>" \
  ["<variant2>" "<variant3>" ...]
```

- `workspace_path`: absolute path (e.g. `/home/stephen.hu/ws/gitee/caps`)
- `primary_keyword`: used for semantic (mempalace) recall
- Extra keywords: combined as `kw1|kw2|kw3` for exact `rg` filtering

**Examples:**

```bash
# Single keyword
bash ~/.cursor/skills/mempalace-memory/scripts/recall.sh \
  /home/stephen.hu/ws/gitee/caps "VGP"

# Keyword with spelling/case variants
bash ~/.cursor/skills/mempalace-memory/scripts/recall.sh \
  /home/stephen.hu/ws/gitee/caps "MSI-X" "MSIX" "msix"

# Code symbol
bash ~/.cursor/skills/mempalace-memory/scripts/recall.sh \
  /home/stephen.hu/ws/gitee/caps "scorpio_vgp_mgr_init"
```

**Keyword expansion guide:**

| User says | Keywords to pass |
|-----------|-----------------|
| VGP | `"VGP" "vgp_mgr" "vgp_device" "dtu_vgp"` |
| MSIX / MSI-X | `"MSI-X" "MSIX" "msix"` |
| MMU | `"MMU" "dtu_mmu" "iommu"` |
| domain | `"hw_domain" "domain_mgr" "dtu_domain"` |
| (generic) | pass the keyword as-is |

> **First-run tip**: The first time Cursor shows this `bash recall.sh ...`
> command, click **"Add to allowlist"** — it auto-runs every time after that.

If `.mempalace-palace` is missing, run Workflow 1 (bind) first.

### Step 2: Format the response — REQUIRED OUTPUT STRUCTURE

**Always** format the recall response using this structure:

```
## 关于「<topic>」的历史记录

### 内容摘要
- <bullet 1: key finding / decision / discussion point>
- <bullet 2>
- <bullet 3>
（2–5 bullets, concise）

### 相关会话
- [<6-word session title>](<uuid>)
- [<6-word session title>](<uuid>)
```

Rules:
- Session title: ≤6 Chinese or English words derived from the first user query.
- UUID: the raw UUID string (no `.jsonl`, no path).
- The format `[title](uuid)` renders as a clickable link in Cursor.
- Deduplicate UUIDs across semantic and exact-match results.
- Show at most 5 results total.
- If no results found, say so clearly and suggest alternative keywords.
- **Do NOT run more than 2 Shell calls total for the entire recall workflow.**

**Example output:**

```
## 关于「MSI-X」的历史记录

### 内容摘要
- VGP 设计文档硬件抽象层中记录了中断控制器 MSI/MSI-X 组件（H5 节点）
- 相关会话集中在 VGP 架构图 Mermaid 图的层次结构调整与渲染问题排查
- 曾将 mermaid 版本从 11.12.1 降级至 9.3.0 排查 undefined 渲染问题

### 相关会话
- [VGP架构图层级删除调整](6a031283-0ba5-46e3-839b-f53bb4ec648e)
- [Mermaid版本渲染问题排查](bf72c5a9-ad7c-4357-a598-0bb9b779f4bb)
- [VGP架构图连接符去除](9c88db6e-448b-4a44-9ba5-94c415eff425)
```

---

## Config

User-level config file:

`~/.config/mempalace-memory/config.json`

Key fields:
- `palace_root`
- `cursor_projects_root`
- `default_family`
- `family_rules` by `folder_name_regex`

## Notes

- This skill is user-level, not repository-level.
- Family detection defaults to folder-name regex and can be customized.
- Transcript source default:
  `~/.cursor/projects/<workspace-key>/agent-transcripts`
- **Do NOT call bind.sh during recall** — it triggers ingest and adds 20s+ latency.
  Only call bind.sh if `.mempalace-palace` is missing.
