{View, $} = require 'space-pen'
{Emitter, CompositeDisposable} = require 'atom'
GradleRunner = require '../gradle-runner'
LeftPane = require './left-pane.coffee'
Converter = require 'ansi-to-html'
{Toolbar} = require 'atom-bottom-dock'

class OutputView extends View
  @content: ->
    @div class: 'output-view', style: 'display:flex;', =>
      @div class: 'content-container', =>
        @div outlet: 'outputContainer', class: 'output-container native-key-bindings', tabindex: -1

  initialize: ->
    @emitter = new Emitter()
    @converter = new Converter fg: $('<span>').css('color')
    @subscriptions = new CompositeDisposable()
    @leftPane = new LeftPane()
    atom.workspace.addRightPanel(item:@leftPane)

  setupTaskList: (tasks) ->
    @leftPane.refresh(this,tasks)

  addGradleTasks: ->
    @tasks = []
    output = "fetching gradle tasks for #{@gradlefile.relativePath}"
    output += " with args: #{@gradlefile.args}" if @gradlefile.args
    @writeOutput output, 'text-info'

    filter = (index, size, task) ->
      if index >= (size - 8) or index <= 20
        true
      else if task == ''
        true
      else if task.replaceAll('-', '') == ''
        true
      else if task is 'Other tasks'
        true
      else if task is 'BUILD SUCCESSFUL'
        true

    onTaskOutput = (output,type) =>
      @writeOutput output, type
      if type
        return
      else
        console.log 'handler tasks'
        @tasks = (task for task in output.split '\n' )

        @handleTask = (task for task,i in @tasks when !filter(i, @tasks.length, task))

        @tasks = []
        @tasks.push task for task in @handleTask
        @handleTask = []


        for t,i in @tasks
          arr = ('' + t).split '-'
          @handleTask.push(arr[0])


        @tasks = []
        @tasks.push task for task in @handleTask


    onTaskExit = (code) =>
      if code is 0
        @setupTaskList @tasks

        @writeOutput "#{@tasks.length} tasks found", "text-info"
      else
        @onExit code
    @gradlefileRunner.getGradleTasks onTaskOutput, @onError, onTaskExit, @gradlefile.args

  setupGradleRunner: (gradlefile, settingsfile) ->
    if settingsfile?
      @gradlefileRunner = new GradleRunner gradlefile.path, settingsfile.path
    else
      @gradlefileRunner = new GradleRunner gradlefile.path
  runTask: (task,args) ->

    @gradlefileRunner?.runGradle task,  @onOutput, @onError, @onExit,args

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
    if @gradlefileRunner
      @gradlefileRunner.destroy()
      @writeOutput('Task Stopped', 'text-info')

  clear: ->
    @outputContainer.empty()

  refresh: (gradlefile, settingsfile) ->
    @destroy()
    @outputContainer.empty()
    @leftPane.clear()
    unless gradlefile
      @gradlefile = null
      return

    @gradlefile = gradlefile
    @settingsfile = settingsfile
    @setupGradleRunner @gradlefile, @settingsfile
    @addGradleTasks()

  destroy: ->
    @gradlefileRunner?.destroy()
    @gradlefileRunner = null
    @subscriptions?.dispose()

module.exports = OutputView
