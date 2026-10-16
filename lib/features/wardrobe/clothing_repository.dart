import '../../database/app_database.dart';

class ClothingRepository {
  ClothingRepository(this._db);

  final AppDatabase _db;

  Stream<int> watchActiveCount() => _db.clothingDao.watchActiveCount();
}
