{DockPaneView, Toolbar} = require 'atom-bottom-dock'
{Emitter, CompositeDisposable} = require 'atom'
OutputView = require './output-view'
ControlsView = require './controls-view'
FileFinderUtil = require '../file-finder-util'
{$} = require 'space-pen'

class GradlePaneView extends DockPaneView
  @content: ->
    @div class: 'gradle-pane', style: 'display:flex;', =>
      @subview 'toolbar', new Toolbar()
      @subview 'outputView', new OutputView()

  initialize: ->
    super()
    @fileFinderUtil = new FileFinderUtil()
    @emitter = new Emitter()
    @subscriptions = new CompositeDisposable()
    @controlsView = new ControlsView()

    @outputView.show()

    @toolbar.addLeftTile item: @controlsView, priority: 0

    @subscriptions.add @controlsView.onDidSelectGradlefile @setGradlefile
    @subscriptions.add @controlsView.onDidClickRefresh @refresh
    @subscriptions.add @controlsView.onDidClickStop @stop
    @subscriptions.add @controlsView.onDidClickClear @clear

    @getGradlefiles()

  getGradlefiles: ->
    gradlefiles = []

    for filePath in @fileFinderUtil.findFiles /^build.gradle/i
      gradlefiles.push
        path: filePath
        relativePath: FileFinderUtil.getRelativePath filePath

    @controlsView.updateGradlefiles gradlefiles

  setGradlefile: (gradlefile) =>
    @outputView.refresh gradlefile

  refresh: =>
    @outputView.refresh()
    @getGradlefiles()

  stop: =>
    @outputView.stop()

  clear: =>
    @outputView.clear()

  destroy: ->
    @outputView.destroy()
    @subscriptions.dispose()
    @remove()

module.exports = GradlePaneView
