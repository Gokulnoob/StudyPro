import 'dart:developer';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/career_models.dart';
import '../models/job_application.dart';
import '../models/mood_entry.dart' as mood_model;
import '../config/ai_config.dart';

class AICareerAssistant {
  static GenerativeModel? _model;

  // Initialize Gemini AI
  static void initialize() {
    try {
      if (AIConfig.geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE') {
        _model = GenerativeModel(
          model: AIConfig.modelName,
          apiKey: AIConfig.geminiApiKey,
          generationConfig: GenerationConfig(
            temperature: AIConfig.temperature,
            maxOutputTokens: AIConfig.maxTokens,
          ),
        );
        log('Gemini AI Career Assistant initialized');
      } else {
        log('Warning: Please set your Gemini API key in ai_config.dart');
      }
    } catch (e) {
      log('Warning: Gemini AI not initialized - $e');
    }
  }

  // Main method to generate comprehensive career insights using Gemini AI
  static Future<CareerInsights> generateInsights(String userId) async {
    try {
      log('Generating AI-powered career insights for user: $userId');
      
      if (_model == null) {
        log('Gemini AI not available, using fallback data');
        return _getFallbackInsights(userId);
      }

      // Create comprehensive prompt for career insights
      final prompt = _buildCareerInsightPrompt(userId);
      
      // Generate insights using Gemini
      final response = await _model!.generateContent([Content.text(prompt)]);
      
      if (response.text != null) {
        final insights = _parseAIResponse(response.text!);
        return insights;
      } else {
        log('Empty response from Gemini AI');
        return _getFallbackInsights(userId);
      }
      
    } catch (e) {
      log('Error generating AI career insights: $e');
      return _getFallbackInsights(userId);
    }
  }

  // Generate AI-powered career recommendations
  static Future<List<ActionableRecommendation>> generateRecommendations(
    List<JobApplication> applications,
    Map<String, dynamic> userProfile,
  ) async {
    try {
      if (_model == null) {
        return _getFallbackRecommendations();
      }

      final prompt = _buildRecommendationPrompt(applications, userProfile);
      final response = await _model!.generateContent([Content.text(prompt)]);
      
      if (response.text != null) {
        return _parseRecommendations(response.text!);
      }
      
      return _getFallbackRecommendations();
    } catch (e) {
      log('Error generating AI recommendations: $e');
      return _getFallbackRecommendations();
    }
  }

  // Analyze application patterns with AI
  static Future<Map<String, dynamic>> analyzeApplicationPattern(
    List<JobApplication> applications,
  ) async {
    try {
      if (_model == null || applications.isEmpty) {
        return _getFallbackAnalysis(applications);
      }

      final prompt = _buildAnalysisPrompt(applications);
      final response = await _model!.generateContent([Content.text(prompt)]);
      
      if (response.text != null) {
        return _parseAnalysisResponse(response.text!, applications);
      }
      
      return _getFallbackAnalysis(applications);
    } catch (e) {
      log('Error analyzing application pattern: $e');
      return _getFallbackAnalysis(applications);
    }
  }

  // AI-powered mood correlation analysis
  static Future<Map<String, dynamic>> analyzeMoodProductivityCorrelation(
    List<mood_model.MoodEntry> moodEntries,
    List<JobApplication> applications,
  ) async {
    try {
      if (_model == null || moodEntries.isEmpty) {
        return _getFallbackMoodAnalysis(moodEntries);
      }

      final prompt = _buildMoodAnalysisPrompt(moodEntries, applications);
      final response = await _model!.generateContent([Content.text(prompt)]);
      
      if (response.text != null) {
        return _parseMoodAnalysisResponse(response.text!);
      }
      
      return _getFallbackMoodAnalysis(moodEntries);
    } catch (e) {
      log('Error analyzing mood productivity correlation: $e');
      return _getFallbackMoodAnalysis(moodEntries);
    }
  }

  // Build comprehensive career insight prompt
  static String _buildCareerInsightPrompt(String userId) {
    return '''
As an AI career advisor, provide comprehensive career insights for a job seeker. 
Analyze current job market trends and provide actionable advice.

Please provide insights in the following areas:
1. Success predictions for job applications (provide percentages for nextApplication, skillMatchScore, currentQuarter, marketDemandScore, next30Days)
2. Current job market analysis including demand trends, salary trends, skill demand, emerging roles
3. Personalized recommendations with specific action steps
4. Next best actions for career advancement

Focus on practical, actionable advice that can improve job search success.
Provide specific percentages and data-driven insights.
''';
  }

  // Build recommendation prompt
  static String _buildRecommendationPrompt(
    List<JobApplication> applications,
    Map<String, dynamic> userProfile,
  ) {
    final appSummary = applications.isEmpty 
        ? "No applications yet" 
        : "Applied to ${applications.length} positions, status breakdown: ${_getStatusBreakdown(applications)}";
    
    return '''
Based on the following job application data and user profile, provide 3-5 specific, actionable career recommendations:

Application Summary: $appSummary
User Profile: $userProfile

For each recommendation, provide:
- A clear title
- Detailed description
- Category (e.g., "Skill Building", "Profile Enhancement", "Networking")
- Priority level (1-5)
- Specific action steps
- Impact score (0.0-1.0)
- Helpful resources

Focus on recommendations that will improve job search success rate and career growth.
''';
  }

  // Build analysis prompt
  static String _buildAnalysisPrompt(List<JobApplication> applications) {
    final appData = applications.map((app) => 
      "${app.company} - ${app.position} - ${app.status} - ${app.applicationDate}"
    ).join(", ");
    
    return '''
Analyze the following job application pattern and provide insights:

Applications: $appData

Provide analysis on:
1. Response rate and success patterns
2. Best performing companies/industries
3. Optimal timing for applications
4. Specific suggestions for improvement
5. Average response time analysis

Return actionable insights that can improve future application success.
''';
  }

  // Build mood analysis prompt
  static String _buildMoodAnalysisPrompt(
    List<mood_model.MoodEntry> moodEntries,
    List<JobApplication> applications,
  ) {
    final moodSummary = moodEntries.isEmpty 
        ? "No mood data available"
        : "Average mood: ${_calculateAverageMood(moodEntries).toStringAsFixed(1)}/5.0";
    
    return '''
Analyze the correlation between mood patterns and job application productivity:

Mood Data: $moodSummary
Application Activity: ${applications.length} total applications

Provide insights on:
1. Optimal mood ranges for job applications
2. Productivity tips based on mood patterns
3. Best times to apply based on mood/energy levels
4. Strategies for maintaining motivation during job search

Focus on actionable advice for optimizing job search based on mental well-being.
''';
  }

  // Parse AI response and create CareerInsights object
  static CareerInsights _parseAIResponse(String aiResponse) {
    // For now, create structured insights with AI-enhanced mock data
    // In a full implementation, you'd parse the AI response more sophisticatedly
    
    final marketInsights = JobMarketInsights(
      demandTrends: {
        'Software Development': 0.85,
        'Data Science': 0.92,
        'AI/ML Engineering': 0.88,
        'DevOps': 0.79
      },
      salaryTrends: {
        'Software Development': 0.75,
        'Data Science': 0.88,
        'AI/ML Engineering': 0.85,
        'DevOps': 0.72
      },
      skillDemand: {
        'Flutter': 0.78,
        'Python': 0.85,
        'Machine Learning': 0.90,
        'Cloud Computing': 0.82
      },
      emergingRoles: [
        'AI Engineer',
        'Flutter Developer',
        'DevOps Engineer',
        'Data Scientist'
      ],
      competitionAnalysis: {
        'Entry Level': 0.65,
        'Mid Level': 0.45,
        'Senior Level': 0.25
      },
    );

    final recommendations = [
      ActionableRecommendation(
        id: 'ai-rec-1',
        title: 'AI-Enhanced Profile Optimization',
        description: 'Leverage AI insights to optimize your professional profile and increase visibility to recruiters',
        category: 'Profile Enhancement',
        priority: 1,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        actionSteps: [
          'Optimize LinkedIn with AI-suggested keywords',
          'Update GitHub portfolio with trending technologies',
          'Create a compelling elevator pitch',
          'Add quantifiable achievements to resume'
        ],
        impactScore: 0.85,
        resources: {
          'LinkedIn Optimization': 'https://linkedin.com',
          'GitHub Best Practices': 'https://github.com',
          'Resume Templates': 'https://resume.io'
        },
      ),
      ActionableRecommendation(
        id: 'ai-rec-2',
        title: 'Strategic Skill Development',
        description: 'Focus on high-demand skills identified through AI market analysis',
        category: 'Skill Building',
        priority: 2,
        dueDate: DateTime.now().add(const Duration(days: 30)),
        actionSteps: [
          'Complete Flutter advanced course',
          'Build AI/ML portfolio projects',
          'Get cloud computing certifications',
          'Contribute to open source projects'
        ],
        impactScore: 0.90,
        resources: {
          'Flutter Courses': 'https://flutter.dev/learn',
          'AI/ML Learning': 'https://coursera.org',
          'Cloud Certifications': 'https://aws.amazon.com/certification'
        },
      ),
    ];

    return CareerInsights(
      successPredictions: {
        'Interview Success': 0.78,
        'Job Offer': 0.52,
        'Salary Negotiation': 0.68,
        'nextApplication': 0.75,
        'skillMatchScore': 0.88,
        'currentQuarter': 0.71,
        'marketDemandScore': 0.82,
        'next30Days': 0.77,
      },
      marketAnalysis: marketInsights,
      personalizedRecommendations: recommendations,
      nextBestActions: [
        'Apply AI insights to optimize your job search strategy',
        'Focus on emerging technologies and high-demand skills',
        'Leverage data-driven approaches for better targeting',
        'Build a strong online presence with AI-optimized content'
      ],
      generatedAt: DateTime.now(),
    );
  }

  // Helper methods for parsing and analysis
  static List<ActionableRecommendation> _parseRecommendations(String aiResponse) {
    // Parse AI response into recommendations
    // For now, return AI-enhanced recommendations
    return _getFallbackRecommendations();
  }

  static Map<String, dynamic> _parseAnalysisResponse(String aiResponse, List<JobApplication> applications) {
    return _getFallbackAnalysis(applications);
  }

  static Map<String, dynamic> _parseMoodAnalysisResponse(String aiResponse) {
    return {
      'optimalMoodRange': {'min': 3.5, 'max': 4.5},
      'productivityTips': [
        'AI suggests applying when mood is above 3.5/5.0',
        'Use meditation apps before important applications',
        'Schedule applications during high-energy periods'
      ]
    };
  }

  // Helper methods
  static String _getStatusBreakdown(List<JobApplication> applications) {
    final statusCount = <String, int>{};
    for (final app in applications) {
      statusCount[app.status] = (statusCount[app.status] ?? 0) + 1;
    }
    return statusCount.entries.map((e) => "${e.key}: ${e.value}").join(", ");
  }

  static double _calculateAverageMood(List<mood_model.MoodEntry> moodEntries) {
    if (moodEntries.isEmpty) return 3.0;
    return moodEntries.map((e) => e.moodLevel).reduce((a, b) => a + b) / moodEntries.length;
  }

  // Fallback methods (enhanced with AI context)
  static Map<String, dynamic> _getFallbackAnalysis(List<JobApplication> applications) {
    final responseRate = applications.isEmpty ? 0.0 : applications
            .where((app) => app.status == 'Interview' || app.status == 'Offer')
            .length /
        applications.length;

    return {
      'responseRate': responseRate,
      'averageResponseTime': 7.5,
      'suggestions': _generateApplicationSuggestions(applications),
      'topPerformingCompanies': _getTopPerformingCompanies(applications),
      'optimalApplicationDays': ['Tuesday', 'Wednesday', 'Thursday'],
    };
  }

  static Map<String, dynamic> _getFallbackMoodAnalysis(List<mood_model.MoodEntry> moodEntries) {
    return {
      'optimalMoodRange': {'min': 3.5, 'max': 4.5},
      'productivityTips': _generateMoodBasedTips(moodEntries),
    };
  }

  static List<ActionableRecommendation> _getFallbackRecommendations() {
    return [
      ActionableRecommendation(
        id: 'fallback-1',
        title: 'Enhance Your Professional Profile',
        description: 'Improve your online presence and professional branding',
        category: 'Profile Enhancement',
        priority: 1,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        actionSteps: [
          'Update LinkedIn profile with recent achievements',
          'Add portfolio projects to GitHub',
          'Write compelling professional summary'
        ],
        impactScore: 0.75,
        resources: {'LinkedIn': 'https://linkedin.com'},
      ),
    ];
  }

  static List<String> _generateApplicationSuggestions(List<JobApplication> applications) {
    List<String> suggestions = [];

    if (applications.isEmpty) {
      suggestions.add("🎯 Start applying to jobs that match your skills");
      suggestions.add("📝 Create a compelling resume and cover letter");
      return suggestions;
    }

    final recentApps = applications
        .where((app) => DateTime.parse(app.applicationDate)
            .isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .toList();

    if (recentApps.length < 5) {
      suggestions.add("🎯 AI recommends 3-5 applications per week for optimal results");
    }

    return suggestions;
  }

  static List<String> _getTopPerformingCompanies(List<JobApplication> applications) {
    if (applications.isEmpty) return ['Focus on tech startups', 'Consider remote-first companies'];
    
    final companySuccess = <String, double>{};
    for (final app in applications) {
      final success = app.status == 'Interview' || app.status == 'Offer' ? 1.0 : 0.0;
      companySuccess[app.company] = (companySuccess[app.company] ?? 0.0) + success;
    }

    return companySuccess.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key)
        .take(5)
        .toList();
  }

  static List<String> _generateMoodBasedTips(List<mood_model.MoodEntry> moodEntries) {
    if (moodEntries.isEmpty) {
      return [
        "🧘 AI suggests tracking mood to optimize application timing",
        "💪 Maintain consistent energy levels for better performance"
      ];
    }

    final averageMood = _calculateAverageMood(moodEntries);
    List<String> tips = [];

    if (averageMood < 3.0) {
      tips.add("🧘 AI recommends meditation before job applications");
      tips.add("🏃 Physical exercise can boost application confidence");
    } else if (averageMood > 4.0) {
      tips.add("✨ Your high energy is perfect for networking!");
      tips.add("📞 Great time for follow-up calls and interviews");
    }

    return tips;
  }

  static CareerInsights _getFallbackInsights(String userId) {
    final fallbackMarketInsights = JobMarketInsights(
      demandTrends: {'Technology': 0.80, 'Healthcare': 0.75, 'Finance': 0.65},
      salaryTrends: {'Technology': 0.85, 'Healthcare': 0.70, 'Finance': 0.75},
      skillDemand: {
        'Communication': 0.90,
        'Problem Solving': 0.85,
        'Technical Skills': 0.80
      },
      emergingRoles: ['AI Specialist', 'Remote Work Coordinator', 'Digital Health Expert'],
      competitionAnalysis: {'Entry Level': 0.70, 'Mid Level': 0.50, 'Senior Level': 0.30},
    );

    return CareerInsights(
      successPredictions: {
        'nextApplication': 0.60,
        'skillMatchScore': 0.65,
        'currentQuarter': 0.55,
        'marketDemandScore': 0.70,
        'next30Days': 0.58,
      },
      marketAnalysis: fallbackMarketInsights,
      personalizedRecommendations: _getFallbackRecommendations(),
      nextBestActions: [
        'Set up Gemini AI integration for personalized insights',
        'Update your skills based on market trends',
        'Start networking in your target industry'
      ],
      generatedAt: DateTime.now(),
    );
  }
}
