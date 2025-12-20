-- TAMAD HUB Seed Data
-- Initial data for development and testing

-- Note: This seed assumes you have created test users via Supabase Auth first.
-- The user IDs below are placeholders and should be replaced with actual UUIDs.

-- ============================================
-- SAMPLE PROFILES (for development/testing)
-- ============================================
-- In production, profiles are created via auth triggers

-- For development, create sample profiles AFTER creating auth users
-- Example UUIDs (replace with actual auth user IDs):
-- User 1: '11111111-1111-1111-1111-111111111111'
-- User 2: '22222222-2222-2222-2222-222222222222'
-- User 3: '33333333-3333-3333-3333-333333333333'
-- Admin:  '44444444-4444-4444-4444-444444444444'

-- ============================================
-- SAMPLE COMPANIES
-- ============================================

INSERT INTO companies (
    id, owner_id, name, name_en, description, industry, company_size,
    website, email, phone, city, country, founded_year, status,
    commercial_registration_number, commercial_registration_issue_date,
    commercial_registration_expiry_date, vat_number,
    national_address, follower_count, employee_count
) VALUES
(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '11111111-1111-1111-1111-111111111111',
    'شركة التقنية المتقدمة',
    'Advanced Tech Solutions',
    'شركة رائدة في مجال حلول تقنية المعلومات والتحول الرقمي. نقدم خدمات البرمجة والاستشارات التقنية للشركات الكبرى.',
    'تقنية المعلومات',
    '51-200',
    'https://advancedtech.sa',
    'info@advancedtech.sa',
    '+966 11 123 4567',
    'الرياض',
    'SA',
    2015,
    'verified',
    '1010123456',
    '2023-01-15',
    '2028-01-14',
    '300012345678901',
    '{"buildingNo": "1234", "street": "طريق الملك فهد", "district": "العليا", "city": "الرياض", "postalCode": "12345", "additionalNo": "6789"}',
    245,
    75
),
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    '22222222-2222-2222-2222-222222222222',
    'مؤسسة الابتكار للاستشارات',
    'Innovation Consulting',
    'نقدم خدمات استشارية متميزة في مجال الإدارة والتطوير المؤسسي.',
    'استشارات',
    '11-50',
    'https://innovation-consulting.sa',
    'contact@innovation.sa',
    '+966 12 456 7890',
    'جدة',
    'SA',
    2018,
    'pending',
    '4031087654',
    '2022-06-01',
    '2027-05-31',
    NULL,
    '{"buildingNo": "5678", "street": "شارع فلسطين", "district": "الحمراء", "city": "جدة", "postalCode": "21452", "additionalNo": "1234"}',
    89,
    25
),
(
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '33333333-3333-3333-3333-333333333333',
    'شركة البناء الحديث',
    'Modern Construction Co',
    'متخصصون في المقاولات العامة وتنفيذ المشاريع الإنشائية الكبرى.',
    'إنشاءات',
    '201-500',
    'https://modern-construction.sa',
    'info@modern-const.sa',
    '+966 13 789 0123',
    'الدمام',
    'SA',
    2010,
    'unverified',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    156,
    320
)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- SAMPLE POSTS
-- ============================================

INSERT INTO posts (
    id, author_id, company_id, content, visibility, created_at
) VALUES
(
    'post1111-1111-1111-1111-111111111111',
    '11111111-1111-1111-1111-111111111111',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'نفخر بإطلاق منصتنا الجديدة للتعلم الإلكتروني! 🎉

بعد أشهر من العمل الجاد، أصبحت المنصة جاهزة لخدمة المتعلمين في جميع أنحاء المملكة.

#تعليم #تقنية #ابتكار',
    'public',
    NOW() - INTERVAL '2 days'
),
(
    'post2222-2222-2222-2222-222222222222',
    '22222222-2222-2222-2222-222222222222',
    NULL,
    'أبحث عن مطورين Flutter محترفين للانضمام لفريقنا!

المتطلبات:
- خبرة لا تقل عن 3 سنوات
- إتقان Dart و Flutter
- معرفة بـ State Management (BLoC/Riverpod)
- خبرة في APIs و Supabase

#وظائف #برمجة #Flutter',
    'public',
    NOW() - INTERVAL '1 day'
),
(
    'post3333-3333-3333-3333-333333333333',
    '33333333-3333-3333-3333-333333333333',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    'أنهينا بنجاح مشروع برج الأعمال في حي العليا! 🏗️

شكراً لفريق العمل المتميز الذي جعل هذا الإنجاز ممكناً.

#إنشاءات #مشاريع #نجاح',
    'public',
    NOW() - INTERVAL '12 hours'
)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- SAMPLE JOBS
-- ============================================

INSERT INTO jobs (
    id, company_id, posted_by, title, description, requirements, responsibilities,
    job_type, location, is_remote, salary_min, salary_max, salary_currency,
    experience_years_min, experience_years_max, skills_required, benefits,
    vacancy_count, is_active, application_deadline
) VALUES
(
    'job11111-1111-1111-1111-111111111111',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '11111111-1111-1111-1111-111111111111',
    'مهندس برمجيات أول - Flutter',
    'نبحث عن مهندس برمجيات خبير للعمل على تطوير تطبيقات الجوال باستخدام Flutter.',
    'خبرة 5+ سنوات في تطوير تطبيقات الجوال\nإتقان Flutter و Dart\nخبرة في Firebase و Supabase',
    'قيادة فريق التطوير\nتصميم وتنفيذ الحلول التقنية\nمراجعة الكود والتأكد من الجودة',
    'full_time',
    'الرياض',
    TRUE,
    20000,
    35000,
    'SAR',
    5,
    10,
    ARRAY['Flutter', 'Dart', 'Firebase', 'Supabase', 'REST APIs'],
    ARRAY['تأمين طبي', 'بدل سكن', 'مكافأة سنوية'],
    2,
    TRUE,
    NOW() + INTERVAL '30 days'
),
(
    'job22222-2222-2222-2222-222222222222',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '11111111-1111-1111-1111-111111111111',
    'مصمم UI/UX',
    'نبحث عن مصمم واجهات مستخدم مبدع للعمل على تصميم تجارب مستخدم استثنائية.',
    'خبرة 3+ سنوات في تصميم UI/UX\nإتقان Figma و Adobe XD\nمحفظة أعمال قوية',
    'تصميم واجهات المستخدم\nإجراء بحوث المستخدمين\nإنشاء النماذج الأولية',
    'full_time',
    'الرياض',
    FALSE,
    12000,
    20000,
    'SAR',
    3,
    7,
    ARRAY['Figma', 'Adobe XD', 'Prototyping', 'User Research'],
    ARRAY['تأمين طبي', 'إجازة سنوية 30 يوم'],
    1,
    TRUE,
    NOW() + INTERVAL '45 days'
),
(
    'job33333-3333-3333-3333-333333333333',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    '22222222-2222-2222-2222-222222222222',
    'مستشار أعمال',
    'فرصة للانضمام لفريق الاستشارات لدينا.',
    'شهادة MBA أو ما يعادلها\nخبرة 5+ سنوات في الاستشارات',
    'تقديم الاستشارات للعملاء\nإعداد التقارير والتحليلات',
    'contract',
    'جدة',
    TRUE,
    25000,
    40000,
    'SAR',
    5,
    15,
    ARRAY['Strategic Planning', 'Business Analysis', 'Project Management'],
    ARRAY['مكافآت أداء', 'تأمين طبي'],
    3,
    TRUE,
    NOW() + INTERVAL '60 days'
)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- SAMPLE COURSES
-- ============================================

INSERT INTO courses (
    id, instructor_id, company_id, title, description, thumbnail_url,
    level, duration_hours, language, price, discount_price, is_free,
    is_published, max_students, category, tags
) VALUES
(
    'course111-1111-1111-1111-111111111111',
    '11111111-1111-1111-1111-111111111111',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'دورة تطوير تطبيقات Flutter للمبتدئين',
    'دورة شاملة لتعلم تطوير تطبيقات الجوال باستخدام Flutter من الصفر إلى الاحتراف.',
    'https://example.com/flutter-course.jpg',
    'beginner',
    40,
    'ar',
    499.00,
    299.00,
    FALSE,
    TRUE,
    100,
    'برمجة',
    ARRAY['Flutter', 'Dart', 'Mobile Development']
)
ON CONFLICT (id) DO NOTHING;

-- Sample course sections
INSERT INTO course_sections (
    id, course_id, title, description, order_index
) VALUES
(
    'section1-1111-1111-1111-111111111111',
    'course111-1111-1111-1111-111111111111',
    'مقدمة في Flutter',
    'التعرف على Flutter وإعداد بيئة التطوير',
    1
),
(
    'section2-2222-2222-2222-222222222222',
    'course111-1111-1111-1111-111111111111',
    'أساسيات Dart',
    'تعلم أساسيات لغة Dart',
    2
)
ON CONFLICT (id) DO NOTHING;

-- Sample course lessons (with YouTube URLs)
INSERT INTO course_lessons (
    id, section_id, title, description, youtube_url, duration_minutes, order_index, is_preview
) VALUES
(
    'lesson11-1111-1111-1111-111111111111',
    'section1-1111-1111-1111-111111111111',
    'ما هو Flutter؟',
    'مقدمة عن إطار العمل Flutter ومميزاته',
    'https://www.youtube.com/watch?v=fq4N0hgOWzU',
    15,
    1,
    TRUE
),
(
    'lesson22-2222-2222-2222-222222222222',
    'section1-1111-1111-1111-111111111111',
    'تثبيت Flutter على Windows',
    'خطوات تثبيت Flutter وإعداد Android Studio',
    'https://www.youtube.com/watch?v=6xvE3_mT9ik',
    25,
    2,
    FALSE
),
(
    'lesson33-3333-3333-3333-333333333333',
    'section2-2222-2222-2222-222222222222',
    'المتغيرات وأنواع البيانات',
    'تعلم كيفية تعريف المتغيرات في Dart',
    'https://www.youtube.com/watch?v=Ej_Pcr4uC2Q',
    30,
    1,
    FALSE
)
ON CONFLICT (id) DO NOTHING;

-- Sample quiz for course
INSERT INTO quizzes (
    id, course_id, section_id, title, description, passing_score, time_limit_minutes
) VALUES
(
    'quiz1111-1111-1111-1111-111111111111',
    'course111-1111-1111-1111-111111111111',
    'section1-1111-1111-1111-111111111111',
    'اختبار: مقدمة في Flutter',
    'اختبار قصير للتأكد من استيعاب المفاهيم الأساسية',
    70,
    15
)
ON CONFLICT (id) DO NOTHING;

-- Sample quiz questions
INSERT INTO quiz_questions (
    id, quiz_id, question_text, question_type, points, order_index
) VALUES
(
    'ques1111-1111-1111-1111-111111111111',
    'quiz1111-1111-1111-1111-111111111111',
    'ما هي لغة البرمجة المستخدمة في Flutter؟',
    'multiple_choice',
    10,
    1
),
(
    'ques2222-2222-2222-2222-222222222222',
    'quiz1111-1111-1111-1111-111111111111',
    'هل يمكن استخدام Flutter لتطوير تطبيقات الويب؟',
    'true_false',
    10,
    2
)
ON CONFLICT (id) DO NOTHING;

-- Sample quiz options
INSERT INTO quiz_options (
    id, question_id, option_text, is_correct, order_index
) VALUES
(
    'opt11111-1111-1111-1111-111111111111',
    'ques1111-1111-1111-1111-111111111111',
    'JavaScript',
    FALSE,
    1
),
(
    'opt22222-2222-2222-2222-222222222222',
    'ques1111-1111-1111-1111-111111111111',
    'Dart',
    TRUE,
    2
),
(
    'opt33333-3333-3333-3333-333333333333',
    'ques1111-1111-1111-1111-111111111111',
    'Python',
    FALSE,
    3
),
(
    'opt44444-4444-4444-4444-444444444444',
    'ques1111-1111-1111-1111-111111111111',
    'Kotlin',
    FALSE,
    4
),
(
    'opt55555-5555-5555-5555-555555555555',
    'ques2222-2222-2222-2222-222222222222',
    'صحيح',
    TRUE,
    1
),
(
    'opt66666-6666-6666-6666-666666666666',
    'ques2222-2222-2222-2222-222222222222',
    'خطأ',
    FALSE,
    2
)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- SAMPLE CHAT CONVERSATION
-- ============================================

INSERT INTO chats (
    id, type, name, created_by, created_at
) VALUES
(
    'chat1111-1111-1111-1111-111111111111',
    'direct',
    NULL,
    '11111111-1111-1111-1111-111111111111',
    NOW() - INTERVAL '1 week'
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO chat_members (
    id, chat_id, user_id, role, joined_at
) VALUES
(
    'memb1111-1111-1111-1111-111111111111',
    'chat1111-1111-1111-1111-111111111111',
    '11111111-1111-1111-1111-111111111111',
    'member',
    NOW() - INTERVAL '1 week'
),
(
    'memb2222-2222-2222-2222-222222222222',
    'chat1111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    'member',
    NOW() - INTERVAL '1 week'
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO messages (
    id, chat_id, sender_id, content, message_type, created_at
) VALUES
(
    'msg11111-1111-1111-1111-111111111111',
    'chat1111-1111-1111-1111-111111111111',
    '11111111-1111-1111-1111-111111111111',
    'مرحباً، هل الوظيفة المعلنة لا تزال متاحة؟',
    'text',
    NOW() - INTERVAL '1 week' + INTERVAL '1 hour'
),
(
    'msg22222-2222-2222-2222-222222222222',
    'chat1111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    'نعم، لا تزال متاحة. يسعدني استقبال طلبك.',
    'text',
    NOW() - INTERVAL '1 week' + INTERVAL '2 hours'
)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- SAMPLE NOTIFICATIONS
-- ============================================

INSERT INTO notifications (
    id, user_id, type, title, body, target_type, target_id, is_read, created_at
) VALUES
(
    'noti1111-1111-1111-1111-111111111111',
    '11111111-1111-1111-1111-111111111111',
    'like',
    'إعجاب جديد',
    'أعجب أحمد بمنشورك',
    'post',
    'post1111-1111-1111-1111-111111111111',
    FALSE,
    NOW() - INTERVAL '6 hours'
),
(
    'noti2222-2222-2222-2222-222222222222',
    '11111111-1111-1111-1111-111111111111',
    'comment',
    'تعليق جديد',
    'علّق محمد على منشورك',
    'post',
    'post1111-1111-1111-1111-111111111111',
    FALSE,
    NOW() - INTERVAL '4 hours'
),
(
    'noti3333-3333-3333-3333-333333333333',
    '22222222-2222-2222-2222-222222222222',
    'job',
    'طلب توظيف جديد',
    'تم استلام طلب جديد لوظيفة مهندس برمجيات',
    'job',
    'job11111-1111-1111-1111-111111111111',
    FALSE,
    NOW() - INTERVAL '2 hours'
)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- INITIAL IMPRESSIONS (Analytics)
-- ============================================

INSERT INTO impressions (
    id, target_type, target_id, user_id, created_at
) VALUES
(
    'impr1111-1111-1111-1111-111111111111',
    'post',
    'post1111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    NOW() - INTERVAL '1 day'
),
(
    'impr2222-2222-2222-2222-222222222222',
    'job',
    'job11111-1111-1111-1111-111111111111',
    '33333333-3333-3333-3333-333333333333',
    NOW() - INTERVAL '12 hours'
)
ON CONFLICT (id) DO NOTHING;
