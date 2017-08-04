$LOAD_PATH << '.'

require 'player_repository'
require 'cwimatch_repository'

module CWIResultProcessor

# Data should be a collection with:
# "players" => ["name1", ..., "name4"]
# "results" => [5, 3]  (score of name1+name2 , name3+name4)
# "start" => time
# "end" => time

def self.parse_result(data)
  group_id = 1 #TODO: FIX THIS
  playernames = data['players']

  #Find players in repo
  player_repo = PlayerRepository.new()
  players = []
  playernames.each do |name|
    player = player_repo.get_by_name(name)
    id = 0
    # Add new player if it was not found
    if player.nil?
      player = Player.new(nil, name, nil)
      id = player_repo.add(player)
    else
      id = player.id
    end
    players << id
  end

  match = CWIMatch.new(nil, players, group_id)

  time = Time.at(data['start'])
  duration = data['end'] - data['start']
  match.set_played_stats(time, duration)

  match.set_scores(data['results'])

  match_repo = CWIMatchRepository.new()
  match_repo.add(match)

  return true
end

end
