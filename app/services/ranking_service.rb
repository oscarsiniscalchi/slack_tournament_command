class RankingService
  K = 30

  def self.compute_scores(match)
    r1 = match.user_one.current_score_value(match.tournament)
    r2 = match.user_two.current_score_value(match.tournament)

    # Compute transformed rating

    tr1 = 10^(r1/400)
    tr2 = 10^(r2/400)

    # Calculate Expected Score

    e1 = tr1 / (tr1 + tr2)
    e2 = tr2 / (tr1 + tr2)

    # Actual Score

    s1 = match.user_one_win? ? 1 : 0
    s2 = match.user_two_win? ? 1 : 0

    # updated scores values

    usv1 = r1 + (K * (s1 - e1))
    usv2 = r2 + (K * (s2 - e2))

    match.user_one.tournament_scores.create(tournament: match.tournament, score: usv1)
    match.user_two.tournament_scores.create(tournament: match.tournament, score: usv2)
  end
end
