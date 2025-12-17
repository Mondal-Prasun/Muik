import 'package:muik/provider/content_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class LoadMusicDb {
  LoadMusicDb._();

  static Future<LoadMusicDb> create() async {
    final instance = LoadMusicDb._();
    await instance._initSqlite();
    return instance;
  }

  late final Database _db;
  final String _dbName = "Loaded_Audio";
  final String _createTable =
      "CREATE TABLE IF NOT EXISTS Music (uuid TEXT PRIMARY KEY,name TEXT NOT NULL,uri TEXT NOT NULL);";

  final String _insertValue =
      " INSERT INTO Music (uuid, name, uri) VALUES (?, ?, ?);";

  Future<void> _initSqlite() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, _dbName);

    _db = await openDatabase(path, version: 1,
        onCreate: (Database d, int _) async {
      await d.execute(_createTable);
    });
  }

  void insertMusicInfo(String name, String uri) async {
    await _db.transaction((txn) async {
      String uuid = Uuid().v4();
      await txn.rawInsert(_insertValue, <String>[uuid, name, uri]);
    });
  }

  Future<List<MusicInfo>> getLimitedMusic(int limit, int offset) async {
    List<MusicInfo> querriedMusic = [];

    await _db.transaction((txn) async {
      QueryCursor qs = await txn.queryCursor("Music");

      while (await qs.moveNext()) {
        final String uuid = qs.current["uuid"] as String;
        final String name = qs.current["name"] as String;
        final String uri = qs.current["uri"] as String;

        querriedMusic.add(MusicInfo(name: name, uri: uri)..uuid = uuid);
      }

      qs.close();
    });

    return querriedMusic;
  }
}
