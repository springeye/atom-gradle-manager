{CompositeDisposable} = require 'atom'
{BasicTabButton} = require 'atom-bottom-dock'

GradlePane = require './views/gradle-pane'

module.exports =
  activate: (state) ->
    @subscriptions = new CompositeDisposable()
    @gradlePanes = []

    packageFound = atom.packages.getAvailablePackageNames()
    .indexOf('bottom-dock') != -1

    unless packageFound
      atom.notifications.addError 'Could not find Bottom-Dock',
        detail: 'Gradle-Manager: The bottom-dock package is a dependency. \n
        Learn more about bottom-dock here: https://atom.io/packages/bottom-dock'
        dismissable: true

    @subscriptions.add atom.commands.add 'atom-workspace',
      'gradle-manager:add': => @add()

  consumeBottomDock: (@bottomDock) ->
    @add()

  add: ->
    if @bottomDock
      newPane = new GradlePane()
      @gradlePanes.push newPane

      config =
        name: 'Gradle'
        id: newPane.getId()
        active: newPane.isActive()

      @bottomDock.addPane newPane, 'Gradle'

  deactivate: ->
    @subscriptions.dispose()
    @bottomDock.deletePane pane.getId() for pane in @gradlePanes
