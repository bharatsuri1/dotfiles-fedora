# System UI font selection

The desktop uses **Inter** for proportional interface text, **Noto** for broad
Unicode fallback, and **JetBrains Mono Nerd Font** only for code, terminal, and
compact data roles. This keeps the lock screen, login screen, notifications,
GTK applications, and future Quickshell UI visually related without asking one
font to solve incompatible jobs.

## Candidate review

| Family | Strengths for this desktop | Constraint | Decision |
| --- | --- | --- | --- |
| Inter 4.1 | Designed specifically for computer UI, with a tall x-height, strong small-text legibility, tabular numerals, and a complete Fedora package | Its neutrality is familiar rather than distinctive | Primary UI family |
| Geist Sans | Crisp Swiss/geometric character and a polished contemporary feel | Upstream and Fedora describe it primarily for headlines, logos, posters, and larger display sizes; its script coverage is narrower than Noto | Keep as an optional lock-screen comparison, not the default |
| Noto Sans | Extremely broad script coverage with deliberate cross-script harmony; matching CJK and emoji families are available | Less distinctive in Latin-only UI and already serves the more important fallback role | Required fallback family |
| Adwaita Sans | Native GNOME baseline and already present on Fedora | Ties the visual voice to GNOME rather than the repository-owned Vesper desktop | Leave installed as a toolkit fallback, but do not make it the authored face |

Primary references:

- [Inter upstream](https://github.com/rsms/inter) and the [Fedora Inter package](https://packages.fedoraproject.org/pkgs/rsms-inter-fonts/rsms-inter-fonts/)
- [Geist upstream](https://github.com/vercel/geist-font) and the [Fedora Geist package](https://packages.fedoraproject.org/pkgs/vercel-geist-fonts/vercel-geist-fonts/)
- [Noto usage guidance](https://notofonts.github.io/noto-docs/website/use/) and the [Fedora Noto Sans package](https://packages.fedoraproject.org/pkgs/google-noto-fonts/google-noto-sans-fonts/)

The static `rsms-inter-fonts` package is intentional. GTK, Qt/SDDM, Mako, and
fontconfig all need predictable named weights; the variable package offers no
material advantage for these surfaces and has more toolkit-dependent behavior.

## Managed application

- `fontconfig` prefers Inter, then Noto Sans, whenever an application requests
  the generic `sans-serif` family.
- GNOME/GTK's interface-font setting is set to `Inter 11` during the
  `desktop-defaults` phase.
- gtklock, Mako, SDDM, and the Quickshell UI token name Inter explicitly.
- Alacritty retains JetBrains Mono Nerd Font; the current Quickshell island uses
  Inter for its clock and battery percentage. Noto Sans, Noto Sans CJK, and
  Noto Color Emoji remain installed.

gtklock uses a repository-owned GTK Builder layout in addition to its CSS. The
layout presents one centered password field and submits on Enter; password
reveal, Caps Lock, PAM messages, and authentication errors remain available.
gtklock's required unlock-button object stays in the widget tree but is hidden,
removing the redundant pointer action without violating its busy-state contract.
Focus and guidance use niri's warm `#ffc799` accent over a darker `#221d18`
tint, while authentication failures retain the separate salmon error color.

## Fast lock-screen comparison

The repository uses gtklock, not Swaylock. The preview helper launches gtklock
in the foreground with a temporary copy of the managed stylesheet; it never
edits the production CSS. Unlock normally to return to the terminal.

```bash
./bin/laptop-setup fonts
./bin/preview-lock-screen --check "Inter"
./bin/preview-lock-screen "Inter"
```

To compare the other packaged candidates without adding them to the managed
setup:

```bash
sudo dnf install vercel-geist-fonts
./bin/preview-lock-screen "Geist"
./bin/preview-lock-screen "Noto Sans"
```

The comparison should focus on the 96 px clock, the 20 px date, the 14 px
prompt, ambiguous glyphs (`Il1`, `O0`), and the visual weight of white text over
the wallpaper. The helper rejects missing or malformed family names so a silent
font fallback cannot be mistaken for a valid comparison.
