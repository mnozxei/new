import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/course_entity.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/course_repository.dart';

part 'student_event.dart';
part 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  StudentBloc({required CourseRepository repository})
      : _repository = repository,
        super(const StudentInitial()) {
    on<LoadMyEnrollments>(_onLoadMyEnrollments);
    on<LoadEnrollmentDetails>(_onLoadEnrollmentDetails);
    on<EnrollInCourse>(_onEnrollInCourse);
    on<MarkLessonComplete>(_onMarkLessonComplete);
    on<UpdateLessonProgress>(_onUpdateLessonProgress);
    on<StartQuiz>(_onStartQuiz);
    on<SubmitQuizAnswer>(_onSubmitQuizAnswer);
    on<SubmitQuiz>(_onSubmitQuiz);
    on<LoadQuiz>(_onLoadQuiz);
    on<LoadCertificate>(_onLoadCertificate);
    on<AddCourseReview>(_onAddCourseReview);
  }

  final CourseRepository _repository;

  Future<void> _onLoadMyEnrollments(
    LoadMyEnrollments event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());
    try {
      final enrollments = await _repository.getMyEnrollments(
        status: event.status,
        limit: event.limit,
        offset: event.offset,
      );
      emit(EnrollmentsLoaded(enrollments));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onLoadEnrollmentDetails(
    LoadEnrollmentDetails event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());
    try {
      final enrollment = await _repository.getEnrollment(event.courseId);
      if (enrollment != null) {
        final course = await _repository.getCourseWithContent(event.courseId);
        emit(EnrollmentDetailsLoaded(
          enrollment: enrollment,
          course: course!,
        ));
      } else {
        emit(const StudentError('لم يتم العثور على التسجيل'));
      }
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onEnrollInCourse(
    EnrollInCourse event,
    Emitter<StudentState> emit,
  ) async {
    emit(const EnrollmentLoading());
    try {
      final enrollment = await _repository.enrollInCourse(
        event.courseId,
        paymentId: event.paymentId,
      );
      emit(EnrollmentSuccess(enrollment));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onMarkLessonComplete(
    MarkLessonComplete event,
    Emitter<StudentState> emit,
  ) async {
    try {
      await _repository.markLessonComplete(event.lessonId);
      emit(LessonCompleted(event.lessonId));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onUpdateLessonProgress(
    UpdateLessonProgress event,
    Emitter<StudentState> emit,
  ) async {
    try {
      final progress = await _repository.updateLessonProgress(
        event.lessonId,
        watchTimeSeconds: event.watchTimeSeconds,
        lastPositionSeconds: event.lastPositionSeconds,
        isCompleted: event.isCompleted,
      );
      emit(LessonProgressUpdated(progress));
    } catch (e) {
      // Silent fail for progress updates
    }
  }

  Future<void> _onStartQuiz(
    StartQuiz event,
    Emitter<StudentState> emit,
  ) async {
    emit(const QuizLoading());
    try {
      final quiz = await _repository.getQuizById(event.quizId);
      if (quiz == null) {
        emit(const StudentError('لم يتم العثور على الاختبار'));
        return;
      }
      final attempt = await _repository.startQuizAttempt(event.quizId);
      emit(QuizStarted(quiz: quiz, attempt: attempt));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onSubmitQuizAnswer(
    SubmitQuizAnswer event,
    Emitter<StudentState> emit,
  ) async {
    // This is handled locally in the UI - answers are collected
    // and submitted all at once with SubmitQuiz
  }

  Future<void> _onSubmitQuiz(
    SubmitQuiz event,
    Emitter<StudentState> emit,
  ) async {
    emit(const QuizSubmitting());
    try {
      final result = await _repository.submitQuizAttempt(
        event.attemptId,
        event.answers,
      );
      emit(QuizCompleted(result));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onLoadQuiz(
    LoadQuiz event,
    Emitter<StudentState> emit,
  ) async {
    emit(const QuizLoading());
    try {
      final quiz = await _repository.getQuizById(event.quizId);
      if (quiz != null) {
        final attempts = await _repository.getQuizAttempts(event.quizId);
        final latestAttempt = attempts.isNotEmpty ? attempts.first : null;
        emit(QuizLoaded(
          quiz: quiz,
          previousAttempt: latestAttempt,
        ));
      } else {
        emit(const StudentError('لم يتم العثور على الاختبار'));
      }
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onLoadCertificate(
    LoadCertificate event,
    Emitter<StudentState> emit,
  ) async {
    emit(const CertificateLoading());
    try {
      final enrollment = await _repository.getEnrollment(event.courseId);
      if (enrollment != null && enrollment.certificateUrl != null) {
        emit(CertificateLoaded(
          certificateUrl: enrollment.certificateUrl!,
          enrollment: enrollment,
        ));
      } else {
        emit(const StudentError('لم يتم إصدار الشهادة بعد'));
      }
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> _onAddCourseReview(
    AddCourseReview event,
    Emitter<StudentState> emit,
  ) async {
    emit(const ReviewSubmitting());
    try {
      final review = await _repository.addReview(AddReviewParams(
        courseId: event.courseId,
        rating: event.rating,
        comment: event.comment,
      ));
      emit(ReviewSubmitted(review));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }
}
