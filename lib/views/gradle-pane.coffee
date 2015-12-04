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
    @subscriptions.add @controlsView.onDidInputCustom @inputCustom
    @subscriptions.add @controlsView.onDidClickRefresh @refresh
    @subscriptions.add @controlsView.onDidClickStop @stop
    @subscriptions.add @controlsView.onDidClickClear @clear

    @outputView.refreshUIAndTask()


  refresh: =>
    @outputView.refreshUIAndTask()

  inputCustom: (task) =>
    args=task.split(' ')
    if args.length>1
      @outputView.runTask args[0],args.join(' ')
    else
      @outputView.runTask task


  stop: =>
    @outputView.stop()

  clear: =>
    @outputView.clear()

  destroy: ->
    @outputView.destroy()
    @subscriptions.dispose()
    @remove()

module.exports = GradlePaneView
