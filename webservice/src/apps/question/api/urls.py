from django.urls import path, include

from .views import (
    QuestionCreateAPIView,
    QuestionUpdateAPIView,
    QuestionDeleteAPIView,
    ParticipantAnswerCreateAPIView,
    ParticipantValidateQuestionAPIView,
)

app_name = "api_question"

urlpatterns = [
    path('create', QuestionCreateAPIView.as_view()),
    path('update/<pk>', QuestionUpdateAPIView.as_view()),
    path('delete/<pk>', QuestionDeleteAPIView.as_view()),
    path('answers/create', ParticipantAnswerCreateAPIView.as_view()),
    path('answers/update/<pk>', ParticipantValidateQuestionAPIView.as_view()),
]
