class MatchService
  attr_reader :match_data, :tournament, :user_one, :user_two

  def initialize(match_data)
    @match_data = match_data
    @tournament = Tournament.first_or_create(name: match_data[:tournament])
    @user_one   = User.first_or_create(slack_id: match_data[:user_one_id])
    @user_two   = User.first_or_create(slack_id: match_data[:user_two_id])
  end


  def register_match_results
    match = Match.create(
      created_at: Time.now,
      user_one: user_one,
      user_two: user_two,
      user_one_score: match_data[:user_one_score],
      user_two_score: match_data[:user_two_score],
      tournament: tournament
    )

    RankingService.compute_scores(match)

    match
  end
end
