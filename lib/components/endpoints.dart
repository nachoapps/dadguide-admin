/// Returns URLs configured properly for the given arguments.
///
/// This makes switching between local dev and prod easier.
abstract class Endpoints {
  String baseServer();

  String serverState() => '${baseServer()}/dadguide/admin/state';
  String randomMonsters() => '${baseServer()}/dadguide/admin/randomMonsters';
  String randomReapprovalMonsters() => '${baseServer()}/dadguide/admin/randomReapprovalMonsters';
  String easyMonsters() => '${baseServer()}/dadguide/admin/easyMonsters';
  String monsterInfo(int monsterId) => '${baseServer()}/dadguide/admin/monsterInfo?id=$monsterId';

  String rawEnemyData(int monsterId) => '${baseServer()}/dadguide/admin/rawEnemyData?id=$monsterId';
  String parsedEnemyData(int monsterId) =>
      '${baseServer()}/dadguide/admin/parsedEnemyData?id=$monsterId';
  String enemyProto(int monsterId) => '${baseServer()}/dadguide/admin/enemyProto?id=$monsterId';
  String enemyProtoEncoded(int monsterId) =>
      '${baseServer()}/dadguide/admin/enemyProtoEncoded?id=$monsterId';
  String saveApprovedAsIs(int monsterId) =>
      '${baseServer()}/dadguide/admin/saveApprovedAsIs?id=$monsterId';
  String saveApprovedWithChanges(int monsterId) =>
      '${baseServer()}/dadguide/admin/saveApprovedWithChanges?id=$monsterId';
  String loadSkill(int skillId) => '${baseServer()}/dadguide/admin/loadSkill?id=$skillId';
  String nextMonster(int monsterId) => '${baseServer()}/dadguide/admin/nextMonster?id=$monsterId';
}

/// Point to localhost; the sanic server in dadguide-data runs on 8000 by default.
class DevEndpoints extends Endpoints {
  String baseServer() => 'http://0.0.0.0:8000';
}

/// Points to the production server.
class ProdEndpoints extends Endpoints {
  String baseServer() => 'http://admin.miru.info';
}
