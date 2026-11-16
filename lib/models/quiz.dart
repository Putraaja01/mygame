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

  const QuizGame({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
  });
}
