import { application } from "controllers/application";

import content from "@katalyst/content";
import tables from "@katalyst/tables";

application.load(content);
application.load(tables);

import govuk from "@katalyst/govuk-formbuilder";

govuk.start(application);
