import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chaoxing_ft/presentation/providers/quiz_provider.dart';
import 'package:chaoxing_ft/presentation/widgets/quiz_widgets.dart';
import 'package:chaoxing_ft/domain/entities/quiz.dart';

/// Quiz page for displaying quiz list
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String? _chapterId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _chapterId = args?['chapterId'] as String?;

    if (_chapterId != null) {
      Provider.of<QuizProvider>(context, listen: false).fetchQuizzesForChapter(_chapterId!);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('错误: 章节ID缺失')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('测验'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_chapterId != null) {
                Provider.of<QuizProvider>(context, listen: false).fetchQuizzesForChapter(_chapterId!);
              }
            },
          ),
        ],
      ),
      body: _chapterId != null
          ? QuizListWidget(chapterId: _chapterId!)
          : const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '章节ID缺失',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
    );
  }
}

/// Quiz taking page
class QuizTakingPage extends StatefulWidget {
  const QuizTakingPage({super.key});

  @override
  State<QuizTakingPage> createState() => _QuizTakingPageState();
}

class _QuizTakingPageState extends State<QuizTakingPage> {
  String? _quizId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _quizId = args?['quizId'] as String?;

    if (_quizId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('错误: 测验ID缺失')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _quizId != null
        ? QuizTakingWidget(quizId: _quizId!)
        : const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '测验ID缺失',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
  }
}

/// Quiz results page
class QuizResultsPage extends StatefulWidget {
  const QuizResultsPage({super.key});

  @override
  State<QuizResultsPage> createState() => _QuizResultsPageState();
}

class _QuizResultsPageState extends State<QuizResultsPage> {
  String? _quizId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _quizId = args?['quizId'] as String?;

    if (_quizId != null) {
      Provider.of<QuizProvider>(context, listen: false).getQuizResults(_quizId!);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('错误: 测验ID缺失')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('测验结果'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_quizId != null) {
                Provider.of<QuizProvider>(context, listen: false).getQuizResults(_quizId!);
              }
            },
          ),
        ],
      ),
      body: Consumer<QuizProvider>(
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
            return const Center(child: Text('测验结果加载失败'));
          }

          final quiz = quizProvider.currentQuiz!;
          return _buildResultsContent(quiz);
        },
      ),
    );
  }

  Widget _buildResultsContent(Quiz quiz) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuizSummary(quiz),
          const SizedBox(height: 24),
          _buildScoreCard(quiz),
          const SizedBox(height: 24),
          _buildQuestionResults(quiz),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildQuizSummary(Quiz quiz) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quiz.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (quiz.description != null) ...[
              const SizedBox(height: 8),
              Text(
                quiz.description!,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSummaryItem('题目数量', '${quiz.totalQuestions}'),
                const SizedBox(width: 24),
                _buildSummaryItem('答题数量', '${quiz.answeredQuestions}'),
                const SizedBox(width: 24),
                _buildSummaryItem('正确数量', '${quiz.correctAnswers}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSummaryItem('准确率', '${(quiz.accuracy * 100).toInt()}%'),
                const SizedBox(width: 24),
                _buildSummaryItem('完成时间', quiz.formattedDuration),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildScoreCard(Quiz quiz) {
    final score = quiz.score ?? 0.0;
    final scorePercentage = (score * 100).toInt();
    final isPassed = quiz.isPassed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              '测验分数',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: score,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isPassed ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                Text(
                  '$scorePercentage%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isPassed ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isPassed ? '恭喜通过！' : '需要重试',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPassed ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionResults(Quiz quiz) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '题目详情',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...quiz.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return _buildQuestionResultItem(index + 1, question);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionResultItem(int questionNumber, Question question) {
    final isCorrect = question.isCorrect;
    final userAnswer = question.userAnswer;
    final correctAnswer = question.correctAnswers.join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '题目 $questionNumber',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.text,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '你的答案: ${userAnswer ?? "未回答"}',
            style: TextStyle(
              fontSize: 12,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 4),
            Text(
              '正确答案: $correctAnswer',
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],
          if (question.explanation != null) ...[
            const SizedBox(height: 8),
            Text(
              '解析: ${question.explanation}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('返回'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to quiz list or retry
              Navigator.of(context).pop();
            },
            child: const Text('重新测验'),
          ),
        ),
      ],
    );
  }
}
