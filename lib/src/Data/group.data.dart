import 'package:be_still/src/Models/group.model.dart';

const List<GroupModel> GROUP_DATA = [
  GroupModel(
    id: '1',
    admin: '1',
    members: ['1', '2'],
    name: 'Group List 1',
    prayerList: ['2', '4', '6'],
    moderators: ['1'],
  ),
  GroupModel(
    id: '2',
    admin: '2',
    members: ['1','2'],
    name: 'Group List 2',
    prayerList: ['7', '8', '10'],
    moderators: ['2'],
  ),
  GroupModel(
    id: '3',
    admin: '2',
    members: ['2'],
    name: 'Group List 3',
    prayerList: ['11'],
    moderators: ['1'],
  ),
];
