# 📁 Download Organizer

A free, lightweight Windows PowerShell tool that automatically organizes your **Downloads folder** into categorized folders based on file types.

Instead of manually sorting downloaded files, Download Organizer monitors your Downloads folder and automatically moves files such as documents, images, videos, audio, archives, installers, and more into their appropriate folders.

Designed to be **simple, lightweight, customizable, and completely free for everyone.**

## ✨ Features

* ⚡ Automatically organizes downloaded files
* 📂 Sorts files based on their extensions
* 🔄 Continuously monitors the Downloads folder
* 🖥️ Can run silently in the background
* 🪶 Lightweight and resource-efficient
* 🔧 Fully customizable categories and file extensions
* 🚫 No paid features
* 🚫 No subscriptions
* 🚫 No advertisements
* 🚫 No third-party software required
* 🪟 Built with Windows PowerShell
* 🆓 Free and open source

## 📥 Installation

### 1. Download the Project

Clone the repository:

```powershell
git clone https://github.com/YOUR-USERNAME/download-organizer.git
```

Or click **Code → Download ZIP** on GitHub and extract the ZIP file.

### 2. Open the Project Folder

Open PowerShell inside the project folder:

```powershell
cd download-organizer
```

### 3. Allow PowerShell Scripts

If Windows prevents the script from running, open PowerShell and run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

Press **Y** to confirm.

> This changes the execution policy only for your current Windows user account.

## ▶️ Usage

Run the organizer with:

```powershell
.\DownloadOrganizer.ps1
```

The script will monitor your Downloads folder and automatically organize new files.

For example:

```text
Downloads
├── Documents
├── Images
├── Videos
├── Audio
├── Archives
├── Installers
└── Others
```

If you download:

```text
example.pdf
```

the organizer can automatically move it to:

```text
Downloads\Documents\example.pdf
```

## 🚀 Run Automatically in the Background

You can configure Windows Task Scheduler to start the organizer automatically when you log in.

1. Press **Win + R**
2. Type `taskschd.msc`
3. Select **Create Task**
4. Create a trigger for **At log on**
5. Create an action to start:

```text
powershell.exe
```

6. Add the following arguments:

```text
-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Path\To\DownloadOrganizer.ps1"
```

After setup, the organizer can start automatically with Windows and run without keeping a visible PowerShell window open.

## ⚙️ Customization

You can customize the organizer to match your workflow.

The script can be modified to change:

* 📁 Folder categories
* 📄 File extensions
* 📍 Downloads folder location
* 🗂️ Handling of unknown file types
* 🔄 Monitoring behavior
* 🖥️ Startup behavior

Open `DownloadOrganizer.ps1` in any text editor and modify the configuration to your requirements.

## 🔒 Privacy

Download Organizer is designed to work locally on your Windows computer.

It does not require an online account or cloud service to organize your files.

## 🆓 Free for Everyone

Download Organizer is provided **free of charge** for personal and commercial use.

You are free to:

* Use it
* Modify it
* Share it
* Fork it
* Improve it
* Include it in your own projects

No subscription or payment is required.

## 🤝 Contributing

Contributions, improvements, bug fixes, and new ideas are welcome.

Feel free to open an **Issue** or submit a **Pull Request**.

## 📄 License

This project is licensed under the **MIT License**.

You are free to use, modify, distribute, and share this software under the terms of the license.

---

### 🎯 Keep your Downloads folder clean automatically.

**Download it. Run it. Forget about manually organizing your files.**

