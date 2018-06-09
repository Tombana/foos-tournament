class CWIGroup

attr_accessor :id
attr_reader :name
attr_reader :scoring
attr_reader :players


def initialize(id, name, scoring, players, matches)
  @id = id
  @name = name
  @scoring = scoring
  @players = players
  @matches = matches
  @analysis_cache = nil
end

def get_player_ids()
  return @players.map { |x| x.id }
end

def get_matches()
  return @matches
end

# Should return an array [c1, c2, ... ]
# where each object in the array has
#
# c[:player_id]
# c[:position]
# c[:points]
# c[:num_matches]
# 
def get_current_classification()
  return get_analysis()
end

def get_statistics()
  team_wins = [0,0]
  @matches.each do |m|
    if m.scores[0] > m.scores[1]
      team_wins[0] += 1
    else
      team_wins[1] += 1
    end
  end
  return team_wins
end

private

def get_analysis()
  @analysis_cache = analyse() if not @analysis_cache
  return @analysis_cache
end

# Map score[0],score[1] to number in [0,1]
def getScore(scores)
  a = scores[0]
  b = scores[1]
  if a == b
    return 0.5
  end
  #if a > b
  #  a += 10
  #else
  #  b += 10
  #end
  # a / (a+b)
  return a.fdiv(a + b)
end

def analyse()
  classification = {}

  player_ids = get_player_ids()
  player_ids.each do |p|
    classification[p] = {
      :player_id => p,
      :position => 0,
      :points => 0,
      :num_matches => 0,
      :attackElo => 1500.0,
      :defenseElo => 1500.0,
      :attackEloCount => 0,
      :defenseEloCount => 0,
      :latest_match_time => Time.new(2016),
    }
  end

  get_matches().reverse.each do |m|
    m.players.zip(m.victories).each do |p,v|
      if not classification.include? p
        classification[p] = {
          :player_id => p,
          :position => 0,
          :points => 0,
          :num_matches => 0,
          :attackElo => 1500.0,
          :defenseElo => 1500.0,
          :attackEloCount => 0,
          :defenseEloCount => 0,
          :latest_match_time => Time.new(2016),
        }
      end
      classification[p][:points] += v
      classification[p][:num_matches] += 1
      classification[p][:latest_match_time] = m.time.to_time
    end
    m.elos = [0,0,0,0]
    m.elos[0] = classification[m.players[0]][:defenseElo].round
    m.elos[1] = classification[m.players[1]][:attackElo].round
    m.elos[2] = classification[m.players[2]][:attackElo].round
    m.elos[3] = classification[m.players[3]][:defenseElo].round

    blueElo = 0.6 * classification[m.players[0]][:defenseElo] + 0.4 * classification[m.players[1]][:attackElo]
    redElo  = 0.6 * classification[m.players[3]][:defenseElo] + 0.4 * classification[m.players[2]][:attackElo]
    # Expected score, number between 0 and 1
    eBlue = 1.0 / (1.0 + (10.0 ** ((redElo - blueElo)/400.0)))
    # Score function mapping m.scores to [0,1]
    scoreBlue = getScore(m.scores)
    # gain: score minus expectedscore
    gainBlue = scoreBlue - eBlue
    gainRed  = -gainBlue
    # TODO: individual K factor per player
    kFactor = 50.0
    classification[m.players[0]][:defenseElo] += kFactor * gainBlue
    classification[m.players[1]][:attackElo]  += kFactor * gainBlue
    classification[m.players[2]][:attackElo]  += kFactor * gainRed
    classification[m.players[3]][:defenseElo] += kFactor * gainRed
    classification[m.players[0]][:defenseEloCount] += 1
    classification[m.players[1]][:attackEloCount]  += 1
    classification[m.players[2]][:attackEloCount]  += 1
    classification[m.players[3]][:defenseEloCount] += 1

    m.elodiffs = [0,0,0,0]
    m.elodiffs[0] = (kFactor * gainBlue).round
    m.elodiffs[1] = (kFactor * gainBlue).round
    m.elodiffs[2] = (kFactor * gainRed).round
    m.elodiffs[3] = (kFactor * gainRed).round
  end

  # Most recent match should be within 2 months + twice the number of matches in days
  tnow = Time.now
  classification = classification.select{|playerid,data| (tnow - data[:latest_match_time]) <= (2 * (30 + data[:num_matches]) * (24*60*60)) }

  best_attackers = classification.values.sort do |a, b|
    comp = b[:attackElo] <=> a[:attackElo]
    comp.zero? ? (b[:defenseElo] <=> a[:defenseElo]) : comp
  end
  best_defenders = classification.values.sort do |a, b|
    comp = b[:defenseElo] <=> a[:defenseElo]
    comp.zero? ? (b[:attackElo] <=> a[:attackElo]) : comp
  end
  best_attackers.each do |c|
    c[:attackElo] = c[:attackElo].round
    c[:defenseElo] = c[:defenseElo].round
  end
  best_defenders.each do |c|
    c[:attackElo] = c[:attackElo].round
    c[:defenseElo] = c[:defenseElo].round
  end

  # Sort by points and then by number of matches (reverse)
  sorted_classification = classification.values.sort do |a, b|
    comp = b[:points] <=> a[:points]
    comp.zero? ? (a[:num_matches] <=> b[:num_matches]) : comp
  end

  pos = 1
  sorted_classification.each do |c|
    c[:position] = pos
    pos += 1

    c[:attackElo] = c[:attackElo].round
    c[:defenseElo] = c[:defenseElo].round
  end

  return {:overall => sorted_classification, :bestattackers => best_attackers, :bestdefenders => best_defenders}
end

end
