class CWIGroup

attr_accessor :id
attr_reader :name
attr_reader :scoring
attr_reader :players

@analysis_cache = nil

def initialize(id, name, scoring, players, matches)
  @id = id
  @name = name
  @scoring = scoring
  @players = players
  @matches = matches
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

private

def get_analysis()
  @analysis_cache = analyse() if not @analysis_cache
  return @analysis_cache
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
    }
  end

  get_matches().each do |m|
    m.players.zip(m.victories).each do |p,v|
      if classification.include? p
        classification[p][:points] += v
        classification[p][:num_matches] += 1
      else
        classification[p] = {
          :player_id => p,
          :position => 0,
          :points => v,
          :num_matches => 1,
        }
      end
    end
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
  end

  return sorted_classification
end

end
