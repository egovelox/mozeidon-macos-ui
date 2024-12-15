# mozeidon-macos-ui

A simple window ala `spotlight` to list and select Mozilla tabs or bookmarks via `mozeidon`.

Requirements : 
- requires macOS >= `14.6`.
- [mozeidon](https://github.com/egovelox/mozeidon) ( follow installation process )


⚠️ this app does not run in `sandbox` mode: it relies on the external mozeidon cli called with `sh -c`.

| Keybinding    | Action |
| -------- | ------- |
| user setting  | list tabs    |
| user setting | list bookmarks     |
| Enter | open element in browser    |
| ctrl-L | close element in browser    |
| ctrl-J    | scroll-down   |
| ctrl-K  | scroll-up   |
| ctrl-C / Esc  | close list   |

<img width="957" alt="mozeidon_ui" src="https://github.com/user-attachments/assets/12fae81b-d56e-464c-865f-cfec97260d2e" />
