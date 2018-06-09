require 'json'

module SlackMessageResponder
  ADD_MATCH_REGEX= /^(?<tournament>.*?)\s(<@(?<user_one_id>U.*?)\|(?<user_one_name>.*?)>\s(?<user_one_score>\d)\s)(<@(?<user_two_id>U.*?)\|(?<user_two_name>.*?)>\s(?<user_two_score>\d))/
  LEADERBOARD_REGEX=/^lead.*?\s(?<tournament>.*?)$/

  def self.response(params)
    action = recognize_action(params['text'])
    send(action, params)
  end

  def self.recognize_action(text)
    return :leaderboard if text.match(LEADERBOARD_REGEX)
    return :add_match if text.match(ADD_MATCH_REGEX)

    :unrecognized_response
  end

  def self.unrecognized_response(params)
    JSON.generate({
      response_type: 'ephemeral',
      text: 'Oops! Not a valid command',
    })
  end

  def self.leaderboard(params)
    data = params['text'].match(LEADERBOARD_REGEX)
    tournament = Tournament.first(name: data[:tournament])
    list = User.all.map{ |u|
      [ u.current_score_value(tournament),
      u.slack_id]
    }
    JSON.generate({
      response_type: 'on_channel',
      text: list,
    })
  end

  def self.add_match(params)
    match_data = params['text'].match(ADD_MATCH_REGEX)
    MatchService.new(match_data).register_match_results

    tournament = Tournament.first(name: match_data[:tournament])
    list = User.all.map{ |u|
      [ u.current_score_value(tournament),
      u.slack_id]
    }
    return JSON.generate({
      response_type: 'on_channel',
      text: list,
    })

    JSON.generate({
      response_type: 'ephemeral',
      text: "Match registred",
    })
  end
end
