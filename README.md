


# XXTerm




<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [A Terminal With Precisely Configurable Fonts Using CSS Unicode Ranges](#a-terminal-with-precisely-configurable-fonts-using-css-unicode-ranges)
- [Installation](#installation)
- [Usage](#usage)
- [To Do](#to-do)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## A Terminal With Precisely Configurable Fonts Using CSS Unicode Ranges

* Why XXTerm
* Why CSS Unicode Ranges

## Installation

Clone this repo into a convenient location, then run `pnpm install` (or `npm install` if you prefer).

```bash
git clone https://github.com/loveencounterflow/xxterm
cd /path/to/xxterm
pnpm install
```

The `clone` command will take a little while because XXTerm includes some fairly large CJK fonts (more or
less the reason I started this is to have good coverage of CJK codepoints). The `install` command will also
take some time because it calls `git-clone-xtermjs`, a script that clones and prepares
[xterm.js](https://github.com/xtermjs/xterm.js).

## Usage

When installation has completed, start a browser window displaying a terminal by executing

```bash
./xxterm
```

This will call `chromium --app=http://localhost:3000`; the browser window will show no menus and no address
bar. In case the browser window does not show a terminal, press `ctrl+r` or use the button to reload the
window.


## To Do

* **[+]** Avoid connection error on startup (by using a splash screen?)
* **[–]** icon
* **[–]** move `xterm` code out of main folder
* **[+]** implement useful action (re-clone, update, cancel) to `git-clone-xtermjs` in case folder `xterm`
  should already exist (NB `git reset --hard` can be redone without changing anything)
* **[–]** make digest or tag to revert to configurable?
* **[–]** fix startups with missing terminal element in browser window
* **[–]** make browser configurable (now hardcoded to `chromium`)






