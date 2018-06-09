require 'json'

module SlackMessageResponder
  ADD_MATCH_REGEX= /^(?<tournament>.*?)\s(<@(?<user_one_id>U.*?)\|(?<user_one_name>.*?)>\s(?<user_one_score>\d)\s)(<@(?<user_two_id>U.*?)\|(?<user_two_name>.*?)>\s(?<user_two_score>\d))/
  ADD_MATCH_COMMAND_REGEX= /\/match/
  LEADERBOARD_COMMAND_REGEX=/\/leaderboard/

  def self.response(params)
    action = recognize_action(params['command'])
    send(action, params)
  end

  def self.recognize_action(text)
    return :leaderboard if text.match(LEADERBOARD_COMMAND_REGEX)
    return :add_match if text.match(ADD_MATCH_COMMAND_REGEX)

    :unrecognized_response
  end

  def self.unrecognized_response(params)
    JSON.generate({
      response_type: 'ephemeral',
      text: 'Oops! Not a valid command',
    })
  end

  def self.leaderboard(params)
    tournament_name = params['text']
    tournament = Tournament.first(name: tournament_name)
    position = 0
    response_text = tournament.leaders.inject('') do |memo, data|
      position += 1
      slack_id, score = data
      memo += "#{position} - <@#{slack_id}> - #{score}.\n"

      memo
    end

    JSON.generate({
      response_type: 'on_channel',
      text: response_text,
    })
  end

  def self.add_match(params)
    match_data = params['text'].match(ADD_MATCH_REGEX)
    MatchService.new(match_data).register_match_results

    JSON.generate({
      response_type: 'ephemeral',
      text: "Ok. Match registerd and rankings updated.",
    })
  end
end
