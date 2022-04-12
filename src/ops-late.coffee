



'use strict'


# _console = console


# #===========================================================================================================
# class Intercepted_console

#   # #---------------------------------------------------------------------------------------------------------
#   # constructor: ( target ) ->
#   #   @target = target
#   #   return undefined

#   #---------------------------------------------------------------------------------------------------------
#   get: ( target, key ) ->
#     _console.log '^334-1^', key
#     return target[ key ]
#     # return Reflect.get arguments...

#   #---------------------------------------------------------------------------------------------------------
#   log: ( P... ) ->
#     _console.log '^334-2^', P
#     return _console.log P...

#   # debug:            ƒ debug()
#   # error:            ƒ error()
#   # info:             ƒ info()
#   # warn:             ƒ warn()

#   #---------------------------------------------------------------------------------------------------------
#   # assert:           ƒ assert()
#   # clear:            ƒ clear()
#   # context:          ƒ context()
#   # count:            ƒ count()
#   # countReset:       ƒ countReset()
#   # dir:              ƒ dir()
#   # dirxml:           ƒ dirxml()
#   # group:            ƒ group()
#   # groupCollapsed:   ƒ groupCollapsed()
#   # groupEnd:         ƒ groupEnd()
#   # memory:           MemoryInfo {totalJSHeapSize: 19300000, usedJSHeapSize: 19300000, jsHeapSizeLimit: 2190000000}
#   # profile:          ƒ profile()
#   # profileEnd:       ƒ profileEnd()
#   # table:            ƒ table()
#   # time:             ƒ time()
#   # timeEnd:          ƒ timeEnd()
#   # timeLog:          ƒ timeLog()
#   # timeStamp:        ƒ timeStamp()
#   # trace:            ƒ trace()

# globalThis.console  = new Proxy console, new Intercepted_console()
# globalThis.log      = console.log
# globalThis.µ        = require 'mudom'
# # globalThis.XXTERM   = {};
# Combokeys           = require 'combokeys'
# count               = 0
# # ckeys               = new Combokeys document.documentElement
# ckeys               = new Combokeys µ.DOM.select_id 'terminal-container'
# ckeys.bind 'ctrl+y', ( event, key ) -> log '^ops-late@1^', event
# ckeys.bind 'ctrl+k', ( event, key ) ->
#   log '^ops-late@2^', "show or hide side bar"
#   event.preventDefault()
#   event.stopPropagation()
#   return false
# ckeys.bind 'ctrl+l', ( event, key ) ->
#   log '^ops-late@3^', "activate address bar"
#   event.preventDefault()
#   event.stopPropagation()
#   return false

console.log '^ops-late@4^', 'OK'
log "^ops-late@5^ OPS loaded"
console.log '^ops-late@5^', term

copy_keys = [
  'xxx'
  # 'type'
  'key'
  'code'
  'keyCode' ]

modifier_names = [
  'Alt'
  'AltGraph'
  'Control'
  'Meta'
  'Shift'
  'CapsLock' ]

locations = [
  'standard'
  'left'
  'right'
  'numpad' ]


xxx_from_event = ( event ) ->
  d         = {}
  d[ k ]    = event[ k ] for k in copy_keys
  xxx       = []
  location  = locations[ event.location ]
  if location isnt 'standard'
    d.location = location
    xxx.push location
  for k in modifier_names
    continue unless event.getModifierState k
    xxx.push k
    d[ k ] = true
  xxx.push d.key
  d.xxx   = xxx.join '+'
  d.event = event
  return d

handle_hotkeys = ( d ) ->
  switch d.xxx
    when 'Control+l'
      log '^ops-late@6^', "prevent activation of address bar"
      d.event.stopPropagation()
      d.event.preventDefault()
      return false
    when 'Control+q'
      log '^ops-late@6^', "quit app"
      d.event.stopPropagation()
      d.event.preventDefault()
      return false
  return null

handle_keys = ( event ) ->
  log '^ops-late@7^', event
  log '^ops-late@7^', xxx_from_event event
  return handle_hotkeys xxx_from_event event


µ.DOM.on document.documentElement, 'keydown', ( event ) -> handle_keys event
term.onKey                                    ( event ) -> handle_keys event.domEvent
# term.paste 'helo'

# log '^ops-late@7^', require 'cnd'
log '^ops-late@7^', require 'guy'
log '^ops-late@7^', require 'datom'


###
public addMarker(cursorYOffset: number): IMarker | undefined {
public attachCustomKeyEventHandler(customKeyEventHandler: CustomKeyEventHandler): void {
public bell(): void {
public bindMouse(): void {
public blur(): void {
public browser: IBrowser = Browser as any;
public cancel(ev: Event, force?: boolean): boolean | undefined {
public clear(): void {
public clearSelection(): void {
public clearTextureAtlas(): void {
public deregisterCharacterJoiner(joinerId: number): void {
public deregisterLinkMatcher(matcherId: number): void {
public dispose(): void {
public element: HTMLElement | undefined;
public focus(): void {
public get buffer(): IBuffer {
public get markers(): IMarker[] {
public get onA11yChar(): IEvent<string> { return this._onA11yCharEmitter.event; }
public get onA11yTab(): IEvent<number> { return this._onA11yTabEmitter.event; }
public get onBell(): IEvent<void> { return this._onBell.event; }
public get onBlur(): IEvent<void> { return this._onBlur.event; }
public get onCursorMove(): IEvent<void> { return this._onCursorMove.event; }
public get onFocus(): IEvent<void> { return this._onFocus.event; }
public get onKey(): IEvent<{ key: string, domEvent: KeyboardEvent }> { return this._onKey.event; }
public get onRender(): IEvent<{ start: number, end: number }> { return this._onRender.event; }
public get onSelectionChange(): IEvent<void> { return this._onSelectionChange.event; }
public get onTitleChange(): IEvent<string> { return this._onTitleChange.event; }
public getSelection(): string {
public getSelectionPosition(): ISelectionPosition | undefined {
public hasSelection(): boolean {
public linkifier2: ILinkifier2;
public linkifier: ILinkifier;
public open(parent: HTMLElement): void {
public paste(data: string): void {
public refresh(start: number, end: number): void {
public registerCharacterJoiner(handler: CharacterJoinerHandler): number {
public registerDecoration(decorationOptions: IDecorationOptions): IDecoration | undefined {
public registerLinkMatcher(regex: RegExp, handler: LinkMatcherHandler, options?: ILinkMatcherOptions): number {
public registerLinkProvider(linkProvider: ILinkProvider): IDisposable {
public reset(): void {
public resize(x: number, y: number): void {
public screenElement: HTMLElement | undefined;
public scrollLines(disp: number, suppressScrollEvent?: boolean, source = ScrollSource.TERMINAL): void {
public select(column: number, row: number, length: number): void {
public selectAll(): void {
public selectLines(start: number, end: number): void {
public textarea: HTMLTextAreaElement | undefined;
public updateCursorStyle(ev: KeyboardEvent): void {
public viewport: IViewport | undefined;
###

