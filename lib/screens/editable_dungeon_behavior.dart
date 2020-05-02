import 'package:dadguide2/proto/enemy_skills/enemy_skills.pb.dart';
import 'package:dadguide2/screens/dungeon_info/dungeon_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'monster_screen.dart';

class ListUpdateRow extends StatelessWidget {
  final int i;
  final List groups;

  const ListUpdateRow(this.i, this.groups);

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<MonsterInfoWrapper>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          onPressed: () {
            groups.insert(i, groups[i].clone());
            data.update();
          },
          child: Text('clone'),
        ),
        InkWell(
          onTap: () {
            if (i > 0) {
              groups.insert(i - 1, groups.removeAt(i));
              data.update();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(Icons.arrow_upward),
          ),
        ),
        InkWell(
          onTap: () {
            if (i < groups.length - 1) {
              groups.insert(i + 1, groups.removeAt(i));
              data.update();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(Icons.arrow_downward),
          ),
        ),
        InkWell(
          onTap: () {
            groups.removeAt(i);
            data.update();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(Icons.remove_circle),
          ),
        ),
      ],
    );
  }
}

class ListUpdateBottomRow extends StatelessWidget {
  final BehaviorGroup group;

  const ListUpdateBottomRow(this.group);

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<MonsterInfoWrapper>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          onPressed: () {
            group.children.add(newGroupBehaviorItem(data));
            data.update();
          },
          child: Text('add group'),
        ),
        FlatButton(
          onPressed: () {
            group.children.add(newBehaviorBehaviorItem(data));
            data.update();
          },
          child: Text('add behavior'),
        ),
      ],
    );
  }

  BehaviorItem newBehaviorBehaviorItem(MonsterInfoWrapper data) {
    var newBehavior = Behavior();
    newBehavior.enemySkillId = data.esLibrary.values.first.enemySkillId;
    var newItem = BehaviorItem();
    newItem.behavior = newBehavior;
    return newItem;
  }

  BehaviorItem newGroupBehaviorItem(MonsterInfoWrapper data) {
    var newGroup = BehaviorGroup();
    newGroup.groupType = BehaviorGroup_GroupType.STANDARD;
    var newItem = BehaviorItem();
    newItem.group = newGroup;
    newItem.group.children.add(newBehaviorBehaviorItem(data));
    return newItem;
  }
}

class EditableEncounterBehaviorWidget extends StatelessWidget {
  final List<BehaviorGroup> groups;

  EditableEncounterBehaviorWidget(this.groups);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: groups.length,
      separatorBuilder: (context, index) => SizedBox(height: 4),
      itemBuilder: (context, index) => TopLevelBehaviorGroup(index, groups),
    );
  }
}

class TopLevelBehaviorGroup extends StatelessWidget {
  final int i;
  final List<BehaviorGroup> groups;

  const TopLevelBehaviorGroup(this.i, this.groups);

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<MonsterInfoWrapper>(context);

    return Column(children: [
      Container(
        color: Colors.blueAccent,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(width: 4),
                DropdownButton(
                    value: groups[i].groupType,
                    items: [
                      for (var t in BehaviorGroup_GroupType.values)
                        DropdownMenuItem(
                          value: t,
                          child: Text(t.name),
                        ),
                    ],
                    onChanged: (v) {
                      groups[i].groupType = v;
                      data.update();
                    }),
                Spacer(),
                ListUpdateRow(i, groups),
              ],
            ),
            SizedBox(
              height: 28,
              child: Row(
                children: <Widget>[
                  Spacer(),
                  ListUpdateBottomRow(groups[i]),
                ],
              ),
            ),
          ],
        ),
      ),
      EditableBehaviorGroupWidget(1, groups[i]),
    ]);
  }
}

/// A group of behavior, containing a list of child groups or individual behaviors.
class EditableBehaviorGroupWidget extends StatelessWidget {
  final int nestingLevel;
  final BehaviorGroup group;

  EditableBehaviorGroupWidget(this.nestingLevel, this.group);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxMe(
            padding: const EdgeInsets.all(2.0),
            color: Colors.grey[300],
            child: EditableConditionWidget(group.ensureCondition())),
        SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: group.children.length,
            separatorBuilder: (context, index) => SizedBox(height: 4),
            itemBuilder: (context, i) =>
                EditableBehaviorGroupAndConditionWidget(nestingLevel, i, group),
          ),
        ),
      ],
    );
  }
}

class EditableBehaviorGroupAndConditionWidget extends StatelessWidget {
  final int nestingLevel;
  final int i;
  final BehaviorGroup group;

  const EditableBehaviorGroupAndConditionWidget(this.nestingLevel, this.i, this.group);

  @override
  Widget build(BuildContext context) {
    var inputs = Provider.of<BehaviorWidgetInputs>(context);

    var child = group.children[i];
    var type = child.hasBehavior() ? 'Behavior' : 'Group';
    var color = child.hasBehavior() ? Colors.purpleAccent : Colors.lightBlueAccent;
    var conditionText = formatCondition(context,
        child.hasBehavior() ? child.behavior.condition : child.group.condition, inputs.esLibrary);
    conditionText = conditionText.isEmpty ? '(no condition)' : conditionText;
    return Column(
      children: <Widget>[
        Container(
          color: color,
          padding: EdgeInsets.all(4.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('$type: $conditionText'),
                  ListUpdateRow(i, group.children),
                ],
              ),
              if (child.hasGroup())
                SizedBox(
                  height: 28,
                  child: Row(
                    children: <Widget>[
                      Spacer(),
                      ListUpdateBottomRow(child.group),
                    ],
                  ),
                ),
            ],
          ),
        ),
        EditableBehaviorItemWidget(nestingLevel + 1, child),
      ],
    );
  }
}

/// An individual child, containing either a nested group or a single behavior.
class EditableBehaviorItemWidget extends StatelessWidget {
  final int nestingLevel;
  final BehaviorItem child;

  EditableBehaviorItemWidget(this.nestingLevel, this.child);

  @override
  Widget build(BuildContext context) {
    if (child.hasGroup()) {
      return EditableBehaviorGroupWidget(nestingLevel, child.group);
    } else {
      return EditableBehaviorWidget(child.behavior);
    }
  }
}

/// An individual behavior.
class EditableBehaviorWidget extends StatelessWidget {
  final Behavior behavior;

  EditableBehaviorWidget(this.behavior);

  @override
  Widget build(BuildContext context) {
    var inputs = Provider.of<BehaviorWidgetInputs>(context);
    var data = Provider.of<MonsterInfoWrapper>(context);

    return BoxMe(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              color: Colors.amber[50],
              child: Row(
                children: <Widget>[
                  DropdownButton(
                    value: behavior.enemySkillId,
                    items: [
                      for (var es in inputs.esLibrary.values)
                        DropdownMenuItem(
                          value: es.enemySkillId,
                          child: Text('${es.enemySkillId} - ${es.nameNa}'),
                        ),
                    ],
                    onChanged: (v) {
                      behavior.enemySkillId = v;
                      data.update();
                    },
                  ),
                ],
              )),
          EditableConditionWidget(behavior.ensureCondition()),
        ],
      ),
    );
  }
}

class EditableConditionWidget extends StatelessWidget {
  final Condition c;

  EditableConditionWidget(this.c);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Condition', style: Theme.of(context).textTheme.subtitle2),
          Divider(),
          DefaultTextStyle(
            style: Theme.of(context).textTheme.caption,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                TableRow(
                  children: [
                    Text('HP'),
                    IntInputWidget(
                      'HP',
                      () => c.hpThreshold,
                      (i) => c.hpThreshold = i,
                      c.clearHpThreshold,
                    ),
                    Text('Chance'),
                    IntInputWidget(
                      'Chance',
                      () => c.useChance,
                      (i) => c.useChance = i,
                      c.clearUseChance,
                    ),
                    Text('Repeats'),
                    IntInputWidget(
                      'Repeats',
                      () => c.repeatsEvery,
                      (i) => c.repeatsEvery = i,
                      c.clearRepeatsEvery,
                    ),
                    Text('Limited'),
                    IntInputWidget(
                      'Limited',
                      () => c.limitedExecution,
                      (i) => c.limitedExecution = i,
                      c.clearLimitedExecution,
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Remaining'),
                    IntInputWidget(
                      'Remaining',
                      () => c.triggerEnemiesRemaining,
                      (i) => c.triggerEnemiesRemaining = i,
                      c.clearTriggerEnemiesRemaining,
                    ),
                    Text('Combos'),
                    IntInputWidget(
                      'Combos',
                      () => c.triggerCombos,
                      (i) => c.triggerCombos = i,
                      c.clearTriggerCombos,
                    ),
                    Text('Turn'),
                    IntInputWidget(
                      'Turn',
                      () => c.triggerTurn,
                      (i) => c.triggerTurn = i,
                      c.clearTriggerTurn,
                    ),
                    Text('Turn end'),
                    IntInputWidget(
                      'Turn End',
                      () => c.triggerTurnEnd,
                      (i) => c.triggerTurnEnd = i,
                      c.clearTriggerTurnEnd,
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text('After'),
                    IntInputWidget(
                      'Always after (skill ID)',
                      () => c.alwaysAfter,
                      (i) => c.alwaysAfter = i,
                      c.clearAlwaysAfter,
                    ),
                    Text(''),
                    Text(''),
                    Text(''),
                    Text(''),
                    Text('Trigger >'),
                    IntInputWidget(
                      'Trigger above HP',
                      () => c.alwaysTriggerAbove,
                      (i) => c.alwaysTriggerAbove = i,
                      c.clearAlwaysTriggerAbove,
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text('One time'),
                    BoolInputWidget(
                      'One Time',
                      () => c.globalOneTime,
                      (b) => c.globalOneTime = b,
                      c.clearGlobalOneTime,
                    ),
                    Text('On death'),
                    BoolInputWidget(
                      'On death',
                      () => c.ifDefeated,
                      (b) => c.ifDefeated = b,
                      c.clearIfDefeated,
                    ),
                    Text('Attr req'),
                    BoolInputWidget('Attr req', () => c.ifAttributesAvailable,
                        (b) => c.ifAttributesAvailable = b, c.clearIfAttributesAvailable),
                    Text(''),
                    Text(''),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class IntInputWidget extends StatelessWidget {
  final String name;
  final int Function() value;
  final Function(int) changed;
  final Function clear;

  IntInputWidget(this.name, this.value, this.changed, this.clear);
  @override
  Widget build(BuildContext context) {
    var data = Provider.of<MonsterInfoWrapper>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            width: 52,
            height: 24,
            child: RaisedButton(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                '${value()}',
                style: Theme.of(context).textTheme.caption,
              ),
              onPressed: () async {
                var newVal = await _asyncInputDialog(name, value(), context);
                if (newVal == null) {
                  return;
                } else if (newVal == 0) {
                  clear();
                } else {
                  changed(newVal);
                }
                data.update();
              },
            )),
      ],
    );
  }

  Future<int> _asyncInputDialog(String name, int oldValue, BuildContext context) async {
    var storedValue = oldValue;
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New value for $name'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextFormField(
                initialValue: '$oldValue',
                autofocus: true,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  storedValue = int.parse(value);
                },
              )),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(storedValue);
              },
            ),
          ],
        );
      },
    );
  }
}

class BoolInputWidget extends StatelessWidget {
  final String name;
  final bool Function() value;
  final Function(bool) changed;
  final Function clear;

  BoolInputWidget(this.name, this.value, this.changed, this.clear);

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<MonsterInfoWrapper>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Checkbox(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: value(),
          onChanged: (v) {
            if (v)
              changed(v);
            else
              clear();
            data.update();
          },
        )
      ],
    );
  }
}

class BoxMe extends StatelessWidget {
  final Color color;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  BoxMe({this.color, this.child, this.padding, this.margin});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(),
      ),
      child: child,
    );
  }
}
