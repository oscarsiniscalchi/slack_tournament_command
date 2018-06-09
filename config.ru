require 'byebug'

require 'dotenv'
Dotenv.load

require './app/services/match_service'
require './app/services/ranking_service'
require './app/services/slack_message_responder'
require './app/api'

require './db'

run Cuba
