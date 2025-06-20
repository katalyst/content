import { application } from "controllers/application";

import content from "@katalyst/content";
import govuk from "@katalyst/govuk-formbuilder";
import tables from "@katalyst/tables";

application.load(content);
application.load(govuk);
application.load(tables);
