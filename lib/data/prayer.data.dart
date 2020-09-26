// import '../models/prayer.model.dart';

// final List<PrayerModel> prayerData = [
//   PrayerModel(
//     id: '1',
//     title: 'Prayer 1',
//     content:
//         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '1',
//     tags: [],
//     isAddedFromGroup: false,
//     hasReminder: false,
//     status: 'active',
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [
//       PrayerUpdateModel(
//           id: '1',
//           date: DateTime.parse("2020-12-02 22:30:00"),
//           tags: ['birth'],
//           content:
//               'Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis  a pellentesque nec, egestas non nisi. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus.')
//     ],
//   ),
//   PrayerModel(
//     id: '2',
//     title: 'Prayer 2',
//     content:
//         'test Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '2',
//     tags: ['praise'],
//     isAddedFromGroup: true,
//     hasReminder: true,
//     date: DateTime.parse("2020-02-02 15:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [],
//     status: 'answered',
//   ),
//   PrayerModel(
//     id: '3',
//     title: 'Prayer 3',
//     content:
//         'test Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '2',
//     tags: ['birth'],
//     isAddedFromGroup: false,
//     hasReminder: false,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [],
//     status: 'answered',
//   ),
//   PrayerModel(
//     id: '4',
//     title: 'Prayer 4',
//     content:
//         'test Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '2',
//     tags: [],
//     status: 'active',
//     hasReminder: true,
//     isAddedFromGroup: true,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [
//       PrayerUpdateModel(
//           id: '1',
//           date: DateTime.parse("2020-12-02 20:30:00"),
//           tags: ['birth'],
//           content:
//               'Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis  a pellentesque nec, egestas non nisi. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus.'),
//       PrayerUpdateModel(
//           tags: ['praise'],
//           id: '2',
//           date: DateTime.parse("2020-02-20 30:30:00"),
//           content:
//               'Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis  a pellentesque nec, egestas non nisi. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus.')
//     ],
//   ),
//   PrayerModel(
//     id: '5',
//     title: 'Prayer 5',
//     content:
//         'test Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '1',
//     tags: ['praise'],
//     isAddedFromGroup: false,
//     hasReminder: false,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [],
//     status: 'active',
//   ),
//   PrayerModel(
//     id: '6',
//     title: 'Prayer 6',
//     content:
//         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '1',
//     tags: ['birth'],
//     hasReminder: true,
//     isAddedFromGroup: true,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [
//       PrayerUpdateModel(
//           id: '1',
//           date: DateTime.parse("2020-12-02 22:30:00"),
//           tags: ['praise'],
//           content:
//               'Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis  a pellentesque nec, egestas non nisi. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus.')
//     ],
//     status: 'active',
//   ),
//   PrayerModel(
//     id: '7',
//     title: 'Prayer 7',
//     status: 'active',
//     content:
//         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '1',
//     tags: [],
//     hasReminder: false,
//     isAddedFromGroup: true,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [
//       PrayerUpdateModel(
//           tags: ['birth'],
//           id: '1',
//           date: DateTime.parse("2020-12-02 22:30:00"),
//           content:
//               'Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis  a pellentesque nec, egestas non nisi. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus.')
//     ],
//   ),
//   PrayerModel(
//     id: '8',
//     title: 'Prayer 8',
//     content:
//         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '2',
//     tags: ['praise'],
//     isAddedFromGroup: true,
//     hasReminder: true,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [],
//     status: 'active',
//   ),
//   PrayerModel(
//     id: '9',
//     title: 'Prayer 9',
//     content:
//         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '1',
//     tags: ['birth'],
//     isAddedFromGroup: false,
//     hasReminder: true,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [],
//     status: 'active',
//   ),
//   PrayerModel(
//     id: '10',
//     title: 'Prayer 10',
//     content:
//         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '1',
//     tags: [],
//     hasReminder: false,
//     isAddedFromGroup: true,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [
//       PrayerUpdateModel(
//           tags: ['birth'],
//           id: '1',
//           date: DateTime.parse("2020-12-02 22:30:00"),
//           content:
//               'Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis  a pellentesque nec, egestas non nisi. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus.')
//     ],
//     status: 'active',
//   ),
//   PrayerModel(
//     id: '11',
//     title: 'Prayer 11',
//     content:
//         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '1',
//     tags: ['praise'],
//     isAddedFromGroup: true,
//     hasReminder: false,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [],
//     status: 'active',
//   ),
//   PrayerModel(
//     id: '12',
//     title: 'Prayer 12',
//     content:
//         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '1',
//     tags: ['birth'],
//     hasReminder: false,
//     isAddedFromGroup: false,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [
//       PrayerUpdateModel(
//           tags: ['birth'],
//           id: '1',
//           date: DateTime.parse("2020-12-02 22:30:00"),
//           content:
//               'Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis  a pellentesque nec, egestas non nisi. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus.')
//     ],
//     status: 'active',
//   ),
//   PrayerModel(
//     id: '13',
//     title: 'Prayer 13',
//     content:
//         'test Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '2',
//     tags: ['birth'],
//     isAddedFromGroup: false,
//     hasReminder: false,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [],
//     status: 'answered',
//   ),
//   PrayerModel(
//     id: '14',
//     title: 'Prayer 14',
//     content:
//         'test Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '2',
//     tags: [],
//     status: 'active',
//     hasReminder: true,
//     isAddedFromGroup: true,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [
//       PrayerUpdateModel(
//           id: '1',
//           date: DateTime.parse("2020-12-02 20:30:00"),
//           tags: ['birth'],
//           content:
//               'Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis  a pellentesque nec, egestas non nisi. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus.'),
//       PrayerUpdateModel(
//           tags: ['praise'],
//           id: '2',
//           date: DateTime.parse("2020-02-20 30:30:00"),
//           content:
//               'Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis  a pellentesque nec, egestas non nisi. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus.')
//     ],
//   ),
//   PrayerModel(
//     id: '15',
//     title: 'Prayer 15',
//     content:
//         'test Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '1',
//     tags: ['praise'],
//     isAddedFromGroup: false,
//     hasReminder: false,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [],
//     status: 'archived',
//   ),
//   PrayerModel(
//     id: '16',
//     title: 'Prayer 16',
//     content:
//         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '1',
//     tags: ['birth'],
//     hasReminder: true,
//     isAddedFromGroup: true,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [
//       PrayerUpdateModel(
//           id: '1',
//           date: DateTime.parse("2020-12-02 22:30:00"),
//           tags: ['praise'],
//           content:
//               'Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis  a pellentesque nec, egestas non nisi. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus.')
//     ],
//     status: 'active',
//   ),
//   PrayerModel(
//     id: '17',
//     title: 'Prayer 17',
//     status: 'active',
//     content:
//         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '1',
//     tags: [],
//     hasReminder: false,
//     isAddedFromGroup: true,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [
//       PrayerUpdateModel(
//           tags: ['birth'],
//           id: '1',
//           date: DateTime.parse("2020-12-02 22:30:00"),
//           content:
//               'Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis  a pellentesque nec, egestas non nisi. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus.')
//     ],
//   ),
//   PrayerModel(
//     id: '18',
//     title: 'Prayer 18',
//     content:
//         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '2',
//     tags: ['praise'],
//     isAddedFromGroup: true,
//     hasReminder: true,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [],
//     status: 'active',
//   ),
//   PrayerModel(
//     id: '19',
//     title: 'Prayer 19',
//     content:
//         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '1',
//     tags: ['birth'],
//     isAddedFromGroup: false,
//     hasReminder: true,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [],
//     status: 'archived',
//   ),
//   PrayerModel(
//     id: '23',
//     title: 'Prayer 23',
//     content:
//         'test Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '2',
//     tags: ['birth'],
//     isAddedFromGroup: false,
//     hasReminder: false,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [],
//     status: 'answered',
//   ),
//   PrayerModel(
//     id: '24',
//     title: 'Prayer 24',
//     content:
//         'test Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '2',
//     tags: [],
//     status: 'active',
//     hasReminder: true,
//     isAddedFromGroup: true,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [
//       PrayerUpdateModel(
//           id: '1',
//           date: DateTime.parse("2020-12-02 20:30:00"),
//           tags: ['birth'],
//           content:
//               'Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis  a pellentesque nec, egestas non nisi. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus.'),
//       PrayerUpdateModel(
//           tags: ['praise'],
//           id: '2',
//           date: DateTime.parse("2020-02-20 30:30:00"),
//           content:
//               'Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis  a pellentesque nec, egestas non nisi. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus.')
//     ],
//   ),
//   PrayerModel(
//     id: '25',
//     title: 'Prayer 25',
//     content:
//         'test Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '1',
//     tags: ['praise'],
//     isAddedFromGroup: false,
//     hasReminder: false,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [],
//     status: 'active',
//   ),
//   PrayerModel(
//     id: '26',
//     title: 'Prayer 26',
//     content:
//         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '1',
//     tags: ['birth'],
//     hasReminder: true,
//     isAddedFromGroup: true,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [
//       PrayerUpdateModel(
//           id: '1',
//           date: DateTime.parse("2020-12-02 22:30:00"),
//           tags: ['praise'],
//           content:
//               'Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis  a pellentesque nec, egestas non nisi. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus.')
//     ],
//     status: 'active',
//   ),
//   PrayerModel(
//     id: '27',
//     title: 'Prayer 27',
//     status: 'archived',
//     content:
//         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '1',
//     tags: [],
//     hasReminder: false,
//     isAddedFromGroup: true,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [
//       PrayerUpdateModel(
//           tags: ['birth'],
//           id: '1',
//           date: DateTime.parse("2020-12-02 22:30:00"),
//           content:
//               'Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis Nulla porttitor accumsan tincidunt. Proin eget tortor risus. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Praesent sapien massa, convallis  a pellentesque nec, egestas non nisi. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus.')
//     ],
//   ),
//   PrayerModel(
//     id: '28',
//     title: 'Prayer 28',
//     content:
//         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '2',
//     tags: ['praise'],
//     isAddedFromGroup: true,
//     hasReminder: true,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [],
//     status: 'active',
//   ),
//   PrayerModel(
//     id: '29',
//     title: 'Prayer 29',
//     content:
//         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed venenatis ex vitae sollicitudin ullamcorper. Vivamus vitae lacus et est viverra fermentum. Pellentesque venenatis nunc ante, sit amet laoreet diam laoreet id. Sed venenatis, augue et hendrerit congue, velit mi vehicula nisl, vitae tincidunt mauris ipsum ut nisi. ',
//     user: '1',
//     tags: ['birth'],
//     isAddedFromGroup: false,
//     hasReminder: true,
//     date: DateTime.parse("2020-02-02 13:30:00"),
//     // time: '7:45am',
//     reminder: 'Monthly | 19 | 4:30P',
//     updates: [],
//     status: 'active',
//   ),
// ];
