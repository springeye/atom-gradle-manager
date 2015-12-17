{View, $} = require 'space-pen'
{Emitter, CompositeDisposable} = require 'atom'
GradleRunner = require '../gradle-runner'
LeftPane = require './left-pane.coffee'
Converter = require 'ansi-to-html'
{Toolbar} = require 'atom-bottom-dock'
Paraser = require '../ParserUtil.coffee'
class OutputView extends View
  @content: ->
    @div class: 'output-view', style: 'display:flex;', =>
      @div class: 'content-container', =>
        @div outlet: 'outputContainer', class: 'output-container native-key-bindings', tabindex: -1

  initialize: ->
    @emitter = new Emitter()
    @converter = new Converter fg: $('<span>').css('color')
    @subscriptions = new CompositeDisposable()
    @leftPaneItem = new LeftPane()
    @leftPane=atom.workspace.addRightPanel(item:@leftPaneItem,visible:false)
  show:()->
    super
    @leftPane.show()
  setupTaskList: (tasks) ->
    @leftPaneItem.refresh(this,tasks)

  refreshTasks: ->
    @tasks = []
    output = "fetching gradle tasks"
    @writeOutput output, 'text-info'
    parser=new Paraser
    onTaskOutput = (output,type) =>
      @writeOutput output, type
      if type
        return
      else
        parser.write(output)

    onTaskExit = (code) =>

      if code is 0
        @tasks=parser.parser()
        parser.close()
        @setupTaskList @tasks
        @writeOutput "#{@tasks.length} tasks found", "text-info"
      else
        @onExit code
    @Runner.getGradleTasks onTaskOutput, @onError, onTaskExit

  setupGradleRunner: () ->
      @Runner = new GradleRunner


  runTask: (task,args) ->
    @Runner?.runGradle task,  @onOutput, @onError, @onExit,args

  writeOutput: (line, klass) ->
    return unless line?.length

    el = $('<pre>')
    el.append line

    el.addClass klass if klass
    @outputContainer.append el
    @outputContainer.scrollToBottom()

  onOutput: (output) =>
    for line in output.split '\n'
      @writeOutput @converter.toHtml(line)

  onError: (output) =>
    for line in output.split '\n'
      @writeOutput @converter.toHtml(line), 'text-error'

  onExit: (code) =>
    @writeOutput "Exited with code #{code}",
      "#{if code then 'text-error' else 'text-success'}"

  stop: ->
    @Runner?.destroy()
    @writeOutput('Task Stopped', 'text-info')

  clear: ->
    @outputContainer.empty()

  refreshUIAndTask: ->
    @outputContainer.empty()
    @leftPaneItem.clear()
    @setupGradleRunner()
    @refreshTasks()

  destroy: ->
    @leftPane.destroy()
    @Runner?.destroy()
    @Runner = null
    @subscriptions?.dispose()

module.exports = OutputView
