# SimplyStyles: Visual Studio Code Setup Guide

Welcome to the SimplyStyles project! This guide will walk you through setting up your development environment in Visual Studio Code (VS Code) for a smooth and productive experience. I've already included a pre-configured `.vscode` folder in the project to get you started quickly.

## 1. Prerequisites

Before you begin, make sure you have the following installed:

- **Visual Studio Code**: The best code editor for Flutter. [Download it here](https://code.visualstudio.com/).
- **Flutter SDK**: The framework for building the app. [Installation Guide](https://docs.flutter.dev/get-started/install).
- **Git**: For version control (highly recommended). [Download it here](https://git-scm.com/).

## 2. Initial Setup

### Step 1: Open the Project in VS Code

1.  Unzip the `simplystyles_mvp.zip` file on your computer.
2.  Open VS Code.
3.  Go to **File > Open Folder...** and select the `simplystyles` folder.

### Step 2: Install Recommended Extensions

When you open the project, VS Code might show a notification in the bottom-right corner saying, "This workspace has recommended extensions." This is because I've included an `extensions.json` file.

1.  Click **Install** on that notification. This will automatically install all the recommended extensions for Flutter and Firebase development.

    *If you don't see the notification, go to the **Extensions** view (Ctrl+Shift+X), type `@recommended` in the search bar, and install them from there.*

    ![VS Code Recommended Extensions](https://i.imgur.com/8g3j4kL.png)

### Step 3: Get Flutter Packages

Open the integrated terminal in VS Code (**View > Terminal** or `Ctrl+\``) and run this command to download all the necessary project dependencies:

```bash
flutter pub get
```

## 3. Understanding the `.vscode` Folder

I've created a `.vscode` folder for you with pre-configured settings to make your life easier. Here's what each file does:

-   **`launch.json`**: This file configures how you run and debug the app. I've set up three launch configurations:
    -   **SimplyStyles (Debug)**: The default mode for development. It enables features like Hot Reload.
    -   **SimplyStyles (Profile)**: For analyzing your app's performance.
    -   **SimplyStyles (Release)**: For building the final, optimized version of your app.

-   **`settings.json`**: This file customizes your VS Code settings specifically for this project. It enables features like automatic formatting on save, sets the line length to 80 characters, and hides unnecessary folders from the file explorer.

-   **`extensions.json`**: This file lists all the recommended VS Code extensions for this project, which you installed in Step 2.

-   **`tasks.json`**: This file defines common commands you can run directly from VS Code. I've set up tasks for things like cleaning the project, getting packages, and deploying Firebase functions.

## 4. Running and Debugging the App

This is the fun part!

1.  **Select a Device**: In the bottom-right corner of the VS Code status bar, click on the device name (e.g., "Chrome (web)") to select a target device. You can choose a connected phone, an emulator/simulator, or a web browser.

    ![VS Code Device Selection](https://i.imgur.com/BqgY2XF.png)

2.  **Start Debugging**: Go to the **Run and Debug** view (Ctrl+Shift+D) on the left sidebar.

3.  **Select Configuration**: At the top, you'll see a dropdown menu. Make sure **"SimplyStyles (Debug)"** is selected.

4.  **Press Play**: Click the green play button (or press **F5**) to start the app. VS Code will build the app and launch it on your selected device.

    ![VS Code Run and Debug](https://i.imgur.com/tF5gJ7d.png)

### Hot Reload

One of Flutter's best features is **Hot Reload**. While the app is running in Debug mode:

-   Make a change to your code (e.g., change a text label).
-   Save the file (Ctrl+S).
-   The app will update instantly on your device without restarting! ⚡️

## 5. Using the Custom Tasks

I've set up some useful tasks to speed up your workflow.

1.  Open the Command Palette (**Ctrl+Shift+P**).
2.  Type **"Tasks: Run Task"** and press Enter.
3.  You'll see a list of the tasks I created in `tasks.json`:
    -   `Flutter: Clean`: Cleans the build directory.
    -   `Flutter: Get Packages`: Runs `flutter pub get`.
    -   `Firebase: Deploy Functions`: Deploys your backend code.

## 6. Securely Managing API Keys

Your project needs an API key for Gemini Cortex AI. It's very important **not to save your secret API key directly in the code**, especially if you plan to share your project on GitHub.

### Recommended Method: Environment Variables

1.  **Create a `.env` file**: In the root of your `simplystyles` folder, create a new file named `.env`.

2.  **Add your key to `.env`**: 
    ```
    GEMINI_CORTEX_API_KEY=your_super_secret_api_key_here
    ```

3.  **IMPORTANT: Add `.env` to `.gitignore`**: I have already added `.env` to the `.gitignore` file. This tells Git to **never** upload this file to GitHub, keeping your key safe.

4.  **Accessing the key in your code**: You'll need a package like `flutter_dotenv` to load these variables. I have not included it by default to keep the project simple, but it's a great next step!

For now, you can temporarily paste your key into the `lib/api/gemini_cortex_api.dart` file for testing, but remember to remove it before you commit your code to GitHub!

## 7. Next Steps

1.  **Follow the `SETUP_GUIDE.md`**: This guide has detailed instructions for setting up your Firebase project.
2.  **Explore the Code**: Start with `lib/main.dart` and navigate through the different screens and widgets.
3.  **Start Building**: Try changing some UI elements, adding a new feature, or connecting your actual Firebase backend.

Happy coding! If you have any more questions, just ask. You've got this! 🚀
