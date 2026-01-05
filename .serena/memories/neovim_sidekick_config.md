# Sidekick.nvim Custom Configuration

## Prompt Buffer & Gemini Integration
A custom setup was implemented to allow `<C-t>` to manage the Sidekick (Gemini) prompt.

### Key Mappings (All mapped to `<C-t>`)
- **Normal Mode (Global):** Toggles the Gemini prompt.
    - If closed: Opens Gemini (background) -> Opens `sidekick://prompt` buffer in a 10-line split below Gemini -> Focuses prompt.
    - If open: Closes the prompt buffer.
- **Terminal Mode (inside Sidekick):** Force-opens/focuses the prompt buffer.
    - Allows jumping from the chat output directly to the input prompt.
- **Normal/Insert Mode (inside `sidekick://prompt`):** Closes the prompt (Cancel).

### Implementation Details
- **Buffer Name:** `sidekick://prompt` (FileType: markdown)
- **Submission:**
    - Uses `require("sidekick.cli").send({ msg = input })`.
    - `submit = true` was replaced with explicit `vim.api.nvim_feedkeys("<CR>")` to ensure reliable execution in the terminal.
- **Window Management:**
    - Uses a global function `_G.toggle_sidekick_prompt(force_open)` to handle logic.
    - Explicitly manages focus using `vim.schedule` and `startinsert`.
    - Sidekick window width increased to 100.
