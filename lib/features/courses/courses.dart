// Courses feature exports

// Data layer
export 'data/datasources/course_remote_data_source.dart';
export 'data/repositories/course_repository_impl.dart';

// Domain layer
export 'domain/entities/course_entity.dart';
export 'domain/entities/quiz_entity.dart';
export 'domain/entities/instructor_entity.dart';
export 'domain/entities/certificate_entity.dart';
export 'domain/repositories/course_repository.dart';

// Presentation layer - BLoCs
export 'presentation/bloc/course_bloc.dart';
export 'presentation/bloc/instructor_bloc.dart' hide UpdateCourse;
export 'presentation/bloc/student_bloc.dart' hide EnrollInCourse;

// Presentation layer - Pages
export 'presentation/pages/course_details_page.dart';
export 'presentation/pages/courses_page.dart';
export 'presentation/pages/course_builder_page.dart';
export 'presentation/pages/instructor_dashboard_page.dart';
export 'presentation/pages/quiz_builder_page.dart';
export 'presentation/pages/quiz_page.dart';
export 'presentation/pages/lesson_page.dart';
export 'presentation/pages/my_learning_page.dart';
export 'presentation/pages/certificate_page.dart';
export 'presentation/pages/certificate_verify_page.dart';
export 'presentation/pages/course_enrollment_page.dart';
export 'presentation/pages/admin_course_moderation_page.dart';
export 'presentation/pages/instructor_application_page.dart';
export 'presentation/pages/instructor_verification_page.dart';

// Presentation layer - Widgets
export 'presentation/widgets/instructor_stats_card.dart';
export 'presentation/widgets/instructor_course_card.dart';
