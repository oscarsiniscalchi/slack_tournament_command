require 'data_mapper'

# If you want the logs displayed you have to do this before the call to setup
DataMapper::Logger.new($stdout, :debug)

# A Postgres connection:
DataMapper.setup(:default, ENV['DATABASE_URL'])

class Tournament
  include DataMapper::Resource

  property :id,   Serial
  property :name, String
  has n, :matches
  has n, :tournament_scores

  def leaders
    tournament_scores
      .all(fields: [:user_id, :score, :id], order: [:id.desc])
      .each_with_index
      .map{ |ts, i|
        [i+1, ts.user.slack_id, ts.score]
      }.uniq{ |re| re[1] }
  end
end

class Match
  include DataMapper::Resource

  property :id,             Serial
  property :created_at,     DateTime
  property :user_one_score, Integer
  property :user_two_score, Integer

  belongs_to :user_one, 'User', key: true
  belongs_to :user_two, 'User', key: true
  belongs_to :tournament

  def user_one_win?
    user_one_score > user_two_score
  end

  def user_two_win?
    user_one_score < user_two_score
  end
end

class User
  include DataMapper::Resource

  property :id,       Serial
  property :slack_id, String

  has n, :matches_as_one, 'Match', child_key: [ :user_one_id ]
  has n, :matches_as_two, 'Match', child_key: [ :user_two_id ]
  has n, :tournament_scores, 'TournamentScore'

  def current_score_value(tournament)
    tournament_score = current_score(tournament)
    tournament_score ? tournament_score.score : 1500
  end

  def current_score(tournament)
    tournament_scores.last({tournament: tournament})
  end
end

class TournamentScore
  include DataMapper::Resource
  property :id,    Serial
  property :score, Integer

  belongs_to :tournament
  belongs_to :user
end

DataMapper.finalize
# DataMapper.auto_migrate!
