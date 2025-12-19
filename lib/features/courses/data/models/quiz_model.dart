import '../../domain/entities/quiz_entity.dart';

class QuizModel extends QuizEntity {
  const QuizModel({
    required super.id,
    required super.courseId,
    super.lessonId,
    required super.title,
    super.description,
    super.type,
    super.passingScore,
    super.timeLimitMinutes,
    super.maxAttempts,
    super.shuffleQuestions,
    super.shuffleAnswers,
    super.showCorrectAnswers,
    super.isRequired,
    super.sortOrder,
    required super.createdAt,
    required super.updatedAt,
    super.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      lessonId: json['lesson_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: QuizType.fromString(json['type'] as String? ?? 'lesson'),
      passingScore: json['passing_score'] as int? ?? 70,
      timeLimitMinutes: json['time_limit_minutes'] as int?,
      maxAttempts: json['max_attempts'] as int? ?? 3,
      shuffleQuestions: json['shuffle_questions'] as bool? ?? true,
      shuffleAnswers: json['shuffle_answers'] as bool? ?? true,
      showCorrectAnswers: json['show_correct_answers'] as bool? ?? false,
      isRequired: json['is_required'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestionModel.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'lesson_id': lessonId,
      'title': title,
      'description': description,
      'type': type.value,
      'passing_score': passingScore,
      'time_limit_minutes': timeLimitMinutes,
      'max_attempts': maxAttempts,
      'shuffle_questions': shuffleQuestions,
      'shuffle_answers': shuffleAnswers,
      'show_correct_answers': showCorrectAnswers,
      'is_required': isRequired,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class QuizQuestionModel extends QuizQuestionEntity {
  const QuizQuestionModel({
    required super.id,
    required super.quizId,
    super.questionType,
    required super.questionText,
    super.questionImageUrl,
    super.explanation,
    super.points,
    super.sortOrder,
    required super.createdAt,
    required super.updatedAt,
    super.answers,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String,
      questionType:
          QuestionType.fromString(json['question_type'] as String? ?? 'single'),
      questionText: json['question_text'] as String,
      questionImageUrl: json['question_image_url'] as String?,
      explanation: json['explanation'] as String?,
      points: json['points'] as int? ?? 1,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      answers: (json['answers'] as List<dynamic>?)
              ?.map((a) => QuizAnswerModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'question_type': questionType.value,
      'question_text': questionText,
      'question_image_url': questionImageUrl,
      'explanation': explanation,
      'points': points,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class QuizAnswerModel extends QuizAnswerEntity {
  const QuizAnswerModel({
    required super.id,
    required super.questionId,
    required super.answerText,
    super.isCorrect,
    super.sortOrder,
    required super.createdAt,
  });

  factory QuizAnswerModel.fromJson(Map<String, dynamic> json) {
    return QuizAnswerModel(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      answerText: json['answer_text'] as String,
      isCorrect: json['is_correct'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'answer_text': answerText,
      'is_correct': isCorrect,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class QuizAttemptModel extends QuizAttemptEntity {
  const QuizAttemptModel({
    required super.id,
    required super.userId,
    required super.quizId,
    required super.courseId,
    super.score,
    super.passed,
    super.timeTakenSeconds,
    super.answers,
    required super.startedAt,
    super.completedAt,
    required super.createdAt,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      quizId: json['quiz_id'] as String,
      courseId: json['course_id'] as String,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      passed: json['passed'] as bool? ?? false,
      timeTakenSeconds: json['time_taken_seconds'] as int?,
      answers: (json['answers'] as Map<String, dynamic>?) ?? {},
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'quiz_id': quizId,
      'course_id': courseId,
      'score': score,
      'passed': passed,
      'time_taken_seconds': timeTakenSeconds,
      'answers': answers,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
