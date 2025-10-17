import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chaoxing_ft/presentation/providers/quiz_provider.dart';
import 'package:chaoxing_ft/domain/entities/quiz.dart';

/// Quiz list widget
class QuizListWidget extends StatelessWidget {

  const QuizListWidget({
    super.key,
    required this.chapterId,
  });
  final String chapterId;

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (quizProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (quizProvider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                quizProvider.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (quizProvider.quizzes.isEmpty) {
          return const Center(child: Text('没有找到测验'));
        }

        return ListView.builder(
          itemCount: quizProvider.quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizProvider.quizzes[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(quiz.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (quiz.description != null) Text(quiz.description!),
                    Text('题目数量: ${quiz.totalQuestions}'),
                    if (quiz.timeLimit != null) Text('时间限制: ${quiz.formattedTimeLimit}'),
                    if (quiz.attemptLimit != null) Text('尝试次数: ${quiz.attemptLimit}'),
                    if (quiz.score != null) Text('分数: ${quiz.formattedScore}'),
                  ],
                ),
                trailing: _buildQuizStatus(quiz),
                onTap: () => _navigateToQuiz(context, quiz),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuizStatus(Quiz quiz) {
    if (quiz.isCompleted) {
      return Icon(
        quiz.isPassed ? Icons.check_circle : Icons.cancel,
        color: quiz.isPassed ? Colors.green : Colors.red,
      );
    }
    return const Icon(Icons.quiz);
  }

  void _navigateToQuiz(BuildContext context, Quiz quiz) {
    Navigator.of(context).pushNamed('/quiz', arguments: {'quizId': quiz.id});
  }
}

/// Quiz taking widget
class QuizTakingWidget extends StatefulWidget {

  const QuizTakingWidget({
    super.key,
    required this.quizId,
  });
  final String quizId;

  @override
  State<QuizTakingWidget> createState() => _QuizTakingWidgetState();
}

class _QuizTakingWidgetState extends State<QuizTakingWidget> {
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizProvider>(context, listen: false).startQuiz(widget.quizId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (quizProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (quizProvider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                quizProvider.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (quizProvider.currentQuiz == null) {
          return const Center(child: Text('测验加载失败'));
        }

        final quiz = quizProvider.currentQuiz!;
        final questions = quiz.questions;

        if (questions.isEmpty) {
          return const Center(child: Text('没有找到题目'));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(quiz.name),
            actions: [
              if (quiz.timeLimit != null)
                _buildTimer(quiz),
            ],
          ),
          body: Column(
            children: [
              _buildProgressBar(quizProvider),
              Expanded(
                child: PageView.builder(
                  controller: PageController(initialPage: _currentQuestionIndex),
                  onPageChanged: (index) {
                    setState(() {
                      _currentQuestionIndex = index;
                    });
                  },
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    return QuestionWidget(
                      question: questions[index],
                      questionIndex: index + 1,
                      totalQuestions: questions.length,
                    );
                  },
                ),
              ),
              _buildNavigationButtons(quizProvider, questions.length),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimer(Quiz quiz) {
    return StreamBuilder<Duration?>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => quiz.remainingTime),
      builder: (context, snapshot) {
        final remaining = snapshot.data;
        if (remaining == null) return const SizedBox.shrink();

        final minutes = remaining.inMinutes;
        final seconds = remaining.inSeconds.remainder(60);
        final color = remaining.inMinutes < 5 ? Colors.red : Colors.white;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(QuizProvider quizProvider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: quizProvider.progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            '进度: ${quizProvider.answeredQuestionsCount}/${quizProvider.currentQuiz?.totalQuestions ?? 0}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(QuizProvider quizProvider, int totalQuestions) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentQuestionIndex > 0
                ? () {
                    setState(() {
                      _currentQuestionIndex--;
                    });
                  }
                : null,
            child: const Text('上一题'),
          ),
          ElevatedButton(
            onPressed: _currentQuestionIndex < totalQuestions - 1
                ? () {
                    setState(() {
                      _currentQuestionIndex++;
                    });
                  }
                : null,
            child: const Text('下一题'),
          ),
          ElevatedButton(
            onPressed: () => _submitQuiz(quizProvider),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('提交测验'),
          ),
        ],
      ),
    );
  }

  void _submitQuiz(QuizProvider quizProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提交测验'),
        content: const Text('确定要提交测验吗？提交后将无法修改答案。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              quizProvider.submitQuiz(widget.quizId, quizProvider.currentAnswers);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// Question widget
class QuestionWidget extends StatelessWidget {

  const QuestionWidget({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
  });
  final Question question;
  final int questionIndex;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '题目 $questionIndex/$totalQuestions',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                question.text,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Text(
                '类型: ${question.type.displayName}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              _buildQuestionContent(question, quizProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionContent(Question question, QuizProvider quizProvider) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoiceOptions(question, quizProvider);
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceOptions(question, quizProvider);
      case QuestionType.trueFalse:
        return _buildTrueFalseOptions(question, quizProvider);
      case QuestionType.fillInBlank:
        return _buildFillInBlankInput(question, quizProvider);
      case QuestionType.essay:
        return _buildEssayInput(question, quizProvider);
      default:
        return const Text('不支持的问题类型');
    }
  }

  Widget _buildSingleChoiceOptions(Question question, QuizProvider quizProvider) {
    return Column(
      children: question.options.map((option) {
        final isSelected = quizProvider.getAnswer(question.id) == option.id;
        return RadioListTile<String>(
          title: Text(option.text),
          value: option.id,
          groupValue: quizProvider.getAnswer(question.id),
          onChanged: (value) {
            if (value != null) {
              quizProvider.updateAnswer(question.id, value);
            }
          },
          selected: isSelected,
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoiceOptions(Question question, QuizProvider quizProvider) {
    final selectedAnswers = quizProvider.getAnswer(question.id)?.split(',') ?? [];
    
    return Column(
      children: question.options.map((option) {
        final isSelected = selectedAnswers.contains(option.id);
        return CheckboxListTile(
          title: Text(option.text),
          value: isSelected,
          onChanged: (value) {
            final newAnswers = List<String>.from(selectedAnswers);
            if (value == true) {
              if (!newAnswers.contains(option.id)) {
                newAnswers.add(option.id);
              }
            } else {
              newAnswers.remove(option.id);
            }
            quizProvider.updateAnswer(question.id, newAnswers.join(','));
          },
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalseOptions(Question question, QuizProvider quizProvider) {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('正确'),
          value: 'true',
          groupValue: quizProvider.getAnswer(question.id),
          onChanged: (value) {
            if (value != null) {
              quizProvider.updateAnswer(question.id, value);
            }
          },
        ),
        RadioListTile<String>(
          title: const Text('错误'),
          value: 'false',
          groupValue: quizProvider.getAnswer(question.id),
          onChanged: (value) {
            if (value != null) {
              quizProvider.updateAnswer(question.id, value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildFillInBlankInput(Question question, QuizProvider quizProvider) {
    return TextField(
      decoration: const InputDecoration(
        hintText: '请输入答案',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        quizProvider.updateAnswer(question.id, value);
      },
      controller: TextEditingController(text: quizProvider.getAnswer(question.id) ?? ''),
    );
  }

  Widget _buildEssayInput(Question question, QuizProvider quizProvider) {
    return TextField(
      decoration: const InputDecoration(
        hintText: '请输入答案',
        border: OutlineInputBorder(),
      ),
      maxLines: 5,
      onChanged: (value) {
        quizProvider.updateAnswer(question.id, value);
      },
      controller: TextEditingController(text: quizProvider.getAnswer(question.id) ?? ''),
    );
  }
}
