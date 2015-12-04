{DockPaneView} = require 'atom-bottom-dock'
{Emitter, CompositeDisposable} = require 'atom'
{$} = require 'space-pen'

class ControlsView extends DockPaneView
  @content: ->
    @div =>
      @span outlet: 'stopButton', class: 'stop-button icon icon-primitive-square', click: 'onStopClicked'
      @span outlet: 'refreshButton', class: 'refresh-button icon icon-sync', click: 'onRefreshClicked'
      @span outlet: 'clearButton', class: 'clear-button icon icon-history', click: 'onClearClicked'
      @span class: 'args-input-label', 'Input Task(And Args)::'

  initialize: ->
    super()
    @emitter = new Emitter()
    @subscriptions = new CompositeDisposable()

    @setupCustomTaskInput()

  setupCustomTaskInput: ->
    @argsInput = document.createElement 'atom-text-editor'
    @argsInput.classList.add 'text-editor'
    @argsInput.setAttribute 'mini', ''
    @argsInput.getModel().setPlaceholderText 'Press Enter to run (Example:tasks --info)'
    @argsInput.addEventListener 'keyup', @onFetchArgsChanged

    @append @argsInput

  onDidClickRefresh: (callback) ->
    @emitter.on 'button:refresh:clicked', callback

  onDidClickStop: (callback) ->
    @emitter.on 'button:stop:clicked', callback

  onDidClickClear: (callback) ->
    @emitter.on 'button:clear:clicked', callback

  onDidInputCustom: (callback) ->
    @emitter.on 'input:custom:clicked', callback

  onRefreshClicked: ->
    @emitter.emit 'button:refresh:clicked'

  onStopClicked: ->
    @emitter.emit 'button:stop:clicked'

  onClearClicked:->
    @emitter.emit 'button:clear:clicked'

  onFetchArgsChanged: (e) =>
    return unless e.keyCode is 13 and @argsInput.getModel().getText()
    @emitter.emit 'input:custom:clicked',@argsInput.getModel().getText()


module.exports = ControlsView
