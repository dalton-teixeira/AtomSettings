fs = require 'fs'
path = require 'path'

propertyPrefixPattern = /(?:^|\[|\(|,|=|:|\s)\s*((?:And|Given|Then|When).*)$/

module.exports =
  selector: '.source.feature, .feature, given.js, then.js, when.js'
  filterSuggestions: true

  load: ->
    # Not used

  getSuggestions: ({bufferPosition, editor}) ->
    file = editor.getText()
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    @getCompletions(line, file)

  getCompletions: (line, file) ->
    completions = []
    match =  propertyPrefixPattern.exec(line)?[1]

    return completions unless match

    results = []

    regex = /(Given|And|When|Then)(.*)/g
    while (myRegexArray = regex.exec(file)) != null
      results.push({"text":myRegexArray[2].replace /^\s+|\s+$/g, ""})

    for feature in fs.readdirSync("#{@rootDirectory()}/features")
      continue unless /.feature/.test(feature)
      data = fs.readFileSync "#{@rootDirectory()}/features/#{feature}", 'utf8'
      while (myRegexArray2 = regex.exec(data)) != null
        results.push({"text":myRegexArray2[2].replace /^\s+|\s+$/g, ""})

    for step in fs.readdirSync("#{@rootDirectory()}/steps")
      regex = /(.given|.and|.when|.then)(.*)/ig
      data = fs.readFileSync "#{@rootDirectory()}/steps/#{step}", 'utf8'

      while (myRegexArray2 = regex.exec(data)) != null
        sugges = myRegexArray2[2].replace /(^\(\/|\^|\$\/|,$)/g, ""
        prefix = myRegexArray2[1]
        prefix = prefix.replace ".given", "Given "
        prefix = prefix.replace ".when", "When "
        prefix = prefix.replace ".then", "Then "
        prefix = prefix.replace ".and", "And "
        results.push({"text": prefix + sugges})

    return  results

  rootDirectory: ->
    atom.project.rootDirectories[0].path

  checkMatches: (matches) ->
