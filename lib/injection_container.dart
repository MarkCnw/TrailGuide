import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trail_guide/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:trail_guide/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:trail_guide/features/p2p/datasources/p2p_native_data_source.dart';
import 'package:trail_guide/features/p2p/domain/usecases/broadcast_message.dart';
import 'package:trail_guide/features/p2p/domain/usecases/watch_messages.dart';
import 'package:trail_guide/features/p2p/presentation/bloc/p2p/p2p_bloc.dart';
import 'package:trail_guide/features/p2p/presentation/bloc/room/room_bloc.dart';
import 'package:trail_guide/features/tracking/presentation/bloc/location/location_bloc.dart';

// Features - P2P
import 'features/p2p/data/repositories/p2p_repository_impl.dart';
import 'features/p2p/domain/repositories/p2p_repository.dart';
import 'features/p2p/domain/usecases/scan_for_peers.dart';
import 'features/p2p/domain/usecases/watch_peers.dart';

// Features - Onboarding
import 'features/onboarding/data/models/user_profile_model.dart';

// Features - History (Clean Architecture)
import 'features/history/data/models/trip_history_model.dart';
import 'features/history/data/datasources/history_local_data_source.dart';
import 'features/history/data/repositories/history_repository_impl.dart';
import 'features/history/domain/repositories/history_repository.dart';
import 'features/history/domain/usecases/get_all_trips.dart';
import 'features/history/domain/usecases/save_trip.dart';
import 'features/history/presentation/cubit/history_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 🧹 1. ล้างค่าเก่าทิ้งก่อน (แก้ปัญหา Hot Restart)
  await sl.reset();

  // ! ===========================
  // !  External (ฐานข้อมูล & Hardware)
  // ! ===========================

  // เปิดใช้งาน Isar Database
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    UserProfileModelSchema,
    TripHistoryModelSchema, // 🆕 เพิ่ม Schema ประวัติทริป
  ], directory: dir.path);
  sl.registerLazySingleton(() => isar);

  // ! ===========================
  // ! Feature: Onboarding (Profile Setup)
  // ! ===========================

  // Data Source
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sl()),
  );

  // Cubit (Global State)
  sl.registerLazySingleton<OnboardingCubit>(
    () => OnboardingCubit(dataSource: sl()),
  );

  // ! ===========================
  // ! Feature: History (Trip Records)
  // ! ===========================

  // Data Source
  sl.registerLazySingleton<HistoryLocalDataSource>(
    () => HistoryLocalDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAllTrips(sl()));
  sl.registerLazySingleton(() => SaveTrip(sl()));

  // Cubit
  sl.registerLazySingleton<HistoryCubit>(
    () => HistoryCubit(getAllTrips: sl(), saveTrip: sl()),
  );

  // ! ===========================
  // ! Feature: P2P (Radar & Host)
  // ! ===========================

  // Repository
  // 1. ลงทะเบียน Data Source (เพิ่มบรรทัดนี้)
  sl.registerLazySingleton<P2PNativeDataSource>(
    () => P2PNativeDataSourceImpl(),
  );
  
  // 2. แก้ไข Repository ให้รับ Data Source เข้าไป
  sl.registerLazySingleton<P2PRepository>(
    () => P2PRepositoryImpl(nativeDataSource: sl()), // เติม sl() ตรงนี้
  );

  // Use Cases
  sl.registerLazySingleton(() => ScanForPeers(sl()));
  sl.registerLazySingleton(() => WatchPeers(sl()));
  sl.registerLazySingleton(() => WatchMessages(sl())); // 🆕
  sl.registerLazySingleton(() => BroadcastMessage(sl())); // 🆕
  // 🔧 Bug #4 Fix: เปลี่ยนจาก registerFactory เป็น registerLazySingleton เพื่อให้ใช้ instance เดียวกันทั้งแอป
  sl.registerLazySingleton(() => LocationBloc());
  // P2P BLoC
  // 🔥 แก้ไขตรงนี้: เติม parameters ที่ขาดไปให้ครบ
  sl.registerFactory<P2PBloc>(
    () => P2PBloc(
      scanForPeers: sl(),
      watchPeers: sl(),
      watchMessages: sl(), // <- เพิ่มตัวนี้
      broadcastMessage: sl(), // <- เพิ่มตัวนี้
      repository: sl(),
    ),
  );

  // 🆕 Room BLoC - เพิ่มใหม่
  sl.registerLazySingleton<RoomBloc>(() {
    final repository = sl<P2PRepository>();
    final roomBloc = RoomBloc(repository: repository);

    // Set callbacks เพื่อให้ RoomBloc รับข้อมูลจาก Repository
    repository.onPayloadReceived = (peerId, bytes) {
      roomBloc.processIncomingMessage(peerId, bytes);
    };

    repository.onPeerDisconnected = (peerId) {
      roomBloc.processPeerDisconnected(peerId);
    };

    return roomBloc;
  });
}
