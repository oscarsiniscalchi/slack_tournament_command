require 'cuba'
require 'cuba/safe'

Cuba.use Rack::Session::Cookie, secret: 'mysecretkey'

Cuba.plugin Cuba::Safe

Cuba.define do
  on get do
    on 'status' do
      res.headers['Content-Type'] = 'application/json; charset=utf-8'
      res.write '{ "status": "ok" }'
    end

    on root do
      res.redirect '/status'
    end
  end

  on post do
    on 'leaderboard' do
      res.headers['Content-Type'] = 'application/json; charset=utf-8'
      res.write SlackMessageResponder.leaderboard(req.params)
    end

    on 'register_match' do
      res.headers['Content-Type'] = 'application/json; charset=utf-8'
      res.write SlackMessageResponder.register_match(req.params)
    end
  end
end
