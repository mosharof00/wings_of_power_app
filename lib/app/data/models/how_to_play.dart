class HowToStepModel {
  final int step;
  final String title;
  final String body;

  HowToStepModel({
    required this.step,
    required this.title,
    required this.body,
  });

  factory HowToStepModel.fromJson(Map<String, dynamic> json) {
    return HowToStepModel(
      step: (json['step'] as num?)?.toInt() ?? 1,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'step': step,
        'title': title,
        'body': body,
      };
}

class HowToPlayModel {
  final List<HowToStepModel> steps;

  HowToPlayModel({required this.steps});

  factory HowToPlayModel.fromJson(dynamic json) {
    if (json is List) {
      return HowToPlayModel(
        steps: json
            .map((item) => HowToStepModel.fromJson(
                  item is Map<String, dynamic>
                      ? item
                      : Map<String, dynamic>.from(item as Map),
                ))
            .toList(),
      );
    } else if (json is Map) {
      final stepsList = json['steps'] ?? json['items'] ?? json['data'];
      if (stepsList is List) {
        return HowToPlayModel(
          steps: stepsList
              .map((item) => HowToStepModel.fromJson(
                    item is Map<String, dynamic>
                        ? item
                        : Map<String, dynamic>.from(item as Map),
                  ))
              .toList(),
        );
      }
    }
    return HowToPlayModel(steps: defaultSteps);
  }

  static List<HowToStepModel> get defaultSteps => [
        HowToStepModel(
          step: 1,
          title: 'Choose the play mode',
          body: 'You can play only with one player as well as team members.',
        ),
        HowToStepModel(
          step: 2,
          title: 'Hit the red buzzer',
          body:
              'The first who buzz gets to answer the question. You have 10 seconds and you can pass once to a teammate.',
        ),
        HowToStepModel(
          step: 3,
          title: 'Steal the point',
          body: 'If the answer is wrong, your opponent can steal!',
        ),
        HowToStepModel(
          step: 4,
          title: 'Earn Shootout Balls',
          body:
              'Every correct answer earns a ball for the Shootout after each round.',
        ),
        HowToStepModel(
          step: 5,
          title: 'Highest total wins',
          body: 'Points from all 4 rounds add up.',
        ),
      ];
}

