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
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < groups.length; i++)
            BoxMe(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Parent Group: ${groups[i].groupType.name}'),
                      ListUpdateRow(i, groups),
                    ],
                  ),
                  EditableBehaviorGroupWidget(groups[i]),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A group of behavior, containing a list of child groups or individual behaviors.
class EditableBehaviorGroupWidget extends StatelessWidget {
  final BehaviorGroup group;

  EditableBehaviorGroupWidget(this.group);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoxMe(
            padding: const EdgeInsets.all(2.0),
            child: EditableConditionWidget(group.ensureCondition())),
        for (var i = 0; i < group.children.length; i++)
          Padding(
            padding: EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('SubGroup: ${group.groupType.name}'),
                    ListUpdateRow(i, group.children),
                  ],
                ),
                EditableBehaviorItemWidget(group.children[i]),
              ],
            ),
          ),
      ],
    );
  }
}

/// An individual child, containing either a nested group or a single behavior.
class EditableBehaviorItemWidget extends StatelessWidget {
  final BehaviorItem child;

  EditableBehaviorItemWidget(this.child);

  @override
  Widget build(BuildContext context) {
    if (child.hasGroup()) {
      return EditableBehaviorGroupWidget(child.group);
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
          Text('${skill.enemySkillId} - ${skill.nameNa}'),
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
        Row(),
        Text('Condition'),
        DefaultTextStyle(
          style: Theme.of(context).textTheme.caption,
          child: Wrap(
            runSpacing: 4,
            spacing: 8,
            children: <Widget>[
              IntInputWidget('HP', () => c.hpThreshold, (i) => c.hpThreshold = i),
              IntInputWidget('Chance', () => c.useChance, (i) => c.useChance = i),
              IntInputWidget('Repeats', () => c.repeatsEvery, (i) => c.repeatsEvery = i),
              IntInputWidget('Limited', () => c.limitedExecution, (i) => c.limitedExecution = i),
              IntInputWidget('Remaining', () => c.triggerEnemiesRemaining,
                  (i) => c.triggerEnemiesRemaining = i),
              IntInputWidget('Combos', () => c.triggerCombos, (i) => c.triggerCombos = i),
              IntInputWidget('Turn', () => c.triggerTurn, (i) => c.triggerTurn = i),
              IntInputWidget('Turn End', () => c.triggerTurnEnd, (i) => c.triggerTurnEnd = i),
              BoolInputWidget('One Time', () => c.globalOneTime, (b) => c.globalOneTime = b),
              BoolInputWidget('On death', () => c.ifDefeated, (b) => c.ifDefeated = b),
              BoolInputWidget(
                  'Attr req', () => c.ifAttributesAvailable, (b) => c.ifAttributesAvailable = b),
            ],
          ),
        )
      ],
    );
  }
}

class IntInputWidget extends StatelessWidget {
  final String name;
  final int Function() value;
  final Function(int) changed;
  final controller = TextEditingController();

  IntInputWidget(this.name, this.value, this.changed) {
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
            style: Theme.of(context).textTheme.caption,
            controller: controller,
            maxLines: 1,
            onChanged: (t) {
              var i = int.tryParse(t);
              if (i != null) changed(i);
              data.update();
            },
          ),
        )
      ],
    );
  }
}

class BoolInputWidget extends StatelessWidget {
  final String name;
  final bool Function() value;
  final Function(bool) changed;

  BoolInputWidget(this.name, this.value, this.changed);

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
              changed(v);
              data.update();
            },
          ),
        )
      ],
    );
  }
}

class BoxMe extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  BoxMe({this.child, this.padding});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: child,
    );
  }
}
