$LOAD_PATH << '.'

require 'dm/data_model'
require 'cwimatch'

class CWIMatchRepository

public

def get(match_id)
  match_record = DataModel::Cwimatch.get(match_id)
  if match_record.nil?
    return nil
  end
  return map_record_to_entity(match_record)
end

def get_group_matches(group_id)
  match_records = DataModel::Cwimatch.all(DataModel::Cwimatch.cwigroup.id => group_id, :order => [:time.desc, :id.asc])
  return map_records_to_entities(match_records)
end

def get_recently_finished_matches(limit)
  match_records = DataModel::Cwimatch.all(:order => [:time.desc], :limit => limit)
  return map_records_to_entities(match_records)
end

def update(match_entity)
  match_id = match_entity.id
  match_record = DataModel::Cwimatch.get(match_id)
  map_entity_to_record(match_entity, match_record)
  match_record.save
end

def add(match_entity)
  match_record = DataModel::Cwimatch.new()
  map_entity_to_record(match_entity, match_record)
  match_record.save
  match_entity.id = match_record.id
  return match_record.id
end

def delete(match_entity)
  match_id = match_entity.id
  match_record = DataModel::Cwimatch.get(match_id)
  match_record.destroy
end

private

def map_record_to_entity(m)
  players = [m.pl1, m.pl2, m.pl3, m.pl4]
  match_entity = CWIMatch.new(m.id,players, m.cwigroup_id)

  replay_records = DataModel::Replay.all(:cwimatch_id => m.id)
  replay_records.each do |r|
    match_entity.replays << {:url => r.url, :time => r.time}
  end

  scores = [m.score1a, m.score1b]
  match_entity.set_scores(scores)

  match_entity.set_played_stats(m.time, m.duration)
  return match_entity
end

def map_records_to_entities(match_records)
  match_entities = []
  match_records.each do |m|
    match_entities << map_record_to_entity(m)
  end
  return match_entities
end

def map_entity_to_record(match_entity, match_record)
  match_record.id = match_entity.id if match_entity.id
  match_record.cwigroup_id = match_entity.group_id
  players = match_entity.players
  match_record.pl1 = players[0]
  match_record.pl2 = players[1]
  match_record.pl3 = players[2]
  match_record.pl4 = players[3]

  scores = match_entity.scores
  match_record.score1a = scores[0]
  match_record.score1b = scores[1]
  time = match_entity.time
  time = Time.now() if time == nil
  match_record.time = time
  match_record.duration = match_entity.duration
end

end
