\# 🔗 LinkVault



\### Your personal library for useful links.



LinkVault is a Flutter-based web application designed to help you save, organize, and revisit useful websites and GitHub repositories in one place. Add personal notes to bookmarks, identify platforms through their icons, and quickly find saved links using search and category filters.



> 🚧 \*\*Status: In Development\*\* — LinkVault is being built incrementally as a learning project using Flutter and Firebase.



\---



\## ✨ Features



\### 🔐 Authentication

\- User registration with email and password.

\- Sign in using Firebase Authentication.

\- Persistent authentication sessions across browser refreshes.

\- Sign out securely from the dashboard.



\### 🔖 Bookmark Management

\- Save website URLs and GitHub repository links.

\- Add a custom title to each saved link.

\- Attach personal notes explaining why a link is useful.

\- Assign a category to each bookmark.

\- Remove bookmarks from the collection.



\### 🎨 Dashboard

\- Dark-themed interface with indigo accents.

\- Search saved links by title, URL, and category.

\- Filter bookmarks by category.

\- View statistics about saved links and matching results.

\- Display platform-specific icons, including GitHub and YouTube.

\- Add bookmarks through a dedicated dialog.



\### 🐙 GitHub Integration

\- Accept GitHub repository URLs.

\- Initial GitHub API integration is under development.

\- Planned repository cards will display descriptions, programming languages, stars, forks, and repository previews.



\---



\## 🛠️ Tech Stack



| Technology | Purpose |

|---|---|

| Flutter | Cross-platform UI development |

| Dart | Application programming language |

| Firebase Authentication | User registration and sign-in |

| Firebase Core | Firebase initialization |

| HTTP | API requests |

| GitHub REST API | Planned repository metadata integration |

| Cloud Firestore | Planned persistent bookmark storage |

| Firebase Storage | Planned screenshot storage |



\---



\## 📂 Project Structure



```text

linkvault/

├── lib/

│   ├── main.dart

│   ├── firebase\_options.dart

│   └── models/

│       └── bookmark.dart

├── android/

├── ios/

├── linux/

├── macos/

├── web/

├── windows/

├── test/

├── pubspec.yaml

├── pubspec.lock

├── analysis\_options.yaml

├── firebase.json

├── .gitignore

└── README.md

```



\---



\## 🚀 Getting Started



\### Prerequisites



Install the following:



\- \[Flutter SDK](https://docs.flutter.dev/get-started/install)

\- \[Dart SDK](https://dart.dev/get-dart) (included with Flutter)

\- \[Git](https://git-scm.com/downloads)

\- \[Visual Studio Code](https://code.visualstudio.com/) or another Flutter-compatible IDE

\- A Firebase project configured for your application



\### 1. Clone the repository



```bash

git clone https://github.com/YOUR\_USERNAME/LinkVault.git

cd LinkVault

```



Replace `YOUR\_USERNAME` with your GitHub username and adjust the repository name if necessary.



\### 2. Install dependencies



```bash

flutter pub get

```



\### 3. Configure Firebase



Create or select a project in the \[Firebase Console](https://console.firebase.google.com/).



Configure Firebase for your Flutter application and enable \*\*Email/Password\*\* authentication.



If you are setting up the project on a new machine, configure FlutterFire CLI and generate the Firebase options for your own Firebase project:



```bash

dart pub global activate flutterfire\_cli

flutterfire configure

```



Follow the CLI prompts and select your Firebase project and target platforms.



\*\*Security note:\*\* Never commit Firebase Admin SDK private keys, service account credentials, or other private secrets.



\### 4. Run the application



To launch LinkVault in Chrome:



```bash

flutter run -d chrome

```



To build the web application:



```bash

flutter build web

```



The production web files will be generated in `build/web/`.



\---



\## 🗺️ Roadmap



\- \[x] Flutter dashboard foundation

\- \[x] Firebase email/password registration

\- \[x] Firebase sign-in and persistent sessions

\- \[x] Save website and GitHub URLs in the current session

\- \[x] Add personal notes to bookmarks

\- \[x] Search and category filtering

\- \[x] Platform-specific icons

\- \[ ] Persistent bookmark storage using Cloud Firestore

\- \[ ] Multiple categories per bookmark

\- \[ ] Edit bookmark details and notes

\- \[ ] Automatic website title and description extraction

\- \[ ] Actual website screenshot previews

\- \[ ] GitHub repository metadata and preview cards

\- \[ ] Responsive production deployment



\---



\## 🔒 Security and Data Storage



LinkVault currently uses Firebase Authentication for user accounts. Bookmark data is currently held in application memory, so saved links and notes are not yet guaranteed to survive a browser refresh.



Cloud Firestore persistence and per-user data access rules are planned for a future development stage.



\---



\## 🤝 Contributing



Contributions, suggestions, and bug reports are welcome.



1\. Fork the repository.

2\. Create a feature branch.

3\. Make your changes.

4\. Test your changes.

5\. Open a pull request describing your contribution.



\---



\## 📄 License



No license has been selected yet. Until a license is added to this repository, please don't assume that the project is available for unrestricted reuse or redistribution.



\---



\## 👨‍💻 Author



\*\*Subhasis Mallick\*\*



Developed as a hands-on project to learn Flutter development, Firebase integration, API communication, and modern web application design.



\---



⭐ If you're interested in the development of LinkVault, follow the repository to see how it evolves.



