module.exports =
  class StepJumper

    constructor: (@line) ->
      matchData = @line.match(/^\s*(\w+)\s+(.*)/)
      if matchData
        @firstWord = matchData[1]
        @restOfLine = matchData[2]

    stepTypeRegex: ->
      new RegExp "(.given|.when|.then|.and)\(.*\)"

    checkMatch: ({filePath, matches}) ->
      for match in matches
        regex = match.matchText.match(/\/([^/]*)/)
        if (regex != null && regex[1] != 'undefined')
          regex[1] = regex[1].replace "$string", ".*"

        try
          regex = new RegExp(regex[1])
        catch e
          console.log(e)
          continue
        if @restOfLine.match(regex)
          return [filePath, match.range[0][0]]
