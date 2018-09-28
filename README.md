# GlanceCal
Very simple iOS Today View extensions/widgets for calendar events scheduled today and tomorrow

<!-- ![Example screenshots](https://raw.githubusercontent.com/jackhallybone/GlanceCal/master/Screenshots.png "Example screenshots") -->

<img src="https://raw.githubusercontent.com/jackhallybone/GlanceCal/master/Screenshots.png"  width='500' alt="Example screenshots">

----

### The Problem

The default iOS Calendar Today View widgets don't make much sense to me. At a glance I only really need to know about events that are scheduled for today and tomorrow.

### The Solution

Make two really quick and simple iOS Today View extensions/widgets that presents all the events scheduled for later today and tomorrow.

### Issues

*I don't yet know anything about Swift, iOS development or Xcode*. I like learning by trial and error so this project will probably contain a lot of blinding errors that I don't know about yet (but hopefully none that I do know about...).

----

### To Do:
- Add framework(?) to abstract eventkit code from each extension
- Hide "Show More" button when not required
- Extension resize does not match data/table size
- Add calendar colour on the left the default calendar app/extension
- Handle 12h and 24h display options
- Order the all day events as they are in the calendar app?
- Link to the event in the calendar app when pressed in extension?

### To Consider:
- Head the extension view with the day of the week and date of the day shown
- Show reminders due today and tomorrow (and any overdue?)
- Show alarms set in the clock app (not possible to access this data)
