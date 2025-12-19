import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../bloc/instructor_bloc.dart';

class QuizBuilderPage extends StatefulWidget {
  const QuizBuilderPage({
    super.key,
    required this.courseId,
    this.quizId,
    this.lessonId,
  });

  final String courseId;
  final String? quizId;
  final String? lessonId;

  @override
  State<QuizBuilderPage> createState() => _QuizBuilderPageState();
}

class _QuizBuilderPageState extends State<QuizBuilderPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passingScoreController = TextEditingController(text: '70');
  final _timeLimitController = TextEditingController();
  final _maxAttemptsController = TextEditingController(text: '3');

  QuizType _quizType = QuizType.lesson;
  bool _shuffleQuestions = true;
  bool _shuffleAnswers = true;
  bool _showCorrectAnswers = false;
  bool _isRequired = true;

  List<_QuestionData> _questions = [];
  bool _isLoading = false;
  bool _isSaving = false;
  QuizEntity? _existingQuiz;

  bool get _isEditing => widget.quizId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadQuiz();
    }
    if (widget.lessonId != null) {
      _quizType = QuizType.lesson;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _passingScoreController.dispose();
    _timeLimitController.dispose();
    _maxAttemptsController.dispose();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    setState(() => _isLoading = true);
    try {
      // Load quiz using InstructorBloc
      context.read<InstructorBloc>().add(LoadQuiz(widget.quizId!));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل الاختبار: $e')),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  void _prefillForm(QuizEntity quiz) {
    _titleController.text = quiz.title;
    _descriptionController.text = quiz.description ?? '';
    _passingScoreController.text = quiz.passingScore.toString();
    _timeLimitController.text = quiz.timeLimitMinutes?.toString() ?? '';
    _maxAttemptsController.text = quiz.maxAttempts.toString();
    _quizType = quiz.type;
    _shuffleQuestions = quiz.shuffleQuestions;
    _shuffleAnswers = quiz.shuffleAnswers;
    _showCorrectAnswers = quiz.showCorrectAnswers;
    _isRequired = quiz.isRequired;

    _questions = quiz.questions.map((q) => _QuestionData.fromEntity(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل الاختبار' : 'إنشاء اختبار جديد'),
        actions: [
          if (_questions.isNotEmpty)
            TextButton.icon(
              onPressed: _isSaving ? null : _saveQuiz,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('حفظ'),
            ),
        ],
      ),
      body: BlocListener<InstructorBloc, InstructorState>(
        listener: (context, state) {
          if (state is QuizLoaded && _existingQuiz == null) {
            setState(() {
              _existingQuiz = state.quiz;
            });
            _prefillForm(state.quiz);
          }
          if (state is QuizSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حفظ الاختبار بنجاح')),
            );
            context.pop();
          }
          if (state is InstructorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfoSection(context),
                      const SizedBox(height: 24),
                      _buildSettingsSection(context),
                      const SizedBox(height: 24),
                      _buildQuestionsSection(context),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addQuestion,
        icon: const Icon(Icons.add),
        label: const Text('إضافة سؤال'),
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات أساسية',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان الاختبار',
                hintText: 'مثال: اختبار الوحدة الأولى',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال عنوان الاختبار';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'وصف الاختبار (اختياري)',
                hintText: 'وصف مختصر لمحتوى الاختبار',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<QuizType>(
              value: _quizType,
              decoration: const InputDecoration(
                labelText: 'نوع الاختبار',
              ),
              items: QuizType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: widget.lessonId != null
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _quizType = value);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات الاختبار',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _passingScoreController,
                    decoration: const InputDecoration(
                      labelText: 'درجة النجاح (%)',
                      hintText: '70',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final score = int.tryParse(value);
                        if (score == null || score < 0 || score > 100) {
                          return 'أدخل قيمة صحيحة (0-100)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _timeLimitController,
                    decoration: const InputDecoration(
                      labelText: 'الوقت المحدد (دقيقة)',
                      hintText: 'بدون حد',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxAttemptsController,
              decoration: const InputDecoration(
                labelText: 'الحد الأقصى للمحاولات',
                hintText: '3',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('خلط الأسئلة'),
              subtitle: const Text('عرض الأسئلة بترتيب عشوائي'),
              value: _shuffleQuestions,
              onChanged: (value) => setState(() => _shuffleQuestions = value),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('خلط الإجابات'),
              subtitle: const Text('عرض الإجابات بترتيب عشوائي'),
              value: _shuffleAnswers,
              onChanged: (value) => setState(() => _shuffleAnswers = value),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('إظهار الإجابات الصحيحة'),
              subtitle: const Text('عرض الإجابات الصحيحة بعد الانتهاء'),
              value: _showCorrectAnswers,
              onChanged: (value) => setState(() => _showCorrectAnswers = value),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('اختبار إلزامي'),
              subtitle: const Text('يجب اجتيازه للتقدم'),
              value: _isRequired,
              onChanged: (value) => setState(() => _isRequired = value),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأسئلة (${_questions.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_questions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد أسئلة بعد',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اضغط على "إضافة سؤال" للبدء',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _questions.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _questions.removeAt(oldIndex);
                _questions.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              return _QuestionCard(
                key: ValueKey(_questions[index].id),
                index: index,
                question: _questions[index],
                onEdit: () => _editQuestion(index),
                onDelete: () => _deleteQuestion(index),
                onDuplicate: () => _duplicateQuestion(index),
              );
            },
          ),
      ],
    );
  }

  void _addQuestion() {
    setState(() {
      _questions.add(_QuestionData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        questionText: '',
        questionType: QuestionType.single,
        points: 1,
        answers: [],
      ));
    });
    _editQuestion(_questions.length - 1);
  }

  Future<void> _editQuestion(int index) async {
    final result = await showDialog<_QuestionData>(
      context: context,
      builder: (context) => _QuestionEditorDialog(
        question: _questions[index],
      ),
    );

    if (result != null) {
      setState(() {
        _questions[index] = result;
      });
    }
  }

  void _deleteQuestion(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف السؤال'),
        content: const Text('هل أنت متأكد من حذف هذا السؤال؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _questions.removeAt(index);
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _duplicateQuestion(int index) {
    setState(() {
      final original = _questions[index];
      _questions.insert(
        index + 1,
        _QuestionData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          questionText: original.questionText,
          questionType: original.questionType,
          points: original.points,
          explanation: original.explanation,
          answers: original.answers
              .map((a) => _AnswerData(
                    id: DateTime.now().millisecondsSinceEpoch.toString() +
                        a.answerText.hashCode.toString(),
                    answerText: a.answerText,
                    isCorrect: a.isCorrect,
                  ))
              .toList(),
        ),
      );
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إضافة سؤال واحد على الأقل')),
      );
      return;
    }

    // Validate each question has at least one correct answer
    for (var i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q.questionText.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('السؤال ${i + 1} فارغ')),
        );
        return;
      }
      if (q.answers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('السؤال ${i + 1} لا يحتوي على إجابات')),
        );
        return;
      }
      if (!q.answers.any((a) => a.isCorrect)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('السؤال ${i + 1} لا يحتوي على إجابة صحيحة')),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    final params = _isEditing
        ? UpdateQuizParams(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            type: _quizType,
            passingScore: int.tryParse(_passingScoreController.text) ?? 70,
            timeLimitMinutes: int.tryParse(_timeLimitController.text),
            maxAttempts: int.tryParse(_maxAttemptsController.text) ?? 3,
            shuffleQuestions: _shuffleQuestions,
            shuffleAnswers: _shuffleAnswers,
            showCorrectAnswers: _showCorrectAnswers,
            isRequired: _isRequired,
          )
        : CreateQuizParams(
            courseId: widget.courseId,
            lessonId: widget.lessonId,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            type: _quizType,
            passingScore: int.tryParse(_passingScoreController.text) ?? 70,
            timeLimitMinutes: int.tryParse(_timeLimitController.text),
            maxAttempts: int.tryParse(_maxAttemptsController.text) ?? 3,
            shuffleQuestions: _shuffleQuestions,
            shuffleAnswers: _shuffleAnswers,
            showCorrectAnswers: _showCorrectAnswers,
            isRequired: _isRequired,
          );

    context.read<InstructorBloc>().add(
          _isEditing
              ? UpdateQuiz(widget.quizId!, params as UpdateQuizParams, _questions)
              : CreateQuiz(params as CreateQuizParams, _questions),
        );

    setState(() => _isSaving = false);
  }
}

class _QuestionData {
  _QuestionData({
    required this.id,
    required this.questionText,
    this.questionType = QuestionType.single,
    this.explanation,
    this.points = 1,
    this.answers = const [],
  });

  final String id;
  String questionText;
  QuestionType questionType;
  String? explanation;
  int points;
  List<_AnswerData> answers;

  factory _QuestionData.fromEntity(QuizQuestionEntity entity) {
    return _QuestionData(
      id: entity.id,
      questionText: entity.questionText,
      questionType: entity.questionType,
      explanation: entity.explanation,
      points: entity.points,
      answers:
          entity.answers.map((a) => _AnswerData.fromEntity(a)).toList(),
    );
  }
}

class _AnswerData {
  _AnswerData({
    required this.id,
    required this.answerText,
    this.isCorrect = false,
  });

  final String id;
  String answerText;
  bool isCorrect;

  factory _AnswerData.fromEntity(QuizAnswerEntity entity) {
    return _AnswerData(
      id: entity.id,
      answerText: entity.answerText,
      isCorrect: entity.isCorrect,
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
  });

  final int index;
  final _QuestionData question;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.questionText.isEmpty
                            ? 'سؤال جديد'
                            : question.questionText,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text(question.questionType.displayName),
                            visualDensity: VisualDensity.compact,
                            labelStyle: theme.textTheme.labelSmall,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${question.points} نقطة',
                            style: theme.textTheme.labelSmall,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${question.answers.length} إجابة',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'duplicate':
                        onDuplicate();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 12),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.copy),
                          SizedBox(width: 12),
                          Text('نسخ'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'حذف',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionEditorDialog extends StatefulWidget {
  const _QuestionEditorDialog({required this.question});

  final _QuestionData question;

  @override
  State<_QuestionEditorDialog> createState() => _QuestionEditorDialogState();
}

class _QuestionEditorDialogState extends State<_QuestionEditorDialog> {
  late TextEditingController _questionController;
  late TextEditingController _explanationController;
  late TextEditingController _pointsController;
  late QuestionType _questionType;
  late List<_AnswerData> _answers;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question.questionText);
    _explanationController =
        TextEditingController(text: widget.question.explanation ?? '');
    _pointsController =
        TextEditingController(text: widget.question.points.toString());
    _questionType = widget.question.questionType;
    _answers = List.from(widget.question.answers);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('تعديل السؤال'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'نص السؤال',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<QuestionType>(
                      value: _questionType,
                      decoration: const InputDecoration(
                        labelText: 'نوع السؤال',
                      ),
                      items: QuestionType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _questionType = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _pointsController,
                      decoration: const InputDecoration(
                        labelText: 'النقاط',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _explanationController,
                decoration: const InputDecoration(
                  labelText: 'شرح الإجابة (اختياري)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الإجابات',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _addAnswer,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._answers.asMap().entries.map((entry) {
                final index = entry.key;
                final answer = entry.value;
                return _AnswerRow(
                  answer: answer,
                  questionType: _questionType,
                  onChanged: (newAnswer) {
                    setState(() {
                      _answers[index] = newAnswer;
                    });
                  },
                  onDelete: () {
                    setState(() {
                      _answers.removeAt(index);
                    });
                  },
                  onCorrectChanged: (isCorrect) {
                    setState(() {
                      if (_questionType == QuestionType.single ||
                          _questionType == QuestionType.trueFalse) {
                        // Single choice - uncheck others
                        for (var a in _answers) {
                          a.isCorrect = false;
                        }
                      }
                      _answers[index].isCorrect = isCorrect;
                    });
                  },
                );
              }),
              if (_questionType == QuestionType.trueFalse && _answers.isEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _answers = [
                        _AnswerData(
                          id: '1',
                          answerText: 'صح',
                          isCorrect: true,
                        ),
                        _AnswerData(
                          id: '2',
                          answerText: 'خطأ',
                          isCorrect: false,
                        ),
                      ];
                    });
                  },
                  child: const Text('إضافة صح / خطأ'),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(
              context,
              _QuestionData(
                id: widget.question.id,
                questionText: _questionController.text.trim(),
                questionType: _questionType,
                explanation: _explanationController.text.trim().isEmpty
                    ? null
                    : _explanationController.text.trim(),
                points: int.tryParse(_pointsController.text) ?? 1,
                answers: _answers,
              ),
            );
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }

  void _addAnswer() {
    setState(() {
      _answers.add(_AnswerData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        answerText: '',
        isCorrect: false,
      ));
    });
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.answer,
    required this.questionType,
    required this.onChanged,
    required this.onDelete,
    required this.onCorrectChanged,
  });

  final _AnswerData answer;
  final QuestionType questionType;
  final Function(_AnswerData) onChanged;
  final VoidCallback onDelete;
  final Function(bool) onCorrectChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (questionType == QuestionType.multiple)
            Checkbox(
              value: answer.isCorrect,
              onChanged: (value) => onCorrectChanged(value ?? false),
            )
          else
            Radio<bool>(
              value: true,
              groupValue: answer.isCorrect,
              onChanged: (value) => onCorrectChanged(true),
            ),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'نص الإجابة',
                isDense: true,
              ),
              controller: TextEditingController(text: answer.answerText),
              onChanged: (value) {
                onChanged(_AnswerData(
                  id: answer.id,
                  answerText: value,
                  isCorrect: answer.isCorrect,
                ));
              },
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.remove_circle_outline,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
