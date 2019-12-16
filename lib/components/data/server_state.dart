import 'package:json_annotation/json_annotation.dart';

part 'server_state.g.dart';

@JsonSerializable(nullable: false, fieldRename: FieldRename.snake)
class ServerState {
  final int dungeons;
  final int monsters;
  final int encounteredMonsters;
  final BehaviorCounts allStatusCounts;
  final BehaviorCounts encounteredStatusCounts;
  ServerState({
    this.dungeons,
    this.monsters,
    this.encounteredMonsters,
    this.allStatusCounts,
    this.encounteredStatusCounts,
  });
  factory ServerState.fromJson(Map<String, dynamic> json) => _$ServerStateFromJson(json);
  Map<String, dynamic> toJson() => _$ServerStateToJson(this);
}

@JsonSerializable(nullable: false, fieldRename: FieldRename.snake)
class BehaviorCounts {
  final int notApproved;
  final int approvedAsIs;
  final int needsReapproval;
  final int approvedWithChanges;
  BehaviorCounts(
      {this.notApproved, this.approvedAsIs, this.needsReapproval, this.approvedWithChanges});
  factory BehaviorCounts.fromJson(Map<String, dynamic> json) => _$BehaviorCountsFromJson(json);
  Map<String, dynamic> toJson() => _$BehaviorCountsToJson(this);
}

@JsonSerializable(nullable: false, fieldRename: FieldRename.snake)
class RandomMonsters {
  final List<BasicMonsterInfo> monsters;
  RandomMonsters({this.monsters});
  factory RandomMonsters.fromJson(Map<String, dynamic> json) => _$RandomMonstersFromJson(json);
  Map<String, dynamic> toJson() => _$RandomMonstersToJson(this);
}

@JsonSerializable(nullable: false, fieldRename: FieldRename.snake)
class BasicMonsterInfo {
  final int monsterId;
  final String name;
  BasicMonsterInfo({this.monsterId, this.name});
  factory BasicMonsterInfo.fromJson(Map<String, dynamic> json) => _$BasicMonsterInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BasicMonsterInfoToJson(this);
}

@JsonSerializable(nullable: false, fieldRename: FieldRename.snake)
class MonsterInfo {
  final BasicMonsterInfo monster;
  final List<EncounterRow> encounters;
  MonsterInfo({this.monster, this.encounters});
  factory MonsterInfo.fromJson(Map<String, dynamic> json) => _$MonsterInfoFromJson(json);
  Map<String, dynamic> toJson() => _$MonsterInfoToJson(this);
}

@JsonSerializable(nullable: false, fieldRename: FieldRename.snake)
class EncounterRow {
  final EncounterInfo encounter;
  final DungeonInfo dungeon;
  final SubDungeonInfo subDungeon;

  EncounterRow(this.encounter, this.dungeon, this.subDungeon);
  factory EncounterRow.fromJson(Map<String, dynamic> json) => _$EncounterRowFromJson(json);
  Map<String, dynamic> toJson() => _$EncounterRowToJson(this);
}

@JsonSerializable(nullable: false, fieldRename: FieldRename.snake)
class EncounterInfo {
  final int amount;
  final int turns;
  final int level;
  final int hp;
  final int atk;
  final int defence;

  EncounterInfo(this.amount, this.turns, this.level, this.hp, this.atk, this.defence);
  factory EncounterInfo.fromJson(Map<String, dynamic> json) => _$EncounterInfoFromJson(json);
  Map<String, dynamic> toJson() => _$EncounterInfoToJson(this);
}

@JsonSerializable(nullable: false, fieldRename: FieldRename.snake)
class DungeonInfo {
  final String name;
  final int iconId;

  DungeonInfo(this.name, this.iconId);
  factory DungeonInfo.fromJson(Map<String, dynamic> json) => _$DungeonInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DungeonInfoToJson(this);
}

@JsonSerializable(nullable: false, fieldRename: FieldRename.snake)
class SubDungeonInfo {
  final String name;

  SubDungeonInfo(this.name);
  factory SubDungeonInfo.fromJson(Map<String, dynamic> json) => _$SubDungeonInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SubDungeonInfoToJson(this);
}
