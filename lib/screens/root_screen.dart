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
      body: RootScreen(),
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
          IntrinsicWidth(child: ServerSettingsCard()),
          SizedBox(width: 600, child: RandomMonstersCard()),
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
              defaultColumnWidth: IntrinsicColumnWidth(),
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
              defaultColumnWidth: IntrinsicColumnWidth(),
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

class RandomMonstersCard extends StatefulWidget {
  @override
  _RandomMonstersCardState createState() => _RandomMonstersCardState();
}

class _RandomMonstersCardState extends State<RandomMonstersCard> {
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
            title: Text('Random monsters that need review'),
            subtitle: Table(
              border: TableBorder.all(),
              children: [
                for (var m in data)
                  TableRow(
                    children: [
                      GestureDetector(
                        onTap: () => goToMonster(context, m.monsterId),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              PadIcon(m.monsterId),
                              SizedBox(width: 8),
                              Text('#${m.monsterId} ${m.name}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            )));
  }

  Future<void> _fetchState() async {
    var newData = await getIt<Api>().randomMonsters();
    setState(() {
      data = newData.monsters.take(10).toList();
    });
  }
}
