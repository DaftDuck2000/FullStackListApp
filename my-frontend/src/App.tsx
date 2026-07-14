import { useEffect, useState } from 'react';
import './App.css';
interface Item {
 id: number;
 name: string;
 priority: string;
 method: string;
}
function App() {
 const [items, setItems] = useState<Item[]>([]);
 const [name, setName] = useState('');
 const [priority, setPriority] = useState('');
 const [method, setMethod] = useState('');
  const [filterName, setFilterName] = useState('');
  const [filterPriority, setFilterPriority] = useState('');
  const [filterMethod, setFilterMethod] = useState('');
  async function loadItems(name?: string, priority?: string, method?: string) {
   const params = new URLSearchParams();
   if (name) params.append('name', name);
   if (priority) params.append('priority', priority);
   if (method) params.append('method', method);
   const qs = params.toString();
   const url = qs ? `/api/items?${qs}` : `/api/items`;
   const response = await fetch(url);
  const data = await response.json();
  setItems(data);
  }
 async function addItem(e: React.FormEvent) {
 e.preventDefault();
 if (!name.trim()) return;
 await fetch('/api/items', {
 method: 'POST',
 headers: { 'Content-Type': 'application/json' },
 body: JSON.stringify({ name, priority, method }),
 });
 setName('');
 setPriority('');
 setMethod('');
 loadItems();
 }
  async function removeItem(id: number) {
    await fetch(`/api/items`, { method: 'DELETE' ,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id })}
    );
    loadItems();
  }
   async function editItem(id: number) {
     await removeItem(id);
     var itemToEdit = items.find(item => item.id === id);
     setName(itemToEdit.name);
     setPriority(itemToEdit.priority);
     setMethod(itemToEdit.method);
   }
   async function resetList() {
    await fetch('/api/reset', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({}),
    });
    loadItems();
   }

 useEffect(() => { loadItems(); }, []);
  return (
     <div className="app">
       <h1>Items</h1>
       <form className="item-form" onSubmit={addItem}>
         <input id="NameInput" value={name} onChange={(e) => setName(e.target.value)} placeholder="New item" />
         <input id="PriorityInput" value={priority} onChange={(e) => setPriority(e.target.value)} placeholder="Priority" />
         <input id="MethodInput" value={method} onChange={(e) => setMethod(e.target.value)} placeholder="Method" />
         <button type="submit">Add</button>
         <button type='button' onClick={() => resetList()} >Reset</button>
       </form>
       <div className="filter-bar">
         <input placeholder="Search name" value={filterName} onChange={e => { setFilterName(e.target.value); loadItems(e.target.value, filterPriority, filterMethod); }} />
         <select value={filterPriority} onChange={e => { setFilterPriority(e.target.value); loadItems(filterName, e.target.value, filterMethod); }}>
           <option value="">All priorities</option>
           <option value="Low">Low</option>
           <option value="Medium">Medium</option>
           <option value="High">High</option>
         </select>
         <select value={filterMethod} onChange={e => { setFilterMethod(e.target.value); loadItems(filterName, filterPriority, e.target.value); }}>
           <option value="">All methods</option>
           <option value="1">1</option>
           <option value="2">2</option>
         </select>
       </div>
       <ul className="item-list">
         {items.map((item) => (
           <li className="item-card" key={item.id}>
             <div className="item-info">
               <div>{item.name}</div>
               <div className="meta">Priority: {item.priority} &middot; Method: {item.method}</div>
             </div>
             <div className="item-actions">
               <button className="btn-edit" onClick={() => editItem(item.id)}>Edit</button>
               <button className="btn-remove" onClick={() => removeItem(item.id)}>Remove</button>
             </div>
           </li>
         ))}
       </ul>
     </div>
   );
}
export default App;