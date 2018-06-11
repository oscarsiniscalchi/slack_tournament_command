require 'json'

module SlackMessageResponder
  ADD_MATCH_REGEX= /^(?<tournament>.*?)\s(<@(?<user_one_id>U.*?)\|(?<user_one_name>.*?)>\s(?<user_one_score>\d)\s)(<@(?<user_two_id>U.*?)\|(?<user_two_name>.*?)>\s(?<user_two_score>\d))/

  def self.error_response(error_message, additional_data = [])
    attachments = additional_data.map { |att| { text: att } }

    JSON.generate({
      response_type: 'ephemeral',
      text: error_message,
      attachments: attachments
    })
  end

  def self.leaderboard(params)
    tournament_name = params['text']
    tournament = Tournament.first(name: tournament_name)

    return error_response(
      "Woops! No such tournament #{tournament_name}",
      ["You can register a match with `/match #{tournament_name}` <user_1> <score> <user_2> <score>"]
    ) unless tournament

    position = 0
    response_text = tournament.leaders.inject('') do |memo, data|
      position += 1
      slack_id, score = data
      memo += "#{decorate_position(position)} - <@#{slack_id}> - #{score}.\n"

      memo
    end

    JSON.generate({
      response_type: 'in_channel',
      text: response_text,
    })
  end

  def self.decorate_position(position)
    case position
    when 1
      ':first_place_medal:'
    when 2
      ':second_place_medal:'
    when 3
      ':third_place_medal:'
    else
      position
    end

  end

  def self.register_match(params)
    match_data = params['text'].match(ADD_MATCH_REGEX)
    MatchService.new(match_data).register_match_results

    JSON.generate({
      response_type: 'ephemeral',
      text: "Ok. Match registerd and rankings updated.",
    })
  end
end
