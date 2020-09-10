import 'package:be_still/models/notifictaion.model.dart';

final List<NotificationModel> notificationData = [
  NotificationModel(
    group: '1',
    id: '1',
    content:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
    creator: 'Jane Doe',
    type: 'BeStill Annoucement',
    date: DateTime.parse("2020-02-02 13:30:00"),
  ),
  NotificationModel(
    group: '1',
    id: '2',
    content:
        'test Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
    creator: 'Jane Doe',
    date: DateTime.parse("2020-02-02 15:30:00"),
    type: 'Prayer Updates',
  ),
  NotificationModel(
    group: '3',
    id: '3',
    content:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
    creator: 'Jane Doe',
    date: DateTime.parse("2020-02-02 13:30:00"),
    type: 'New Prayers',
  ),
  NotificationModel(
    group: '3',
    id: '4',
    content:
        'test Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
    creator: 'Jane Doe',
    type: 'Message',
    date: DateTime.parse("2020-02-02 13:30:00"),
  ),
  NotificationModel(
    group: '2',
    id: '5',
    content:
        'test Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
    creator: 'Jane Doe',
    date: DateTime.parse("2020-02-02 13:30:00"),
    type: 'Request',
  ),
];
