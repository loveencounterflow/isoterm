


<img src='app/static/logo.png'>


# XXTerm




<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [A Terminal With Precisely Configurable Fonts Using CSS Unicode Ranges](#a-terminal-with-precisely-configurable-fonts-using-css-unicode-ranges)
- [Installation](#installation)
- [Usage](#usage)
- [Live Replay / Echo](#live-replay--echo)
- [To Do](#to-do)
- [Is Done](#is-done)

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

## Live Replay / Echo

As of [commit&nbsp;#3768e37aaa0](https://github.com/loveencounterflow/xxterm/commit/3768e37aaa0486895bbe9e86d7bbccfdc42cdef8)
the parent process can echo everything that's going on in the web terminal, including colors, `zsh` line
completions, and even `less` paging (including the ability to clear the screen) and more advanced TUI stuff
like `htop` just work. Not sure ATM why that would be useful but it does make for a nice demo!



## To Do

* **[–]** Move `xterm` code out of main folder
* **[–]** Make digest or tag to revert to configurable?
* **[–]** Fix startups with missing terminal element in browser window
* **[–]** Make browser configurable (now hardcoded to `chromium`)
* **[–]** Try to avoid the startup delay caused having to wait for webpack (by including bundled code in
  `dist` or by removing webpack altogether)
* **[–]** Use exit handler to ensure server process gets terminated
* **[–]** make echoing of web terminal configurable
* **[–]** `exit` in web terminal should ternminate XXTerm (as it does in other terminal emulators)
* **[–]** implement On-Page Script (`ops.js`) to avoid having to code insed of `index.html`

## Is Done

* **[+]** Avoid connection error on startup (by using a splash screen?)
* **[+]** Implement useful action (re-clone, update, cancel) to `git-clone-xtermjs` in case folder `xterm`
  should already exist (NB `git reset --hard` can be redone without changing anything)
* **[+]** Establish websocket communication between server and browser
* **[+]** Icon (sorta)
* **[+]** remove dependency on https://cdnjs.cloudflare.com/ajax/libs/es6-promise/4.1.1/es6-promise.auto.min.js
* **[+]** remove dependency on https://cdnjs.cloudflare.com/ajax/libs/fetch/1.0.0/fetch.min.js




