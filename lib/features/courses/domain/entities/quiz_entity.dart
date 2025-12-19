import 'package:equatable/equatable.dart';

/// Quiz type
enum QuizType {
  lesson('lesson'),
  section('section'),
  final_('final');

  const QuizType(this.value);
  final String value;

  static QuizType fromString(String value) {
    return QuizType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => QuizType.lesson,
    );
  }

  String get displayName {
    switch (this) {
      case QuizType.lesson:
        return 'اختبار الدرس';
      case QuizType.section:
        return 'اختبار القسم';
      case QuizType.final_:
        return 'الاختبار النهائي';
    }
  }
}

/// Question type
enum QuestionType {
  single('single'),
  multiple('multiple'),
  trueFalse('true_false'),
  shortAnswer('short_answer');

  const QuestionType(this.value);
  final String value;

  static QuestionType fromString(String value) {
    return QuestionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => QuestionType.single,
    );
  }

  String get displayName {
    switch (this) {
      case QuestionType.single:
        return 'اختيار واحد';
      case QuestionType.multiple:
        return 'اختيار متعدد';
      case QuestionType.trueFalse:
        return 'صح / خطأ';
      case QuestionType.shortAnswer:
        return 'إجابة قصيرة';
    }
  }
}

/// Quiz entity
class QuizEntity extends Equatable {
  const QuizEntity({
    required this.id,
    required this.courseId,
    this.lessonId,
    required this.title,
    this.description,
    this.type = QuizType.lesson,
    this.passingScore = 70,
    this.timeLimitMinutes,
    this.maxAttempts = 3,
    this.shuffleQuestions = true,
    this.shuffleAnswers = true,
    this.showCorrectAnswers = false,
    this.isRequired = true,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.questions = const [],
  });

  final String id;
  final String courseId;
  final String? lessonId;
  final String title;
  final String? description;
  final QuizType type;
  final int passingScore;
  final int? timeLimitMinutes;
  final int maxAttempts;
  final bool shuffleQuestions;
  final bool shuffleAnswers;
  final bool showCorrectAnswers;
  final bool isRequired;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<QuizQuestionEntity> questions;

  int get questionCount => questions.length;

  int get totalPoints => questions.fold(0, (sum, q) => sum + q.points);

  QuizEntity copyWith({
    String? id,
    String? courseId,
    String? lessonId,
    String? title,
    String? description,
    QuizType? type,
    int? passingScore,
    int? timeLimitMinutes,
    int? maxAttempts,
    bool? shuffleQuestions,
    bool? shuffleAnswers,
    bool? showCorrectAnswers,
    bool? isRequired,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<QuizQuestionEntity>? questions,
  }) {
    return QuizEntity(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      lessonId: lessonId ?? this.lessonId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      passingScore: passingScore ?? this.passingScore,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      shuffleAnswers: shuffleAnswers ?? this.shuffleAnswers,
      showCorrectAnswers: showCorrectAnswers ?? this.showCorrectAnswers,
      isRequired: isRequired ?? this.isRequired,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      questions: questions ?? this.questions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        lessonId,
        title,
        description,
        type,
        passingScore,
        timeLimitMinutes,
        maxAttempts,
        shuffleQuestions,
        shuffleAnswers,
        showCorrectAnswers,
        isRequired,
        sortOrder,
        createdAt,
        updatedAt,
        questions,
      ];
}

/// Quiz question entity
class QuizQuestionEntity extends Equatable {
  const QuizQuestionEntity({
    required this.id,
    required this.quizId,
    this.questionType = QuestionType.single,
    required this.questionText,
    this.questionImageUrl,
    this.explanation,
    this.points = 1,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.answers = const [],
  });

  final String id;
  final String quizId;
  final QuestionType questionType;
  final String questionText;
  final String? questionImageUrl;
  final String? explanation;
  final int points;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<QuizAnswerEntity> answers;

  /// Get the correct answer(s) for this question
  List<QuizAnswerEntity> get correctAnswers =>
      answers.where((a) => a.isCorrect).toList();

  QuizQuestionEntity copyWith({
    String? id,
    String? quizId,
    QuestionType? questionType,
    String? questionText,
    String? questionImageUrl,
    String? explanation,
    int? points,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<QuizAnswerEntity>? answers,
  }) {
    return QuizQuestionEntity(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      questionType: questionType ?? this.questionType,
      questionText: questionText ?? this.questionText,
      questionImageUrl: questionImageUrl ?? this.questionImageUrl,
      explanation: explanation ?? this.explanation,
      points: points ?? this.points,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      answers: answers ?? this.answers,
    );
  }

  @override
  List<Object?> get props => [
        id,
        quizId,
        questionType,
        questionText,
        questionImageUrl,
        explanation,
        points,
        sortOrder,
        createdAt,
        updatedAt,
        answers,
      ];
}

/// Quiz answer entity
class QuizAnswerEntity extends Equatable {
  const QuizAnswerEntity({
    required this.id,
    required this.questionId,
    required this.answerText,
    this.isCorrect = false,
    this.sortOrder = 0,
    required this.createdAt,
  });

  final String id;
  final String questionId;
  final String answerText;
  final bool isCorrect;
  final int sortOrder;
  final DateTime createdAt;

  QuizAnswerEntity copyWith({
    String? id,
    String? questionId,
    String? answerText,
    bool? isCorrect,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return QuizAnswerEntity(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      answerText: answerText ?? this.answerText,
      isCorrect: isCorrect ?? this.isCorrect,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        questionId,
        answerText,
        isCorrect,
        sortOrder,
        createdAt,
      ];
}

/// Quiz attempt entity - tracks user's quiz attempts
class QuizAttemptEntity extends Equatable {
  const QuizAttemptEntity({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.courseId,
    this.attemptNumber = 1,
    this.score = 0,
    this.passed = false,
    this.timeTakenSeconds,
    this.answers = const {},
    required this.startedAt,
    this.completedAt,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String quizId;
  final String courseId;
  final int attemptNumber;
  final double score;
  final bool passed;
  final int? timeTakenSeconds;
  final Map<String, dynamic> answers; // questionId -> selectedAnswerId(s)
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  bool get isCompleted => completedAt != null;

  String get formattedTimeTaken {
    if (timeTakenSeconds == null) return '--:--';
    final minutes = timeTakenSeconds! ~/ 60;
    final seconds = timeTakenSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  QuizAttemptEntity copyWith({
    String? id,
    String? userId,
    String? quizId,
    String? courseId,
    double? score,
    bool? passed,
    int? timeTakenSeconds,
    Map<String, dynamic>? answers,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return QuizAttemptEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      quizId: quizId ?? this.quizId,
      courseId: courseId ?? this.courseId,
      score: score ?? this.score,
      passed: passed ?? this.passed,
      timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
      answers: answers ?? this.answers,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        quizId,
        courseId,
        score,
        passed,
        timeTakenSeconds,
        answers,
        startedAt,
        completedAt,
        createdAt,
      ];
}
