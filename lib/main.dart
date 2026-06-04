import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trail_guide/core/config/routes/app_router.dart';
import 'package:trail_guide/core/theme/app_theme.dart';
import 'package:trail_guide/features/p2p/presentation/bloc/p2p/p2p_bloc.dart';
import 'package:trail_guide/features/p2p/presentation/bloc/room/room_bloc.dart';
import 'package:trail_guide/features/tracking/presentation/bloc/location/location_bloc.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'features/history/presentation/cubit/history_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 🟢 1. Import
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers:  [
        // 1. Onboarding (ข้อมูลส่วนตัว)
        BlocProvider<OnboardingCubit>(
          create: (_) => di.sl<OnboardingCubit>()..loadUserProfile(),
        ),

        // 2. P2PBloc (ระบบ Host/Join)
        BlocProvider<P2PBloc>(
          create:  (_) => di.sl<P2PBloc>(),
        ),

        // 🆕 3. RoomBloc (ระบบจัดการห้อง)
        BlocProvider<RoomBloc>(
          create: (_) => di.sl<RoomBloc>(),
        ),

        BlocProvider(create: (_) => di.sl<LocationBloc>()),

        // 🆕 5. HistoryCubit (ประวัติทริป)
        BlocProvider<HistoryCubit>(
          create: (_) => di.sl<HistoryCubit>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844), // ขนาดหน้าจอ Figma ของคุณ
        minTextAdapt: true, // ปรับสเกลฟอนต์อัตโนมัติ
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'TrailGuide',
            routerConfig: AppRouter.router,
            theme: AppTheme.lightTheme,
          );
        
        },
      )
      );
    
    
  }
}