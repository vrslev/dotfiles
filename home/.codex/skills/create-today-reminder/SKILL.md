---
name: create-today-reminder
description: Create one all-day reminder due today in macOS Reminders. Use when the user explicitly asks to add, create, or set a reminder for today in Apple Reminders or Reminders.app.
---

# Create Today Reminder

Create one reminder in the default list with today's local calendar date as its all-day due date.

1. Use the exact reminder title from the request without inventing details. An explicit request to create the reminder authorizes one creation; hypothetical questions and requests without a title do not.
2. Resolve this skill's directory and run:

   ```bash
   /usr/bin/osascript "<skill-dir>/scripts/create_today_reminder.applescript" "<title>"
   ```

   Pass the title as one safely shell-quoted argument. Never interpolate it into AppleScript source.
3. On success, report the exact title and that it is due today. Do not claim a notification time was set.
4. If the command fails after contacting Reminders, do not retry automatically because the first attempt may have succeeded. Ask the user to check Reminders before retrying.

Use the default Reminders list. “Today” is a smart view, not the destination list. Set `allday due date` without inventing an alert time, and let the script derive today from the Mac's local date. Do not enumerate existing reminders. If macOS denies access, explain that the calling app needs permission to control Reminders.
