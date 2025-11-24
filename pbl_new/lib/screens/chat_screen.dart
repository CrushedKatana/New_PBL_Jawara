import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Pesan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: Text('Silakan login terlebih dahulu'))
          : _buildDummyChatList(),
    );
  }

  Widget _buildDummyChatList() {
    final dummyChats = [
      {
        'name': 'Ibu Siti',
        'message': 'Baik, saya tunggu ya',
        'time': '10:30',
        'unread': 2,
        'avatar': 'IS',
        'verified': true,
      },
      {
        'name': 'Pak Budi',
        'message': 'Harga masih bisa nego?',
        'time': '09:15',
        'unread': 0,
        'avatar': 'PB',
        'verified': true,
      },
      {
        'name': 'Dimas',
        'message': 'Foto lengkapnya ada?',
        'time': 'Kemarin',
        'unread': 1,
        'avatar': 'D',
        'verified': false,
      },
      {
        'name': 'Toko Sepatu Jaya',
        'message': 'Terima kasih sudah belanja',
        'time': '2 hari lalu',
        'unread': 0,
        'avatar': 'TSJ',
        'verified': true,
      },
    ];

    return ListView.builder(
      itemCount: dummyChats.length,
      itemBuilder: (context, index) {
        final chat = dummyChats[index];
        final hasUnread = (chat['unread'] as int) > 0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2D3FE3),
              child: Text(
                chat['avatar'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    chat['name'] as String,
                    style: TextStyle(
                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (chat['verified'] == true) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified,
                    size: 16,
                    color: Color(0xFF2D3FE3),
                  ),
                ],
                const Spacer(),
                Text(
                  chat['time'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: hasUnread ? const Color(0xFF2D3FE3) : Colors.grey,
                    fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    chat['message'] as String,
                    style: TextStyle(
                      color: hasUnread ? Colors.black87 : Colors.grey,
                      fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasUnread)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D3FE3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${chat['unread']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () {
              // Navigate to chat detail with dummy messages
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _ChatDetailDemoScreen(
                    userName: chat['name'] as String,
                    userAvatar: chat['avatar'] as String,
                    isVerified: chat['verified'] as bool,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Chat Detail Demo Screen
class _ChatDetailDemoScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;
  final bool isVerified;

  const _ChatDetailDemoScreen({
    required this.userName,
    required this.userAvatar,
    required this.isVerified,
  });

  @override
  State<_ChatDetailDemoScreen> createState() => _ChatDetailDemoScreenState();
}

class _ChatDetailDemoScreenState extends State<_ChatDetailDemoScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _dummyMessages = [];

  @override
  void initState() {
    super.initState();
    _loadDummyMessages();
  }

  void _loadDummyMessages() {
    // Load dummy messages based on user
    if (widget.userName == 'Ibu Siti') {
      _dummyMessages.addAll([
        {'text': 'Halo, masih tersedia kah?', 'isMe': false, 'time': '09:00'},
        {'text': 'Halo! Iya masih ada kok', 'isMe': true, 'time': '09:02'},
        {'text': 'Boleh minta foto detail nya?', 'isMe': false, 'time': '09:05'},
        {'text': 'Baik, nanti saya kirim ya', 'isMe': true, 'time': '09:06'},
        {'text': 'Bisa COD di area RT 05 kan?', 'isMe': false, 'time': '10:15'},
        {'text': 'Bisa dong, kebetulan satu RT', 'isMe': true, 'time': '10:20'},
        {'text': 'Baik, saya tunggu ya', 'isMe': false, 'time': '10:30'},
      ]);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3FE3),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Text(
                widget.userAvatar,
                style: const TextStyle(
                  color: Color(0xFF2D3FE3),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.userName,
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 16),
                      ],
                    ],
                  ),
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _dummyMessages.length,
                itemBuilder: (context, index) {
                  final message = _dummyMessages[index];
                  final isMe = message['isMe'] as bool;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment:
                          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (isMe) const Spacer(flex: 2),
                        Flexible(
                          flex: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? const Color(0xFF2D3FE3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['text'] as String,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message['time'] as String,
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white70
                                        : Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!isMe) const Spacer(flex: 2),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {},
                  color: Colors.grey,
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () {},
                  color: Colors.grey,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D3FE3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_messageController.text.trim().isNotEmpty) {
                        setState(() {
                          _dummyMessages.add({
                            'text': _messageController.text,
                            'isMe': true,
                            'time': TimeOfDay.now().format(context),
                          });
                        });
                        _messageController.clear();
                      }
                    },
                    color: Colors.white,
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
