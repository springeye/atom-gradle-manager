{BufferedProcess} = require 'atom'
path = require 'path'
FileFinderUtil = require './file-finder-util'
util = require 'util'

class GradleRunner
  constructor: () ->
    @fileFinderUtil = new FileFinderUtil()
    @gradleHome=atom.config.get('gradle-manager.gradle_home')

  getGradleTasks: (onOutput, onError, onExit, args) ->
    @runGradle 'tasks',onOutput, onError, onExit, args


  runGradle: (task, onOutput, stderr, exit, extraArgs) ->
    cwd=atom.project.getPaths()[0]

    @process?.kill()
    @process = null
    win= process.platform.indexOf 'win'
    ##get run command
    command = ''
    commands = @fileFinderUtil.findFiles unless win then /^gradlew\.bat$/i else /^gradlew$/i
    if commands.length > 0
      command = commands[0]
    if command is ''
      if @gradleHome?.trim()
          unless win
              command= path.join @gradleHome,'/bin/gradle.bat'
          else
              command= path.join @gradleHome,'/bin/gradle'
      else
          unless win
              command = 'gradle.bat'
          else
              command = 'gradle'


    args=[]
    ##add options and args
    for arg in task.split ' '
      args.push(arg)

    if extraArgs
      for arg in extraArgs.split ' '
        args.push arg
    onOutput util.format('Path: "%s"', cwd),'text-info'
    if extraArgs
      onOutput util.format('Execute: "%s %s %s"', command,task,extraArgs),'text-info'
    else
      onOutput util.format('Execute: "%s %s"', command,task),'text-info'
    @process = new BufferedProcess
      command: command
      args: args
      options:
        env: process.env,
        cwd:cwd
      stdout: onOutput
      stderr: stderr
      exit: exit

  destroy: ->
    @process?.kill()
    @process = null

module.exports = GradleRunner
