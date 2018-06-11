# ELO RANKINGS FOR OFFICE TOURNAMENTS.

This is the backend api to add two custom commands to Slack.

## Register match

`/match tournament_name <@user_1> <score_1> <@user_2> <score_2>`

This will register a tournament if it does not exist and register the match between the two users.
It will also update the Elo ranking of those users. If user has no registered ranking it will default to 1500.
K factor for tournaments is hardcoded to 30. Eventually it could be an attribute of the tournament
to have leagues with different rankings.

## Leaderboard

`/leaderboard tournament_name`

This will simply look for a tournament with the provided name and list
the ordered list of users based on their current ELO points for that tournament.

## TODO

- ~Clean up code. Separate the single entry point to independent entry points (originally planed for a bot integration)~
- Make K factor configurable per tournament
- Minimal web UX to list leaderboards per tournament
- Achievements (background process that grant users trophies )
