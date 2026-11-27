import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final _supabase = Supabase.instance.client;

  static Future<List<dynamic>> getHistorySummary() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];
      
      final response = await _supabase.rpc('get_user_repository_history', params: {'p_user_id': userId});
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error fetching history from Supabase: $e');
    }
  }

  static Future<void> toggleFavorite(String repositoryId, bool isFavorite) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      if (isFavorite) {
        await _supabase.from('user_favorites').upsert({
          'user_id': userId,
          'repository_id': repositoryId,
        });
      } else {
        await _supabase.from('user_favorites').delete()
            .eq('user_id', userId)
            .eq('repository_id', repositoryId);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }


  static Future<String> startAnalysis(
    String repoUrl, {
    bool security = true,
    bool quality = true,
    bool performance = true,
    bool maintainability = true,
    bool dependencies = true,
    String? branch,
  }) async {
    final session = Supabase.instance.client.auth.currentSession;
    String? githubToken = session?.providerToken;
    
    if (githubToken == null) {
      final prefs = await SharedPreferences.getInstance();
      githubToken = prefs.getString('github_provider_token');
    }

    String? userId = session?.user.id;
    final supabaseToken = session?.accessToken;

    if (userId == null) {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('guest_user_id');
      if (userId == null) {
        userId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('guest_user_id', userId);
      }
    }

    // Use dotenv for the backend URL
    final baseUrl = dotenv.env['API_BASE_URL']?.replaceAll(RegExp(r'\s+'), '');
    if (baseUrl == null) throw Exception('API_BASE_URL not found in .env');
    final backendUrl = '$baseUrl/api/analyze'; 

    final response = await http.post(
      Uri.parse(backendUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'repo_url': repoUrl,
        'github_token': githubToken,
        'user_id': userId,
        'supabase_token': supabaseToken,
        'is_private': true, 
        'security': security,
        'quality': quality,
        'performance': performance,
        'maintainability': maintainability,
        'dependencies': dependencies,
        if (branch != null && branch.isNotEmpty) 'branch': branch,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final jobId = data['job_id'];
      
      if (session?.user.id == null) {
        final prefs = await SharedPreferences.getInstance();
        List<String> guestJobs = prefs.getStringList('guest_job_ids') ?? [];
        guestJobs.add(jobId);
        await prefs.setStringList('guest_job_ids', guestJobs);
      }
      
      return jobId;
    } else {
      // Show the server's human-readable message (e.g. "Only public websites can be checked").
      String message = response.body;
      try {
        message = jsonDecode(response.body)['detail']?.toString() ?? message;
      } catch (_) {}
      throw Exception(message);
    }
  }

  /// Branch names of a repository, default branch first (for the branch picker).
  static Future<List<String>> getBranches(String repoUrl) async {
    final session = Supabase.instance.client.auth.currentSession;
    String? githubToken = session?.providerToken;
    if (githubToken == null) {
      final prefs = await SharedPreferences.getInstance();
      githubToken = prefs.getString('github_provider_token');
    }

    final baseUrl = dotenv.env['API_BASE_URL']?.replaceAll(RegExp(r'\s+'), '');
    if (baseUrl == null) throw Exception('API_BASE_URL not found in .env');

    final response = await http
        .post(
          Uri.parse('$baseUrl/api/branches'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'repo_url': repoUrl, 'github_token': githubToken}),
        )
        .timeout(const Duration(seconds: 30));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return List<String>.from((data['branches'] as List).map((b) => b.toString()));
    }
    throw Exception(data['detail']?.toString() ?? 'Could not load branches.');
  }

  static Future<Map<String, dynamic>?> getReportByJobId(String jobId) async {
    final baseUrl = dotenv.env['API_BASE_URL']?.replaceAll(RegExp(r'\s+'), '');
    if (baseUrl == null) throw Exception('API_BASE_URL not found in .env');
    final backendUrl = '$baseUrl/api/report/$jobId';
    try {
      final response = await http.get(Uri.parse(backendUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching report from backend: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>> getRepositoryHistory(String repositoryId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');
      
      final repo = await _supabase.from('repositories').select('*').eq('id', repositoryId).single();
      
      final reports = await _supabase.from('reports')
          .select('id, job_id, overall_score, score_security, score_quality, score_performance, created_at')
          .eq('repository_id', repositoryId)
          .eq('user_id', userId)
          .order('created_at', ascending: true);
          
      return {
        'repository_id': repo['id'],
        'repo_name': repo['repo_name'] ?? repo['repo_url'] ?? 'Unknown',
        'reports': reports,
      };
    } catch (e) {
      throw Exception('Error fetching repository history: $e');
    }
  }

  static Future<void> deleteRepository(dynamic repositoryId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');
      
      await _supabase.from('reports')
          .delete()
          .eq('repository_id', repositoryId)
          .eq('user_id', userId);
          
    } catch (e) {
      throw Exception('Error deleting repository history: $e');
    }
  }

  static Future<void> deleteReport(dynamic reportId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');
      
      final res = await _supabase.from('reports')
          .delete()
          .eq('id', reportId)
          .eq('user_id', userId)
          .select();
          
      if (res.isEmpty) {
        throw Exception('Deletion blocked by database permissions or report not found.');
      }
    } catch (e) {
      throw Exception('Error deleting report: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getChatHistory(String jobId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');
      
      final history = await _supabase.from('ai_chats')
          .select('role, message, created_at')
          .eq('job_id', jobId)
          .eq('user_id', userId)
          .order('created_at', ascending: true);
          
      return List<Map<String, dynamic>>.from(history);
    } catch (e) {
      throw Exception('Error fetching chat history: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getChatSessions() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // 1. Get all chats for user to find unique job_ids
      final chats = await _supabase.from('ai_chats')
          .select('job_id, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final uniqueJobs = <String, DateTime>{};
      for (var chat in chats) {
        final j = chat['job_id'];
        if (j != null && !uniqueJobs.containsKey(j)) {
          uniqueJobs[j] = DateTime.parse(chat['created_at']);
        }
      }

      if (uniqueJobs.isEmpty) return [];

      // 2. Get all reports for user to map job_id -> repository_id
      final reports = await _supabase.from('reports')
          .select('job_id, repository_id')
          .eq('user_id', userId);

      final jobToRepoId = <String, String>{};
      for (var r in reports) {
        if (r['job_id'] != null && r['repository_id'] != null) {
          jobToRepoId[r['job_id']] = r['repository_id'];
        }
      }

      // 3. Get all repos to map repository_id -> repo_name
      final repos = await _supabase.from('repositories')
          .select('id, repo_name');

      final repoIdToName = <String, String>{};
      for (var r in repos) {
        repoIdToName[r['id']] = r['repo_name'];
      }

      // 4. Assemble the final list
      List<Map<String, dynamic>> sessions = [];
      for (var entry in uniqueJobs.entries) {
        final jobId = entry.key;
        final repoId = jobToRepoId[jobId];
        final repoName = repoId != null ? (repoIdToName[repoId] ?? 'Unknown Repo') : 'Unknown Repo';

        sessions.add({
          'job_id': jobId,
          'repo_name': repoName,
          'last_active': entry.value,
        });
      }

      return sessions;
    } catch (e) {
      print('Error fetching chat sessions: $e');
      return [];
    }
  }

  static Future<void> linkGuestAccount(String guestId, String realUserId) async {
    final baseUrl = dotenv.env['API_BASE_URL']?.replaceAll(RegExp(r'\s+'), '');
    if (baseUrl == null) throw Exception('API_BASE_URL not found in .env');
    final backendUrl = '$baseUrl/api/link-guest';
    
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> guestJobs = prefs.getStringList('guest_job_ids') ?? [];
      
      if (guestJobs.isEmpty) return; // Nothing to link

      await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'guest_id': guestId,
          'real_user_id': realUserId,
          'job_ids': guestJobs,
        }),
      );
      
      await prefs.remove('guest_job_ids');
    } catch (e) {
      print('Failed to link guest account: $e');
    }
  }

  static Stream<String> askAIStream(String jobId, String userMessage) async* {
    final session = Supabase.instance.client.auth.currentSession;
    final userId = session?.user.id;
    final supabaseToken = session?.accessToken;

    if (userId == null || supabaseToken == null) {
      yield 'Error: User authentication not found. Please log in again.';
      return;
    }

    final baseUrl = dotenv.env['API_BASE_URL']?.replaceAll(RegExp(r'\s+'), '');
    if (baseUrl == null) throw Exception('API_BASE_URL not found in .env');
    final backendUrl = '$baseUrl/api/ai/chat'; 
    
    final client = http.Client();
    final request = http.Request('POST', Uri.parse(backendUrl))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'job_id': jobId,
        'message': userMessage,
        'user_id': userId,
        'supabase_token': supabaseToken,
      });

    try {
      final response = await client.send(request);
      
      if (response.statusCode != 200) {
        final errorString = await response.stream.bytesToString();
        yield 'Error: Failed to get AI response: $errorString';
        return;
      }
      
      await for (var chunk in response.stream.transform(utf8.decoder)) {
        yield chunk;
      }
    } catch (e) {
      yield 'Error asking AI: $e';
    } finally {
      client.close();
    }
  }
}
