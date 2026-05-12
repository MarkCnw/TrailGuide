import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:svg_flutter/svg.dart';

// 🟢 Import Design System
import '../../../../core/constants/app_colors.dart';
import 'package:trail_guide/features/p2p/presentation/bloc/p2p/p2p_bloc.dart';
import '../../../onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../domain/entities/peer_entity.dart';
import '../../utils/image_helper.dart';
import '../bloc/room/room_bloc.dart';
import '../bloc/room/room_event.dart';
import '../bloc/room/room_state.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isCreatingRoom = false;
  bool _showPassword = false;

  String _hostName = 'Host';
  String? _hostImagePath;
  String? _hostImageBase64;

  @override
  void initState() {
    super.initState();
    _loadHostInfo();

    
  }

  Future<void> _loadHostInfo() async {
    final onboardingState = context.read<OnboardingCubit>().state;
    if (onboardingState is OnboardingLoaded) {
      _hostName = onboardingState.profile.nickname;
      _hostImagePath = onboardingState.profile.imagePath;

      if (_hostImagePath != null) {
        _hostImageBase64 = await ImageHelper.compressAndEncode(
          _hostImagePath,
        );
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _createRoom() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isCreatingRoom = true);
    context.read<RoomBloc>().add(
      CreateRoomEvent(
        password: _passwordController.text,
        hostName: _hostName,
        hostImageBase64: _hostImageBase64,
        maxMembers: 5,
      ),
    );
  }

  // 🚪 ฟังก์ชันออกห้องแบบ Shared (ใช้ได้ทั้ง Host และ Member)
  void _showExitRoomDialog() {
    final textTheme = Theme.of(context).textTheme;
    final isHost = context.read<RoomBloc>().isHost; // 🟢 เช็กว่าเป็นหัวหน้าหรือไม่

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isHost 
                    ? AppColors.danger.withValues(alpha: 0.1) 
                    : AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isHost ? Icons.power_settings_new_rounded : Icons.exit_to_app_rounded,
                color: isHost ? AppColors.danger : AppColors.warning,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isHost ? 'ยุติการเดินทาง?' : 'ออกจากห้อง?',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: AppColors.textHigh,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isHost 
                ? 'ระบบจะตัดการเชื่อมต่อลูกทีมทั้งหมด\nและเรดาร์จะหยุดทำงานทันที'
                : 'คุณแน่ใจหรือไม่ว่าต้องการออกจากกลุ่มนี้?',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textMedium,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ยกเลิก'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (isHost) {
                        context.read<RoomBloc>().add(const CloseRoomEvent(reason: 'Host closed the room. '));
                      } else {
                        context.read<RoomBloc>().add(const LeaveRoomEvent());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isHost ? AppColors.danger : AppColors.warning,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isHost ? 'ปิดห้อง' : 'ออกจากห้อง'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<RoomBloc, RoomState>(
      listener: (context, state) {
        if (state is RoomCreated) {
          setState(() => _isCreatingRoom = false);
        } else if (state is RoomTripStarted) {
          context.go('/radar');
        } else if (state is RoomClosedByHost) {
          context.go('/home'); // หัวหน้าปิดห้อง กลับโฮม
        } else if (state is RoomLeft) {
          context.go('/radar'); // ลูกทีมกดออก กลับไปหน้าสแกน(เรดาร์)
        } else if (state is RoomError) {
          setState(() => _isCreatingRoom = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.message,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      },
      builder: (context, state) {
        // 🟢 เช็กว่าอยู่ในสถานะที่เข้าห้องแล้ว (ทั้งแบบ Host และ Member)
        final isInLobby = state is RoomCreated || state is RoomJoined;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(state, isInLobby),
          body: isInLobby
              ? _buildLobbyContent(state)
              : _buildCreateRoomForm(),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(RoomState state, bool isInLobby) {
    final textTheme = Theme.of(context).textTheme;

    String countDisplay = '';
    bool isFull = false;

    // 🟢 ดึงข้อมูลจำนวนคนจาก State ของทั้งสองฝั่ง
    if (state is RoomCreated) {
      countDisplay = state.memberCountDisplay;
      isFull = state.isFull;
    } else if (state is RoomJoined) {
      countDisplay = state.memberCountDisplay;
      isFull = state.allMembers.length >= state.maxMembers;
    }

    return AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textHigh,
          size: 20,
        ),
        onPressed: () {
          if (isInLobby) {
            _showExitRoomDialog(); // 🟢 ใช้ Dialog รวมสำหรับออกห้อง
          } else {
            context.read<P2PBloc>().add(StopDiscoveryEvent());
            context.go('/radar');
          }
        },
      ),
      title: Text(
        isInLobby ? 'Lobby' : '',
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.textHigh,
          letterSpacing: -0.5,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        if (isInLobby)
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isFull ? AppColors.warning : AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  countDisplay,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.textHigh,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ==========================================
  // ✨ หน้าสร้างห้อง: (สำหรับ Host ก่อนสร้างสำเร็จ)
  // ==========================================
  Widget _buildCreateRoomForm() {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    SvgPicture.asset(
                      'assets/Illustration/create.svg',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'ตั้งรหัสความปลอดภัย',
                      style: textTheme.headlineSmall?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textHigh,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'รหัสผ่าน 4 หลักนี้ จะถูกใช้เป็นกุญแจสำหรับ\nเพื่อนร่วมทีมของคุณในการเข้าร่วมกลุ่ม',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        color: AppColors.textMedium,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // 🔐 Minimal OTP Input
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _passwordController,
                          builder: (context, value, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (index) {
                                final isFocused = value.text.length == index;
                                final hasChar = index < value.text.length;
                                final char = hasChar
                                    ? (_showPassword ? value.text[index] : '●')
                                    : '';

                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  width: 60,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isFocused ? AppColors.primary : AppColors.border,
                                      width: isFocused ? 2 : 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    char,
                                    style: textTheme.headlineMedium?.copyWith(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textHigh,
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.0,
                            child: TextFormField(
                              controller: _passwordController,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              showCursor: false,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.length != 4) return 'ต้องการ 4 หลัก';
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                      child: Text(_showPassword ? 'ซ่อนตัวเลข' : 'แสดงตัวเลข'),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCreatingRoom ? null : _createRoom,
                        child: _isCreatingRoom
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : const Text('ดำเนินการสร้างกลุ่ม'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ✨ หน้าล็อบบี้ (Shared UI สำหรับ Host และ Member)
  // ==========================================
  Widget _buildLobbyContent(RoomState state) {
    final textTheme = Theme.of(context).textTheme;
    final isHost = context.read<RoomBloc>().isHost; // 🟢 แยก Role

    String password = '';
    List<PeerEntity> members = [];

    // 🟢 ดึงข้อมูลให้ถูก State
    if (state is RoomCreated) {
      password = state.room.password;
      members = state.allParticipants; // (ตามโค้ดเดิมของคุณ)
    } else if (state is RoomJoined) {
      password = state.roomPassword;
      members = state.allMembers;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔐 รหัสผ่านแบบไม่มีการ์ด วางกลมกลืนกับพื้นหลัง
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: SvgPicture.asset('assets/Illustration/fire.svg', width: 150, height: 150),
                ),
                const SizedBox(height: 16),
                Text(
                  'รหัสเข้าร่วมทีม',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.textMedium,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),

                // 🔲 Clean PIN Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: password.split('').map((digit) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 56,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        digit,
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
                Text(
                  'ให้เพื่อนกรอกรหัสนี้เพื่อเข้าร่วมเรดาร์',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLow,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 👥 Members List
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'รายชื่อลูกทีม',
            style: textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textHigh,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: members.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildPremiumMemberItem(members[index]);
                  },
                ),
              ),

              // 🚀 Bottom Button (เงื่อนไขระหว่าง Host และ Member)
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5), // 🟢 withValues
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54, // กำหนดความสูงปุ่มให้มาตรฐาน
                  child: isHost
                      // ปุ่มของ Host (กดเริ่มได้)
                      ? ElevatedButton.icon(
                          onPressed: () => context.read<RoomBloc>().add(StartTripEvent()),
                          icon: const Icon(Icons.explore_rounded, size: 22),
                          label: const Text('เริ่มการเดินทาง', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        )
                      // ปุ่มของ Member (กดไม่ได้ โชว์สถานะรอ)
                      : OutlinedButton.icon(
                          onPressed: () {}, // ว่างไว้
                          icon: const Icon(Icons.hourglass_empty_rounded, size: 20),
                          label: const Text('รอหัวหน้าทีมเริ่มทริป...', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                            side: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumMemberItem(PeerEntity member) {
    final textTheme = Theme.of(context).textTheme;
    final imageBytes = ImageHelper.decodeBase64(member.imageBase64);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          // 🖼️ Avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: member.isHost
                    ? AppColors.warning
                    : AppColors.primary.withValues(alpha: 0.3), // 🟢 withValues
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.background,
              backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
              child: imageBytes == null
                  ? Text(
                      member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.textHigh,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),

          // 📝 Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  member.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.textHigh,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: member.isHost ? AppColors.warning : AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      member.isHost ? 'หัวหน้าทีม' : 'พร้อมลุย',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 👑 Icon ฝั่งขวา
          if (member.isHost)
            Container(
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset('assets/icons/app/Crown1.svg'),
            ),
        ],
      ),
    );
  }
}