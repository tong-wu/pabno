class QuestionOption < EnumerateIt::Base
  associate_values(
      yes:  [1, 'Yes'],
      no:   [2, 'No']
  )
end