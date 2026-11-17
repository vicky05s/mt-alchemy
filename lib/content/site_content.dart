import 'package:flutter/material.dart';

/// PLACEHOLDER COPY. The service names, challenge/solution lists and impact
/// figure come from the employer brief. Descriptions, programme details,
/// prices and FAQs below are drafted to fit those and must be replaced with
/// MT Alchemy's real material before launch.

class ServiceCategory {
  final String id;
  final String title;
  final IconData icon;
  final String summary;
  final String audience;
  final List<String> objectives;
  final String enquiryType; // must match an option in the contact form

  const ServiceCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.summary,
    required this.audience,
    required this.objectives,
    required this.enquiryType,
  });
}

const serviceCategories = <ServiceCategory>[
  ServiceCategory(
    id: 'ei-mindfulness',
    title: 'Emotional Intelligence & Mindfulness',
    icon: Icons.psychology_outlined,
    summary:
        'Practical sessions that build self-awareness, emotional regulation and mindful habits at work.',
    audience: 'Teams and individuals at every level of an organisation.',
    objectives: [
      'Recognise emotions and their effect on behaviour.',
      'Respond to pressure with greater calm and clarity.',
      'Build simple mindfulness habits for the workday.',
    ],
    enquiryType: 'Corporate Training',
  ),
  ServiceCategory(
    id: 'leadership-communication',
    title: 'Leadership & Communication',
    icon: Icons.record_voice_over_outlined,
    summary:
        'Develop leaders who communicate with clarity, empathy and confidence.',
    audience: 'Emerging leaders, managers and senior leadership teams.',
    objectives: [
      'Strengthen leadership awareness and style.',
      'Hold clear, constructive conversations.',
      'Build trust and accountability in teams.',
    ],
    enquiryType: 'Leadership Development',
  ),
  ServiceCategory(
    id: 'wellbeing-assessment',
    title: 'Organization Well-being Assessment',
    icon: Icons.monitor_heart_outlined,
    summary:
        'Understand how people are really doing, and where to focus support.',
    audience: 'HR leaders and management teams planning well-being initiatives.',
    objectives: [
      'Identify stress, burnout and engagement risks.',
      'Gather honest feedback from employees.',
      'Prioritise practical next steps.',
    ],
    enquiryType: 'Corporate Training',
  ),
  ServiceCategory(
    id: 'team-effectiveness',
    title: 'Team Building & Team Effectiveness',
    icon: Icons.groups_outlined,
    summary:
        'Help teams connect, collaborate and work through conflict together.',
    audience: 'Teams that want stronger collaboration and trust.',
    objectives: [
      'Improve communication and collaboration.',
      'Build psychological safety.',
      'Turn team activities into lasting habits.',
    ],
    enquiryType: 'Team Development',
  ),
  ServiceCategory(
    id: 'csr-esg',
    title: 'CSR & ESG',
    icon: Icons.volunteer_activism_outlined,
    summary:
        'People-centred CSR and ESG programmes that create meaningful community impact.',
    audience: 'Organisations planning CSR or ESG initiatives with a people focus.',
    objectives: [
      'Design programmes aligned with your values.',
      'Engage employees and communities.',
      'Measure and share the impact.',
    ],
    enquiryType: 'Partnership',
  ),
  ServiceCategory(
    id: 'customized',
    title: 'Customized Programmes',
    icon: Icons.tune_outlined,
    summary:
        'Programmes shaped around your people, goals and workforce demographics.',
    audience: 'Organisations with specific goals or diverse teams.',
    objectives: [
      'Understand your context and goals.',
      'Adapt content for your workforce.',
      'Deliver, review and refine.',
    ],
    enquiryType: 'Corporate Training',
  ),
];

const organizationalChallenges = <String>[
  'Employee burnout',
  'Rising stress',
  'Communication breakdowns',
  'Team conflicts',
  'Leadership gaps',
  'Low employee engagement',
  'High turnover',
];

const organizationalSolutions = <(String, IconData)>[
  ('Leadership Development', Icons.trending_up),
  ('Emotional Intelligence', Icons.psychology_outlined),
  ('Team Effectiveness', Icons.groups_outlined),
  ('Communication', Icons.record_voice_over_outlined),
  ('Workplace Well-being', Icons.favorite_border),
  ('Organizational Development', Icons.account_tree_outlined),
  ('CSR & ESG', Icons.volunteer_activism_outlined),
  ('Customized Training', Icons.tune_outlined),
];

/// Number from the brief.
const participantsImpacted = '1,100+';

class Programme {
  final String id;
  final String title;
  final String type; // Public Programme | Corporate Programme
  final String description;
  final List<String> objectives;
  final String audience;
  final String duration;
  final String participants;
  final String delivery;
  final List<String> modules;
  final String trainer;
  final double? price; // per person; null = request a quote

  const Programme({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.objectives,
    required this.audience,
    required this.duration,
    required this.participants,
    required this.delivery,
    required this.modules,
    required this.trainer,
    this.price,
  });

  bool get isPublic => type == 'Public Programme';
}

const programmes = <Programme>[
  Programme(
    id: 'ei-at-work',
    title: 'Emotional Intelligence at Work',
    type: 'Public Programme',
    description:
        'A practical workshop on self-awareness, emotional regulation and empathy in the workplace.',
    objectives: [
      'Name and understand your emotions.',
      'Respond rather than react under pressure.',
      'Build stronger working relationships.',
    ],
    audience: 'Professionals from any organisation.',
    duration: '1 day',
    participants: 'Up to 30',
    delivery: 'In person or online',
    modules: ['Self-awareness', 'Self-regulation', 'Empathy', 'Relationships'],
    trainer: 'Mabel Tan KH',
    price: 350,
  ),
  Programme(
    id: 'mindful-teams',
    title: 'Mindfulness for Teams',
    type: 'Public Programme',
    description:
        'Simple mindfulness practices that help people focus and reset during the working day.',
    objectives: [
      'Practise short mindfulness techniques.',
      'Reduce stress during busy days.',
      'Build a shared habit of mindful pauses.',
    ],
    audience: 'Teams and individuals who want calmer, more focused days.',
    duration: 'Half day',
    participants: 'Up to 30',
    delivery: 'In person or online',
    modules: ['Mindful breathing', 'Mindful communication', 'Short resets'],
    trainer: 'Mabel Tan KH',
    price: 220,
  ),
  Programme(
    id: 'leadership-communication',
    title: 'Leadership & Communication Programme',
    type: 'Corporate Programme',
    description:
        'A tailored programme to build confident, empathetic leaders and clearer communication across your organisation.',
    objectives: [
      'Discover your leadership style.',
      'Lead difficult conversations well.',
      'Create a culture of trust and accountability.',
    ],
    audience: 'Leaders and managers in your organisation.',
    duration: 'Customised',
    participants: 'Agreed with you',
    delivery: 'On-site, online or blended',
    modules: ['Leadership style', 'Communication', 'Difficult conversations', 'Action planning'],
    trainer: 'Mabel Tan KH',
  ),
  Programme(
    id: 'team-engagement',
    title: 'Team Engagement Programme',
    type: 'Corporate Programme',
    description:
        'Build connection, collaboration and momentum with a programme designed around your team.',
    objectives: [
      'Understand what drives engagement.',
      'Improve collaboration and trust.',
      'Sustain momentum after the programme.',
    ],
    audience: 'Teams of any size.',
    duration: 'Customised',
    participants: 'Agreed with you',
    delivery: 'On-site, online or blended',
    modules: ['Engagement drivers', 'Team communication', 'Collaboration', 'Sustaining momentum'],
    trainer: 'Mabel Tan KH',
  ),
];

const coachingFocus = <(String, IconData, String)>[
  ('Career guidance', Icons.explore_outlined, 'Clarity on your direction, strengths and next steps.'),
  ('Career transitions', Icons.swap_horiz_rounded, 'Support through a change of role, industry or stage.'),
  ('Relationships', Icons.people_outline, 'Better communication and connection at work and at home.'),
  ('Personal development', Icons.self_improvement_outlined, 'Build confidence, resilience and healthy habits.'),
];

const coachingSteps = <(String, String)>[
  ('Book a session', 'Tell us what you would like to work on.'),
  ('Discovery conversation', 'We talk through your goals and how coaching can help.'),
  ('Coaching sessions', 'Work one-to-one on practical steps, at your pace.'),
  ('Review and grow', 'Reflect on progress and plan what comes next.'),
];

const coachingProgrammes = <(String, String)>[
  ('Discovery Session', 'A first conversation to explore your goals.'),
  ('Focus Pack', 'A short series of sessions on one clear goal.'),
  ('Growth Journey', 'An ongoing programme for deeper, longer-term change.'),
];

const coachingFaqs = <(String, String)>[
  ('Who is individual coaching for?',
      'Anyone who wants support with their career, relationships or personal growth.'),
  ('How do sessions work?',
      'Sessions are one-to-one conversations, available online or in person.'),
  ('How long is each session?',
      'Session length and number of sessions are agreed with you after a first conversation.'),
  ('Is what I share confidential?',
      'Yes. Coaching conversations are private.'),
  ('How do I get started?',
      'Tap "Book a Coaching Session" and tell us a little about what you would like to work on.'),
];

const founderName = 'Mabel Tan KH';
const founderTitle = 'Founder | EQ Coach | HRDC Certified Trainer';

/// Add real team members here (name, role). The "Our Team" section on the
/// About page stays hidden until this list has entries.
const teamMembers = <(String, String)>[];
