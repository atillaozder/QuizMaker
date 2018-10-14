from django.apps import AppConfig


class QuizConfig(AppConfig):
    name = 'quiz'

    def ready(self):
        import apps.quiz.signals
