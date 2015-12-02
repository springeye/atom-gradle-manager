{DockPaneView} = require 'atom-bottom-dock'
{Emitter, CompositeDisposable} = require 'atom'
{$} = require 'space-pen'

class ControlsView extends DockPaneView
  @content: ->
    @div =>
      @span outlet: 'stopButton', class: 'stop-button icon icon-primitive-square', click: 'onStopClicked'
      @span outlet: 'refreshButton', class: 'refresh-button icon icon-sync', click: 'onRefreshClicked'
      @span outlet: 'clearButton', class: 'clear-button icon icon-history', click: 'onClearClicked'
      @select outlet: 'fileSelector'
      @span class: 'args-input-label', 'Args to fetch tasks (optional):'

  initialize: ->
    super()
    @emitter = new Emitter()
    @subscriptions = new CompositeDisposable()
    @fileSelector.change(@onGradlefileSelected)

    @setupCustomTaskInput()


  setupCustomTaskInput: ->
    @argsInput = document.createElement 'atom-text-editor'
    @argsInput.classList.add 'text-editor'
    @argsInput.setAttribute 'mini', ''
    @argsInput.getModel().setPlaceholderText 'Press Enter to run'

    @argsInput.addEventListener 'keyup', @onFetchArgsChanged

    @append @argsInput

  updateGradlefiles: (gradlefiles) ->
    @gradlefiles = {}
    @fileSelector.empty()

    for gradlefile in gradlefiles
      @gradlefiles[gradlefile.relativePath] = gradlefile

      @fileSelector.append $("<option>#{gradlefile.relativePath}</option>")
    if gradlefiles.length
      @fileSelector.selectedIndex = 0
      @fileSelector.change()

  onDidClickRefresh: (callback) ->
    @emitter.on 'button:refresh:clicked', callback

  onDidClickStop: (callback) ->
    @emitter.on 'button:stop:clicked', callback

  onDidClickClear: (callback) ->
    @emitter.on 'button:clear:clicked', callback

  onDidSelectGradlefile: (callback) ->
    @emitter.on 'gradlefile:selected', callback

  onRefreshClicked: ->
    @emitter.emit 'button:refresh:clicked'

  onStopClicked: ->
    @emitter.emit 'button:stop:clicked'

  onClearClicked: (callback) ->
    @emitter.emit 'button:clear:clicked'

  onGradlefileSelected: (e) =>
    gradlefile = @gradlefiles[e.target.value]
    gradlefile.args = @argsInput.getModel().getText()
    @emitter.emit 'gradlefile:selected', gradlefile

  onFetchArgsChanged: (e) =>
    return unless e.keyCode is 13 and @fileSelector.val()

    gradlefile = @gradlefiles[@fileSelector.val()]
    gradlefile.args = @argsInput.getModel().getText()
    @emitter.emit 'gradlefile:selected', gradlefile


module.exports = ControlsView
