import ContainerController from "./editor/container_controller";
import ItemController from "./editor/item_controller";
import ItemEditorController from "./editor/item_editor_controller";
import ListController from "./editor/list_controller";
import NewItemsController from "./editor/new_items_controller";
import StatusBarController from "./editor/status_bar_controller";
import TableController from "./editor/table_controller";
import TrixController from "./editor/trix_controller";

const Definitions = [
  {
    identifier: "content--editor--container",
    controllerConstructor: ContainerController,
  },
  {
    identifier: "content--editor--item",
    controllerConstructor: ItemController,
  },
  {
    identifier: "content--editor--item-editor",
    controllerConstructor: ItemEditorController,
  },
  {
    identifier: "content--editor--list",
    controllerConstructor: ListController,
  },
  {
    identifier: "content--editor--new-items",
    controllerConstructor: NewItemsController,
  },
  {
    identifier: "content--editor--status-bar",
    controllerConstructor: StatusBarController,
  },
  {
    identifier: "content--editor--table",
    controllerConstructor: TableController,
  },
  {
    identifier: "content--editor--trix",
    controllerConstructor: TrixController,
  },
];

export { Definitions as default };
