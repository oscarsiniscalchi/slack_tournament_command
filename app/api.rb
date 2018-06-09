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
    on 'slack_command' do
      res.headers['Content-Type'] = 'application/json; charset=utf-8'
      res.write SlackMessageResponder.response(req.params)
    end
  end
end
