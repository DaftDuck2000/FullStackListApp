import express from 'express';
const app = express();
app.use(express.json());
const API_URL = 'http://localhost:8000';

app.get('/api/items', async (req, res) => {
    const params = new URLSearchParams(req.query).toString();
    const url = params ? `${API_URL}/items?${params}` : `${API_URL}/items`;
    const response = await fetch(url);
    const data = await response.json();
    res.json(data);
})

app.post('/api/items', async (req, res) => {
 const response = await fetch(`${API_URL}/items`, {
 method: 'POST',
 headers: { 'Content-Type': 'application/json' },
 body: JSON.stringify(req.body),
 });
 const data = await response.json();
 res.json(data);
});

app.delete('/api/items', async (req, res) => {
    const response = await fetch(`${API_URL}/items`, {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(req.body),
    });
    const data = await response.json();
    res.json(data);
});

app.post('/api/reset', async (req, res) => {
    const response = await fetch (`${API_URL}/reset`, {
 method: 'POST',
 headers: { 'Content-Type': 'application/json' },
 body: JSON.stringify(),
 });
 const data = await response.json();
 res.json(data);
});

app.listen(3001, () => console.log('BFF running on http://localhost:3001'));