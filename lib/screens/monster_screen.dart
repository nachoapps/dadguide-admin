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

Future<void> goToMonster(BuildContext context, int monsterId, {bool replace: false}) {
  return Routes.router.navigateTo(context, '${Routes.monster}?id=$monsterId', replace: replace);
}

class MonsterPage extends StatelessWidget {
  final int monsterId;

  const MonsterPage(this.monsterId, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Tools - Monster')),
      body: SingleChildScrollView(child: MonsterScreen(monsterId)),
    );
  }
}

class MonsterInfoWrapper with ChangeNotifier {
  final int monsterId;
  String name = '';
  List<EncounterRow> encounters = [];
  EncounterRow selected;
  Map<int, EnemySkill> esLibrary = {};

  String rawText = '';
  String parsedText = '';
  String protoText = '';
  var protoObj = MonsterBehaviorWithOverrides();

  MonsterInfoWrapper(this.monsterId);

  void update() {
    notifyListeners();
  }
}

class EncounterWrapper with ChangeNotifier {
  EncounterRow selected;

  void update() {
    notifyListeners();
  }
}

class MonsterScreen extends StatefulWidget {
  final int monsterId;

  MonsterScreen(this.monsterId);

  @override
  _MonsterScreenState createState() => _MonsterScreenState();
}

class _MonsterScreenState extends State<MonsterScreen> {
  MonsterInfoWrapper data;

  @override
  void initState() {
    super.initState();
    data = MonsterInfoWrapper(widget.monsterId);
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
    var newData = await api.monsterInfo(data.monsterId);
    var raw = await api.rawEnemyData(data.monsterId);
    var parsed = await api.parsedEnemyData(data.monsterId);
    var proto = await api.enemyProto(data.monsterId);
    var protoObj = await api.enemyProtoParsed(data.monsterId);

    var allBehaviors = <BehaviorGroup>[];
    for (var level in protoObj.levels) {
      allBehaviors.addAll(level.groups);
    }
    var skillIds = extractSkillIds(allBehaviors);
    for (var skillId in skillIds) {
      data.esLibrary[skillId] = await api.loadSkill(skillId);
    }

    setState(() {
      data.name = newData.monster.name;
      data.encounters = newData.encounters..sort((l, r) => l.encounter.level - r.encounter.level);
      data.rawText = raw;
      data.parsedText = parsed;
      data.protoText = proto;
      data.protoObj = protoObj;
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
            IntrinsicWidth(
              child: ListTile(
                leading: PadIcon(data.monsterId),
                title: Row(
                  children: <Widget>[
                    Text('#${data.monsterId} - ${data.name}'),
                    SizedBox(width: 16),
                    RaisedButton(
                      onPressed: () async {
                        var nextId = await getIt<Api>().nextMonster(data.monsterId);
                        goToMonster(context, nextId, replace: true);
                      },
                      child: Text('Next pending'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Text('Status: ${data.protoObj.status.name}'),
            SizedBox(width: 16),
            RaisedButton(
              onPressed: () async {
                await getIt<Api>().saveApprovedAsIs(data.monsterId);
                data.protoObj.status = MonsterBehaviorWithOverrides_Status.APPROVED_AS_IS;
                data.update();
              },
              child: Text('Approve As Is'),
            ),
          ],
        ),
        SizedBox(height: 16),
        for (var levelBehaviors in data.protoObj.levels) LevelRow(levelBehaviors)
      ],
    );
  }
}

class LevelRow extends StatelessWidget {
  final LevelBehavior levelBehaviors;
  final encounterWrapper = EncounterWrapper();

  LevelRow(this.levelBehaviors);

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<MonsterInfoWrapper>(context);

    var limitedEncounters =
        data.encounters.where((e) => e.encounter.level >= levelBehaviors.level).toList();

    return ChangeNotifierProvider.value(
      value: encounterWrapper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('ES Level: ${levelBehaviors.level}'),
          DropdownButton(
            hint: Text('select an encounter to see skill display'),
            value: encounterWrapper.selected,
            onChanged: (v) {
              encounterWrapper.selected = v;
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
          Row(
            children: <Widget>[
              SizedBox(width: 400, height: 600, child: InfoTabbed()),
              if (encounterWrapper.selected != null)
                SizedBox(
                    width: 400,
                    height: 600,
                    child: EnemyDisplay(levelBehaviors, encounterWrapper.selected)),
            ],
          ),
        ],
      ),
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
      child: SingleChildScrollView(
        child: EncounterBehavior(true, levelBehaviors.groups),
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(data),
          ),
        ],
      ),
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
                  data.monsterId,
                  data.rawText,
                ),
                PlainData(
                  data.monsterId,
                  data.parsedText,
                ),
                PlainData(
                  data.monsterId,
                  data.protoText,
                ),
                PlainData(
                  data.monsterId,
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
