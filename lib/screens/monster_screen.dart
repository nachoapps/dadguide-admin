import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/proto/enemy_skills/enemy_skills.pb.dart';
import 'package:dadguide2/proto/utils/enemy_skills_utils.dart';
import 'package:dadguide2/screens/dungeon_info/dungeon_behavior.dart';
import 'package:dadguide_admin/components/api.dart';
import 'package:dadguide_admin/components/data/server_state.dart';
import 'package:dadguide_admin/components/images.dart';
import 'package:dadguide_admin/components/routes.dart';
import 'package:dadguide_admin/components/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'editable_dungeon_behavior.dart';

Future<void> goToMonster(BuildContext context, int enemyId, {bool replace: false}) {
  return Routes.router
      .navigateTo(context, '${Routes.monster}?id=$enemyId', replace: replace, transition: null);
}

class MonsterPage extends StatelessWidget {
  final int enemyId;

  const MonsterPage(this.enemyId, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Tools - Monster')),
      body: SingleChildScrollView(child: MonsterScreen(enemyId)),
    );
  }
}

class MonsterInfoWrapper with ChangeNotifier {
  final int enemyId;
  final int monsterId;
  String name = '';
  List<EncounterRow> encounters = [];
  EncounterRow selected;
  Map<int, EnemySkill> esLibrary = {};
  List<int> altIds = [];

  String rawText = '';
  String parsedText = '';
  String protoText = '';
  var protoObj = MonsterBehaviorWithOverrides();

  MonsterInfoWrapper(this.enemyId) : monsterId = enemyId % 100000;

  void update() {
    notifyListeners();
  }
}

class MonsterScreen extends StatefulWidget {
  final int enemyId;
  final int monsterId;

  MonsterScreen(this.enemyId) : monsterId = enemyId % 100000;

  @override
  _MonsterScreenState createState() => _MonsterScreenState();
}

class _MonsterScreenState extends State<MonsterScreen> {
  MonsterInfoWrapper data;

  @override
  void initState() {
    super.initState();
    data = MonsterInfoWrapper(widget.enemyId);
    _fetchState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: data,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MonsterHeader(),
      ),
    );
  }

  Future<void> _fetchState() async {
    var api = getIt<Api>();
    var newData = await api.monsterInfo(data.enemyId);
    var raw = await api.rawEnemyData(data.enemyId);
    var parsed = await api.parsedEnemyData(data.enemyId);
    var proto = await api.enemyProto(data.enemyId);
    var protoObj = await api.enemyProtoParsed(data.enemyId);

    var allBehaviors = <BehaviorGroup>[];
    for (var level in protoObj.levels) {
      allBehaviors.addAll(level.groups);
    }
    var skillIds = extractSkillIds(allBehaviors);
    for (var skillId in skillIds) {
      data.esLibrary[skillId] = await api.loadSkill(skillId);
    }

    if (protoObj.levels.isNotEmpty && protoObj.levelOverrides.isEmpty) {
      for (var level in protoObj.levels) {
        protoObj.levelOverrides.add(level.clone());
      }
    }

    setState(() {
      data.name = newData.monster.name;
      data.encounters = newData.encounters..sort((l, r) => l.encounter.level - r.encounter.level);
      data.altIds = newData.altEnemyIds;
      print(data.altIds);
      data.rawText = raw;
      data.parsedText = parsed;
      data.protoText = proto;
      data.protoObj = protoObj;

      for (var levelData in data.protoObj.levels) {
        data.encounters.add(EncounterRow(
          EncounterInfo(1, 1, levelData.level, 1, 1, 0),
          DungeonInfo('Fake Dungeon', data.monsterId),
          SubDungeonInfo('Fake Level'),
        ));
      }

      data.update();
    });
  }
}

class MonsterHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data = Provider.of<MonsterInfoWrapper>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: <Widget>[
            SizedBox(
              width: 1200,
              child: ListTile(
                leading: PadIcon(data.monsterId),
                title: Row(
                  children: <Widget>[
                    Text('#${data.enemyId} - ${data.name}'),
                    SizedBox(width: 16),
                    RaisedButton(
                      onPressed: () async {
                        var nextId = await getIt<Api>().nextMonster(data.enemyId);
                        await goToMonster(context, nextId, replace: true);
                      },
                      child: Text('Next pending'),
                    ),
                    SizedBox(width: 16),
                    RaisedButton(
                      onPressed: () async {
                        var nextId = await getIt<Api>().nextReapprovalMonster(data.enemyId);
                        await goToMonster(context, nextId, replace: true);
                      },
                      child: Text('Next reapproval'),
                    ),
                    SizedBox(width: 32),
                    for (var altId in data.altIds)
                      RaisedButton(
                        onPressed: () async {
                          await goToMonster(context, altId, replace: true);
                        },
                        child: Text('Go to alt: $altId'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text('Status: ${data.protoObj.status.name} - Levels: ${data.protoObj.levels.length}'),
        if (data.protoObj.levels.length > 1)
          Text('WARNING: This monster has multiple levels, scroll down before approving'),
        SizedBox(height: 16),
        for (int i = 0; i < data.protoObj.levels.length; i++)
          LevelRow(data.protoObj.levels[i], data.protoObj.levelOverrides[i])
      ],
    );
  }
}

class LevelRow extends StatelessWidget {
  final LevelBehavior levelBehaviors;
  final LevelBehavior levelBehaviorsOverrides;

  LevelRow(this.levelBehaviors, this.levelBehaviorsOverrides);

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<MonsterInfoWrapper>(context);

    var limitedEncounters =
        data.encounters.where((e) => e.encounter.level >= levelBehaviors.level).toList();

    if (limitedEncounters.isNotEmpty && data.selected == null) {
      data.selected = limitedEncounters.first;
    }

    var okToReapprove =
        data.protoObj.status == MonsterBehaviorWithOverrides_Status.NEEDS_REAPPROVAL &&
            levelBehaviors == levelBehaviorsOverrides;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('ES Level: ${levelBehaviors.level}'),
        DropdownButton(
          hint: Text('select an encounter to see skill display'),
          value: data.selected,
          onChanged: (v) {
            data.selected = v;
            data.update();
//              encounterWrapper.update();
          },
          items: [
            for (var e in limitedEncounters)
              DropdownMenuItem(
                child:
                    Text('level ${e.encounter.level} - ${e.dungeon.name} - ${e.subDungeon.name}'),
                value: e,
              ),
          ],
        ),
        if (data.selected != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 400, height: 600, child: InfoTabbed()),
              Column(
                children: <Widget>[
                  if (okToReapprove)
                    Text('EQUAL',
                        style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.green)),
                  RaisedButton(
                    onPressed: () async {
                      await getIt<Api>().saveApprovedAsIs(data.enemyId);
                      data.protoObj.status = MonsterBehaviorWithOverrides_Status.APPROVED_AS_IS;
                      data.update();
                    },
                    child: Text('Approve As Is'),
                  ),
                  SizedBox(width: 400, child: EnemyDisplay(levelBehaviors, data.selected)),
                ],
              ),
              SizedBox(
                  width: 500, child: EditableEnemyDisplay(levelBehaviorsOverrides, data.selected)),
              Column(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () async {
                      await getIt<Api>().saveApprovedWithChanges(data.enemyId, data.protoObj);
                      data.protoObj.status =
                          MonsterBehaviorWithOverrides_Status.APPROVED_WITH_CHANGES;
                      data.update();
                    },
                    child: Text('Approve With Changes'),
                  ),
                  SizedBox(width: 400, child: EnemyDisplay(levelBehaviorsOverrides, data.selected)),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

class EditableEnemyDisplay extends StatelessWidget {
  final LevelBehavior levelBehaviors;
  final EncounterRow selected;
  EditableEnemyDisplay(this.levelBehaviors, this.selected);

  @override
  Widget build(BuildContext context) {
    var info = Provider.of<MonsterInfoWrapper>(context);

    var inputs = BehaviorWidgetInputs(selected.encounter.atk, info.esLibrary);
    return Provider.value(
      value: inputs,
      child: EditableEncounterBehaviorWidget(levelBehaviors.groups),
    );
  }
}

class EnemyDisplay extends StatelessWidget {
  final LevelBehavior levelBehaviors;
  final EncounterRow selected;
  EnemyDisplay(this.levelBehaviors, this.selected);

  @override
  Widget build(BuildContext context) {
    var info = Provider.of<MonsterInfoWrapper>(context);

    var inputs = BehaviorWidgetInputs(selected.encounter.atk, info.esLibrary);
    return Provider.value(
      value: inputs,
      child: EncounterBehavior(true, levelBehaviors.groups),
    );
  }
}

class PlainData extends StatelessWidget {
  final int monsterId;
  final String data;

  const PlainData(this.monsterId, this.data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Text(data),
    );
  }
}

class InfoTabbed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data = Provider.of<MonsterInfoWrapper>(context);

    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: TabBar(
              tabs: [
                Tab(text: 'plain'),
                Tab(text: 'parsed'),
                Tab(text: 'proto'),
                Tab(text: 'combined'),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                PlainData(
                  data.enemyId,
                  data.rawText,
                ),
                PlainData(
                  data.enemyId,
                  data.parsedText,
                ),
                PlainData(
                  data.enemyId,
                  data.protoText,
                ),
                PlainData(
                  data.enemyId,
                  data.protoObj.toDebugString(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
