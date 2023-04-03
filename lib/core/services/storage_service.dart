import 'package:shared_preferences/shared_preferences.dart';

// шагомер
const WALKING_LAST_SYNC_DATE_KEY = 'WALKING_LAST_SYNC_DATE_KEY';
const WALKING_EVENT_COMPLETE_KEY = 'WALKING_EVENT_COMPLETE_KEY';

enum AppMode { DEV, PROD }

class StorageService {
  final SharedPreferences _prefs;

  const StorageService(this._prefs);

  String? get lastSyncDate => _prefs.getString(WALKING_LAST_SYNC_DATE_KEY);

  bool? get walkingCompleteEvent => _prefs.getBool(WALKING_EVENT_COMPLETE_KEY);

  Future<bool> setWalkingEventComplete() => _prefs.setBool(WALKING_EVENT_COMPLETE_KEY, true);

  Future<bool> resetWalkingStore(int currentSteps, DateTime syncDate) async {
    final dateSaved = await _prefs.setString(
      WALKING_LAST_SYNC_DATE_KEY,
      syncDate.toIso8601String(),
    );

    final eventSaved = await _prefs.setBool(WALKING_EVENT_COMPLETE_KEY, false);

    return dateSaved && eventSaved;
  }
}
