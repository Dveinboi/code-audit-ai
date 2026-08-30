import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../issues/issues_screen.dart';
import '../history/history_screen.dart';

import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({Key? key}) : super(key: key);

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _jobId;

  @override
  void initState() {
    super.initState();
    final data = context.read<ReportProvider>().reportData;
    _jobId = data?['job_id'];
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (_jobId == null) {
      setState(() {
        _isInitializing = false;
        _messages = [
          {'role': 'ai', 'message': 'No repo analyzed. Please select a repository from the dashboard first.'}
        ];
      });
      return;
    }

    setState(() {
      _messages = [
        {'role': 'ai', 'message': 'Hello! I am your code security and quality assistant. I have reviewed the specific issues found in this repository. How can I help you fix them today?'}
      ];
      _isInitializing = false;
    });
  }

  Future<void> _loadChat(String jobId) async {
    Navigator.pop(context); // Close drawer
    setState(() {
      _isInitializing = true;
      _jobId = jobId;
    });
    try {
      final history = await ApiService.getChatHistory(jobId);
      setState(() {
        _messages = history;
        if (_messages.isEmpty) {
          _messages.add({
            'role': 'ai',
            'message': 'Hello! I am your code security and quality assistant. How can I help you today?'
          });
        }
        _isInitializing = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages = [{'role': 'ai', 'message': 'Failed to load chat history. $e'}];
        _isInitializing = false;
      });
    }
  }

  void _showChatHistoryDialog() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _jobId == null) return;

    setState(() {
      _messages.add({'role': 'user', 'message': text});
      // Add empty AI message to stream into
      _messages.add({'role': 'ai', 'message': ''});
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    final aiMessageIndex = _messages.length - 1;
    String fullAiResponse = '';

    try {
      final stream = ApiService.askAIStream(_jobId!, text);
      
      await for (var chunk in stream) {
        if (_isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
        fullAiResponse += chunk;
        setState(() {
          _messages[aiMessageIndex] = {'role': 'ai', 'message': fullAiResponse};
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages[aiMessageIndex] = {'role': 'ai', 'message': fullAiResponse + '\n\nError: $e'};
      });
    } finally {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onBottomNavTapped(int index) {
    if (index == 2) return;
    if (index == 0) {
      Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
      return;
    }
    if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const IssuesScreen()));
      return;
    }
    if (index == 3) {
      Navigator.pushNamed(context, '/select_repo', arguments: true);
      return;
    }
    if (index == 4) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF111111) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
          },
        ),
        title: Text(
          'AI Assistant',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: textColor),
            onPressed: _showChatHistoryDialog,
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: bgColor,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Recents',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
              Divider(color: dividerColor),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: ApiService.getChatSessions(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error', style: TextStyle(color: textColor)));
                    }
                    final sessions = snapshot.data ?? [];
                    if (sessions.isEmpty) {
                      return Center(child: Text('No recent chats', style: TextStyle(color: subtitleColor)));
                    }

                    return ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        return ListTile(
                          title: Text(
                            session['repo_name'],
                            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _loadChat(session['job_id']),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: _isInitializing 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  return _buildChatBubble(msg['message'], isUser, isDark, cardColor, textColor, subtitleColor);
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    const CircularProgressIndicator(color: Color(0xFF10B981)),
                    const SizedBox(width: 16),
                    Text('AI is typing...', style: TextStyle(color: subtitleColor)),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(top: BorderSide(color: borderColor, width: 1.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Ask about fixing the issues...',
                        hintStyle: TextStyle(color: subtitleColor),
                        filled: true,
                        fillColor: cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isLoading ? null : _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: dividerColor, width: 1.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: 2,
          onTap: _onBottomNavTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: bgColor,
          elevation: 0,
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: subtitleColor,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bug_report_outlined),
              activeIcon: Icon(Icons.bug_report),
              label: 'Issues',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome),
              label: 'AI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'New Repo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser, bool isDark, Color cardColor, Color textColor, Color subtitleColor) {
    final RegExp issueRegex = RegExp(r'\[ISSUE:\s*([A-Za-z0-9-]+)\]');
    
    if (isUser || !issueRegex.hasMatch(text)) {
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF10B981) : cardColor,
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
              bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
            ),
            border: isUser ? null : Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isUser ? Colors.white : textColor,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      );
    }
    
    // AI message containing Issue Cards
    List<Widget> bubbleContents = [];
    text.splitMapJoin(
      issueRegex,
      onMatch: (Match match) {
        final issueId = match.group(1);
        bubbleContents.add(
          GestureDetector(
            onTap: () {
              _textController.text = 'How do I fix $issueId?';
              _sendMessage();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bug_report, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Issue: $issueId',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, color: Color(0xFF10B981), size: 14),
                ],
              ),
            ),
          ),
        );
        return '';
      },
      onNonMatch: (String nonMatch) {
        if (nonMatch.trim().isNotEmpty) {
          bubbleContents.add(
            Text(
              nonMatch.trim(),
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          );
        }
        return '';
      },
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: const Radius.circular(0),
          ),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: bubbleContents,
        ),
      ),
    );
  }
}