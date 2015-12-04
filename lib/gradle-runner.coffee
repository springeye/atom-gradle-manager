{BufferedProcess} = require 'atom'
FileFinderUtil = require './file-finder-util'
util = require 'util'

class GradleRunner
  constructor: (@filePath, @settingsPath) ->
    @fileFinderUtil = new FileFinderUtil()
  getGradleTasks: (onTaskOutput, onOutput, onError, onExit, args) ->
    @runGradle 'tasks', onTaskOutput, onOutput, onError, onExit, args

  runGradle: (task, onTaskOutput, onOutput, stderr, exit, extraArgs) ->
    @process?.kill()
    @process = null

    ##get run command
    command = ''
    commands = @fileFinderUtil.findFiles if process.platform.indexOf 'win' == 0 then /^gradlew\.bat$/i else /^gradlew$/i
    if commands.length > 0
      command = commands[0]
    if command is ''
      command = 'gradle'
    else
      onOutput(util.format('Execute: "%s"', command))

    ##use settings.gradle when exist
    if @settingsPath?
      args = ['-c', @settingsPath]
      args.push('-b', @filePath)
      onOutput(util.format('Settings File: "%s"\nBuild File: "%s"', @settingsPath, @filePath))
    else
      args = ['-b', @filePath]
      onOutput(util.format('Build File: "%s"', @filePath))

    ##add options and args
    for arg in task.split ' '
      args.push(arg)

    if extraArgs
      for arg in extraArgs.split ' '
        args.push arg

    onOutput util.format('Task: "%s"', task)
    @process = new BufferedProcess
      command: command
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
