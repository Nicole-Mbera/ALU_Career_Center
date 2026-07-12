# ALU CAREER CENTER

A comprehensive mobile application designed to bridge the gap between student talent and student-led startups within the African Leadership University (ALU) ecosystem. Built as the final project for the Mobile Development course.

## Overview
Many students struggle to secure internships, while student entrepreneurs need support building their businesses. ALU Ventures provides a secure, verified platform for startups to post opportunities and for students to discover and apply for roles that genuinely match their skill sets.

## Key Features
* **Role-Based Authentication:** Distinct, secure onboarding and dashboards for 'Students' and 'Founders'.
* **Startup Verification:** Founders must upload a registration certificate to ensure platform trust and prevent spam.
* **Skill Matching Engine:** A local algorithm that calculates a 0-100% match score between a student's profile and an opportunity's required skills.
* **Real-Time Application Tracking:** Founders can manage their applicant pipeline (Under Review, Shortlisted, Accepted) which instantly updates on the student's dashboard.
* **Bookmarking:** Students can save opportunities for later viewing.
* **Secure CV Uploads:** Students can upload PDF CVs that founders can securely view in-browser.

##  Tech Stack & Architecture
* **Frontend:** Flutter (Dart) using a custom Material 3 Emerald theme.
* **State Management:** `Provider` (Selected for its seamless integration with continuous Firebase streams and performance scaling).
* **Primary Backend:** Firebase (Authentication & Cloud Firestore) for real-time NoSQL CRUD operations.
* **Binary Storage:** Supabase Storage. (Integrated specifically to host heavy PDF/Image files, bypassing Firebase Storage pricing limits and ensuring scalable bandwidth).

##  Getting Started

### Prerequisites
* Flutter SDK (Latest Version)
* Dart SDK
* An IDE (VS Code, Android Studio, etc.)
* iOS Simulator or Android Emulator

### Installation
1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/alu_ventures.git
   cd alu_ventures
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

*(Note: The project requires `google-services.json` and `GoogleService-Info.plist` files connected to your own Firebase project if cloning from scratch).*

## Architecture & Scalability Highlights
* **Flat NoSQL Schema:** Ensures infinite horizontal scaling by keeping root collections separate rather than deeply nesting documents.
* **Local Computing:** The matching engine runs on the client device rather than a Cloud Function, reducing server costs to zero.
* **Surgical UI Rebuilds:** Utilizing `context.watch()`, the UI only rebuilds specific widgets that change, maintaining a buttery smooth 60 FPS experience.

