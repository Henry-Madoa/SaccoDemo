-- Department on the Employee card is now powered by the existing Global Dimension 2 infrastructure
-- (global_dimension_2_value, already carried on employee.global_dimension_2_id for GL cost-centre
-- tagging) rather than a bespoke master — this app already uses Global Dimension 2 as "Department"
-- everywhere else (members, journal lines). The parallel hr_department table/column were redundant.
ALTER TABLE "employee" DROP COLUMN "department_id";
ALTER TABLE "employee_edit_request" DROP COLUMN "department_id";
DROP TABLE "hr_department";
