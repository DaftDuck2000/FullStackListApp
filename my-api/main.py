from fastapi import FastAPI
from pydantic import BaseModel
app = FastAPI()
items: list[dict] = []

names = ["Item1", "Item2", "Item3"]
Priorities = ["Low", "Medium", "High"]
Methods = ["1", "2"]

def addDefaults():
  items.clear()
  for name in names:
    for prio in Priorities:
      for metho in Methods:
        items.append({"name":f"Item {len(items) + 1}", "priority": prio, "method": metho, "id":len(items)})

class NewItem(BaseModel):
 id: str | None = None
 name: str
 priority: str = "low"
 method: str = "test"


@app.get("/items")
def get_items(priority: str = None, name: str = None, method: str = None):
 result = items
 if priority:
  result = [i for i in result if i["priority"] == priority]
 if name:
  result = [i for i in result if name.lower() in i["name"].lower()]
 if method:
  result = [i for i in result if i["method"] == method]
 return result

@app.post("/items")
def add_item(item: NewItem):
 new_item = {"id": len(items), "name": item.name, "priority": item.priority, "method": item.method}
 items.append(new_item)
 return new_item

@app.delete("/items")
def remove_item(body: dict):
 print(body)
 for i, item in enumerate(items):
  if item["id"] == body['id']:
   del items[i]
   break
 return {"ok": True}


@app.post("/reset")
def reset():
 addDefaults()
 return {"ok": True}