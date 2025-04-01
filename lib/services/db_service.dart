import 'package:sqflite/sqflite.dart';

class DbService {
  late Database db;

  final String chatsTable = 'chats_table';
  final String chatId = '_id';
  final String chatName = 'name';
  final String messages = 'messages';
  final String participants = 'participants';

  final String messagesTable = 'messages_table';


  Future open() async {
    var databasesPath = await getDatabasesPath();
    String path = '$databasesPath/demo.db';

    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $messagesTable ( 
  $chatId text not null, 
  $chatName text,
  $messages integer not null
  $participants)
)

create table $chatsTable ( 
  $chatId text not null, 
  $chatName text,
  $messages,
  $participants)
''');
    });
  }
}
