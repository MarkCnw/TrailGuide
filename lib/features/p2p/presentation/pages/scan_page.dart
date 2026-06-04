import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trail_guide/features/p2p/presentation/bloc/p2p/p2p_bloc.dart';

import '../../../../core/constants/app_colors.dart';

import '../../../onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../domain/entities/peer_entity.dart';
import '../../utils/image_helper.dart';

import '../bloc/room/room_bloc.dart';
import '../bloc/room/room_event.dart';
import '../bloc/room/room_state.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final _passwordController = TextEditingController();

  String _memberName = 'Member';
  String? _memberImagePath;
  String? _memberImageBase64;

  PeerEntity? _selectedHost;
  late final P2PBloc _p2pBloc;

  @override
  void initState() {
    super.initState();
    _p2pBloc = context.read<P2PBloc>();
    _loadMemberInfo();
    _startDiscovery();
  }

  Future<void> _loadMemberInfo() async {
    final onboardingState = context.read<OnboardingCubit>().state;
    if (onboardingState is OnboardingLoaded) {
      _memberName = onboardingState.profile.nickname;
      _memberImagePath = onboardingState.profile.imagePath;

      if (_memberImagePath != null) {
        _memberImageBase64 = await ImageHelper.compressAndEncode(
          _memberImagePath,
        );
      }
      setState(() {});
    }
  }

  void _startDiscovery() {
    _p2pBloc.add(StartDiscoveryEvent(_memberName));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _p2pBloc.add(StopDiscoveryEvent());
    super.dispose();
  }

  String _getHostName(String advertisingName) {
    final parts = advertisingName.split('#');
    return parts.isNotEmpty ? parts[0] : advertisingName;
  }

  void _showPasswordDialog(PeerEntity host) {
    _selectedHost = host;
    _passwordController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPasswordBottomSheet(host),
    );
  }

  void _joinRoom() {
    if (_selectedHost == null) return;
    if (_passwordController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a 4-digit password'),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }

    Navigator.pop(context);

    context.read<RoomBloc>().add(
      JoinRoomEvent(
        hostPeerId: _selectedHost!.id,
        hostName: _getHostName(_selectedHost!.name),
        password: _passwordController.text,
        memberName: _memberName,
        memberImageBase64: _memberImageBase64,
      ),
    );
  }

  void _showRoomClosedDialog(String reason) {
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cancel_outlined,
                color: Colors.red[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Room Closed',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          reason,
          style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<RoomBloc>().add(const ResetRoomEvent());
                _startDiscovery();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'OK',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomBloc, RoomState>(
      listener: (context, state) {
        // 🟢 เพิ่มจุดนี้: ถ้าเข้าห้องสำเร็จ ให้โยนไปหน้า Lobby 
        if (state is RoomJoined) {
          context.go('/lobby');
        } else if (state is RoomTripStarted) {
          context.go('/radar');
        } else if (state is RoomLeft) {
          _startDiscovery();
        } else if (state is RoomClosedByHost) {
          _showRoomClosedDialog(state.reason);
        } else if (state is RoomPasswordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.lock, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(state.message),
                ],
              ),
              backgroundColor: Colors.red[600],
            ),
          );
          // 🟢 FIX: Reset state กลับเพื่อให้กดเข้าห้องใหม่ได้
          context.read<RoomBloc>().add(const ResetRoomEvent());
        } else if (state is RoomFullError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.people, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(state.message),
                ],
              ),
              backgroundColor: Colors.orange[600],
            ),
          );
          // 🟢 FIX: Reset state กลับเพื่อให้กดเข้าห้องใหม่ได้
          context.read<RoomBloc>().add(const ResetRoomEvent());
        } else if (state is RoomError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red[600],
            ),
          );
          // 🟢 FIX: Reset state กลับเพื่อให้กดเข้าห้องใหม่ได้
          context.read<RoomBloc>().add(const ResetRoomEvent());
        }
      },
      builder: (context, roomState) {
        // 🛑 ถอด _buildInRoomView ออกไปแล้ว
        if (roomState is RoomJoining) {
          return _buildJoiningView(roomState);
        }
        return _buildScanView();
      },
    );
  }

  Widget _buildScanView() {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () {
                          _p2pBloc.add(StopDiscoveryEvent());
                          context.go('/radar');
                        },
                      ),
                    ],
                  ),
                  Icon(
                    Icons.wifi_tethering_rounded,
                    size: 48,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'กำลังค้นหาห้องใกล้เคียง...',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'ตรวจสอบให้เเน่ใจว่าคุณอยู่ใกล้Host',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<P2PBloc, P2PState>(
                builder: (context, state) {
                  if (state is P2PLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is P2PUpdated) {
                    if (state.peers.isEmpty) {
                      return _buildEmptyView();
                    }
                    return _buildRoomList(state.peers);
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomList(List<PeerEntity> peers) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: peers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final peer = peers[index];
        return _buildRoomItem(peer);
      },
    );
  }

  Widget _buildRoomItem(PeerEntity peer) {
    final textTheme = Theme.of(context).textTheme;
    final hostName = _getHostName(peer.name);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPasswordDialog(peer),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[600]!],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      hostName.isNotEmpty ? hostName[0].toUpperCase() : '?',
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$hostName\'s ห้อง',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green[500],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Available',
                            style: textTheme.labelMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'เข้า',
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'ไม่พบห้องใกล้เคียง',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ให้Hostสร้างห้องก่อน',
            style: textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _startDiscovery,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('รีเฟรช'),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordBottomSheet(PeerEntity host) {
    final textTheme = Theme.of(context).textTheme;
    final hostName = _getHostName(host.name);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 32,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Join $hostName\'s ห้อง',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ป้อนรหัสผ่าน 4 หลัก',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _passwordController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              autofocus: true,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 16,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '••••',
                hintStyle: textTheme.headlineMedium?.copyWith(
                  color: Colors.grey[300],
                  letterSpacing: 16,
                ),
                counterText: '',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.green[600]!,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                if (value.length == 4) _joinRoom();
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _joinRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'เข้าห้อง',
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildJoiningView(RoomJoining state) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.green,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'กำลังเข้า ${state.hostName}\'s ห้อง.. .',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'กรุณารอสักครู่..',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}