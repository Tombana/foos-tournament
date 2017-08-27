#
# Describes a single match that has already been played
# No submatches
#
class CWIMatch

attr_accessor :id 
attr_reader :players
attr_reader :group_id
attr_reader :time
attr_reader :duration
attr_reader :scores
attr_reader :victories
attr_accessor :elos
attr_accessor :elodiffs
attr_accessor :replays

def initialize(id, players, group_id)
  @id = id
  @players = players
  @group_id = group_id

  @time = nil
  @duration = nil

  @scores = []
  @victories = []

  @elos = []
  @elodiffs = []

  @replays = []
end

def set_played_stats(time, duration)
  @time = time
  @duration = duration
end

def set_scores(scores)
  @scores = scores
  calculate_victories()
end

def calculate_victories()
  @victories = [0, 0, 0, 0]
  if @scores[0] > @scores[1]
    @victories[0] += 1
    @victories[1] += 1
  else
    @victories[2] += 1
    @victories[3] += 1
  end
end

# FIXME: The human version should be generated in FE, not here
def get_time()
  return @time.strftime("%Y/%m/%d %H:%M")
end

# FIXME: The human version should be generated in FE, not here
def get_duration()
  if @duration
    duration_human = "%02d:%02d" % [@duration / 60, @duration % 60]
  else
    duration_human = "-"
  end
  return duration_human
end

end
