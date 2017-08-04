$LOAD_PATH << '.'

require 'dm/data_model'
require 'cwigroup'
require 'cwimatch_repository'
require 'player_repository'

class CWIGroupRepository

public

def get(group_id)
  gr = DataModel::Cwigroup.get(group_id)
  return map_record_to_entity(gr)
end

def get_season_groups(season_id)
  group_entities = []
  group_records = DataModel::Cwigroup.all(:season_id => season_id)
  group_records.each do |gr|
    group_entities << map_record_to_entity(gr)
  end
  return group_entities
end

def map_record_to_entity(gr)
  player_repo = PlayerRepository.new()
  players = player_repo.get_group_players(gr.id) # TODO: implement in player repo

  cwimatch_repo = CWIMatchRepository.new()
  cwimatches = cwimatch_repo.get_group_matches(gr.id)

  group_entity = CWIGroup.new(gr.id, gr.name, gr.scoring, players, cwimatches)
  return group_entity
end

### TODO below here

def add(group_entity)
  group_record = DataModel::Cwigroup.new()
  group_record.name = group_entity.name
  group_record.level = group_entity.level
  group_record.scoring = group_entity.scoring
  group_record.save()
  group_entity.id = group_record.id
  return group_record.id
end

def update(group_entity)
  group_id = group_entity.id
  group_record = DataModel::Cwigroup.get(group_id)
  groupplayer_records = DataModel::groupplayer.all(DataModel::groupplayer.group_id => group_id)

  map_entity_to_record(group_entity, group_record, groupplayer_records)

  group_record.save()
  groupplayer_records.each do |dp_record|
    dp_record.save()
  end
end

private

def get_group_players_data(group_id)
  total_matches = {}
  planned_matches = {}
  group_players = DataModel::groupplayer.all(DataModel::groupplayer.group_id => group_id)
  group_players.each do |dp|
    total_matches[dp.player_id] = dp.total_matches
    planned_matches[dp.player_id] = dp.planned_matches
  end
  return [total_matches, planned_matches]
end

def map_entity_to_record(group_entity, group_record, groupplayer_records)
  group_record.current_round = group_entity.current_round
  planned_matches = group_entity.planned_matches
  groupplayer_records.each do |dp_record|
    player_id = dp_record.player_id
    dp_record.planned_matches = planned_matches[player_id]
  end
end

end
