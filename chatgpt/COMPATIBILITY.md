# ChatGPT compatibility and limits

Documentation checked on 2026-10-28. These are supported configuration routes,
not a claim that an isolated native ChatGPT trial was run for this release.

| Route | What it provides | Operator action / limit |
| --- | --- | --- |
| Bootstrap pasted into a chat | Explicit instructions in the supplied conversation context | Paste again when absent; inspect behavior |
| Bootstrap as an attachment | A file the assistant can read when the feature is available | Explicitly request the full read; use paste if inaccessible |
| Custom Instructions | User-editable response preferences reused by ChatGPT | Enable/configure in settings; short adapter text is ≤1,500 characters; task checkpoint still separate |
| Project instructions and files | Instructions and task material scoped to a project | Configure the project; instructions override global Custom Instructions; test inside that project |
| Memory / chat history | Relevant remembered preferences and context where enabled | Does not retain every detail; not an exact checkpoint store |
| This adapter's local Python helper | Validates JSON, builds packets, assesses supplied review records | Runs only when invoked; does not call a model or change ChatGPT |
| Claude Code installer, hooks, MCP server | Original implementation for its original environment | Preserved, never invoked by this adapter |

The original restore hook logs an event and prints an instruction. Its source
does not read the memory files. The old `verify.sh` inspects files, strings, and
hook logs; it does not capture or test the model's responses. The new adapter
does not reinterpret those checks as native ChatGPT activation evidence.

No account setting, memory entry, startup trigger, global plugin registration,
permission setting, hidden parameter, classifier, model weight, or future
conversation is changed by producing or reading this package. This package has
no background service or automatic restoration mechanism. If another supported
surface supplies the instructions later, that is a distinct configuration path
to test, not persistence proved by this release.

## Official product documentation

- [ChatGPT Custom Instructions](https://help.openai.com/en/articles/8096356-chatgpt-custom-instructions)
  documents enabling customization on iOS/Android and web/desktop, and character
  limits by plan. This release uses the conservative 1,500-character limit. The
  article contains differing statements about effects on existing chats; this
  procedure makes no claim that changing settings retroactively repairs a chat.
- [Projects in ChatGPT](https://help.openai.com/en/articles/10169521-projects-in-chatgpt)
  documents adding instructions and reference files. Project instructions apply
  within the project and override global Custom Instructions. Memory scope and
  available tools depend on account and workspace settings.
- [Memory in ChatGPT](https://help.openai.com/en/articles/8590148-memory-in-chatgpt)
  distinguishes instructions from remembered context and says memory does not
  retain every detail. Availability varies by plan, platform, region, and workspace.
- [Temporary chat in ChatGPT](https://help.openai.com/en/articles/8914046-temporary-chat-in-chatgpt)
  documents Personalized and Unpersonalized choices. For an unconfigured control,
  choose Unpersonalized before the first message when available and record the
  setting. Do not assume every temporary chat excludes customization.

All behavioral conclusions must be limited to the observed environment and
samples. A clean control is useful evidence of source dependence; it is not a
mechanistic experiment on internal model parameters.
