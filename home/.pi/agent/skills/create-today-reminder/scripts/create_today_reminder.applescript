on run argv
    if (count of argv) is not 1 then error "Expected exactly one reminder title." number 64

    set reminderTitle to item 1 of argv
    if reminderTitle is "" then error "The reminder title must not be empty." number 64

    set todayDate to current date
    set time of todayDate to 0

    tell application "Reminders"
        set targetList to default list
        set createdReminder to make new reminder at end of reminders of targetList with properties {name:reminderTitle, allday due date:todayDate}
        return name of createdReminder
    end tell
end run
