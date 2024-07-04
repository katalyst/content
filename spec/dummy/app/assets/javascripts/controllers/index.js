import { application } from "controllers/application";

import content from "@katalyst/content";
import kpop from "@katalyst/kpop";
import tables from "@katalyst/tables";

application.load(content);
application.load(kpop);
application.load(tables);
