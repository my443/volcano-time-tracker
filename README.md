# Volcano Time Tracking
Last Updated 2015-06-15

## Description

A small program used to track the time you spend on each of your projects. Simply add the time worked for each project. View times by project, or by day.
All time entries can be exported to excel for further analysis.

**Manual can be [found here](/Volcano Time Tracking - Manual v1.0.pdf)**
 
<div align="center">

<img src="https://raw.githubusercontent.com/my443/volcano-time-tracker/master/img/Screenshot1.png" alt="Screenshot #1"><br>
Keep a list of all of your projects.<br>
<img src="https://raw.githubusercontent.com/my443/volcano-time-tracker/master/img/Screenshot2.png" alt="Screenshot #2"><br>
When you do work, enter the time that you worked on that project.<br>
<img src="https://raw.githubusercontent.com/my443/volcano-time-tracker/master/img/Screenshot3.png" alt="Screenshot #3"><br>
Time entries can hold notes and information on the work completed.<br>
<img src="https://raw.githubusercontent.com/my443/volcano-time-tracker/master/img/Screenshot4.png" alt="Screenshot #4"><br>
Summary of a selected date`s time entries are reported in the Today`s Time tab.<br>
<img src="https://raw.githubusercontent.com/my443/volcano-time-tracker/master/img/Screenshot4.png" alt="Screenshot #5"><br>
Edit project information and add notes.<br>

</div>

## Directory Structure

* /img - Screenshot images
* /bin - includes the compiled appication for Windows.
* /src - source code files

## Technology 

This application is written using [FreePascal.](https://www.freepascal.org/) 

Notes on Compilation
====================

1.  The Package LazDBExport is required to be installed before compiling.
2.  Volcano Time Tracking uses SQLite and may require the proper DLL (either in the .exe directory, or in the Path) for the program to work.

Fixes - VERSION 1.2
===================
2015-06-15 - Fixed an issue with the time entries list where not all entries were displaying when first opening the time entry screen.

Fixes - VERSION 1.1
===================

2015-03-31 -- Fixed the Time Entries List so that all of the entries are displayed in the time entry.

2015-03-31 -- Fixed the date fields so that the short date format of MM/DD/YY is used on all forms.
	** Previous entries can be converted by opening the dialog and saving it again.  Dates will convert automatically. **
	
2015-04-02 -- Added the clock icon to the volcano project.
	Icon is from http://www.flaticon.com/free-icon/small-wall-clock_3921

	Attribution text is here:
	Icon Made by Daniel Bruce from http://www.danielbruce.se
	
	<div>Icon made by <a href="http://www.danielbruce.se" title="Daniel Bruce">Daniel Bruce</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a> is licensed under <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>
	
2015-04-02 -- Change navigation page caption (title) to "Project List".
2015-04-02 -- Change Time entries caption (title) to "Time Entries"

Outstanding Bugs
================
2015-04-02 - Error when you try to enter time entry when there is no projects selected in the list.
(What happens if all of the projects are 'inactive'?)
