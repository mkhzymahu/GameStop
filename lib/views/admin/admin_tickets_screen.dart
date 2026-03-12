// lib/views/admin/admin_tickets_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/user_storage_service.dart';
import '../../models/support_ticket_model.dart';
import '../../providers/auth_provider.dart';

class AdminTicketsScreen extends StatefulWidget {
  const AdminTicketsScreen({super.key});

  @override
  State<AdminTicketsScreen> createState() => _AdminTicketsScreenState();
}

class _AdminTicketsScreenState extends State<AdminTicketsScreen> {
  List<SupportTicket> _tickets = [];
  List<SupportTicket> _filtered = [];
  String _search = '';
  String _statusFilter = 'All';
  SupportTicket? _selected;
  final _replyCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  void _load() {
    final tickets = UserStorageService.loadAllTickets();
    setState(() {
      _tickets = tickets;
      _applyFilter();
      // keep selected in sync
      if (_selected != null) {
        _selected = _tickets.firstWhere((t) => t.id == _selected!.id,
            orElse: () => _tickets.isNotEmpty ? _tickets.first : _selected!);
      }
      _loading = false;
    });
  }

  void _applyFilter() {
    _filtered = _tickets.where((t) {
      final matchSearch = _search.isEmpty ||
          t.subject.toLowerCase().contains(_search.toLowerCase()) ||
          t.userName.toLowerCase().contains(_search.toLowerCase());
      final matchStatus = _statusFilter == 'All' ||
          t.status.name.toLowerCase() == _statusFilter.toLowerCase();
      return matchSearch && matchStatus;
    }).toList();
  }

  Future<void> _sendReply(String adminId, String adminName) async {
    if (_selected == null || _replyCtrl.text.trim().isEmpty) return;
    final msg = TicketMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: adminId,
      senderName: adminName,
      isAdmin: true,
      message: _replyCtrl.text.trim(),
      sentAt: DateTime.now(),
    );
    final updatedMessages = [..._selected!.messages, msg];
    final updatedTicket = _selected!.copyWith(
      messages: updatedMessages,
      status: TicketStatus.inProgress,
    );
    final userTickets = UserStorageService.loadTickets(_selected!.userId);
    final updated = userTickets
        .map((t) => t.id == updatedTicket.id ? updatedTicket : t)
        .toList();
    await UserStorageService.saveTickets(_selected!.userId, updated);
    _replyCtrl.clear();
    _load();
  }

  Future<void> _updateTicketStatus(String newStatus) async {
    if (_selected == null) return;
    final statusEnum = TicketStatus.values.firstWhere((s) => s.name == newStatus, orElse: () => TicketStatus.open);
    final updatedTicket = _selected!.copyWith(
      status: statusEnum,
      resolvedAt: statusEnum == TicketStatus.resolved ? DateTime.now() : null,
    );
    final userTickets = UserStorageService.loadTickets(_selected!.userId);
    final updated = userTickets
        .map((t) => t.id == updatedTicket.id ? updatedTicket : t)
        .toList();
    await UserStorageService.saveTickets(_selected!.userId, updated);
    _load();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'open': return const Color(0xFF6C63FF);
      case 'inProgress': return const Color(0xFFFFB347);
      case 'resolved': return const Color(0xFF00BFA5);
      case 'closed': return Colors.white30;
      default: return Colors.white38;
    }
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'urgent': return const Color(0xFFE63946);
      case 'high': return const Color(0xFFFFB347);
      case 'medium': return const Color(0xFF6C63FF);
      default: return Colors.white38;
    }
  }

  String _formatTime(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final adminId = auth.currentUser?.id ?? 'admin';
    final adminName = auth.currentUser?.name ?? 'Admin';

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
            color: Color(0xFF6C63FF), strokeWidth: 2),
      );
    }

    return Container(
      color: const Color(0xFF0A0A0F),
      child: Row(
        children: [
          // ── Left panel: ticket list ──
          SizedBox(
            width: 340,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.white.withOpacity(0.06)),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Support Tickets',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        Text('${_tickets.length} total',
                            style: GoogleFonts.poppins(
                                color: Colors.white30, fontSize: 12)),
                        const SizedBox(height: 12),
                        // Search
                        Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F0F18),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.07)),
                          ),
                          child: TextField(
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Search tickets...',
                              hintStyle: GoogleFonts.poppins(
                                  color: Colors.white24, fontSize: 12),
                              prefixIcon: const Icon(Icons.search,
                                  color: Colors.white24, size: 16),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onChanged: (v) => setState(() {
                              _search = v;
                              _applyFilter();
                            }),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Status filter chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['All', 'open', 'inProgress', 'resolved', 'closed']
                                .map((s) => Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          _statusFilter = s;
                                          _applyFilter();
                                        }),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 150),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: _statusFilter == s
                                                ? _statusColor(s)
                                                    .withOpacity(0.15)
                                                : const Color(0xFF0F0F18),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                              color: _statusFilter == s
                                                  ? _statusColor(s)
                                                      .withOpacity(0.4)
                                                  : Colors.white
                                                      .withOpacity(0.07),
                                            ),
                                          ),
                                          child: Text(
                                            s == 'All'
                                                ? 'All'
                                                : s == 'inProgress'
                                                    ? 'In Progress'
                                                    : s[0].toUpperCase() +
                                                        s.substring(1),
                                            style: GoogleFonts.poppins(
                                              color: _statusFilter == s
                                                  ? _statusColor(s)
                                                  : Colors.white30,
                                              fontSize: 10,
                                              fontWeight: _statusFilter == s
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.white.withOpacity(0.06)),
                  // Ticket list
                  Expanded(
                    child: _filtered.isEmpty
                        ? Center(
                            child: Text('No tickets',
                                style: GoogleFonts.poppins(
                                    color: Colors.white24, fontSize: 13)))
                        : ListView.builder(
                            itemCount: _filtered.length,
                            itemBuilder: (context, i) {
                              final t = _filtered[i];
                              final isSelected = _selected?.id == t.id;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selected = t),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF6C63FF)
                                            .withOpacity(0.08)
                                        : Colors.transparent,
                                    border: Border(
                                      left: BorderSide(
                                        color: isSelected
                                            ? const Color(0xFF6C63FF)
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      bottom: BorderSide(
                                          color:
                                              Colors.white.withOpacity(0.04)),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(t.subject,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: _priorityColor(
                                                  t.priority.name),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(t.userName,
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white38,
                                                  fontSize: 11)),
                                          const Spacer(),
                                          Text(
                                              _formatTime(t.createdAt),
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white24,
                                                  fontSize: 10)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 2),
                                            decoration: BoxDecoration(
                                              color: _statusColor(t.status.name)
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              t.status == TicketStatus.inProgress
                                                  ? 'IN PROGRESS'
                                                  : t.status.name.toUpperCase(),
                                              style: GoogleFonts.poppins(
                                                color:
                                                    _statusColor(t.status.name),
                                                fontSize: 8,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(t.category,
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white24,
                                                  fontSize: 10)),
                                          const Spacer(),
                                          Icon(Icons.chat_bubble_outline,
                                              color: Colors.white24,
                                              size: 12),
                                          const SizedBox(width: 3),
                                          Text(
                                              t.messages.length.toString(),
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white24,
                                                  fontSize: 10)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          // ── Right panel: ticket detail + reply ──
          Expanded(
            child: _selected == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.support_agent_outlined,
                            color: Colors.white12, size: 48),
                        const SizedBox(height: 12),
                        Text('Select a ticket to view',
                            style: GoogleFonts.poppins(
                                color: Colors.white24, fontSize: 14)),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Ticket header
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.white.withOpacity(0.06)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(_selected!.subject,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700)),
                                ),
                                // Status update dropdown
                                PopupMenuButton<String>(
                                  color: const Color(0xFF1A1A2E),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8)),
                                  onSelected: _updateTicketStatus,
                                  itemBuilder: (_) => [
                                    'open',
                                    'inProgress',
                                    'resolved',
                                    'closed'
                                  ]
                                      .map((s) => PopupMenuItem(
                                            value: s,
                                            child: Text(
                                              s == 'inProgress'
                                                  ? 'In Progress'
                                                  : s[0].toUpperCase() +
                                                      s.substring(1),
                                              style: GoogleFonts.poppins(
                                                color: _statusColor(s),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _statusColor(_selected!.status.name)
                                          .withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                      border: Border.all(
                                          color:
                                              _statusColor(_selected!.status.name)
                                                  .withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _selected!.status == TicketStatus.inProgress
                                              ? 'IN PROGRESS'
                                              : _selected!.status.name
                                                  .toUpperCase(),
                                          style: GoogleFonts.poppins(
                                              color: _statusColor(
                                                  _selected!.status.name),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.expand_more,
                                            color: _statusColor(
                                                _selected!.status.name),
                                            size: 14),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text('From: ${_selected!.userName}',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white38,
                                        fontSize: 12)),
                                const SizedBox(width: 16),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color:
                                        _priorityColor(_selected!.priority.name),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                    '${_selected!.priority.name.toUpperCase()} PRIORITY',
                                    style: GoogleFonts.poppins(
                                        color:
                                            _priorityColor(_selected!.priority.name),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(width: 16),
                                Text(_selected!.category,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white24,
                                        fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Messages
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _selected!.messages.length,
                          itemBuilder: (context, i) {
                            final msg = _selected!.messages[i];
                            return _MessageBubble(
                              message: msg,
                              formatTime: _formatTime,
                            );
                          },
                        ),
                      ),

                      // Reply box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0F18),
                          border: Border(
                            top: BorderSide(
                                color: Colors.white.withOpacity(0.06)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF13131F),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color:
                                          Colors.white.withOpacity(0.08)),
                                ),
                                child: TextField(
                                  controller: _replyCtrl,
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 13),
                                  maxLines: 2,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                    hintText: 'Write a reply...',
                                    hintStyle: GoogleFonts.poppins(
                                        color: Colors.white24,
                                        fontSize: 13),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _sendReply(adminId, adminName),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.send_rounded,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final TicketMessage message;
  final String Function(DateTime) formatTime;
  const _MessageBubble({required this.message, required this.formatTime});

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.isAdmin;
    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          crossAxisAlignment:
              isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isAdmin)
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        message.senderName.isNotEmpty
                            ? message.senderName[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                Text(message.senderName,
                    style: GoogleFonts.poppins(
                        color: isAdmin
                            ? const Color(0xFF6C63FF)
                            : Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                if (isAdmin)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text('ADMIN',
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF6C63FF),
                            fontSize: 8,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAdmin
                    ? const Color(0xFF6C63FF).withOpacity(0.12)
                    : const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isAdmin
                      ? const Color(0xFF6C63FF).withOpacity(0.2)
                      : Colors.white.withOpacity(0.06),
                ),
              ),
              child: Text(message.message,
                  style:
                      GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
            ),
            const SizedBox(height: 3),
            Text(formatTime(message.sentAt),
                style: GoogleFonts.poppins(
                    color: Colors.white24, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
