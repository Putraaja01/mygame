class QuizQuestion {
  final String prompt;
  final String answer;
  final String? category;

  const QuizQuestion(this.prompt, this.answer, {this.category});
}

class QuizGame {
  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;

  /// Koin yang didapat setiap jawaban benar di game ini.
  final int coinPerCorrect;

  const QuizGame({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    this.coinPerCorrect = 5,
  });
}
