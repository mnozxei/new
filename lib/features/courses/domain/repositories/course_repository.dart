import '../entities/certificate_entity.dart';
import '../entities/course_entity.dart';
import '../entities/quiz_entity.dart';

abstract class CourseRepository {
  /// Get published courses with filters
  Future<List<CourseEntity>> getCourses({
    String? category,
    CourseLevel? level,
    bool? isFree,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  });

  /// Get featured courses
  Future<List<CourseEntity>> getFeaturedCourses({int limit = 10});

  /// Get course by ID with full details
  Future<CourseEntity?> getCourseById(String id);

  /// Get course with sections and lessons
  Future<CourseEntity?> getCourseWithContent(String id);

  /// Get instructor's courses
  Future<List<CourseEntity>> getInstructorCourses(String instructorId);

  /// Get my courses (as instructor)
  Future<List<CourseEntity>> getMyCourses();

  /// Create a new course
  Future<CourseEntity> createCourse(CreateCourseParams params);

  /// Update course
  Future<CourseEntity> updateCourse(String id, UpdateCourseParams params);

  /// Delete course
  Future<void> deleteCourse(String id);

  /// Publish/unpublish course
  Future<CourseEntity> togglePublish(String id);

  /// Upload course thumbnail
  Future<String> uploadThumbnail(String courseId, dynamic file);

  /// Create section
  Future<CourseSectionEntity> createSection(CreateSectionParams params);

  /// Update section
  Future<CourseSectionEntity> updateSection(
      String sectionId, UpdateSectionParams params);

  /// Delete section
  Future<void> deleteSection(String sectionId);

  /// Reorder sections
  Future<void> reorderSections(String courseId, List<String> sectionIds);

  /// Create lesson
  Future<LessonEntity> createLesson(CreateLessonParams params);

  /// Update lesson
  Future<LessonEntity> updateLesson(String lessonId, UpdateLessonParams params);

  /// Delete lesson
  Future<void> deleteLesson(String lessonId);

  /// Reorder lessons
  Future<void> reorderLessons(String sectionId, List<String> lessonIds);

  /// Check if enrolled
  Future<bool> isEnrolled(String courseId);

  /// Get enrollment
  Future<EnrollmentEntity?> getEnrollment(String courseId);

  /// Get my enrollments
  Future<List<EnrollmentEntity>> getMyEnrollments({
    EnrollmentStatus? status,
    int limit = 20,
    int offset = 0,
  });

  /// Enroll in course
  Future<EnrollmentEntity> enrollInCourse(String courseId, {String? paymentId});

  /// Update lesson progress
  Future<LessonProgressEntity> updateLessonProgress(
    String lessonId, {
    int? watchTimeSeconds,
    int? lastPositionSeconds,
    bool? isCompleted,
  });

  /// Get lesson progress
  Future<LessonProgressEntity?> getLessonProgress(String lessonId);

  /// Mark lesson as complete
  Future<void> markLessonComplete(String lessonId);

  /// Update enrollment progress (recalculate based on completed lessons)
  Future<EnrollmentEntity> updateEnrollmentProgress(String courseId);

  /// Check if course can be completed and complete it if requirements met
  Future<EnrollmentEntity?> checkAndCompleteCourse(String courseId);

  /// Get course reviews
  Future<List<CourseReviewEntity>> getCourseReviews(
    String courseId, {
    int limit = 20,
    int offset = 0,
  });

  /// Add review
  Future<CourseReviewEntity> addReview(AddReviewParams params);

  /// Update review
  Future<CourseReviewEntity> updateReview(String reviewId, int rating,
      {String? comment});

  /// Delete review
  Future<void> deleteReview(String reviewId);

  /// Get instructor stats
  Future<InstructorStats> getInstructorStats();

  /// Get course stats
  Future<CourseStats> getCourseStats(String courseId);

  // ============================================
  // QUIZ METHODS
  // ============================================

  /// Get quizzes for a course
  Future<List<QuizEntity>> getCourseQuizzes(String courseId);

  /// Get quiz by ID
  Future<QuizEntity?> getQuizById(String quizId);

  /// Get quiz for a lesson
  Future<QuizEntity?> getLessonQuiz(String lessonId);

  /// Create a quiz
  Future<QuizEntity> createQuiz(CreateQuizParams params);

  /// Update a quiz
  Future<QuizEntity> updateQuiz(String quizId, UpdateQuizParams params);

  /// Delete a quiz
  Future<void> deleteQuiz(String quizId);

  /// Add question to quiz
  Future<QuizQuestionEntity> addQuestion(AddQuestionParams params);

  /// Update question
  Future<QuizQuestionEntity> updateQuestion(
    String questionId,
    UpdateQuestionParams params,
  );

  /// Delete question
  Future<void> deleteQuestion(String questionId);

  /// Reorder questions
  Future<void> reorderQuestions(String quizId, List<String> questionIds);

  /// Start a quiz attempt
  Future<QuizAttemptEntity> startQuizAttempt(String quizId);

  /// Submit quiz attempt
  Future<QuizAttemptEntity> submitQuizAttempt(
    String attemptId,
    Map<String, dynamic> answers,
  );

  /// Get quiz attempts for a user
  Future<List<QuizAttemptEntity>> getQuizAttempts(String quizId);

  /// Get latest quiz attempt
  Future<QuizAttemptEntity?> getLatestQuizAttempt(String quizId);

  /// Check if quiz is passed
  Future<bool> isQuizPassed(String quizId);

  /// Check if lesson is unlocked (previous quiz passed if required)
  Future<bool> isLessonUnlocked(String lessonId);

  // ============================================
  // CERTIFICATE METHODS
  // ============================================

  /// Issue a certificate for a completed enrollment
  Future<CertificateEntity> issueCertificate(String enrollmentId);

  /// Get certificate by ID
  Future<CertificateEntity?> getCertificate(String certificateId);

  /// Get certificate by enrollment ID
  Future<CertificateEntity?> getCertificateByEnrollment(String enrollmentId);

  /// Get certificate by serial number
  Future<CertificateEntity?> getCertificateBySerial(String serialNumber);

  /// Verify a certificate by serial number
  Future<CertificateVerificationResult> verifyCertificate(String serialNumber);

  /// Get all certificates for the current user
  Future<List<CertificateEntity>> getUserCertificates();

  /// Revoke a certificate (admin only)
  Future<void> revokeCertificate(String certificateId, String reason);
}

class CreateCourseParams {
  const CreateCourseParams({
    required this.title,
    this.description,
    this.shortDescription,
    this.level = CourseLevel.beginner,
    this.category,
    this.subcategory,
    this.language = 'ar',
    this.price = 0,
    this.currency = 'SAR',
    this.isFree = false,
    this.requirements = const [],
    this.objectives = const [],
    this.tags = const [],
  });

  final String title;
  final String? description;
  final String? shortDescription;
  final CourseLevel level;
  final String? category;
  final String? subcategory;
  final String language;
  final double price;
  final String currency;
  final bool isFree;
  final List<String> requirements;
  final List<String> objectives;
  final List<String> tags;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        if (shortDescription != null) 'short_description': shortDescription,
        'level': level.value,
        if (category != null) 'category': category,
        if (subcategory != null) 'subcategory': subcategory,
        'language': language,
        'price': price,
        'currency': currency,
        'is_free': isFree,
        'requirements': requirements,
        'objectives': objectives,
        'tags': tags,
      };
}

class UpdateCourseParams {
  const UpdateCourseParams({
    this.title,
    this.description,
    this.shortDescription,
    this.level,
    this.category,
    this.subcategory,
    this.language,
    this.price,
    this.currency,
    this.isFree,
    this.requirements,
    this.objectives,
    this.tags,
  });

  final String? title;
  final String? description;
  final String? shortDescription;
  final CourseLevel? level;
  final String? category;
  final String? subcategory;
  final String? language;
  final double? price;
  final String? currency;
  final bool? isFree;
  final List<String>? requirements;
  final List<String>? objectives;
  final List<String>? tags;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (shortDescription != null) json['short_description'] = shortDescription;
    if (level != null) json['level'] = level!.value;
    if (category != null) json['category'] = category;
    if (subcategory != null) json['subcategory'] = subcategory;
    if (language != null) json['language'] = language;
    if (price != null) json['price'] = price;
    if (currency != null) json['currency'] = currency;
    if (isFree != null) json['is_free'] = isFree;
    if (requirements != null) json['requirements'] = requirements;
    if (objectives != null) json['objectives'] = objectives;
    if (tags != null) json['tags'] = tags;
    return json;
  }
}

class CreateSectionParams {
  const CreateSectionParams({
    required this.courseId,
    required this.title,
    this.description,
  });

  final String courseId;
  final String title;
  final String? description;
}

class UpdateSectionParams {
  const UpdateSectionParams({
    this.title,
    this.description,
  });

  final String? title;
  final String? description;
}

class CreateLessonParams {
  const CreateLessonParams({
    required this.sectionId,
    required this.courseId,
    required this.title,
    this.description,
    this.contentType = 'video',
    this.videoUrl,
    this.durationSeconds = 0,
    this.content,
    this.isFreePreview = false,
  });

  final String sectionId;
  final String courseId;
  final String title;
  final String? description;
  final String contentType;
  final String? videoUrl;
  final int durationSeconds;
  final String? content;
  final bool isFreePreview;
}

class UpdateLessonParams {
  const UpdateLessonParams({
    this.title,
    this.description,
    this.contentType,
    this.videoUrl,
    this.durationSeconds,
    this.content,
    this.isFreePreview,
  });

  final String? title;
  final String? description;
  final String? contentType;
  final String? videoUrl;
  final int? durationSeconds;
  final String? content;
  final bool? isFreePreview;
}

class AddReviewParams {
  const AddReviewParams({
    required this.courseId,
    required this.rating,
    this.comment,
  });

  final String courseId;
  final int rating;
  final String? comment;
}

class InstructorStats {
  const InstructorStats({
    this.totalCourses = 0,
    this.totalStudents = 0,
    this.totalRevenue = 0,
    this.averageRating = 0,
    this.totalReviews = 0,
  });

  final int totalCourses;
  final int totalStudents;
  final double totalRevenue;
  final double averageRating;
  final int totalReviews;
}

class CourseStats {
  const CourseStats({
    this.enrollments = 0,
    this.completions = 0,
    this.revenue = 0,
    this.averageProgress = 0,
    this.averageRating = 0,
    this.totalReviews = 0,
  });

  final int enrollments;
  final int completions;
  final double revenue;
  final double averageProgress;
  final double averageRating;
  final int totalReviews;
}

// ============================================
// QUIZ PARAMS
// ============================================

class CreateQuizParams {
  const CreateQuizParams({
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
  });

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

  Map<String, dynamic> toJson() => {
        'course_id': courseId,
        if (lessonId != null) 'lesson_id': lessonId,
        'title': title,
        if (description != null) 'description': description,
        'type': type.value,
        'passing_score': passingScore,
        if (timeLimitMinutes != null) 'time_limit_minutes': timeLimitMinutes,
        'max_attempts': maxAttempts,
        'shuffle_questions': shuffleQuestions,
        'shuffle_answers': shuffleAnswers,
        'show_correct_answers': showCorrectAnswers,
        'is_required': isRequired,
      };
}

class UpdateQuizParams {
  const UpdateQuizParams({
    this.title,
    this.description,
    this.type,
    this.passingScore,
    this.timeLimitMinutes,
    this.maxAttempts,
    this.shuffleQuestions,
    this.shuffleAnswers,
    this.showCorrectAnswers,
    this.isRequired,
  });

  final String? title;
  final String? description;
  final QuizType? type;
  final int? passingScore;
  final int? timeLimitMinutes;
  final int? maxAttempts;
  final bool? shuffleQuestions;
  final bool? shuffleAnswers;
  final bool? showCorrectAnswers;
  final bool? isRequired;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (type != null) json['type'] = type!.value;
    if (passingScore != null) json['passing_score'] = passingScore;
    if (timeLimitMinutes != null) json['time_limit_minutes'] = timeLimitMinutes;
    if (maxAttempts != null) json['max_attempts'] = maxAttempts;
    if (shuffleQuestions != null) json['shuffle_questions'] = shuffleQuestions;
    if (shuffleAnswers != null) json['shuffle_answers'] = shuffleAnswers;
    if (showCorrectAnswers != null) {
      json['show_correct_answers'] = showCorrectAnswers;
    }
    if (isRequired != null) json['is_required'] = isRequired;
    return json;
  }
}

class AddQuestionParams {
  const AddQuestionParams({
    required this.quizId,
    required this.questionText,
    this.questionType = QuestionType.single,
    this.questionImageUrl,
    this.explanation,
    this.points = 1,
    this.answers = const [],
  });

  final String quizId;
  final String questionText;
  final QuestionType questionType;
  final String? questionImageUrl;
  final String? explanation;
  final int points;
  final List<AnswerInput> answers;

  Map<String, dynamic> toJson() => {
        'quiz_id': quizId,
        'question_text': questionText,
        'question_type': questionType.value,
        if (questionImageUrl != null) 'question_image_url': questionImageUrl,
        if (explanation != null) 'explanation': explanation,
        'points': points,
      };
}

class UpdateQuestionParams {
  const UpdateQuestionParams({
    this.questionText,
    this.questionType,
    this.questionImageUrl,
    this.explanation,
    this.points,
  });

  final String? questionText;
  final QuestionType? questionType;
  final String? questionImageUrl;
  final String? explanation;
  final int? points;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (questionText != null) json['question_text'] = questionText;
    if (questionType != null) json['question_type'] = questionType!.value;
    if (questionImageUrl != null) json['question_image_url'] = questionImageUrl;
    if (explanation != null) json['explanation'] = explanation;
    if (points != null) json['points'] = points;
    return json;
  }
}

class AnswerInput {
  const AnswerInput({
    required this.answerText,
    this.isCorrect = false,
  });

  final String answerText;
  final bool isCorrect;

  Map<String, dynamic> toJson() => {
        'answer_text': answerText,
        'is_correct': isCorrect,
      };
}
