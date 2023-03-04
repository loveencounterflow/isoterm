


<img src='app/static/logo.png'>


# ISOTerm

**Note**—the dependency tree of this project looks like this:

![](https://imgs.xkcd.com/comics/dependency_2x.png)

And while it did work in April 2022, trying to install it according to the instructions given below
in March 2023 results in series of failures. I did manage to update some of the dependencies and
made the thing run its crazy installtion script, but only with `npm`, *not* with `pnpm` for reasons that
are totally not clear to me. Then, running `./isoterm` does open a browser window, in which, however the terminal element
is missing. The console output in dev tools does show some problems:

```
client-bundle.js:1          Failed to load resource: the server responded with a status of 404 (Not Found)
ops.coffee:21 ^334-1^ log
ops.coffee:21 ^334-1^ debug
ops.coffee:21 ^334-1^ log
ops.coffee:21 ^334-1^ debug
ops.coffee:21 ^334-1^ log
ops.coffee:21 ^334-1^ log
localhost/:1 Refused to execute script from 'http://localhost:33281/dist/client-bundle.js' because its MIME type ('text/html') is not executable, and strict MIME type checking is enabled.
ops.coffee:21 ^334-1^ log
ops-late.coffee:76 ^ops-late@4^ OK
ops-late.coffee:77 ^ops-late@5^ OPS loaded
ops.coffee:21 ^334-1^ log
ops-late.coffee:78 Uncaught ReferenceError: term is not defined
    at ops-late.coffee:78:29
    at ops-late.coffee:5:1
```

—so, hopefully, after fixing those, the terminal will become operational again.


<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [A Terminal With Precisely Configurable Fonts Using CSS Unicode Ranges](#a-terminal-with-precisely-configurable-fonts-using-css-unicode-ranges)
- [Installation](#installation)
- [Usage](#usage)
- [Live Replay / Echo](#live-replay--echo)
- [Appendix: Relevant Chrom{e|ium} Command Line Flags](#appendix-relevant-chromeium-command-line-flags)
- [To Do](#to-do)
- [Is Done](#is-done)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## A Terminal With Precisely Configurable Fonts Using CSS Unicode Ranges

* Why ISOTerm
* Why CSS Unicode Ranges

## Installation

Clone this repo into a convenient location, then run `pnpm install` (or `npm install` if you prefer).


```bash
pnpm add -g yarn # or `npm install -g yarn`
git clone https://github.com/loveencounterflow/isoterm
cd /path/to/isoterm
pnpm install
```

The `clone` command will take a little while because ISOTerm includes some fairly large CJK fonts (more or
less the reason I started this is to have good coverage of CJK codepoints). The `install` command will also
take some time because it calls `git-clone-xtermjs`, a script that clones and prepares
[xterm.js](https://github.com/xtermjs/xterm.js).

> **Note** `xterm` will want to run tests using `yarn` which should be installed globally. The tests will
> fail **for seemingly unrelated reasons** unless `yarn` is found, and because of this failure,
> transpilation of modules will likewise not complete, meaning the `xterm` subdirectory is left in an
> unusable state. What's more, the tests will also download `playwright` which is needed for these very
> tests only (not for displaying a terminal in the browser as such), incurring a sizable additional
> dependency just because `xterm` insists on running tests when being installed (as such not a bad idea, but
> still). I hope that in the future, we can resolve these inconveniences and avoid unnecessary downloads,
> but for the time being I do not see precisely how to accomplish that.


Chromium is currently hardcoded to be used for the web terminal; on Debian-ish system, install it with

```bash
sudo apt install -y chromium-browser
```


## Usage

When installation has completed, start a browser window displaying a terminal by executing

```bash
./isoterm
```

This will call `chromium --app=http://localhost:3000`; the browser window will show no menus and no address
bar. In case the browser window does not show a terminal, press `ctrl+r` or use the button to reload the
window.

## Live Replay / Echo

As of [commit&nbsp;#3768e37aaa0](https://github.com/loveencounterflow/isoterm/commit/3768e37aaa0486895bbe9e86d7bbccfdc42cdef8)
the parent process can echo everything that's going on in the web terminal, including colors, `zsh` line
completions, and even `less` paging (including the ability to clear the screen) and more advanced TUI stuff
like `htop` just work. Not sure ATM why that would be useful but it does make for a nice demo!

## Appendix: Relevant Chrom{e|ium} Command Line Flags

* see https://codefodder.github.io/chrome-chromium-startup-flags/
* see https://peter.sh/experiments/chromium-command-line-switches/


```sh
--window-position=0,0
--window-size=1920,1080
--kiosk
--start-fullscreen
--start-maximized
--incognito
--disable-infobars
--no-default-browser-check
--noerrdialogs
--disable-crash-report
--ignore-certificate-errors
--test-type
--disable-translate
--fast
--fast-start
--disable-features=TranslateUI
--disk-cache-dir=/dev/null
--password-store=basic
```

## To Do

* **[–]** Move `xterm` code out of main folder
* **[–]** Make digest or tag to revert to configurable?
* **[–]** Fix startups with missing terminal element in browser window
* **[–]** Make browser configurable (now hardcoded to `chromium`)
* **[–]** Try to avoid the startup delay caused having to wait for webpack (by including bundled code in
  `dist` or by removing webpack altogether)
* **[–]** Use exit handler to ensure server process gets terminated
* **[–]** make echoing of web terminal configurable
* **[–]** `exit` in web terminal should ternminate ISOTerm (as it does in other terminal emulators)
* **[–]** implement On-Page Script (`ops.js`) to avoid having to code insed of `index.html`
* **[–]** can we mirror errors &c that happen in the browser console to the main process (`cli.js`)?
* **[–]** make browser console output easier to look at from the web terminal
* **[–]** handle race condition where a chosen port is no longer available so `server.js` fails to connect
* **[–]** make browser size configurable
* **[–]** start server in `cli` process, cutting down from 3 to 2 processes per terminal
* **[–]** add option whether to start in user mode or in app (kiosk) mode (showing vs hiding user chrome
  like address bar)
* **[–]** find out how to implement custom key shortcuts (key bindings) when terminal DOM element has focus;
  currently this is blocked by `xterm/src/browser/Terminal.ts:446` &al.
* **[–]** ensure standard key bindings like `shift+ctrl+c`, `shift+ctrl+v` do work as intended (and only as
  intended). **NOTE** Interestingly, `alt+f4` will exit the browser.
* **[–]** currently when using `--start-fullscreen` there is no obvious way to quit the browser or even
  leave fullscreen by pressing `F11`, not even when focusing are outside of the terminal (there is a not-so
  obvious way; move mouse cursor along top edge will show a circled `X` symbol that, when clicked, will make
  the browser exit fullscreen).
* **[–]** is it possible to hide the title bar similar to when in fullscreen but *without* also hiding the
  OS task bar?
* **[–]** infinite zoom plane / utopia planitia?
* **[–]** clarify why in `app/index.html` a useless literal `<script>` tag is needed even when the `defer`
  attribute on the `<script src="dist/client-bundle.js"></script>` tag has been removed—this looks like a
  very strange and unexpected interaction

## Is Done

* **[+]** Avoid connection error on startup (by using a splash screen?)
* **[+]** Implement useful action (re-clone, update, cancel) to `git-clone-xtermjs` in case folder `xterm`
  should already exist (NB `git reset --hard` can be redone without changing anything)
* **[+]** Establish websocket communication between server and browser
* **[+]** Icon (sorta)
* **[+]** remove dependency on https://cdnjs.cloudflare.com/ajax/libs/es6-promise/4.1.1/es6-promise.auto.min.js
* **[+]** remove dependency on https://cdnjs.cloudflare.com/ajax/libs/fetch/1.0.0/fetch.min.js
* **[+]** each `isoterm` instance should look for its own free port, fail with message in case it doesn't
  succeed in the configured range, with configured end digits
* **[+]** implement opening browser in fullscreen
* **[+]** implement technique to add key shortcut that overrides browser defaults such as `ctrl+l`, `ctrl+k`




