import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/proto/enemy_skills/enemy_skills.pb.dart';
import 'package:dadguide_admin/components/data/server_state.dart';
import 'package:dadguide_admin/components/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class Api {
  final Dio dio;
  final Endpoints endpoints;

  Api(this.dio, this.endpoints);

  Future<ServerState> serverState() async {
    var resp = await http.get(endpoints.serverState());
    return ServerState.fromJson(toJson(resp));
  }

  Future<RandomMonsters> randomMonsters() async {
    var resp = await http.get(endpoints.randomMonsters());
    return RandomMonsters.fromJson(toJson(resp));
  }

  Future<RandomMonsters> randomReapprovalMonsters() async {
    var resp = await http.get(endpoints.randomReapprovalMonsters());
    return RandomMonsters.fromJson(toJson(resp));
  }

  Future<RandomMonsters> easyMonsters() async {
    var resp = await http.get(endpoints.easyMonsters());
    return RandomMonsters.fromJson(toJson(resp));
  }

  Future<MonsterInfo> monsterInfo(int enemyId) async {
    var resp = await http.get(endpoints.monsterInfo(enemyId));
    return MonsterInfo.fromJson(toJson(resp));
  }

  Future<String> rawEnemyData(int enemyId) async {
    var resp = await http.get(endpoints.rawEnemyData(enemyId));
    return plainString(resp);
  }

  Future<String> parsedEnemyData(int enemyId) async {
    var resp = await http.get(endpoints.parsedEnemyData(enemyId));
    return plainString(resp);
  }

  Future<String> enemyProto(int enemyId) async {
    var resp = await http.get(endpoints.enemyProto(enemyId));
    return plainString(resp);
  }

  Future<MonsterBehaviorWithOverrides> enemyProtoParsed(int enemyId) async {
    var resp = await http.get(endpoints.enemyProtoEncoded(enemyId));
    var encodedBehavior = plainString(resp);
    var decodedBehavior = Uint8List.fromList(hex.decode(encodedBehavior));
    var behavior = MonsterBehaviorWithOverrides();
    behavior.mergeFromBuffer(decodedBehavior);
    return behavior;
  }

  Future<void> saveApprovedAsIs(int enemyId) async {
    await http.get(endpoints.saveApprovedAsIs(enemyId));
  }

  Future<void> saveApprovedWithChanges(int enemyId, MonsterBehaviorWithOverrides mbwo) async {
    var data = hex.encode(mbwo.writeToBuffer());
    await http.post(endpoints.saveApprovedWithChanges(enemyId), body: data);
  }

  Future<int> nextMonster(int enemyId) async {
    var resp = await http.get(endpoints.nextMonster(enemyId));
    return int.parse(plainString(resp));
  }

  Future<int> nextReapprovalMonster(int enemyId) async {
    var resp = await http.get(endpoints.nextReapprovalMonster(enemyId));
    return int.parse(plainString(resp));
  }

  Future<EnemySkill> loadSkill(int skillId) async {
    var resp = await http.get(endpoints.loadSkill(skillId));
    var json = toJson(resp);
    return EnemySkill.fromJson(json);
  }

  dynamic toJson(http.Response response) {
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return json.decode(response.body);
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  String plainString(http.Response response) {
    if (response.statusCode == 200) {
      // If server returns an OK response, return the contents
      return response.body;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }
}
