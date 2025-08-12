class CareerProfile {
  final String userId;
  final List<String> skills;
  final List<String> interests;
  final String experienceLevel;
  final List<String> preferredIndustries;
  final List<String> preferredLocations;
  final SalaryRange salaryExpectations;
  final Map<String, double> skillProficiency;
  final List<CareerGoal> careerGoals;
  final DateTime lastUpdated;

  CareerProfile({
    required this.userId,
    required this.skills,
    required this.interests,
    required this.experienceLevel,
    required this.preferredIndustries,
    required this.preferredLocations,
    required this.salaryExpectations,
    required this.skillProficiency,
    required this.careerGoals,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'skills': skills,
      'interests': interests,
      'experienceLevel': experienceLevel,
      'preferredIndustries': preferredIndustries,
      'preferredLocations': preferredLocations,
      'salaryExpectations': salaryExpectations.toJson(),
      'skillProficiency': skillProficiency,
      'careerGoals': careerGoals.map((g) => g.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory CareerProfile.fromJson(Map<String, dynamic> json) {
    return CareerProfile(
      userId: json['userId'],
      skills: List<String>.from(json['skills']),
      interests: List<String>.from(json['interests']),
      experienceLevel: json['experienceLevel'],
      preferredIndustries: List<String>.from(json['preferredIndustries']),
      preferredLocations: List<String>.from(json['preferredLocations']),
      salaryExpectations: SalaryRange.fromJson(json['salaryExpectations']),
      skillProficiency: Map<String, double>.from(json['skillProficiency']),
      careerGoals: (json['careerGoals'] as List)
          .map((g) => CareerGoal.fromJson(g))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

class SalaryRange {
  final double minimum;
  final double maximum;
  final String currency;

  SalaryRange({
    required this.minimum,
    required this.maximum,
    required this.currency,
  });

  factory SalaryRange.fromJson(Map<String, dynamic> json) {
    return SalaryRange(
      minimum: json['minimum'].toDouble(),
      maximum: json['maximum'].toDouble(),
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minimum': minimum,
      'maximum': maximum,
      'currency': currency,
    };
  }
}

class CareerGoal {
  final String id;
  final String title;
  final String description;
  final String targetRole;
  final String targetIndustry;
  final DateTime targetDate;
  final List<String> requiredSkills;
  final double progress;
  final bool isCompleted;

  CareerGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetRole,
    required this.targetIndustry,
    required this.targetDate,
    required this.requiredSkills,
    required this.progress,
    required this.isCompleted,
  });

  factory CareerGoal.fromJson(Map<String, dynamic> json) {
    return CareerGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetRole: json['targetRole'],
      targetIndustry: json['targetIndustry'],
      targetDate: DateTime.parse(json['targetDate']),
      requiredSkills: List<String>.from(json['requiredSkills']),
      progress: json['progress'].toDouble(),
      isCompleted: json['isCompleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetRole': targetRole,
      'targetIndustry': targetIndustry,
      'targetDate': targetDate.toIso8601String(),
      'requiredSkills': requiredSkills,
      'progress': progress,
      'isCompleted': isCompleted,
    };
  }
}

class JobMarketData {
  final String position;
  final String industry;
  final double averageSalary;
  final int demandScore;
  final List<String> requiredSkills;
  final double growthProjection;
  final int competitionLevel;
  final DateTime dataDate;

  JobMarketData({
    required this.position,
    required this.industry,
    required this.averageSalary,
    required this.demandScore,
    required this.requiredSkills,
    required this.growthProjection,
    required this.competitionLevel,
    required this.dataDate,
  });

  factory JobMarketData.fromJson(Map<String, dynamic> json) {
    return JobMarketData(
      position: json['position'],
      industry: json['industry'],
      averageSalary: json['averageSalary'].toDouble(),
      demandScore: json['demandScore'],
      requiredSkills: List<String>.from(json['requiredSkills']),
      growthProjection: json['growthProjection'].toDouble(),
      competitionLevel: json['competitionLevel'],
      dataDate: DateTime.parse(json['dataDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'industry': industry,
      'averageSalary': averageSalary,
      'demandScore': demandScore,
      'requiredSkills': requiredSkills,
      'growthProjection': growthProjection,
      'competitionLevel': competitionLevel,
      'dataDate': dataDate.toIso8601String(),
    };
  }
}

class ApplicationInsight {
  final String applicationId;
  final double successProbability;
  final List<String> strengthFactors;
  final List<String> improvementAreas;
  final Map<String, double> skillGaps;
  final String recommendedAction;
  final DateTime analyzedAt;

  ApplicationInsight({
    required this.applicationId,
    required this.successProbability,
    required this.strengthFactors,
    required this.improvementAreas,
    required this.skillGaps,
    required this.recommendedAction,
    required this.analyzedAt,
  });

  factory ApplicationInsight.fromJson(Map<String, dynamic> json) {
    return ApplicationInsight(
      applicationId: json['applicationId'],
      successProbability: json['successProbability'].toDouble(),
      strengthFactors: List<String>.from(json['strengthFactors']),
      improvementAreas: List<String>.from(json['improvementAreas']),
      skillGaps: Map<String, double>.from(json['skillGaps']),
      recommendedAction: json['recommendedAction'],
      analyzedAt: DateTime.parse(json['analyzedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'successProbability': successProbability,
      'strengthFactors': strengthFactors,
      'improvementAreas': improvementAreas,
      'skillGaps': skillGaps,
      'recommendedAction': recommendedAction,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }
}

class ApplicationPattern {
  final double applicationFrequency;
  final double successRate;
  final Map<String, int> optimalTiming;
  final Map<String, double> industryPerformance;
  final Map<String, double> positionLevelAnalysis;
  final Map<String, int> geographicPreferences;

  ApplicationPattern({
    required this.applicationFrequency,
    required this.successRate,
    required this.optimalTiming,
    required this.industryPerformance,
    required this.positionLevelAnalysis,
    required this.geographicPreferences,
  });

  factory ApplicationPattern.fromJson(Map<String, dynamic> json) {
    return ApplicationPattern(
      applicationFrequency: json['applicationFrequency'].toDouble(),
      successRate: json['successRate'].toDouble(),
      optimalTiming: Map<String, int>.from(json['optimalTiming']),
      industryPerformance:
          Map<String, double>.from(json['industryPerformance']),
      positionLevelAnalysis:
          Map<String, double>.from(json['positionLevelAnalysis']),
      geographicPreferences:
          Map<String, int>.from(json['geographicPreferences']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationFrequency': applicationFrequency,
      'successRate': successRate,
      'optimalTiming': optimalTiming,
      'industryPerformance': industryPerformance,
      'positionLevelAnalysis': positionLevelAnalysis,
      'geographicPreferences': geographicPreferences,
    };
  }
}

class JobMarketInsights {
  final Map<String, double> demandTrends;
  final Map<String, double> salaryTrends;
  final Map<String, double> skillDemand;
  final List<String> emergingRoles;
  final Map<String, double> competitionAnalysis;

  JobMarketInsights({
    required this.demandTrends,
    required this.salaryTrends,
    required this.skillDemand,
    required this.emergingRoles,
    required this.competitionAnalysis,
  });

  factory JobMarketInsights.fromJson(Map<String, dynamic> json) {
    return JobMarketInsights(
      demandTrends: Map<String, double>.from(json['demandTrends']),
      salaryTrends: Map<String, double>.from(json['salaryTrends']),
      skillDemand: Map<String, double>.from(json['skillDemand']),
      emergingRoles: List<String>.from(json['emergingRoles']),
      competitionAnalysis:
          Map<String, double>.from(json['competitionAnalysis']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'demandTrends': demandTrends,
      'salaryTrends': salaryTrends,
      'skillDemand': skillDemand,
      'emergingRoles': emergingRoles,
      'competitionAnalysis': competitionAnalysis,
    };
  }
}

class ActionableRecommendation {
  final String id;
  final String title;
  final String description;
  final String category;
  final int priority;
  final DateTime dueDate;
  final List<String> actionSteps;
  final double impactScore;
  final Map<String, String> resources;

  ActionableRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.dueDate,
    required this.actionSteps,
    required this.impactScore,
    required this.resources,
  });

  factory ActionableRecommendation.fromJson(Map<String, dynamic> json) {
    return ActionableRecommendation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      priority: json['priority'],
      dueDate: DateTime.parse(json['dueDate']),
      actionSteps: List<String>.from(json['actionSteps']),
      impactScore: json['impactScore'].toDouble(),
      resources: Map<String, String>.from(json['resources']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'dueDate': dueDate.toIso8601String(),
      'actionSteps': actionSteps,
      'impactScore': impactScore,
      'resources': resources,
    };
  }
}

class CareerInsights {
  final Map<String, double> successPredictions;
  final JobMarketInsights marketAnalysis;
  final List<ActionableRecommendation> personalizedRecommendations;
  final List<String> nextBestActions;
  final DateTime generatedAt;

  CareerInsights({
    required this.successPredictions,
    required this.marketAnalysis,
    required this.personalizedRecommendations,
    required this.nextBestActions,
    required this.generatedAt,
  });

  factory CareerInsights.fromJson(Map<String, dynamic> json) {
    return CareerInsights(
      successPredictions: Map<String, double>.from(json['successPredictions']),
      marketAnalysis: JobMarketInsights.fromJson(json['marketAnalysis']),
      personalizedRecommendations: (json['personalizedRecommendations'] as List)
          .map((r) => ActionableRecommendation.fromJson(r))
          .toList(),
      nextBestActions: List<String>.from(json['nextBestActions']),
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'successPredictions': successPredictions,
      'marketAnalysis': marketAnalysis.toJson(),
      'personalizedRecommendations':
          personalizedRecommendations.map((r) => r.toJson()).toList(),
      'nextBestActions': nextBestActions,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

// Analysis engines
class ApplicationPatternAnalyzer {
  static ApplicationPattern analyzeUserPattern(
      List<dynamic> applications, CareerProfile profile) {
    // Mock implementation - in real app, this would analyze actual application data
    return ApplicationPattern(
      applicationFrequency: 2.5, // applications per week
      successRate: 0.12, // 12% success rate
      optimalTiming: {
        'Tuesday': 3,
        'Wednesday': 4,
        'Thursday': 3,
      },
      industryPerformance: {
        'Technology': 0.15,
        'Finance': 0.10,
        'Healthcare': 0.08,
      },
      positionLevelAnalysis: {
        'Entry': 0.20,
        'Mid': 0.12,
        'Senior': 0.08,
      },
      geographicPreferences: {
        'Remote': 5,
        'On-site': 3,
        'Hybrid': 4,
      },
    );
  }
}

class SuccessPredictionModel {
  static Future<Map<String, double>> predictApplicationSuccess(
      List<dynamic> applications,
      CareerProfile profile,
      JobMarketInsights marketData) async {
    // Mock prediction model - in real app, this would use ML algorithms
    return {
      'nextApplication': 0.15,
      'next30Days': 0.45,
      'currentQuarter': 0.78,
      'skillMatchScore': 0.82,
      'marketDemandScore': 0.65,
    };
  }
}

// Mock mood entry class for mood analysis
class MoodEntry {
  final String id;
  final String userId;
  final double moodLevel;
  final DateTime timestamp;
  final String? notes;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.moodLevel,
    required this.timestamp,
    this.notes,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'],
      userId: json['userId'],
      moodLevel: json['moodLevel'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'moodLevel': moodLevel,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }
}
