{BufferedProcess} = require 'atom'
path = require 'path'
class GradleRunner
  constructor: (@filePath) ->

  getGradleTasks: (onOutput, onError, onExit, args) ->
    @runGradle 'tasks', onOutput, onError, onExit, args

  runGradle: (task, stdout, stderr, exit, extraArgs) ->
    @process?.kill()
    @process = null
    if  path.basename(@filePath)== 'settings.gradle'
        args=['-c',@filePath]
    else
        args=['-b',@filePath]


    for arg in task.split ' '
      args.push(arg)

    if extraArgs
      for arg in extraArgs.split ' '
        args.push arg
    @process = new BufferedProcess
      command: 'gradle'
      args: args
      options:
        env: process.env
      stdout: stdout
      stderr: stderr
      exit: exit

  destroy: ->
    @process?.kill()
    @process = null

module.exports = GradleRunner
