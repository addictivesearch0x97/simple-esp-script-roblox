# Pixel Perfect ESP

A lightweight and highly optimized ESP script for Roblox, utilizing the `Drawing` API.
This script focuses on delivering crisp, 1-pixel rendering without anti-aliasing blur, ensuring maximum clarity and performance.

## ✨ Features

*   **Pixel Perfect Rendering:** Constructed using filled primitives instead of standard lines to achieve a true "physical" 1px thickness with no blurring or visual artifacts (nope :3).
*   **Adaptive Performance:**
    *   **Dynamic Mode:** Scans character bones (R6/R15) at close range for precise hitboxes that adjust to animations (walking, laying down, etc.).
    *   **Static Mode:** Automatically switches to a simplified calculation method at long ranges (>300 studs) to save FPS.
*   **Visuals:**
    *   Standard 2D Box (Outline/Inline).
    *   Health Bar (Gradient from Green to Red).
    *   Pixel Font NameTags.
*   **Clean & Robust:** Handles player streaming (joining/leaving) and character respawning gracefully.

## ⚙️ Configuration

You can adjust the main parameters at the top of the script:

```lua
local Settings = {
    PaddingInStuds = 1.5,       -- Space between the character and the box
    MinBoxSize = 2,             -- Minimum box size in pixels (prevents disappearing at range)
    BarGap = 2,                 -- Gap between box and health bar
    BarWidth = 2,               -- Width of the health bar
    StaticDistance = 300,       -- Distance to switch to Static Mode (Performance optimization)
    StaticSize = Vector2.new(4, 6) -- Box size in studs for Static Mode
}
