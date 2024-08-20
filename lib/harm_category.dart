// Enum for HarmCategory
enum HarmCategory {
  harmCategoryUnspecified,
  harmCategoryHateSpeech,
  harmCategorySexuallyExplicit,
  harmCategoryHarassment,
  harmCategoryDangerousContent
}

// Enum for HarmBlockThreshold
enum HarmBlockThreshold {
  harmBlockThresholdUnspecified,
  blockLowAndAbove,
  blockMediumAndAbove,
  blockOnlyHigh,
  blockNone
}

// Enum for HarmProbability
enum HarmProbability {
  harmProbabilityUnspecified,
  negligible,
  low,
  medium,
  high
}

// SafetySetting class
class SafetySetting {
  final HarmCategory category;
  final HarmBlockThreshold threshold;

  SafetySetting({required this.category, required this.threshold});
}

// SafetyRating class
class SafetyRating {
  final HarmCategory category;
  final HarmProbability probability;

  SafetyRating({required this.category, required this.probability});
}

// BlockReason enum
enum BlockReason {
  blockedReasonUnspecified,
  safety,
  other
}

// PromptFeedback class
class PromptFeedback {
  final BlockReason blockReason;
  final List<SafetyRating> safetyRatings;
  final String? blockReasonMessage;

  PromptFeedback({
    required this.blockReason,
    required this.safetyRatings,
    this.blockReasonMessage,
  });
}