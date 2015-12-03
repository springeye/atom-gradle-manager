{BufferedProcess} = require 'atom'
util = require 'util'

class GradleRunner
  constructor: (@filePath, @settingsPath) ->

  getGradleTasks: (onTaskOutput, onOutput, onError, onExit, args) ->
    @runGradle 'tasks', onTaskOutput, onOutput, onError, onExit, args

  runGradle: (task, onTaskOutput, onOutput, stderr, exit, extraArgs) ->
    @process?.kill()
    @process = null
    if @settingsPath?
      args = ['-c', @settingsPath]
      args.push('-b', @filePath)
      onOutput(util.format('settings.gradle : %s\nbuild.gradle : %s', @settingsPath, @filePath))
    else
      args = ['-b', @filePath]
      onOutput(util.format('build.gradle : %s', @filePath))

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
      stdout: onTaskOutput
      stderr: stderr
      exit: exit

  destroy: ->
    @process?.kill()
    @process = null

module.exports = GradleRunner
