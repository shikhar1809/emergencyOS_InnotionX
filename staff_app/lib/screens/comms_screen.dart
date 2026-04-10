import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/doctor_model.dart';
import '../models/message_model.dart';
import '../models/presence_model.dart';
import '../services/firestore_service.dart';

class CommsScreen extends StatefulWidget {
  final DoctorModel doctor;
  final FirestoreService firestoreService;

  const CommsScreen({
    super.key,
    required this.doctor,
    required this.firestoreService,
  });

  @override
  State<CommsScreen> createState() => _CommsScreenState();
}

class _CommsScreenState extends State<CommsScreen> {
  // Same Firestore channel IDs + labels as admin (`web/index.html` — Internal Comms sidebar).
  static const _channelsAnnouncements = [
    ('announcements', '# announcements', Icons.campaign_outlined),
    ('alerts', '# alerts', Icons.warning_amber_outlined),
  ];

  static const _channelsStaff = [
    ('shift-updates', '# shift-updates', Icons.schedule_outlined),
    ('ems-handshake', '# ems-handshake', Icons.sync_alt_outlined),
    ('admin', '# admin', Icons.admin_panel_settings_outlined),
  ];

  static const _channelDescs = {
    'announcements': 'Broadcast updates and critical notices.',
    'alerts': 'High-priority operational alerts and hazard notices.',
    'shift-updates': 'Shift handovers, staffing changes, quick coordination.',
    'ems-handshake': 'Coordination with incoming EMS units.',
    'admin': 'Admin-only operations coordination and approvals.',
  };

  final _allChannels = [..._channelsAnnouncements, ..._channelsStaff];
  int _channelIndex = 0; // index in _allChannels
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  String get _activeChannelId => _allChannels[_channelIndex].$1;
  String get _activeChannelLabel => _allChannels[_channelIndex].$2;
  String get _activeChannelDesc => _channelDescs[_activeChannelId] ?? '';

  /// Admin-managed; staff app stays read-only here (same Firestore feed as admin).
  bool get _composerReadOnly => _activeChannelId == 'alerts';

  static const double _wideBreakpoint = 720;

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _formatLastSeen(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _sidebarSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 2),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: const Color(0xFF6b7280),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _sidebarChannelButton((String id, String label, IconData icon) chan) {
    final idx = _allChannels.indexWhere((c) => c.$1 == chan.$1);
    final active = idx == _channelIndex;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _channelIndex = idx),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF1a1a35) : const Color(0xFF13132a),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: active ? const Color(0xFF7c3aed) : const Color(0xFF1e1e3a),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  chan.$3,
                  size: 16,
                  color: active ? const Color(0xFFc4b5fd) : const Color(0xFF4b5563),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    chan.$2,
                    style: GoogleFonts.inter(
                      color: active ? Colors.white : const Color(0xFFd1d5db),
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
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

  /// Left column — matches admin `channelSidebar`.
  Widget _buildChannelSidebar(double width) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: Color(0xFF13132a),
        border: Border(right: BorderSide(color: Color(0xFF1e1e3a))),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 16),
        children: [
          Text(
            'Internal Comms',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _sidebarSectionLabel('Announcements'),
          ..._channelsAnnouncements.map(_sidebarChannelButton),
          const SizedBox(height: 10),
          _sidebarSectionLabel('Staff Comms'),
          ..._channelsStaff.map(_sidebarChannelButton),
        ],
      ),
    );
  }

  Widget _buildCommsHeader({required bool showRosterShortcut}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      color: const Color(0xFF0d0d1a),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _activeChannelLabel,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (_activeChannelDesc.isNotEmpty)
                  Text(
                    _activeChannelDesc,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF6b7280),
                    ),
                  ),
              ],
            ),
          ),
          StreamBuilder<List<PresenceModel>>(
            stream: widget.firestoreService.onlinePresenceStream(),
            builder: (context, snap) {
              final n = (snap.data ?? const []).length;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF13132a),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1e1e3a)),
                ),
                child: Text(
                  '$n online',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFc4b5fd),
                  ),
                ),
              );
            },
          ),
          if (showRosterShortcut) ...[
            const SizedBox(width: 6),
            IconButton(
              onPressed: _openRosterSheet,
              icon: const Icon(Icons.groups_2_outlined, color: Color(0xFFcbd5e1)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<List<MessageModel>>(
      stream: widget.firestoreService.messagesStream(_activeChannelId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7c3aed)),
          );
        }
        final msgs = snapshot.data ?? [];
        if (msgs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline,
                    color: Color(0xFF1e1e3a), size: 48),
                const SizedBox(height: 12),
                Text(
                  'No messages in $_activeChannelLabel',
                  style: GoogleFonts.inter(
                      color: const Color(0xFF4b5563), fontSize: 13),
                ),
                Text(
                  _composerReadOnly
                      ? 'No messages yet. Admin posts appear here.'
                      : 'Be the first to send a message.',
                  style: GoogleFonts.inter(
                      color: const Color(0xFF374151), fontSize: 11),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          itemCount: msgs.length,
          itemBuilder: (ctx, i) {
            final msg = msgs[i];
            final isMe = msg.senderUid == widget.doctor.uid;
            final showSender =
                i == 0 || msgs[i - 1].senderUid != msg.senderUid;
            return _messageBubble(msg, isMe: isMe, showSender: showSender);
          },
        );
      },
    );
  }

  Widget _buildComposer() {
    if (_composerReadOnly) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF13132a),
          border: Border(top: BorderSide(color: Color(0xFF1e1e3a))),
        ),
        child: Text(
          '#alerts is view-only in the staff app (same feed as admin).',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color(0xFF6b7280),
            fontSize: 12,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF13132a),
        border: Border(top: BorderSide(color: Color(0xFF1e1e3a))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Message $_activeChannelLabel…',
                hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF374151), fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF0d0d1a),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: Color(0xFF1e1e3a)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: Color(0xFF1e1e3a)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: Color(0xFF7c3aed)),
                ),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: const Color(0xFF7c3aed),
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              onTap: _sending ? null : _send,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRosterColumn() {
    return Container(
      width: 200,
      decoration: const BoxDecoration(
        color: Color(0xFF13132a),
        border: Border(left: BorderSide(color: Color(0xFF1e1e3a))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
            child: Text(
              'Online staff',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Text(
              'Live presence',
              style: GoogleFonts.inter(
                color: const Color(0xFF6b7280),
                fontSize: 11,
              ),
            ),
          ),
          Container(height: 1, color: const Color(0xFF1e1e3a)),
          Expanded(child: _buildRosterListBody()),
        ],
      ),
    );
  }

  Widget _buildRosterListBody() {
    return StreamBuilder<List<PresenceModel>>(
      stream: widget.firestoreService.onlinePresenceStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7c3aed)),
          );
        }
        final list = snap.data ?? const [];
        if (list.isEmpty) {
          return Center(
            child: Text(
              'No staff online.',
              style: GoogleFonts.inter(
                color: const Color(0xFF6b7280),
                fontSize: 12,
              ),
            ),
          );
        }
        final byRole = <String, List<PresenceModel>>{};
        for (final p in list) {
          (byRole[p.role] ??= []).add(p);
        }
        final roles = byRole.keys.toList()..sort();
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
          itemCount: roles.length,
          itemBuilder: (ctx, i) {
            final role = roles[i];
            final people = byRole[role]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 2),
                    child: Text(
                      role.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6b7280),
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  ...people.map((p) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0d0d1a),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF1e1e3a)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: p.state == 'idle'
                                  ? const Color(0xFFfbbf24)
                                  : const Color(0xFF4ade80),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${p.state}${p.department.isNotEmpty ? ' · ${p.department}' : ''} · ${_formatLastSeen(p.lastSeen)}',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF6b7280),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openRosterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0d0d1a),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.75,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Online staff',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Color(0xFF9ca3af)),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: const Color(0xFF1e1e3a)),
                Expanded(child: _buildRosterListBody()),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await widget.firestoreService.sendMessage(
        channel: _activeChannelId,
        senderUid: widget.doctor.uid,
        senderName: widget.doctor.name,
        role: widget.doctor.role,
        text: text,
      );
      _msgCtrl.clear();
      // Scroll to bottom after send
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: const Color(0xFFb91c1c),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _wideBreakpoint;
        final sideW = wide
            ? 220.0
            : (constraints.maxWidth * 0.36).clamp(128.0, 188.0);

        final feed = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCommsHeader(showRosterShortcut: !wide),
            Container(height: 1, color: const Color(0xFF1e1e3a)),
            Expanded(child: _buildMessageList()),
            _buildComposer(),
          ],
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildChannelSidebar(sideW),
              Expanded(child: feed),
              _buildRosterColumn(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildChannelSidebar(sideW),
            Expanded(child: feed),
          ],
        );
      },
    );
  }

  Widget _messageBubble(MessageModel msg, {required bool isMe, required bool showSender}) {
    final tf = DateFormat('h:mm a');
    final isSystem = msg.role == 'HAZARD ALERT' || msg.senderUid.isEmpty;

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF7f1d1d).withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFef4444).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, color: Color(0xFFfca5a5), size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                msg.text,
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFFfca5a5)),
              ),
            ),
            Text(
              tf.format(msg.timestamp),
              style: GoogleFonts.inter(
                  fontSize: 10, color: const Color(0xFF6b7280)),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: showSender ? 8 : 2,
        bottom: 2,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF1e1e3a),
              child: Text(
                msg.senderName.isNotEmpty ? msg.senderName[0].toUpperCase() : '?',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (showSender && !isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3, left: 2),
                    child: Row(
                      children: [
                        Text(
                          msg.senderName,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFa78bfa),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          msg.role,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: const Color(0xFF4b5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color(0xFF4c1d95)
                        : const Color(0xFF1e1e3a),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: isMe
                          ? const Radius.circular(14)
                          : const Radius.circular(4),
                      bottomRight: isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(14),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 2, right: 2),
                  child: Text(
                    tf.format(msg.timestamp),
                    style: GoogleFonts.inter(
                        fontSize: 10, color: const Color(0xFF4b5563)),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 6),
        ],
      ),
    );
  }
}
