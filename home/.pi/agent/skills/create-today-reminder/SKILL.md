---
name: create-today-reminder
description: Create one all-day reminder due today in macOS Reminders in the default list. Use when the user explicitly says “remind me” with a today deadline or asks to add, create, or set a reminder for today in Apple Reminders or Reminders.app.
---

# Create Today Reminder

Create one reminder in the default list with today's local calendar date as its all-day due date.

## Workflow

1. Extract the exact reminder title from the user's request. Do not add details the user did not provide.
2. Treat an explicit request such as “Remind me to submit my timesheet today” as authorization to create one reminder. If the user asks only how to do it, speaks hypothetically, or does not provide a title, do not change Reminders.
3. Resolve this skill's directory and run:

   ```bash
   /usr/bin/osascript "<skill-dir>/scripts/create_today_reminder.applescript" "<title>"
   ```

   Pass the title as one safely shell-quoted argument. Never interpolate it into AppleScript source.
4. On success, report the exact title and that it is due today. Do not claim that a notification time was set.
5. If the command fails after contacting Reminders, do not retry automatically because the first attempt may have created the reminder. Report the error and ask the user to check Reminders before retrying.

## Boundaries

- Use the default Reminders list. “Today” is a smart view, not the destination list.
- Set `allday due date`, which adds the reminder to Today without inventing an alert time.
- Let the script derive today from the Mac's current local date.
- Do not enumerate or display existing reminders.
- If macOS denies access, stop and explain that the calling app needs permission to control Reminders.
