# E2E Testing Framework

## Metadata

- **Driver:** Jon Psaila
- **Approver(s):** Jon Psaila
- **Contributors:**
- **Informed:**
- **Decision:** [What was ultimately decided?]
- **Date Decided:** [2025-05-13]

---

## 1. Define the Problem

- In order to ensure quality, and compliance with our core user journeys, we want to incorporate e2e tests into CI
- We currently don't have this, and our current tests are very granular to specific method testing and doesn't test overall flows
- This is unsatisfactory since we don't see how state changes over time and how that manifests for our users
- It's possible for us to make a core user journey less delightful by introducing changes, since we don't exhaustively test these journeys currently.

---

## 2. Specify the Objectives

- (Must have) Allows us to intract with the app within a testing env
- (Must have) We want to framework to be free
- We want a framework that works well with Ruby/Rails, or interfaces with it well
- (Must have) Integrates into CI
- (Nice to have) Ideally should be easily read by non technical folks (stakeholder-readable specs)
- (Nice to have) Supports parallel execution / performance to help keep CI pipelines fast, especially as test suites grow.
- (Nice to have) Supports cross-browser testing if the app has a user base across different platforms.
- (Nice to have) Supports visual regression testing to help catch UI regressions if your app is visual/content-heavy.
- (Nice to have) Good debugging tools / error feedback

---

## 3. Develop Alternatives

- Cypress
- Capybara + RSpec + Selenium/ChromeDriver
- Playwright
- TestCafe
- Cucumber + Capybara

---

## 4. Identify the Consequences

| Objective                                | Cypress                                   | Capybara + RSpec + Selenium              | Playwright                                 | TestCafe                                | Cucumber + Capybara                        |
| ---------------------------------------- | ----------------------------------------- | ---------------------------------------- | ------------------------------------------ | --------------------------------------- | ------------------------------------------ |
| Easy to work with / test env interaction | 4/5 – Intuitive API, browser-like testing | 5/5 – Native to Rails, deeply integrated | 4/5 – Slick modern tooling, slight JS bias | 3/5 – Simpler but not as intuitive      | 4/5 – Great for BDD, slight learning curve |
| Free                                     | 5/5 – Fully open source                   | 5/5 – Fully open source                  | 5/5 – Fully open source                    | 5/5 – Fully open source                 | 5/5 – Fully open source                    |
| Works with Rails / integrates well       | 3/5 – External to Rails                   | 5/5 – Perfect match for Rails            | 4/5 – Indirect integration, needs config   | 3/5 – Works via HTTP but no Rails magic | 5/5 – Built for Rails with BDD in mind     |
| CI Integration                           | 5/5 – Built for CI                        | 5/5 – Common CI pattern                  | 5/5 – Strong CI tooling                    | 5/5 – Simple headless runs              | 5/5 – Well-documented CI use               |
| Stakeholder Readability                  | 2/5 – Dev-focused                         | 3/5 – Understandable with effort         | 2/5 – JS-focused DSL                       | 2/5 – Technical syntax                  | 5/5 – Built for this                       |
| Parallel Test Support                    | 4/5 – Built-in                            | 2/5 – Manual setup via RSpec parallel    | 5/5 – First-class                          | 4/5 – Parallel runner                   | 2/5 – Needs setup via parallel_tests       |
| Cross-Browser Testing                    | 5/5 – Chrome, Firefox, Edge               | 3/5 – Possible but not common            | 5/5 – Chrome, Safari, Firefox, Edge        | 5/5 – Cross-browser out-of-box          | 3/5 – Limited focus here                   |
| Debugging / Developer UX                 | 5/5 – Amazing devtools                    | 3/5 – RSpec output driven                | 5/5 – Snapshots, videos                    | 3/5 – Basic feedback                    | 3/5 – CLI-based stacktraces                |
| Visual Regression Capabilities           | 4/5 – With plugins                        | 2/5 – Needs integration                  | 4/5 – Via tools like Percy                 | 3/5 – Plugins available                 | 2/5 – Requires external setup              |

---

## 5. Clarify the Tradeoffs

- Capybara + RSpec is great for deep Rails integration with minimal ceremony.
- Cypress or Playwright are good for JS-heavy UIs or if I want a slicker debugging/dev experience.
- Cucumber is a great fit given stakeholder-readable specs are a priority.
- TestCafe is your lightweight option if simplicity and cross-browser matters more than Rails-native ties.

- Overall, Cucumber is the optimal choice here. Its focus of behaviour driven development, ease of understanding, and ease of integration make it a solid choice.

---

## 6. Additional Considerations (Optional)

- Maintenance effort. Cucumber tests can get really verbose unless we use discipline.

---

## 7. Appendix

- [Cypress](https://docs.cypress.io/app/end-to-end-testing/writing-your-first-end-to-end-test)
- [Capybara](https://github.com/teamcapybara/capybara) + RSpec + [Selenium/ChromeDriver](https://www.youtube.com/watch?v=2TInLtG8dj4)
- [Playwright](https://playwright.dev/)
- [TestCafe](https://testcafe.io/)
- [Cucumber](https://cucumber.io/docs/gherkin/reference) + Capybara

---

> This template follows the PrOACT framework for structured decision-making. Adapt as necessary to fit the context and scale of your project.
