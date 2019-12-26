import 'package:dadguide2/proto/enemy_skills/enemy_skills.pb.dart';
import 'package:dadguide2/screens/dungeon_info/dungeon_behavior.dart';
import 'package:flutter/material.dart';
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
        InkWell(
          onTap: () {
            groups.insert(i, groups[i].clone());
            data.update();
          },
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text('clone'),
          ),
        ),
        InkWell(
          onTap: () {
            if (i > 0) {
              groups.insert(i - 1, groups.removeAt(i));
              data.update();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(2.0),
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
            padding: const EdgeInsets.all(2.0),
            child: Icon(Icons.arrow_downward),
          ),
        ),
        InkWell(
          onTap: () {
            groups.removeAt(i);
            data.update();
          },
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Icon(Icons.remove_circle),
          ),
        ),
      ],
    );
  }
}

class EditableEncounterBehaviorWidget extends StatelessWidget {
  final List<BehaviorGroup> groups;

  EditableEncounterBehaviorWidget(this.groups);

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<MonsterInfoWrapper>(context);

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < groups.length; i++)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: BoxMe(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Colors.blueAccent,
                      child: Row(
                        children: <Widget>[
                          Text('Top:  '),
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
                    ),
                    EditableBehaviorGroupWidget(1, groups[i]),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A group of behavior, containing a list of child groups or individual behaviors.
class EditableBehaviorGroupWidget extends StatelessWidget {
  final int nestingLevel;
  final BehaviorGroup group;

  EditableBehaviorGroupWidget(this.nestingLevel, this.group);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BoxMe(
                padding: const EdgeInsets.all(2.0),
                color: Colors.grey[300],
//                color: Colors.grey[200 * nestingLevel],
                child: EditableConditionWidget(group.ensureCondition())),
            SizedBox(height: 6),
            for (var i = 0; i < group.children.length; i++)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  color: Colors.grey[300],
//                  color: Colors.grey[200 * nestingLevel],
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.lightBlueAccent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Group ${nestingLevel}-${i + 1}'),
                            ListUpdateRow(i, group.children),
                          ],
                        ),
                      ),
                      EditableBehaviorItemWidget(
                          nestingLevel + 1, group.children[i]),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
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
    var skill = inputs.esLibrary[behavior.enemySkillId];

    return BoxMe(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              color: Colors.amber[50],
              child: Row(
                children: <Widget>[
                  Text('${skill.enemySkillId} - ${skill.nameNa}'),
                ],
              )),
          EditableConditionWidget(behavior.ensureCondition()),
//        if (skill.minHits > 0) Text(formatAttack(skill, inputs.atk), style: secondary(context)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.amber[50],
          child: Row(
            children: [
              Text('Condition'),
            ],
          ),
        ),
        DefaultTextStyle(
          style: Theme.of(context).textTheme.caption,
          child: Column(children: [
            Row(
              children: <Widget>[
                IntInputWidget(
                  'HP',
                  () => c.hpThreshold,
                  (i) => c.hpThreshold = i,
                  c.clearHpThreshold,
                ),
                IntInputWidget(
                  'Chance',
                  () => c.useChance,
                  (i) => c.useChance = i,
                  c.clearUseChance,
                ),
                IntInputWidget(
                  'Repeats',
                  () => c.repeatsEvery,
                  (i) => c.repeatsEvery = i,
                  c.clearRepeatsEvery,
                ),
                IntInputWidget(
                  'Limited',
                  () => c.limitedExecution,
                  (i) => c.limitedExecution = i,
                  c.clearLimitedExecution,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                IntInputWidget(
                  'Remaining',
                  () => c.triggerEnemiesRemaining,
                  (i) => c.triggerEnemiesRemaining = i,
                  c.clearTriggerEnemiesRemaining,
                ),
                IntInputWidget(
                  'Combos',
                  () => c.triggerCombos,
                  (i) => c.triggerCombos = i,
                  c.clearTriggerCombos,
                ),
                IntInputWidget(
                  'Turn',
                  () => c.triggerTurn,
                  (i) => c.triggerTurn = i,
                  c.clearTriggerTurn,
                ),
                IntInputWidget(
                  'Turn End',
                  () => c.triggerTurnEnd,
                  (i) => c.triggerTurnEnd = i,
                  c.clearTriggerTurnEnd,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                BoolInputWidget(
                  'One Time',
                  () => c.globalOneTime,
                  (b) => c.globalOneTime = b,
                  c.clearGlobalOneTime,
                ),
                BoolInputWidget(
                  'On death',
                  () => c.ifDefeated,
                  (b) => c.ifDefeated = b,
                  c.clearIfDefeated,
                ),
                BoolInputWidget(
                    'Attr req',
                    () => c.ifAttributesAvailable,
                    (b) => c.ifAttributesAvailable = b,
                    c.clearIfAttributesAvailable),
              ],
            ),
          ]),
        )
      ],
    );
  }
}

class IntInputWidget extends StatelessWidget {
  final String name;
  final int Function() value;
  final Function(int) changed;
  final Function clear;
  final controller = TextEditingController();

  IntInputWidget(this.name, this.value, this.changed, this.clear) {
    controller.text = value().toString();
  }
  @override
  Widget build(BuildContext context) {
    var data = Provider.of<MonsterInfoWrapper>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(name),
        SizedBox(width: 4),
        SizedBox(
          width: 34,
          height: 24,
          child: TextField(
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.caption,
            controller: controller,
            maxLines: 1,
            onChanged: (t) {
              var i = int.tryParse(t);
              if (i == 0)
                clear();
              else if (i != null) changed(i);
              data.update();
            },
          ),
        ),
        SizedBox(width: 8),
      ],
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
        Text(name),
        Transform.scale(
          scale: .8,
          child: Checkbox(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: value(),
            onChanged: (v) {
              if (v)
                changed(v);
              else
                clear();
              data.update();
            },
          ),
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
