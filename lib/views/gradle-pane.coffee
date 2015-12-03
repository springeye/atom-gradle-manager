{DockPaneView, Toolbar} = require 'atom-bottom-dock'
{Emitter, CompositeDisposable} = require 'atom'
OutputView = require './output-view'
ControlsView = require './controls-view'
FileFinderUtil = require '../file-finder-util'
{$} = require 'space-pen'
path = require 'path'

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

    @settingsfile = {}
    @getGradlefiles()

  getGradlefiles: ->
    scriptfiles = []
    gradlefiles = []
    for filePath in @fileFinderUtil.findFiles /^(build|settings).gradle/i
      scriptfiles.push
        path: filePath
        relativePath: FileFinderUtil.getRelativePath filePath

    for file in scriptfiles
      if file.relativePath is 'settings.gradle'
        @settingsfile = file
      else
        gradlefiles.push file
        
    @controlsView.updateGradlefiles gradlefiles

  setGradlefile: (gradlefile) =>
    if @settingsfile?
      @outputView.refresh gradlefile, @settingsfile
    else
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
