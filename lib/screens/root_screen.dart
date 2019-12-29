import 'package:dadguide_admin/components/api.dart';
import 'package:dadguide_admin/components/data/server_state.dart';
import 'package:dadguide_admin/components/images.dart';
import 'package:dadguide_admin/components/service_locator.dart';
import 'package:dadguide_admin/screens/monster_screen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  static const path = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Tools - Home')),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RootScreen(),
      )),
    );
  }
}

class RootScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 900, child: ServerSettingsCard()),
          Row(
            children: <Widget>[
              SizedBox(
                  width: 600,
                  child: MonstersCard(
                      'Random monsters needing approval', getIt<Api>().randomMonsters)),
              SizedBox(
                  width: 600,
                  child: MonstersCard('Easy monsters needing approval', getIt<Api>().easyMonsters)),
            ],
          ),
        ],
      ),
    );
  }
}

class ServerSettingsCard extends StatefulWidget {
  @override
  _ServerSettingsCardState createState() => _ServerSettingsCardState();
}

class _ServerSettingsCardState extends State<ServerSettingsCard> {
  var data = ServerState(
    encounteredStatusCounts: BehaviorCounts(),
    allStatusCounts: BehaviorCounts(),
  );

  @override
  void initState() {
    super.initState();
    _fetchState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Server Info'),
        subtitle: Row(
          children: [
            Table(
              defaultColumnWidth: FixedColumnWidth(100),
              children: [
                TableRow(
                  children: [
                    _cell(''),
                    _cell(''),
                  ],
                ),
                TableRow(
                  children: [
                    _cell('Dungeons'),
                    _cell('${data.dungeons}'),
                  ],
                ),
                TableRow(
                  children: [
                    _cell('Monsters'),
                    _cell('${data.monsters}'),
                  ],
                ),
                TableRow(
                  children: [
                    _cell('Seen Monsters'),
                    _cell('${data.encounteredMonsters}'),
                  ],
                ),
                TableRow(
                  children: [
                    _cell(''),
                    _cell(''),
                  ],
                ),
              ],
            ),
            SizedBox(width: 32),
            Table(
              defaultColumnWidth: FixedColumnWidth(200),
              children: [
                TableRow(
                  children: [
                    _cell(''),
                    _cell('All Monsters'),
                    _cell('Seen Monsters'),
                  ],
                ),
                TableRow(
                  children: [
                    _cell('Not Approved'),
                    _cell('${data.allStatusCounts.notApproved}'),
                    _cell('${data.encounteredStatusCounts.notApproved}'),
                  ],
                ),
                TableRow(
                  children: [
                    _cell('Approved As Is'),
                    _cell('${data.allStatusCounts.approvedAsIs}'),
                    _cell('${data.encounteredStatusCounts.approvedAsIs}'),
                  ],
                ),
                TableRow(
                  children: [
                    _cell('Needs Reapproval'),
                    _cell('${data.allStatusCounts.needsReapproval}'),
                    _cell('${data.encounteredStatusCounts.needsReapproval}'),
                  ],
                ),
                TableRow(
                  children: [
                    _cell('Approved With Changes'),
                    _cell('${data.allStatusCounts.approvedWithChanges}'),
                    _cell('${data.encounteredStatusCounts.approvedWithChanges}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String text) => Padding(padding: const EdgeInsets.all(4.0), child: Text(text));

  Future<void> _fetchState() async {
    var newData = await getIt<Api>().serverState();
    setState(() {
      data = newData;
    });
  }
}

class MonstersCard extends StatefulWidget {
  final String title;
  final Future<RandomMonsters> Function() getter;

  const MonstersCard(this.title, this.getter);

  @override
  _MonstersCardState createState() => _MonstersCardState();
}

class _MonstersCardState extends State<MonstersCard> {
  var data = <BasicMonsterInfo>[];

  @override
  void initState() {
    super.initState();
    _fetchState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
            title: Text(widget.title),
            subtitle: Table(
              border: TableBorder.all(),
              children: [
                for (var m in data)
                  TableRow(
                    children: [
                      GestureDetector(
                        onTap: () => goToMonster(context, m.enemyId),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              PadIcon(m.monsterId),
                              SizedBox(width: 8),
                              Text(name(m)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            )));
  }

  String name(BasicMonsterInfo m) {
    var name = '#${m.enemyId}';
    if (m.enemyId > 100000) name += ' (Alt ${m.enemyId ~/ 100000})';
    name += ' ${m.name}';
    return name;
  }

  Future<void> _fetchState() async {
    var newData = await widget.getter();
    setState(() {
      data = newData.monsters.take(10).toList();
    });
  }
}
