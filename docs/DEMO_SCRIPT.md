# Demo Script - 13 Oct 2026 (about 5-7 minutes)

Run first: `flutter pub get` then `flutter run -d chrome`. Test once on the presenting laptop beforehand.
Split speaking parts between your 3 members (every member should present something).

| # | Say / do | Screen | Rubric area |
|---|---|---|---|
| 1 | Introduce MT Alchemy: people-development consultancy (EQ, leadership, team engagement, well-being). Four user groups: visitors, individuals, corporates, admins. Brand colours: Deep Blue, Soft Yellow, Purple. | Home | Introduction & brand |
| 2 | Show the top navigation (About, Services, Learn, Store, Insights, Contact, Sign in). Resize the browser window to show the bottom navigation and responsive layout. | Home | Scaffold & navigation |
| 3 | Open About and Services, return to Home. Point out the AppBar + body structure (Scaffold) on each screen. | About / Services | Scaffold |
| 4 | **Journey A:** Register -> submit empty form (show validation) -> fill in -> Login. | Register / Login | Form |
| 5 | Courses -> open a course -> Enrol -> Course Player -> Assessment -> Certificate. | LMS screens | Journey A |
| 6 | **Journey B:** Store -> search/filter -> product -> Add to cart -> Cart -> Checkout (show validation) -> confirmation. | Store / Cart / Checkout | Journey B, Form |
| 7 | Contact form and Corporate Learning enquiry (validation errors, then success). | Contact / Corporate | Form |
| 8 | Show the Container usage: cards, banners, badges (ProductCard, CourseCard widgets). Mention reusable widgets and AppTheme. | Store / Courses | Container, reusable code |
| 9 | Show sitemap, journey diagrams (A, B, C) and ER diagram from the report. Explain Journey C (employer) is documented now, built in the final project. | Report | IA & journeys |
| 10 | Wrap up: what is next (Firebase, payments, employer + admin portals). | - | - |

## Likely questions
- Why Flutter? One codebase for web, Android and iOS.
- Is there a backend? Not at Checkpoint 1; Firebase comes later.
- How is it responsive? LayoutBuilder / MediaQuery with different column counts and nav layouts.
- Where are Scaffold, Container, Form? See README and report sections 2-4.
