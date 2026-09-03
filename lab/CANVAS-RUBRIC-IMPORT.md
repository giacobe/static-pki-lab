# Importing the Rubrics into Canvas

The files in `output/canvas/` use the Canvas Enhanced Rubrics CSV format.

## Import each rubric

1. Open the appropriate Canvas course.
2. Open **Rubrics** in the course navigation menu.
3. Select **Import Rubric**.
4. Upload one CSV file:
   - `PKI-Environment-Precursor-Canvas-Rubric.csv`
   - `Three-VM-PKI-Lab-Canvas-Rubric.csv`
5. Review the imported rubric and confirm that its total is 50 points.
6. Attach the imported rubric to the corresponding assignment and enable its
   use for grading if desired.

If **Import Rubric** is unavailable, ask the Canvas administrator whether
Enhanced Rubrics and rubric CSV import are enabled for the course or account.

## Imported structure

Each lab imports as a separate rubric. Evidence and Qualitative items are
separate Canvas criteria so that the grading split remains auditable:

- Evidence criteria total 30 points.
- Qualitative criteria total 20 points.
- Each criterion has full-credit, half-credit, and zero-credit ratings.

Canvas may allow a grader to enter a score between the listed ratings when
the criterion's range option is enabled. These files leave range scoring
disabled so graders select the defined rating levels consistently.
