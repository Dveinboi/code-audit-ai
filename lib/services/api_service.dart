import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static final _supabase = Supabase.instance.client;

  static Future<List<dynamic>> getHistorySummary() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];
      
      // Fetch all repositories
      final repos = await _supabase.from('repositories').select('*');
      
      List<Map<String, dynamic>> results = [];
      for (var repo in repos) {
        // Fetch latest report for this repo and user
        final reports = await _supabase.from('reports')
            .select('overall_score, created_at')
            .eq('repository_id', repo['id'])
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .limit(1);
            
        if (reports.isNotEmpty) {
          final latestReport = reports.first;
          results.add({
            'repository_id': repo['id'],
            'repo_name': repo['repo_name'] ?? repo['repo_url'] ?? 'Unknown',
            'latest_score': latestReport['overall_score'] ?? 0,
            'analyzed_at': latestReport['created_at'] ?? '',
          });
        }
      }
      
      // Sort by most recently analyzed
      results.sort((a, b) => (b['analyzed_at'] as String).compareTo(a['analyzed_at'] as String));
      return results;
    } catch (e) {
      throw Exception('Error fetching history from Supabase: $e');
    }
  }

  static Future<Map<String, dynamic>> getRepositoryHistory(String repositoryId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');
      
      final repo = await _supabase.from('repositories').select('*').eq('id', repositoryId).single();
      
      final reports = await _supabase.from('reports')
          .select('id, overall_score, score_security, score_quality, score_performance, created_at')
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
}
