import 'course_models.dart';

/// Sample courses so the platform has content on day one.
/// IMPORTANT: module titles, lesson text, prices and instructor are
/// PLACEHOLDERS. Replace with MT Alchemy's real course content.
List<Course> sampleCourses() {
  const lessonBody =
      'Work through this lesson at your own pace, reflect on the key ideas '
      'and complete the activity before moving on.';

  List<Lesson> lessons(List<String> titles, {Map<String, String> types = const {}}) {
    return [
      for (var i = 0; i < titles.length; i++)
        Lesson(
          title: titles[i],
          type: types[titles[i]] ?? (i == 0 ? 'video' : 'text'),
          body: lessonBody,
          minutes: i == 0 ? 12 : 8,
        ),
    ];
  }

  const instructor = 'Mabel Tan KH';

  return [
    Course(
      id: 'emotional-intelligence',
      title: 'Emotional Intelligence',
      category: 'People Skills',
      description:
          'Understand yourself, connect with others and lead with awareness.',
      about:
          'A practical course on building self-awareness, managing emotions and strengthening relationships at work and in life.',
      instructor: instructor,
      level: 'Beginner',
      durationHours: 5,
      price: 149,
      image: 'assets/images/team_collaboration.png',
      accent: 'purple',
      audience: 'Professionals and individuals who want stronger self-awareness and relationships.',
      objectives: const [
        'Recognise your emotions and their impact on your behaviour.',
        'Respond to pressure with greater calm and clarity.',
        'Listen with empathy and communicate with care.',
        'Build stronger, more trusting relationships.',
      ],
      requirements: const ['No prior experience needed.'],
      modules: [
        CourseModule(title: 'Self-Awareness', lessons: lessons(['What is Emotional Intelligence?', 'Naming Your Emotions', 'Your Emotional Triggers'])),
        CourseModule(title: 'Self-Regulation', lessons: lessons(['Pausing Before Reacting', 'Managing Stress', 'Staying Resilient'])),
        CourseModule(title: 'Empathy & Social Awareness', lessons: lessons(['Understanding Others', 'Active Listening', 'Reading the Room'])),
        CourseModule(title: 'Relationship Management', lessons: lessons(['Clear Communication', 'Handling Conflict', 'Giving Feedback'])),
        CourseModule(title: 'Putting EQ into Practice', lessons: lessons(['Your EQ Action Plan', 'Daily Habits', 'Final Reflection'], types: {'Your EQ Action Plan': 'pdf'})),
      ],
      assessment: Assessment(passingScore: 60, questions: [
        Question.single('Which best describes emotional intelligence?', ['Being the smartest person in the room', 'Recognising and managing your own and others\' emotions', 'Avoiding all strong feelings', 'Always agreeing with others'], 1, explanation: 'Emotional intelligence is the ability to recognise and manage emotions in yourself and others.'),
        Question.trueFalse('Pausing before reacting can help you respond more calmly.', true, explanation: 'A short pause creates space to choose a considered response.'),
        Question.multiple('Which are part of active listening? (select all that apply)', ['Giving the speaker your full attention', 'Planning your reply while they talk', 'Checking you understood', 'Interrupting with advice'], [0, 2], explanation: 'Active listening means paying attention and confirming understanding.'),
        Question.short('Complete the phrase: self-______ is knowing your own emotions and triggers.', ['awareness'], explanation: 'Self-awareness is the foundation of emotional intelligence.'),
      ]),
    ),
    Course(
      id: 'leadership-development',
      title: 'Leadership Development',
      category: 'Leadership',
      description:
          'Build practical leadership habits for real workplace situations.',
      about:
          'This learning experience helps participants strengthen leadership awareness, communication and decision-making through practical activities and reflection.',
      instructor: instructor,
      level: 'Intermediate',
      durationHours: 8,
      price: 249,
      featured: true,
      image: 'assets/images/leadership_discussion.png',
      accent: 'blue',
      audience: 'New and emerging leaders, team leads and managers.',
      objectives: const [
        'Recognise your leadership strengths and development areas.',
        'Communicate with greater clarity, empathy and confidence.',
        'Apply practical leadership behaviours in workplace situations.',
        'Build stronger relationships and more engaged teams.',
      ],
      requirements: const ['Some experience leading or influencing others is helpful.'],
      modules: [
        CourseModule(title: 'Understanding Your Leadership Style', lessons: lessons(['Introduction to Leadership', 'Discovering Your Leadership Style', 'Strengths and Development Areas', 'Leadership Reflection'])),
        CourseModule(title: 'Communication & Influence', lessons: lessons(['Effective Communication', 'Active Listening', 'Influencing Others', 'Building Trust', 'Communication Practice'])),
        CourseModule(title: 'Leading Difficult Conversations', lessons: lessons(['Understanding Difficult Conversations', 'Preparing for Challenging Discussions', 'Managing Emotions', 'Conversation Practice'])),
        CourseModule(title: 'Building High-Trust Teams', lessons: lessons(['What Makes a High-Trust Team?', 'Team Collaboration', 'Psychological Safety', 'Giving Feedback', 'Team Activity'])),
        CourseModule(title: 'Decision Making & Accountability', lessons: lessons(['Making Better Decisions', 'Taking Ownership', 'Accountability in Teams', 'Decision-Making Practice'])),
        CourseModule(title: 'From Insight to Impact', lessons: lessons(['Turning Learning into Action', 'Creating Your Action Plan', 'Final Reflection'], types: {'Creating Your Action Plan': 'pdf'})),
      ],
      assessment: Assessment(passingScore: 60, questions: [
        Question.single('What is one important quality of an effective leader?', ['Avoiding feedback', 'Clear communication', 'Making every decision alone', 'Ignoring team concerns'], 1, explanation: 'Clear communication helps people understand direction and expectations.'),
        Question.single('What does active listening involve?', ['Interrupting to give advice', 'Thinking only about your reply', 'Paying attention and understanding the speaker', 'Changing the subject quickly'], 2, explanation: 'Active listening is about attention and understanding, not preparing your reply.'),
        Question.trueFalse('Leaders build trust by being consistent and accountable.', true, explanation: 'Consistency and accountability show people they can rely on you.'),
        Question.multiple('Which behaviours help build a high-trust team? (select all that apply)', ['Being consistent and accountable', 'Sharing important information openly', 'Avoiding difficult conversations', 'Taking credit for others\' work'], [0, 1], explanation: 'Trust grows through consistency, openness and accountability.'),
        Question.single('What should a leader do after receiving constructive feedback?', ['Reject it immediately', 'Blame the team', 'Ignore it', 'Reflect on it and identify improvements'], 3, explanation: 'Reflecting on feedback turns it into growth.'),
        Question.short('Complete the phrase: a leadership action plan turns learning into ______.', ['action', 'practice'], explanation: 'An action plan turns insight into practical action.'),
      ]),
    ),
    Course(
      id: 'team-engagement',
      title: 'Team Engagement',
      category: 'Team Engagement',
      description: 'Create connected, motivated and collaborative teams.',
      about:
          'Learn what drives engagement and how to build habits that keep teams connected, motivated and collaborating well.',
      instructor: instructor,
      level: 'Beginner',
      durationHours: 4,
      price: 129,
      image: 'assets/images/upskilling_workspace.png',
      accent: 'yellow',
      audience: 'Team leaders, HR practitioners and anyone responsible for team culture.',
      objectives: const [
        'Understand what drives engagement in a team.',
        'Improve communication and collaboration.',
        'Build trust and psychological safety.',
        'Sustain momentum after team activities.',
      ],
      requirements: const ['No prior experience needed.'],
      modules: [
        CourseModule(title: 'What Drives Engagement', lessons: lessons(['Why Engagement Matters', 'Signs of a Disengaged Team', 'Engagement Drivers'])),
        CourseModule(title: 'Communication in Teams', lessons: lessons(['Open Communication', 'Team Meetings That Work', 'Feedback Loops'])),
        CourseModule(title: 'Collaboration & Trust', lessons: lessons(['Building Trust', 'Working Across Differences', 'Team Activity'])),
        CourseModule(title: 'Sustaining Momentum', lessons: lessons(['Recognition and Celebration', 'Your Team Action Plan', 'Final Reflection'], types: {'Your Team Action Plan': 'pdf'})),
      ],
      assessment: Assessment(passingScore: 60, questions: [
        Question.single('Which is a common sign of a disengaged team?', ['High energy in meetings', 'Low participation and little initiative', 'Frequent knowledge sharing', 'Strong team spirit'], 1, explanation: 'Low participation and initiative often signal disengagement.'),
        Question.trueFalse('Recognition and celebration can help sustain team momentum.', true, explanation: 'Regular recognition keeps people motivated.'),
        Question.multiple('Which help build collaboration? (select all that apply)', ['Open communication', 'Working in silos', 'Shared goals', 'Withholding feedback'], [0, 2], explanation: 'Open communication and shared goals support collaboration.'),
        Question.single('What is the purpose of a team action plan?', ['To avoid goals', 'To turn ideas into agreed actions', 'To replace communication', 'To stop team activities'], 1, explanation: 'A team action plan turns ideas into agreed actions.'),
      ]),
    ),
    Course(
      id: 'workplace-wellbeing',
      title: 'Workplace Well-being',
      category: 'Well-being',
      description:
          'Build healthier habits and create a more supportive workplace.',
      about:
          'Explore stress, burnout and mindfulness, and learn how to build a workplace culture that supports well-being.',
      instructor: instructor,
      level: 'Beginner',
      durationHours: 4,
      price: 99,
      image: 'assets/images/hero_office.png',
      accent: 'green',
      audience: 'Employees, managers and HR teams who care about well-being at work.',
      objectives: const [
        'Recognise early signs of stress and burnout.',
        'Practise simple mindfulness techniques at work.',
        'Set healthy boundaries and routines.',
        'Contribute to a more supportive workplace culture.',
      ],
      requirements: const ['No prior experience needed.'],
      modules: [
        CourseModule(title: 'Understanding Workplace Well-being', lessons: lessons(['What Well-being Means at Work', 'The Cost of Ignoring It', 'Your Well-being Check-in'])),
        CourseModule(title: 'Managing Stress and Burnout', lessons: lessons(['Recognising Stress', 'Preventing Burnout', 'Recovery Habits'])),
        CourseModule(title: 'Mindfulness at Work', lessons: lessons(['Mindful Breathing', 'Mindful Communication', 'Short Resets'], types: {'Mindful Breathing': 'audio'})),
        CourseModule(title: 'Building a Supportive Culture', lessons: lessons(['Supporting Colleagues', 'Healthy Boundaries', 'Your Well-being Plan'])),
      ],
      assessment: Assessment(passingScore: 60, questions: [
        Question.single('Which is an early sign of burnout?', ['Constant energy', 'Persistent exhaustion and detachment', 'Improved focus', 'Better sleep'], 1, explanation: 'Persistent exhaustion and detachment are common early signs.'),
        Question.trueFalse('Short mindful breathing breaks can help reset stress at work.', true, explanation: 'Brief resets can lower stress and restore focus.'),
        Question.multiple('Which support a healthier workplace? (select all that apply)', ['Healthy boundaries', 'Supporting colleagues', 'Ignoring workload', 'Regular recovery breaks'], [0, 1, 3], explanation: 'Boundaries, support and recovery all protect well-being.'),
        Question.short('Complete the phrase: setting healthy ______ helps protect your time and energy.', ['boundaries', 'boundary'], explanation: 'Healthy boundaries protect your time and energy.'),
      ]),
    ),
  ];
}
