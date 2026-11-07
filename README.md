# 🏷  Student Grade Report Parser

A Bash script that cleans, processes, validates, and ranks student grades from a CSV file.

## 📌 Problem Statement

Rebase instructors receive a spreadsheet of scores and spend an evening calculating averages and rankings by hand. Build grades.sh helps the instructors to take two seconds.

## 🎯 Project Goals

- collect scores for students in their various courses
- calculate the total score per student
- calculate the average per studen
- get the rank of each student based on their scores
- give their mentions with respet to their averages

## Setup & Execution

Clone the repository and navigate to the project directory:

```bash
git clone <your-repo-url>
cd Bash-09-grade-report
chmod +x grades.sh
```

Run the script by providing the path to a grade CSV file:

```bash
./grades.sh grades.csv
```

## Sample Output

```text
RANK NAME             HTML  CSS BASH  GIT AVERAGE MENTION
   1 Brenda Fon         19   20   18   17   18.50 Très bien
   2 Becky              18   18   17   16   17.25 Très bien
   3 Kevin Tabi         12   11   11   12   11.50 Passable
----------------------------------------------
Class average: 15.75
Skipped 2 invalid lines (see warnings above)
```

## 🛠 Tech Stack

bash
Git
GitHub

## 📷 Screenshots

![ bash grade_report ](<assets/images/Screenshot From 2026-11-03 14-28-22.png>)

## ⚙ Installation & Setup

clone the repository

```bash
    git clone https://github.com/NyapB/Bash-09-grade-report.git

    - cd Bash_09_grade_report
    - give permission using chmod +x grades.sh
    - run with ./grades.sh
```

## 🧠 Challenges Faced

- identifying a file
- looping through to validate the information in the file
- carrying calculations as bash does not work with decimals

## 📚 What I Learned

- strengthen checks using while loops and if statements
- compressing codes inorder to have very long codes

## 👨🏽‍💻 Author

Nyap Becky Beri

Junior Fullstack Developer

[beribecky8@gmail.com](mailto:beribecky8@gmail.com)

🌍 Based in Cameroon | Open to remote opportunities
